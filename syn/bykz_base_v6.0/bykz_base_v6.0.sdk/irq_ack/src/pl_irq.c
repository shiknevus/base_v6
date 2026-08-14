// @file pl_irq.c
// bare-metal interrupt ack: read IRQ_REG1/2, echo {bhv,tx} back to rpt reg
// ISR path + poll fallback

#include "pl_irq.h"
#include "pl_reg.h"
#include "pl_cmd.h"
#include "util.h"

#include "xil_io.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include "xscugic.h"
#include "xintc.h"
#include "xparameters.h"
#include "xstatus.h"

// PL INTC #0 -> GIC
#define INTC_DEV_ID     0
#define INTC_BASE       0xA0000000U
#define GIC_SPI         121
#define INTC_BIT        9       // ec_pul_axis

// INTC regs
#define INTC_ISR        0x00U
#define INTC_IER        0x08U
#define INTC_IAR        0x0CU

#define EC_BASE         (PL_CFG_BASE + REG_BIAS_EC_PUL_AXIS)

// ps ack result, must match RTL IRQ_OK
#define RES_OK          0x51U

static XScuGic Gic;
static XIntc   Intc;

// ISR hit count, shown by 'g'
static volatile u32 g_isr_cnt;

u32 IrqIsrCount(void)
{
    return g_isr_cnt;
}

// wait IRQ_REG1 nonzero (latched by arbiter 1~2 clk after INTC edge)
static u32 ReadReg1(void)
{
    u32 reg1 = 0U;
    int i;

    for (i = 0; i < 8; i++) {
        reg1 = Xil_In32(EC_BASE + IRQ_REG1);
        if (reg1 != 0U)
            break;
    }
    return reg1;
}

// respond according to the interrupt registers; write only, caller prints
// returns resp, or 0 when dropped (stale irq: no busy channel tx matches)
static u32 AckIrq(u32 reg1)
{
    u32 bhv, tx, resp;
    u32 rpt_off;
    u32 b_busy, a_busy;

    bhv = (reg1 >> 8) & 0xFFU;
    tx  = reg1 & 0xFFU;

    b_busy = Xil_In32(EC_BASE + EC_CHB_ST) & 0x1U;
    a_busy = Xil_In32(EC_BASE + EC_CHA_ST) & 0x1U;

    // route by live channel state: reg1's bhv field clears to 0 when the FSM
    // returns to S_IDLE, so it cannot be trusted for routing
    if (b_busy && (Xil_In32(EC_BASE + B_TX_ID) & 0xFFU) == tx) {
        rpt_off = B_TX_RSULT_RPT;
        bhv = Xil_In32(EC_BASE + B_BHV_ID) & 0xFFU;   // b_bhv_id holds during transaction
    } else if (a_busy && (Xil_In32(EC_BASE + A_TX_ID) & 0xFFU) == tx) {
        rpt_off = A_TX_RSULT_RPT;
        bhv = Xil_In32(EC_BASE + A_BHV_ID) & 0xFFU;
    } else {
        return 0;   // stale: drop, no channel busy with this tx
    }

    // rpt layout: {bhv, tx, result, ps_alm}; write pulses tx_result_vld, which is also the arbiter's irq_receive_ack
    resp = (bhv << 24) | (tx << 16) | (RES_OK << 8) | 0x00U;
    Xil_Out32(EC_BASE + rpt_off, resp);

    // getpos done: report position (PARAM51 pulses -> mm)
    if (rpt_off == A_TX_RSULT_RPT && tx == 0x1EU &&
        (Xil_In32(EC_BASE + A_BHV_ID) & 0xFFU) == 30U) {
        u32 p51 = Xil_In32(EC_BASE + PARAM51);
        xil_printf("pos %d pulses (", (int)p51);
        PrintFp((float)(int)p51 / (float)CmdFactor());
        xil_printf(" mm)\r\n");
    }
    return resp;
}

static void PrintAck(const char *tag, u32 reg1, u32 reg2, u32 resp)
{
    xil_printf("[%u] %s raw=0x%08x alm=%u resp=0x%08x\r\n",
               (unsigned)ts_ms(), tag, (unsigned)reg1,
               (unsigned)((reg2 >> 24) & 0xFFU), (unsigned)resp);
}

static void PrintStale(const char *tag, u32 reg1)
{
    xil_printf("[%u] %s stale raw=0x%08x dropped\r\n",
               (unsigned)ts_ms(), tag, (unsigned)reg1);
}

static void EcIsr(void *ref)
{
    u32 reg1, reg2, resp;

    (void)ref;
    g_isr_cnt++;

    reg1 = ReadReg1();
    if (reg1 == 0U)
        return; // stale irq
    reg2 = Xil_In32(EC_BASE + IRQ_REG2);
    resp = AckIrq(reg1);
    if (resp)
        PrintAck("isr", reg1, reg2, resp);
    else
        PrintStale("isr", reg1);
}

// poll INTC directly: works even if the GIC path is broken
void PollIrqFallback(void)
{
    u32 pending = Xil_In32(INTC_BASE + INTC_ISR) & Xil_In32(INTC_BASE + INTC_IER);
    u32 reg1, reg2, resp;

    if (!(pending & (1U << INTC_BIT)))
        return;

    Xil_Out32(INTC_BASE + INTC_IAR, 1U << INTC_BIT);   // clear first

    reg1 = ReadReg1();
    if (reg1 == 0U)
        return; // stale irq
    reg2 = Xil_In32(EC_BASE + IRQ_REG2);
    resp = AckIrq(reg1);
    if (resp)
        PrintAck("poll", reg1, reg2, resp);
    else
        PrintStale("poll", reg1);
}

// interrupt setup: INTC bit -> GIC SPI
int SetupInterruptSystem(void)
{
    XScuGic_Config *GicCfg;
    int Status;

    GicCfg = XScuGic_LookupConfig(XPAR_SCUGIC_0_DEVICE_ID);
    if (!GicCfg)
        return XST_FAILURE;
    Status = XScuGic_CfgInitialize(&Gic, GicCfg, GicCfg->CpuBaseAddress);
    if (Status != XST_SUCCESS)
        return XST_FAILURE;

    Status = XIntc_Initialize(&Intc, INTC_DEV_ID);
    if (Status != XST_SUCCESS)
        return XST_FAILURE;

    XIntc_Connect(&Intc, INTC_BIT, (XInterruptHandler)EcIsr, NULL);
    XIntc_Start(&Intc, XIN_REAL_MODE);
    XIntc_Enable(&Intc, INTC_BIT);

    // INTC -> GIC; XIntc driver acks IAR after EcIsr returns
    XScuGic_SetPriorityTriggerType(&Gic, GIC_SPI, 0xA0U, 0x1U);  // active-high level
    Status = XScuGic_Connect(&Gic, GIC_SPI,
                     (Xil_ExceptionHandler)XIntc_InterruptHandler, &Intc);
    if (Status != XST_SUCCESS)
        return XST_FAILURE;
    XScuGic_Enable(&Gic, GIC_SPI);

    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                     (Xil_ExceptionHandler)XScuGic_InterruptHandler, &Gic);
    Xil_ExceptionEnable();

    return XST_SUCCESS;
}
