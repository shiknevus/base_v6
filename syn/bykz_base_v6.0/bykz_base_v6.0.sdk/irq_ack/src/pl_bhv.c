// @file pl_bhv.c
// A-channel behavior FSM

#include "pl_bhv.h"
#include "pl_reg.h"
#include "pl_comp.h"
#include "util.h"

#include "xil_io.h"
#include "xil_printf.h"

static BhvState       bhv_state = BHV_IDLE;
static IrqSlot       *bhv_slot  = NULL;
static u8             bhv_id    = 0;
static u32            bhv_deadline = 0;

// last acked
static u32 last_acked_reg1[NUM_IRQ_SLOTS];

// id check
#define EC_ID_VAL 0x88U
#define SC_ID_VAL 0x66U

// tx timeout
static u32 BhvTxTimeout(u8 id)
{
	if (id == 1U || id == 2U || id == 3U || id == 20U || id == 21U)
		return 30U;
	return 3U;
}

// ack event
static void PsIrqAck(IrqSlot *slot, u32 irq_reg1, u32 irq_reg2)
{
	u32 bhv_id, irq_num, status, resp, hdr, rpt_off;
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

	hdr = (irq_reg1 >> 16) & 0xFFFFU;
	if (hdr != ((EC_ID_VAL << 8) | SC_ID_VAL))
		xil_printf("[%08u]  [%s] !! IRQ_REG1 hdr=0x%04x expect 0x%04x\r\n",
			   (unsigned)ts_ms(), slot->name, (unsigned)hdr,
			   (unsigned)((EC_ID_VAL << 8) | SC_ID_VAL));

	// B channel rpt
	if (bhv_id >= 100U) {
		status  = (irq_num == 0x28U) ? 0x5101U : 0x5100U;
		rpt_off = B_TX_RSULT_RPT;
	} else {
		if (bhv_id == 1U || bhv_id == 2U)
			status = (irq_num == 0x28U) ? 0x5101U : 0x5100U;
		else
			status = (irq_num == 0x28U) ? 0x5199U : 0x5167U;
		rpt_off = A_TX_RSULT_RPT;
	}

	resp = (bhv_id << 24) | (irq_num << 16) | status;
	Xil_Out32(slot->base_addr + rpt_off, resp);
	xil_printf("[%08u]  [%s] -> %s=0x%08x (bhv=%u tx=%u %s)\r\n",
		   (unsigned)ts_ms(), slot->name,
		   (rpt_off == B_TX_RSULT_RPT) ? "B_TX_RSULT_RPT" : "A_TX_RSULT_RPT",
		   (unsigned)resp, (unsigned)bhv_id, (unsigned)irq_num,
		   (irq_num == 0x28U) ? "FAIL" : "SUCCESS");

	for (idx = 0; idx < NUM_IRQ_SLOTS; idx++)
		if (&irq_table[idx] == slot) {
			last_acked_reg1[idx] = irq_reg1;
			break;
		}
}

// trigger A bhv
void BhvStart(IrqSlot *slot, u8 id)
{
	u32 ot = BhvTxTimeout(id);

	xil_printf("[%08u] \r\n[BHV %u] %s @0x%08x (A_TX_OT=%us)...\r\n",
		   (unsigned)ts_ms(), (unsigned)id, slot->name, (unsigned)slot->base_addr,
		   (unsigned)ot);
	Xil_Out32(slot->base_addr + A_TX_OT, ot);
	Xil_Out32(slot->base_addr + A_BHV_ID, (u32)id);

	bhv_slot  = slot;
	bhv_id    = id;
	bhv_state = BHV_WAIT_REQ;
	bhv_deadline = ts_ms() + 5000U;
}

// deadline expired
void BhvTimeout(void)
{
	u32 diag_irq1, diag_isr, diag_ier, diag_imr;
	u32 dbg1;

	diag_irq1 = Xil_In32(bhv_slot->base_addr + IRQ_REG1);

	// tx10 pending but missed: blind ack 10
	if ((diag_irq1 & 0xFFU) == 0x0AU && bhv_state == BHV_WAIT_REQ &&
	    ((diag_irq1 >> 8) & 0xFFU) == (u32)bhv_id) {
		xil_printf("[%08u] [BHV %u] %s missed tx10, blind ack...\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, bhv_slot->name);
		Xil_Out32(bhv_slot->base_addr + A_TX_RSULT_RPT,
			  ((u32)bhv_id << 24) | (0x0AU << 16) | 0x5100U);
		bhv_state   = BHV_WAIT_RESULT;
		bhv_deadline = ts_ms() + (BhvTxTimeout(bhv_id) + 10U) * 1000U;
		return;
	}

	// A stuck in S_SUCC_30_ACK: blind ack to unstick
	dbg1 = Xil_In32(bhv_slot->base_addr + DEBUG_REG1);
	if ((dbg1 & 0xFFU) == 0x09U && bhv_state == BHV_WAIT_RESULT) {
		const char *nm = bhv_slot->name;
		xil_printf("[%08u] [BHV %u] %s stuck 30, blind ack...\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, nm);
		Xil_Out32(bhv_slot->base_addr + A_TX_RSULT_RPT,
			  ((u32)bhv_id << 24) | (0x1EU << 16) | 0x5100U);
		bhv_state = BHV_IDLE;
		bhv_slot  = NULL;
		xil_printf("[%08u] [BHV %u] %s COMPLETE!\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, nm);
		return;
	}

	xil_printf("[%08u] [BHV %u] %s TIMEOUT (state=%s, isr=%u drop=%u)\r\n",
		   (unsigned)ts_ms(), (unsigned)bhv_id, bhv_slot->name,
		   (bhv_state == BHV_WAIT_REQ) ? "req" : "result",
		   (unsigned)IntcIsrCount(), (unsigned)EvDropCountGet());

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

// event -> FSM
void ProcessEvent(const IrqEvent *ev)
{
	u32 num    = ev->irq_reg1 & 0xFFU;
	u32 ev_bhv = (ev->irq_reg1 >> 8) & 0xFFU;
	IrqSlot *slot = ev->slot;
	int idx;

	if (ev->irq_reg1 == 0U)
		return;

	for (idx = 0; idx < NUM_IRQ_SLOTS; idx++)
		if (&irq_table[idx] == slot)
			break;
	if (idx < NUM_IRQ_SLOTS && ev->irq_reg1 == last_acked_reg1[idx])
		return;

	// bhv=0: B done / A idle
	if (ev_bhv == 0U && bhv_state == BHV_IDLE) {
		Xil_Out32(slot->base_addr + B_TX_RSULT_RPT, (num << 16) | 0x5167U);
		return;
	}

	// B: always ack
	if (ev_bhv >= 100U) {
		xil_printf("[%08u]  [%s] B bhv=%u tx=0x%02x ack...\r\n",
			   (unsigned)ts_ms(), slot->name, (unsigned)ev_bhv, (unsigned)num);
		PsIrqAck(slot, ev->irq_reg1, ev->irq_reg2);
		return;
	}

	// A: 40 without 0x0A (pre/undefined bhv)
	if (bhv_state == BHV_WAIT_REQ && slot == bhv_slot &&
	    num == 0x28U && ev_bhv == bhv_id) {
		xil_printf("[%08u] [BHV %u] %s FAIL(0x28) no-req ack...\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, slot->name);
		PsIrqAck(slot, ev->irq_reg1, ev->irq_reg2);
		xil_printf("[%08u] [BHV %u] %s COMPLETE!\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, slot->name);
		bhv_state = BHV_IDLE;
		bhv_slot  = NULL;
		return;
	}

	// A channel: request
	if (bhv_state == BHV_WAIT_REQ && slot == bhv_slot &&
	    num == 0x0AU && ev_bhv == bhv_id) {
		xil_printf("[%08u] [BHV %u] %s irq_num=0x%02x ack...\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, slot->name, (unsigned)num);
		PsIrqAck(slot, ev->irq_reg1, ev->irq_reg2);
		bhv_state   = BHV_WAIT_RESULT;
		// pause window
		bhv_deadline = ts_ms() + (BhvTxTimeout(bhv_id) + 10U) * 1000U;
		return;
	}

	// A channel: result
	if (bhv_state == BHV_WAIT_RESULT && slot == bhv_slot &&
	    (num == 0x1EU || num == 0x28U) && ev_bhv == bhv_id) {
		xil_printf("[%08u] [BHV %u] %s %s(0x%02x) ack...\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, slot->name,
			   (num == 0x1EU) ? "SUCCESS" : "FAIL", (unsigned)num);
		PsIrqAck(slot, ev->irq_reg1, ev->irq_reg2);
		xil_printf("[%08u] [BHV %u] %s COMPLETE!\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, slot->name);
		{
			u32 p51 = Xil_In32(slot->base_addr + PARAM51);
			xil_printf("[%08u] [BHV %u] %s POS pulse=%d = ",
				   (unsigned)ts_ms(), (unsigned)bhv_id, slot->name, (int)p51);
			PrintFp(PulseToMm(p51));
			xil_printf(" mm%s\r\n", (bhv_id == 30U) ? " [GETPOS]" : "");
		}
		bhv_state = BHV_IDLE;
		bhv_slot  = NULL;
		return;
	}

	// early ACK
	if (ev_bhv == 0U && num == 0x1EU &&
	    bhv_state == BHV_WAIT_RESULT && slot == bhv_slot) {
		u32 dbg1 = Xil_In32(slot->base_addr + DEBUG_REG1);
		if ((dbg1 & 0xFFU) == 0x09U) {
			xil_printf("[%08u] [BHV %u] %s stuck 30, blind ack...\r\n",
				   (unsigned)ts_ms(), (unsigned)bhv_id, slot->name);
			bhv_state = BHV_IDLE;
			bhv_slot  = NULL;
			xil_printf("[%08u] [BHV %u] %s COMPLETE!\r\n",
				   (unsigned)ts_ms(), (unsigned)bhv_id, slot->name);
		}
		Xil_Out32(slot->base_addr + A_TX_RSULT_RPT,
			  ((u32)bhv_id << 24) | (0x1EU << 16) | 0x5100U);
		Xil_Out32(slot->base_addr + B_TX_RSULT_RPT, (0x1EU << 16) | 0x5167U);
		return;
	}

	// other events
	if (ev->irq_reg1 != 0U) {
		if (ev_bhv == 0U) {
			u32 b_bhv = Xil_In32(slot->base_addr + B_BHV_ID);
			xil_printf("[%08u]  [%s] bg bhv=0 tx=0x%02x (B_BHV_ID=%u) -> B rpt\r\n",
				   (unsigned)ts_ms(), slot->name, (unsigned)num, (unsigned)b_bhv);
			Xil_Out32(slot->base_addr + B_TX_RSULT_RPT, (num << 16) | 0x5167U);
			return;
		}
		xil_printf("[%08u]  [%s] bg irq_num=0x%02x ack...\r\n",
			   (unsigned)ts_ms(), slot->name, (unsigned)num);
		PsIrqAck(slot, ev->irq_reg1, ev->irq_reg2);
	}
}

// poll fallback
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

		// comp finished: safe to clear IAR
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
