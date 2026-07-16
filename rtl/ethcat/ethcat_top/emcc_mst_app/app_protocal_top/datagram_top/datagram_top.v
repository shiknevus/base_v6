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
module datagram_top(
     input              clk
    ,input              reset
    
    //indicate that one datagram could been transfer
    ,input              pkg_trsf_start
    
    //head content
    ,input  wire    [3:0]   ethcat_tx_type
    ,input          [7:0]   datagram_tx_cmd
    ,input          [15:0]  datagram_tx_len
    ,input          [7:0]   datagram_tx_num
    ,input  wire    [16:0]  datagram_tx_uuid

    ,output                 prot_send_req
    ,input                  prot_send_ack
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

    datagram_tx
        datagram_tx_u
        (
             .clk                   (clk    )
            ,.reset                 (reset  )
            //indicate that one datagram could been transfer
            ,.pkg_trsf_start        (pkg_trsf_start )
            //head content
            ,.ethcat_tx_type        (ethcat_tx_type )
            ,.datagram_tx_cmd       (datagram_tx_cmd)
            ,.datagram_tx_len       (datagram_tx_len)
            ,.datagram_tx_num       (datagram_tx_num)
            ,.datagram_tx_uuid      (datagram_tx_uuid)

            ,.prot_send_req         (prot_send_req      )
            ,.prot_send_ack         (prot_send_ack      )
            //current station's address,which is only used by heart beat
            ,.dg_hb_dst_addr        (dg_hb_dst_addr )//datagram heartbeat dst address
            //ll bus between datagram layer and top app depot
            ,.app_rd_en             (app_rd_en)
            ,.app_rd_addr           (app_rd_addr)
            ,.app_rd_data           (app_rd_data)
            //axi stream to ethercat layer
            ,.m_app_tx_tvalid       (m_app_tx_tvalid)
            ,.m_app_tx_tready       (m_app_tx_tready)
            ,.m_app_tx_sop          (m_app_tx_sop   )
            ,.m_app_tx_eop          (m_app_tx_eop   )
            ,.m_app_tx_tdata        (m_app_tx_tdata)
        );

endmodule

