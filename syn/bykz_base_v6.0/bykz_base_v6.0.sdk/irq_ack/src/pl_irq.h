// @file pl_irq.h
// bare-metal interrupt ack

#ifndef PL_IRQ_H
#define PL_IRQ_H

#include "xil_types.h"

// GIC + PL INTC setup, ISR answers in place
int SetupInterruptSystem(void);

// main-loop INTC poll, backup path of the ISR
void PollIrqFallback(void);

// ISR hit count (diag)
u32 IrqIsrCount(void);

#endif /* PL_IRQ_H */
