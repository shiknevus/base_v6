onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_spi_module/spi_module_u0/i_clk
add wave -noupdate /tb_spi_module/spi_module_u0/i_rst
add wave -noupdate -color Coral /tb_spi_module/spi_module_u0/o_spi_csn
add wave -noupdate -color Coral /tb_spi_module/spi_module_u0/o_spi_clk
add wave -noupdate -color Coral /tb_spi_module/spi_module_u0/o_spi_mosi
add wave -noupdate /tb_spi_module/spi_module_u0/i_spi_miso
add wave -noupdate -radix binary /tb_spi_module/spi_module_u0/i_tx_da
add wave -noupdate /tb_spi_module/spi_module_u0/i_tx_vld
add wave -noupdate /tb_spi_module/spi_module_u0/o_spi_busy
add wave -noupdate /tb_spi_module/spi_module_u0/o_rx_da
add wave -noupdate /tb_spi_module/spi_module_u0/o_rx_vld
add wave -noupdate /tb_spi_module/spi_module_u0/curr_sta
add wave -noupdate /tb_spi_module/spi_module_u0/next_sta
add wave -noupdate /tb_spi_module/spi_module_u0/run
add wave -noupdate /tb_spi_module/spi_module_u0/ri_tx_da
add wave -noupdate /tb_spi_module/spi_module_u0/cnt_div
add wave -noupdate -radix decimal /tb_spi_module/spi_module_u0/cnt_sck
add wave -noupdate /tb_spi_module/spi_module_u0/posedge_sck
add wave -noupdate /tb_spi_module/spi_module_u0/negedge_sck
add wave -noupdate /tb_spi_module/spi_module_u0/run_1d
add wave -noupdate /tb_spi_module/spi_module_u0/cnt_delay
add wave -noupdate /tb_spi_module/spi_module_u0/run_negedge
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13931627 ps} 0}
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
WaveRestoreZoom {2479332 ps} {22410257 ps}
