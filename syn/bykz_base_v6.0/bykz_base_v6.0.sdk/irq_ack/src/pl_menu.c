// @file pl_menu.c
// Interactive UART menu + input mode state machine

#include "pl_menu.h"
#include "pl_reg.h"
#include "pl_intc.h"
#include "pl_bhv.h"
#include "pl_comp.h"
#include "util.h"

#include "platform.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xuartps_hw.h"

// Input mode state machine
typedef enum {
	MODE_BEHAVIOR,       // 0~f triggers behavior on current component
	MODE_SELECT_COMP,    // waiting for digits to select component
	MODE_SET_PARAM,      // waiting for param selection (1~6)
	MODE_PARAM_VAL,      // waiting for value input
	MODE_EXT_BHV,        // '.' pressed: enter behavior number (1-100)
} InputMode;

static InputMode input_mode = MODE_BEHAVIOR;
static int  comp_select_buf = -1;    // accumulated digit buffer, -1 = empty
static int  param_sel        = 0;    // which param is being edited (1..6)
static int  ext_bhv_val      = -1;   // accumulated behavior number, -1 = none
#define PARAM_STR_MAX 24
static char param_str_buf[PARAM_STR_MAX];  // decimal value accumulator
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
	xil_printf("  0~f      - Send behavior 0~15 to CURRENT component\r\n");
	xil_printf("  .        - Enter behavior number (1-100)\r\n");
	xil_printf("  c        - Enter component-select mode \r\n");
	xil_printf("  w        - Set motion params (spd/acc/dec/target_mm/step_mm/factor)\r\n");
	xil_printf("  p        - Read position (pulse + mm) of current component\r\n");
	xil_printf("  r        - Read all registers of current component\r\n");
	xil_printf("  m        - Show this menu\r\n");
	xil_printf("  i        - Init/re-init current component\r\n");
	xil_printf("  I        - Init ALL components\r\n");
	xil_printf("  s        - Scan: read PARAM51 of all components\r\n");
	xil_printf("  q        - Exit\r\n");
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

int MenuHandleKey(char key)
{
	// mode branches first (they own the key while active)
	if (input_mode == MODE_SELECT_COMP) {
		// Accumulate digits, Enter to confirm, Esc to cancel
		if (key >= '0' && key <= '9') {
			int d = (int)(key - '0');
			if (comp_select_buf < 0)
				comp_select_buf = d;
			else
				comp_select_buf = comp_select_buf * 10 + d;
			xil_printf("%c", key);
			if (comp_select_buf > NUM_IRQ_SLOTS - 1) {
				xil_printf("\r\nInvalid index %d (max %d)\r\n",
					   comp_select_buf, NUM_IRQ_SLOTS - 1);
				comp_select_buf = -1;
				input_mode = MODE_BEHAVIOR;
			}
			// else: stay in MODE_SELECT_COMP for more digits
		} else if (key == '\r' || key == '\n') {
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
		} else if (key == 0x1B || key == 0x7F || key == 0x08) {
			// Esc / Backspace / Del -> cancel
			xil_printf("\r\nCancelled.\r\n");
			comp_select_buf = -1;
			input_mode = MODE_BEHAVIOR;
		}
		/* else: ignore other chars, stay in MODE_SELECT_COMP */
	}
	// Param config: select which parameter
	else if (input_mode == MODE_SET_PARAM) {
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
	// Param config: enter decimal value (string buffer, supports "[-]ddd[.ddd]")
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
			// backspace: drop last char
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
	// Extended behavior number (1-100): accumulate digits, Enter to run
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
	// Component select: enter selection mode
	else if (key == 'c' || key == 'C') {
		input_mode = MODE_SELECT_COMP;
		xil_printf("\r\nSelect component (0-%d): ", NUM_IRQ_SLOTS - 1);
	}
	// Set motion params
	else if (key == 'w' || key == 'W') {
		input_mode = MODE_SET_PARAM;
		PrintParamMenu();
	}
	// Extended behavior number mode
	else if (key == '.') {
		input_mode = MODE_EXT_BHV;
		ext_bhv_val = -1;
		xil_printf("\r\nEnter behavior (1-100): ");
	}
	// Behavior hex digits (0-9, a-f, A-F)
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
	// Read position of current component
	else if (key == 'p' || key == 'P') {
		IrqSlot *comp = &irq_table[cur_component];
		u32 p51 = Xil_In32(comp->base_addr + PARAM51);  // abs pulse (int)
		u32 p52 = Xil_In32(comp->base_addr + PARAM52);  // abs mm (float32)
		u32 p53 = Xil_In32(comp->base_addr + PARAM53);
		u32 link_st = Xil_In32(PL_CFG_BASE + LINK_STATUS);
		xil_printf("\r\n[%d:%s] abs_pulse=%d (0x%08x)  abs_mm=",
			   cur_component, comp->name, (int)p51, (unsigned)p51);
		PrintFp(U32ToFp(p52));
		xil_printf("  PARAM53=0x%08x\r\n", (unsigned)p53);
		u32 send_dbg = Xil_In32(PL_CFG_BASE + SEND_DBG);
		xil_printf("  LINK_STATUS=0x%08x (ch0=%d ch1=%d slv_sta=%u)\r\n",
			   (unsigned)link_st,
			   (int)((link_st >> 1) & 1U), (int)(link_st & 1U),
			   (unsigned)((link_st >> 24) & 0xFFU));
		xil_printf("  SEND_DBG=0x%08x (link=%d ack=%d wk_state=%d)\r\n",
			   (unsigned)send_dbg,
			   (int)((send_dbg >> 4) & 1U), (int)((send_dbg >> 3) & 1U),
			   (int)(send_dbg & 7U));
	}
	// Read all registers of current component
	else if (key == 'r' || key == 'R') {
		IrqSlot *comp = &irq_table[cur_component];
		xil_printf("\r\n");
		PlRegRead(comp->base_addr, comp->name);
	}
	// Re-init current component
	else if (key == 'i') {
		IrqSlot *comp = &irq_table[cur_component];
		xil_printf("\r\nRe-init [%d] %s...\r\n",
			   cur_component, comp->name);
		if (CompIsPulAxis(comp->base_addr))
			PlRegWritePulAxis(comp->base_addr);
		else
			PlRegWrite(comp->base_addr);
		PlRegRead(comp->base_addr, comp->name);
	}
	// Init ALL components
	else if (key == 'I') {
		xil_printf("\r\nRe-initializing ALL components...\r\n");
		CompInitAll();
		xil_printf("All components re-initialized.\r\n");
	}
	// Scan all components PARAM51
	else if (key == 's' || key == 'S') {
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
