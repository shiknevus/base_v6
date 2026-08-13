// @file pl_comp.h
// reg access + params

#ifndef PL_COMP_H
#define PL_COMP_H

#include "xil_types.h"

// params
extern float param_spd;        // spd mm/s
extern float param_acc;        // acc mm/s2
extern float param_dec;        // dec mm/s2
extern float param_target_mm;  // target mm
extern float param_step_mm;    // step mm
extern u32  param_factor;      // pulse/mm

// common init
void PlRegWrite(u32 base_addr);
// pul_axis init
void PlRegWritePulAxis(u32 base_addr);
// dump regs
void PlRegRead(u32 base_addr, const char *name);
// init all
void CompInitAll(void);

// pulse -> mm
float PulseToMm(u32 pulse);

// param menu
const char *ParamName(int sel);
void ParamWriteCur(int sel, const char *str);
void PrintParamMenu(void);

#endif /* PL_COMP_H */
