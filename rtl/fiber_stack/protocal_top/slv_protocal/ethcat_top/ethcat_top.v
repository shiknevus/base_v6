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
module ethcat_top
#(
    parameter  WOKE_MODE   = "MAST"
)
(
     input                  clk
    ,input                  reset

    //ethercat head content
    ,input          [3:0]   ethcat_tx_type
    ,input          [15:0]  ethcat_tx_len
    //axi stream interface is used to transfer tx package
    ,input                  s_app_tx_tvalid
    ,output                 s_app_tx_tready
    ,input                  s_app_tx_sop
    ,input                  s_app_tx_eop
    ,input          [31:0]  s_app_tx_tdata

    //ethercat layer cache ll bus,this cache stored full content of one package
    ,input          [3:0]   cache_we
    ,input          [15:0]  cache_addr
    ,input          [31:0]  cache_din
    ,output         [31:0]  cache_dout
    //crc valid and crc result
    ,output                 rx_crc_vld
    ,output                 rx_crc_pass
    //only used by slave mode,which is used to recive the package,
    //and transfer this package to aurora IP
    ,input  wire            s_slvsta_tx_sof
    ,input  wire            s_slvsta_tx_eof
    ,input  wire            s_slvsta_tx_tvalid
    ,input  wire    [31:0]  s_slvsta_tx_tdata

    //axi stream interface to aurora IP
    ,output                 m_boroa_tx_tvalid
    ,input                  m_boroa_tx_tready
    ,output         [3:0]   m_boroa_tx_tkeep
    ,output                 m_boroa_tx_tlast
    ,output         [31:0]  m_boroa_tx_tdata

    //axi stream rx interface from aurora IP
    ,input  wire            s_aurora_rx_tvalid
    ,input  wire    [3:0]   s_aurora_rx_tkeep
    ,input  wire            s_aurora_rx_tlast
    ,input  wire    [31:0]  s_aurora_rx_tdata
);

    ethcat_send_top
    #(
        .WOKE_MODE      (WOKE_MODE  )
    )
        ethcat_send_top_u
        (
             .clk                   (clk)
            ,.reset                 (reset)

            //ethercat head content
            ,.ethcat_length         (ethcat_tx_len)
            ,.ethcat_type           (ethcat_tx_type)

            //axi stream interface is used to transfer tx package
            ,.s_app_tx_tvalid       (s_app_tx_tvalid)
            ,.s_app_tx_tready       (s_app_tx_tready)
            ,.s_app_tx_sop          (s_app_tx_sop   )
            ,.s_app_tx_eop          (s_app_tx_eop   )
            ,.s_app_tx_tdata        (s_app_tx_tdata )

            //axi stream interface to aurora IP
            ,.m_boroa_tx_tvalid     (m_boroa_tx_tvalid)
            ,.m_boroa_tx_tready     (m_boroa_tx_tready)
            ,.m_boroa_tx_tkeep      (m_boroa_tx_tkeep)
            ,.m_boroa_tx_tlast      (m_boroa_tx_tlast)
            ,.m_boroa_tx_tdata      (m_boroa_tx_tdata)

            //only used by slave mode,which is used to recive the package,
            //and transfer this package to aurora IP
            ,.s_slvsta_tx_sof       (s_slvsta_tx_sof   )
            ,.s_slvsta_tx_eof       (s_slvsta_tx_eof   )
            ,.s_slvsta_tx_tvalid    (s_slvsta_tx_tvalid)
            ,.s_slvsta_tx_tdata     (s_slvsta_tx_tdata )

        );

    ethcat_rcv_top
    #(
        .WOKE_MODE      (WOKE_MODE  )
    )
        ethcat_rcv_top_u
        (
             .clk                   (clk                )
            ,.reset                 (reset              )

            //crc valid and crc result
            ,.rx_crc_vld            (rx_crc_vld         )
            ,.rx_crc_pass           (rx_crc_pass        )

            //axi stream rx interface from aurora IP
            ,.s_aurora_rx_tvalid    (s_aurora_rx_tvalid )
            ,.s_aurora_rx_tkeep     (s_aurora_rx_tkeep  )
            ,.s_aurora_rx_tlast     (s_aurora_rx_tlast  )
            ,.s_aurora_rx_tdata     (s_aurora_rx_tdata  )

            //ethercat layer cache ll bus,this cache stored full content of one package
            ,.cache_we              (cache_we           )
            ,.cache_addr            (cache_addr         )
            ,.cache_din             (cache_din          )
            ,.cache_dout            (cache_dout         )
    );
endmodule

