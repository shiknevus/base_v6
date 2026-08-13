// @file pl_comp.c
// reg access + motion params

#include "pl_comp.h"
#include "pl_reg.h"
#include "pl_intc.h"
#include "util.h"

#include "xil_io.h"
#include "xil_printf.h"

float param_spd       = 20.0f;        // spd mm/s
float param_acc       = 100.0f;       // acc mm/s2
float param_dec       = 100.0f;       // dec mm/s2
float param_target_mm = 500.0f;       // target mm
float param_step_mm   = 50.0f;        // step mm
u32  param_factor     = 50000U;       // pulse/mm 

// common component init
// common init
void PlRegWrite(u32 base_addr)
{
	Xil_Out32(base_addr + RST_EN,  0x00000000U);
	Xil_Out32(base_addr + RST_EN,  0x00000001U);
	Xil_Out32(base_addr + SC_ID,   0x00000066U);
	Xil_Out32(base_addr + EC_ID,   0x00000088U);
	Xil_Out32(base_addr + A_EN,    0x00000001U);
	Xil_Out32(base_addr + C_EN,    0x00000000U);
	Xil_Out32(base_addr + A_TX_OT, 30U);
}

// pul_axis init
void PlRegWritePulAxis(u32 base_addr)
{
	PlRegWrite(base_addr);  // common init first
	Xil_Out32(base_addr + B_EN,    0x00000001U);
	Xil_Out32(base_addr + B_TX_OT, 30U);

	Xil_Out32(base_addr + PARAM1,  0x00002710U); // rcfg_spd_max
	Xil_Out32(base_addr + PARAM2,  0x00002710U); // rcfg_acc_max
	Xil_Out32(base_addr + PARAM3,  0x00002710U); // rcfg_dec_max
	Xil_Out32(base_addr + PARAM5,  (u32)(param_acc * (float)param_factor / 1000.0f)); // acc
	Xil_Out32(base_addr + PARAM33, 0x00004E20U);    // touch_spd
	Xil_Out32(base_addr + PARAM34, (u32)(param_dec * (float)param_factor / 1000.0f)); // dec
	Xil_Out32(base_addr + PARAM35, (u32)(param_spd * (float)param_factor / 1000.0f)); // spd
	// mm -> pulses
	Xil_Out32(base_addr + PARAM36, (u32)(param_target_mm * (float)param_factor));
	Xil_Out32(base_addr + PARAM37, (u32)(param_step_mm   * (float)param_factor));
	// drive_on=1, dir POS
	Xil_Out32(base_addr + PARAM16, 0x00000001U);
	Xil_Out32(base_addr + PARAM26, 0x00000000U);
	Xil_Out32(base_addr + PARAM27, 0x00000000U);
	Xil_Out32(base_addr + PARAM28, 0x00000000U);
	Xil_Out32(base_addr + PARAM29, 0x00000000U);
	Xil_Out32(base_addr + PARAM30, 0x00000001U);
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
	xil_printf("  PARAM16=0x%08x (dir) P26=0x%08x (pause) P27=0x%08x (stop) P28=0x%08x (resume)\r\n",
		(unsigned)Xil_In32(base_addr + PARAM16),
		(unsigned)Xil_In32(base_addr + PARAM26),
		(unsigned)Xil_In32(base_addr + PARAM27),
		(unsigned)Xil_In32(base_addr + PARAM28));
	xil_printf("  PARAM29=0x%08x (drv_reset) PARAM30=0x%08x (drv_on)\r\n",
		(unsigned)Xil_In32(base_addr + PARAM29),
		(unsigned)Xil_In32(base_addr + PARAM30));
	u32 p51 = Xil_In32(base_addr + PARAM51);
	xil_printf("  PARAM51=0x%08x (abs pulse = ", (unsigned)p51);
	PrintFp(PulseToMm(p51));
	xil_printf(" mm) PARAM53=0x%08x\r\n",
		(unsigned)Xil_In32(base_addr + PARAM53));
	xil_printf("  DEBUG1=0x%08x (A fsm) 2=0x%08x 3=0x%08x 4=0x%08x 5=0x%08x\r\n",
		(unsigned)Xil_In32(base_addr + DEBUG_REG1),
		(unsigned)Xil_In32(base_addr + DEBUG_REG2),
		(unsigned)Xil_In32(base_addr + DEBUG_REG3),
		(unsigned)Xil_In32(base_addr + DEBUG_REG4),
		(unsigned)Xil_In32(base_addr + DEBUG_REG5));
	xil_printf("  B_BHV_ID=0x%08x B_TX_OT=0x%08x\r\n",
		(unsigned)Xil_In32(base_addr + B_BHV_ID),
		(unsigned)Xil_In32(base_addr + B_TX_OT));
}

// pulse -> mm
float PulseToMm(u32 pulse)
{
	return (float)(int)pulse / (float)param_factor;
}

void CompInitAll(void)
{
	for (int i = 0; i < NUM_IRQ_SLOTS; i++) {
		PlRegWritePulAxis(irq_table[i].base_addr);
		xil_printf("  [%d] pul_axis init @0x%08x\r\n",
			   i, (unsigned)irq_table[i].base_addr);
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

// write param
void ParamWriteCur(int sel, const char *str)
{
	IrqSlot *comp = &irq_table[cur_component];
	u32 off;
	switch (sel) {
		case 1: param_spd = ParseFloat(str); off = PARAM35; break;
		case 2: param_acc = ParseFloat(str); off = PARAM5;  break;
		case 3: param_dec = ParseFloat(str); off = PARAM34; break;
		case 4: param_target_mm = ParseFloat(str); off = PARAM36; break;
		case 5: param_step_mm   = ParseFloat(str); off = PARAM37; break;
		case 6: param_factor = ParseUint(str); off = PARAM4;  break;
		default: return;
	}
	if (sel >= 1 && sel <= 5) {
		// mm -> pulses / kpps
		float vf = (sel == 1) ? param_spd : (sel == 2) ? param_acc :
			   (sel == 3) ? param_dec : (sel == 4) ? param_target_mm : param_step_mm;
		u32 v = (sel == 4 || sel == 5)
			? (u32)(vf * (float)param_factor)
			: (u32)(vf * (float)param_factor / 1000.0f);
		Xil_Out32(comp->base_addr + off, v);
		xil_printf("  [%d:%s] PARAM%u(%-9s) <= ", cur_component, comp->name,
			   (unsigned)(sel == 1 ? 35 : sel == 2 ? 5 : sel == 3 ? 34 : sel == 4 ? 36 : 37),
			   ParamName(sel));
		PrintFp(vf);
		xil_printf(" -> %u\r\n", (unsigned)v);
	} else {
		u32 v = param_factor;
		Xil_Out32(comp->base_addr + off, v);
		xil_printf("  [%d:%s] PARAM4(%-9s) <= %u (0x%08x) pulse/mm\r\n",
			   cur_component, comp->name, ParamName(sel), (unsigned)v, (unsigned)v);
	}
}

void PrintParamMenu(void)
{
	IrqSlot *comp = &irq_table[cur_component];
	xil_printf("\r\n--- Set Param on [%d] %s ---\r\n", cur_component, comp->name);
	xil_printf("  1: spd    (PARAM35) = ");
	PrintFp(param_spd);
	xil_printf(" mm/s = %u kpps\r\n", (unsigned)(param_spd * (float)param_factor / 1000.0f));
	xil_printf("  2: acc    (PARAM5)  = ");
	PrintFp(param_acc);
	xil_printf(" mm/s2 = %u kpps/s\r\n", (unsigned)(param_acc * (float)param_factor / 1000.0f));
	xil_printf("  3: dec    (PARAM34) = ");
	PrintFp(param_dec);
	xil_printf(" mm/s2 = %u kpps/s\r\n", (unsigned)(param_dec * (float)param_factor / 1000.0f));
	xil_printf("  4: target (PARAM36) = ");
	PrintFp(param_target_mm);
	xil_printf(" mm = %u pulse\r\n", (unsigned)(param_target_mm * (float)param_factor));
	xil_printf("  5: step   (PARAM37) = ");
	PrintFp(param_step_mm);
	xil_printf(" mm = %u pulse\r\n", (unsigned)(param_step_mm * (float)param_factor));
	xil_printf("  6: factor (PARAM4)  = %u (0x%08x) pulse/mm\r\n", (unsigned)param_factor, (unsigned)param_factor);
	xil_printf("  Esc / q: cancel\r\n");
	xil_printf("Select param (1~6): ");
}
