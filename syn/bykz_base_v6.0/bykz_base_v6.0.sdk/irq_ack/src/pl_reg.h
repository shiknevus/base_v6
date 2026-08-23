// @file pl_reg.h
// PL register map: mirror of rtl/include_files/reg_addr_pl.vh, keep in sync

#ifndef PL_REG_H
#define PL_REG_H

#include "xparameters.h"

#define PL_CFG_BASE          XPAR_PLCFG_M_AXI_BASEADDR    // 0xB0100000

// component space bias, same as emcc_mix_top instantiation
#define REG_BIAS_EC_1DO      0x800U   // ec_1do_u0 (mst DO)
#define REG_BIAS_EC_1DO_SLV  0xC00U   // ec_1do_u1 (slave DO)
#define REG_BIAS_EC_PUL_AXIS     0xA00U   // ec_pul_axis_u0
#define REG_BIAS_EC_SLV_PUL_AXIS 0xE00U   // ec_slv_pul_axis_u0
#define REG_BIAS_EC_CAN_SERVO    0x3000U // ec_can_servo_11

// mst_app registers (rtl/include_files/components_param.vh)
#define MST_APP_BASE         PL_CFG_BASE                   // MST_APP_REG_BIAS=0
#define LINK_STATUS          0x050U
#define OPT_INTF_INIT_EN     0x080U
#define MST_APP_MODE         0x030U
#define SLV_STA_NUM          0x020U

// common register offsets
#define IRQ_REG1             0x000U   // {ec_id,sc_id,bhv_id,tx_id}
#define IRQ_REG2             0x004U   // {alm_num,24'd0}
#define RST_EN               0x008U
#define EC_ID                0x00CU
#define SC_ID                0x010U
#define BHV_PRIORITY         0x014U
#define UNIT_ID              0x018U
#define UNIT_ECTRL           0x01CU
#define UNIT_ST              0x020U
#define M_ID                 0x024U
#define M_ECTRL              0x028U
#define M_ST                 0x02CU
#define M_WK_MOD             0x030U
#define BHV_EN               0x034U
#define M_SAF_ST             0x038U
#define LINK_M_SAF_ST        0x03CU

// A ch (proactive)
#define A_TASK_ID            0x054U
#define A_TASK_BHV_ID        0x058U
#define A_EN                 0x05CU
#define EC_CHA_ST            0x060U
#define A_TX_OT              0x064U
#define A_TX_RSULT_RPT       0x068U
#define A_ALM_NUM            0x06CU
#define A_TX_ID              0x070U
#define A_BHV_ID             0x074U

// B ch (status)
#define B_EN                 0x084U
#define EC_CHB_ST            0x088U
#define B_TX_OT              0x08CU
#define B_TX_RSULT_RPT       0x090U
#define B_ALM_NUM            0x094U
#define B_TX_ID              0x098U
#define B_BHV_ID             0x09CU

// C ch (timing)
#define C_EN                 0x0ACU
#define EC_CHC_ST            0x0B0U
#define C_TX_OT              0x0B4U
#define C_TX_RSULT_RPT       0x0B8U
#define C_ALM_NUM            0x0BCU
#define C_TX_ID              0x0C0U
#define C_BHV_ID             0x0C4U
#define C_GAP_CRL            0x0C8U

// PARAM1-15
#define PARAM1               0x0D8U
#define PARAM2               0x0DCU
#define PARAM3               0x0E0U
#define PARAM4               0x0E4U
#define PARAM5               0x0E8U
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

// PARAM16-30
#define PARAM16              0x114U
#define PARAM17              0x118U
#define PARAM18              0x11CU
#define PARAM19              0x120U
#define PARAM20              0x124U
#define PARAM21              0x128U
#define PARAM22              0x12CU
#define PARAM23              0x130U
#define PARAM24              0x134U
#define PARAM25              0x138U
#define PARAM26              0x13CU
#define PARAM27              0x140U
#define PARAM28              0x144U
#define PARAM29              0x148U
#define PARAM30              0x14CU

// PARAM31-40 (PS write; pul_axis: 33 touch spd, 34 dec, 35 spd, 36 target, 37 step)
#define PARAM31              0x150U
#define PARAM32              0x154U
#define PARAM33              0x158U
#define PARAM34              0x15CU
#define PARAM35              0x160U
#define PARAM36              0x164U
#define PARAM37              0x168U
#define PARAM38              0x16CU
#define PARAM39              0x170U
#define PARAM40              0x174U

// PARAM51-70 (PL read; pul_axis pos fb @51, 1do do st @66)
#define PARAM51              0x178U
#define PARAM52              0x17CU
#define PARAM53              0x180U
#define PARAM54              0x184U
#define PARAM55              0x188U
#define PARAM56              0x18CU
#define PARAM57              0x190U
#define PARAM58              0x194U
#define PARAM59              0x198U
#define PARAM60              0x19CU
#define PARAM61              0x1A0U
#define PARAM62              0x1A4U
#define PARAM63              0x1A8U
#define PARAM64              0x1ACU
#define PARAM65              0x1B0U
#define PARAM66              0x1B4U
#define PARAM67              0x1B8U
#define PARAM68              0x1BCU
#define PARAM69              0x1C0U
#define PARAM70              0x1C4U

// debug
#define DEBUG_REG1           0x1ECU
#define DEBUG_REG2           0x1F0U
#define DEBUG_REG3           0x1F4U
#define DEBUG_REG4           0x1F8U
#define DEBUG_REG5           0x1FCU

#endif /* PL_REG_H */