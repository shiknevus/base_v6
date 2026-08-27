onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_man_handwheel/man_handwheel/clk
add wave -noupdate /tb_man_handwheel/man_handwheel/reset
add wave -noupdate /tb_man_handwheel/man_handwheel/i_pulse_a
add wave -noupdate /tb_man_handwheel/man_handwheel/i_pulse_b
add wave -noupdate /tb_man_handwheel/man_handwheel/i_stp_x1
add wave -noupdate /tb_man_handwheel/man_handwheel/i_stp_x10
add wave -noupdate /tb_man_handwheel/man_handwheel/i_stp_x100
add wave -noupdate /tb_man_handwheel/man_handwheel/i_axis_x
add wave -noupdate /tb_man_handwheel/man_handwheel/i_axis_y
add wave -noupdate /tb_man_handwheel/man_handwheel/i_axis_z
add wave -noupdate /tb_man_handwheel/man_handwheel/i_axis_4
add wave -noupdate /tb_man_handwheel/man_handwheel/i_axis_5
add wave -noupdate /tb_man_handwheel/man_handwheel/i_axis_6
add wave -noupdate /tb_man_handwheel/man_handwheel/i_axis_7
add wave -noupdate /tb_man_handwheel/man_handwheel/o_axis_number
add wave -noupdate /tb_man_handwheel/man_handwheel/o_speed_gear
add wave -noupdate /tb_man_handwheel/man_handwheel/o_pulse_cnt
add wave -noupdate /tb_man_handwheel/man_handwheel/o_wheel_dir
add wave -noupdate /tb_man_handwheel/man_handwheel/sample_vld
add wave -noupdate /tb_man_handwheel/man_handwheel/time_cnt
add wave -noupdate /tb_man_handwheel/man_handwheel/aclk_r
add wave -noupdate /tb_man_handwheel/man_handwheel/aclk_r_r
add wave -noupdate /tb_man_handwheel/man_handwheel/aclk_r_r_r
add wave -noupdate /tb_man_handwheel/man_handwheel/aclk_pose
add wave -noupdate /tb_man_handwheel/man_handwheel/previ
add wave -noupdate /tb_man_handwheel/man_handwheel/axis_number_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2491465000 ps} 0}
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
WaveRestoreZoom {0 ps} {4720991607 ps}
