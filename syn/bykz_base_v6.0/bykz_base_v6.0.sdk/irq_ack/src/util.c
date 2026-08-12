// @file util.c
// Time stamp + float32 helpers (xil_printf has no %f support)

#include "util.h"
#include "xil_printf.h"

// ARM generic timer helpers (Cortex-A53)
static inline u64 get_cntpct(void) {
	u64 cnt;
	__asm__ volatile("mrs %0, cntpct_el0" : "=r"(cnt));
	return cnt;
}
static inline u32 get_cntfrq(void) {
	u32 freq;
	__asm__ volatile("mrs %0, cntfrq_el0" : "=r"(freq));
	return freq;
}

u32 ts_ms(void) {
	static u32 freq;
	if (!freq) freq = get_cntfrq();
	return (u32)(get_cntpct() / (freq / 1000));
}

u32 FpToU32(float f)
{
	union { float f; u32 u; } c;
	c.f = f;
	return c.u;
}

float U32ToFp(u32 u)
{
	union { float f; u32 u; } c;
	c.u = u;
	return c.f;
}

// parse "[-]ddd[.ddd]" to float, no libc dependency
float ParseFloat(const char *s)
{
	float val = 0.0f, frac = 0.1f;
	int neg = 0, i = 0;
	if (s[0] == '-') { neg = 1; i = 1; }
	for (; s[i] >= '0' && s[i] <= '9'; i++)
		val = val * 10.0f + (float)(s[i] - '0');
	if (s[i] == '.') {
		i++;
		for (; s[i] >= '0' && s[i] <= '9'; i++) {
			val += frac * (float)(s[i] - '0');
			frac *= 0.1f;
		}
	}
	return neg ? -val : val;
}

u32 ParseUint(const char *s)
{
	u32 v = 0;
	int i = 0;
	for (; s[i] >= '0' && s[i] <= '9'; i++)
		v = v * 10U + (u32)(s[i] - '0');
	return v;
}

// print float with 3 decimals
void PrintFp(float f)
{
	u32 ip, fp;
	int neg = (f < 0.0f);
	if (neg) f = -f;
	ip = (u32)f;
	fp = (u32)((f - (float)ip) * 1000.0f + 0.5f);
	if (fp >= 1000U) { fp -= 1000U; ip++; }
	if (neg) xil_printf("-");
	xil_printf("%u.%03u", (unsigned)ip, (unsigned)fp);
}
