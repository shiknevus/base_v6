// @file pl_intc.h
// 16-INTC + ISR queue

#ifndef PL_INTC_H
#define PL_INTC_H

#include "xil_types.h"

// INTC desc
typedef struct {
	u32 dev_id;
	u32 baseaddr;
	u32 gic_spi;
} IntcDesc;

#define NUM_INTC 16

#define INTC_ISR 0x00U
#define INTC_IER 0x08U
#define INTC_IAR 0x0CU

// irq slot
typedef struct {
	const char *name;
	int   intc_idx;
	u32   intc_bit;
	u32   base_addr;
} IrqSlot;

#define NUM_IRQ_SLOTS 1

// event
typedef struct {
	IrqSlot *slot;
	u32      irq_reg1;
	u32      irq_reg2;
	u32      tick;
} IrqEvent;

extern const IntcDesc intc_desc[NUM_INTC];
extern IrqSlot irq_table[NUM_IRQ_SLOTS];
extern int  cur_component;

// setup
int  SetupInterruptSystem(void);

// main side
int  EvPop(IrqEvent *ev);

// diag
u32  IntcIsrCount(void);
u32  EvDropCountGet(void);
void EvDropCountClear(void);

#endif /* PL_INTC_H */
