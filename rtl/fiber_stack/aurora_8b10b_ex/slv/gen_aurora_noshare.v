///////////////////////////////////////////////////////////////////////////////
// (c) Copyright 2008 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//
///////////////////////////////////////////////////////////////////////////////
//
//  AURORA_EXAMPLE
//
//  Aurora Generator
//
//
//  Description: Sample Instantiation of a 1 4-byte lane module.
//               Only tests initialization in hardware.
//
//        
`timescale 1 ns / 1 ps
(* core_generation_info = "aurora_8b10b_0,aurora_8b10b_v11_1_6,{user_interface=AXI_4_Streaming,backchannel_mode=Sidebands,c_aurora_lanes=1,c_column_used=left,c_gt_clock_1=GTHQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=31250,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=125000,c_simplex=false,c_simplex_mode=TX,c_stream=false,c_ufc=false,flow_mode=None,interface_mode=Framing,dataflow_config=Duplex}" *)
(* DowngradeIPIdentifiedWarnings="yes" *)
module gen_aurora_noshare #
(
     parameter   USE_CORE_TRAFFIC     = 1,
     parameter   USE_CHIPSCOPE        = 0
)
(
    // User IO
     output reg         HARD_ERR
    ,output reg         SOFT_ERR
    ,output reg         FRAME_ERR

    ,output reg         LANE_UP
    ,output reg         CHANNEL_UP

    // GT I/O
    ,input              RXP
    ,input              RXN
    ,output             TXP
    ,output             TXN

    ,input              user_clk_in
    ,input              sys_reset_in
    ,input              sync_clk_in
    ,input              gt_reset_in
    ,input              gt_refclk1_in
    ,input              pll_not_locked_in
    ,input              init_clk_in

    ,input              gt0_pll0refclklost_in
    ,input              quad1_common_lock_in 
    ,input              gt0_pll0outclk_in    
    ,input              gt0_pll1outclk_in    
    ,input              gt0_pll0outrefclk_in 
    ,input              gt0_pll1outrefclk_in 

    //AXI INTERFACE
        //AXI TX
    ,input   [0:31]     s_axi_tx_tdata
    ,input   [0:3]      s_axi_tx_tkeep
    ,input              s_axi_tx_tvalid
    ,input              s_axi_tx_tlast
    ,output             s_axi_tx_tready
        //AXI RX
    ,output  [0:31]     m_axi_rx_tdata
    ,output  [0:3]      m_axi_rx_tkeep
    ,output             m_axi_rx_tvalid
    ,output             m_axi_rx_tlast

);

//********************************Wire Declarations**********************************

    // Error Detection Interface
(* mark_debug = "true" *)wire               hard_err_i;
(* mark_debug = "true" *)wire               soft_err_i;
(* mark_debug = "true" *)wire               frame_err_i;
    // Status
(* mark_debug = "true" *)wire               channel_up_i;
(* mark_debug = "true" *)wire               lane_up_i;
    // System Interface
wire               user_clk_i;
wire               reset_i;
wire               power_down_i;
wire               tx_lock_i;
(* mark_debug = "true" *)wire               link_reset_i;
(* mark_debug = "true" *)wire               tx_resetdone_i;
(* mark_debug = "true" *)wire               rx_resetdone_i;
(* KEEP = "TRUE" *) wire               init_clk_i;
wire    [8:0]     daddr_in_i;
wire              dclk_in_i;
wire              den_in_i;
wire    [15:0]    di_in_i;
wire              drdy_out_unused_i;
wire    [15:0]    drpdo_out_unused_i;
wire              dwe_in_i;


(* mark_debug = "true" *)wire               system_reset_i;
wire               gtreset_vio_o;
wire    [2:0]      loopback_vio_o;


wire               tied_to_ground_i;
wire    [0:31]     tied_to_gnd_vec_i;
    // TX AXI PDU I/F wires
wire    [0:31]     tx_data_i;
wire               tx_tvalid_i;
wire               tx_tready_i;
wire    [0:3]      tx_tkeep_i;
wire               tx_tlast_i;

    // RX AXI PDU I/F wires
wire    [0:31]     rx_data_i;
wire               rx_tvalid_i;
wire    [0:3]      rx_tkeep_i;
wire               rx_tlast_i;
   wire  drpclk_i;
//*********************************Main Body of Code**********************************
    assign  init_clk_i = init_clk_in;

//____________________________Register User I/O___________________________________
// Register User Outputs from core.

    always @(posedge user_clk_i)
    begin
        HARD_ERR      <=  hard_err_i;
        SOFT_ERR      <=  soft_err_i;
        FRAME_ERR     <=  frame_err_i;
        LANE_UP         <=  lane_up_i;
        CHANNEL_UP      <=  channel_up_i;
    end

//____________________________Tie off unused signals_______________________________

    // System Interface
    assign          tied_to_ground_i        = 1'b0;
    assign  tied_to_gnd_vec_i   =   32'd0;
    assign  power_down_i        =   1'b0;


assign  daddr_in_i  =  9'h0;
assign  den_in_i    =  1'b0;
assign  di_in_i     =  16'h0;
assign  dwe_in_i    =  1'b0;
//___________________________Module Instantiations_________________________________
assign  user_clk_i = user_clk_in;

    aurora_8b10b_1 aurora_8b10b_1_i
         (
            // AXI TX Interface
           .s_axi_tx_tdata               (tx_data_i),
           .s_axi_tx_tkeep               (tx_tkeep_i),
           .s_axi_tx_tvalid              (tx_tvalid_i),
           .s_axi_tx_tlast               (tx_tlast_i),
           .s_axi_tx_tready              (tx_tready_i),

            // AXI RX Interface
           .m_axi_rx_tdata               (rx_data_i),
           .m_axi_rx_tkeep               (rx_tkeep_i),
           .m_axi_rx_tvalid              (rx_tvalid_i),
           .m_axi_rx_tlast               (rx_tlast_i),


            // GT Serial I/O
           .rxp                          (RXP),
           .rxn                          (RXN),
           .txp                          (TXP),
           .txn                          (TXN),

            // GT Reference Clock Interface
           .gt_refclk1                   (gt_refclk1_in),
            // Error Detection Interface
           .frame_err                    (frame_err_i),

            // Error Detection Interface
           .hard_err                     (hard_err_i),
           .soft_err                     (soft_err_i),

            // Status
           .channel_up                   (channel_up_i),
           .lane_up                      (lane_up_i),




            // System Interface
           .user_clk                     (user_clk_in),
           .sync_clk                     (sync_clk_in),
           .reset                        (reset_i),
           .power_down                   (power_down_i),
           .loopback                     (loopback_vio_o),
           .gt_reset                     (gtreset_vio_o),
           .tx_lock                      (tx_lock_i),
//       .bufg_gt_clr_out              (bufg_gt_clr_int),
           .init_clk_in                  (init_clk_i),
           .pll_not_locked               (pll_not_locked_in),
           .tx_resetdone_out             (tx_resetdone_i),
           .rx_resetdone_out             (rx_resetdone_i),
           .link_reset_out               (link_reset_i),
       .drpclk_in                    (init_clk_i ),
       .drpaddr_in                   (daddr_in_i),
       .drpen_in                     (den_in_i),
       .drpdi_in                     (di_in_i),
       .drprdy_out                   (drdy_out_unused_i),
       .drpdo_out                    (drpdo_out_unused_i),
       .drpwe_in                     (dwe_in_i),

//------------------{
.gt_common_reset_out ( ),
//____________________________COMMON PORTS_______________________________{
.gt0_pll0refclklost_in (gt0_pll0refclklost_in ),
.quad1_common_lock_in (quad1_common_lock_in ),
//----------------------- Channel - Ref Clock Ports ------------------------
.gt0_pll0outclk_in (gt0_pll0outclk_in ),
.gt0_pll1outclk_in (gt0_pll1outclk_in ),
.gt0_pll0outrefclk_in (gt0_pll0outrefclk_in ),
.gt0_pll1outrefclk_in (gt0_pll1outrefclk_in ),
//____________________________COMMON PORTS_______________________________}
//------------------}


           .sys_reset_out                (system_reset_i),
           .tx_out_clk                   (tx_out_clk_i)

         );

     //define traffic generation modules here
    assign  tx_data_i   =   s_axi_tx_tdata;
    assign  tx_tkeep_i  =   s_axi_tx_tkeep;
    assign  tx_tvalid_i =   s_axi_tx_tvalid;
    assign  tx_tlast_i  =   s_axi_tx_tlast;
    assign  s_axi_tx_tready =   tx_tready_i;
        //AXI RX
    assign  m_axi_rx_tdata   =  rx_data_i;
    assign  m_axi_rx_tkeep   =  rx_tkeep_i;
    assign  m_axi_rx_tvalid  =  rx_tvalid_i;
    assign  m_axi_rx_tlast   =  rx_tlast_i;


 assign  reset_i =   sys_reset_in;
 assign  gtreset_vio_o =   gt_reset_in;
 assign  loopback_vio_o =   3'b000;

endmodule
