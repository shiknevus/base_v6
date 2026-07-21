/////////////////////////////////////////////////////////////////
// Company:
// Engineer:      Huaye Zhang
// Creat Date:    
// Design Name:   
// Module Name:   
// Project Name:  
// Target Devices:
// Tool versions:
//                
// Dependencies:
//    
//
//Description:
//
/////////////////////////////////////////////////////////////////
module app_ctrl_top
#(
    parameter  WOKE_MODE   = "MAST"
)
(
     input                  clk
    ,input                  reset
    
    // mater mode systerm signal
    ,input                  app_trsf_en     //application transfer enable
    ,input                  mst_sta_restart //master station transfer restart,only active on rise edge
    ,input  wire    [15:0]  each_dg_length  //PS config each datagram length
    ,output wire            app_err_flag    //the error type of slave station is valid
    ,output wire    [15:0]  app_err_type    //the error type of slave station
    ,output wire    [15:0]  hb_err_slvsta       //indicate the index of the error station
    ,output wire            mst_prcs_hb_flag
    ,output reg             mst_sta_trsf_flag
    ,output wire    [7:0]   slv_sta_num         //this signals only update during first initial datagram.It indicate the number of slave station
    ,input  wire            loop_link_success
    ,output wire            ping_pong_flag

    ,output wire            prot_rcv_req
    ,input  wire            prot_rcv_ack

    ,output wire            prot_send_req
    ,input  wire            prot_send_ack

    //slave mode systerm signal
    ,output         [1:0]   slvsta_rcv_hb_flag  //indicate heartbeat type
    ,input                  slvsta_id_vld
    ,input          [31:0]  slvsta_id           //
    ,output wire    [7:0]   cfg_sta_addr        //the slave station address which is configed by master station
    ,output wire    [15:0]  cur_slv_dg_beat     //current slave station datagram beat number

    
    //down layer config signals
    ,output                 pkg_trsf_start      //APP notice datagram layer could transfer datagram
    ,input  wire            rx_crc_vld          //ecat notice that one ethercat frame has been received and cac is pass
    ,input  wire            rx_crc_pass
        //ethcat header content
    ,output         [3:0]   ethcat_tx_type
    ,output         [15:0]  ethcat_tx_len
        //datagram header content
    ,output         [7:0]   datagram_tx_cmd
    ,output         [15:0]  datagram_tx_len
    ,output         [7:0]   datagram_tx_num
    ,output         [16:0]  datagram_tx_uuid
        //this signal is only used by hearbeat,which is used to indicate
        //what is dst_addr message in heartbeat datagram layer.
    ,output         [31:0]  dg_hb_dst_addr//datagram heartbeat dst address
    //ll interface which is used between app layer and ethcat layer
    ,output wire    [3:0]   cache_we
    ,output wire    [15:0]  cache_addr
    ,output wire    [31:0]  cache_din
    ,input  wire    [31:0]  cache_dout

    //app layer ll interface with application depot
    ,output wire            depot_rden
    ,output wire    [3:0]   depot_we
    ,output wire    [15:0]  depot_addr
    ,output wire    [31:0]  depot_din
    ,input wire     [31:0]  depot_dout

    ,output wire    [3:0]   slv_id_we
    ,output wire    [15:0]  slv_id_addr
    ,output wire    [31:0]  slv_id_din

    //only used by slave mode,which are used to transfer complete package to ethcater tx buffer
    ,output wire            m_slvsta_tx_sof     //slave station tx port
    ,output wire            m_slvsta_tx_eof     //slave station tx port
    ,output wire            m_slvsta_tx_tvalid   //slave station tx port
    ,output wire    [31:0]  m_slvsta_tx_tdata    //slave station tx port

);
    wire            one_ecat_frm_done;  //rx channel notice to app ctrl module that one complete return package has been recived.
    wire    [3:0]   ecat_frm_rslt;      //pkg crc result
    wire    [3:0]   rx_eth_type;        //the type of package has been received by rx channel

    generate
        if(WOKE_MODE ==  "MAST") begin:MAST
            app_mst_tx_ctrl
                app_mst_tx_ctrl_u
                (
                     .clk               (clk            )
                    ,.reset             (reset          )

                    ,.app_trsf_en       (app_trsf_en    )
                    ,.mst_sta_restart   (mst_sta_restart)
                    ,.hb_err_slvsta     (hb_err_slvsta)
                    ,.mst_prcs_hb_flag  (mst_prcs_hb_flag)
                    ,.loop_link_success (loop_link_success)
                    ,.ping_pong_flag    (ping_pong_flag     )
                    ,.pkg_trsf_start    (pkg_trsf_start )
                    ,.each_dg_length    (each_dg_length )
                    ,.app_err_flag      (app_err_flag)
                    ,.app_err_type      (app_err_type)
                    
                    ,.one_ecat_frm_done (one_ecat_frm_done  )
                    ,.ecat_frm_rslt     (ecat_frm_rslt      )
                    ,.slv_sta_num       (slv_sta_num        )
                    ,.rx_eth_type       (rx_eth_type        )
                    
                    ,.ethcat_tx_type    (ethcat_tx_type )
                    ,.ethcat_tx_len     (ethcat_tx_len  )
                    ,.datagram_tx_cmd   (datagram_tx_cmd)
                    ,.datagram_tx_len   (datagram_tx_len)
                    ,.datagram_tx_num   (datagram_tx_num)
                    ,.datagram_tx_uuid  (datagram_tx_uuid  )
                    ,.dg_hb_dst_addr    (dg_hb_dst_addr )
                );

            app_mst_rx_ctrl
                app_mst_rx_ctrl_u
            (
                 .clk               (clk                )
                ,.reset             (reset              )
                ,.one_ecat_frm_done (one_ecat_frm_done  )
                ,.ecat_frm_rslt     (ecat_frm_rslt      )
                ,.slv_sta_num       (slv_sta_num        )
                ,.rx_eth_type       (rx_eth_type        )
                ,.prot_rcv_req      (prot_rcv_req       )
                ,.prot_rcv_ack      (prot_rcv_ack       )

                ,.depot_we          (depot_we           )
                ,.depot_addr        (depot_addr         )
                ,.depot_din         (depot_din          )

                ,.slv_id_we         (slv_id_we          )
                ,.slv_id_addr       (slv_id_addr        )
                ,.slv_id_din        (slv_id_din         )

                ,.cache_we          (cache_we           )
                ,.cache_addr        (cache_addr         )
                ,.cache_din         (cache_din          )
                ,.cache_dout        (cache_dout         )
                ,.rx_crc_vld        (rx_crc_vld         )
                ,.rx_crc_pass       (rx_crc_pass        )
            );
            
            always @(posedge clk)begin
                if(reset)begin
                    mst_sta_trsf_flag   <=  'd0;
                end else if (rx_crc_vld)begin
                    mst_sta_trsf_flag   <=  'd0;
                end else if (pkg_trsf_start)begin
                    mst_sta_trsf_flag   <=  'd1;
                end else begin
                    mst_sta_trsf_flag   <=  mst_sta_trsf_flag;
                end
            end
        end else begin:SLAVE
            app_slv_rx_ctrl
                app_slv_rx_ctrl_u
            (
                 .clk               (clk                )
                ,.reset             (reset              )
                ,.slvsta_rcv_hb_flag(slvsta_rcv_hb_flag )
                ,.slvsta_id_vld     (slvsta_id_vld      )
                ,.slvsta_id         (slvsta_id          )
                ,.cfg_sta_addr      (cfg_sta_addr       )
                ,.ping_pong_flag    (ping_pong_flag     )
                ,.one_ecat_frm_done (one_ecat_frm_done  )
                ,.ecat_frm_rslt     (ecat_frm_rslt      )
                ,.slv_sta_num       (slv_sta_num        )
                ,.rx_eth_type       (rx_eth_type        )
                ,.cur_slv_dg_beat   (cur_slv_dg_beat    )
                
                ,.prot_rcv_req      (prot_rcv_req       )
                ,.prot_rcv_ack      (prot_rcv_ack       )
                
                ,.prot_send_req     (prot_send_req       )
                ,.prot_send_ack     (prot_send_ack       )

                ,.cache_we          (cache_we           )
                ,.cache_addr        (cache_addr         )
                ,.cache_din         (cache_din          )
                ,.cache_dout        (cache_dout         )
                ,.rx_crc_vld        (rx_crc_vld         )
                ,.rx_crc_pass       (rx_crc_pass        )

                ,.depot_rden        (depot_rden         )
                ,.depot_we          (depot_we           )
                ,.depot_addr        (depot_addr         )
                ,.depot_din         (depot_din          )
                ,.depot_dout        (depot_dout         )
                ,.m_slvsta_tx_sof     (m_slvsta_tx_sof      )
                ,.m_slvsta_tx_eof     (m_slvsta_tx_eof      )
                ,.m_slvsta_tx_tvalid  (m_slvsta_tx_tvalid   )
                ,.m_slvsta_tx_tdata   (m_slvsta_tx_tdata    )
            );
        end
    endgenerate

endmodule

