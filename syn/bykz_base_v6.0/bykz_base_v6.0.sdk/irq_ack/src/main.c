// @file main.c

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xil_exception.h"
#include "xil_io.h"
#include "xil_cache.h"
#include "xscugic.h"
#include "xintc.h"
#include "xuartps_hw.h"
#include "sleep.h"

// ARM generic timer helpers (Cortex-A53)
static inline u64 get_cntpct(void) {
	u64 cnt;
	__asm__ volatile("mrs %0, cntpct_el0" : "=r"(cnt));
	return cnt;
}
static inline u32 get_cntfrq(void) {
	u32 freq;
	__asm__ volatile("mrs %0, cntfrq_el0" : "=r"(freq));
	return freq;
}
static u32 ts_ms(void) {
	static u32 freq;
	if (!freq) freq = get_cntfrq();
	return (u32)(get_cntpct() / (freq / 1000));
}

#define PL_CFG_BASE          XPAR_PLCFG_M_AXI_BASEADDR    // 0xB0100000

// Component register offset base address
#define REG_BIAS_EC_1DI         0x0800U
#define REG_BIAS_EC_1DO         0x0A00U
#define REG_BIAS_EC_2DI_2DO     0x0C00U
#define REG_BIAS_EC_3DI_2DO     0x0E00U
#define REG_BIAS_EC_3DI_1DO     0x1000U
#define REG_BIAS_EC_1DI_1DO     0x1200U
#define REG_BIAS_EC_4DI_2DO     0x1400U
#define REG_BIAS_EC_3LED        0x1600U
#define REG_BIAS_EC_5DI         0x1800U
#define REG_BIAS_EC_PUL_AXIS    0x1A00U
#define REG_BIAS_EC_SLV_PUL_AXIS 0x1C00U

// Register offsets
#define IRQ_REG1             0x000U
#define IRQ_REG2             0x004U
#define RST_EN               0x008U
#define EC_ID                0x00CU
#define SC_ID                0x010U
#define BHV_PRIORITY         0x014U
#define A_EN                 0x05CU
#define A_TX_OT              0x064U
#define A_TX_RSULT_RPT       0x068U
#define A_BHV_ID             0x074U
#define B_EN                 0x084U
#define C_EN                 0x0ACU
#define PARAM1               0x0D8U
#define PARAM2               0x0DCU
#define PARAM3               0x0E0U
#define PARAM4               0x0E4U
#define PARAM5               0x0E8U
#define PARAM6               0x0ECU
#define PARAM7               0x0F0U
#define PARAM8               0x0F4U
#define PARAM9               0x0F8U
#define PARAM10              0x0FCU
#define PARAM11              0x100U
#define PARAM12              0x104U
#define PARAM13              0x108U
#define PARAM14              0x10CU
#define PARAM15              0x110U
#define PARAM16              0x114U
#define PARAM17              0x118U
#define PARAM18              0x11CU
#define PARAM19              0x120U
#define PARAM20              0x124U
#define PARAM21              0x128U
#define PARAM22              0x12CU
#define PARAM23              0x130U
#define PARAM24              0x134U
#define PARAM25              0x138U
#define PARAM26              0x13CU
#define PARAM27              0x140U
#define PARAM28              0x144U
#define PARAM29              0x148U
#define PARAM30              0x14CU
#define PARAM51              0x150U
#define PARAM52              0x154U

// INTC instance descriptor (16-INTC dispatch architecture)
typedef struct {
	u32 dev_id;
	u32 baseaddr;
	u32 gic_spi;
} IntcDesc;

#define NUM_INTC 16

#define INTC_ISR 0x00U
#define INTC_IER 0x08U
#define INTC_IAR 0x0CU
static const IntcDesc intc_desc[NUM_INTC] = {
	{  0, 0xA0000000U, 121 }, {  1, 0xA0001000U, 122 },
	{  2, 0xA0002000U, 123 }, {  3, 0xA0003000U, 124 },
	{  4, 0xA0004000U, 125 }, {  5, 0xA0005000U, 126 },
	{  6, 0xA0006000U, 127 }, {  7, 0xA0007000U, 128 },
	{  8, 0xA0008000U, 136 }, {  9, 0xA0009000U, 137 },
	{ 10, 0xA000A000U, 138 }, { 11, 0xA000B000U, 139 },
	{ 12, 0xA000C000U, 140 }, { 13, 0xA000D000U, 141 },
	{ 14, 0xA000E000U, 142 }, { 15, 0xA000F000U, 143 },
};

// Interrupt routing slot
typedef struct {
	const char *name;
	int   intc_idx;
	u32   intc_bit;
	u32   base_addr;
} IrqSlot;

#define NUM_IRQ_SLOTS 11
static IrqSlot irq_table[NUM_IRQ_SLOTS] = {
	{ "ec_1di",          0,  0, PL_CFG_BASE + REG_BIAS_EC_1DI         },
	{ "ec_1do",          0,  1, PL_CFG_BASE + REG_BIAS_EC_1DO         },
	{ "ec_2di_2do",      0,  2, PL_CFG_BASE + REG_BIAS_EC_2DI_2DO     },
	{ "ec_3di_2do",      0,  3, PL_CFG_BASE + REG_BIAS_EC_3DI_2DO     },
	{ "ec_3di_1do",      0,  4, PL_CFG_BASE + REG_BIAS_EC_3DI_1DO     },
	{ "ec_1di_1do",      0,  5, PL_CFG_BASE + REG_BIAS_EC_1DI_1DO     },
	{ "ec_4di_2do",      0,  6, PL_CFG_BASE + REG_BIAS_EC_4DI_2DO     },
	{ "ec_3led",         0,  7, PL_CFG_BASE + REG_BIAS_EC_3LED        },
	{ "ec_5di",          0,  8, PL_CFG_BASE + REG_BIAS_EC_5DI         },
	{ "ec_pul_axis",     0,  9, PL_CFG_BASE + REG_BIAS_EC_PUL_AXIS    },
	{ "ec_slv_pul_axis", 0, 10, PL_CFG_BASE + REG_BIAS_EC_SLV_PUL_AXIS },
};

static XScuGic Gic;
static XIntc   Intc;

// Multi-component support
static int  cur_component = 0;          // currently selected component index [0..NUM_IRQ_SLOTS-1]

static u32 param_spd       = 0x00000064U; // PARAM4:  home/jog/move_spd
static u32 param_acc       = 0x00000064U; // PARAM5:  home/jog/move_acc
static u32 param_dec       = 0x00000064U; // PARAM6:  home/jog/move_dec
static u32 param_target    = 0x0007A120U; // PARAM8:  target_pulse
static u32 param_step      = 0x0000C350U; // PARAM9:  step_pulse
static u32 param_serv_dir  = 0x00000000U; // PARAM27: serv_dir

// Input mode state machine
typedef enum {
	MODE_BEHAVIOR,       // 0~f triggers behavior on current component
	MODE_SELECT_COMP,    // waiting for digits to select component
	MODE_SET_PARAM,      // waiting for param selection (1~6)
	MODE_PARAM_VAL,      // waiting for hex value input
} InputMode;
static InputMode input_mode = MODE_BEHAVIOR;
static int  comp_select_buf = -1;    // accumulated digit buffer, -1 = empty
static int  param_sel        = 0;    // which param is being edited (1..6)
static u32  param_val_buf    = 0;    // hex value accumulator

//---------------------------------------------------------------------------
// Event queue (ISR -> main loop)
//---------------------------------------------------------------------------
typedef struct {
	IrqSlot *slot;
	u32      irq_reg1;
	u32      irq_reg2;
	u32      tick;
} IrqEvent;

#define EVQ_SIZE 64
static IrqEvent evq[EVQ_SIZE];
static volatile int  evq_head, evq_tail;
static volatile u32  EvDropCount;
static volatile u32  IsrCount;   // diag: how many times the ISR ran

// Called from ISR context only. Non-blocking; drops and counts on overflow.
static int EvPush(const IrqEvent *ev)
{
	int next = (evq_head + 1) % EVQ_SIZE;
	if (next == evq_tail)
		return 0;
	evq[evq_head] = *ev;
	evq_head = next;
	return 1;
}

// Called from main loop only.
static int EvPop(IrqEvent *ev)
{
	if (evq_head == evq_tail)
		return 0;
	*ev = evq[evq_tail];
	evq_tail = (evq_tail + 1) % EVQ_SIZE;
	return 1;
}

// Per-bit ISR: capture registers, push event. No ack, no print, no wait.
static void ComponentIsr(void *ref)
{
	IrqSlot *slot = (IrqSlot *)ref;
	IrqEvent ev;
	int i;

	IsrCount++;

	ev.slot     = slot;
	ev.irq_reg2 = Xil_In32(slot->base_addr + IRQ_REG2);
	ev.irq_reg1 = 0;
	// IRQ_REG1 may lag the INTC edge by a few AXI cycles; retry briefly.
	// Dropping this event loses the edge forever (level source + edge INTC),
	// because the bit is cleared by IAR right after this handler returns.
	for (i = 0; i < 8; i++) {
		ev.irq_reg1 = Xil_In32(slot->base_addr + IRQ_REG1);
		if (ev.irq_reg1 != 0U) break;
	}
	ev.tick     = ts_ms();

	if (!EvPush(&ev))
		EvDropCount++;
}

//---------------------------------------------------------------------------
// Behavior transaction state machine (main-loop context)
//---------------------------------------------------------------------------
typedef enum {
	BHV_IDLE,
	BHV_WAIT_REQ,      // wrote A_BHV_ID, waiting for 0x0A interrupt
	BHV_WAIT_RESULT,   // acked 0x0A, waiting for 0x1E (ok) / 0x28 (fail)
} BhvState;

static BhvState       bhv_state = BHV_IDLE;
static IrqSlot       *bhv_slot  = NULL;
static u8             bhv_id    = 0;
static u32            bhv_deadline = 0;

// last acked IRQ_REG1 per component, for stale-duplicate suppression
// (HW keeps IRQ asserted until A_TX_RSULT_RPT is written, so the ISR can
//  fire several times before the ACK lands; only the first event matters)
static u32 last_acked_reg1[NUM_IRQ_SLOTS];

// ACK with the values captured in the event (main-loop context only)
static void PsIrqAck(IrqSlot *slot, u32 irq_reg1, u32 irq_reg2)
{
	u32 bhv_id, irq_num, status, resp;
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
static void BhvStart(IrqSlot *slot, u8 id)
{
	xil_printf("[%08u] \r\n[BHV %u] %s @0x%08x...\r\n",
		   (unsigned)ts_ms(), (unsigned)id, slot->name, (unsigned)slot->base_addr);
	Xil_Out32(slot->base_addr + A_BHV_ID, (u32)id);

	bhv_slot  = slot;
	bhv_id    = id;
	bhv_state = BHV_WAIT_REQ;
	bhv_deadline = ts_ms() + 5000U;   // req(0x0A) wait, 5s
}

// Called from main loop: deadline expired
static void BhvTimeout(void)
{
	xil_printf("[%08u] [BHV %u] %s TIMEOUT (state=%s, isr=%u drop=%u)\r\n",
		   (unsigned)ts_ms(), (unsigned)bhv_id, bhv_slot->name,
		   (bhv_state == BHV_WAIT_REQ) ? "req" : "result",
		   (unsigned)IsrCount, (unsigned)EvDropCount);
	bhv_state = BHV_IDLE;
	bhv_slot  = NULL;
}

// Consume one queued event, advance the behavior state machine.
static void ProcessEvent(const IrqEvent *ev)
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
static void PollIntcFallback(void)
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

//---------------------------------------------------------------------------
// Interrupt system setup
//---------------------------------------------------------------------------
static int SetupInterruptSystem(void)
{
	XScuGic_Config *GicCfg;
	int Status;
	u32 i;

	GicCfg = XScuGic_LookupConfig(XPAR_SCUGIC_0_DEVICE_ID);
	if (!GicCfg) return XST_FAILURE;
	Status = XScuGic_CfgInitialize(&Gic, GicCfg, GicCfg->CpuBaseAddress);
	if (Status != XST_SUCCESS) return XST_FAILURE;

	// Initialize all INTCs used by irq_table
	Status = XIntc_Initialize(&Intc, intc_desc[0].dev_id);
	if (Status != XST_SUCCESS) return XST_FAILURE;

	// Per-bit handler: hardware dispatches, no software polling
	for (i = 0; i < NUM_IRQ_SLOTS; i++) {
		if (!irq_table[i].name) continue;
		XIntc_Connect(&Intc, irq_table[i].intc_bit,
			      (XInterruptHandler)ComponentIsr, &irq_table[i]);
	}

	XIntc_Start(&Intc, XIN_REAL_MODE);

	for (i = 0; i < NUM_IRQ_SLOTS; i++) {
		if (!irq_table[i].name) continue;
		XIntc_Enable(&Intc, irq_table[i].intc_bit);
	}

	// Connect INTC#0 to GIC
	Status = XScuGic_Connect(&Gic, intc_desc[0].gic_spi,
				 (Xil_ExceptionHandler)XIntc_InterruptHandler, &Intc);
	if (Status != XST_SUCCESS) return XST_FAILURE;
	XScuGic_Enable(&Gic, intc_desc[0].gic_spi);

	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
				     (Xil_ExceptionHandler)XScuGic_InterruptHandler, &Gic);
	Xil_ExceptionEnable();

	for (i = 0; i < NUM_IRQ_SLOTS; i++)
		last_acked_reg1[i] = 0;

	return XST_SUCCESS;
}

//---------------------------------------------------------------------------
// Component register access (main-loop context)
//---------------------------------------------------------------------------
static void PlRegWrite(u32 base_addr)
{
	Xil_Out32(base_addr + RST_EN,  0x00000000U);
	Xil_Out32(base_addr + RST_EN,  0x00000001U);
	Xil_Out32(base_addr + SC_ID,   0x00000066U);
	Xil_Out32(base_addr + EC_ID,   0x00000088U);
	Xil_Out32(base_addr + A_EN,    0x00000001U);
	Xil_Out32(base_addr + B_EN,    0x00000000U);
	Xil_Out32(base_addr + C_EN,    0x00000000U);
	Xil_Out32(base_addr + A_TX_OT, 0xFFFF0000U);
}

// ec_pul_axis specific initialization
static void PlRegWritePulAxis(u32 base_addr)
{
	PlRegWrite(base_addr);  // common init first

	Xil_Out32(base_addr + PARAM1,  0x00002710U); // max_spd
	Xil_Out32(base_addr + PARAM2,  0x00002710U); // max_acc
	Xil_Out32(base_addr + PARAM3,  0x00002710U); // max_dec
	Xil_Out32(base_addr + PARAM4,  param_spd);      // home/jog/move_spd
	Xil_Out32(base_addr + PARAM5,  param_acc);      // home/jog/move_acc
	Xil_Out32(base_addr + PARAM6,  param_dec);      // home/jog/move_dec
	Xil_Out32(base_addr + PARAM7,  0x00004E20U);    // qs_dec
	Xil_Out32(base_addr + PARAM8,  param_target);   // target_pulse
	Xil_Out32(base_addr + PARAM9,  param_step);     // step_pulse
	Xil_Out32(base_addr + PARAM16, 0x00000000U);    // pf_mode
	Xil_Out32(base_addr + PARAM27, param_serv_dir); // serv_dir
	Xil_Out32(base_addr + PARAM30, 0x00000001U); // drive_on
}

static void PlRegRead(u32 base_addr, const char *name)
{
	xil_printf("[%s]\r\n", name);
	xil_printf("  RST_EN=0x%08x SC_ID=0x%08x EC_ID=0x%08x A_EN=0x%08x B_EN=0x%08x C_EN=0x%08x A_TX_OT=0x%08x\r\n",
		(unsigned)Xil_In32(base_addr + RST_EN),
		(unsigned)Xil_In32(base_addr + SC_ID),
		(unsigned)Xil_In32(base_addr + EC_ID),
		(unsigned)Xil_In32(base_addr + A_EN),
		(unsigned)Xil_In32(base_addr + B_EN),
		(unsigned)Xil_In32(base_addr + C_EN),
		(unsigned)Xil_In32(base_addr + A_TX_OT));
	xil_printf("  PARAM1 =0x%08x PARAM2 =0x%08x PARAM3 =0x%08x\r\n",
		(unsigned)Xil_In32(base_addr + PARAM1),
		(unsigned)Xil_In32(base_addr + PARAM2),
		(unsigned)Xil_In32(base_addr + PARAM3));
	xil_printf("  PARAM4 =0x%08x PARAM5 =0x%08x PARAM6 =0x%08x\r\n",
		(unsigned)Xil_In32(base_addr + PARAM4),
		(unsigned)Xil_In32(base_addr + PARAM5),
		(unsigned)Xil_In32(base_addr + PARAM6));
	xil_printf("  PARAM7 =0x%08x PARAM8 =0x%08x PARAM9 =0x%08x\r\n",
		(unsigned)Xil_In32(base_addr + PARAM7),
		(unsigned)Xil_In32(base_addr + PARAM8),
		(unsigned)Xil_In32(base_addr + PARAM9));
	xil_printf("  PARAM16=0x%08x PARAM27=0x%08x PARAM30=0x%08x\r\n",
		(unsigned)Xil_In32(base_addr + PARAM16),
		(unsigned)Xil_In32(base_addr + PARAM27),
		(unsigned)Xil_In32(base_addr + PARAM30));
	xil_printf("  PARAM51=0x%08x PARAM52=0x%08x\r\n",
		(unsigned)Xil_In32(base_addr + PARAM51),
		(unsigned)Xil_In32(base_addr + PARAM52));
}

// Map param index -> register offset
static u32 ParamRegOffset(int sel)
{
	switch (sel) {
		case 1: return PARAM4;
		case 2: return PARAM5;
		case 3: return PARAM6;
		case 4: return PARAM8;
		case 5: return PARAM9;
		case 6: return PARAM27;
		default: return 0;
	}
}

// Get pointer to the global param variable by index
static u32* ParamVarPtr(int sel)
{
	switch (sel) {
		case 1: return &param_spd;
		case 2: return &param_acc;
		case 3: return &param_dec;
		case 4: return &param_target;
		case 5: return &param_step;
		case 6: return &param_serv_dir;
		default: return NULL;
	}
}

static const char* ParamName(int sel)
{
	switch (sel) {
		case 1: return "spd       ";
		case 2: return "acc       ";
		case 3: return "dec       ";
		case 4: return "target    ";
		case 5: return "step      ";
		case 6: return "serv_dir  ";
		default: return "?         ";
	}
}

// Write one param to current component's register
static void ParamWriteCur(int sel, u32 val)
{
	u32 off = ParamRegOffset(sel);
	if (off == 0) return;
	IrqSlot *comp = &irq_table[cur_component];
	Xil_Out32(comp->base_addr + off, val);
	u32 *pvar = ParamVarPtr(sel);
	if (pvar) *pvar = val;
	xil_printf("  [%d:%s] PARAM%u(%-9s) <= 0x%08x (%u)\r\n",
		   cur_component, comp->name,
		   (unsigned)(sel <= 3 ? sel + 3 : sel == 4 ? 8 : sel == 5 ? 9 : 27),
		   ParamName(sel), (unsigned)val, (unsigned)val);
}

static void PrintParamMenu(void)
{
	IrqSlot *comp = &irq_table[cur_component];
	xil_printf("\r\n--- Set Param on [%d] %s ---\r\n", cur_component, comp->name);
	xil_printf("  1: spd       (PARAM4)  = %u (0x%08x)\r\n", (unsigned)param_spd, (unsigned)param_spd);
	xil_printf("  2: acc       (PARAM5)  = %u (0x%08x)\r\n", (unsigned)param_acc, (unsigned)param_acc);
	xil_printf("  3: dec       (PARAM6)  = %u (0x%08x)\r\n", (unsigned)param_dec, (unsigned)param_dec);
	xil_printf("  4: target    (PARAM8)  = %u (0x%08x)\r\n", (unsigned)param_target, (unsigned)param_target);
	xil_printf("  5: step      (PARAM9)  = %u (0x%08x)\r\n", (unsigned)param_step, (unsigned)param_step);
	xil_printf("  6: serv_dir  (PARAM27) = %u (0x%08x)\r\n", (unsigned)param_serv_dir, (unsigned)param_serv_dir);
	xil_printf("  Esc / q: cancel\r\n");
	xil_printf("Select param (1~6): ");
}

static void PrintMenu(void)
{
	xil_printf("\r\n");
	xil_printf("===========================================\r\n");
	xil_printf(" Multi-Component IRQ ACK (event-driven)\r\n");
	xil_printf(" Current component: [%d] %s\r\n",
		   cur_component, irq_table[cur_component].name);
	xil_printf("===========================================\r\n");
	xil_printf(" Keys:\r\n");
	xil_printf("  0~f      - Send behavior 0~15 to CURRENT component\r\n");
	xil_printf("  c        - Enter component-select mode \r\n");
	xil_printf("  w        - Set motion params (spd/acc/dec/target/step/dir)\r\n");
	xil_printf("  p        - Read PARAM of current component\r\n");
	xil_printf("  r        - Read all registers of current component\r\n");
	xil_printf("  m        - Show this menu\r\n");
	xil_printf("  i        - Init/re-init current component\r\n");
	xil_printf("  I        - Init ALL components\r\n");
	xil_printf("  s        - Scan: read PARAM51 of all components\r\n");
	xil_printf("===========================================\r\n");
	xil_printf(" Component list:\r\n");
	for (int i = 0; i < NUM_IRQ_SLOTS; i++) {
		xil_printf("  [%d] %s%s (bit%u @0x%08x)\r\n",
			   i, irq_table[i].name,
			   (i == cur_component) ? " <--" : "",
			   irq_table[i].intc_bit, (unsigned)irq_table[i].base_addr);
	}
	xil_printf("===========================================\r\n");
}

int main(void)
{
	int Status;
	char key_index;

	init_platform();

	xil_printf("\r\n==============================================\r\n");
	xil_printf(" PL IRQ: Multi-Component BM (pure event-driven)\r\n");
	xil_printf(" 16-INTC dispatch architecture\r\n");
	xil_printf(" %d components registered on INTC#0\r\n", NUM_IRQ_SLOTS);
	xil_printf("==============================================\r\n");

	// Initialize ALL components
	xil_printf("\r\nInitializing all components...\r\n");
	for (int i = 0; i < NUM_IRQ_SLOTS; i++) {
		if (irq_table[i].base_addr == (PL_CFG_BASE + REG_BIAS_EC_PUL_AXIS) ||
		    irq_table[i].base_addr == (PL_CFG_BASE + REG_BIAS_EC_SLV_PUL_AXIS)) {
			PlRegWritePulAxis(irq_table[i].base_addr);
			xil_printf("  [%d] pul_axis init @0x%08x\r\n",
				   i, (unsigned)irq_table[i].base_addr);
		} else {
			PlRegWrite(irq_table[i].base_addr);
			xil_printf("  [%d] %s init @0x%08x\r\n",
				   i, irq_table[i].name,
				   (unsigned)irq_table[i].base_addr);
		}
	}

	Status = SetupInterruptSystem();
	if (Status != XST_SUCCESS) {
		xil_printf("Setup FAILED.\r\n");
		cleanup_platform();
		return XST_FAILURE;
	}

	xil_printf("\r\nAll components ready! Interrupts enabled.\r\n");

	PrintMenu();

	while (1) {
		IrqEvent ev;

		// 1. drain event queue (ISR feeds, main-loop consumes)
		while (EvPop(&ev))
			ProcessEvent(&ev);

		// 1b. INTC polling fallback (GIC ISR path may not deliver)
		PollIntcFallback();

		if (EvDropCount) {
			xil_printf("[%08u] EVQ overflow: %u dropped\r\n",
				   (unsigned)ts_ms(), (unsigned)EvDropCount);
			EvDropCount = 0;
		}

		// 2. behavior timeout (timestamp deadline, non-blocking)
		if (bhv_state != BHV_IDLE &&
		    (s32)(ts_ms() - bhv_deadline) > 0)
			BhvTimeout();

		// 3. UART menu (non-blocking, so events/timeouts run while idle)
		if (XUartPs_IsReceiveData(STDIN_BASEADDRESS))
			key_index = XUartPs_RecvByte(STDIN_BASEADDRESS);
		else
			key_index = 0;

		if (key_index == 0 || key_index == 0xFF) {
			usleep(10000);
			continue;
		}

		if (input_mode == MODE_SELECT_COMP) {
			// Accumulate digits, Enter to confirm, Esc to cancel
			if (key_index >= '0' && key_index <= '9') {
				int d = (int)(key_index - '0');
				if (comp_select_buf < 0)
					comp_select_buf = d;
				else
					comp_select_buf = comp_select_buf * 10 + d;
				xil_printf("%c", key_index);
				if (comp_select_buf > NUM_IRQ_SLOTS - 1) {
					xil_printf("\r\nInvalid index %d (max %d)\r\n",
						   comp_select_buf, NUM_IRQ_SLOTS - 1);
					comp_select_buf = -1;
					input_mode = MODE_BEHAVIOR;
				}
				// else: stay in MODE_SELECT_COMP for more digits
			} else if (key_index == '\r' || key_index == '\n') {
				// Enter confirms selection
				if (comp_select_buf >= 0) {
					cur_component = comp_select_buf;
					xil_printf("\r\n>>> Switched to [%d] %s <<<\r\n",
						   cur_component,
						   irq_table[cur_component].name);
				} else {
					xil_printf("\r\nNo digit, cancelled.\r\n");
				}
				comp_select_buf = -1;
				input_mode = MODE_BEHAVIOR;
			} else if (key_index == 0x1B || key_index == 0x7F || key_index == 0x08) {
				// Esc / Backspace / Del → cancel
				xil_printf("\r\nCancelled.\r\n");
				comp_select_buf = -1;
				input_mode = MODE_BEHAVIOR;
			}
			/* else: ignore other chars, stay in MODE_SELECT_COMP */
		}
		// Param config: select which parameter
		else if (input_mode == MODE_SET_PARAM) {
			if (key_index >= '1' && key_index <= '6') {
				param_sel = (int)(key_index - '0');
				param_val_buf = 0;
				input_mode = MODE_PARAM_VAL;
				xil_printf("%c\r\nEnter decimal value for %s: ", key_index, ParamName(param_sel));
			} else if (key_index == 0x1B || key_index == 'q' || key_index == 'Q') {
				xil_printf("\r\nCancelled.\r\n");
				input_mode = MODE_BEHAVIOR;
			}
		}
		// Param config: enter decimal value
		else if (input_mode == MODE_PARAM_VAL) {
			if (key_index >= '0' && key_index <= '9') {
				param_val_buf = param_val_buf * 10 + (u32)(key_index - '0');
				xil_printf("%c", key_index);
			} else if (key_index == '\r' || key_index == '\n') {
				xil_printf("\r\n");
				ParamWriteCur(param_sel, param_val_buf);
				input_mode = MODE_BEHAVIOR;
			} else if (key_index == 0x1B || key_index == 0x7F || key_index == 0x08) {
				xil_printf("\r\nCancelled.\r\n");
				input_mode = MODE_BEHAVIOR;
			}
		}
		// Component select: enter selection mode
		else if (key_index == 'c' || key_index == 'C') {
			input_mode = MODE_SELECT_COMP;
			xil_printf("\r\nSelect component (0-%d): ", NUM_IRQ_SLOTS - 1);
		}
		// Set motion params
		else if (key_index == 'w' || key_index == 'W') {
			input_mode = MODE_SET_PARAM;
			PrintParamMenu();
		}
		// Behavior hex digits (0-9, a-f, A-F)
		else if ((key_index >= '0' && key_index <= '9') ||
			 (key_index >= 'a' && key_index <= 'f') ||
			 (key_index >= 'A' && key_index <= 'F')) {
			u8 bhv = (key_index <= '9') ? (u8)(key_index - '0') :
				 (key_index <= 'F') ? (u8)(key_index - 'A' + 10) :
				              (u8)(key_index - 'a' + 10);
			IrqSlot *comp = &irq_table[cur_component];
			if (bhv_state != BHV_IDLE) {
				xil_printf("\r\n[BHV %u] still running on %s, ignore\r\n",
					   (unsigned)bhv_id, bhv_slot->name);
			} else {
				xil_printf("\r\n>>> [BHV=%u] on [%d] %s <<<\r\n",
					   (unsigned)bhv, cur_component, comp->name);
				BhvStart(comp, bhv);
			}
		}
		// Read PARAM51 of current component
		else if (key_index == 'p' || key_index == 'P') {
			IrqSlot *comp = &irq_table[cur_component];
			xil_printf("\r\n[%d:%s] PARAM51=0x%08x PARAM52=0x%08x\r\n",
				   cur_component, comp->name,
				   (unsigned)Xil_In32(comp->base_addr + PARAM51),
				   (unsigned)Xil_In32(comp->base_addr + PARAM52));
		}
		// Read all registers of current component
		else if (key_index == 'r' || key_index == 'R') {
			IrqSlot *comp = &irq_table[cur_component];
			xil_printf("\r\n");
			PlRegRead(comp->base_addr, comp->name);
		}
		// Re-init current component
		else if (key_index == 'i') {
			IrqSlot *comp = &irq_table[cur_component];
			xil_printf("\r\nRe-init [%d] %s...\r\n",
				   cur_component, comp->name);
			if (comp->base_addr == (PL_CFG_BASE + REG_BIAS_EC_PUL_AXIS) ||
			    comp->base_addr == (PL_CFG_BASE + REG_BIAS_EC_SLV_PUL_AXIS))
				PlRegWritePulAxis(comp->base_addr);
			else
				PlRegWrite(comp->base_addr);
			PlRegRead(comp->base_addr, comp->name);
		}
		// Init ALL components
		else if (key_index == 'I') {
			xil_printf("\r\nRe-initializing ALL components...\r\n");
			for (int i = 0; i < NUM_IRQ_SLOTS; i++) {
				if (irq_table[i].base_addr == (PL_CFG_BASE + REG_BIAS_EC_PUL_AXIS) ||
				    irq_table[i].base_addr == (PL_CFG_BASE + REG_BIAS_EC_SLV_PUL_AXIS))
					PlRegWritePulAxis(irq_table[i].base_addr);
				else
					PlRegWrite(irq_table[i].base_addr);
			}
			xil_printf("All components re-initialized.\r\n");
		}
		// Scan all components PARAM51
		else if (key_index == 's' || key_index == 'S') {
			xil_printf("\r\n=== Scanning all components ===\r\n");
			for (int i = 0; i < NUM_IRQ_SLOTS; i++) {
				u32 p51 = Xil_In32(irq_table[i].base_addr + PARAM51);
				u32 irq1 = Xil_In32(irq_table[i].base_addr + IRQ_REG1);
				xil_printf("  [%d] %-20s PARAM51=0x%08x IRQ_REG1=0x%08x\r\n",
					   i, irq_table[i].name,
					   (unsigned)p51, (unsigned)irq1);
			}
			xil_printf("=== Scan complete ===\r\n");
		}
		// Show menu
		else if (key_index == 'm' || key_index == 'M') {
			PrintMenu();
		}
		else if (key_index == 'q' || key_index == 'Q') {
			xil_printf("\r\nExiting...\r\n");
			break;
		}
		else if (key_index >= 32 && key_index < 127) {
			xil_printf("\r\n[?] '%c' (0x%02x) - press 'm' for menu\r\n",
				   key_index, (unsigned)key_index);
		}

		usleep(10000);
	}

	cleanup_platform();
	return 0;
}
