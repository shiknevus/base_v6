// @file pl_bhv.h
// Behavior transaction state machine (main-loop context)

#ifndef PL_BHV_H
#define PL_BHV_H

#include "xil_types.h"
#include "pl_intc.h"

typedef enum {
	BHV_IDLE,
	BHV_WAIT_REQ,      // wrote A_BHV_ID, waiting for 0x0A interrupt
	BHV_WAIT_RESULT,   // acked 0x0A, waiting for 0x1E (ok) / 0x28 (fail)
} BhvState;

// Trigger a behavior on the given component (async, returns immediately)
void BhvStart(IrqSlot *slot, u8 id);

// Consume one queued event, advance the behavior state machine.
void ProcessEvent(const IrqEvent *ev);

// Fallback: poll INTC ISR directly and feed the same state machine.
void PollIntcFallback(void);

// Called from main loop: deadline expired
void BhvTimeout(void);

// reset stale-duplicate ack table (call once after interrupt setup)
void BhvResetAck(void);

// state query for main loop / menu
int  BhvIsRunning(void);
u8   BhvActiveId(void);
const char *BhvActiveName(void);
u32  BhvDeadline(void);

#endif /* PL_BHV_H */
