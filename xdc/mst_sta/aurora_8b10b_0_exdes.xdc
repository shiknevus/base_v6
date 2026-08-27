#xczu5eg-sfvc784-2-i
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
set_property PACKAGE_PIN Y5 [get_ports GT_REFCLK_N]
set_property PACKAGE_PIN Y6 [get_ports GT_REFCLK_P]
####################### GT reference clock LOC #######################


## 12.8 ns period Board Clock Constraint
#create_clock -name init_clk_i -period 12.8 [get_ports INIT_CLK_P]


###### CDC in RESET_LOGIC from INIT_CLK to USER_CLK ##############
#########################################################################set_false_path -to [get_pins -filter REF_PIN_NAME=~*D -of_objects [get_cells -hierarchical -filter {NAME =~ *aurora_8b10b_0_cdc_to*}]]
# False path constraints for Ultrascale Clocking Module (BUFG_GT)
# ----------------------------------------------------------------------------------------------------------------------
set_false_path -to [get_cells -hierarchical -filter {NAME =~ *clock_module_i/*PLL_NOT_LOCKED*}]
set_false_path -through [get_pins -filter REF_PIN_NAME=~*CLR -of_objects [get_cells -hierarchical -filter {NAME =~ *clock_module_i/*user_clk_buf_i*}]]

##################### Locatoin constrain #########################
##Note: User should add LOC based upon the board
#       Below LOC's are place holders and need to be changed as per the device and board
set_property PACKAGE_PIN L3 [get_ports INIT_CLK_P]
set_property PACKAGE_PIN L2 [get_ports INIT_CLK_N]
set_property PACKAGE_PIN AB13 [get_ports led]
set_property PACKAGE_PIN AG11 [get_ports sfp0_disable]
set_property PACKAGE_PIN AD15 [get_ports sfp1_disable]



##Note: User should add IOSTANDARD based upon the board
#       Below IOSTANDARD's are place holders and need to be changed as per the device and board
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports INIT_CLK_P]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports INIT_CLK_N]
set_property IOSTANDARD LVCMOS33 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports sfp0_disable]
set_property IOSTANDARD LVCMOS33 [get_ports sfp1_disable]

set_false_path -from [get_clocks -of_objects [get_pins sys_signal_gen_u/MAST.aurora_mmcm_u/inst/mmcme4_adv_inst/CLKOUT0]]
set_false_path -to [get_clocks -of_objects [get_pins sys_signal_gen_u/MAST.aurora_mmcm_u/inst/mmcme4_adv_inst/CLKOUT0]]
#create_generated_clock -name prot_clk -source [get_pins aurora_8b10b_top_u/axi_clk_0] -divide_by 1 [get_pins prot_clk_bufg/O]
#create_clock -period 6.4 -name prot_clk [get_pins {prot_clk_bufg/O}]
create_clock -period 6.400 -name prot_clk -waveform {0.000 3.200} [get_pins aurora_8b10b_top_u/user_clk_out]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks prot_clk]
set_false_path -from [get_clocks prot_clk] -to [get_clocks clk_pl_0]
##################################################################



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
#connect_debug_port u_ila_0/clk [get_nets [list aurora_8b10b_top_u/aurora_8b10b_0_exdes_u/aurora_module_i/inst/clock_module_i/cpllpd_int_reg]]
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
#set_property port_width 15 [get_debug_ports u_ila_0/probe0]
#connect_debug_port u_ila_0/probe0 [get_nets [list {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[0]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[1]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[2]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[3]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[4]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[5]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[6]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[7]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[8]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[9]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[10]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[11]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[12]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[13]} {emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_rcv_top_u/ethcat_rcv_u/addra[14]}]]
#set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
#set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
#set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets prot_clk]
