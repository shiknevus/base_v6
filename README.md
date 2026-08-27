# bykz_base_v6.0
Run the  ../tool/mklinks.bat script before simulation and compilation.

Must select .xpr to start vivado gui when miklinks.bat while running.

Please clone project into the second-level directory of the drive, likes "./../project".

Please set Simulation Compiled library location before Run Simulation. 

mst_project(MPSoC xczu5eg):`syn/bykz_base_v6.0.xpr`,Top=`emcc_mst_top`(rtl/top/emcc_mst_top.sv).

slv_project(7series xc7a75t):`syn/bykz_base_slave_v6.0.xpr`,Top=`emcc_slv_top`(rtl/top/emcc_slv_top.v).