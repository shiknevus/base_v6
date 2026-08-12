// @file pl_comp.h
// Component register access + motion params (main-loop context)

#ifndef PL_COMP_H
#define PL_COMP_H

#include "xil_types.h"

// motion params (PS-side mirrors of PL registers)
extern u32  param_spd;         // PARAM35: home/jog/move_spd (kpps)
extern u32  param_acc;         // PARAM5:  home/jog/move_acc
extern u32  param_dec;         // PARAM34: home/jog/move_dec
extern float param_target_mm;  // PARAM36: move target (mm, float32)
extern float param_step_mm;    // PARAM37: jog step (mm, float32)
extern u32  param_factor;      // PARAM4:  conversion_factor (pulse/mm)

// common component init
void PlRegWrite(u32 base_addr);
// ec_pul_axis / ec_slv_pul_axis specific init
void PlRegWritePulAxis(u32 base_addr);
// dump registers (with mm decode for float32 params)
void PlRegRead(u32 base_addr, const char *name);
// init all registered components (pul_axis variants get PlRegWritePulAxis)
void CompInitAll(void);
// true if base_addr is a pul_axis variant
int  CompIsPulAxis(u32 base_addr);

// param menu support
const char *ParamName(int sel);
void ParamWriteCur(int sel, const char *str);
void PrintParamMenu(void);

#endif /* PL_COMP_H */
