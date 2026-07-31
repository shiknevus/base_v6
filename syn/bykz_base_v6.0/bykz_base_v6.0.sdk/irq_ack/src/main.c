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

// INTC instance descriptor
typedef struct {
	u32 dev_id;
	u32 baseaddr;
	u32 gic_spi;
} IntcDesc;

#define NUM_INTC 16
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

#define INTC_ISR 0x00U
#define INTC_IER 0x08U
#define INTC_MER 0x1CU

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
volatile static u32 IrqCount   = 0;
volatile static int IrqPending = FALSE;
static IrqSlot *irq_lut[32];

// Multi-component support
static int  cur_component = 0;          // currently selected component index [0..NUM_IRQ_SLOTS-1]
static int  bhv_pending[NUM_IRQ_SLOTS]; // 1 = fire-and-forget behavior running on this component
static u32  bhv_intc_bit[NUM_IRQ_SLOTS]; // INTC bit for each component

// Input mode state machine
typedef enum {
	MODE_BEHAVIOR,       // 0~f triggers behavior on current component
	MODE_SELECT_COMP,    // waiting for digits to select component
} InputMode;
static InputMode input_mode = MODE_BEHAVIOR;
static int  comp_select_buf = -1;    // accumulated digit buffer, -1 = empty


// Function declarations
static int  SetupInterruptSystem(void);
static void PlIrqHandler(void *CallbackRef);
static void PlRegWrite(u32 base_addr);
static void PlRegWritePulAxis(u32 base_addr);
static void PlRegRead(u32 base_addr, const char *name);
static void PsIrqAck(u32 base_addr, const char *name);
static void DispatchIntc(int intc_idx);
static void DispatchAll(void);
static int  WaitForIrq(u32 expected_bit, u32 timeout_ms);
static int  DoBehavior(u32 base_addr, u8 bhv_id, u32 intc_bit, const char *comp_name);
static void PrintMenu(void);

// ISR
static void PlIrqHandler(void *CallbackRef)
{
	(void)CallbackRef;
	IrqCount++;
	IrqPending = TRUE;
}

// Common initialization
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
	Xil_Out32(base_addr + PARAM4,  0x00000064U); // home/jog/move_spd
	Xil_Out32(base_addr + PARAM5,  0x00000064U); // home/jog/move_acc
	Xil_Out32(base_addr + PARAM6,  0x00000064U); // home/jog/move_dec
	Xil_Out32(base_addr + PARAM7,  0x00004E20U); // qs_dec
	Xil_Out32(base_addr + PARAM8,  0x0007A120U); // target_pulse
	Xil_Out32(base_addr + PARAM9,  0x0000C350U); // step_pulse
	Xil_Out32(base_addr + PARAM16, 0x00000000U); // pf_mode
	Xil_Out32(base_addr + PARAM27, 0x00000000U); // serv_dir
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

// Interrupt acknowledge
static void PsIrqAck(u32 base_addr, const char *name)
{
	u32 irq_reg1, irq_reg2, irq_num, bhv_id, status, resp;

	irq_reg2 = Xil_In32(base_addr + IRQ_REG2);
	irq_reg1 = Xil_In32(base_addr + IRQ_REG1);

	if (irq_reg1 == 0U)
		return;

	xil_printf("[%08u]  [%s] IRQ_REG2=0x%08x IRQ_REG1=0x%08x\r\n",
		   (unsigned)ts_ms(), name, (unsigned)irq_reg2, (unsigned)irq_reg1);

	if (irq_reg2 != 0U)
		xil_printf("[%08u]  [%s] ALARM num=0x%02x\r\n",
			   (unsigned)ts_ms(), name,
			   (unsigned)((irq_reg2 >> 24) & 0xFFU));

	bhv_id  = (irq_reg1 >> 8) & 0xFFU;
	irq_num = irq_reg1 & 0xFFU;

	if (bhv_id == 1U || bhv_id == 2U)
		status = (irq_num == 0x28U) ? 0x5101U : 0x5100U;
	else
		status = (irq_num == 0x28U) ? 0x5199U : 0x5167U;

	resp = (bhv_id << 24) | (irq_num << 16) | status;
	Xil_Out32(base_addr + A_TX_RSULT_RPT, resp);
	xil_printf("[%08u]  [%s] -> A_TX_RSULT_RPT=0x%08x (bhv=%u irq_num=%u %s)\r\n",
		   (unsigned)ts_ms(), name, (unsigned)resp, (unsigned)bhv_id, (unsigned)irq_num,
		   (irq_num == 0x28U) ? "FAIL" : "SUCCESS");
}

// Interrupt system initialization
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

	// Connect all components' interrupts to the handler
	for (i = 0; i < NUM_IRQ_SLOTS; i++) {
		if (!irq_table[i].name) continue;
		XIntc_Connect(&Intc, irq_table[i].intc_bit,
			      (XInterruptHandler)PlIrqHandler, &Intc);
	}

	XIntc_Start(&Intc, XIN_REAL_MODE);

	// Enable all components' interrupts
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

	// Build LUT for quick INTC bit -> IrqSlot lookup
	for (i = 0; i < 32; i++) irq_lut[i] = NULL;
	for (i = 0; i < NUM_IRQ_SLOTS; i++) {
		if (!irq_table[i].name) continue;
		irq_lut[irq_table[i].intc_bit] = &irq_table[i];
		bhv_intc_bit[i] = irq_table[i].intc_bit;
		bhv_pending[i]  = 0;
	}

	return XST_SUCCESS;
}

static void DispatchIntc(int intc_idx)
{
	u32 base = intc_desc[intc_idx].baseaddr;
	u32 isr = Xil_In32(base + INTC_ISR);
	u32 ier = Xil_In32(base + INTC_IER);
	u32 pending = isr & ier;
	if (!pending) return;

	for (u32 bit = 0; bit < 32 && pending; bit++) {
		u32 mask = 1U << bit;
		if ((pending & mask) && irq_lut[bit]) {
			PsIrqAck(irq_lut[bit]->base_addr, irq_lut[bit]->name);
			pending &= ~mask;
		}
	}
}

static void DispatchAll(void)
{
	for (int i = 0; i < NUM_INTC; i++)
		DispatchIntc(i);
}

// Wait for specific INTC bit interrupt
static int WaitForIrq(u32 expected_bit, u32 timeout_ms)
{
	u32 elapsed_ms = 0;
	u32 mask = 1U << expected_bit;
	u32 base = intc_desc[0].baseaddr;

	while (1) {
		u32 isr = Xil_In32(base + INTC_ISR);
		u32 ier = Xil_In32(base + INTC_IER);
		u32 pending = isr & ier;

		if (pending) {
			// Background processing for non-target interrupts
			u32 bg = pending & ~mask;
			for (u32 bit = 0; bit < 32 && bg; bit++) {
				u32 m = 1U << bit;
				if ((bg & m) && irq_lut[bit]) {
					xil_printf("  [WaitIrq] bg: %s (bit%u)\r\n",
						   irq_lut[bit]->name, bit);
					PsIrqAck(irq_lut[bit]->base_addr, irq_lut[bit]->name);
					bg &= ~m;
				}
			}
			if (pending & mask) {
				return 1;
			}
		}

		usleep(1000);
		if (timeout_ms) {
			elapsed_ms++;
			if ((elapsed_ms % 5000) == 0)
				xil_printf("  [WaitIrq] %us ISR=0x%08x\r\n",
					   (unsigned)(elapsed_ms / 1000), (unsigned)isr);
			if (elapsed_ms >= timeout_ms) return 0;
		}
	}
}

// Read IRQ_REG1 with retry
static u32 ReadIrqReg1(u32 base_addr)
{
	u32 v;
	for (int r = 0; r < 5; r++) {
		v = Xil_In32(base_addr + IRQ_REG1);
		if (v != 0U) return v;
		usleep(1000);
	}
	return v;
}

// Behavior transaction
static int DoBehavior(u32 base_addr, u8 bhv_id, u32 intc_bit, const char *comp_name)
{
	u32 irq_reg1, irq_num;

	xil_printf("[%08u] \r\n[BHV %u] %s @0x%08x...\r\n",
		   (unsigned)ts_ms(), (unsigned)bhv_id, comp_name, (unsigned)base_addr);
	Xil_Out32(base_addr + A_BHV_ID, (u32)bhv_id);

	//  Wait for 10(0x0A) interrupt
	if (!WaitForIrq(intc_bit, 5000)) {
		xil_printf("[%08u] [BHV %u] %s TIMEOUT req(10)\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, comp_name);
		return 0;
	}
	irq_reg1 = ReadIrqReg1(base_addr);
	irq_num  = irq_reg1 & 0xFFU;
	xil_printf("[%08u] [BHV %u] %s irq_num=0x%02x ack...\r\n",
		   (unsigned)ts_ms(), (unsigned)bhv_id, comp_name, (unsigned)irq_num);
	PsIrqAck(base_addr, comp_name);
	usleep(1000);

	//  Wait for 30(0x1E)/40(0x28) interrupt
	if (!WaitForIrq(intc_bit, 30000)) {
		xil_printf("[%08u] [BHV %u] %s TIMEOUT result\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, comp_name);
		return 0;
	}
	irq_reg1 = ReadIrqReg1(base_addr);
	irq_num  = irq_reg1 & 0xFFU;

	if (irq_num == 0x1EU) {
		xil_printf("[%08u] [BHV %u] %s SUCCESS(30) ack...\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, comp_name);
		PsIrqAck(base_addr, comp_name);
		xil_printf("[%08u] [BHV %u] %s COMPLETE!\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, comp_name);
		return 1;
	} else if (irq_num == 0x28U) {
		xil_printf("[%08u] [BHV %u] %s FAIL(40) ack...\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, comp_name);
		PsIrqAck(base_addr, comp_name);
		xil_printf("[%08u] [BHV %u] %s FAILED.\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, comp_name);
		return 0;
	} else {
		xil_printf("[%08u] [BHV %u] %s irq_num=0x%02x (unexpected)\r\n",
			   (unsigned)ts_ms(), (unsigned)bhv_id, comp_name, (unsigned)irq_num);
		if (irq_num != 0U) PsIrqAck(base_addr, comp_name);
		return 0;
	}
}

static void PrintMenu(void)
{
	xil_printf("\r\n");
	xil_printf("===========================================\r\n");
	xil_printf(" Multi-Component IRQ ACK\r\n");
	xil_printf(" Current component: [%d] %s\r\n",
		   cur_component, irq_table[cur_component].name);
	xil_printf("===========================================\r\n");
	xil_printf(" Keys:\r\n");
	xil_printf("  0~f      - Send behavior 0~15 to CURRENT component\r\n");
	xil_printf("  c        - Enter component-select mode \r\n");
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
	xil_printf(" PL IRQ: Multi-Component BM\r\n");
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
		DispatchAll();

		key_index = XUartPs_RecvByte(STDIN_BASEADDRESS);

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
		// Component select: enter selection mode
		else if (key_index == 'c' || key_index == 'C') {
			input_mode = MODE_SELECT_COMP;
			xil_printf("\r\nSelect component (0-%d): ", NUM_IRQ_SLOTS - 1);
		}
		// Behavior hex digits (0-9, a-f, A-F)
		else if ((key_index >= '0' && key_index <= '9') ||
			 (key_index >= 'a' && key_index <= 'f') ||
			 (key_index >= 'A' && key_index <= 'F')) {
			u8 bhv = (key_index <= '9') ? (u8)(key_index - '0') :
				 (key_index <= 'F') ? (u8)(key_index - 'A' + 10) :
				              (u8)(key_index - 'a' + 10);
			IrqSlot *comp = &irq_table[cur_component];
			xil_printf("\r\n>>> [BHV=%u] on [%d] %s <<<\r\n",
				   (unsigned)bhv, cur_component, comp->name);
			DoBehavior(comp->base_addr, bhv, comp->intc_bit, comp->name);
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
