#-------------------------------------------------------------
# Generated Example Tcl script for IP 'aurora_8b10b_1' (xilinx.com:ip:aurora_8b10b:11.1)
#-------------------------------------------------------------

# Set up project params
set_param tcl.collectionResultDisplayLimit 0
set_param xicom.use_bs_reader 1
# Declare source IP directory
set srcIpDir "e:/develop/emcc_slv/emcc_mst.srcs/sources_1/ip/aurora_8b10b_1"

# Create project
puts "INFO: \[open_example_project\] Creating new example project..."
create_project -name aurora_8b10b_1_ex -force
set_property part xc7a75tfgg484-2 [current_project]
set_property target_language verilog [current_project]
set_property simulator_language MIXED [current_project]
set_property coreContainer.enable false [current_project]
# Set up imports directory
set projDir [get_property DIRECTORY [current_project]]
set importDir [file join $projDir imports]
file mkdir $importDir

set returnCode 0

# Set up pre-compilation paths
set_property compxlib.modelsim_compiled_library_dir {D:/modeltech64_10.5/lib/vivado_2018p3} [current_project]

# Import the original IP (excluding example files)
puts "INFO: \[open_example_project\] Importing original IP ..."
import_ip -files [list [file join $srcIpDir aurora_8b10b_1.xci]] -name aurora_8b10b_1
reset_target {open_example} [get_ips aurora_8b10b_1]

# Generate the IP
proc _filter_supported_targets {targets ip} {
  set res {}
  set all [get_property SUPPORTED_TARGETS $ip]
  foreach target $targets {
    lappend res {*}[lsearch -all -inline -nocase $all $target]
  }
  return $res
}
puts "INFO: \[open_example_project\] Generating the example project IP ..."
generate_target -quiet [_filter_supported_targets {instantiation_template synthesis simulation implementation shared_logic} [get_ips aurora_8b10b_1]] [get_ips aurora_8b10b_1]

# Add example synthesis HDL files
puts "INFO: \[open_example_project\] Adding example synthesis HDL files ..."
add_files -quiet -copy_to $importDir -fileset [current_fileset] \
  [list [file join $srcIpDir aurora_8b10b_1/example_design/aurora_8b10b_1_axi_to_ll_exdes.v]] \
  [list [file join $srcIpDir aurora_8b10b_1/example_design/aurora_8b10b_1_ll_to_axi_exdes.v]] \
  [list [file join $srcIpDir aurora_8b10b_1/example_design/aurora_8b10b_1_cdc_sync_exdes.v]] \
  [list [file join $srcIpDir aurora_8b10b_1/example_design/aurora_8b10b_1_exdes.v]] \
  [list [file join $srcIpDir aurora_8b10b_1/example_design/traffic_gen_check/aurora_8b10b_1_frame_check.v]] \
  [list [file join $srcIpDir aurora_8b10b_1/example_design/traffic_gen_check/aurora_8b10b_1_frame_gen.v]] \
  [list [file join $srcIpDir aurora_8b10b_1/example_design/support/aurora_8b10b_1_support.v]] \
  [list [file join $srcIpDir aurora_8b10b_1/example_design/support/aurora_8b10b_1_gt_common_wrapper.v]] \
  [list [file join $srcIpDir aurora_8b10b_1/example_design/support/aurora_8b10b_1_support_reset_logic.v]] \
  [list [file join $srcIpDir aurora_8b10b_1/example_design/support/aurora_8b10b_1_clock_module.v]]

# Add example XDC files
puts "INFO: \[open_example_project\] Adding example XDC files ..."
add_files -quiet -copy_to $importDir -fileset [current_fileset -constrset] \
  [list [file join $srcIpDir aurora_8b10b_1/example_design/aurora_8b10b_1_exdes.xdc]]


# Add example simulation HDL files
puts "INFO: \[open_example_project\] Adding simulation HDL files ..."
if { [catch {current_fileset -simset} exc] } { create_fileset -simset sim_1 }
add_files -quiet -copy_to $importDir -fileset [current_fileset -simset] \
  [list [file join $srcIpDir aurora_8b10b_1/simulation/aurora_8b10b_1_tb.v]]
set_property USED_IN_SYNTHESIS false [get_files [list [file join $importDir aurora_8b10b_1_tb.v]]]

# Set top
set_property TOP [lindex [find_top] 0] [current_fileset]

# Update compile order
update_compile_order -fileset [current_fileset]
update_compile_order -fileset [current_fileset -simset]
set tops [list]
foreach tfile [ get_files -filter {name=~"*.xci" || name=~"*.bdj" || name=~"*.bd"}] { if { [lsearch [list_property $tfile] PARENT_COMPOSITE_FILE ] == -1} {lappend tops $tfile} }
puts "INFO: \[open_example_project\] Rebuilding all the top level IPs ..."
generate_target all $tops
export_ip_user_files -force

set dfile [file join $srcIpDir oepdone.txt]
if { [ catch { set doneFile [open $dfile w] } ] } {
} else { 
  puts $doneFile "Open Example Project DONE"
  close $doneFile
}
if { $returnCode != 0 } {
  puts "ERROR: \[open_example_project\] Problems were encountered while executing the example design script, please review the log file."
  error "ERROR: See log file for details."
  incr returnCode
} else {
  puts "INFO: \[open_example_project\] Open Example Project completed"
}
