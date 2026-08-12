// @file pl_comp.c
// Component register access + motion params (main-loop context)

#include "pl_comp.h"
#include "pl_reg.h"
#include "pl_intc.h"
#include "util.h"

#include "xil_io.h"
#include "xil_printf.h"

u32  param_spd         = 0x00000064U; // PARAM35: home/jog/move_spd (kpps)
u32  param_acc         = 0x00000064U; // PARAM5:  home/jog/move_acc
u32  param_dec         = 0x00000064U; // PARAM34: home/jog/move_dec
float param_target_mm  = 500.0f;      // PARAM36: move target (mm, float32)
float param_step_mm    = 50.0f;       // PARAM37: jog step (mm, float32)
u32  param_factor      = 1000U;       // PARAM4:  conversion_factor (pulse/mm)

// common component init
void PlRegWrite(u32 base_addr)
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
void PlRegWritePulAxis(u32 base_addr)
{
	PlRegWrite(base_addr);  // common init first

	Xil_Out32(base_addr + PARAM1,  0x00002710U); // rcfg_spd_max
	Xil_Out32(base_addr + PARAM2,  0x00002710U); // rcfg_acc_max
	Xil_Out32(base_addr + PARAM3,  0x00002710U); // rcfg_dec_max
	Xil_Out32(base_addr + PARAM4,  param_factor);   // rcfg_conversion_factor (pulse/mm)
	Xil_Out32(base_addr + PARAM5,  param_acc);      // home/jog/move_acc
	Xil_Out32(base_addr + PARAM33, 0x00004E20U);    // rcfg_qs_dec
	Xil_Out32(base_addr + PARAM34, param_dec);      // home/jog/move_dec
	Xil_Out32(base_addr + PARAM35, param_spd);      // home/jog/move_spd (kpps)
	Xil_Out32(base_addr + PARAM36, FpToU32(param_target_mm)); // move target (mm, float32)
	Xil_Out32(base_addr + PARAM37, FpToU32(param_step_mm));   // jog step (mm, float32)
	// control regs: all inactive, drive_on = 1
	Xil_Out32(base_addr + PARAM16, 0x00000000U);    // rctrl_stop
	Xil_Out32(base_addr + PARAM26, 0x00000000U);    // rctrl_pause
	Xil_Out32(base_addr + PARAM28, 0x00000000U);    // rctrl_resume
	Xil_Out32(base_addr + PARAM29, 0x00000000U);    // rctrl_drive_reset
	Xil_Out32(base_addr + PARAM30, 0x00000001U);    // rctrl_drive_on
}

void PlRegRead(u32 base_addr, const char *name)
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
	xil_printf("  PARAM4 =0x%08x (factor p/mm) PARAM5 =0x%08x (acc) PARAM33=0x%08x (qs_dec)\r\n",
		(unsigned)Xil_In32(base_addr + PARAM4),
		(unsigned)Xil_In32(base_addr + PARAM5),
		(unsigned)Xil_In32(base_addr + PARAM33));
	xil_printf("  PARAM34=0x%08x (dec) PARAM35=0x%08x (spd kpps)\r\n",
		(unsigned)Xil_In32(base_addr + PARAM34),
		(unsigned)Xil_In32(base_addr + PARAM35));
	xil_printf("  PARAM36=0x%08x target_mm=",
		(unsigned)Xil_In32(base_addr + PARAM36));
	PrintFp(U32ToFp(Xil_In32(base_addr + PARAM36)));
	xil_printf("  PARAM37=0x%08x step_mm=",
		(unsigned)Xil_In32(base_addr + PARAM37));
	PrintFp(U32ToFp(Xil_In32(base_addr + PARAM37)));
	xil_printf("\r\n");
	xil_printf("  PARAM16=0x%08x (stop) PARAM26=0x%08x (pause) PARAM28=0x%08x (resume)\r\n",
		(unsigned)Xil_In32(base_addr + PARAM16),
		(unsigned)Xil_In32(base_addr + PARAM26),
		(unsigned)Xil_In32(base_addr + PARAM28));
	xil_printf("  PARAM29=0x%08x (drv_reset) PARAM30=0x%08x (drv_on)\r\n",
		(unsigned)Xil_In32(base_addr + PARAM29),
		(unsigned)Xil_In32(base_addr + PARAM30));
	xil_printf("  PARAM51=0x%08x (abs pulse) PARAM52=0x%08x (abs mm) PARAM53=0x%08x\r\n",
		(unsigned)Xil_In32(base_addr + PARAM51),
		(unsigned)Xil_In32(base_addr + PARAM52),
		(unsigned)Xil_In32(base_addr + PARAM53));
}

int CompIsPulAxis(u32 base_addr)
{
	return (base_addr == (PL_CFG_BASE + REG_BIAS_EC_PUL_AXIS) ||
		base_addr == (PL_CFG_BASE + REG_BIAS_EC_SLV_PUL_AXIS));
}

void CompInitAll(void)
{
	for (int i = 0; i < NUM_IRQ_SLOTS; i++) {
		if (CompIsPulAxis(irq_table[i].base_addr)) {
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
}

const char* ParamName(int sel)
{
	switch (sel) {
		case 1: return "spd    ";
		case 2: return "acc    ";
		case 3: return "dec    ";
		case 4: return "target ";
		case 5: return "step   ";
		case 6: return "factor ";
		default: return "?      ";
	}
}

// Write one param (value as decimal string) to current component's register
void ParamWriteCur(int sel, const char *str)
{
	IrqSlot *comp = &irq_table[cur_component];
	u32 off;
	switch (sel) {
		case 1: param_spd   = ParseUint(str); off = PARAM35; break;
		case 2: param_acc   = ParseUint(str); off = PARAM5;  break;
		case 3: param_dec   = ParseUint(str); off = PARAM34; break;
		case 4: param_target_mm = ParseFloat(str); off = PARAM36; break;
		case 5: param_step_mm   = ParseFloat(str); off = PARAM37; break;
		case 6: param_factor = ParseUint(str); off = PARAM4;  break;
		default: return;
	}
	if (sel == 4 || sel == 5) {
		Xil_Out32(comp->base_addr + off, FpToU32((sel == 4) ? param_target_mm : param_step_mm));
		xil_printf("  [%d:%s] PARAM%u(%-9s) <= ", cur_component, comp->name,
			   (unsigned)(sel == 4 ? 36 : 37), ParamName(sel));
		PrintFp((sel == 4) ? param_target_mm : param_step_mm);
		xil_printf(" mm\r\n");
	} else {
		u32 v = (sel == 1) ? param_spd : (sel == 2) ? param_acc :
			(sel == 3) ? param_dec : param_factor;
		Xil_Out32(comp->base_addr + off, v);
		xil_printf("  [%d:%s] PARAM%u(%-9s) <= %u (0x%08x)%s\r\n",
			   cur_component, comp->name,
			   (unsigned)(sel == 1 ? 35 : sel == 2 ? 5 : sel == 3 ? 34 : 4),
			   ParamName(sel), (unsigned)v, (unsigned)v,
			   (sel == 1) ? " kpps" : (sel == 6) ? " pulse/mm" : "");
	}
}

void PrintParamMenu(void)
{
	IrqSlot *comp = &irq_table[cur_component];
	xil_printf("\r\n--- Set Param on [%d] %s ---\r\n", cur_component, comp->name);
	xil_printf("  1: spd    (PARAM35) = %u (0x%08x) kpps\r\n", (unsigned)param_spd, (unsigned)param_spd);
	xil_printf("  2: acc    (PARAM5)  = %u (0x%08x)\r\n", (unsigned)param_acc, (unsigned)param_acc);
	xil_printf("  3: dec    (PARAM34) = %u (0x%08x)\r\n", (unsigned)param_dec, (unsigned)param_dec);
	xil_printf("  4: target (PARAM36) = ");
	PrintFp(param_target_mm);
	xil_printf(" mm (float32)\r\n");
	xil_printf("  5: step   (PARAM37) = ");
	PrintFp(param_step_mm);
	xil_printf(" mm (float32)\r\n");
	xil_printf("  6: factor (PARAM4)  = %u (0x%08x) pulse/mm\r\n", (unsigned)param_factor, (unsigned)param_factor);
	xil_printf("  Esc / q: cancel\r\n");
	xil_printf("Select param (1~6): ");
}
