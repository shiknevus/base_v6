// @file pl_reg.h
// PL register map: ec_pul_axis

#ifndef PL_REG_H
#define PL_REG_H

#include "xparameters.h"

#define PL_CFG_BASE          XPAR_PLCFG_M_AXI_BASEADDR    // 0xB0100000

// mst app ctrl
#define MST_APP_MODE         0x030U   // [0]=trsf_port_en

#define REG_BIAS_EC_PUL_AXIS 0x1A00U

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
#define B_TX_OT              0x08CU
#define B_TX_RSULT_RPT       0x090U
#define B_BHV_ID             0x09CU
#define C_EN                 0x0ACU

// PARAM register offsets
#define PARAM1               0x0D8U
#define PARAM2               0x0DCU
#define PARAM3               0x0E0U
#define PARAM4               0x0E4U   // factor (PS side only)
#define PARAM5               0x0E8U   // acc
#define PARAM16              0x114U   // rserv_dir [0]
#define PARAM26              0x13CU   // rctrl_pause
#define PARAM27              0x140U   // rctrl_stop
#define PARAM28              0x144U   // rctrl_resume
#define PARAM29              0x148U   // rctrl_drive_reset
#define PARAM30              0x14CU   // rctrl_drive_on
#define PARAM33              0x1A8U   // touch_spd
#define PARAM34              0x1ACU   // dec
#define PARAM35              0x1B0U   // spd
#define PARAM36              0x1B4U   // target pulse
#define PARAM37              0x1B8U   // step pulse
#define PARAM51              0x150U   // abspos
#define PARAM53              0x158U

// debug
#define DEBUG_REG1           0x1ECU   // A FSM {m3,m2,m1,cur}
#define DEBUG_REG2           0x1F0U
#define DEBUG_REG3           0x1F4U
#define DEBUG_REG4           0x1F8U
#define DEBUG_REG5           0x1FCU

#endif /* PL_REG_H */
