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
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/irq_reg1
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_1di_u0/ps_rw_pl_reg_u0/irq_reg2
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/a_bhv_id
add wave -noupdate -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/a_bhv_id_r
add wave -noupdate /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/r_pf_abspos
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_pf_spd
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_pf_acc
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_pf_dec
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_quickstop_dec
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_quickstop
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_pf_mode
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_pf_start
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_pf_stop
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_pf_dir
add wave -noupdate -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_pf_pulse
add wave -noupdate -group home -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_drv_son
add wave -noupdate -group home -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_pf_spd
add wave -noupdate -group home -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_pf_acc
add wave -noupdate -group home -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_pf_dec
add wave -noupdate -group home -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_pf_dir
add wave -noupdate -group home -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_lim_f
add wave -noupdate -group home -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_lim_b
add wave -noupdate -group home -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_org
add wave -noupdate -group home -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_start
add wave -noupdate -group home -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_stop
add wave -noupdate -group home -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/fsm_st
add wave -noupdate -expand -group jog -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_u/i_drv_son
add wave -noupdate -expand -group jog -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_u/i_pf_spd
add wave -noupdate -expand -group jog -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_u/i_pf_acc
add wave -noupdate -expand -group jog -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_u/i_pf_dec
add wave -noupdate -expand -group jog -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_u/i_pf_pulse
add wave -noupdate -expand -group jog -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_u/i_pf_dir
add wave -noupdate -expand -group jog -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_u/i_lim_f
add wave -noupdate -expand -group jog -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_u/i_lim_b
add wave -noupdate -expand -group jog -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_u/i_org
add wave -noupdate -expand -group jog -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_u/i_start
add wave -noupdate -expand -group jog -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_u/i_stop
add wave -noupdate -expand -group jog -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/jog_u/fsm_st
add wave -noupdate -group move -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_u/i_drv_son
add wave -noupdate -group move -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_u/i_pf_spd
add wave -noupdate -group move -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_u/i_pf_acc
add wave -noupdate -group move -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_u/i_pf_dec
add wave -noupdate -group move -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_u/i_pf_pulse
add wave -noupdate -group move -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_u/i_lim_f
add wave -noupdate -group move -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_u/i_lim_b
add wave -noupdate -group move -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_u/i_org
add wave -noupdate -group move -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_u/i_abspos
add wave -noupdate -group move -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_u/i_start
add wave -noupdate -group move -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_u/i_stop
add wave -noupdate -group move -color Cyan /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/move_u/fsm_st
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/i_pf_spd
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/i_pf_acc
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/i_pf_dec
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/i_pf_mode
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/i_pf_start
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/i_pf_stop
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/i_pf_dir
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/i_pf_pulse
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/i_quickstop
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/i_quickstop_dec
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/o_pf_done
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/o_pf_error
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/o_pf_busy
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/o_pulse_start
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/o_pulse_period
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/o_pulse_number
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/o_pulse_dir
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/i_pulse_done
add wave -noupdate -group pos_fd -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/pos_u/fsm_st
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/i_bv_pulse_start
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/i_bv_pulse_period
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/i_bv_pulse_number
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/i_bv_pulse_dir
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/o_bv_pulse_done
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/i_dv_ready
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/i_dv_inp
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/i_dv_phase_a
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/i_dv_phase_b
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/i_dv_phase_z
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/o_dv_pulse_p
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/o_dv_pulse_n
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/r_pulse_period
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/r_pulse_number
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/r_pulse_dir
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/r_pulse_count
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/r_pulse_idx
add wave -noupdate -group pul -color Violet /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/Pulmot_fd00/r_pulse_pn
add wave -noupdate /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/r_pf_abspos
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_drv_son
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_pf_spd
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_pf_acc
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_pf_dec
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_pf_dir
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_lim_f
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_lim_b
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_org
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_start
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_stop
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/o_busy
add wave -noupdate -group {home status} -color Magenta /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/o_done
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/o_error
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/o_pf_spd
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/o_pf_acc
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/o_pf_dec
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/o_pf_pulse
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/o_pf_dir
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/o_pf_start
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/o_pf_stop
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/o_pf_quickstop
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_pf_busy
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/i_pf_done
add wave -noupdate -group {home status} /tb_ec_pul_axis/emcc_mst_top_u/emcc_mix_top_u/ec_pul_axis_u0/proactive_beh_pul_axis_u0/home_u/fsm_st
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3764609641100 fs} 0}
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
WaveRestoreZoom {3759121077456 fs} {3775827645790 fs}
