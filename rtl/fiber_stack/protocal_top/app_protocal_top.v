
module app_protocal_top
#(
    parameter  WOKE_MODE   = "MAST"
)
(
     input                  clk
    ,input                  reset
    // master mode systerm signal
    ,input                  app_trsf_en         //application transfer enable
    ,input                  mst_sta_restart     //master station restart control signal.
    ,input  wire    [15:0]  each_dg_length      //indicate that each datagram length
    ,output wire            app_err_flag        //the error type of slave station is valid
    ,output wire    [7:0]   app_err_type        //the error type of slave station
    ,output wire    [7:0]   hb_err_slvsta       //no use
    ,output wire            mst_prcs_hb_flag
    ,output wire            mst_sta_trsf_flag
    ,output wire    [7:0]   slv_sta_num         //this signals only update during first initial datagram.It indicate the number of slave station
    ,input  wire            loop_link_success
    ,output wire            ping_pong_flag
    
    ,output wire            prot_send_req
    ,input  wire            prot_send_ack
    ,output wire            prot_rcv_req
    ,input  wire            prot_rcv_ack
	
	,input wire             init_error
    ,input              downstream_lane_up
    ,input              downstream_link
    //slave mode systerm signal
    ,output         [1:0]   slvsta_rcv_hb_flag  //slave station receive heartbeat flag[1:0]
                                                    //[1bit]: receive hb fram; [0]:check slave station address is match
    ,input                  slvsta_id_vld
    ,input          [31:0]  slvsta_id           //slave station id
    ,output wire    [7:0]   cfg_sta_addr        //the slave station address which is configed by master station
    ,output wire    [15:0]  cur_slv_dg_beat     //current slave station datagram beat number

    //interface between application depot
    ,output wire    [3:0]   app_wr_en
    ,output wire    [31:0]  app_wr_data
    ,output                 app_rd_en
    ,output         [15:0]  app_rd_addr
    ,input          [31:0]  app_rd_data

    ,output wire    [3:0]   slv_id_we
    ,output wire    [15:0]  slv_id_addr
    ,output wire    [31:0]  slv_id_din
    ,output wire    [31:0]  slv_fpga_version
	
	,input  wire            init_err_clr
	,output wire            init_err
	,input  wire            cnt_err_clr
	,output wire	[31:0]  cnt_err
	,output wire			init_finish

    //master AXI interface to aurora IP:send port
    ,output                 m_boroa_tx_tvalid
    ,input                  m_boroa_tx_tready
    ,output         [3:0]   m_boroa_tx_tkeep
    ,output                 m_boroa_tx_tlast
    ,output         [31:0]  m_boroa_tx_tdata

    //slave AXI receive interface
    ,input  wire            s_aurora_rx_tvalid
    ,input  wire    [3:0]   s_aurora_rx_tkeep
    ,input  wire            s_aurora_rx_tlast
    ,input  wire    [31:0]  s_aurora_rx_tdata
);
    
    wire            pkg_trsf_start;     //protocol layer indicate that ethcat layer could transfer datagram.
    //the axi master tx port: form datagram layser to ethercat layer
    wire            m_app_tx_tvalid;
    wire            m_app_tx_tready;
    wire            m_app_tx_sop;
    wire            m_app_tx_eop;
    wire    [31:0]  m_app_tx_tdata;
    //local logic bus of ethercat layer frame buffer.
    wire    [3:0]   cache_we;
    wire    [15:0]  cache_addr;
    wire    [31:0]  cache_din;
    wire    [31:0]  cache_dout;
    //these signal that receive chanel has receive datagram and cac is pass
    wire            rx_crc_vld;
    wire            rx_crc_pass;
    //the app tell ethcat layer which type tx datagramis
    wire    [3:0]   ethcat_tx_type;
    wire    [15:0]  ethcat_tx_len;
    //the app tell datagram layer the content of datagram head
    wire    [7:0]   datagram_tx_cmd;
    wire    [15:0]  datagram_tx_len;
    wire    [7:0]   datagram_tx_num;
    //heartbeat datagram dst address
    wire   [31:0]   dg_hb_dst_addr;
    //axi stream interface whic is only used to transfer the content which is cached in
    //eth_cat buffer,these signal is only used by slave mode.
    wire            m_slvsta_tx_sof;
    wire            m_slvsta_tx_eof;
    wire            m_slvsta_tx_tvalid;
    wire    [31:0]  m_slvsta_tx_tdata;
    
    wire            depot_rden_mst;
    wire            depot_rden_slv;
    wire    [15:0]  depot_addr;
    wire    [15:0]  app_rd_addr_w;
    wire    [16:0]  datagram_tx_uuid;
    wire            prot_send_req_mst;
    wire            prot_send_ack_mst;
    wire            prot_send_req_slv;
    wire            prot_send_ack_slv;

    generate
        if(WOKE_MODE ==  "MAST") begin:MAST
            assign  app_rd_addr =   (app_wr_en !== 0) ? depot_addr : app_rd_addr_w;
            assign  prot_send_req       =   prot_send_req_mst;
            assign  prot_send_ack_mst   =   prot_send_ack;
            assign  app_rd_en           =   depot_rden_mst;
        end else begin:SLAVE
            assign  app_rd_addr =   depot_addr;
            assign  prot_send_req       =   prot_send_req_slv;
            assign  prot_send_ack_slv   =   prot_send_ack;
            assign  app_rd_en           =   depot_rden_slv;
        end
    endgenerate

    app_ctrl_top
    #(
        .WOKE_MODE      (WOKE_MODE  )
    )
        app_ctrl_top_u
        (
             .clk                   (clk                )
            ,.reset                 (reset              )
            
            // mater mode systerm signal
            ,.app_trsf_en           (app_trsf_en        )
            ,.mst_sta_restart       (mst_sta_restart    )
            ,.each_dg_length        (each_dg_length     )
            ,.app_err_flag          (app_err_flag       )
            ,.app_err_type          (app_err_type       )
            ,.hb_err_slvsta         (hb_err_slvsta      )
            ,.mst_prcs_hb_flag      (mst_prcs_hb_flag   )
            ,.mst_sta_trsf_flag     (mst_sta_trsf_flag  )
            ,.slv_sta_num           (slv_sta_num        )
            ,.loop_link_success     (loop_link_success  )
            ,.ping_pong_flag        (ping_pong_flag     )
            
            ,.prot_rcv_req      (prot_rcv_req       )
            ,.prot_rcv_ack      (prot_rcv_ack       )
			
			,.init_err_clr		(init_err_clr)
			,.init_err			(init_err)
			,.cnt_err_clr		(cnt_err_clr)
			,.cnt_err			(cnt_err)
			,.init_finish		(init_finish)

            ,.prot_send_req     (prot_send_req_slv      )
            ,.prot_send_ack     (prot_send_ack_slv      )
            //slave mode systerm signal
                //indicate heartbeat type
            ,.slvsta_rcv_hb_flag    (slvsta_rcv_hb_flag )
                //current slave station id
            ,.slvsta_id_vld         (slvsta_id_vld      )
            ,.slvsta_id             (slvsta_id          )
            ,.cfg_sta_addr          (cfg_sta_addr       )
            ,.cur_slv_dg_beat       (cur_slv_dg_beat    )
                //notice datagram could transfer datagram
            ,.pkg_trsf_start        (pkg_trsf_start     )
                //datagram head message
            ,.datagram_tx_cmd       (datagram_tx_cmd    )
            ,.datagram_tx_len       (datagram_tx_len    )
            ,.datagram_tx_num       (datagram_tx_num    )
            ,.datagram_tx_uuid      (datagram_tx_uuid   )
                //ethercat head message
            ,.ethcat_tx_type        (ethcat_tx_type     )
            ,.ethcat_tx_len         (ethcat_tx_len      )
                //this signal is only used by hearbeat,which is used to indicate
                //what is dst_addr message in heartbeat datagram layer.
            ,.dg_hb_dst_addr        (dg_hb_dst_addr     )
			,.init_error		(init_error			)
                    ,.downstream_lane_up(downstream_lane_up)
                    ,.downstream_link   (downstream_link   )
            
                //app layer ll interface with application depot
            ,.depot_rden        (depot_rden_slv)
            ,.depot_we          (app_wr_en           )
            ,.depot_addr        (depot_addr         )
            ,.depot_din         (app_wr_data          )
            ,.depot_dout        (app_rd_data)

            ,.slv_id_we         (slv_id_we          )
            ,.slv_id_addr       (slv_id_addr        )
            ,.slv_id_din        (slv_id_din         )
            ,.slv_fpga_version  (slv_fpga_version   )

                //ll interface which is used between app layer and ethcat layer
            ,.cache_we              (cache_we           )
            ,.cache_addr            (cache_addr         )
            ,.cache_din             (cache_din          )
            ,.cache_dout            (cache_dout         )
                //ecat notice that one ethercat frame has been received and cac is pass
            ,.rx_crc_vld            (rx_crc_vld         )
            ,.rx_crc_pass           (rx_crc_pass        )
                //only used by slave mode,which are used to transfer complete package to ethcater tx buffer
            ,.m_slvsta_tx_sof     (m_slvsta_tx_sof      )
            ,.m_slvsta_tx_eof     (m_slvsta_tx_eof      )
            ,.m_slvsta_tx_tvalid  (m_slvsta_tx_tvalid   )
            ,.m_slvsta_tx_tdata   (m_slvsta_tx_tdata    )
    );

    datagram_top
        datagram_top_u
        (
             .clk                   (clk    )
            ,.reset                 (reset  )
            //indicate that one datagram could been transfer
            ,.pkg_trsf_start        (pkg_trsf_start)
            //head content
            ,.ethcat_tx_type        (ethcat_tx_type )
            ,.datagram_tx_cmd       (datagram_tx_cmd)
            ,.datagram_tx_len       (datagram_tx_len)
            ,.datagram_tx_num       (datagram_tx_num)
            ,.datagram_tx_uuid      (datagram_tx_uuid)
            ,.prot_send_req         (prot_send_req_mst    )
            ,.prot_send_ack         (prot_send_ack_mst    )
            //current station's address,which is only used by heart beat
            ,.dg_hb_dst_addr        (dg_hb_dst_addr )
            //ll bus between datagram layer and top app depot
            ,.app_rd_en             (depot_rden_mst      )
            ,.app_rd_addr           (app_rd_addr_w  )
            ,.app_rd_data           (app_rd_data    )
            //axi stream to ethercat layer
            ,.m_app_tx_tvalid       (m_app_tx_tvalid)
            ,.m_app_tx_tready       (m_app_tx_tready)
            ,.m_app_tx_sop          (m_app_tx_sop   )
            ,.m_app_tx_eop          (m_app_tx_eop   )
            ,.m_app_tx_tdata        (m_app_tx_tdata)
        );

    ethcat_top
    #(
        .WOKE_MODE      (WOKE_MODE  )
    )
        ethcat_top_u
        (
             .clk                   (clk)
            ,.reset                 (reset)
            //ethercat head content
            ,.ethcat_tx_type        (ethcat_tx_type     )
            ,.ethcat_tx_len         (ethcat_tx_len      )
            //axi stream interface is used to transfer tx package
            ,.s_app_tx_tvalid       (m_app_tx_tvalid    )
            ,.s_app_tx_tready       (m_app_tx_tready    )
            ,.s_app_tx_sop          (m_app_tx_sop       )
            ,.s_app_tx_eop          (m_app_tx_eop       )
            ,.s_app_tx_tdata        (m_app_tx_tdata     )

            //ethercat layer cache ll bus,this cache stored full content of one package
            ,.cache_we              (cache_we           )
            ,.cache_addr            (cache_addr         )
            ,.cache_din             (cache_din          )
            ,.cache_dout            (cache_dout         )
            //crc valid and crc result
            ,.rx_crc_vld            (rx_crc_vld         )
            ,.rx_crc_pass           (rx_crc_pass        )
            //only used by slave mode,which is used to recive the package,
            //and transfer this package to aurora IP
            ,.s_slvsta_tx_sof     (m_slvsta_tx_sof      )
            ,.s_slvsta_tx_eof     (m_slvsta_tx_eof      )
            ,.s_slvsta_tx_tvalid  (m_slvsta_tx_tvalid   )
            ,.s_slvsta_tx_tdata   (m_slvsta_tx_tdata    )

            //axi stream interface to aurora IP
            ,.m_boroa_tx_tvalid     (m_boroa_tx_tvalid)
            ,.m_boroa_tx_tready     (m_boroa_tx_tready)
            ,.m_boroa_tx_tkeep      (m_boroa_tx_tkeep)
            ,.m_boroa_tx_tlast      (m_boroa_tx_tlast)
            ,.m_boroa_tx_tdata      (m_boroa_tx_tdata)

            //axi stream rx interface from aurora IP
            ,.s_aurora_rx_tvalid    (s_aurora_rx_tvalid)
            ,.s_aurora_rx_tkeep     (s_aurora_rx_tkeep )
            ,.s_aurora_rx_tlast     (s_aurora_rx_tlast )
            ,.s_aurora_rx_tdata     (s_aurora_rx_tdata )
        );
    
endmodule
