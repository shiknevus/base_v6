// @file pl_irq.c
// bare-metal interrupt ack: read IRQ_REG1/2, echo {bhv,tx} back to rpt reg
// ISR path + poll fallback

#include "pl_irq.h"
#include "pl_reg.h"
#include "pl_cmd.h"
#include "util.h"

#include <stdint.h>

#include "xil_io.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include "xscugic.h"
#include "xintc.h"
#include "xparameters.h"
#include "xstatus.h"

// PL INTC -> GIC
#define INTC_DEV_ID     0
#define INTC_BASE       0xA0000000U      // INTC #0 (1do/axis)
#define GIC_SPI         121
#define INTC_BIT_1DO   1       // ec_1do_u0 (mst DO)
#define INTC_BIT_1DO_S 2       // ec_1do_u1 (slave DO)
#define INTC_BIT_AXIS  9       // ec_pul_axis

#define INTC_DEV_SRV    2
#define INTC_BASE_SRV   0xA0002000U      // INTC #2 (can servo)
#define GIC_SPI_SRV     123
#define INTC_BIT_SERVO  11      // ec_can_servo_11: map_irq[75] -> INTC#2 bit11

// INTC regs
#define INTC_ISR        0x00U
#define INTC_IER        0x08U
#define INTC_IAR        0x0CU

#define EC_BASE        (PL_CFG_BASE + REG_BIAS_EC_PUL_AXIS)
#define EC1DO_BASE     (PL_CFG_BASE + REG_BIAS_EC_1DO)
#define EC_S1DO_BASE   (PL_CFG_BASE + REG_BIAS_EC_1DO_SLV)
#define EC_SRV_BASE    (PL_CFG_BASE + REG_BIAS_EC_CAN_SERVO)

// ps ack result, must match RTL IRQ_OK
#define RES_OK          0x51U
#define RES_NG          0x52U

static XScuGic Gic;
static XIntc   Intc;      // INTC #0
static XIntc   IntcSrv;   // INTC #2

// ISR hit count, shown by 'g'
static volatile u32 g_isr_cnt;

u32 IrqIsrCount(void)
{
    return g_isr_cnt;
}

// wait IRQ_REG1 nonzero (latched by arbiter 1~2 clk after INTC edge)
static u32 ReadReg1(u32 base)
{
    u32 reg1 = 0U;
    int i;

    for (i = 0; i < 8; i++) {
        reg1 = Xil_In32(base + IRQ_REG1);
        if (reg1 != 0U)
            break;
    }
    return reg1;
}

// RTL layout: IRQ_REG1 = {ec_id[13:0], sc_id[9:0], bhv_id[7:0]},
//             IRQ_REG2 = {tx_id[7:0], alm_num[7:0], 16'd0}
static u32 AckIrq(u32 base, u32 reg1, u32 reg2)
{
    u32 bhv, tx, resp;
    u32 rpt_off;
    u32 b_busy, a_busy, c_busy;

    bhv = reg1 & 0xFFU;
    tx  = (reg2 >> 24) & 0xFFU;

    b_busy = Xil_In32(base + EC_CHB_ST) & 0x1U;
    a_busy = Xil_In32(base + EC_CHA_ST) & 0x1U;
    c_busy = Xil_In32(base + EC_CHC_ST) & 0x1U;

    if (b_busy && (Xil_In32(base + B_TX_ID) & 0xFFU) == tx) {
        rpt_off = B_TX_RSULT_RPT;
        bhv = Xil_In32(base + B_BHV_ID) & 0xFFU;   // b_bhv_id holds during transaction
    } else if (a_busy && (Xil_In32(base + A_TX_ID) & 0xFFU) == tx) {
        rpt_off = A_TX_RSULT_RPT;
        bhv = Xil_In32(base + A_BHV_ID) & 0xFFU;
    } else if (c_busy && (Xil_In32(base + C_TX_ID) & 0xFFU) == tx) {
        rpt_off = C_TX_RSULT_RPT;
        bhv = Xil_In32(base + C_BHV_ID) & 0xFFU;
    } else {
        return 0;   // stale: drop, no channel busy with this tx
    }

    resp = (bhv << 24) | (tx << 16) | (RES_OK << 8) | 0x00U;   // rpt={bhv,tx,result,alm}
    Xil_Out32(base + rpt_off, resp);

    // getpos done: report position (PARAM51 pulses -> mm)
    if (base == EC_BASE && rpt_off == A_TX_RSULT_RPT && tx == 0x1EU &&
        (Xil_In32(base + A_BHV_ID) & 0xFFU) == 30U) {
        u32 p51 = Xil_In32(base + PARAM51);
        xil_printf("pos %d pulses (", (int)p51);
        PrintFp((float)(int)p51 / (float)CmdFactor());
        xil_printf(" mm)\r\n");
    }
    return resp;
}

static const char *IrqTag(u32 base)
{
    if (base == EC1DO_BASE)
        return "1do";
    if (base == EC_S1DO_BASE)
        return "1doS";
    if (base == EC_SRV_BASE)
        return "srv";
    return "axis";
}

static void PrintAck(const char *tag, u32 reg1, u32 reg2, u32 resp)
{
    xil_printf("[%u] %s raw=0x%08x tx=%u alm=%u resp=0x%08x\r\n",
               (unsigned)ts_ms(), tag, (unsigned)reg1,
               (unsigned)((reg2 >> 24) & 0xFFU),
               (unsigned)((reg2 >> 16) & 0xFFU), (unsigned)resp);
}

static void PrintStale(const char *tag, u32 reg1)
{
    xil_printf("[%u] %s stale raw=0x%08x dropped\r\n",
               (unsigned)ts_ms(), tag, (unsigned)reg1);
}

static void HandleIrq(u32 base)
{
    u32 reg1, reg2, resp;
    const char *tag = IrqTag(base);

    reg1 = ReadReg1(base);
    if (reg1 == 0U)
        return; // stale irq
    reg2 = Xil_In32(base + IRQ_REG2);
    resp = AckIrq(base, reg1, reg2);
    if (resp)
        PrintAck(tag, reg1, reg2, resp);
    else
        PrintStale(tag, reg1);
}

static void EcIsr(void *ref)
{
    int id = (int)(intptr_t)ref;
    u32 base = (id == INTC_BIT_1DO)   ? EC1DO_BASE :
               (id == INTC_BIT_1DO_S) ? EC_S1DO_BASE : EC_BASE;

    g_isr_cnt++;
    HandleIrq(base);
}

static void ServoIsr(void *ref)
{
    g_isr_cnt++;
    HandleIrq(EC_SRV_BASE);
}

// poll INTC directly: works even if the GIC path is broken
void PollIrqFallback(void)
{
    const struct { u32 intc; int bit; u32 base; } irqs[] = {
        { INTC_BASE,     INTC_BIT_1DO,   EC1DO_BASE },
        { INTC_BASE,     INTC_BIT_1DO_S, EC_S1DO_BASE },
        { INTC_BASE,     INTC_BIT_AXIS,  EC_BASE },
        { INTC_BASE_SRV, INTC_BIT_SERVO, EC_SRV_BASE },
    };
    int i;

    for (i = 0; i < 4; i++) {
        u32 bit = 1U << irqs[i].bit;
        u32 pending = Xil_In32(irqs[i].intc + INTC_ISR) & Xil_In32(irqs[i].intc + INTC_IER);

        if (!(pending & bit))
            continue;
        Xil_Out32(irqs[i].intc + INTC_IAR, bit);   // clear first
        HandleIrq(irqs[i].base);
    }
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

    XIntc_Connect(&Intc, INTC_BIT_1DO,
                  (XInterruptHandler)EcIsr, (void *)(intptr_t)INTC_BIT_1DO);
    XIntc_Connect(&Intc, INTC_BIT_1DO_S,
                  (XInterruptHandler)EcIsr, (void *)(intptr_t)INTC_BIT_1DO_S);
    XIntc_Connect(&Intc, INTC_BIT_AXIS,
                  (XInterruptHandler)EcIsr, (void *)(intptr_t)INTC_BIT_AXIS);
    XIntc_Start(&Intc, XIN_REAL_MODE);
    XIntc_Enable(&Intc, INTC_BIT_1DO);
    XIntc_Enable(&Intc, INTC_BIT_1DO_S);
    XIntc_Enable(&Intc, INTC_BIT_AXIS);

    // INTC #0 -> GIC; XIntc driver acks IAR after EcIsr returns
    XScuGic_SetPriorityTriggerType(&Gic, GIC_SPI, 0xA0U, 0x1U);  // active-high level
    Status = XScuGic_Connect(&Gic, GIC_SPI,
                     (Xil_ExceptionHandler)XIntc_InterruptHandler, &Intc);
    if (Status != XST_SUCCESS)
        return XST_FAILURE;
    XScuGic_Enable(&Gic, GIC_SPI);

    // INTC #2 -> GIC (can servo, map_irq[75])
    Status = XIntc_Initialize(&IntcSrv, INTC_DEV_SRV);
    if (Status != XST_SUCCESS)
        return XST_FAILURE;
    XIntc_Connect(&IntcSrv, INTC_BIT_SERVO,
                  (XInterruptHandler)ServoIsr, NULL);
    XIntc_Start(&IntcSrv, XIN_REAL_MODE);
    XIntc_Enable(&IntcSrv, INTC_BIT_SERVO);

    XScuGic_SetPriorityTriggerType(&Gic, GIC_SPI_SRV, 0xA0U, 0x1U);  // active-high level
    Status = XScuGic_Connect(&Gic, GIC_SPI_SRV,
                     (Xil_ExceptionHandler)XIntc_InterruptHandler, &IntcSrv);
    if (Status != XST_SUCCESS)
        return XST_FAILURE;
    XScuGic_Enable(&Gic, GIC_SPI_SRV);

    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                     (Xil_ExceptionHandler)XScuGic_InterruptHandler, &Gic);
    Xil_ExceptionEnable();

    return XST_SUCCESS;
}
