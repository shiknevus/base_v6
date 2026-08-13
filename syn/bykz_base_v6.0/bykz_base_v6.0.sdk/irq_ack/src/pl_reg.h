// @file pl_reg.h
// PL register address map: emcc_mix_top window + component offset bases

#ifndef PL_REG_H
#define PL_REG_H

#include "xparameters.h"

#define PL_CFG_BASE          XPAR_PLCFG_M_AXI_BASEADDR    // 0xB0100000

// mst app control register (inside PL_CFG_BASE window)
#define MST_APP_MODE         0x030U   // [0]=trsf_port_en; bit16=0 normal, bit31=0 no loopback

// Component register offset base address
#define REG_BIAS_EC_1DI         0x0800U
#define REG_BIAS_EC_1DO         0x0A00U
#define REG_BIAS_EC_2DI_2DO     0x0C00U
#define REG_BIAS_EC_3DI_2DO     0x0E00U
#define REG_BIAS_EC_3DI_1DO     0x1000U
#define REG_BIAS_EC_1DI_1DO     0x1200U
#define REG_BIAS_EC_4DI_2DO     0x1400U
#define REG_BIAS_EC_3LED        0x1600U
#define REG_BIAS_EC_5DI         0x1800U
#define REG_BIAS_EC_PUL_AXIS    0x1A00U
#define REG_BIAS_EC_SLV_PUL_AXIS 0x1C00U

// Common register offsets
#define IRQ_REG1             0x000U
#define IRQ_REG2             0x004U
#define RST_EN               0x008U
#define EC_ID                0x00CU
#define SC_ID                0x010U
#define BHV_PRIORITY         0x014U
#define A_EN                 0x05CU
#define A_TX_OT              0x064U
#define A_TX_RSULT_RPT       0x068U
#define A_BHV_ID             0x074U
#define B_EN                 0x084U
#define C_EN                 0x0ACU

// PARAM register offsets (ec_pul_axis)
#define PARAM1               0x0D8U
#define PARAM2               0x0DCU
#define PARAM3               0x0E0U
#define PARAM4               0x0E4U   // rcfg_conversion_factor (pulse/mm)
#define PARAM5               0x0E8U   // home/jog/move_acc
#define PARAM6               0x0ECU
#define PARAM7               0x0F0U
#define PARAM8               0x0F4U
#define PARAM9               0x0F8U
#define PARAM10              0x0FCU
#define PARAM11              0x100U
#define PARAM12              0x104U
#define PARAM13              0x108U
#define PARAM14              0x10CU
#define PARAM15              0x110U
#define PARAM16              0x114U   // rserv_dir (jog dir) [0]
#define PARAM17              0x118U
#define PARAM18              0x11CU
#define PARAM19              0x120U
#define PARAM20              0x124U
#define PARAM21              0x128U
#define PARAM22              0x12CU
#define PARAM23              0x130U
#define PARAM24              0x134U
#define PARAM25              0x138U
#define PARAM26              0x13CU   // rctrl_pause
#define PARAM27              0x140U   // rctrl_stop
#define PARAM28              0x144U   // rctrl_resume
#define PARAM29              0x148U   // rctrl_drive_reset
#define PARAM30              0x14CU   // rctrl_drive_on
#define PARAM33              0x1A8U   // rcfg_touch_spd
#define PARAM34              0x1ACU   // home/jog/move_dec
#define PARAM35              0x1B0U   // home/jog/move_spd (kpps)
#define PARAM36              0x1B4U   // rserv_target_pulse (mm, float32)
#define PARAM37              0x1B8U   // rserv_step_pulse (mm, float32)
#define PARAM51              0x150U   // r_pf_abspos (int pulses)
#define PARAM52              0x154U   // o_abspos_mm (float32)
#define PARAM53              0x158U

#endif /* PL_REG_H */
