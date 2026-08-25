/*
 * reg_write32.c
 *
 *  Created on: 2026Äê8ÔÂ24ÈÕ
 *      Author: cgliu
 */
#include <stdio.h>
#include <stdint.h>
#include <stddef.h>   // for uintptr_t
#include "platform.h"
#include "xil_printf.h"

void reg_write32(uintptr_t reg_phy_addr, uint32_t val)
{
    volatile uint32_t *reg_addr = (volatile uint32_t *)reg_phy_addr;
    *reg_addr = val;
}

