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
module ethcat_rx_crc_top(
     input              clk
    ,input              reset
    
    ,input  wire            s_aurora_rx_tvalid
    ,input  wire    [3:0]   s_aurora_rx_tkeep
    ,input  wire            s_aurora_rx_tlast
    ,input  wire    [31:0]  s_aurora_rx_tdata

    ,output wire    [31:0]  rx_data
    ,output wire            rx_sof
    ,output wire            rx_eof
    ,output wire    [1:0]   rx_rem_int
    ,output wire            rx_src_rdy
    ,output wire            crc_valid
    ,output wire            crc_pass_fail
);
    wire            rx_sof_n;
    wire            rx_eof_n;
    wire            rx_src_rdy_n;

    wire    [31:0]  rx_data_crc;
    wire            rx_sof_crc_n;
    wire            rx_eof_crc_n;
    wire    [1:0]   rx_rem_int_crc;
    wire            rx_src_rdy_crc_n;
    wire            rx_dst_rdy_crc_n;
    wire            crc_pass_fail_n;

    assign  rx_sof      = ~rx_sof_n;
    assign  rx_eof      = ~rx_eof_n;
    assign  rx_src_rdy  = ~rx_src_rdy_n;
    assign  crc_pass_fail = ~crc_pass_fail_n;

    axi_to_ll #
    (
       .DATA_WIDTH(32),
       .STRB_WIDTH(4),
       .USE_4_NFC (0),
       .REM_WIDTH (2)
    )

    axi_to_ll_u
    (
     .AXI4_S_IP_TX_TVALID(s_aurora_rx_tvalid),
     .AXI4_S_IP_TX_TREADY(),
     .AXI4_S_IP_TX_TDATA(s_aurora_rx_tdata),
     .AXI4_S_IP_TX_TKEEP(s_aurora_rx_tkeep),
     .AXI4_S_IP_TX_TLAST(s_aurora_rx_tlast),

     .LL_OP_DATA(rx_data_crc),
     .LL_OP_SOF_N(rx_sof_crc_n),
     .LL_OP_EOF_N(rx_eof_crc_n),
     .LL_OP_REM(rx_rem_int_crc),
     .LL_OP_SRC_RDY_N(rx_src_rdy_crc_n),
     .LL_IP_DST_RDY_N(rx_dst_rdy_crc_n),

     // System Interface
     .USER_CLK(clk),
     .RESET(reset), 
     .CHANNEL_UP(1)//axi data stream is valid while this signal is asserted
    );

   rx_crc rx_crc_u
    (
    //to ll
     .DATA_DS(rx_data),
     .REM_DS(rx_rem_int),
     .SOF_N_DS(rx_sof_n),
     .EOF_N_DS(rx_eof_n),
     .SRC_RDY_N_DS(rx_src_rdy_n),//data valid
     .DST_RDY_N_DS(1'b0),// receive mode application buffer is always ready.
     
     //from crc
     .CRC_PASS_FAIL_N(crc_pass_fail_n),
     .CRC_VALID(crc_valid),

     .DST_RDY_N_US(rx_dst_rdy_crc_n),//to crc
     .DATA_US(rx_data_crc),
     .REM_US(rx_rem_int_crc),
     .SOF_N_US(rx_sof_crc_n),
     .EOF_N_US(rx_eof_crc_n),
     .SRC_RDY_N_US(rx_src_rdy_crc_n),//
     .RESET(reset),
     .CLK(clk)

    );

    
endmodule

