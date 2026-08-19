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

    // ec_1do: A ch only (B/C disabled in RTL)
    base = PL_CFG_BASE + REG_BIAS_EC_1DO;

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

    PlRegInit();
    CmdInit();

    Status = SetupInterruptSystem();
    if (Status != XST_SUCCESS) {
        xil_printf("Setup FAILED.\r\n");
        cleanup_platform();
        return XST_FAILURE;
    }

    xil_printf("ec_1do + ec_pul_axis ready\r\n");
    PrintMenu();

    while (1) {
        CmdPoll();
        PollIrqFallback();
        usleep(10000);
    }

    return 0;
}
