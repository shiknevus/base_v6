// @file main.c
// Entry point only: init, main loop (event drain + fallback + timeout + menu).
// All functionality lives in modules: util / pl_intc / pl_bhv / pl_comp / pl_menu.

#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xstatus.h"
#include "sleep.h"

#include "pl_reg.h"
#include "util.h"
#include "pl_intc.h"
#include "pl_bhv.h"
#include "pl_comp.h"
#include "pl_menu.h"

int main(void)
{
	int Status;
	int key;

	init_platform();

	xil_printf("\r\n==============================================\r\n");
	xil_printf(" PL IRQ: Multi-Component BM (pure event-driven)\r\n");
	xil_printf(" 16-INTC dispatch architecture\r\n");
	xil_printf(" %d components registered on INTC#0\r\n", NUM_IRQ_SLOTS);
	xil_printf("==============================================\r\n");

	// Enable master app transfer port: mst_app_wk_mode[0]=1 (trsf_port_en) ->
	// starts depot polling so m2s frames (pul_motor etc.) are actually sent.
	// bit16=0 normal mode, bit31=0 no loopback.
	Xil_Out32(PL_CFG_BASE + MST_APP_MODE, 0x00000001U);

	// Initialize ALL components
	xil_printf("\r\nInitializing all components...\r\n");
	CompInitAll();

	Status = SetupInterruptSystem();
	if (Status != XST_SUCCESS) {
		xil_printf("Setup FAILED.\r\n");
		cleanup_platform();
		return XST_FAILURE;
	}
	BhvResetAck();

	xil_printf("\r\nAll components ready! Interrupts enabled.\r\n");

	PrintMenu();

	while (1) {
		IrqEvent ev;

		// 1. drain event queue (ISR feeds, main-loop consumes)
		while (EvPop(&ev))
			ProcessEvent(&ev);

		// 1b. INTC polling fallback (GIC ISR path may not deliver)
		PollIntcFallback();

		if (EvDropCountGet()) {
			xil_printf("[%08u] EVQ overflow: %u dropped\r\n",
				   (unsigned)ts_ms(), (unsigned)EvDropCountGet());
			EvDropCountClear();
		}

		// 2. behavior timeout (timestamp deadline, non-blocking)
		if (BhvIsRunning() && (s32)(ts_ms() - BhvDeadline()) > 0)
			BhvTimeout();

		// 3. UART menu (non-blocking, so events/timeouts run while idle)
		key = MenuPollKey();
		if (key != 0 && MenuHandleKey((char)key))
			break;

		usleep(10000);
	}

	cleanup_platform();
	return 0;
}
