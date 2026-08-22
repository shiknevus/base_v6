// @file main.c
// bare-metal: init regs -> enable interrupt -> serial cmds; irq ack in ISR + poll fallback

#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xstatus.h"
#include "sleep.h"

#include "pl_reg.h"
#include "pl_irq.h"
#include "pl_cmd.h"

// mst_app init: fiber link, slave communication
static int PlAppInit(void)
{
    u32 st;
    int i;

    // 1) wait aurora link up (LINK_STATUS[1:0]==2'b11)
    for (i = 0; i < 200; i++) {
        st = Xil_In32(PL_CFG_BASE + LINK_STATUS);
        if ((st & 0x3U) == 0x3U)
            break;
        usleep(100000); // 100ms
    }
    if (i >= 200) {
        xil_printf("Aurora link timeout, st=0x%08x\r\n", (unsigned)st);
        return XST_FAILURE;
    }
    xil_printf("Aurora link up\r\n");

    // 2) enable optical fiber interface init
    Xil_Out32(PL_CFG_BASE + OPT_INTF_INIT_EN, 0x00000001U);
    usleep(10000);

    // 3) enable transfer port
    Xil_Out32(PL_CFG_BASE + MST_APP_MODE, 0x00000001U);
    usleep(10000);

    // 4) wait slave station online
    for (i = 0; i < 100; i++) {
        st = Xil_In32(PL_CFG_BASE + SLV_STA_NUM);
        if (st != 0U)
            break;
        usleep(100000); // 100ms
    }
    if (i >= 100) {
        xil_printf("Slave station timeout\r\n");
        return XST_FAILURE;
    }
    xil_printf("Slave station number=%u\r\n", (unsigned)st);
    return XST_SUCCESS;
}

// PL regs for irq ack
static void PlRegInit(void)
{
    u32 base = PL_CFG_BASE + REG_BIAS_EC_PUL_AXIS;

    Xil_Out32(base + RST_EN, 0x00000000U);              // reset
    Xil_Out32(base + RST_EN, 0x00000001U);              // release
    Xil_Out32(base + EC_ID, 0x00003FFFU);
    Xil_Out32(base + SC_ID, 0x00000066U);
    Xil_Out32(base + BHV_PRIORITY, 0x00000000U);        // abc

    Xil_Out32(base + A_EN, 0x00000001U);
    Xil_Out32(base + A_TX_OT, 60U);                     // tx timeout 60s
    Xil_Out32(base + B_EN, 0x00000001U);
    Xil_Out32(base + B_TX_OT, 3U);                      // tx timeout 3s
    Xil_Out32(base + C_EN, 0x00000000U);
    Xil_Out32(base + C_TX_OT, 0x16U);                   // tb: 22s
    Xil_Out32(base + C_GAP_CRL, 1000U);                 // 1s period (tb=1ms too fast for bare-metal)

    // ec_1do_u0: mst DO, A ch only (B/C disabled in RTL)
    base = PL_CFG_BASE + REG_BIAS_EC_1DO;

    Xil_Out32(base + RST_EN, 0x00000000U);              // reset
    Xil_Out32(base + RST_EN, 0x00000001U);              // release
    Xil_Out32(base + EC_ID, 0x00000088U);
    Xil_Out32(base + SC_ID, 0x00000066U);
    Xil_Out32(base + BHV_PRIORITY, 0x00000000U);

    Xil_Out32(base + A_EN, 0x00000001U);
    Xil_Out32(base + A_TX_OT, 30U);                     // tx timeout 30s

    // ec_1do_u1: slave DO, A ch only (tb_ec_1do_slave params)
    base = PL_CFG_BASE + REG_BIAS_EC_1DO_SLV;

    Xil_Out32(base + RST_EN, 0x00000000U);              // reset
    Xil_Out32(base + RST_EN, 0x00000001U);              // release
    Xil_Out32(base + EC_ID, 0x00003FFFU);
    Xil_Out32(base + SC_ID, 0x00000004U);
    Xil_Out32(base + BHV_PRIORITY, 0x00000000U);

    Xil_Out32(base + A_EN, 0x00000001U);
    Xil_Out32(base + A_TX_OT, 30U);                     // tx timeout 30s

    // ec_can_servo_11: A ch only (B/C disabled, tb_ec_ethercat_servo params)
    base = PL_CFG_BASE + REG_BIAS_EC_CAN_SERVO;

    Xil_Out32(base + RST_EN, 0x00000000U);              // reset
    Xil_Out32(base + RST_EN, 0x00000001U);              // release
    Xil_Out32(base + EC_ID, 0x00000088U);
    Xil_Out32(base + SC_ID, 0x00000066U);
    Xil_Out32(base + BHV_PRIORITY, 0x00000000U);

    Xil_Out32(base + A_EN, 0x00000001U);
    Xil_Out32(base + A_TX_OT, 30U);                     // tx timeout 30s
}

int main(void)
{
    int Status;

    init_platform();

    Status = PlAppInit();
    if (Status != XST_SUCCESS) {
        xil_printf("App init FAILED, continue anyway\r\n");
        // non-fatal: components may still work partially
    }

    PlRegInit();
    CmdInit();

    Status = SetupInterruptSystem();
    if (Status != XST_SUCCESS) {
        xil_printf("Setup FAILED.\r\n");
        cleanup_platform();
        return XST_FAILURE;
    }

    xil_printf("ec_1do + ec_pul_axis + ec_can_servo ready\r\n");
    PrintMenu();

    while (1) {
        CmdPoll();
        PollIrqFallback();
        usleep(10000);
    }

    return 0;
}