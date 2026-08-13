// @file pl_bhv.h
// A-channel FSM

#ifndef PL_BHV_H
#define PL_BHV_H

#include "xil_types.h"
#include "pl_intc.h"

typedef enum {
	BHV_IDLE,
	BHV_WAIT_REQ,      // wait 0x0A
	BHV_WAIT_RESULT,   // wait 0x1E/0x28
} BhvState;

// trigger
void BhvStart(IrqSlot *slot, u8 id);

// event -> FSM
void ProcessEvent(const IrqEvent *ev);

// poll fallback
void PollIntcFallback(void);

// deadline
void BhvTimeout(void);

// reset ack
void BhvResetAck(void);

// state query
int  BhvIsRunning(void);
u8   BhvActiveId(void);
const char *BhvActiveName(void);
u32  BhvDeadline(void);

#endif /* PL_BHV_H */
