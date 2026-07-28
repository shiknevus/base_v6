onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/clk_i
add wave -noupdate /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/rst_i
add wave -noupdate /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/i_time_1ms_vld
add wave -noupdate /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/i_time_1s_vld
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pre_sta_allow
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/post_sta_allow
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/o_dv_pulse
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/o_dv_dir
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/o_dv_reset
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/o_dv_son
add wave -noupdate /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/ps_reg_clk
add wave -noupdate /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/ps_reg_reset
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_st_wr_en
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_st_wr_addr
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_st_wr_data
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_st_rd_en
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_st_rd_addr
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/o_st_rd_data
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/o_st_rd_vld
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/state_monitor_o
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/i_servo_notok
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/i_servo_stop
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/i_axis_limf
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/i_axis_org
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/i_axis_limb
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/i_emerge_stop_signal
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/i_safe_status
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/i_axis_point
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/i_axis_reset
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/i_dv_alarm
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/axis_org
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_stop
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_busy
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_done
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_error
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_stop
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_busy
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_done
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_error
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_stop
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_busy
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_done
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_error
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_pf_dir
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_pf_pulse
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/o_rc_pulse_start
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/o_rc_pulse_period
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/o_rc_pulse_number
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/o_rc_pulse_dir
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/i_rc_pulse_done
add wave -noupdate /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/r_pf_abspos
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_servo_notok
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_servo_stop
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_axis_limf
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_axis_org
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_axis_limb
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_emerge_stop_signal
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_safe_status
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_axis_point
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_axis_reset
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/i_dv_alarm
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/o_dv_pulse
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/o_dv_dir
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/o_dv_reset
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/o_dv_son
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/o_intr_irq
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {41513355848 fs} 0}
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
WaveRestoreZoom {28739843872 fs} {59176850323 fs}
