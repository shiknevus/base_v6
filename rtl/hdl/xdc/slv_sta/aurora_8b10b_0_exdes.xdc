
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

set_false_path -to [get_clocks -of_objects [get_pins sys_signal_gen_u/SLAVE.aurora_mmcm_u/inst/mmcm_adv_inst/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins sys_signal_gen_u/SLAVE.aurora_mmcm_u/inst/mmcm_adv_inst/CLKOUT0]]

set_property MARK_DEBUG true [get_nets {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_type[*]}]
set_property MARK_DEBUG true [get_nets {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[*]}]
set_property MARK_DEBUG true [get_nets {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/wk_state[*]}]
set_property MARK_DEBUG true [get_nets {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/wk_state_d1[*]}]





set_property MARK_DEBUG true [get_nets app_protocal_top_u/app_ctrl_top_u/reset]


connect_debug_port u_ila_0/probe22 [get_nets [list ping_pong_flag]]





create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list aurora_8b10b_top_u/aurora_8b10b_0_exdes_u/aurora_module_i/inst/clock_module_i/mmcm_adv_inst_0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[0]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[1]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[2]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[3]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[4]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[5]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[6]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[7]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[8]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[9]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[10]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[11]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[12]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[13]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[14]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_addr[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 4 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_we[0]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_we[1]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_we[2]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_we[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 32 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[0]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[1]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[2]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[3]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[4]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[5]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[6]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[7]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[8]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[9]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[10]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[11]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[12]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[13]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[14]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[15]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[16]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[17]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[18]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[19]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[20]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[21]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[22]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[23]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[24]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[25]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[26]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[27]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[28]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[29]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[30]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/cache_din[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 16 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[0]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[1]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[2]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[3]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[4]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[5]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[6]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[7]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[8]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[9]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[10]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[11]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[12]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[13]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[14]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rd_cache_cnt[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[0]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[1]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[2]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[3]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[4]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[5]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[6]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[7]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[8]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[9]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[10]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[11]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[12]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[13]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[14]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_len[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 4 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_type[0]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_type[1]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_type[2]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ethcat_type[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 32 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[0]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[1]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[2]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[3]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[4]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[5]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[6]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[7]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[8]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[9]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[10]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[11]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[12]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[13]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[14]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[15]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[16]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[17]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[18]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[19]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[20]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[21]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[22]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[23]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[24]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[25]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[26]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[27]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[28]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[29]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[30]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/rx_user_dg_id[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 32 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[0]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[1]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[2]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[3]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[4]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[5]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[6]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[7]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[8]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[9]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[10]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[11]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[12]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[13]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[14]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[15]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[16]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[17]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[18]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[19]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[20]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[21]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[22]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[23]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[24]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[25]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[26]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[27]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[28]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[29]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[30]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/tx_user_dg_id[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 6 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/wk_state[0]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/wk_state[1]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/wk_state[2]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/wk_state[3]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/wk_state[4]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/wk_state[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 8 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_wkc[0]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_wkc[1]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_wkc[2]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_wkc[3]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_wkc[4]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_wkc[5]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_wkc[6]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_wkc[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 16 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[0]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[1]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[2]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[3]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[4]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[5]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[6]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[7]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[8]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[9]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[10]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[11]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[12]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[13]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[14]} {app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/datagram_len[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 32 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[0]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[1]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[2]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[3]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[4]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[5]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[6]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[7]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[8]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[9]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[10]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[11]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[12]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[13]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[14]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[15]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[16]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[17]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[18]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[19]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[20]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[21]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[22]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[23]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[24]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[25]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[26]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[27]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[28]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[29]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[30]} {app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_dat[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 4 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tkeep[0]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tkeep[1]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tkeep[2]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tkeep[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 32 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[0]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[1]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[2]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[3]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[4]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[5]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[6]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[7]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[8]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[9]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[10]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[11]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[12]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[13]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[14]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[15]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[16]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[17]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[18]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[19]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[20]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[21]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[22]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[23]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[24]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[25]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[26]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[27]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[28]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[29]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[30]} {app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 2 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {slvsta_rcv_hb_flag[0]} {slvsta_rcv_hb_flag[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {app_wr_en[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 8 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {cfg_sta_addr[0]} {cfg_sta_addr[1]} {cfg_sta_addr[2]} {cfg_sta_addr[3]} {cfg_sta_addr[4]} {cfg_sta_addr[5]} {cfg_sta_addr[6]} {cfg_sta_addr[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/error_flag]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_send_cache_u/m_boroa_tx_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/ping_pong_flag0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list app_protocal_top_u/app_ctrl_top_u/reset]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_eop]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_sop]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/s_ethcat_rx_vld]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list sys_signal_gen_u/SLAVE.aurora_mmcm_u/inst/aurora_ref_clk]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 32 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[0]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[1]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[2]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[3]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[4]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[5]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[6]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[7]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[8]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[9]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[10]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[11]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[12]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[13]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[14]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[15]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[16]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[17]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[18]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[19]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[20]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[21]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[22]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[23]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[24]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[25]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[26]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[27]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[28]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[29]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[30]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 9 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_addra[0]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_addra[1]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_addra[2]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_addra[3]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_addra[4]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_addra[5]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_addra[6]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_addra[7]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_addra[8]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
set_property port_width 32 [get_debug_ports u_ila_1/probe2]
connect_debug_port u_ila_1/probe2 [get_nets [list {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[0]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[1]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[2]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[3]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[4]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[5]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[6]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[7]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[8]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[9]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[10]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[11]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[12]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[13]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[14]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[15]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[16]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[17]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[18]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[19]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[20]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[21]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[22]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[23]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[24]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[25]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[26]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[27]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[28]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[29]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[30]} {emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe3]
set_property port_width 5 [get_debug_ports u_ila_1/probe3]
connect_debug_port u_ila_1/probe3 [get_nets [list {emcc_slv_app_u/slv_app_rcv_u/wk_state[0]} {emcc_slv_app_u/slv_app_rcv_u/wk_state[1]} {emcc_slv_app_u/slv_app_rcv_u/wk_state[2]} {emcc_slv_app_u/slv_app_rcv_u/wk_state[3]} {emcc_slv_app_u/slv_app_rcv_u/wk_state[4]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe4]
set_property port_width 32 [get_debug_ports u_ila_1/probe4]
connect_debug_port u_ila_1/probe4 [get_nets [list {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[0]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[1]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[2]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[3]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[4]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[5]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[6]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[7]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[8]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[9]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[10]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[11]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[12]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[13]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[14]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[15]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[16]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[17]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[18]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[19]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[20]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[21]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[22]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[23]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[24]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[25]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[26]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[27]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[28]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[29]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[30]} {emcc_slv_app_u/slv_app_rcv_u/pre_uuid[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe5]
set_property port_width 8 [get_debug_ports u_ila_1/probe5]
connect_debug_port u_ila_1/probe5 [get_nets [list {emcc_slv_app_u/slv_app_rcv_u/cur_uuid_d1[8]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid_d1[9]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid_d1[10]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid_d1[11]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid_d1[12]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid_d1[13]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid_d1[14]} {emcc_slv_app_u/slv_app_rcv_u/cur_uuid_d1[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe6]
set_property port_width 32 [get_debug_ports u_ila_1/probe6]
connect_debug_port u_ila_1/probe6 [get_nets [list {emcc_slv_app_u/slv_app_send_u/cur_uuid[0]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[1]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[2]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[3]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[4]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[5]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[6]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[7]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[8]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[9]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[10]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[11]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[12]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[13]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[14]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[15]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[16]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[17]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[18]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[19]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[20]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[21]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[22]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[23]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[24]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[25]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[26]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[27]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[28]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[29]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[30]} {emcc_slv_app_u/slv_app_send_u/cur_uuid[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe7]
set_property port_width 9 [get_debug_ports u_ila_1/probe7]
connect_debug_port u_ila_1/probe7 [get_nets [list {emcc_slv_app_u/slv_app_send_u/send_buf_addra[0]} {emcc_slv_app_u/slv_app_send_u/send_buf_addra[1]} {emcc_slv_app_u/slv_app_send_u/send_buf_addra[2]} {emcc_slv_app_u/slv_app_send_u/send_buf_addra[3]} {emcc_slv_app_u/slv_app_send_u/send_buf_addra[4]} {emcc_slv_app_u/slv_app_send_u/send_buf_addra[5]} {emcc_slv_app_u/slv_app_send_u/send_buf_addra[6]} {emcc_slv_app_u/slv_app_send_u/send_buf_addra[7]} {emcc_slv_app_u/slv_app_send_u/send_buf_addra[8]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe8]
set_property port_width 1 [get_debug_ports u_ila_1/probe8]
connect_debug_port u_ila_1/probe8 [get_nets [list {emcc_slv_app_u/slv_app_send_u/send_buf_wea[0]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe9]
set_property port_width 32 [get_debug_ports u_ila_1/probe9]
connect_debug_port u_ila_1/probe9 [get_nets [list {emcc_slv_app_u/slv_app_send_u/send_buf_dina[0]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[1]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[2]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[3]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[4]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[5]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[6]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[7]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[8]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[9]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[10]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[11]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[12]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[13]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[14]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[15]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[16]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[17]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[18]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[19]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[20]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[21]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[22]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[23]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[24]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[25]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[26]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[27]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[28]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[29]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[30]} {emcc_slv_app_u/slv_app_send_u/send_buf_dina[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe10]
set_property port_width 5 [get_debug_ports u_ila_1/probe10]
connect_debug_port u_ila_1/probe10 [get_nets [list {emcc_slv_app_u/slv_app_send_u/wk_state[0]} {emcc_slv_app_u/slv_app_send_u/wk_state[1]} {emcc_slv_app_u/slv_app_send_u/wk_state[2]} {emcc_slv_app_u/slv_app_send_u/wk_state[3]} {emcc_slv_app_u/slv_app_send_u/wk_state[4]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe11]
set_property port_width 32 [get_debug_ports u_ila_1/probe11]
connect_debug_port u_ila_1/probe11 [get_nets [list {rs232_1st_msg[0]} {rs232_1st_msg[1]} {rs232_1st_msg[2]} {rs232_1st_msg[3]} {rs232_1st_msg[4]} {rs232_1st_msg[5]} {rs232_1st_msg[6]} {rs232_1st_msg[7]} {rs232_1st_msg[8]} {rs232_1st_msg[9]} {rs232_1st_msg[10]} {rs232_1st_msg[11]} {rs232_1st_msg[12]} {rs232_1st_msg[13]} {rs232_1st_msg[14]} {rs232_1st_msg[15]} {rs232_1st_msg[16]} {rs232_1st_msg[17]} {rs232_1st_msg[18]} {rs232_1st_msg[19]} {rs232_1st_msg[20]} {rs232_1st_msg[21]} {rs232_1st_msg[22]} {rs232_1st_msg[23]} {rs232_1st_msg[24]} {rs232_1st_msg[25]} {rs232_1st_msg[26]} {rs232_1st_msg[27]} {rs232_1st_msg[28]} {rs232_1st_msg[29]} {rs232_1st_msg[30]} {rs232_1st_msg[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe12]
set_property port_width 9 [get_debug_ports u_ila_1/probe12]
connect_debug_port u_ila_1/probe12 [get_nets [list {rd_msg_addr[0]} {rd_msg_addr[1]} {rd_msg_addr[2]} {rd_msg_addr[3]} {rd_msg_addr[4]} {rd_msg_addr[5]} {rd_msg_addr[6]} {rd_msg_addr[7]} {rd_msg_addr[8]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe13]
set_property port_width 1 [get_debug_ports u_ila_1/probe13]
connect_debug_port u_ila_1/probe13 [get_nets [list emcc_slv_app_u/slv_app_rcv_u/err_flag]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe14]
set_property port_width 1 [get_debug_ports u_ila_1/probe14]
connect_debug_port u_ila_1/probe14 [get_nets [list rd_msg_addr_en]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe15]
set_property port_width 1 [get_debug_ports u_ila_1/probe15]
connect_debug_port u_ila_1/probe15 [get_nets [list app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/slvsta_id_vld]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe16]
set_property port_width 1 [get_debug_ports u_ila_1/probe16]
connect_debug_port u_ila_1/probe16 [get_nets [list app_protocal_top_u/app_ctrl_top_u/SLAVE.app_slv_rx_ctrl_u/error_flag_prcs]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets ll_clk]
