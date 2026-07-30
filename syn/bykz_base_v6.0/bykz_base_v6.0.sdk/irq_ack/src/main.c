
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

#define TEST_INTC_IDX  0
#define TEST_BASE      (PL_CFG_BASE + REG_BIAS_EC_3DI_2DO)
#define TEST_INTC_BIT  3

static XScuGic Gic;
static XIntc   Intc;
volatile static u32 IrqCount   = 0;
volatile static int IrqPending = FALSE;
static IrqSlot *irq_lut[32];

// Function declarations
static int  SetupInterruptSystem(void);
static void PlIrqHandler(void *CallbackRef);
static void PlRegWrite(u32 base_addr);
static void PlRegWritePulAxis(u32 base_addr);
static void PlRegRead(u32 base_addr);
static void PsIrqAck(u32 base_addr, const char *name);
static void DispatchIntc(int intc_idx);
static void DispatchAll(void);
static int  WaitForIrq(u32 expected_bit, u32 timeout_ms);
static int  DoBehavior(u32 base_addr, u8 bhv_id, u32 intc_bit);

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
	Xil_Out32(base_addr + RST_EN,  0x00000001U);
	Xil_Out32(base_addr + SC_ID,   0x00000066U);
	Xil_Out32(base_addr + EC_ID,   0x00000088U);
	Xil_Out32(base_addr + A_EN,    0x00000001U);
	Xil_Out32(base_addr + B_EN,    0x00000000U);
	Xil_Out32(base_addr + C_EN,    0x00000000U);
	Xil_Out32(base_addr + A_TX_OT, 0xFFFF0000U);
	xil_printf("PL regs init @0x%08x\r\n", (unsigned)base_addr);
}

// ec_pul_axis specific initialization
static void PlRegWritePulAxis(u32 base_addr)
{
	Xil_Out32(base_addr + RST_EN,  0x00000001U);
	Xil_Out32(base_addr + SC_ID,   0x00000066U);
	Xil_Out32(base_addr + EC_ID,   0x00000088U);
	Xil_Out32(base_addr + A_EN,    0x00000001U);
	Xil_Out32(base_addr + B_EN,    0x00000000U);
	Xil_Out32(base_addr + C_EN,    0x00000000U);
	Xil_Out32(base_addr + A_TX_OT, 0xFFFF0000U);

	Xil_Out32(base_addr + PARAM1,  0x00002710U);
	Xil_Out32(base_addr + PARAM2,  0x00002710U);
	Xil_Out32(base_addr + PARAM3,  0x00002710U);
	Xil_Out32(base_addr + PARAM4,  0x00001388U);
	Xil_Out32(base_addr + PARAM5,  0x00002710U);
	Xil_Out32(base_addr + PARAM6,  0x00002710U);
	Xil_Out32(base_addr + PARAM7,  0x00004E20U);
	Xil_Out32(base_addr + PARAM8,  0x00004E20U);
	Xil_Out32(base_addr + PARAM9,  0x000003E8U);
	Xil_Out32(base_addr + PARAM16, 0x00000000U);
	Xil_Out32(base_addr + PARAM27, 0x00000000U);
	Xil_Out32(base_addr + PARAM30, 0x00000001U);
	xil_printf("PL pul_axis init @0x%08x\r\n", (unsigned)base_addr);
}

static void PlRegRead(u32 base_addr)
{
	xil_printf("  RST_EN=0x%08x SC_ID=0x%08x EC_ID=0x%08x A_EN=0x%08x\r\n",
		(unsigned)Xil_In32(base_addr + RST_EN),
		(unsigned)Xil_In32(base_addr + SC_ID),
		(unsigned)Xil_In32(base_addr + EC_ID),
		(unsigned)Xil_In32(base_addr + A_EN));
	xil_printf("  PARAM1=0x%08x PARAM2=0x%08x PARAM3=0x%08x PARAM51=0x%08x\r\n",
		(unsigned)Xil_In32(base_addr + PARAM1),
		(unsigned)Xil_In32(base_addr + PARAM2),
		(unsigned)Xil_In32(base_addr + PARAM3),
		(unsigned)Xil_In32(base_addr + PARAM51));
}

// Interrupt acknowledge
static void PsIrqAck(u32 base_addr, const char *name)
{
	u32 irq_reg1, irq_reg2, irq_num, bhv_id, status, resp;

	irq_reg2 = Xil_In32(base_addr + IRQ_REG2);
	irq_reg1 = Xil_In32(base_addr + IRQ_REG1);

	xil_printf(" [%s] IRQ_REG2=0x%08x IRQ_REG1=0x%08x\r\n",
		   name, (unsigned)irq_reg2, (unsigned)irq_reg1);

	if (irq_reg1 == 0U) {
		xil_printf(" [%s] IRQ_REG1=0, skip ack\r\n", name);
		return;
	}

	if (irq_reg2 != 0U)
		xil_printf(" [%s] ALARM num=0x%02x\r\n", name,
			   (unsigned)((irq_reg2 >> 24) & 0xFFU));

	bhv_id  = (irq_reg1 >> 8) & 0xFFU;
	irq_num = irq_reg1 & 0xFFU;

	if (bhv_id == 1U || bhv_id == 2U)
		status = (irq_num == 0x28U) ? 0x5101U : 0x5100U;
	else
		status = (irq_num == 0x28U) ? 0x5199U : 0x5167U;

	resp = (bhv_id << 24) | (irq_num << 16) | status;
	Xil_Out32(base_addr + A_TX_RSULT_RPT, resp);
	xil_printf(" [%s] -> A_TX_RSULT_RPT=0x%08x (bhv=%u irq_num=%u %s)\r\n",
		   name, (unsigned)resp, (unsigned)bhv_id, (unsigned)irq_num,
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

	Status = XIntc_Initialize(&Intc, intc_desc[TEST_INTC_IDX].dev_id);
	if (Status != XST_SUCCESS) return XST_FAILURE;

	for (i = 0; i < NUM_IRQ_SLOTS; i++) {
		if (!irq_table[i].name) continue;
		if (irq_table[i].intc_idx != TEST_INTC_IDX) continue;
		XIntc_Connect(&Intc, irq_table[i].intc_bit,
			      (XInterruptHandler)PlIrqHandler, &Intc);
	}

	XIntc_Start(&Intc, XIN_REAL_MODE);

	for (i = 0; i < NUM_IRQ_SLOTS; i++) {
		if (!irq_table[i].name) continue;
		if (irq_table[i].intc_idx != TEST_INTC_IDX) continue;
		XIntc_Enable(&Intc, irq_table[i].intc_bit);
	}

	Status = XScuGic_Connect(&Gic, intc_desc[TEST_INTC_IDX].gic_spi,
				 (Xil_ExceptionHandler)XIntc_InterruptHandler, &Intc);
	if (Status != XST_SUCCESS) return XST_FAILURE;
	XScuGic_Enable(&Gic, intc_desc[TEST_INTC_IDX].gic_spi);

	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
				     (Xil_ExceptionHandler)XScuGic_InterruptHandler, &Gic);
	Xil_ExceptionEnable();

	for (i = 0; i < 32; i++) irq_lut[i] = NULL;
	for (i = 0; i < NUM_IRQ_SLOTS; i++) {
		if (!irq_table[i].name) continue;
		if (irq_table[i].intc_idx != TEST_INTC_IDX) continue;
		irq_lut[irq_table[i].intc_bit] = &irq_table[i];
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

	if (intc_idx == TEST_INTC_IDX) {
		for (u32 bit = 0; bit < 32 && pending; bit++) {
			u32 mask = 1U << bit;
			if ((pending & mask) && irq_lut[bit]) {
				xil_printf("\r\n[Dispatch] %s (INTC#%d bit%u)\r\n",
					   irq_lut[bit]->name, intc_idx, bit);
				PsIrqAck(irq_lut[bit]->base_addr, irq_lut[bit]->name);
				pending &= ~mask;
			}
		}
	} else {
		for (u32 i = 0; i < NUM_IRQ_SLOTS && pending; i++) {
			if (!irq_table[i].name) continue;
			if (irq_table[i].intc_idx != intc_idx) continue;
			u32 mask = 1U << irq_table[i].intc_bit;
			if (pending & mask) {
				xil_printf("\r\n[Dispatch] %s (INTC#%d bit%u)\r\n",
					   irq_table[i].name, intc_idx, irq_table[i].intc_bit);
				PsIrqAck(irq_table[i].base_addr, irq_table[i].name);
				pending &= ~mask;
			}
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
	u32 base = intc_desc[TEST_INTC_IDX].baseaddr;

	xil_printf("  [WaitIrq] waiting bit%u (timeout=%ums)...\r\n",
		   expected_bit, (unsigned)timeout_ms);

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
				xil_printf("  [WaitIrq] got bit%u!\r\n", expected_bit);
				return 1;
			}
		}

		usleep(1000);
		if (timeout_ms) {
			elapsed_ms++;
			if ((elapsed_ms % 1000) == 0)
				xil_printf("  [WaitIrq] %us ISR=0x%08x\r\n",
					   (unsigned)(elapsed_ms / 1000), (unsigned)isr);
			if (elapsed_ms >= timeout_ms) return 0;
		}
	}
}

// Read IRQ_REG1
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
static int DoBehavior(u32 base_addr, u8 bhv_id, u32 intc_bit)
{
	u32 irq_reg1, irq_num;

	xil_printf("\r\n[BHV %u] trigger @0x%08x...\r\n",
		   (unsigned)bhv_id, (unsigned)base_addr);
	Xil_Out32(base_addr + A_BHV_ID, (u32)bhv_id);

	// ① Wait for 10(0x0A) interrupt
	if (!WaitForIrq(intc_bit, 5000)) {
		xil_printf("[BHV %u] TIMEOUT req(10)\r\n", (unsigned)bhv_id);
		return 0;
	}
	irq_reg1 = ReadIrqReg1(base_addr);
	irq_num  = irq_reg1 & 0xFFU;
	xil_printf("[BHV %u] irq_num=0x%02x ack...\r\n",
		   (unsigned)bhv_id, (unsigned)irq_num);
	IrqCount++;
	PsIrqAck(base_addr, "bhv");
	usleep(1000);

	// ② Wait for 30(0x1E)/40(0x28) interrupt
	if (!WaitForIrq(intc_bit, 30000)) {
		xil_printf("[BHV %u] TIMEOUT result\r\n", (unsigned)bhv_id);
		return 0;
	}
	irq_reg1 = ReadIrqReg1(base_addr);
	irq_num  = irq_reg1 & 0xFFU;
	IrqCount++;

	if (irq_num == 0x1EU) {
		xil_printf("[BHV %u] SUCCESS(30) ack...\r\n", (unsigned)bhv_id);
		PsIrqAck(base_addr, "bhv");
		xil_printf("[BHV %u] COMPLETE!\r\n", (unsigned)bhv_id);
		return 1;
	} else if (irq_num == 0x28U) {
		xil_printf("[BHV %u] FAIL(40) ack...\r\n", (unsigned)bhv_id);
		PsIrqAck(base_addr, "bhv");
		xil_printf("[BHV %u] FAILED.\r\n", (unsigned)bhv_id);
		return 0;
	} else {
		xil_printf("[BHV %u] irq_num=0x%02x (unexpected)\r\n",
			   (unsigned)bhv_id, (unsigned)irq_num);
		if (irq_num != 0U) PsIrqAck(base_addr, "bhv");
		return 0;
	}
}

int main(void)
{
	int Status;

	init_platform();

	xil_printf("\r\n==============================================\r\n");
	xil_printf(" PL IRQ: 16-INTC dispatch architecture\r\n");
	xil_printf(" INTC#0 @0x%08x -> GIC SPI %u\r\n",
		   (unsigned)intc_desc[0].baseaddr, (unsigned)intc_desc[0].gic_spi);
	xil_printf("==============================================\r\n");

	PlRegWrite(TEST_BASE);
	PlRegRead(TEST_BASE);

	Status = SetupInterruptSystem();
	if (Status != XST_SUCCESS) {
		xil_printf("Setup FAILED.\r\n");
		cleanup_platform();
		return XST_FAILURE;
	}
	xil_printf("Ready. p=PARAM51 0~f=bhv 0~15\r\n");

	while (1) {
		DispatchAll();

		char c = XUartPs_RecvByte(STDIN_BASEADDRESS);
		if (c == 'p' || c == 'P') {
			xil_printf("\r\n[PARAM51] = 0x%08x\r\n",
				   (unsigned)Xil_In32(TEST_BASE + PARAM51));
		} else if ((c >= '0' && c <= '9') ||
			   (c >= 'a' && c <= 'f') ||
			   (c >= 'A' && c <= 'F')) {
			u8 bhv = (c <= '9') ? (u8)(c - '0') :
				 (c <= 'F') ? (u8)(c - 'A' + 10) :
				              (u8)(c - 'a' + 10);
			DoBehavior(TEST_BASE, bhv, TEST_INTC_BIT);
		} else if (c != 0) {
			xil_printf("\r\n[ERROR!] '%c'\r\n", c);
		}

		usleep(10000);
	}

	return 0;
}
