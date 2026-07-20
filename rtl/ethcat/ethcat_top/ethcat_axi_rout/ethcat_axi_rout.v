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
module ethcat_axi_rout #
(

)
(
     input              clk
    ,input              rst
    ,input              downstream_lane_up
    ,input              downstream_link
    //from app
    ,input  wire            s_app_tx_tvalid
    ,output reg             s_app_tx_tready
    ,input  wire    [3:0]   s_app_tx_tkeep
    ,input  wire            s_app_tx_tlast
    ,input  wire    [31:0]  s_app_tx_tdata

    ,output wire            m_app_rx_tvalid
    ,output wire    [3:0]   m_app_rx_tkeep
    ,output wire            m_app_rx_tlast
    ,output wire    [31:0]  m_app_rx_tdata

    //AXI INTF  upstream
    ,(* MARK_DEBUG="true" *)output [0:31]      m_axi_tx_tdata_0
    ,(* MARK_DEBUG="true" *)output [0:3]       m_axi_tx_tkeep_0
    ,(* MARK_DEBUG="true" *)output             m_axi_tx_tvalid_0
    ,(* MARK_DEBUG="true" *)output             m_axi_tx_tlast_0
    ,(* MARK_DEBUG="true" *)input              m_axi_tx_tready_0
        //AXI RX
    ,input  [0:31]      s_axi_rx_tdata_0
    ,input  [0:3]       s_axi_rx_tkeep_0
    ,input              s_axi_rx_tvalid_0
    ,input              s_axi_rx_tlast_0

    //AXI INTF downstream
    ,output   [0:31]    m_axi_tx_tdata_1
    ,output   [0:3]     m_axi_tx_tkeep_1
    ,output             m_axi_tx_tvalid_1
    ,output             m_axi_tx_tlast_1
    ,input              m_axi_tx_tready_1
        //AXI RX
    ,(* MARK_DEBUG="true" *)input  [0:31]     s_axi_rx_tdata_1
    ,(* MARK_DEBUG="true" *)input  [0:3]      s_axi_rx_tkeep_1
    ,(* MARK_DEBUG="true" *)input             s_axi_rx_tvalid_1
    ,(* MARK_DEBUG="true" *)input             s_axi_rx_tlast_1

);
    assign  m_app_rx_tvalid =   s_axi_rx_tvalid_0;
    assign  m_app_rx_tkeep  =   s_axi_rx_tkeep_0;
    assign  m_app_rx_tlast  =   s_axi_rx_tlast_0;
    assign  m_app_rx_tdata  =   s_axi_rx_tdata_0;
    
    assign  m_axi_tx_tdata_1    =   downstream_lane_up ? s_app_tx_tdata : 'd0;
    assign  m_axi_tx_tkeep_1    =   downstream_lane_up ? s_app_tx_tkeep : 'd0;
    assign  m_axi_tx_tvalid_1   =   downstream_lane_up ? s_app_tx_tvalid : 'd0;
    assign  m_axi_tx_tlast_1    =   downstream_lane_up ? s_app_tx_tlast : 'd0;

    reg         m_cache_tvalid;
    wire        m_cache_tready;
    reg [3:0]   m_cache_tkeep;
    reg         m_cache_tlast;
    reg [31:0]  m_cache_tdata;
    always @( * )begin
        if(downstream_lane_up)begin
            m_cache_tvalid  <=  s_axi_rx_tvalid_1;
            m_cache_tkeep   <=  s_axi_rx_tkeep_1;
            m_cache_tlast   <=  s_axi_rx_tlast_1;
            m_cache_tdata   <=  s_axi_rx_tdata_1;
        end else begin
            m_cache_tvalid  <=  s_app_tx_tvalid;
            m_cache_tkeep   <=  s_app_tx_tkeep;
            m_cache_tlast   <=  s_app_tx_tlast;
            m_cache_tdata   <=  s_app_tx_tdata;
        end
    end

    always @( * )begin
        if(downstream_lane_up)begin
            s_app_tx_tready <=   downstream_link ? m_axi_tx_tready_1 : 1;//while link is not bulid,asserting s_app_tx_tready high is ordet to clear protocol_send cache.
        end else begin
            s_app_tx_tready <=  m_cache_tready;
        end
    end

    axi_cache
        axi_cache_u
        (
             .clk           (clk    )
            ,.reset         (rst    )

            ,.s_axi_tvalid  (m_cache_tvalid  )
            ,.s_axi_tready  (m_cache_tready )
            ,.s_axi_tkeep   (m_cache_tkeep   )
            ,.s_axi_tlast   (m_cache_tlast   )
            ,.s_axi_tdata   (m_cache_tdata   )

            ,.m_axi_tvalid  (m_axi_tx_tvalid_0)
            ,.m_axi_tready  (m_axi_tx_tready_0)
            ,.m_axi_tkeep   (m_axi_tx_tkeep_0)
            ,.m_axi_tlast   (m_axi_tx_tlast_0)
            ,.m_axi_tdata   (m_axi_tx_tdata_0)
        );

endmodule
