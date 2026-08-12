// @file pl_intc.c
// Interrupt infrastructure: 16-INTC dispatch, component table, ISR event queue

#include "pl_intc.h"
#include "pl_reg.h"
#include "util.h"

#include "xil_io.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xscugic.h"
#include "xintc.h"

const IntcDesc intc_desc[NUM_INTC] = {
	{  0, 0xA0000000U, 121 }, {  1, 0xA0001000U, 122 },
	{  2, 0xA0002000U, 123 }, {  3, 0xA0003000U, 124 },
	{  4, 0xA0004000U, 125 }, {  5, 0xA0005000U, 126 },
	{  6, 0xA0006000U, 127 }, {  7, 0xA0007000U, 128 },
	{  8, 0xA0008000U, 136 }, {  9, 0xA0009000U, 137 },
	{ 10, 0xA000A000U, 138 }, { 11, 0xA000B000U, 139 },
	{ 12, 0xA000C000U, 140 }, { 13, 0xA000D000U, 141 },
	{ 14, 0xA000E000U, 142 }, { 15, 0xA000F000U, 143 },
};

IrqSlot irq_table[NUM_IRQ_SLOTS] = {
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

int  cur_component = 0;          // currently selected component index [0..NUM_IRQ_SLOTS-1]

static XScuGic Gic;
static XIntc   Intc;

// Event queue (ISR -> main loop)
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
int EvPop(IrqEvent *ev)
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

u32 IntcIsrCount(void)
{
	return IsrCount;
}

u32 EvDropCountGet(void)
{
	return EvDropCount;
}

void EvDropCountClear(void)
{
	EvDropCount = 0;
}

//---------------------------------------------------------------------------
// Interrupt system setup
//---------------------------------------------------------------------------
int SetupInterruptSystem(void)
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

	return XST_SUCCESS;
}
