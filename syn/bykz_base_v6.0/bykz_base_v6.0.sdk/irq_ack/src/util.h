// @file util.h
// Time stamp + float32 helpers (xil_printf has no %f support)

#ifndef UTIL_H
#define UTIL_H

#include "xil_types.h"

// milliseconds since boot (ARM generic timer, Cortex-A53)
u32  ts_ms(void);

// float32 <-> u32 bit-pattern
u32  FpToU32(float f);
float U32ToFp(u32 u);

// parse "[-]ddd[.ddd]" to float, no libc dependency
float ParseFloat(const char *s);
u32  ParseUint(const char *s);

// print float with 3 decimals
void PrintFp(float f);

#endif /* UTIL_H */
