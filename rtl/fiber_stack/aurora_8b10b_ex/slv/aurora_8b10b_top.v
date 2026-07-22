///////////////////////////////////////////////////////////////////////////////
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
module aurora_8b10b_top #
(

)
(
    // User IO
     input          RESET
    ,output         HARD_ERR_0
    ,output         SOFT_ERR_0
    ,output         FRAME_ERR_0

    ,output         LANE_UP_0
    ,output         CHANNEL_UP_0
    ,input          INIT_CLK_IN
    ,input          GT_RESET_IN
    // Clocks
    ,input          GT_REFCLK_P
    ,input          GT_REFCLK_N
    // GT I/O
    ,input          RXP_0
    ,input          RXN_0
    ,output         TXP_0
    ,output         TXN_0
    //AXI INTF  
    ,output             axi_clk_0
    ,output             axi_clk_rst_0
    ,input   [0:31]     s_axi_tx_tdata_0
    ,input   [0:3]      s_axi_tx_tkeep_0
    ,input              s_axi_tx_tvalid_0
    ,input              s_axi_tx_tlast_0
    ,output             s_axi_tx_tready_0
        //AXI RX
    ,output  [0:31]     m_axi_rx_tdata_0
    ,output  [0:3]      m_axi_rx_tkeep_0
    ,output             m_axi_rx_tvalid_0
    ,output             m_axi_rx_tlast_0
/////////////////////////////////////////////
//    2nd
    ,output         HARD_ERR_1
    ,output         SOFT_ERR_1
    ,output         FRAME_ERR_1
    ,output         LANE_UP_1
    ,output         CHANNEL_UP_1

    ,input          RXP_1
    ,input          RXN_1
    ,output         TXP_1
    ,output         TXN_1

    ,input   [0:31]     s_axi_tx_tdata_1
    ,input   [0:3]      s_axi_tx_tkeep_1
    ,input              s_axi_tx_tvalid_1
    ,input              s_axi_tx_tlast_1
    ,output             s_axi_tx_tready_1
        //AXI RX
    ,output  [0:31]     m_axi_rx_tdata_1
    ,output  [0:3]      m_axi_rx_tkeep_1
    ,output             m_axi_rx_tvalid_1
    ,output             m_axi_rx_tlast_1

);
    
    wire    user_clk_w;
    wire    sys_reset_w;
    wire    sync_clk_w;
    wire    gt_reset_w;
    wire    gt_refclk1_w;
    wire    pll_not_locked_w;
    wire    init_clk_w;

    wire    gt0_pll0refclklost_out;
    wire    quad1_common_lock_out;
    wire    gt0_pll0outclk_out;
    wire    gt0_pll1outclk_out;
    wire    gt0_pll0outrefclk_out;
    wire    gt0_pll1outrefclk_out;

    assign  axi_clk_rst_0   =   sys_reset_w;
    assign  axi_clk_0       =   user_clk_w;

    gen_aurora
        #(
             .USE_CORE_TRAFFIC      (0)
            ,.USE_CHIPSCOPE         (0)
        )
        aurora_8b10b_0_exdes_u
        (
            // User IO
             .RESET         (RESET      )
            ,.HARD_ERR      (HARD_ERR_0   )
            ,.SOFT_ERR      (SOFT_ERR_0   )
            ,.FRAME_ERR     (FRAME_ERR_0  )
        
            ,.LANE_UP       (LANE_UP_0    )
            ,.CHANNEL_UP    (CHANNEL_UP_0 )
            ,.INIT_CLK_IN   (INIT_CLK_IN)
            ,.GT_RESET_IN   (GT_RESET_IN)
        
            ,.GT_REFCLK_P   (GT_REFCLK_P)
            ,.GT_REFCLK_N   (GT_REFCLK_N)
            // GT I/O
            ,.RXP           (RXP_0        )
            ,.RXN           (RXN_0        )
            ,.TXP           (TXP_0        )
            ,.TXN           (TXN_0        )

            ,.user_clk_out  (user_clk_w  )
            ,.sys_reset_out (sys_reset_w )
            ,.sync_clk_out  (sync_clk_w  )
            ,.gt_reset_out  (gt_reset_w  )
            ,.gt_refclk1_out(gt_refclk1_w)
            ,.pll_not_locked_out(pll_not_locked_w)
            ,.init_clk_out      (init_clk_w)

            ,.gt0_pll0refclklost_out    (gt0_pll0refclklost_out)
            ,.quad1_common_lock_out     (quad1_common_lock_out )
            ,.gt0_pll0outclk_out        (gt0_pll0outclk_out    )
            ,.gt0_pll1outclk_out        (gt0_pll1outclk_out    )
            ,.gt0_pll0outrefclk_out     (gt0_pll0outrefclk_out )
            ,.gt0_pll1outrefclk_out     (gt0_pll1outrefclk_out )

            //AXI   INTF
            ,.s_axi_tx_tdata    (s_axi_tx_tdata_0 )
            ,.s_axi_tx_tkeep    (s_axi_tx_tkeep_0 )
            ,.s_axi_tx_tvalid   (s_axi_tx_tvalid_0)
            ,.s_axi_tx_tlast    (s_axi_tx_tlast_0 )
            ,.s_axi_tx_tready   (s_axi_tx_tready_0)
                //AXI RX
            ,.m_axi_rx_tdata    (m_axi_rx_tdata_0 )
            ,.m_axi_rx_tkeep    (m_axi_rx_tkeep_0 )
            ,.m_axi_rx_tvalid   (m_axi_rx_tvalid_0)
            ,.m_axi_rx_tlast    (m_axi_rx_tlast_0 )
        );
    
    gen_aurora_noshare
        #(
             .USE_CORE_TRAFFIC      (0)
            ,.USE_CHIPSCOPE         (0)
        )
        aurora_8b10b_1_exdes_u
        (
            // User IO
             .HARD_ERR      (HARD_ERR_1   )
            ,.SOFT_ERR      (SOFT_ERR_1   )
            ,.FRAME_ERR     (FRAME_ERR_1  )
        
            ,.LANE_UP       (LANE_UP_1    )
            ,.CHANNEL_UP    (CHANNEL_UP_1 )
        
            // GT I/O
            ,.RXP           (RXP_1        )
            ,.RXN           (RXN_1        )
            ,.TXP           (TXP_1        )
            ,.TXN           (TXN_1        )

            ,.user_clk_in  (user_clk_w  )
            ,.sys_reset_in (sys_reset_w )
            ,.sync_clk_in  (sync_clk_w  )
            ,.gt_reset_in  (gt_reset_w  )
            ,.gt_refclk1_in(gt_refclk1_w)
            ,.pll_not_locked_in(pll_not_locked_w)
            ,.init_clk_in      (init_clk_w)

            ,.gt0_pll0refclklost_in    (gt0_pll0refclklost_out)
            ,.quad1_common_lock_in     (quad1_common_lock_out )
            ,.gt0_pll0outclk_in        (gt0_pll0outclk_out    )
            ,.gt0_pll1outclk_in        (gt0_pll1outclk_out    )
            ,.gt0_pll0outrefclk_in     (gt0_pll0outrefclk_out )
            ,.gt0_pll1outrefclk_in     (gt0_pll1outrefclk_out )

            //AXI   INTF
            ,.s_axi_tx_tdata    (s_axi_tx_tdata_1 )
            ,.s_axi_tx_tkeep    (s_axi_tx_tkeep_1 )
            ,.s_axi_tx_tvalid   (s_axi_tx_tvalid_1)
            ,.s_axi_tx_tlast    (s_axi_tx_tlast_1 )
            ,.s_axi_tx_tready   (s_axi_tx_tready_1)
                //AXI RX
            ,.m_axi_rx_tdata    (m_axi_rx_tdata_1 )
            ,.m_axi_rx_tkeep    (m_axi_rx_tkeep_1 )
            ,.m_axi_rx_tvalid   (m_axi_rx_tvalid_1)
            ,.m_axi_rx_tlast    (m_axi_rx_tlast_1 )

        );

endmodule
