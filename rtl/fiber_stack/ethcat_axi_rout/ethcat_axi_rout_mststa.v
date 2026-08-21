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
module ethcat_axi_rout_mststa
(
     input              clk
    ,input              rst
    ,input              downstream_lane_up

    //from app
    ,input  wire            s_app_tx_tvalid
    ,output wire             s_app_tx_tready
    ,input  wire    [3:0]   s_app_tx_tkeep
    ,input  wire            s_app_tx_tlast
    ,input  wire    [31:0]  s_app_tx_tdata

    ,output reg            m_app_rx_tvalid
    ,output reg    [3:0]   m_app_rx_tkeep
    ,output reg            m_app_rx_tlast
    ,output reg    [31:0]  m_app_rx_tdata
    //
    ,output [0:31]      m_axi_tx_tdata_0
    ,output [0:3]       m_axi_tx_tkeep_0
    ,output             m_axi_tx_tvalid_0
    ,output             m_axi_tx_tlast_0
    ,input              m_axi_tx_tready_0
        //AXI RX 0
    ,input  [0:31]      s_axi_rx_tdata_0
    ,input  [0:3]       s_axi_rx_tkeep_0
    ,input              s_axi_rx_tvalid_0
    ,input              s_axi_rx_tlast_0

        //AXI RX 1
    ,input  [0:31]     s_axi_rx_tdata_1
    ,input  [0:3]      s_axi_rx_tkeep_1
    ,input             s_axi_rx_tvalid_1
    ,input             s_axi_rx_tlast_1

);

    always @( * )begin
        if(downstream_lane_up)begin
            m_app_rx_tvalid <=  s_axi_rx_tvalid_0;
            m_app_rx_tkeep  <=  s_axi_rx_tkeep_0;
            m_app_rx_tlast  <=  s_axi_rx_tlast_0;
            m_app_rx_tdata  <=  s_axi_rx_tdata_0;
        end else begin
            m_app_rx_tvalid <=  s_axi_rx_tvalid_1;
            m_app_rx_tkeep  <=  s_axi_rx_tkeep_1;
            m_app_rx_tlast  <=  s_axi_rx_tlast_1;
            m_app_rx_tdata  <=  s_axi_rx_tdata_1;
        end
    end

    assign  m_axi_tx_tvalid_0   =   s_app_tx_tvalid;
    assign  s_app_tx_tready     =   m_axi_tx_tready_0;
    assign  m_axi_tx_tkeep_0    =   s_app_tx_tkeep;
    assign  m_axi_tx_tlast_0    =   s_app_tx_tlast;
    assign  m_axi_tx_tdata_0    =   s_app_tx_tdata;

endmodule
