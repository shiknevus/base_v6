onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_ec_siemens_cnc/emcc_mst_top_u/emcc_mix_top_u/ec_siemens_cnc_u0/i_st_wr_en
add wave -noupdate /tb_ec_siemens_cnc/emcc_mst_top_u/emcc_mix_top_u/ec_siemens_cnc_u0/i_st_wr_addr
add wave -noupdate /tb_ec_siemens_cnc/emcc_mst_top_u/emcc_mix_top_u/ec_siemens_cnc_u0/i_st_wr_data
add wave -noupdate /tb_ec_siemens_cnc/emcc_mst_top_u/emcc_mix_top_u/ec_siemens_cnc_u0/i_st_rd_en
add wave -noupdate /tb_ec_siemens_cnc/emcc_mst_top_u/emcc_mix_top_u/ec_siemens_cnc_u0/i_st_rd_addr
add wave -noupdate /tb_ec_siemens_cnc/emcc_mst_top_u/emcc_mix_top_u/ec_siemens_cnc_u0/proactive_beh_siemens_cnc_u0/a_bhv_id
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11928181761 fs} 0}
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
WaveRestoreZoom {0 fs} {88752984600 fs}
