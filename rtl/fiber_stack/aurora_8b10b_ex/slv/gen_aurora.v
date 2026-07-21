
`timescale 1 ns / 1 ps

module gen_aurora #
(
     parameter   USE_CORE_TRAFFIC     = 1,
     parameter   USE_CHIPSCOPE        = 0
)
(
    // User IO
     input              RESET
    ,input  wire        INIT_CLK_IN
    ,input              GT_RESET_IN
    ,output reg         HARD_ERR
    ,output reg         SOFT_ERR
    ,output reg         FRAME_ERR

    ,output reg         LANE_UP
    ,output reg         CHANNEL_UP
    // Clocks
    ,input              GT_REFCLK_P
    ,input              GT_REFCLK_N

    // GT Serial I/O
    ,input              RXP
    ,input              RXN
    ,output             TXP
    ,output             TXN

    //to other aurora IP which is not contain share logic
    ,output user_clk_out
    ,output sys_reset_out
    ,output sync_clk_out
    ,output gt_reset_out
    ,output gt_refclk1_out
    ,output pll_not_locked_out
    ,output init_clk_out

    ,output gt0_pll0refclklost_out
    ,output quad1_common_lock_out
    ,output gt0_pll0outclk_out
    ,output gt0_pll1outclk_out
    ,output gt0_pll0outrefclk_out
    ,output gt0_pll1outrefclk_out

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
(* mark_debug = "true" *)wire               pll_not_locked_i;
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
    //Frame check signals

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
   //SLACK Registers
//*********************************Main Body of Code**********************************
    assign  init_clk_i = INIT_CLK_IN;
 
 assign init_clk_out = init_clk_i;
//////////////////////
    assign  user_clk_out = user_clk_i;
    assign  sys_reset_out= system_reset_i;
    assign  pll_not_locked_out =    pll_not_locked_i;

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

    aurora_8b10b_0
    aurora_module_i
    (
        // AXI TX Interface
        .s_axi_tx_tdata(tx_data_i),
        .s_axi_tx_tkeep(tx_tkeep_i),
        .s_axi_tx_tvalid(tx_tvalid_i),
        .s_axi_tx_tlast(tx_tlast_i),
        .s_axi_tx_tready(tx_tready_i),

        // AXI RX Interface
        .m_axi_rx_tdata(rx_data_i),
        .m_axi_rx_tkeep(rx_tkeep_i),
        .m_axi_rx_tvalid(rx_tvalid_i),
        .m_axi_rx_tlast(rx_tlast_i),
        // V5 Serial I/O
        .rxp(RXP),
        .rxn(RXN),
        .txp(TXP),
        .txn(TXN),
        // GT Reference Clock Interface
 
        .gt_refclk1_p(GT_REFCLK_P),
        .gt_refclk1_n(GT_REFCLK_N),
        // Error Detection Interface
        .hard_err(hard_err_i),
        .soft_err(soft_err_i),
        .frame_err(frame_err_i),


        // Status
        .channel_up(channel_up_i),
        .lane_up(lane_up_i),
        // System Interface
        .user_clk_out(user_clk_i),
        .reset(reset_i),
        .sys_reset_out(system_reset_i),
        .power_down(power_down_i),
        .loopback(loopback_vio_o),
        .gt_reset(gtreset_vio_o),
        .tx_lock(tx_lock_i),
        .pll_not_locked_out(pll_not_locked_i),
	.tx_resetdone_out(tx_resetdone_i),
	.rx_resetdone_out(rx_resetdone_i),
        .init_clk_in(init_clk_i),
        .drpclk_in  (init_clk_i),
.drpaddr_in  (daddr_in_i),
.drpen_in    (den_in_i),
.drpdi_in     (di_in_i),
.drprdy_out  (drdy_out_unused_i),
.drpdo_out (drpdo_out_unused_i),
.drpwe_in    (dwe_in_i),
.gt_reset_out    (gt_reset_out ),
.sync_clk_out    (sync_clk_out ),
.gt_refclk1_out  (gt_refclk1_out),
//____________________________COMMON PORTS_______________________________{
.gt0_pll0refclklost_out (gt0_pll0refclklost_out ),
.quad1_common_lock_out (quad1_common_lock_out ),
//----------------------- Channel - Ref Clock Ports ------------------------
.gt0_pll0outclk_out (gt0_pll0outclk_out ),
.gt0_pll1outclk_out (gt0_pll1outclk_out ),
.gt0_pll0outrefclk_out (gt0_pll0outrefclk_out ),
.gt0_pll1outrefclk_out (gt0_pll1outrefclk_out ),
//____________________________COMMON PORTS_______________________________}

        .link_reset_out(link_reset_i)
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

 assign  reset_i =   RESET;
 assign  gtreset_vio_o =   GT_RESET_IN;
 assign  loopback_vio_o =   3'b000;

endmodule
