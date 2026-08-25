connect -url tcp:127.0.0.1:3121
source D:/Vivado_18_3/SDK/2018.3/scripts/sdk/util/zynqmp_utils.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS1 210512180081"} -index 1
rst -system
after 3000
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS1 210512180081"} -index 1
reset_apu
targets -set -filter {jtag_cable_name =~ "Digilent JTAG-HS1 210512180081" && level==0} -index 0
fpga -file C:/Users/keyang/Desktop/Git_cgliu/bykz_v6.0/syn/bykz_base_v6.0/bykz_base_v6.0.runs/impl_1/sunny_fpga.bit
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS1 210512180081"} -index 1
loadhw -hw C:/Users/keyang/Desktop/Git_cgliu/bykz_v6.0/syn/bykz_base_v6.0/bykz_base_v6.0.sdk/emcc_mst_top_hw_platform_0/system.hdf -mem-ranges [list {0x80000000 0xbfffffff} {0x400000000 0x5ffffffff} {0x1000000000 0x7fffffffff}]
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS1 210512180081"} -index 1
source C:/Users/keyang/Desktop/Git_cgliu/bykz_v6.0/syn/bykz_base_v6.0/bykz_base_v6.0.sdk/emcc_mst_top_hw_platform_0/psu_init.tcl
psu_init
after 1000
psu_ps_pl_isolation_removal
after 1000
psu_ps_pl_reset_config
catch {psu_protection}
targets -set -nocase -filter {name =~"*A53*0" && jtag_cable_name =~ "Digilent JTAG-HS1 210512180081"} -index 1
rst -processor
dow C:/Users/keyang/Desktop/Git_cgliu/bykz_v6.0/syn/bykz_base_v6.0/bykz_base_v6.0.sdk/test_ctrl/Debug/test_ctrl.elf
configparams force-mem-access 0
bpadd -addr &main
