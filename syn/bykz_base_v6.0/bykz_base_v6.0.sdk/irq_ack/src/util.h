// @file util.h
// time + float parse/print

#ifndef UTIL_H
#define UTIL_H

#include "xil_types.h"

u32   ts_ms(void);
float ParseFloat(const char *s);
u32   ParseUint(const char *s);
void  PrintFp(float f);

#endif /* UTIL_H */
