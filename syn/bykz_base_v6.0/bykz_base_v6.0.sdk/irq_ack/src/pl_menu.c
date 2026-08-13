// @file pl_menu.c
// menu + input FSM

#include "pl_menu.h"
#include "pl_reg.h"
#include "pl_intc.h"
#include "pl_bhv.h"
#include "pl_comp.h"
#include "util.h"

#include "platform.h"
#include "sleep.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xuartps_hw.h"

// input mode
typedef enum {
	MODE_BEHAVIOR,       // 0~f behavior
	MODE_SET_PARAM,      // param sel 1~6
	MODE_PARAM_VAL,      // value input
	MODE_EXT_BHV,        // '.' ext bhv
} InputMode;

static InputMode input_mode = MODE_BEHAVIOR;
static int  param_sel        = 0;    // param sel
static int  ext_bhv_val      = -1;   // bhv buf
#define PARAM_STR_MAX 24
static char param_str_buf[PARAM_STR_MAX];  // value buf
static int  param_str_len = 0;

int MenuPollKey(void)
{
	int c;
	if (!XUartPs_IsReceiveData(STDIN_BASEADDRESS))
		return 0;
	c = XUartPs_RecvByte(STDIN_BASEADDRESS);
	return (c == 0xFF) ? 0 : c;
}

void PrintMenu(void)
{
	xil_printf("\r\n");
	xil_printf("===========================================\r\n");
	xil_printf(" Multi-Component IRQ ACK (event-driven)\r\n");
	xil_printf(" Current component: [%d] %s\r\n",
		   cur_component, irq_table[cur_component].name);
	xil_printf("===========================================\r\n");
	xil_printf(" Keys:\r\n");
	xil_printf("  0~f / .  - Behavior (A ch)\r\n");
	xil_printf("  x/v/k    - Pause / Resume / Stop (B ch)\r\n");
	xil_printf("  d        - Drive reset (B ch)\r\n");
	xil_printf("  e/f      - Servo on / off (B ch)\r\n");
	xil_printf("  w        - Set motion params\r\n");
	xil_printf("  p        - Read position (mm)\r\n");
	xil_printf("  r        - Read all registers\r\n");
	xil_printf("  m        - Menu\r\n");
	xil_printf("  i        - Re-init\r\n");
	xil_printf("  q        - Exit\r\n");
	xil_printf("===========================================\r\n");
}

int MenuHandleKey(char key)
{
	// modes first
	if (input_mode == MODE_SET_PARAM) {
		if (key >= '1' && key <= '6') {
			param_sel = (int)(key - '0');
			param_str_len = 0;
			param_str_buf[0] = 0;
			input_mode = MODE_PARAM_VAL;
			xil_printf("%c\r\nEnter decimal value for %s: ", key, ParamName(param_sel));
		} else if (key == 0x1B || key == 'q' || key == 'Q') {
			xil_printf("\r\nCancelled.\r\n");
			input_mode = MODE_BEHAVIOR;
		}
	}
	// value input
	else if (input_mode == MODE_PARAM_VAL) {
		if ((key >= '0' && key <= '9') ||
		    key == '.' || key == '-') {
			if (param_str_len < PARAM_STR_MAX - 1) {
				param_str_buf[param_str_len++] = key;
				param_str_buf[param_str_len] = 0;
				xil_printf("%c", key);
			}
		} else if (key == '\r' || key == '\n') {
			xil_printf("\r\n");
			if (param_str_len > 0) {
				ParamWriteCur(param_sel, param_str_buf);
			} else {
				xil_printf("Empty value, ignored.\r\n");
			}
			param_str_len = 0;
			param_str_buf[0] = 0;
			input_mode = MODE_BEHAVIOR;
		} else if (key == 0x7F || key == 0x08) {
			// backspace
			if (param_str_len > 0) {
				param_str_len--;
				param_str_buf[param_str_len] = 0;
				xil_printf("\b \b");
			}
		} else if (key == 0x1B) {
			xil_printf("\r\nCancelled.\r\n");
			param_str_len = 0;
			param_str_buf[0] = 0;
			input_mode = MODE_BEHAVIOR;
		}
	}
	// ext bhv
	else if (input_mode == MODE_EXT_BHV) {
		if (key >= '0' && key <= '9') {
			int d = (int)(key - '0');
			if (ext_bhv_val < 0)
				ext_bhv_val = d;
			else if (ext_bhv_val <= 99)
				ext_bhv_val = ext_bhv_val * 10 + d;
			if (ext_bhv_val > 100) {
				xil_printf("\r\nInvalid behavior %d (max 100)\r\n",
					   ext_bhv_val);
				ext_bhv_val = -1;
				input_mode = MODE_BEHAVIOR;
			} else {
				xil_printf("%c", key);
			}
		} else if (key == '\r' || key == '\n') {
			if (ext_bhv_val > 0) {
				IrqSlot *comp = &irq_table[cur_component];
				xil_printf("\r\n>>> [BHV=%d] on [%d] %s <<<\r\n",
					   ext_bhv_val, cur_component, comp->name);
				if (BhvIsRunning()) {
					xil_printf("\r\n[BHV %u] still running on %s, ignore\r\n",
						   (unsigned)BhvActiveId(), BhvActiveName());
				} else {
					BhvStart(comp, (u8)ext_bhv_val);
				}
			} else {
				xil_printf("\r\nNo behavior, cancelled.\r\n");
			}
			ext_bhv_val = -1;
			input_mode = MODE_BEHAVIOR;
		} else if (key == 0x1B || key == 0x7F || key == 0x08) {
			xil_printf("\r\nCancelled.\r\n");
			ext_bhv_val = -1;
			input_mode = MODE_BEHAVIOR;
		}
		/* else: ignore other chars, stay in MODE_EXT_BHV */
	}
	// params
	else if (key == 'w' || key == 'W') {
		input_mode = MODE_SET_PARAM;
		PrintParamMenu();
	}
	// ext bhv
	else if (key == '.') {
		input_mode = MODE_EXT_BHV;
		ext_bhv_val = -1;
		xil_printf("\r\nEnter behavior (1-100): ");
	}
	// B: self-dispatch + auto-clear
	else if (key == 'x') {
		IrqSlot *comp = &irq_table[cur_component];
		Xil_Out32(comp->base_addr + PARAM26, 1U);   // pause
		xil_printf("\r\n>>> [%d:%s] PAUSE <<<\r\n", cur_component, comp->name);
	}
	else if (key == 'v') {
		IrqSlot *comp = &irq_table[cur_component];
		Xil_Out32(comp->base_addr + PARAM28, 1U);   // P28 first
		Xil_Out32(comp->base_addr + PARAM26, 1U);
		xil_printf("\r\n>>> [%d:%s] RESUME <<<\r\n", cur_component, comp->name);
	}
	else if (key == 'k') {
		IrqSlot *comp = &irq_table[cur_component];
		Xil_Out32(comp->base_addr + PARAM27, 1U);   // P27 first
		Xil_Out32(comp->base_addr + PARAM26, 1U);
		xil_printf("\r\n>>> [%d:%s] STOP <<<\r\n", cur_component, comp->name);
	}
	else if (key == 'd') {
		IrqSlot *comp = &irq_table[cur_component];
		Xil_Out32(comp->base_addr + PARAM29, 1U);   // drive reset
		usleep(10000);
		Xil_Out32(comp->base_addr + PARAM29, 0U);
		xil_printf("\r\n>>> [%d:%s] DRIVE RESET <<<\r\n", cur_component, comp->name);
	}
	else if (key == 'e') {
		IrqSlot *comp = &irq_table[cur_component];
		Xil_Out32(comp->base_addr + PARAM30, 1U);   // son on
		xil_printf("\r\n>>> [%d:%s] SON ON <<<\r\n", cur_component, comp->name);
	}
	else if (key == 'f') {
		IrqSlot *comp = &irq_table[cur_component];
		Xil_Out32(comp->base_addr + PARAM30, 0U);   // son off
		xil_printf("\r\n>>> [%d:%s] SON OFF <<<\r\n", cur_component, comp->name);
	}
	// hex bhv
	else if ((key >= '0' && key <= '9') ||
		 (key >= 'a' && key <= 'f') ||
		 (key >= 'A' && key <= 'F')) {
		u8 bhv = (key <= '9') ? (u8)(key - '0') :
			 (key <= 'F') ? (u8)(key - 'A' + 10) :
			              (u8)(key - 'a' + 10);
		IrqSlot *comp = &irq_table[cur_component];
		if (BhvIsRunning()) {
			xil_printf("\r\n[BHV %u] still running on %s, ignore\r\n",
				   (unsigned)BhvActiveId(), BhvActiveName());
		} else {
			xil_printf("\r\n>>> [BHV=%u] on [%d] %s <<<\r\n",
				   (unsigned)bhv, cur_component, comp->name);
			BhvStart(comp, bhv);
		}
	}
	// position
	else if (key == 'p' || key == 'P') {
		IrqSlot *comp = &irq_table[cur_component];
		u32 p51 = Xil_In32(comp->base_addr + PARAM51);
		u32 p53 = Xil_In32(comp->base_addr + PARAM53);
		xil_printf("\r\n[%d:%s] abs_pulse=%d (0x%08x) = ",
			   cur_component, comp->name, (int)p51, (unsigned)p51);
		PrintFp(PulseToMm(p51));
		xil_printf(" mm  PARAM53=0x%08x\r\n", (unsigned)p53);
	}
	// regs
	else if (key == 'r' || key == 'R') {
		IrqSlot *comp = &irq_table[cur_component];
		xil_printf("\r\n");
		PlRegRead(comp->base_addr, comp->name);
	}
	// re-init
	else if (key == 'i') {
		IrqSlot *comp = &irq_table[cur_component];
		xil_printf("\r\nRe-init [%d] %s...\r\n",
			   cur_component, comp->name);
		PlRegWritePulAxis(comp->base_addr);
		PlRegRead(comp->base_addr, comp->name);
	}
	// menu
	else if (key == 'm' || key == 'M') {
		PrintMenu();
	}
	else if (key == 'q' || key == 'Q') {
		xil_printf("\r\nExiting...\r\n");
		return 1;
	}
	else if (key >= 32 && key < 127) {
		xil_printf("\r\n[?] '%c' (0x%02x) - press 'm' for menu\r\n",
			   key, (unsigned)key);
	}

	return 0;
}
