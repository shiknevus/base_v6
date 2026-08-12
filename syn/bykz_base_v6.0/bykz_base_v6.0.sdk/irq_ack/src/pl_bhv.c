// @file pl_bhv.c
// Behavior transaction state machine (main-loop context)

#include "pl_bhv.h"
#include "pl_reg.h"
#include "util.h"

#include "xil_io.h"
#include "xil_printf.h"

static BhvState       bhv_state = BHV_IDLE;
static IrqSlot       *bhv_slot  = NULL;
static u8             bhv_id    = 0;
static u32            bhv_deadline = 0;

// last acked IRQ_REG1 per component, for stale-duplicate suppression
// (HW keeps IRQ asserted until A_TX_RSULT_RPT is written, so the ISR can
//  fire several times before the ACK lands; only the first event matters)
static u32 last_acked_reg1[NUM_IRQ_SLOTS];

// EC/SC ids programmed at init; IRQ_REG1[31:16] must echo them back.
#define EC_ID_VAL 0x88U
#define SC_ID_VAL 0x66U

// Per-behavior RTL tx timeout (seconds): motion behaviors get a long window,
// others (virtual/GETPOS/undefined) a short one so the 40-timeout path is
// reachable within the PS deadline.
static u32 BhvTxTimeout(u8 id)
{
	if (id == 1U || id == 2U || id == 3U || id == 20U || id == 21U)
		return 30U;
	return 3U;
}

// ACK with the values captured in the event (main-loop context only)
static void PsIrqAck(IrqSlot *slot, u32 irq_reg1, u32 irq_reg2)
{
	u32 bhv_id, irq_num, status, resp, hdr;
	int idx;

	if (irq_reg1 == 0U)
		return;

	xil_printf("[%08u]  [%s] IRQ_REG2=0x%08x IRQ_REG1=0x%08x\r\n",
		   (unsigned)ts_ms(), slot->name, (unsigned)irq_reg2, (unsigned)irq_reg1);

	if (irq_reg2 != 0U)
		xil_printf("[%08u]  [%s] ALARM num=0x%02x\r\n",
			   (unsigned)ts_ms(), slot->name,
			   (unsigned)((irq_reg2 >> 24) & 0xFFU));

	bhv_id  = (irq_reg1 >> 8) & 0xFFU;
	irq_num = irq_reg1 & 0xFFU;

	// sanity: arbiter packs {ec_id,sc_id} into IRQ_REG1[31:16]
	hdr = (irq_reg1 >> 16) & 0xFFFFU;
	if (hdr != ((EC_ID_VAL << 8) | SC_ID_VAL))
		xil_printf("[%08u]  [%s] !! IRQ_REG1 hdr=0x%04x expect 0x%04x (ec/sc id)\r\n",
			   (unsigned)ts_ms(), slot->name, (unsigned)hdr,
			   (unsigned)((EC_ID_VAL << 8) | SC_ID_VAL));

	if (bhv_id == 1U || bhv_id == 2U)
		status = (irq_num == 0x28U) ? 0x5101U : 0x5100U;
	else
		status = (irq_num == 0x28U) ? 0x5199U : 0x5167U;

	resp = (bhv_id << 24) | (irq_num << 16) | status;
	Xil_Out32(slot->base_addr + A_TX_RSULT_RPT, resp);
	xil_printf("[%08u]  [%s] -> A_TX_RSULT_RPT=0x%08x (bhv=%u irq_num=%u %s)\r\n",
		   (unsigned)ts_ms(), slot->name, (unsigned)resp, (unsigned)bhv_id, (unsigned)irq_num,
		   (irq_num == 0x28U) ? "FAIL" : "SUCCESS");

	for (idx = 0; idx < NUM_IRQ_SLOTS; idx++)
		if (&irq_table[idx] == slot) {
			last_acked_reg1[idx] = irq_reg1;
			break;
		}
}

// Trigger a behavior on the given component (async, returns immediately)
void BhvStart(IrqSlot *slot, u8 id)
{
	u32 ot = BhvTxTimeout(id);

	xil_printf("[%08u] \r\n[BHV %u] %s @0x%08x (A_TX_OT=%us)...\r\n",
		   (unsigned)ts_ms(), (unsigned)id, slot->name, (unsigned)slot->base_addr,
		   (unsigned)ot);
	// per-behavior RTL tx timeout before triggering
	Xil_Out32(slot->base_addr + A_TX_OT, ot);
	Xil_Out32(slot->base_addr + A_BHV_ID, (u32)id);

	bhv_slot  = slot;
	bhv_id    = id;
	bhv_state = BHV_WAIT_REQ;
	bhv_deadline = ts_ms() + 5000U;   // req(0x0A) wait, 5s
}

// Called from main loop: deadline expired
void BhvTimeout(void)
{
	u32 diag_irq1, diag_isr, diag_ier, diag_imr;

	xil_printf("[%08u] [BHV %u] %s TIMEOUT (state=%s, isr=%u drop=%u)\r\n",
		   (unsigned)ts_ms(), (unsigned)bhv_id, bhv_slot->name,
		   (bhv_state == BHV_WAIT_REQ) ? "req" : "result",
		   (unsigned)IntcIsrCount(), (unsigned)EvDropCountGet());

	// diag: component IRQ_REG1 (arbiter packing) + axi_intc0 ISR/IER/IMR
	diag_irq1 = Xil_In32(bhv_slot->base_addr + IRQ_REG1);
	diag_isr  = Xil_In32(intc_desc[0].baseaddr + 0x0CU);
	diag_ier  = Xil_In32(intc_desc[0].baseaddr + 0x08U);
	diag_imr  = Xil_In32(intc_desc[0].baseaddr + 0x04U);
	xil_printf("DIAG irq1=0x%08x isr=0x%08x ier=0x%08x imr=0x%08x\r\n",
		   (unsigned)diag_irq1, (unsigned)diag_isr,
		   (unsigned)diag_ier, (unsigned)diag_imr);

	bhv_state = BHV_IDLE;
	bhv_slot  = NULL;
}

// Consume one queued event, advance the behavior state machine.
void ProcessEvent(const IrqEvent *ev)
{
	u32 num = ev->irq_reg1 & 0xFFU;
	IrqSlot *slot = ev->slot;
	int idx;

	if (ev->irq_reg1 == 0U)
		return;

	// stale duplicate of an already-acked interrupt -> drop
	for (idx = 0; idx < NUM_IRQ_SLOTS; idx++)
		if (&irq_table[idx] == slot)
			break;
	if (idx < NUM_IRQ_SLOTS && ev->irq_reg1 == last_acked_reg1[idx])
		return;   // duplicate of last acked event (IRQ_REG1 holds last value)

	// expected "request" interrupt
	if (bhv_state == BHV_WAIT_REQ && slot == bhv_slot && num == 0x0AU) {
		xil_printf("[%08u] [BHV %u] %s irq_num=0x%02x ack...\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, slot->name, (unsigned)num);
		PsIrqAck(slot, ev->irq_reg1, ev->irq_reg2);
		bhv_state   = BHV_WAIT_RESULT;
		bhv_deadline = ts_ms() + 5000U;   // result wait, 5s
		return;
	}

	// expected "result" interrupt
	if (bhv_state == BHV_WAIT_RESULT && slot == bhv_slot &&
	    (num == 0x1EU || num == 0x28U)) {
		xil_printf("[%08u] [BHV %u] %s %s(0x%02x) ack...\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, slot->name,
			   (num == 0x1EU) ? "SUCCESS" : "FAIL", (unsigned)num);
		PsIrqAck(slot, ev->irq_reg1, ev->irq_reg2);
		xil_printf("[%08u] [BHV %u] %s COMPLETE!\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, slot->name);
		// report the tracked absolute position after the transaction
		{
			u32 p51 = Xil_In32(slot->base_addr + PARAM51);
			xil_printf("[%08u] [BHV %u] %s POS abs_pulse=%d (0x%08x)%s\r\n",
				   (unsigned)ts_ms(), (unsigned)bhv_id, slot->name,
				   (int)p51, (unsigned)p51,
				   (bhv_id == 30U) ? " [GETPOS]" : "");
		}
		bhv_state = BHV_IDLE;
		bhv_slot  = NULL;
		return;
	}

	// background / non-matching interrupt: ack immediately so HW deasserts.
	// (stale duplicates of the in-flight target event are already filtered
	//  by last_acked_reg1, and events of the target slot which do not match
	//  the current transition are not re-acked while a behavior is running)
	if (bhv_state != BHV_IDLE && slot == bhv_slot) {
		xil_printf("[%08u]  [%s] unexpected irq_num=0x%02x while BHV active, dropped\r\n",
			   (unsigned)ts_ms(), slot->name, (unsigned)num);
		return;
	}
	if (ev->irq_reg1 != 0U) {
		xil_printf("[%08u]  [%s] bg irq_num=0x%02x ack...\r\n",
			   (unsigned)ts_ms(), slot->name, (unsigned)num);
		PsIrqAck(slot, ev->irq_reg1, ev->irq_reg2);
	}
}

// Fallback: poll INTC ISR directly and feed the same state machine.
// The ISR path (GIC) may be unreliable; polling the INTC level is
// what the original BM did, so keep it as a safety net.
void PollIntcFallback(void)
{
	u32 base = intc_desc[0].baseaddr;
	u32 pending = Xil_In32(base + INTC_ISR) & Xil_In32(base + INTC_IER);

	for (int i = 0; i < NUM_IRQ_SLOTS && pending; i++) {
		if (!irq_table[i].name) continue;
		if (irq_table[i].intc_idx != 0) continue;
		u32 m = 1U << irq_table[i].intc_bit;
		if (!(pending & m)) continue;

		IrqEvent ev;
		ev.slot     = &irq_table[i];
		ev.irq_reg2 = Xil_In32(irq_table[i].base_addr + IRQ_REG2);
		ev.irq_reg1 = Xil_In32(irq_table[i].base_addr + IRQ_REG1);
		ev.tick     = ts_ms();

		// IRQ_REG1 == 0 while the bit is set: the component has finished
		// the transaction and returned to IDLE, so its irq line is low
		// again. Clearing the latched INTC bit is SAFE now (no pending
		// edge to lose) and prevents poll from spinning forever on the
		// stale bit. Do NOT clear it earlier: the component re-asserts
		// within microseconds of the ack (S_SUCC_30), and clearing the
		// edge during that window loses the event forever.
		if (ev.irq_reg1 == 0U) {
			Xil_Out32(base + INTC_IAR, m);
			continue;
		}

		ProcessEvent(&ev);
		pending &= ~m;
	}
}

void BhvResetAck(void)
{
	for (int i = 0; i < NUM_IRQ_SLOTS; i++)
		last_acked_reg1[i] = 0;
}

int BhvIsRunning(void)
{
	return (bhv_state != BHV_IDLE);
}

u8 BhvActiveId(void)
{
	return bhv_id;
}

const char *BhvActiveName(void)
{
	return bhv_slot ? bhv_slot->name : "";
}

u32 BhvDeadline(void)
{
	return bhv_deadline;
}
