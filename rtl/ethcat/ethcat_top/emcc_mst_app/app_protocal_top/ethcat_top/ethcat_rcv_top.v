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
module ethcat_rcv_top
#(
    parameter  WOKE_MODE   = "MAST"
)
(
     input              clk
    ,input              reset
    
    ,input  wire            s_aurora_rx_tvalid
    ,input  wire    [3:0]   s_aurora_rx_tkeep
    ,input  wire            s_aurora_rx_tlast
    ,input  wire    [31:0]  s_aurora_rx_tdata

    ,input          [3:0]   cache_we
    ,input          [15:0]  cache_addr
    ,input          [31:0]  cache_din
    ,output         [31:0]  cache_dout
    ,output                 rx_crc_vld
    ,output                 rx_crc_pass

);

    wire    [31:0]  rx_data;
    wire            rx_sof;
    wire            rx_eof;
    wire    [1:0]   rx_rem_int;
    wire            rx_src_rdy;
    wire            crc_valid;
    wire            crc_pass_fail;

    ethcat_rx_crc_top
        ethcat_rx_crc_top_u
        (
             .clk                   (clk               )
            ,.reset                 (reset             )
    
            ,.s_aurora_rx_tvalid    (s_aurora_rx_tvalid)
            ,.s_aurora_rx_tkeep     (s_aurora_rx_tkeep )
            ,.s_aurora_rx_tlast     (s_aurora_rx_tlast )
            ,.s_aurora_rx_tdata     (s_aurora_rx_tdata )
    
            ,.rx_data               (rx_data           )
            ,.rx_sof                (rx_sof            )
            ,.rx_eof                (rx_eof            )
            ,.rx_rem_int            (rx_rem_int        )
            ,.rx_src_rdy            (rx_src_rdy        )
            ,.crc_valid             (crc_valid         )
            ,.crc_pass_fail         (crc_pass_fail     )
        );

    ethcat_rcv
    #(
        .WOKE_MODE      (WOKE_MODE  )
    )
        ethcat_rcv_u
            (
                 .clk               (clk            )
                ,.reset             (reset          )
                ,.s_ethcat_rx_sop   (rx_sof         )
                ,.s_ethcat_rx_eop   (rx_eof         )
                ,.s_ethcat_rx_vld   (rx_src_rdy     )
                ,.s_ethcat_rx_dat   (rx_data        )
                ,.crc_valid         (crc_valid      )
                ,.crc_pass_fail     (crc_pass_fail  )

                ,.cache_we          (cache_we   )
                ,.cache_addr        (cache_addr )
                ,.cache_din         (cache_din  )
                ,.cache_dout        (cache_dout )
                ,.rx_crc_vld        (rx_crc_vld )
                ,.rx_crc_pass       (rx_crc_pass)

                ,.test_sig            ()
        );

endmodule

