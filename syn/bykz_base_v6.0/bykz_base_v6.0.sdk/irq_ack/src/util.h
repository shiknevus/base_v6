// @file util.h
// time + float32

#ifndef UTIL_H
#define UTIL_H

#include "xil_types.h"

// ms since boot
u32  ts_ms(void);

// float32 <-> u32
u32  FpToU32(float f);
float U32ToFp(u32 u);

// parse float
float ParseFloat(const char *s);
u32  ParseUint(const char *s);

// print float
void PrintFp(float f);

#endif /* UTIL_H */
