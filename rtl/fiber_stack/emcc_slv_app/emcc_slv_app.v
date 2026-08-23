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
module emcc_slv_app
#(
     parameter  RAM_DEPTH   =   4096
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
    ,parameter  PKG_NUM     =   RAM_DEPTH
)
(
     input              clk
    ,input              reset
    
    ,input  wire[7:0]   slv_sta_num     //this signals only update during first initial datagram.It indicate the number of slave station
    ,input      [15:0]  each_dg_len

    ,output wire        app_send_req
    ,input               app_send_ack
    ,output wire        app_rcv_req
    ,input               app_rcv_ack
    
    //send buffer
    ,output wire                        send_buf_ena
    ,output wire    [4-1:0]             send_buf_wea
    ,output wire    [RAM_AWIDTH-1:0]    send_buf_addra
    ,output wire    [RAM_DWIDTH-1:0]    send_buf_dina
    //receive buffer
    ,output wire                        rcv_buf_ena
    ,output wire    [RAM_AWIDTH-1:0]    rcv_buf_addra
    ,input  wire    [RAM_DWIDTH-1:0]    rcv_buf_douta
    
    ,output wire                        app_cfg_wea
    ,output wire    [RAM_AWIDTH-1:0]    app_cfg_addra
    ,output wire    [RAM_DWIDTH-1:0]    app_cfg_dina
    ,output wire                        driver_cfg_msg_wr_req
    ,input  wire                        driver_cfg_msg_wr_ack
    ,output wire                        rd_msg_addr_en
    ,output wire    [RAM_AWIDTH-1:0]    rd_msg_addr

    ,input  wire    [31:0]              do_regoin_msg
    ,input  wire    [31:0]              di_regoin_msg
    ,input  wire    [31:0]              ai_regoin_msg
    ,input  wire    [31:0]              rs232_ch0_msg
    ,input  wire    [31:0]              rs232_ch1_msg
    ,input  wire    [31:0]              rs232_ch2_msg
    ,input  wire    [31:0]              rs232_ch3_msg
    ,input  wire    [31:0]              rs232_ch4_msg
    ,input  wire    [31:0]              rs232_ch5_msg
    ,input  wire    [31:0]              rs232_ch6_msg
    ,input  wire    [31:0]              rs232_ch7_msg
    ,input  wire    [31:0]              rs485_ch8_msg
    ,input  wire    [31:0]              pul_motor0_msg
    ,input  wire    [31:0]              pul_motor1_msg
    ,input  wire    [31:0]              pul_motor2_msg
    ,input  wire    [31:0]              pul_motor3_msg
);
    reg     [31:0]  tst_cnt;
    wire            app_tx_pulse;
    wire    [31:0]  pre_uuid;
    wire    [31:0]  cur_uuid;
    wire    [31:0]  id_regoin_msg;
    wire            intf_tst_flag;
    assign  id_regoin_msg   =   32'hdead_beff;
    slv_app_rcv
    #(
         .RAM_DEPTH     (RAM_DEPTH  )
        ,.RAM_DWIDTH    (RAM_DWIDTH )
    )
        slv_app_rcv_u
        (
             .clk           (clk        )
            ,.reset         (reset      )

            ,.slv_sta_num   (slv_sta_num    )
            ,.each_dg_len   (each_dg_len    )

            ,.app_rcv_req   (app_rcv_req    )
            ,.app_rcv_ack   (app_rcv_ack    )
            
            ,.app_tx_pulse  (app_tx_pulse   )
            ,.pre_uuid      (pre_uuid       )
            ,.cur_uuid      (cur_uuid       )
            //receive buffer
            ,.rcv_buf_ena   (rcv_buf_ena    )
            ,.rcv_buf_addra (rcv_buf_addra  )
            ,.rcv_buf_douta (rcv_buf_douta  )

            ,.app_cfg_wea           (app_cfg_wea            )
            ,.app_cfg_addra         (app_cfg_addra          )
            ,.app_cfg_dina          (app_cfg_dina           )
            ,.driver_cfg_msg_wr_req (driver_cfg_msg_wr_req  )
            ,.driver_cfg_msg_wr_ack (driver_cfg_msg_wr_ack  )
            
            //to tx module
            ,.intf_tst_flag         (intf_tst_flag          )
        );

    slv_app_send
    #(
         .RAM_DEPTH     (RAM_DEPTH      )
        ,.RAM_DWIDTH    (RAM_DWIDTH     )
    )
        slv_app_send_u
        (
             .clk           (clk            )
            ,.reset         (reset          )

            ,.app_tx_pulse  (app_tx_pulse   )
            ,.pre_uuid      (pre_uuid       )
            ,.cur_uuid      (cur_uuid       )
            ,.slv_sta_num   (slv_sta_num    )
            ,.each_dg_len   (each_dg_len    )
            ,.app_send_req  (app_send_req   )
            ,.app_send_ack  (app_send_ack   )

            ,.send_buf_ena  (send_buf_ena   )
            ,.send_buf_wea  (send_buf_wea   )
            ,.send_buf_addra(send_buf_addra )
            ,.send_buf_dina (send_buf_dina  )

            ,.rd_msg_addr_en(rd_msg_addr_en)
            ,.rd_msg_addr   (rd_msg_addr   )

            ,.id_regoin_msg (id_regoin_msg  )
            ,.do_regoin_msg (do_regoin_msg  )
            ,.di_regoin_msg (di_regoin_msg  )
            ,.ai_regoin_msg (ai_regoin_msg  )
            ,.rs232_ch0_msg (rs232_ch0_msg  )
            ,.rs232_ch1_msg (rs232_ch1_msg  )
            ,.rs232_ch2_msg (rs232_ch2_msg  )
            ,.rs232_ch3_msg (rs232_ch3_msg  )
            ,.rs232_ch4_msg (rs232_ch4_msg  )
            ,.rs232_ch5_msg (rs232_ch5_msg  )
            ,.rs232_ch6_msg (rs232_ch6_msg  )
            ,.rs232_ch7_msg (rs232_ch7_msg  )
            ,.rs485_ch8_msg (rs485_ch8_msg  )
            ,.pul_motor0_msg (pul_motor0_msg  )
            ,.pul_motor1_msg (pul_motor1_msg  )
            ,.pul_motor2_msg (pul_motor2_msg  )
            ,.pul_motor3_msg (pul_motor3_msg  )

            ,.intf_tst_flag     (intf_tst_flag)
            ,.rx_wr_txbuf_wen   (app_cfg_wea    )
            ,.rx_wr_txbuf_addr  (app_cfg_addra  )
            ,.rx_wr_txbuf_data  (app_cfg_dina   )
        );

endmodule

