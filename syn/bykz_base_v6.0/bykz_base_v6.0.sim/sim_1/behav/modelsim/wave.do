onerror {resume}
quietly WaveActivateNextPane {} 0
<<<<<<< HEAD
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/A_BHA_NUM
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/B_BHA_NUM
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/clk_i
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/rst
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/i_time_1ms_vld
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/i_time_1s_vld
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/i_st_wr_en
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/i_st_wr_addr
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/i_st_wr_data
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/i_st_rd_en
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/i_st_rd_addr
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/o_st_rd_data
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/o_st_rd_vld
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/di_i
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/do_o
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/o_intr_irq
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/sc_id
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/ec_id
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/rst_en_n
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/a_bhv_id
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/a_bhv_vld
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/a_task_id
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/a_tx_ot
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/a_tx_result_rpt
add wave -noupdate -color Cyan /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/irq_3i1o_arbitrator_u0/irq_reg1_o
add wave -noupdate -color Cyan /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/irq_3i1o_arbitrator_u0/irq_reg2_o
add wave -noupdate /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/proactive_beh_3di_1do_u0/curr_state
add wave -noupdate -color Magenta /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_pre_sta_allow
add wave -noupdate -color Magenta -expand -subitemconfig {{/tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow[12]} {-color Magenta -height 15} {/tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow[11]} {-color Magenta -height 15} {/tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow[10]} {-color Magenta -height 15} {/tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow[9]} {-color Magenta -height 15} {/tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow[8]} {-color Magenta -height 15} {/tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow[7]} {-color Magenta -height 15} {/tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow[6]} {-color Magenta -height 15} {/tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow[5]} {-color Magenta -height 15} {/tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow[4]} {-color Magenta -height 15} {/tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow[3]} {-color Magenta -height 15} {/tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow[2]} {-color Magenta -height 15} {/tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow[1]} {-color Magenta -height 15} {/tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow[0]} {-color Magenta -height 15}} /tb_ec_3di_1do/emcc_mst_top_u/emcc_mix_top_u/ec_3di_1do_u0/pre_post_sta_check_3di_1do_u0/a_post_sta_allow
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {41711733908 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
=======
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/clk_i
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/rst_i
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/i_time_1ms_vld
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/i_time_1s_vld
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/pre_sta_allow
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/post_sta_allow
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/a_en
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/a_bhv_id
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/a_bhv_vld
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/a_tx_ot
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/ec_cha_st
add wave -noupdate -expand -group act -radix decimal /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/a_tx_id
add wave -noupdate -expand -group act -color Salmon /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_reg1_o
add wave -noupdate -expand -group act -color Salmon /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_reg2_o
add wave -noupdate -expand -group act -color Salmon /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_o
add wave -noupdate -expand -group act -color Yellow /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/a_tx_result_rpt
add wave -noupdate -expand -group act -color Yellow /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/a_tx_result_vld
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/a_alm_num
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/di
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/irq_o
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/irq_ack_i
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/a_bhv_id_r
add wave -noupdate -expand -group act -color {Medium Slate Blue} -radix unsigned /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/curr_state
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/curr_state_1d
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/next_state
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/timout
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/timout_cnt
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/ack_beh_id
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/ack_tx_id
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/ack_tx_result
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/ack_ps_alart_num
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/match_10
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/match_30
add wave -noupdate -expand -group act /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/proactive_beh_1di_u0/match_40
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/clk_i
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/rst_i
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/sc_id
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/ec_id
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/chl_priority
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_a_i
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_a_grant_o
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/a_bhv_id
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/a_tx_id
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/a_alm_num
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_b_i
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_b_grant_o
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/b_bhv_id
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/b_tx_id
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/b_alm_num
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_c_i
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_c_grant_o
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/c_bhv_id
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/c_tx_id
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/c_alm_num
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_busy_o
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_receive_ack_i
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/curr_state
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/curr_state_1d
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/next_state
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_cnt
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_receive_ack
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/irq_receive_ack_i_r
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/sel_irq_a
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/sel_irq_b
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/sel_irq_c
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/sel_irq_a_d
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/sel_irq_b_d
add wave -noupdate -expand -group irq /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_3i1o_arbitrator_u0/sel_irq_c_d
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/clk_i
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/rst_i
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/i_st_wr_en
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/i_st_wr_addr
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/i_st_wr_data
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/i_st_rd_en
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/i_st_rd_addr
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/o_st_rd_data
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/o_st_rd_vld
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/rst_en_n
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/ec_id
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/sc_id
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/chl_priority
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/unit_id
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/unit_ectrl
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/unit_st
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/m_id
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/m_ectrl
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/m_st
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/m_wk_mod
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/m_saf_st
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/link_m_saf_st
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/bhv_en
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/a_task_id
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/a_task_bhv_id
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/a_en
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/a_bhv_ot
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/a_tsc_result_rpt
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/a_tsc_result_vld
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/a_bhv_id
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/a_bhv_vld
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/b_en
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/b_bhv_ot
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/b_tsc_result_rpt
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/b_tsc_result_vld
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/c_en
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/c_bhv_ot
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/c_tsc_result_rpt
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/c_tsc_result_vld
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/c_bhv_gap_crl
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param1
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param2
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param3
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param4
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param5
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param6
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param7
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param8
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param9
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param10
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param11
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param12
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param13
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param14
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param15
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param16
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param17
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param18
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param19
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param20
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param21
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param22
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param23
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param24
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param25
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param26
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param27
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param28
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param29
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param30
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/irq_reg1
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/irq_reg2
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/a_st
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/a_alm_num
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/a_tsc_id
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/b_st
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/b_alm_num
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/b_tsc_id
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/b_bhv_id
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/c_st
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/c_alm_num
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/c_tsc_id
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/c_bhv_id
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param51
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param52
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param53
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param54
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param55
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param56
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param57
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param58
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param59
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param60
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param61
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param62
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param63
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param64
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param65
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param66
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param67
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param68
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param69
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/param70
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/rd_en_d1
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/rd_en_d2
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/rd_space_select
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/wr_space_select
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/wr_task_vld
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/rd_addr_d1
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/rd_addr_d2
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/rd_task_addr
add wave -noupdate -expand -group reg /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/wr_task_addr
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/clk_i
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/rst
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/i_time_1ms_vld
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/i_time_1s_vld
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_reg_clk
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_reg_reset
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/i_st_wr_en
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/i_st_wr_addr
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/i_st_wr_data
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/i_st_rd_en
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/i_st_rd_addr
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/o_st_rd_data
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/o_st_rd_vld
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/di
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/o_intr_irq
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/unit_id
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/unit_ectrl
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/unit_st
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/m_id
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/m_ectrl
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/m_st
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/m_wk_mod
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/m_saf_st
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/link_m_saf_st
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/sc_id
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ec_id
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/rst_en_n
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_bhv_id
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_bhv_vld
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_task_id
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_tx_ot
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_tx_result_rpt
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/b_tx_ot
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/b_tx_result_rpt
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/b_en
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/c_tx_ot
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/c_gap_crl
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/c_tx_result_rpt
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/c_en
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ec_cha_st
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ec_chb_st
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ec_chc_st
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_bhv_typ
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_tx_id
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_alm_num
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/b_bhv_id
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/b_tx_id
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/b_alm_num
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/c_bhv_id
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/c_tx_id
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/c_alm_num
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param1
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param2
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param3
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param4
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param5
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param6
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param7
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param8
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param9
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param10
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param11
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param12
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param13
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param14
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param15
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param16
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param17
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param18
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param19
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param20
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param21
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param22
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param23
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param24
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param25
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param26
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param27
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param28
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param29
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param30
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param51
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param52
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param53
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param54
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param55
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param56
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param57
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param58
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param59
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param60
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param61
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param62
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param63
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param64
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param65
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param66
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param67
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param68
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param69
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/param70
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/task_time_cnt
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_tx_result_vld
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/b_tx_result_vld
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/c_tx_result_vld
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_pre_sta_allow
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_post_sta_allow
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/b_pre_sta_allow
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/b_post_sta_allow
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/c_pre_sta_allow
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/c_post_sta_allow
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_a
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_b
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_c
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_a_grant
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_b_grant
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_c_grant
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_busy_o
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_reg1
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_reg2
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/rst_i
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/chl_priority
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_task_bhv_id
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_en
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/bhv_en
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/a_bhv_id_r
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_o
add wave -noupdate -expand -group ec_1di /tb_ec_1di/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/irq_ack_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {64838682678 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 164
>>>>>>> origin/cgliu
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
<<<<<<< HEAD
WaveRestoreZoom {0 fs} {62648250 ps}
=======
WaveRestoreZoom {56898195454 fs} {67137412340 fs}
>>>>>>> origin/cgliu
