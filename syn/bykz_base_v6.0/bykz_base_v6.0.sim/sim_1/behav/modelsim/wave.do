onerror {resume}
quietly virtual signal -install /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0 { /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(15 downto 2)} com_addr
quietly WaveActivateNextPane {} 0
add wave -noupdate -group top /aurora_8b10b_0_TB/reference_clk_1_n_r
add wave -noupdate -group top /aurora_8b10b_0_TB/reference_clk_2_n_r
add wave -noupdate -group top /aurora_8b10b_0_TB/init_clk_p
add wave -noupdate -group top /aurora_8b10b_0_TB/gt_reset_in
add wave -noupdate -group top /aurora_8b10b_0_TB/gsr_r
add wave -noupdate -group top /aurora_8b10b_0_TB/gts_r
add wave -noupdate -group top /aurora_8b10b_0_TB/reset_i
add wave -noupdate -group top /aurora_8b10b_0_TB/reference_clk_1_p_r
add wave -noupdate -group top /aurora_8b10b_0_TB/reference_clk_2_p_r
add wave -noupdate -group top /aurora_8b10b_0_TB/init_clk_n
add wave -noupdate -group top /aurora_8b10b_0_TB/channel_up_1_i
add wave -noupdate -group top /aurora_8b10b_0_TB/rxp_1_i
add wave -noupdate -group top /aurora_8b10b_0_TB/rxn_1_i
add wave -noupdate -group top /aurora_8b10b_0_TB/txp_1_i
add wave -noupdate -group top /aurora_8b10b_0_TB/txn_1_i
add wave -noupdate -group top /aurora_8b10b_0_TB/channel_up_2_i
add wave -noupdate /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/link_success
add wave -noupdate /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/app_trsf_en
add wave -noupdate /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/trsf_dly_cnt
add wave -noupdate /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/trsf_dly_cnt_en
add wave -noupdate /glbl/GSR
add wave -noupdate /aurora_8b10b_0_TB/gen_link_error
add wave -noupdate -expand -group master -group ps_cfg_msg -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/axilite_S_AXI_u/OPT_MEM_ADDR_BITS
add wave -noupdate -expand -group master -group ps_cfg_msg -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/axilite_S_AXI_u/C_S_AXI_DATA_WIDTH
add wave -noupdate -expand -group master -group ps_cfg_msg -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/axilite_S_AXI_u/C_S_AXI_ADDR_WIDTH
add wave -noupdate -expand -group master -group ps_cfg_msg -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/axilite_S_AXI_u/ADDR_LSB
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/clk
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/reset
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/slv_reg_we
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/slv_reg_addr
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/slv_reg_wr_dat
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/slv_reg_re
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/slv_reg_rd_addr
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/slv_reg_rd_vld
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/slv_reg_rd_dat
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/ps_reg_clk
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/ps_reg_reset
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/ps_reg_we
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/ps_reg_addr
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/ps_reg_wr_dat
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/ps_reg_re
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/ps_reg_rd_addr
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/ps_reg_rd_vld
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/ps_reg_rd_dat
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/slv_reg_re_d1
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/slv_reg_re_d2
add wave -noupdate -expand -group master -group ps_cfg_msg /aurora_8b10b_0_TB/emmcc_mst_top_u/ps_cfg_top_u/cfg_msg_prcs_u/slv_reg_re_d3
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/RAM_DEPTH
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/RAM_DWIDTH
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/RAM_AWIDTH
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/PKG_NUM
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/WOKE_MODE
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/RAM_TYPE
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/prot_clk
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/prot_reset
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/ll_clk
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/ll_clk_rst
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/prot_send_req
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/prot_send_ack
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/app_send_req
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/app_send_ack
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/prot_rcv_req
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/prot_rcv_ack
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/app_rcv_req
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/app_rcv_ack
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/ping_pong_flag
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/prot_wr_en
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/prot_rd_en
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/prot_rd_addr
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/prot_rd_data
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/prot_wr_data
add wave -noupdate -expand -group master -group mst_depot -expand -group 11111 /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/send_buf_ena
add wave -noupdate -expand -group master -group mst_depot -expand -group 11111 /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/send_buf_wea
add wave -noupdate -expand -group master -group mst_depot -expand -group 11111 /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/send_buf_addra
add wave -noupdate -expand -group master -group mst_depot -expand -group 11111 /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/send_buf_dina
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rcv_buf_ena
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rcv_buf_addra
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rcv_buf_douta
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/wr_addr
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/wr_dat
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rd_enb
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rd_addr
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rd_dat
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/dinb
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/wr_ea
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/web
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/pong_ena
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/pong_wea
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/pong_addra
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/pong_dina
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/pong_douta
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/pong_enb
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/pong_web
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/pong_addrb
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/pong_dinb
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/pong_doutb
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rcv_ena
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rcv_wea
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rcv_addra
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rcv_dina
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rcv_douta
add wave -noupdate -expand -group master -group mst_depot -expand -group rcv_buf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rcv_enb
add wave -noupdate -expand -group master -group mst_depot -expand -group rcv_buf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rcv_web
add wave -noupdate -expand -group master -group mst_depot -expand -group rcv_buf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rcv_addrb
add wave -noupdate -expand -group master -group mst_depot -expand -group rcv_buf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rcv_dinb
add wave -noupdate -expand -group master -group mst_depot -expand -group rcv_buf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/rcv_doutb
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/prot_rd_en_d1
add wave -noupdate -expand -group master -group mst_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_depot_top_u/prot_rd_en_d2
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/RESET
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/HARD_ERR_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/SOFT_ERR_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/FRAME_ERR_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/LANE_UP_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/CHANNEL_UP_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/INIT_CLK_IN
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/GT_RESET_IN
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/GT_REFCLK_P
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/GT_REFCLK_N
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/RXP_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/RXN_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/TXP_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/TXN_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/axi_clk_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/axi_clk_rst_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/s_axi_tx_tvalid_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/s_axi_tx_tdata_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/s_axi_tx_tkeep_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/s_axi_tx_tlast_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/s_axi_tx_tready_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/m_axi_rx_tdata_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/m_axi_rx_tkeep_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/m_axi_rx_tvalid_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/m_axi_rx_tlast_0
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/HARD_ERR_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/SOFT_ERR_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/FRAME_ERR_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/LANE_UP_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/CHANNEL_UP_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/RXP_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/RXN_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/TXP_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/TXN_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/s_axi_tx_tdata_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/s_axi_tx_tkeep_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/s_axi_tx_tvalid_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/s_axi_tx_tlast_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/s_axi_tx_tready_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/m_axi_rx_tvalid_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/m_axi_rx_tdata_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/m_axi_rx_tkeep_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/m_axi_rx_tlast_1
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/user_clk_w
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/sys_reset_w
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/sync_clk_w
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/gt_reset_w
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/gt_refclk1_w
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/pll_not_locked_w
add wave -noupdate -expand -group master -expand -group app_protocol -group aurora /aurora_8b10b_0_TB/emmcc_mst_top_u/aurora_8b10b_top_u/init_clk_w
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/clk
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/reset
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/app_trsf_en
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/mst_sta_restart
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/each_dg_length
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/app_err_flag
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/app_err_type
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/hb_err_slvsta
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/mst_prcs_hb_flag
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/loop_link_success
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/ping_pong_flag
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/prot_send_req
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/prot_send_ack
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/pkg_trsf_start
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/one_ecat_frm_done
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/ecat_frm_rslt
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/slv_sta_num
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/rx_eth_type
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/ethcat_tx_type
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/ethcat_tx_len
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/datagram_tx_cmd
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/datagram_tx_len
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/datagram_tx_num
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/datagram_tx_uuid
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/dg_hb_dst_addr
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/timer_cnt
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/timer_done
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl -color Salmon /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/wk_state
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/ck_hb_sta_cnt
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/last_ck_hb_sta
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/mst_sta_restart_d1
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/mst_sta_restart_r
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_tx_ctrl_u/latch_sta_rs_flag
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_tx_ctrl -expand -group heartbeat -color Coral /aurora_8b10b_0_TB/gen_link_error
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/clk
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/reset
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/datagram_rd_start
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/datagram_rd_finish
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/first_slv_sta
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/last_slv_sta
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/ethcat_tx_type
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/datagram_rd_bias
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/datagram_cmd
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/datagram_index
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/datagram_dst_addr
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/datagram_pl_len
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/datagram_wkc
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/datagram_uuid
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd -color Salmon /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/app_rd_en
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd -color Salmon /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/app_rd_addr
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/app_rd_data
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd -expand -group tx_data /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/wk_state_d2
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd -expand -group tx_data -radix decimal /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/work_cnt_d2
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd -expand -group tx_data /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/m_app_tx_tvalid
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd -expand -group tx_data /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/m_app_tx_sop
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd -expand -group tx_data /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/m_app_tx_eop
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd -expand -group tx_data /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/m_app_tx_tdata
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/wk_state
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/wk_state_d1
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/rd_app_done
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/work_cnt
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/work_cnt_d1
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/pkg_rdy
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/payload_len
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/RSV_TAG
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group dg_tx_rd /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/IRQ_TAG
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/clk
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/reset
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/one_ecat_frm_done
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/ecat_frm_rslt
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/slv_sta_num
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/rx_eth_type
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/prot_rcv_req
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/prot_rcv_ack
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/cache_we
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/cache_addr
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/cache_din
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/cache_dout
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/rx_crc_vld
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/rx_crc_pass
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group 1111 /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/depot_we
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group 1111 /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/depot_addr
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group 1111 /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/depot_din
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/depot_dout
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -color Salmon /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/slv_id_we
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -color Salmon /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/slv_id_addr
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -color Salmon /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/slv_id_din
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/ck_slv_hb_vld
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/ck_slv_hb_addr
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/ck_slv_hb_data
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/wk_state
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/wk_state_d1
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/wk_state_d2
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/latency_cnt
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/latency_cnt_done
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/ethcat_len
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/ethcat_type
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/rd_cache_cnt
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/rd_cache_cnt_d1
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/rd_cache_cnt_d2
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/rd_cache_done
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/cache_rd_en
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/cache_rd_en_d1
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/cache_rd_en_d2
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/cache_addr_nxt_bias
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group datagram_P -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/wk_state
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group datagram_P /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/datagram_cmd
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group datagram_P /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/datagram_index
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group datagram_P /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/datagram_addr
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group datagram_P /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/datagram_len
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group datagram_P /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/datagram_last
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group datagram_P /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/datagram_wkc
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/slv_sta_addr
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/slv_sta_id
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/rsv_tag
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/ira_tag
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group {6.0 apperr} /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/ethcat_type
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group {6.0 apperr} /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/error_status
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group {6.0 apperr} /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/app_err_type
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group {6.0 apperr} /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/hb_err_slvsta
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group {6.0 apperr} -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/wk_state
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group {6.0 apperr} -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/cache_addr
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group {6.0 apperr} /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/cache_din
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group {6.0 apperr} /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/cache_dout
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group {6.0 apperr} /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/latency_cnt_done
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl -expand -group {6.0 apperr} -expand -subitemconfig {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/data_buf[2]} {-color Salmon -height 15}} /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/data_buf
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/rx_dg_cnt
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/depot_bias_addr
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/jump_dg_size
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/each_rl_dg_size
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/each_dg_head_size
add wave -noupdate -expand -group master -expand -group app_protocol -expand -group mst_rx_ctrl /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/jump_dg_number
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/PS_REG_AWIDTH
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/PS_REG_DWIDTH
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/RAM_DEPTH
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/RAM_DWIDTH
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/RAM_AWIDTH
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/clk
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/reset
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/link_success
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/loop_link_success
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/slv_cfg_msg_rden
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/slv_cfg_msg_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/slv_cfg_msg_dat
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/jtag_slv_cfg_msg_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/jtag_slv_cfg_msg_dat
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_reg_clk
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_reg_reset
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_reg_we
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_reg_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_reg_wr_dat
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_reg_re
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_reg_rd_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_reg_rd_vld
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_reg_rd_dat
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_tx_depot_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_tx_depot_dout
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_rd_depot_flag
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/slv_sta_msg_vld
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/slv_sta_msg_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/slv_sta_msg_dat
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_prcs_hb_flag
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/m_boroa_tx_tvalid
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/m_boroa_tx_tready
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/m_boroa_tx_tkeep
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/m_boroa_tx_tlast
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/m_boroa_tx_tdata
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/s_aurora_rx_tvalid
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/s_aurora_rx_tkeep
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/s_aurora_rx_tlast
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/s_aurora_rx_tdata
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_tst_trsf_port
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_trsf_port_en
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_tx_req
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_tx_ack
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/cur_tx_trsf_pkg_id
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/send_buf_ena
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top -group ps_depot_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_loopback_flag
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top -group ps_depot_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/tx_dg_done
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top -group ps_depot_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/rx_dg_done
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top -group ps_depot_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/rcv_intf_tst_dg_done
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top -group ps_depot_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/send_buf_wea
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top -group ps_depot_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/send_buf_addra
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top -group ps_depot_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/send_buf_dina
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top -group ps_depot_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_depot_we
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top -group ps_depot_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_depot_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top -group ps_depot_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ps_depot_din
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top -group ps_depot_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/rx_ps_depot_we
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top -group ps_depot_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/rx_ps_depot_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top -group ps_depot_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/rx_ps_depot_din
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/rcv_buf_ena
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/rcv_buf_addra
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/rcv_buf_douta
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_send_req
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_send_ack
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_rcv_req
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_rcv_ack
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/prot_send_req
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/prot_send_ack
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/prot_rcv_req
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/prot_rcv_ack
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/prot_wr_en
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/prot_rd_en
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/prot_rd_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/prot_rd_data
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/prot_wr_data
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_trsf_en
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_err_flag
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_err_type
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/each_dg_len
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/slv_sta_num
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/hb_err_slvsta
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/slv_id_we
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/slv_id_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/slv_id_din
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/ping_pong_flag
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_sta_trsf_flag
add wave -noupdate -expand -group master -group mst_app_top -group mst_ap_top /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/wk_cnt
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_reg_clk
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_reg_reset
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_reg_we
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_reg_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_reg_wr_dat
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_reg_re
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_reg_rd_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_reg_rd_vld
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_reg_rd_dat
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/fpga_version_buf_rd_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/fpga_version_buf_rd_dat
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/prot_clk
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/slv_id_we
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/slv_id_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/slv_id_din
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/slv_fpga_version
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/link_success
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/loop_link_success
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg -color Coral /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/app_err_flag
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg -color Coral /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/app_err_type
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/hb_err_slvsta
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/slv_sta_num
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg -color {Violet Red} /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/stat_rslt
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_tst_trsf_port
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_trsf_port_en
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_tx_req
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_reg_re_d1
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/ps_reg_re_d2
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/wr_space_select
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/rd_space_select
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/wr_reg_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/rd_reg_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/rd_reg_addr_d1
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/rd_reg_addr_d2
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/mst_app_wk_mode
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/id_buf_rd_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_cfg /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/id_buf_rd_dat
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/clk
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/reset
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/link_success
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/slv_sta_num
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/each_dg_len
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/app_send_req
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/app_send_req
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/app_send_ack
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_ena
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group ps_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/aclk
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group ps_depot -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_tx_depot_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group ps_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_tx_depot_addr_d1
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group ps_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_tx_depot_addr_d2
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group ps_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_tx_depot_dout
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group protocol_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/wk_state_d2
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group protocol_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/slv_cfg_msg_vld
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group protocol_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_wea
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group protocol_depot -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_addra
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group protocol_depot -radix hexadecimal -childformat {{{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[31]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[30]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[29]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[28]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[27]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[26]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[25]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[24]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[23]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[22]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[21]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[20]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[19]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[18]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[17]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[16]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[15]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[14]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[13]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[12]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[11]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[10]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[9]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[8]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[7]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[6]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[5]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[4]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[3]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[2]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[1]} -radix hexadecimal} {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[0]} -radix hexadecimal}} -subitemconfig {{/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[31]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[30]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[29]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[28]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[27]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[26]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[25]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[24]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[23]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[22]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[21]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[20]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[19]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[18]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[17]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[16]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[15]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[14]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[13]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[12]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[11]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[10]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[9]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[8]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[7]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[6]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[5]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[4]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[3]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[2]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[1]} {-height 15 -radix hexadecimal} {/aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina[0]} {-height 15 -radix hexadecimal}} /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/send_buf_dina
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group rd_slv_cfg_msg_from_comp -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/slv_cfg_msg_rden
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group rd_slv_cfg_msg_from_comp -radix hexadecimal /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/slv_cfg_msg_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group rd_slv_cfg_msg_from_comp -radix hexadecimal /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/slv_cfg_msg_dat
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group 1 /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/wk_state_d2
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group 1 -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/slv_cfg_msg_dat
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group 1 -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/slv_cfg_msg_addr_d2
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/jtag_slv_cfg_msg_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/jtag_slv_cfg_msg_dat
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_tst_trsf_port
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_trsf_port_en
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/app_trsf_en
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group unuse /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/tst_sig
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/work_cnt
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group state -color Salmon /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rcv_intf_tst_dg_done
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group state /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_tx_req
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group state /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_tx_ack
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group state /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/rx_dg_done
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group state /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/rx_dg_done_d1
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group state /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/rx_dg_done_r
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group state -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/wk_state
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group state /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/slv_sta_num_d2
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group state /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/slv_dg_index
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -expand -group state -radix hexadecimal /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/slv_cfg_msg_addr
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group app_trsf_en /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/link_success_d3
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -group app_trsf_en /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/wk_state
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/stat_cnt
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/wk_state_d1
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/wk_state_d2
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/gen_dat_done
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/slv_sta_num_d2
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/slv_dg_index
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/frm_cnt
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/wait_cnt
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/wait_cnt_done
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/link_success_d1
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/link_success_d2
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/link_success_r
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_tx_req_d1
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_tx_req_d2
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_trsf_port_en_d1
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_trsf_port_en_d2
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_tst_trsf_port_d1
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_tst_trsf_port_d2
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/ps_tx_depot_addr_d1
add wave -noupdate -expand -group master -group mst_app_top -group mst_app_send /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/slv_cfg_msg_addr_d1
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/clk
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/reset
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/slv_sta_num
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/each_dg_len
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/app_rcv_req
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/app_rcv_ack
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rcv_buf_ena
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rcv_buf_addra
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rcv_buf_douta
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -color Coral /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rx_dg_done
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group app_rslt_port -color Orange /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/app_rslt_wea
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group app_rslt_port -color Orange /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/app_rslt_addra
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group app_rslt_port -color Orange /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/app_rslt_dina
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group ps_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/ps_rd_depot_flag
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group ps_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/latch_ps_rd_depot_flag
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group ps_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/ps_depot_we
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group ps_intf -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/ps_depot_addr
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group ps_intf -radix hexadecimal /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/ps_depot_din
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group ps_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/ps_rd_depot_flag
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group slv_sta_intf -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/slv_dg_index
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group slv_sta_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/slv_sta_msg_vld
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group slv_sta_intf -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/slv_sta_msg_addr
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group slv_sta_intf /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/slv_sta_msg_dat
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -color Salmon /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rcv_intf_tst_dg_done
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -color Salmon /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/intf_tst_flag
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group state -color Salmon /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/cur_tx_trsf_pkg_id
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group state /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rcv_buf_douta
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group state /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rcv_buf_douta_d1
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -expand -group state /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/wk_state
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -color Salmon /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_send_u/frm_cnt
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/work_cnt
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/wk_state_d1
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/wk_state_d2
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/gen_dat_done
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rcv_buf_douta_d1
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/slv_dg_index
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/slv_sta_num_d1
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/slv_sta_num_d2
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rcv_buf_addra_d1
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rcv_buf_addra_d2
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rcv_buf_rden
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rcv_buf_rden_d1
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/rcv_buf_rden_d2
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv -color Orange /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/app_rslt_wea
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/app_rslt_addra
add wave -noupdate -expand -group master -group mst_app_top -expand -group mst_app_rcv /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_rcv_u/app_rslt_dina
add wave -noupdate -group slave0 -group FPGA_VERSION -radix unsigned {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state}
add wave -noupdate -group slave0 -group FPGA_VERSION {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ethcat_type}
add wave -noupdate -group slave0 -group FPGA_VERSION {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_cnt}
add wave -noupdate -group slave0 -group FPGA_VERSION {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_addr_nxt_bias}
add wave -noupdate -group slave0 -group FPGA_VERSION -color {Violet Red} {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_we}
add wave -noupdate -group slave0 -group FPGA_VERSION {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_rd_en}
add wave -noupdate -group slave0 -group FPGA_VERSION -color {Violet Red} -radix decimal {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_addr}
add wave -noupdate -group slave0 -group FPGA_VERSION -color {Violet Red} {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_din}
add wave -noupdate -group slave0 -group FPGA_VERSION {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_dout}
add wave -noupdate -group slave0 -group FPGA_VERSION {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/STM_DG_PRCS}
add wave -noupdate -group slave0 -group FPGA_VERSION {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cfg_sta_mode}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/clk}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/rst}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/downstream_lane_up}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/downstream_link}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/s_app_tx_tvalid}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/s_app_tx_tready}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/s_app_tx_tkeep}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/s_app_tx_tlast}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/s_app_tx_tdata}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_app_rx_tvalid}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_app_rx_tkeep}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_app_rx_tlast}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_app_rx_tdata}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tdata_0}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tkeep_0}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tvalid_0}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tlast_0}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tready_0}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tkeep_0}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tvalid_0}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tlast_0}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tdata_0}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tdata_1}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tkeep_1}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tvalid_1}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tlast_1}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tready_1}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tdata_1}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tkeep_1}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tvalid_1}
add wave -noupdate -group slave0 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tlast_1}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/clk}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/reset}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_rcv_hb_flag}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_id}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cfg_sta_addr}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/one_ecat_frm_done}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ecat_frm_rslt}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slv_sta_num}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rx_eth_type}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cur_slv_dg_beat}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -radix unsigned {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/prot_rcv_req}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/prot_rcv_ack}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/prot_send_req}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/prot_send_ack}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_we}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -radix unsigned {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_addr}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_din}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -color Orange {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_dout}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rx_crc_vld}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rx_crc_pass}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group dg_id_ck {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/error_flag}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group dg_id_ck -color Salmon {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ping_pong_flag}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group dg_id_ck {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state_d2}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group dg_id_ck {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_cnt_d2}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group dg_id_ck -color Salmon {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rx_user_dg_id}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group dg_id_ck -color Salmon {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/tx_user_dg_id}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group to_slave_depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_we}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group to_slave_depot -radix unsigned {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_rden}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group to_slave_depot -radix unsigned {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_addr}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group to_slave_depot -radix unsigned {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_din}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group to_slave_depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_dout}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slv_id_we}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slv_id_addr}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slv_id_din}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ck_slv_hb_vld}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ck_slv_hb_addr}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ck_slv_hb_data}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_sof}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_eof}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_tvalid}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_tdata}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group 11111 -color Maroon /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/m_app_tx_tvalid
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group 11111 {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group 11111 {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cfg_sta_mode}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group 11111 {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_uuid_old}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group 11111 {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_uuid}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group 11111 {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state_d1}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/latency_cnt}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/latency_cnt_done}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ethcat_len}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ethcat_type}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -radix unsigned {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_cnt}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_cnt_d1}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_done}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group cache_logic {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group cache_logic {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_rd_en_d1}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group cache_logic {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_rd_en_d2}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group cache_logic {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_we}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group cache_logic {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_rd_en}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group cache_logic -radix decimal {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_addr}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group cache_logic {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_din}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group cache_logic -color Orange {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_dout}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_addr_nxt_bias}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group DATAGRAM {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group DATAGRAM {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_cmd}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group DATAGRAM {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_index}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group DATAGRAM -color {Medium Violet Red} {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_addr}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group DATAGRAM -radix unsigned {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_len}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group DATAGRAM {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_last}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group DATAGRAM {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_wkc}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand -group DATAGRAM {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cfg_sta_addr}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -expand {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/data_buf}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rsv_tag}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ira_tag}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rx_dg_cnt}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/timestamp}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/jump_dg_size}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/each_rl_dg_size}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/each_dg_head_size}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/jump_dg_number}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_tvalid}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_sof}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_eof}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_sof_d1}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_eof_d1}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_sof}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_eof}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_tvalid}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_tdata}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state_d1}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group cache {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_we}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group cache {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_rd_en}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group cache {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_addr}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group cache {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_cnt}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group cache -color Salmon {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_din}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group cache {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_cnt_d2}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group cache {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_dout}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group init {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group init {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ethcat_type}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group init -expand {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/data_buf}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cfg_sta_mode}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cfg_sta_addr}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_we}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_rden}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_addr}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_din}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_dout}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ethcat_type}
add wave -noupdate -group slave0 -expand -group slv_protocol_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_tvalid_d1}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_clk}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_reset}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/ll_clk}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/ll_clk_rst}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_send_req}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_send_ack}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/app_send_req}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/app_send_ack}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_rcv_req}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_rcv_ack}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/app_rcv_req}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/app_rcv_ack}
add wave -noupdate -group slave0 -group depot -color Salmon {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/ping_pong_flag}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_wr_en}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_rd_en}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_rd_addr}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_rd_data}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_wr_data}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/send_buf_ena}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/send_buf_wea}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/send_buf_addra}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/send_buf_dina}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rcv_buf_ena}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rcv_buf_addra}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rcv_buf_douta}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/wr_addr}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/wr_dat}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rd_enb}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rd_addr}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rd_dat}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/dinb}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/wr_ea}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/web}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/pong_ena}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/pong_wea}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/pong_addra}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/pong_dina}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/pong_douta}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/pong_enb}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/pong_web}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/pong_addrb}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/pong_dinb}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/pong_doutb}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rcv_ena}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rcv_wea}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rcv_addra}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rcv_dina}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rcv_douta}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rcv_enb}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rcv_web}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rcv_addrb}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rcv_dinb}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/rcv_doutb}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_rd_addr_d1}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_rd_addr_d2}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_rd_en_d1}
add wave -noupdate -group slave0 -group depot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_depot_top_u/prot_rd_en_d2}
add wave -noupdate -group slave0 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/clk}
add wave -noupdate -group slave0 -group slv_app -divider send
add wave -noupdate -group slave0 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/app_tx_pulse}
add wave -noupdate -group slave0 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/wk_state}
add wave -noupdate -group slave0 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/send_buf_wea}
add wave -noupdate -group slave0 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/send_buf_addra}
add wave -noupdate -group slave0 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/send_buf_dina}
add wave -noupdate -group slave0 -group slv_app -divider receive
add wave -noupdate -group slave0 -group slv_app -color Maroon {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/cur_uuid}
add wave -noupdate -group slave0 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/wk_state}
add wave -noupdate -group slave0 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/rcv_buf_ena}
add wave -noupdate -group slave0 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/rcv_buf_addra}
add wave -noupdate -group slave0 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_sta_num}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/each_dg_len}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/app_send_req}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/app_send_ack}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/app_rcv_req}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/app_rcv_ack}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/send_buf_ena}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/send_buf_wea}
add wave -noupdate -group slave0 -group slv_app -group top -radix unsigned {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/send_buf_addra}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/send_buf_dina}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/rcv_buf_ena}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/rcv_buf_addra}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/rcv_buf_douta}
add wave -noupdate -group slave0 -group slv_app -group top -group cfg_driver -color Salmon {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/app_cfg_wea}
add wave -noupdate -group slave0 -group slv_app -group top -group cfg_driver -color Salmon -radix unsigned {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/app_cfg_addra}
add wave -noupdate -group slave0 -group slv_app -group top -group cfg_driver -color Salmon {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/app_cfg_dina}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/driver_cfg_msg_wr_req}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/driver_cfg_msg_wr_ack}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/rd_msg_addr_en}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/rd_msg_addr}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/do_regoin_msg}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/di_regoin_msg}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/ai_regoin_msg}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/rs232_1st_msg}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/rs232_2nd_msg}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/tst_cnt}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/app_tx_pulse}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/pre_uuid}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/id_regoin_msg}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/intf_tst_flag}
add wave -noupdate -group slave0 -group slv_app -group top {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/reset}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/clk}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/reset}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/app_tx_pulse}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use -color Maroon {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/pre_uuid}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/slv_sta_num}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/each_dg_len}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/app_send_req}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/app_send_ack}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use -expand -group todepot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/send_buf_ena}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use -expand -group todepot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/send_buf_wea}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use -expand -group todepot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/send_buf_addra}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use -expand -group todepot {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/send_buf_dina}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/id_regoin_msg}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/do_regoin_msg}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/di_regoin_msg}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/ai_regoin_msg}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rd_msg_addr_en}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rd_msg_addr}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rs232_1st_msg}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rs232_2nd_msg}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/intf_tst_flag}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rx_wr_txbuf_wen}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rx_wr_txbuf_addr}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rx_wr_txbuf_data}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/tst_sig}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/work_cnt}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/wk_state}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/wk_state_d1}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/wk_state_d2}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/work_cnt_done}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/slv_dg_index}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/slv_sta_num_d1}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/slv_sta_num_d2}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rd_msg_addr_en_d1}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rd_msg_addr_en_d2}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rd_msg_addr_en_d3}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rd_msg_addr_d1}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rd_msg_addr_d2}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rd_msg_addr_d3}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rd_msg_data}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/msg_array}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rx_wr_txbuf_wen_d1}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rx_wr_txbuf_wen_f}
add wave -noupdate -group slave0 -group slv_app -group slv_app_sned -expand -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/latch_intf_tst_flag}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/clk}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/reset}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/slv_sta_num}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/each_dg_len}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/app_rcv_req}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/app_rcv_ack}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/rcv_buf_ena}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use -radix unsigned {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/rcv_buf_addra}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/app_cfg_wea}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/app_cfg_addra}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/app_cfg_dina}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/driver_cfg_msg_wr_req}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/driver_cfg_msg_wr_ack}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/app_tx_pulse}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use -color Maroon {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/pre_uuid}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use -color Maroon {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/cur_uuid}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/ping_pong_flag}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/intf_tst_flag}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/tst_sig}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/work_cnt}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/wk_state}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/wk_state_d1}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/wk_state_d2}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/work_cnt_done}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/rcv_buf_douta_d1}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/slv_dg_index}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/slv_sta_num_d1}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/slv_sta_num_d2}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/rcv_buf_addra_d1}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/rcv_buf_addra_d2}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/rcv_buf_rden}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/rcv_buf_rden_d1}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/rcv_buf_rden_d2}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/cfg_msg_rd_en}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/cfg_msg_rd_en_d1}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/cfg_msg_rd_en_d2}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/cfg_msg_rd_addr}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/cfg_msg_rd_addr_d1}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/cfg_msg_rd_addr_d2}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/cfg_msg_rd_dat}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/app_rslt_wea}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/app_rslt_addra}
add wave -noupdate -group slave0 -group slv_app -expand -group slv_app_rcv -group no_use {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_rcv_u/app_rslt_dina}
add wave -noupdate -group slave1 {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/clk}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/reset}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_rcv_hb_flag}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_id}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cfg_sta_addr}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ping_pong_flag}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/one_ecat_frm_done}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ecat_frm_rslt}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slv_sta_num}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rx_eth_type}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cur_slv_dg_beat}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/prot_rcv_req}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/prot_rcv_ack}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/prot_send_req}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/prot_send_ack}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_we}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_addr}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_din}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_dout}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rx_crc_vld}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rx_crc_pass}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_rden}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_we}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_addr}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_din}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_dout}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slv_id_we}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slv_id_addr}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slv_id_din}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ck_slv_hb_vld}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ck_slv_hb_addr}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ck_slv_hb_data}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_sof}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_eof}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_tvalid}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_tdata}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cfg_sta_mode}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state_d1}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state_d2}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/latency_cnt}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/latency_cnt_done}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ethcat_len}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ethcat_type}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_cnt}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_cnt_d1}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_cnt_d2}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_done}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_rd_en}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_rd_en_d1}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_rd_en_d2}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_addr_nxt_bias}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_cmd}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_index}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_addr}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_len}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_last}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_wkc}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rsv_tag}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ira_tag}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rx_dg_cnt}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/timestamp}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_uuid}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_uuid_old}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/jump_dg_size}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/each_rl_dg_size}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/each_dg_head_size}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/jump_dg_number}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_sof}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_eof}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_tvalid}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_sof_d1}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_eof_d1}
add wave -noupdate -group slave1 -expand -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_tvalid_d1}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/clk}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/reset}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/slv_sta_num}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/each_dg_len}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/app_send_req}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/app_send_ack}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/app_rcv_req}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/app_rcv_ack}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/send_buf_ena}
add wave -noupdate -group slave1 -group slv_app -expand -group send_to_buf {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/send_buf_wea}
add wave -noupdate -group slave1 -group slv_app -expand -group send_to_buf {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/send_buf_addra}
add wave -noupdate -group slave1 -group slv_app -expand -group send_to_buf {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/send_buf_dina}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/rcv_buf_ena}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/rcv_buf_addra}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/rcv_buf_douta}
add wave -noupdate -group slave1 -group slv_app -color Salmon {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/app_cfg_wea}
add wave -noupdate -group slave1 -group slv_app -color Salmon {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/app_cfg_addra}
add wave -noupdate -group slave1 -group slv_app -color Salmon {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/app_cfg_dina}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/driver_cfg_msg_wr_req}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/driver_cfg_msg_wr_ack}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/rd_msg_addr_en}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/rd_msg_addr}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/do_regoin_msg}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/di_regoin_msg}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/ai_regoin_msg}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/rs232_1st_msg}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/rs232_2nd_msg}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/tst_sig}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/tst_cnt}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/app_tx_pulse}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/pre_uuid}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/id_regoin_msg}
add wave -noupdate -group slave1 -group slv_app {/aurora_8b10b_0_TB/SLV_STA[1]/emmcc_slv_top_u/emcc_slv_app_u/intf_tst_flag}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/clk}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/rst}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/downstream_lane_up}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/downstream_link}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/s_app_tx_tvalid}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/s_app_tx_tready}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/s_app_tx_tkeep}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/s_app_tx_tlast}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/s_app_tx_tdata}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_app_rx_tvalid}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_app_rx_tkeep}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_app_rx_tlast}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_app_rx_tdata}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tdata_0}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tkeep_0}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tvalid_0}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tlast_0}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tready_0}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tdata_0}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tkeep_0}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tvalid_0}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tlast_0}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tvalid_1}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tlast_1}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tready_1}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tdata_1}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/m_axi_tx_tkeep_1}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tdata_1}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tkeep_1}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tvalid_1}
add wave -noupdate -group slave2 -group ethcat_route {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/ethcat_axi_rout_u/s_axi_rx_tlast_1}
add wave -noupdate -group slave2 {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/clk}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/reset}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_rcv_hb_flag}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_id}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cfg_sta_addr}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ping_pong_flag}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/one_ecat_frm_done}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ecat_frm_rslt}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slv_sta_num}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rx_eth_type}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cur_slv_dg_beat}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/prot_rcv_req}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/prot_rcv_ack}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/prot_send_req}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/prot_send_ack}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_we}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_addr}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_din}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_dout}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rx_crc_vld}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rx_crc_pass}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_rden}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_we}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_addr}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_din}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/depot_dout}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slv_id_we}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slv_id_addr}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slv_id_din}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ck_slv_hb_vld}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ck_slv_hb_addr}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ck_slv_hb_data}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_sof}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_eof}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_tvalid}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/m_slvsta_tx_tdata}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cfg_sta_mode}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state_d1}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/wk_state_d2}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/latency_cnt}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/latency_cnt_done}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ethcat_len}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ethcat_type}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_cnt}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_cnt_d1}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_cnt_d2}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rd_cache_done}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_rd_en}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_rd_en_d1}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_rd_en_d2}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cache_addr_nxt_bias}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_cmd}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_index}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_addr}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_len}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_last}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_wkc}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rsv_tag}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/ira_tag}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/rx_dg_cnt}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/timestamp}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_uuid}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/datagram_uuid_old}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/jump_dg_size}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/each_rl_dg_size}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/each_dg_head_size}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/jump_dg_number}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_sof}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_eof}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_tvalid}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_sof_d1}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_eof_d1}
add wave -noupdate -group slave2 -group slv_protcol_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/slvsta_tx_tvalid_d1}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/clk}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/reset}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/slv_sta_num}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/each_dg_len}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/app_send_req}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/app_send_ack}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/app_rcv_req}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/app_rcv_ack}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/send_buf_ena}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/send_buf_wea}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/send_buf_addra}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/send_buf_dina}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/rcv_buf_ena}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/rcv_buf_addra}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/rcv_buf_douta}
add wave -noupdate -group slave2 -group slv_app_rcv -color Salmon {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/app_cfg_wea}
add wave -noupdate -group slave2 -group slv_app_rcv -color Salmon {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/app_cfg_addra}
add wave -noupdate -group slave2 -group slv_app_rcv -color Salmon {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/app_cfg_dina}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/driver_cfg_msg_wr_req}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/driver_cfg_msg_wr_ack}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/rd_msg_addr_en}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/rd_msg_addr}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/do_regoin_msg}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/di_regoin_msg}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/ai_regoin_msg}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/rs232_1st_msg}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/rs232_2nd_msg}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/tst_sig}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/tst_cnt}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/app_tx_pulse}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/pre_uuid}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/id_regoin_msg}
add wave -noupdate -group slave2 -group slv_app_rcv {/aurora_8b10b_0_TB/SLV_STA[2]/emmcc_slv_top_u/emcc_slv_app_u/intf_tst_flag}
add wave -noupdate -group TX_barm /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_aclk
add wave -noupdate -group TX_barm /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_clk_a
add wave -noupdate -group TX_barm /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_aresetn
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_awaddr
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_awprot
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_awvalid
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_awready
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_wdata
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_wstrb
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_wvalid
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_wready
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_bresp
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_bvalid
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_bready
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_araddr
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_arprot
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_arvalid
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_arready
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_rdata
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_rresp
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_rvalid
add wave -noupdate -group TX_barm -group nouse /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_rready
add wave -noupdate -group TX_barm /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_rst_a
add wave -noupdate -group TX_barm -radix unsigned -childformat {{/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(15) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(14) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(13) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(12) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(11) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(10) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(9) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(8) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(7) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(6) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(5) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(4) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(3) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(2) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(1) -radix unsigned} {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(0) -radix unsigned}} -subitemconfig {/aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(15) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(14) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(13) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(12) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(11) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(10) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(9) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(8) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(7) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(6) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(5) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(4) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(3) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(2) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(1) {-height 15 -radix unsigned} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a(0) {-height 15 -radix unsigned}} /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a
add wave -noupdate -group TX_barm /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_en_a
add wave -noupdate -group TX_barm /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_we_a
add wave -noupdate -group TX_barm -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/com_addr
add wave -noupdate -group TX_barm /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_wrdata_a
add wave -noupdate -group TX_barm /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_rddata_a
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/clk
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/reset
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_length
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/ethcat_type
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/s_app_tx_tvalid
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/s_app_tx_sop
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/s_app_tx_eop
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/s_app_tx_tdata
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/m_boroa_tx_tvalid
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/m_boroa_tx_tready
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/m_boroa_tx_tkeep
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/m_boroa_tx_tlast
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/m_boroa_tx_tdata
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/m_ethcat_tx_tvalid
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/m_ethcat_tx_sop
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/m_ethcat_tx_eop
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/m_ethcat_tx_tdata
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/tx_data_crc
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/tx_rem_crc
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/tx_sof_crc_n
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/tx_eof_crc_n
add wave -noupdate -group ethcat /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/ethcat_top_u/ethcat_send_top_u/tx_src_rdy_crc_n
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_aclk
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_aresetn
add wave -noupdate -group tx_depot -color Coral /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_awvalid
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_awready
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_awaddr
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_wvalid
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_wready
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_wstrb
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_wdata
add wave -noupdate -group tx_depot -color Coral /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_bvalid
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_bready
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_bresp
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_araddr
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_arprot
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_arvalid
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_arready
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_rdata
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_rresp
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_rvalid
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/s_axi_rready
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_rst_a
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_clk_a
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_en_a
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_we_a
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_addr_a
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_wrdata_a
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/bram_rddata_a
add wave -noupdate -group tx_depot /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/axi_bram_ctrl_0/com_addr
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/aclk
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/aclk1
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/aresetn
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_awvalid
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_awready
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_awid
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_awaddr
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_awlen
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_awsize
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_awburst
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_awlock
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_awcache
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_awprot
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_awqos
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_wvalid
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_wready
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_wlast
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_wstrb
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_wdata
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_bid
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_bresp
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_bvalid
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_bready
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_arid
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_araddr
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_arlen
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_arsize
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_arburst
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_arlock
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_arcache
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_arprot
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_arqos
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_aruser
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_arvalid
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_arready
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_rid
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_rdata
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_rresp
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_rlast
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_rvalid
add wave -noupdate -group smartaxi_1 /aurora_8b10b_0_TB/emmcc_mst_top_u/mststa_mpsoc_u/smartconnect_1/S00_AXI_rready
add wave -noupdate /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/slv_fpga_version
add wave -noupdate -group mst_datagram_tx_rr /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/wk_state_d2
add wave -noupdate -group mst_datagram_tx_rr -radix unsigned /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/work_cnt_d2
add wave -noupdate -group mst_datagram_tx_rr /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/m_app_tx_tvalid
add wave -noupdate -group mst_datagram_tx_rr /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/m_app_tx_sop
add wave -noupdate -group mst_datagram_tx_rr /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/m_app_tx_eop
add wave -noupdate -group mst_datagram_tx_rr /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/m_app_tx_tdata
add wave -noupdate -group mst_datagram_tx_rr /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/datagram_wkc
add wave -noupdate -group mst_datagram_tx_rr /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/SS_ADDR_CFG_MODE
add wave -noupdate -group mst_datagram_tx_rr /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/datagram_uuid
add wave -noupdate -group mst_datagram_tx_rr /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/RSV_TAG
add wave -noupdate -group mst_datagram_tx_rr /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/last_slv_sta
add wave -noupdate -group mst_datagram_tx_rr /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/SS_ADDR_CFG_MODE
add wave -noupdate -group mst_datagram_tx_rr /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/datagram_top_u/datagram_tx_u/datagram_tx_rd_u/datagram_dst_addr
add wave -noupdate {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cfg_sta_addr}
add wave -noupdate {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/rx_wr_txbuf_data}
add wave -noupdate {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/latch_intf_tst_flag}
add wave -noupdate {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/emcc_slv_app_u/slv_app_send_u/cur_uuid}
add wave -noupdate {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/datain}
add wave -noupdate {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/dataout}
add wave -noupdate {/aurora_8b10b_0_TB/SLV_STA[0]/emmcc_slv_top_u/app_protocal_top_u/app_ctrl_top_u/SLAVE/app_slv_rx_ctrl_u/cfg_sta_addr}
add wave -noupdate /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/data_buf
add wave -noupdate /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/rsv_tag
add wave -noupdate -expand -group new_fsm /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/app_protocal_top_u/app_ctrl_top_u/MAST/app_mst_rx_ctrl_u/ira_tag
add wave -noupdate -expand -group new_fsm /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/wk_state
add wave -noupdate -expand -group new_fsm /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/init_finish_d1
add wave -noupdate -expand -group new_fsm /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/f_nstate
add wave -noupdate -expand -group new_fsm /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/run_en
add wave -noupdate -expand -group new_fsm /aurora_8b10b_0_TB/emmcc_mst_top_u/emcc_mst_app_u/mst_app_cfg_u/init_error
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 8} {76862000000 fs} 1} {{Cursor 10} {44724956345 fs} 1} {{Cursor 6} {90093251965 fs} 0}
quietly wave cursor active 3
configure wave -namecolwidth 704
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 fs} {161136471250 fs}
