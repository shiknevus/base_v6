// @file pl_intc.h
// Interrupt infrastructure: 16-INTC dispatch, component table, ISR event queue

#ifndef PL_INTC_H
#define PL_INTC_H

#include "xil_types.h"

// INTC instance descriptor (16-INTC dispatch architecture)
typedef struct {
	u32 dev_id;
	u32 baseaddr;
	u32 gic_spi;
} IntcDesc;

#define NUM_INTC 16

#define INTC_ISR 0x00U
#define INTC_IER 0x08U
#define INTC_IAR 0x0CU

// Interrupt routing slot
typedef struct {
	const char *name;
	int   intc_idx;
	u32   intc_bit;
	u32   base_addr;
} IrqSlot;

#define NUM_IRQ_SLOTS 11

// Event queue entry (ISR -> main loop)
typedef struct {
	IrqSlot *slot;
	u32      irq_reg1;
	u32      irq_reg2;
	u32      tick;
} IrqEvent;

extern const IntcDesc intc_desc[NUM_INTC];
extern IrqSlot irq_table[NUM_IRQ_SLOTS];
extern int  cur_component;          // currently selected component index

// Setup GIC + INTC#0, per-bit ISR dispatch, enable exceptions
int  SetupInterruptSystem(void);

// main-loop side of the event queue
int  EvPop(IrqEvent *ev);

// diagnostics
u32  IntcIsrCount(void);    // how many times the ISR ran
u32  EvDropCountGet(void);
void EvDropCountClear(void);

#endif /* PL_INTC_H */
