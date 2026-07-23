onerror {resume}
quietly WaveActivateNextPane {} 0
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
WaveRestoreZoom {0 fs} {62648250 ps}
