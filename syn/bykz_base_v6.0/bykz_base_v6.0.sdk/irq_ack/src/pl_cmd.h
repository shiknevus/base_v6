// @file pl_cmd.h
// serial cmd interface

#ifndef PL_CMD_H
#define PL_CMD_H

#include "xil_types.h"

void CmdInit(void);      // motion defaults -> PL
void CmdPoll(void);      // poll uart, handle key
void PrintMenu(void);

u32 CmdFactor(void);     // pulse/mm, for irq pos report

#endif /* PL_CMD_H */
