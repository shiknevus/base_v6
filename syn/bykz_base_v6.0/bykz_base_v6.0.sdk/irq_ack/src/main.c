// @file main.c
// init + main loop

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
	xil_printf(" ec_pul_axis test (event-driven)\r\n");
	xil_printf("==============================================\r\n");

	// trsf_port_en
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

		// 1. drain events
		while (EvPop(&ev))
			ProcessEvent(&ev);

		// 1b. INTC poll fallback
		PollIntcFallback();

		if (EvDropCountGet()) {
			xil_printf("[%08u] EVQ overflow: %u dropped\r\n",
				   (unsigned)ts_ms(), (unsigned)EvDropCountGet());
			EvDropCountClear();
		}

		// 2. bhv timeout
		if (BhvIsRunning() && (s32)(ts_ms() - BhvDeadline()) > 0)
			BhvTimeout();

		// 3. menu
		key = MenuPollKey();
		if (key != 0 && MenuHandleKey((char)key))
			break;

		usleep(10000);
	}

	cleanup_platform();
	return 0;
}
