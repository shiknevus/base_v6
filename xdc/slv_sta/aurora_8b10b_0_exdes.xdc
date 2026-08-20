#xc7a75tfgg484-2
################################################################################
##
## (c) Copyright 2010-2014 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
##
################################################################################
## XDC generated for xczu5eg-sfvc784-2 device
# 125.0MHz GT Reference clock constraint
#create_clock -period 8.000 -name GT_REFCLK1 [get_ports GT_REFCLK_P]
# Reference clock location
set_property PACKAGE_PIN F6 [get_ports GT_REFCLK_P]
set_property PACKAGE_PIN E6 [get_ports GT_REFCLK_N]
####################### GT reference clock LOC #######################


## 12.8 ns period Board Clock Constraint
#create_clock -name init_clk_i -period 12.8 [get_ports INIT_CLK_P]


###### CDC in RESET_LOGIC from INIT_CLK to USER_CLK ##############
set_false_path -to [get_pins -filter REF_PIN_NAME=~*D -of_objects [get_cells -hierarchical -filter {NAME =~ *aurora_8b10b_0_cdc_to*}]]
# False path constraints for Ultrascale Clocking Module (BUFG_GT)
# ----------------------------------------------------------------------------------------------------------------------
##set_false_path -to [get_cells -hierarchical -filter {NAME =~ *clock_module_i/*PLL_NOT_LOCKED*}]
####set_false_path -through [get_pins -filter {REF_PIN_NAME=~*CLR} -of_objects [get_cells -hierarchical -filter {NAME =~ *clock_module_i/*user_clk_buf_i*}]]

##################### Locatoin constrain #########################
##Note: User should add LOC based upon the board
#       Below LOC's are place holders and need to be changed as per the device and board
set_property PACKAGE_PIN C18 [get_ports INIT_CLK]
set_property PACKAGE_PIN A15 [get_ports sfp0_disable]
set_property PACKAGE_PIN A20 [get_ports sfp1_disable]
set_property PACKAGE_PIN P16 [get_ports iic_rtl_0_scl_io]
set_property PACKAGE_PIN R17 [get_ports iic_rtl_0_sda_io]
##Note: User should add IOSTANDARD based upon the board
#       Below IOSTANDARD's are place holders and need to be changed as per the device and board
set_property IOSTANDARD LVCMOS33 [get_ports INIT_CLK]
set_property IOSTANDARD LVCMOS33 [get_ports sfp0_disable]
set_property IOSTANDARD LVCMOS33 [get_ports sfp1_disable]
set_property IOSTANDARD LVCMOS33 [get_ports iic_rtl_0_scl_io]
set_property IOSTANDARD LVCMOS33 [get_ports iic_rtl_0_sda_io]
##################################################################
#set_property LOC GTPE2_CHANNEL_X0Y4 [get_cells aurora_module_i/inst/aurora_8b10b_0_core_i/gt_wrapper_i/aurora_8b10b_0_multi_gt_i/gt0_aurora_8b10b_0_i/gtpe2_i]
set_property LOC GTPE2_CHANNEL_X0Y4 [get_cells aurora_8b10b_top_u/aurora_8b10b_0_exdes_u/aurora_module_i/inst/aurora_8b10b_0_core_i/gt_wrapper_i/aurora_8b10b_0_multi_gt_i/gt0_aurora_8b10b_0_i/gtpe2_i]
set_property LOC GTPE2_CHANNEL_X0Y5 [get_cells aurora_8b10b_top_u/aurora_8b10b_1_exdes_u/aurora_8b10b_1_i/inst/gt_wrapper_i/aurora_8b10b_1_multi_gt_i/gt0_aurora_8b10b_1_i/gtpe2_i]

#set_false_path -to [get_clocks -of_objects [get_pins sys_signal_gen_u/SLAVE.aurora_mmcm_u/inst/mmcm_adv_inst/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins sys_signal_gen_u/SLAVE.aurora_mmcm_u/inst/mmcm_adv_inst/CLKOUT0]]

#set_property MARK_DEBUG true [get_nets {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_type[*]}]
#set_property MARK_DEBUG true [get_nets {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[*]}]
#set_property MARK_DEBUG true [get_nets {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/wk_state[*]}]
#set_property MARK_DEBUG true [get_nets {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/wk_state_d1[*]}]





#set_property MARK_DEBUG true [get_nets app_protocal_top_u/app_ctrl_top_u/reset]


#connect_debug_port u_ila_0/probe22 [get_nets [list ping_pong_flag]]






#connect_debug_port u_ila_0/probe0 [get_nets [list {cfg_sta_addr[0]} {cfg_sta_addr[1]} {cfg_sta_addr[2]} {cfg_sta_addr[3]} {cfg_sta_addr[4]} {cfg_sta_addr[5]} {cfg_sta_addr[6]} {cfg_sta_addr[7]}]]








#connect_debug_port u_ila_0/probe0 [get_nets [list {id_u/out_addr0_data_tst[0]} {id_u/out_addr0_data_tst[1]} {id_u/out_addr0_data_tst[2]} {id_u/out_addr0_data_tst[3]} {id_u/out_addr0_data_tst[4]} {id_u/out_addr0_data_tst[5]} {id_u/out_addr0_data_tst[6]} {id_u/out_addr0_data_tst[7]} {id_u/out_addr0_data_tst[8]} {id_u/out_addr0_data_tst[9]} {id_u/out_addr0_data_tst[10]} {id_u/out_addr0_data_tst[11]} {id_u/out_addr0_data_tst[12]} {id_u/out_addr0_data_tst[13]} {id_u/out_addr0_data_tst[14]} {id_u/out_addr0_data_tst[15]} {id_u/out_addr0_data_tst[16]} {id_u/out_addr0_data_tst[17]} {id_u/out_addr0_data_tst[18]} {id_u/out_addr0_data_tst[19]} {id_u/out_addr0_data_tst[20]} {id_u/out_addr0_data_tst[21]} {id_u/out_addr0_data_tst[22]} {id_u/out_addr0_data_tst[23]} {id_u/out_addr0_data_tst[24]} {id_u/out_addr0_data_tst[25]} {id_u/out_addr0_data_tst[26]} {id_u/out_addr0_data_tst[27]} {id_u/out_addr0_data_tst[28]} {id_u/out_addr0_data_tst[29]} {id_u/out_addr0_data_tst[30]} {id_u/out_addr0_data_tst[31]}]]
#connect_debug_port u_ila_0/probe1 [get_nets [list {id_u/out_addr1_data_tst[0]} {id_u/out_addr1_data_tst[1]} {id_u/out_addr1_data_tst[2]} {id_u/out_addr1_data_tst[3]} {id_u/out_addr1_data_tst[4]} {id_u/out_addr1_data_tst[5]} {id_u/out_addr1_data_tst[6]} {id_u/out_addr1_data_tst[7]} {id_u/out_addr1_data_tst[8]} {id_u/out_addr1_data_tst[9]} {id_u/out_addr1_data_tst[10]} {id_u/out_addr1_data_tst[11]} {id_u/out_addr1_data_tst[12]} {id_u/out_addr1_data_tst[13]} {id_u/out_addr1_data_tst[14]} {id_u/out_addr1_data_tst[15]} {id_u/out_addr1_data_tst[16]} {id_u/out_addr1_data_tst[17]} {id_u/out_addr1_data_tst[18]} {id_u/out_addr1_data_tst[19]} {id_u/out_addr1_data_tst[20]} {id_u/out_addr1_data_tst[21]} {id_u/out_addr1_data_tst[22]} {id_u/out_addr1_data_tst[23]} {id_u/out_addr1_data_tst[24]} {id_u/out_addr1_data_tst[25]} {id_u/out_addr1_data_tst[26]} {id_u/out_addr1_data_tst[27]} {id_u/out_addr1_data_tst[28]} {id_u/out_addr1_data_tst[29]} {id_u/out_addr1_data_tst[30]} {id_u/out_addr1_data_tst[31]}]]
#connect_debug_port u_ila_0/probe2 [get_nets [list {id_u/out_addr2_data_tst[0]} {id_u/out_addr2_data_tst[1]} {id_u/out_addr2_data_tst[2]} {id_u/out_addr2_data_tst[3]} {id_u/out_addr2_data_tst[4]} {id_u/out_addr2_data_tst[5]} {id_u/out_addr2_data_tst[6]} {id_u/out_addr2_data_tst[7]} {id_u/out_addr2_data_tst[8]} {id_u/out_addr2_data_tst[9]} {id_u/out_addr2_data_tst[10]} {id_u/out_addr2_data_tst[11]} {id_u/out_addr2_data_tst[12]} {id_u/out_addr2_data_tst[13]} {id_u/out_addr2_data_tst[14]} {id_u/out_addr2_data_tst[15]} {id_u/out_addr2_data_tst[16]} {id_u/out_addr2_data_tst[17]} {id_u/out_addr2_data_tst[18]} {id_u/out_addr2_data_tst[19]} {id_u/out_addr2_data_tst[20]} {id_u/out_addr2_data_tst[21]} {id_u/out_addr2_data_tst[22]} {id_u/out_addr2_data_tst[23]} {id_u/out_addr2_data_tst[24]} {id_u/out_addr2_data_tst[25]} {id_u/out_addr2_data_tst[26]} {id_u/out_addr2_data_tst[27]} {id_u/out_addr2_data_tst[28]} {id_u/out_addr2_data_tst[29]} {id_u/out_addr2_data_tst[30]} {id_u/out_addr2_data_tst[31]}]]








#connect_debug_port u_ila_0/probe0 [get_nets [list {out_addr1_data_tst[0]} {out_addr1_data_tst[1]} {out_addr1_data_tst[2]} {out_addr1_data_tst[3]} {out_addr1_data_tst[4]} {out_addr1_data_tst[5]} {out_addr1_data_tst[6]} {out_addr1_data_tst[7]} {out_addr1_data_tst[8]} {out_addr1_data_tst[9]} {out_addr1_data_tst[10]} {out_addr1_data_tst[11]} {out_addr1_data_tst[12]} {out_addr1_data_tst[13]} {out_addr1_data_tst[14]} {out_addr1_data_tst[15]} {out_addr1_data_tst[16]} {out_addr1_data_tst[17]} {out_addr1_data_tst[18]} {out_addr1_data_tst[19]} {out_addr1_data_tst[20]} {out_addr1_data_tst[21]} {out_addr1_data_tst[22]} {out_addr1_data_tst[23]} {out_addr1_data_tst[24]} {out_addr1_data_tst[25]} {out_addr1_data_tst[26]} {out_addr1_data_tst[27]} {out_addr1_data_tst[28]} {out_addr1_data_tst[29]} {out_addr1_data_tst[30]} {out_addr1_data_tst[31]}]]
#connect_debug_port u_ila_0/probe1 [get_nets [list {out_addr0_data_tst[0]} {out_addr0_data_tst[1]} {out_addr0_data_tst[2]} {out_addr0_data_tst[3]} {out_addr0_data_tst[4]} {out_addr0_data_tst[5]} {out_addr0_data_tst[6]} {out_addr0_data_tst[7]} {out_addr0_data_tst[8]} {out_addr0_data_tst[9]} {out_addr0_data_tst[10]} {out_addr0_data_tst[11]} {out_addr0_data_tst[12]} {out_addr0_data_tst[13]} {out_addr0_data_tst[14]} {out_addr0_data_tst[15]} {out_addr0_data_tst[16]} {out_addr0_data_tst[17]} {out_addr0_data_tst[18]} {out_addr0_data_tst[19]} {out_addr0_data_tst[20]} {out_addr0_data_tst[21]} {out_addr0_data_tst[22]} {out_addr0_data_tst[23]} {out_addr0_data_tst[24]} {out_addr0_data_tst[25]} {out_addr0_data_tst[26]} {out_addr0_data_tst[27]} {out_addr0_data_tst[28]} {out_addr0_data_tst[29]} {out_addr0_data_tst[30]} {out_addr0_data_tst[31]}]]
#connect_debug_port u_ila_0/probe2 [get_nets [list {out_addr2_data_tst[0]} {out_addr2_data_tst[1]} {out_addr2_data_tst[2]} {out_addr2_data_tst[3]} {out_addr2_data_tst[4]} {out_addr2_data_tst[5]} {out_addr2_data_tst[6]} {out_addr2_data_tst[7]} {out_addr2_data_tst[8]} {out_addr2_data_tst[9]} {out_addr2_data_tst[10]} {out_addr2_data_tst[11]} {out_addr2_data_tst[12]} {out_addr2_data_tst[13]} {out_addr2_data_tst[14]} {out_addr2_data_tst[15]} {out_addr2_data_tst[16]} {out_addr2_data_tst[17]} {out_addr2_data_tst[18]} {out_addr2_data_tst[19]} {out_addr2_data_tst[20]} {out_addr2_data_tst[21]} {out_addr2_data_tst[22]} {out_addr2_data_tst[23]} {out_addr2_data_tst[24]} {out_addr2_data_tst[25]} {out_addr2_data_tst[26]} {out_addr2_data_tst[27]} {out_addr2_data_tst[28]} {out_addr2_data_tst[29]} {out_addr2_data_tst[30]} {out_addr2_data_tst[31]}]]


#connect_debug_port u_ila_0/probe2 [get_nets [list {state_tst_tst[0]} {state_tst_tst[1]} {state_tst_tst[2]} {state_tst_tst[3]} {state_tst_tst[4]} {state_tst_tst[5]}]]

#connect_debug_port u_ila_0/probe0 [get_nets [list {out_uart1_data_tst[0]} {out_uart1_data_tst[1]} {out_uart1_data_tst[2]} {out_uart1_data_tst[3]} {out_uart1_data_tst[4]} {out_uart1_data_tst[5]} {out_uart1_data_tst[6]} {out_uart1_data_tst[7]} {out_uart1_data_tst[8]} {out_uart1_data_tst[9]} {out_uart1_data_tst[10]} {out_uart1_data_tst[11]} {out_uart1_data_tst[12]} {out_uart1_data_tst[13]} {out_uart1_data_tst[14]} {out_uart1_data_tst[15]} {out_uart1_data_tst[16]} {out_uart1_data_tst[17]} {out_uart1_data_tst[18]} {out_uart1_data_tst[19]} {out_uart1_data_tst[20]} {out_uart1_data_tst[21]} {out_uart1_data_tst[22]} {out_uart1_data_tst[23]} {out_uart1_data_tst[24]} {out_uart1_data_tst[25]} {out_uart1_data_tst[26]} {out_uart1_data_tst[27]} {out_uart1_data_tst[28]} {out_uart1_data_tst[29]} {out_uart1_data_tst[30]} {out_uart1_data_tst[31]}]]
#connect_debug_port u_ila_0/probe1 [get_nets [list {out_uart2_data_tst[0]} {out_uart2_data_tst[1]} {out_uart2_data_tst[2]} {out_uart2_data_tst[3]} {out_uart2_data_tst[4]} {out_uart2_data_tst[5]} {out_uart2_data_tst[6]} {out_uart2_data_tst[7]} {out_uart2_data_tst[8]} {out_uart2_data_tst[9]} {out_uart2_data_tst[10]} {out_uart2_data_tst[11]} {out_uart2_data_tst[12]} {out_uart2_data_tst[13]} {out_uart2_data_tst[14]} {out_uart2_data_tst[15]} {out_uart2_data_tst[16]} {out_uart2_data_tst[17]} {out_uart2_data_tst[18]} {out_uart2_data_tst[19]} {out_uart2_data_tst[20]} {out_uart2_data_tst[21]} {out_uart2_data_tst[22]} {out_uart2_data_tst[23]} {out_uart2_data_tst[24]} {out_uart2_data_tst[25]} {out_uart2_data_tst[26]} {out_uart2_data_tst[27]} {out_uart2_data_tst[28]} {out_uart2_data_tst[29]} {out_uart2_data_tst[30]} {out_uart2_data_tst[31]}]]






#connect_debug_port u_ila_0/probe0 [get_nets [list {hardware_interface_top_u/driver_cfg_addra_tmp[0]} {hardware_interface_top_u/driver_cfg_addra_tmp[1]} {hardware_interface_top_u/driver_cfg_addra_tmp[2]} {hardware_interface_top_u/driver_cfg_addra_tmp[3]} {hardware_interface_top_u/driver_cfg_addra_tmp[4]} {hardware_interface_top_u/driver_cfg_addra_tmp[5]} {hardware_interface_top_u/driver_cfg_addra_tmp[6]} {hardware_interface_top_u/driver_cfg_addra_tmp[7]} {hardware_interface_top_u/driver_cfg_addra_tmp[8]} {hardware_interface_top_u/driver_cfg_addra_tmp[9]} {hardware_interface_top_u/driver_cfg_addra_tmp[10]} {hardware_interface_top_u/driver_cfg_addra_tmp[11]} {hardware_interface_top_u/driver_cfg_addra_tmp[12]} {hardware_interface_top_u/driver_cfg_addra_tmp[13]} {hardware_interface_top_u/driver_cfg_addra_tmp[14]} {hardware_interface_top_u/driver_cfg_addra_tmp[15]}]]
#connect_debug_port u_ila_0/probe1 [get_nets [list {hardware_interface_top_u/driver_cfg_dina_tmp[0]} {hardware_interface_top_u/driver_cfg_dina_tmp[1]} {hardware_interface_top_u/driver_cfg_dina_tmp[2]} {hardware_interface_top_u/driver_cfg_dina_tmp[3]} {hardware_interface_top_u/driver_cfg_dina_tmp[4]} {hardware_interface_top_u/driver_cfg_dina_tmp[5]} {hardware_interface_top_u/driver_cfg_dina_tmp[6]} {hardware_interface_top_u/driver_cfg_dina_tmp[7]} {hardware_interface_top_u/driver_cfg_dina_tmp[8]} {hardware_interface_top_u/driver_cfg_dina_tmp[9]} {hardware_interface_top_u/driver_cfg_dina_tmp[10]} {hardware_interface_top_u/driver_cfg_dina_tmp[11]} {hardware_interface_top_u/driver_cfg_dina_tmp[12]} {hardware_interface_top_u/driver_cfg_dina_tmp[13]} {hardware_interface_top_u/driver_cfg_dina_tmp[14]} {hardware_interface_top_u/driver_cfg_dina_tmp[15]} {hardware_interface_top_u/driver_cfg_dina_tmp[16]} {hardware_interface_top_u/driver_cfg_dina_tmp[17]} {hardware_interface_top_u/driver_cfg_dina_tmp[18]} {hardware_interface_top_u/driver_cfg_dina_tmp[19]} {hardware_interface_top_u/driver_cfg_dina_tmp[20]} {hardware_interface_top_u/driver_cfg_dina_tmp[21]} {hardware_interface_top_u/driver_cfg_dina_tmp[22]} {hardware_interface_top_u/driver_cfg_dina_tmp[23]} {hardware_interface_top_u/driver_cfg_dina_tmp[24]} {hardware_interface_top_u/driver_cfg_dina_tmp[25]} {hardware_interface_top_u/driver_cfg_dina_tmp[26]} {hardware_interface_top_u/driver_cfg_dina_tmp[27]} {hardware_interface_top_u/driver_cfg_dina_tmp[28]} {hardware_interface_top_u/driver_cfg_dina_tmp[29]} {hardware_interface_top_u/driver_cfg_dina_tmp[30]} {hardware_interface_top_u/driver_cfg_dina_tmp[31]}]]
#connect_debug_port u_ila_0/probe2 [get_nets [list {hardware_interface_top_u/pul_motor1_buf_0[0]} {hardware_interface_top_u/pul_motor1_buf_0[1]} {hardware_interface_top_u/pul_motor1_buf_0[2]} {hardware_interface_top_u/pul_motor1_buf_0[3]} {hardware_interface_top_u/pul_motor1_buf_0[4]} {hardware_interface_top_u/pul_motor1_buf_0[5]} {hardware_interface_top_u/pul_motor1_buf_0[6]} {hardware_interface_top_u/pul_motor1_buf_0[7]} {hardware_interface_top_u/pul_motor1_buf_0[8]} {hardware_interface_top_u/pul_motor1_buf_0[9]} {hardware_interface_top_u/pul_motor1_buf_0[10]} {hardware_interface_top_u/pul_motor1_buf_0[11]} {hardware_interface_top_u/pul_motor1_buf_0[12]} {hardware_interface_top_u/pul_motor1_buf_0[13]} {hardware_interface_top_u/pul_motor1_buf_0[14]} {hardware_interface_top_u/pul_motor1_buf_0[15]} {hardware_interface_top_u/pul_motor1_buf_0[16]} {hardware_interface_top_u/pul_motor1_buf_0[17]} {hardware_interface_top_u/pul_motor1_buf_0[18]} {hardware_interface_top_u/pul_motor1_buf_0[19]} {hardware_interface_top_u/pul_motor1_buf_0[20]} {hardware_interface_top_u/pul_motor1_buf_0[21]} {hardware_interface_top_u/pul_motor1_buf_0[22]} {hardware_interface_top_u/pul_motor1_buf_0[23]} {hardware_interface_top_u/pul_motor1_buf_0[24]} {hardware_interface_top_u/pul_motor1_buf_0[25]} {hardware_interface_top_u/pul_motor1_buf_0[26]} {hardware_interface_top_u/pul_motor1_buf_0[27]} {hardware_interface_top_u/pul_motor1_buf_0[28]} {hardware_interface_top_u/pul_motor1_buf_0[29]} {hardware_interface_top_u/pul_motor1_buf_0[30]} {hardware_interface_top_u/pul_motor1_buf_0[31]}]]
#connect_debug_port u_ila_0/probe3 [get_nets [list {hardware_interface_top_u/pul_motor1_msg_tmp[0]} {hardware_interface_top_u/pul_motor1_msg_tmp[1]} {hardware_interface_top_u/pul_motor1_msg_tmp[2]} {hardware_interface_top_u/pul_motor1_msg_tmp[3]} {hardware_interface_top_u/pul_motor1_msg_tmp[4]} {hardware_interface_top_u/pul_motor1_msg_tmp[5]} {hardware_interface_top_u/pul_motor1_msg_tmp[6]} {hardware_interface_top_u/pul_motor1_msg_tmp[7]} {hardware_interface_top_u/pul_motor1_msg_tmp[8]} {hardware_interface_top_u/pul_motor1_msg_tmp[9]} {hardware_interface_top_u/pul_motor1_msg_tmp[10]} {hardware_interface_top_u/pul_motor1_msg_tmp[11]} {hardware_interface_top_u/pul_motor1_msg_tmp[12]} {hardware_interface_top_u/pul_motor1_msg_tmp[13]} {hardware_interface_top_u/pul_motor1_msg_tmp[14]} {hardware_interface_top_u/pul_motor1_msg_tmp[15]} {hardware_interface_top_u/pul_motor1_msg_tmp[16]} {hardware_interface_top_u/pul_motor1_msg_tmp[17]} {hardware_interface_top_u/pul_motor1_msg_tmp[18]} {hardware_interface_top_u/pul_motor1_msg_tmp[19]} {hardware_interface_top_u/pul_motor1_msg_tmp[20]} {hardware_interface_top_u/pul_motor1_msg_tmp[21]} {hardware_interface_top_u/pul_motor1_msg_tmp[22]} {hardware_interface_top_u/pul_motor1_msg_tmp[23]} {hardware_interface_top_u/pul_motor1_msg_tmp[24]} {hardware_interface_top_u/pul_motor1_msg_tmp[25]} {hardware_interface_top_u/pul_motor1_msg_tmp[26]} {hardware_interface_top_u/pul_motor1_msg_tmp[27]} {hardware_interface_top_u/pul_motor1_msg_tmp[28]} {hardware_interface_top_u/pul_motor1_msg_tmp[29]} {hardware_interface_top_u/pul_motor1_msg_tmp[30]} {hardware_interface_top_u/pul_motor1_msg_tmp[31]}]]



#connect_debug_port u_ila_0/probe8 [get_nets [list {hardware_interface_top_u/rs232_uart_id_tmp[0]} {hardware_interface_top_u/rs232_uart_id_tmp[1]} {hardware_interface_top_u/rs232_uart_id_tmp[2]} {hardware_interface_top_u/rs232_uart_id_tmp[3]} {hardware_interface_top_u/rs232_uart_id_tmp[4]} {hardware_interface_top_u/rs232_uart_id_tmp[5]} {hardware_interface_top_u/rs232_uart_id_tmp[6]} {hardware_interface_top_u/rs232_uart_id_tmp[7]} {hardware_interface_top_u/rs232_uart_id_tmp[8]} {hardware_interface_top_u/rs232_uart_id_tmp[9]} {hardware_interface_top_u/rs232_uart_id_tmp[10]} {hardware_interface_top_u/rs232_uart_id_tmp[11]} {hardware_interface_top_u/rs232_uart_id_tmp[12]} {hardware_interface_top_u/rs232_uart_id_tmp[13]} {hardware_interface_top_u/rs232_uart_id_tmp[14]} {hardware_interface_top_u/rs232_uart_id_tmp[15]} {hardware_interface_top_u/rs232_uart_id_tmp[16]} {hardware_interface_top_u/rs232_uart_id_tmp[17]} {hardware_interface_top_u/rs232_uart_id_tmp[18]} {hardware_interface_top_u/rs232_uart_id_tmp[19]} {hardware_interface_top_u/rs232_uart_id_tmp[20]} {hardware_interface_top_u/rs232_uart_id_tmp[21]} {hardware_interface_top_u/rs232_uart_id_tmp[22]} {hardware_interface_top_u/rs232_uart_id_tmp[23]} {hardware_interface_top_u/rs232_uart_id_tmp[24]} {hardware_interface_top_u/rs232_uart_id_tmp[25]} {hardware_interface_top_u/rs232_uart_id_tmp[26]} {hardware_interface_top_u/rs232_uart_id_tmp[27]} {hardware_interface_top_u/rs232_uart_id_tmp[28]} {hardware_interface_top_u/rs232_uart_id_tmp[29]} {hardware_interface_top_u/rs232_uart_id_tmp[30]} {hardware_interface_top_u/rs232_uart_id_tmp[31]}]]



#connect_debug_port u_ila_0/probe0 [get_nets [list {id_u/cfg_sta_addr_tmp[0]} {id_u/cfg_sta_addr_tmp[1]} {id_u/cfg_sta_addr_tmp[2]} {id_u/cfg_sta_addr_tmp[3]} {id_u/cfg_sta_addr_tmp[4]} {id_u/cfg_sta_addr_tmp[5]} {id_u/cfg_sta_addr_tmp[6]} {id_u/cfg_sta_addr_tmp[7]}]]
#connect_debug_port u_ila_0/probe1 [get_nets [list {id_u/eeprom_work_tmp[0]} {id_u/eeprom_work_tmp[1]} {id_u/eeprom_work_tmp[2]} {id_u/eeprom_work_tmp[3]}]]
#connect_debug_port u_ila_0/probe2 [get_nets [list {id_u/read_sta_addr_tmp[0]} {id_u/read_sta_addr_tmp[1]} {id_u/read_sta_addr_tmp[2]} {id_u/read_sta_addr_tmp[3]} {id_u/read_sta_addr_tmp[4]} {id_u/read_sta_addr_tmp[5]} {id_u/read_sta_addr_tmp[6]} {id_u/read_sta_addr_tmp[7]}]]
#connect_debug_port u_ila_0/probe3 [get_nets [list {id_u/state_tmp[0]} {id_u/state_tmp[1]} {id_u/state_tmp[2]} {id_u/state_tmp[3]} {id_u/state_tmp[4]} {id_u/state_tmp[5]}]]
#connect_debug_port u_ila_0/probe4 [get_nets [list id_u/cfg_sta_addr_vld_tmp]]
#connect_debug_port u_ila_0/probe5 [get_nets [list id_u/read_sta_addr_vld_tmp]]






#connect_debug_port u_ila_0/probe0 [get_nets [list {cfg_sta_addr_tmp[0]} {cfg_sta_addr_tmp[1]} {cfg_sta_addr_tmp[2]} {cfg_sta_addr_tmp[3]} {cfg_sta_addr_tmp[4]} {cfg_sta_addr_tmp[5]} {cfg_sta_addr_tmp[6]} {cfg_sta_addr_tmp[7]}]]
#connect_debug_port u_ila_0/probe1 [get_nets [list {eeprom_work_tmp[0]} {eeprom_work_tmp[1]} {eeprom_work_tmp[2]} {eeprom_work_tmp[3]}]]
#connect_debug_port u_ila_0/probe2 [get_nets [list {read_sta_addr_tmp[0]} {read_sta_addr_tmp[1]} {read_sta_addr_tmp[2]} {read_sta_addr_tmp[3]} {read_sta_addr_tmp[4]} {read_sta_addr_tmp[5]} {read_sta_addr_tmp[6]} {read_sta_addr_tmp[7]}]]
#connect_debug_port u_ila_0/probe3 [get_nets [list {state_tmp[0]} {state_tmp[1]} {state_tmp[2]} {state_tmp[3]} {state_tmp[4]} {state_tmp[5]}]]
#connect_debug_port u_ila_0/probe4 [get_nets [list cfg_sta_addr_vld_tmp]]
#connect_debug_port u_ila_0/probe5 [get_nets [list read_sta_addr_vld_tmp]]
#connect_debug_port u_ila_0/probe6 [get_nets [list read_uuid_key_tmp]]
#connect_debug_port u_ila_0/probe7 [get_nets [list did_tmp]]
#connect_debug_port u_ila_0/probe8 [get_nets [list id_r_en_tmp]]
#connect_debug_port u_ila_0/probe9 [get_nets [list id_w_en_tmp]]





#connect_debug_port u_ila_0/probe0 [get_nets [list {hardware_interface_top_u/rcfg_wheel_spd_tst[0]} {hardware_interface_top_u/rcfg_wheel_spd_tst[1]} {hardware_interface_top_u/rcfg_wheel_spd_tst[2]} {hardware_interface_top_u/rcfg_wheel_spd_tst[3]} {hardware_interface_top_u/rcfg_wheel_spd_tst[4]} {hardware_interface_top_u/rcfg_wheel_spd_tst[5]} {hardware_interface_top_u/rcfg_wheel_spd_tst[6]} {hardware_interface_top_u/rcfg_wheel_spd_tst[7]} {hardware_interface_top_u/rcfg_wheel_spd_tst[8]} {hardware_interface_top_u/rcfg_wheel_spd_tst[9]} {hardware_interface_top_u/rcfg_wheel_spd_tst[10]} {hardware_interface_top_u/rcfg_wheel_spd_tst[11]} {hardware_interface_top_u/rcfg_wheel_spd_tst[12]} {hardware_interface_top_u/rcfg_wheel_spd_tst[13]} {hardware_interface_top_u/rcfg_wheel_spd_tst[14]} {hardware_interface_top_u/rcfg_wheel_spd_tst[15]}]]
#connect_debug_port u_ila_0/probe1 [get_nets [list hardware_interface_top_u/rcfg_wheel_dir_tst]]
#connect_debug_port u_ila_0/probe2 [get_nets [list hardware_interface_top_u/rcfg_wheel_son_tst]]
#connect_debug_port u_ila_0/probe3 [get_nets [list hardware_interface_top_u/rcfg_wheel_work_tst]]





#connect_debug_port u_ila_1/probe0 [get_nets [list {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[0]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[1]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[2]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[3]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[4]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[5]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[6]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[7]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[8]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[9]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[10]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[11]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[12]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[13]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[14]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[15]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[16]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[17]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[18]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[19]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[20]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[21]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[22]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[23]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[24]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[25]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[26]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[27]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[28]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[29]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[30]} {hardware_interface_top_u/common_rs485_top_u/rx_dev_data_dbg[31]}]]

#create_debug_core u_ila_0 ila
#set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
#set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
#set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
#set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
#set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
#set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
#set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
#set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
#set_property port_width 1 [get_debug_ports u_ila_0/clk]
#connect_debug_port u_ila_0/clk [get_nets [list aurora_8b10b_top_u/aurora_8b10b_0_exdes_u/aurora_module_i/inst/clock_module_i/mmcm_adv_inst_0]]
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
#set_property port_width 15 [get_debug_ports u_ila_0/probe0]
#connect_debug_port u_ila_0/probe0 [get_nets [list {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[0]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[1]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[2]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[3]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[4]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[5]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[6]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[7]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[8]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[9]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[10]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[11]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[12]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[13]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[14]}]]
#set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
#set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
#set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets prot_clk]
