
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
set_property PACKAGE_PIN AG4 [get_ports tst_sig]

###set_property LOC A1 [get_ports RESET]
###set_property LOC A2 [get_ports GT_RESET_IN]
###set_property LOC A3 [get_ports CHANNEL_UP_0]
###set_property LOC A4 [get_ports LANE_UP_0]
###set_property LOC A5 [get_ports HARD_ERR_0]
###set_property LOC A6  [get_ports SOFT_ERR_0]
###set_property LOC A7  [get_ports ERR_COUNT_0[0]]
###set_property LOC A8 [get_ports ERR_COUNT_0[1]]
###set_property LOC A9 [get_ports ERR_COUNT_0[2]]
###set_property LOC B1  [get_ports ERR_COUNT_0[3]]
###set_property LOC B3  [get_ports ERR_COUNT_0[4]]
###set_property LOC B4  [get_ports ERR_COUNT_0[5]]
###set_property LOC B5  [get_ports ERR_COUNT_0[6]]
###set_property LOC B6  [get_ports ERR_COUNT_0[7]]
###set_property LOC B8  [get_ports FRAME_ERR_0]

###set_property LOC D1 [get_ports CHANNEL_UP_1]
###set_property LOC D2 [get_ports LANE_UP_1]
###set_property LOC D4 [get_ports HARD_ERR_1]
###set_property LOC D5  [get_ports SOFT_ERR_1]
###set_property LOC C1  [get_ports ERR_COUNT_1[0]]
###set_property LOC C2 [get_ports ERR_COUNT_1[1]]
###set_property LOC C3 [get_ports ERR_COUNT_1[2]]
###set_property LOC C4  [get_ports ERR_COUNT_1[3]]
###set_property LOC C6  [get_ports ERR_COUNT_1[4]]
###set_property LOC C7  [get_ports ERR_COUNT_1[5]]
###set_property LOC C8  [get_ports ERR_COUNT_1[6]]
###set_property LOC C9  [get_ports ERR_COUNT_1[7]]
###set_property LOC D6  [get_ports FRAME_ERR_1]


##Note: User should add IOSTANDARD based upon the board
#       Below IOSTANDARD's are place holders and need to be changed as per the device and board
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports INIT_CLK_P]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports INIT_CLK_N]
set_property IOSTANDARD LVCMOS33 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports sfp0_disable]
set_property IOSTANDARD LVCMOS33 [get_ports sfp1_disable]
set_property IOSTANDARD LVCMOS18 [get_ports tst_sig]

#####set_property IOSTANDARD LVCMOS18 [get_ports RESET]
#####set_property IOSTANDARD LVCMOS18 [get_ports GT_RESET_IN]
#####
#####set_property IOSTANDARD LVCMOS18 [get_ports CHANNEL_UP_0]
#####set_property IOSTANDARD LVCMOS18 [get_ports LANE_UP_0]
#####set_property IOSTANDARD LVCMOS18 [get_ports HARD_ERR_0]
#####set_property IOSTANDARD LVCMOS18 [get_ports SOFT_ERR_0]
#####set_property IOSTANDARD LVCMOS18 [get_ports ERR_COUNT_0[*]]
#####set_property IOSTANDARD LVCMOS18 [get_ports FRAME_ERR_0]
#####
#####set_property IOSTANDARD LVCMOS18 [get_ports CHANNEL_UP_1]
#####set_property IOSTANDARD LVCMOS18 [get_ports LANE_UP_1]
#####set_property IOSTANDARD LVCMOS18 [get_ports HARD_ERR_1]
#####set_property IOSTANDARD LVCMOS18 [get_ports SOFT_ERR_1]
#####set_property IOSTANDARD LVCMOS18 [get_ports ERR_COUNT_1[*]]
#####set_property IOSTANDARD LVCMOS18 [get_ports FRAME_ERR_1]
set_false_path -from [get_clocks -of_objects [get_pins sys_signal_gen_u/MAST.aurora_mmcm_u/inst/mmcme4_adv_inst/CLKOUT0]]
set_false_path -to [get_clocks -of_objects [get_pins sys_signal_gen_u/MAST.aurora_mmcm_u/inst/mmcme4_adv_inst/CLKOUT0]]
#create_generated_clock -name prot_clk -source [get_pins aurora_8b10b_top_u/axi_clk_0] -divide_by 1 [get_pins prot_clk_bufg/O]
#create_clock -period 6.4 -name prot_clk [get_pins {prot_clk_bufg/O}]
create_clock -period 6.400 -name prot_clk -waveform {0.000 3.200} [get_pins aurora_8b10b_top_u/axi_clk_0]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks prot_clk]
set_false_path -from [get_clocks prot_clk] -to [get_clocks clk_pl_0]
##################################################################






connect_debug_port u_ila_0/probe0 [get_nets [list {emcc_comp_top_u/roller_2066_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2066_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2066_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2066_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2066_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2066_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe1 [get_nets [list {emcc_comp_top_u/roller_2063_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2063_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2063_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2063_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2063_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2063_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe2 [get_nets [list {emcc_comp_top_u/roller_2000_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2000_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2000_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2000_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2000_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2000_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe3 [get_nets [list {emcc_comp_top_u/roller_2015_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2015_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2015_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2015_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2015_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2015_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe4 [get_nets [list {emcc_comp_top_u/roller_2016_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2016_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2016_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2016_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2016_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2016_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe5 [get_nets [list {emcc_comp_top_u/roller_2023_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2023_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2023_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2023_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2023_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2023_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe6 [get_nets [list {emcc_comp_top_u/roller_2024_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2024_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2024_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2024_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2024_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2024_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe7 [get_nets [list {emcc_comp_top_u/roller_2031_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2031_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2031_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2031_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2031_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2031_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe8 [get_nets [list {emcc_comp_top_u/roller_2032_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2032_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2032_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2032_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2032_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2032_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe9 [get_nets [list {emcc_comp_top_u/roller_2039_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2039_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2039_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2039_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2039_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2039_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe10 [get_nets [list {emcc_comp_top_u/roller_2040_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2040_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2040_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2040_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2040_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2040_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe11 [get_nets [list {emcc_comp_top_u/roller_2045_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2045_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2045_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2045_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2045_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2045_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe12 [get_nets [list {emcc_comp_top_u/roller_2006_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2006_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2006_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2006_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2006_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2006_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe13 [get_nets [list {emcc_comp_top_u/roller_2010_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2010_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2010_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2010_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2010_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2010_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe14 [get_nets [list {emcc_comp_top_u/roller_2046_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2046_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2046_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2046_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2046_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2046_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe15 [get_nets [list {emcc_comp_top_u/roller_2051_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2051_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2051_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2051_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2051_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2051_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe16 [get_nets [list {emcc_comp_top_u/roller_2052_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2052_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2052_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2052_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2052_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2052_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe17 [get_nets [list {emcc_comp_top_u/roller_2013_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2013_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2013_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2013_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2013_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2013_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe18 [get_nets [list {emcc_comp_top_u/roller_2018_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2018_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2018_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2018_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2018_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2018_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe19 [get_nets [list {emcc_comp_top_u/roller_2021_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2021_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2021_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2021_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2021_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2021_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe20 [get_nets [list {emcc_comp_top_u/roller_2026_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2026_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2026_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2026_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2026_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2026_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe21 [get_nets [list {emcc_comp_top_u/roller_2029_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2029_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2029_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2029_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2029_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2029_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe22 [get_nets [list {emcc_comp_top_u/roller_2034_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2034_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2034_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2034_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2034_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2034_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe23 [get_nets [list {emcc_comp_top_u/roller_2037_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2037_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2037_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2037_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2037_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2037_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe24 [get_nets [list {emcc_comp_top_u/roller_2042_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2042_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2042_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2042_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2042_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2042_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe25 [get_nets [list {emcc_comp_top_u/roller_2049_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2049_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2049_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2049_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2049_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2049_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe26 [get_nets [list {emcc_comp_top_u/roller_2054_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2054_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2054_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2054_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2054_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2054_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe27 [get_nets [list {emcc_comp_top_u/roller_2057_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2057_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2057_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2057_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2057_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2057_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe28 [get_nets [list {emcc_comp_top_u/roller_2061_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2061_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2061_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2061_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2061_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2061_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe29 [get_nets [list {emcc_comp_top_u/roller_2068_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2068_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2068_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2068_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2068_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2068_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe30 [get_nets [list {emcc_comp_top_u/roller_2069_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2069_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2069_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2069_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2069_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2069_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe31 [get_nets [list {emcc_comp_top_u/roller_2028_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2028_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2028_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2028_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2028_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2028_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe32 [get_nets [list {emcc_comp_top_u/roller_2033_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2033_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2033_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2033_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2033_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2033_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe33 [get_nets [list {emcc_comp_top_u/roller_2036_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2036_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2036_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2036_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2036_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2036_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe34 [get_nets [list {emcc_comp_top_u/roller_2041_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2041_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2041_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2041_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2041_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2041_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe35 [get_nets [list {emcc_comp_top_u/roller_2017_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2017_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2017_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2017_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2017_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2017_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe36 [get_nets [list {emcc_comp_top_u/roller_2020_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2020_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2020_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2020_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2020_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2020_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe37 [get_nets [list {emcc_comp_top_u/roller_2025_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2025_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2025_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2025_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2025_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2025_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe38 [get_nets [list {emcc_comp_top_u/roller_2048_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2048_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2048_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2048_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2048_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2048_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe39 [get_nets [list {emcc_comp_top_u/roller_2053_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2053_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2053_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2053_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2053_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2053_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe40 [get_nets [list {emcc_comp_top_u/roller_2056_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2056_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2056_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2056_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2056_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2056_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe41 [get_nets [list {emcc_comp_top_u/roller_2007_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2007_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2007_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2007_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2007_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2007_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe42 [get_nets [list {emcc_comp_top_u/roller_2002_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2002_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2002_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2002_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2002_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2002_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe43 [get_nets [list {emcc_comp_top_u/roller_2064_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2064_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2064_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2064_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2064_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2064_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe44 [get_nets [list {emcc_comp_top_u/roller_2067_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2067_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2067_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2067_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2067_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2067_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe45 [get_nets [list {emcc_comp_top_u/roller_2012_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2012_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2012_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2012_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2012_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2012_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe46 [get_nets [list {emcc_comp_top_u/roller_2044_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2044_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2044_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2044_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2044_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2044_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe47 [get_nets [list {emcc_comp_top_u/roller_2009_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2009_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2009_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2009_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2009_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2009_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe48 [get_nets [list {emcc_comp_top_u/roller_2001_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2001_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2001_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2001_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2001_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2001_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe49 [get_nets [list {emcc_comp_top_u/roller_2003_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2003_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2003_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2003_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2003_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2003_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe50 [get_nets [list {emcc_comp_top_u/roller_2004_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2004_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2004_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2004_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2004_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2004_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe51 [get_nets [list {emcc_comp_top_u/roller_2008_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2008_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2008_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2008_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2008_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2008_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe52 [get_nets [list {emcc_comp_top_u/roller_2047_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2047_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2047_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2047_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2047_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2047_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe53 [get_nets [list {emcc_comp_top_u/roller_2005_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2005_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2005_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2005_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2005_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2005_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe54 [get_nets [list {emcc_comp_top_u/roller_2059_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2059_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2059_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2059_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2059_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2059_u/roller_comp_u/wk_state_debug[5]}]]
connect_debug_port u_ila_0/probe55 [get_nets [list {emcc_comp_top_u/roller_2060_u/roller_comp_u/wk_state_debug[0]} {emcc_comp_top_u/roller_2060_u/roller_comp_u/wk_state_debug[1]} {emcc_comp_top_u/roller_2060_u/roller_comp_u/wk_state_debug[2]} {emcc_comp_top_u/roller_2060_u/roller_comp_u/wk_state_debug[3]} {emcc_comp_top_u/roller_2060_u/roller_comp_u/wk_state_debug[4]} {emcc_comp_top_u/roller_2060_u/roller_comp_u/wk_state_debug[5]}]]



create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list aurora_8b10b_top_u/aurora_8b10b_0_exdes_u/aurora_module_i/inst/clock_module_i/cpllpd_int_reg]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 19 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[0]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[1]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[2]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[3]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[4]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[5]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[6]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[7]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[8]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[9]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[10]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[11]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[12]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[13]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[14]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[15]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[16]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[17]} {emcc_comp_top_u/roller_1002_u/roller_comp_u/wk_cnt[32]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets prot_clk]
