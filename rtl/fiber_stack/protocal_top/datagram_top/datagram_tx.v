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
//       |<--------------------------32bit-------------------------->|
//       |  0        7 |  8       15   | 16        23 |  24      31  |
//       |     CMD     |     INDEX     |    DST ADDR_L(reg addr)     |
//       |  DST ADDR_H(slave station)  |       package length        |
//       |                           RSCV                            |
//       |-----------------------------------------------------------|
//       |                                                           |
//       |                           DATA                            |
//       |-----------------------------------------------------------|
/////////////////////////////////////////////////////////////////
module datagram_tx(
     input                  clk
    ,input                  reset
    //indicate that one datagram could been transfer
    ,input                  pkg_trsf_start
    //head content
    ,input  wire    [3:0]   ethcat_tx_type
    ,input          [7:0]   datagram_tx_cmd
    ,input          [15:0]  datagram_tx_len
    ,input          [7:0]   datagram_tx_num 
    ,input  wire    [16:0]  datagram_tx_uuid

    ,output wire            prot_send_req
    ,input  wire            prot_send_ack

    //current station's address,which is only used by heart beat
    ,input          [31:0]  dg_hb_dst_addr//datagram heartbeat dst address
    //ll bus between datagram layer and top app depot
    ,output             app_rd_en
    ,output     [15:0]  app_rd_addr
    ,input      [31:0]  app_rd_data
    //axi stream to ethercat layer
    ,output wire        m_app_tx_tvalid
    ,input              m_app_tx_tready
    ,output wire        m_app_tx_sop
    ,output wire        m_app_tx_eop
    ,output wire[31:0]  m_app_tx_tdata
);
    wire    [15:0]  datagram_rd_bias;   //tx controler noticed tx_rd module that the package stored bias address in depot buffer
    //datagram header
    wire    [7:0]   datagram_cmd;       //datagram command
    wire    [7:0]   datagram_index;
    wire    [31:0]  datagram_dst_addr;
    wire    [15:0]  datagram_pl_len;
    wire    [7:0]   datagram_wkc;

    wire            first_slv_sta;      //tx controler noticed tx_rd module that current datagram is first slave station
    wire            last_slv_sta;       //tx controler noticed tx_rd module that current datagram is last slave station

    wire            datagram_rd_start;  //datagram read start
    wire            datagram_rd_finish; //datagram read operatin finish
    wire    [15:0]  datagram_uuid;
    datagram_tx_ctrl
        datagram_tx_ctrl_u
        (
             .clk                   (clk                )
            ,.reset                 (reset              )

            ,.pkg_trsf_start        (pkg_trsf_start     )//indicate that one datagram could been transfer

            ,.ethcat_tx_type        (ethcat_tx_type     )//current ethcat frame type 
            //datagram header
            ,.datagram_tx_cmd       (datagram_tx_cmd    )
            ,.datagram_tx_len       (datagram_tx_len    )
            ,.datagram_tx_num       (datagram_tx_num    )
            ,.datagram_tx_uuid      (datagram_tx_uuid   )
            ,.prot_send_req         (prot_send_req      )
            ,.prot_send_ack         (prot_send_ack      )
            //current datagram heartbeat dst address,which drive datagram layer
            ,.dg_hb_dst_addr        (dg_hb_dst_addr     )
            
            //the control interface during tx_controller and tx_read
            ,.datagram_rd_start     (datagram_rd_start  )
            ,.datagram_rd_finish    (datagram_rd_finish )
            ,.first_slv_sta         (first_slv_sta      )//first child datagram package
            ,.last_slv_sta          (last_slv_sta       )//last child datagram package

            ,.datagram_rd_bias      (datagram_rd_bias   )//depot read bias address
            //datagram header to tx_rd module
            ,.datagram_cmd          (datagram_cmd       )
            ,.datagram_index        (datagram_index     )
            ,.datagram_dst_addr     (datagram_dst_addr  )
            ,.datagram_pl_len       (datagram_pl_len    )//datagram_payload_length
            ,.datagram_uuid         (datagram_uuid      )
            ,.datagram_wkc          (datagram_wkc       )
        );

    datagram_tx_rd
        datagram_tx_rd_u
        (
             .clk                   (clk    )
            ,.reset                 (reset  )
            //the signals of tx controler to tx_rd module 
            ,.datagram_rd_start     (datagram_rd_start  )
            ,.datagram_rd_finish    (datagram_rd_finish )
            ,.first_slv_sta         (first_slv_sta      )//first child datagram package
            ,.last_slv_sta          (last_slv_sta       )//last child datagram package
            //ethercat and datagram header
            ,.ethcat_tx_type        (ethcat_tx_type     )
            ,.datagram_rd_bias      (datagram_rd_bias   )
            ,.datagram_cmd          (datagram_cmd       )
            ,.datagram_index        (datagram_index     )
            ,.datagram_dst_addr     (datagram_dst_addr  )
            ,.datagram_pl_len       (datagram_pl_len    )
            ,.datagram_uuid         (datagram_uuid      )
            ,.datagram_wkc          (datagram_wkc       )
            
            //app depot ll bus
            ,.app_rd_en             (app_rd_en)
            ,.app_rd_addr           (app_rd_addr)
            ,.app_rd_data           (app_rd_data)
            //datagram axi stream to ethcat layer
            ,.m_app_tx_tvalid       (m_app_tx_tvalid)
            ,.m_app_tx_tready       (m_app_tx_tready)
            ,.m_app_tx_sop          (m_app_tx_sop   )
            ,.m_app_tx_eop          (m_app_tx_eop   )
            ,.m_app_tx_tdata        (m_app_tx_tdata )
        );

endmodule