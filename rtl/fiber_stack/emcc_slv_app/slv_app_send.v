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
module slv_app_send
#(
     parameter  RAM_DEPTH   =   4096
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
    ,parameter  PKG_NUM     =   RAM_DEPTH
)
(
     input              clk
    ,input              reset
    
    ,input              app_tx_pulse
    ,input  [31:0]      pre_uuid
    ,input  [31:0]      cur_uuid
    
    ,input  wire[7:0]   slv_sta_num     //this signals only update during first initial datagram.It indicate the number of slave station
    
    ,input      [15:0]  each_dg_len

    ,output reg         app_send_req
    ,input              app_send_ack
    
    //receive buffer
    ,output wire                        send_buf_ena
    ,output reg     [3:0]               send_buf_wea
    ,output reg     [RAM_AWIDTH-1:0]    send_buf_addra
    ,output reg     [RAM_DWIDTH-1:0]    send_buf_dina
    
    ,input  wire    [31:0]              id_regoin_msg

    ,input  wire    [31:0]              do_regoin_msg
    ,input  wire    [31:0]              di_regoin_msg

   // ,input  wire    [31:0]              ao_regoin_msg
    ,input  wire    [31:0]              ai_regoin_msg

    ,output reg                         rd_msg_addr_en
    ,output reg     [RAM_AWIDTH-1:0]    rd_msg_addr

//    ,input  wire    [31:0]              axis_1st_msg
//    ,input  wire    [31:0]              axis_2nd_msg
//    ,input  wire    [31:0]              axis_3rd_msg
//    ,input  wire    [31:0]              axis_4th_msg
    
    ,input  wire    [31:0]              rs232_1st_msg
    ,input  wire    [31:0]              rs232_2nd_msg
//    ,input  wire    [31:0]              rs232_3rd_msg
//    ,input  wire    [31:0]              rs232_4th_msg
//    ,input  wire    [31:0]              rs232_5th_msg
//    ,input  wire    [31:0]              rs232_6th_msg
//    ,input  wire    [31:0]              rs232_7th_msg
//    ,input  wire    [31:0]              rs232_8th_msg

//    ,input  wire    [31:0]              rs485_1st_msg

//rx module
    ,input  wire                        intf_tst_flag
    ,input  wire                        rx_wr_txbuf_wen
    ,input  wire    [RAM_AWIDTH-1:0]    rx_wr_txbuf_addr
    ,input  wire    [RAM_DWIDTH-1:0]    rx_wr_txbuf_data

    ,output reg         tst_sig
);

(* MARK_DEBUG="true" *)    reg [31:0]  work_cnt = 0;

    localparam  STM_IDLE        = 'd0;
    localparam  STM_TX_HS       = 'd3;//this state check that the portocol buffer is busying now?
    localparam  STM_RD_DAT      = 'd7;//read data from protocol buffer to application buffer
    localparam  STM_RD_ONCE_END = 'd8;
    localparam  STM_RD_FINISH   = 'd9;
    localparam  STM_CHECK_RSLT  = 'd10;//this state is no use in slave station mode
    localparam  STM_END         = 'd13;
   (* MARK_DEBUG="true" *)    reg [4:0] wk_state  = 'd0;
    reg [4:0] wk_state_d1 = 'd0;
    reg [4:0] wk_state_d2 = 'd0;
    reg         work_cnt_done;
    reg [15:0]  slv_dg_index;
    reg [7:0]   slv_sta_num_d1;
    reg [7:0]   slv_sta_num_d2;
    reg                     rd_msg_addr_en_d1;
    reg                     rd_msg_addr_en_d2;
    reg                     rd_msg_addr_en_d3;
    reg [RAM_AWIDTH-1:0]    rd_msg_addr_d1;
    reg [RAM_AWIDTH-1:0]    rd_msg_addr_d2;
    reg [RAM_AWIDTH-1:0]    rd_msg_addr_d3;
    reg [RAM_DWIDTH-1:0]    rd_msg_data;
    wire    [31:0]          msg_array[31:0];
    reg                     rx_wr_txbuf_wen_d1;
    reg                     rx_wr_txbuf_wen_f;
    reg                     latch_intf_tst_flag;
    (* ASYNC_REG = "TRUE" *) reg [15:0] each_dg_len_d1; //cdc sync from prot domain
    reg [15:0] each_dg_len_d2;
    always @(posedge clk)begin
        each_dg_len_d1  <=  each_dg_len;
        each_dg_len_d2  <=  each_dg_len_d1;
    end
    always @(posedge clk)begin
        rx_wr_txbuf_wen_d1  <=  rx_wr_txbuf_wen;
        rx_wr_txbuf_wen_f   <=  (~rx_wr_txbuf_wen) & rx_wr_txbuf_wen_d1;
    end
    
    always @(posedge clk)begin
        slv_sta_num_d1  <=  slv_sta_num;
        slv_sta_num_d2  <=  slv_sta_num_d1;
    end

    always @(posedge clk)begin
        wk_state_d1 <=  wk_state;
        wk_state_d2 <=  wk_state_d1;
    end
    
    always @(posedge clk) begin
        if(reset)begin
          wk_state  <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE: begin
                    if(app_tx_pulse) begin
                        wk_state  <=  STM_TX_HS;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_TX_HS:begin
                    if(app_send_ack)begin
                        wk_state  <=  STM_RD_DAT;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_RD_DAT:begin//
                    if((latch_intf_tst_flag & rx_wr_txbuf_wen_f) | ((~latch_intf_tst_flag) & work_cnt_done))begin
//                        wk_state  <=  STM_RD_ONCE_END;
                        wk_state  <=  STM_RD_FINISH;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_RD_ONCE_END:begin
                    if(slv_dg_index == (slv_sta_num_d2 - 1))begin
                        wk_state  <=  STM_RD_FINISH;
                    end else begin
                        wk_state  <=  STM_RD_DAT;
                    end
                end
                STM_RD_FINISH:begin
                    wk_state  <=  STM_CHECK_RSLT;
                end
                STM_CHECK_RSLT:begin
                    if(work_cnt_done)begin
                        wk_state  <=  STM_END;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_END:begin
                    wk_state  <=  STM_IDLE;
                end
                default: begin
                    wk_state  <=  STM_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            latch_intf_tst_flag <=  'd0;
        end else if (wk_state == STM_END)begin
            latch_intf_tst_flag <=  'd0;
        end else if (app_tx_pulse & intf_tst_flag)begin
            latch_intf_tst_flag <=  'd1;
        end else begin
            latch_intf_tst_flag <=  latch_intf_tst_flag;
        end
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE,STM_RD_FINISH:begin
                slv_dg_index    <=  'd0;
            end
            STM_RD_ONCE_END:begin
                slv_dg_index    <=  slv_dg_index    +   1;
            end
            default: begin
                slv_dg_index    <=  slv_dg_index;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE,STM_CHECK_RSLT:begin
                app_send_req    <=  0;
            end
            STM_TX_HS:begin
                app_send_req    <=  1;
            end
            default: begin
                app_send_req    <=  app_send_req;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_CHECK_RSLT,STM_RD_DAT:begin
                work_cnt <= work_cnt + 1;
            end
            default: begin
                work_cnt  <=  0;
            end
        endcase
    end
    
    always @ ( * )begin
        case(wk_state)
            STM_CHECK_RSLT:begin
                work_cnt_done <= (work_cnt == 5 - 1) ? 1'b1 : 1'b0;
            end
            STM_RD_DAT:begin
                work_cnt_done <= (work_cnt == (each_dg_len_d2>>3) - 1) ? 1'b1 : 1'b0;
//                work_cnt_done <= (work_cnt == 511) ? 1'b1 : 1'b0;
            end
            default: begin
                work_cnt_done <= 1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE:begin
                rd_msg_addr     <=  'd0;
                rd_msg_addr_en  <=  'd0;
            end
            STM_RD_DAT:begin
                rd_msg_addr  <=  work_cnt + {slv_dg_index,{$clog2(`EACH_CHILD_DEPOT_SIZE){1'b0}}};
                rd_msg_addr_en  <=  'd1;
            end
            default: begin
                rd_msg_addr   <=  rd_msg_addr;
                rd_msg_addr_en  <=  'd0;
            end
        endcase
    end

    always @(posedge clk)begin
        rd_msg_addr_d1  <=  rd_msg_addr;
        rd_msg_addr_d2  <=  rd_msg_addr_d1;
        
        rd_msg_addr_en_d1   <=  rd_msg_addr_en;
        rd_msg_addr_en_d2   <=  rd_msg_addr_en_d1;
    end
    
    always @(posedge clk)begin
        if(latch_intf_tst_flag)begin
            rd_msg_addr_d3      <=  rx_wr_txbuf_addr;
            rd_msg_addr_en_d3   <=  rx_wr_txbuf_wen;
        end else begin
            rd_msg_addr_d3      <=  rd_msg_addr_d2;
            rd_msg_addr_en_d3   <=  rd_msg_addr_en_d2;
        end
    end
    
    assign  msg_array[0]    =   cur_uuid;
    assign  msg_array[1]    =   do_regoin_msg;
    assign  msg_array[2]    =   di_regoin_msg;
//    assign  msg_array[3]    =   ao_regoin_msg;
    assign  msg_array[4]    =   ai_regoin_msg;
//    assign  msg_array[5]    =   axis_1st_msg;
//    assign  msg_array[6]    =   axis_2nd_msg;
//    assign  msg_array[7]    =   axis_3rd_msg;
//    assign  msg_array[8]    =   axis_4th_msg;
    assign  msg_array[9]    =   rs232_1st_msg;
    assign  msg_array[10]   =   rs232_2nd_msg;
//    assign  msg_array[11]   =   rs232_3rd_msg;
//    assign  msg_array[12]   =   rs232_4th_msg;
//    assign  msg_array[13]   =   rs232_5th_msg;
//    assign  msg_array[14]   =   rs232_6th_msg;
//    assign  msg_array[15]   =   rs232_7th_msg;
//    assign  msg_array[16]   =   rs232_8th_msg;
//    assign  msg_array[17]   =   rs485_1st_msg;

    always @(posedge clk)begin
        if(reset)begin
            rd_msg_data <=  'd0;
        end else if (latch_intf_tst_flag)begin
            rd_msg_data <=  rx_wr_txbuf_data;
        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_ID) & (rd_msg_addr_d2 < `DEPOT_BIAS_DO))begin
            rd_msg_data <=  msg_array[0];
        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_DO) & (rd_msg_addr_d2 < `DEPOT_BIAS_DI))begin
            rd_msg_data <=  msg_array[1];
        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_DI) & (rd_msg_addr_d2 < `DEPOT_BIAS_AI))begin
            rd_msg_data <=  msg_array[2];
    //    end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_AO) & (rd_msg_addr_d2 < `DEPOT_BIAS_AI))begin
    //        rd_msg_data <=  msg_array[3];
        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_AI) & (rd_msg_addr_d2 < `DEPOT_BIAS_RS232_1ST))begin
            rd_msg_data <=  msg_array[4];
//        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_AXIS_1ST) & (rd_msg_addr_d2 < `DEPOT_BIAS_AXIS_2ND))begin
//            rd_msg_data <=  msg_array[5];
//        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_AXIS_2ND) & (rd_msg_addr_d2 < `DEPOT_BIAS_AXIS_3RD))begin
//            rd_msg_data <=  msg_array[6];
//        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_AXIS_3RD) & (rd_msg_addr_d2 < `DEPOT_BIAS_AXIS_4TH))begin
//            rd_msg_data <=  msg_array[7];
//        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_AXIS_4TH) & (rd_msg_addr_d2 < `DEPOT_BIAS_RS232_1ST))begin
//           rd_msg_data <=  msg_array[8];
        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_RS232_1ST) & (rd_msg_addr_d2 < `DEPOT_BIAS_RS232_2ND))begin
            rd_msg_data <=  msg_array[9];
        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_RS232_2ND) & (rd_msg_addr_d2 < `DEPOT_BIAS_RS232_2ND+`DEPOT_SIZE_RS232_2ND))begin
            rd_msg_data <=  msg_array[10];
//        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_RS232_3RD) & (rd_msg_addr_d2 < `DEPOT_BIAS_RS232_4TH))begin
//            rd_msg_data <=  msg_array[11];
//        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_RS232_4TH) & (rd_msg_addr_d2 < `DEPOT_BIAS_RS232_5TH))begin
//            rd_msg_data <=  msg_array[12];
//        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_RS232_5TH) & (rd_msg_addr_d2 < `DEPOT_BIAS_RS232_6TH))begin
//            rd_msg_data <=  msg_array[13];
//        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_RS232_6TH) & (rd_msg_addr_d2 < `DEPOT_BIAS_RS232_7TH))begin
//            rd_msg_data <=  msg_array[14];//d
//        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_RS232_7TH) & (rd_msg_addr_d2 < `DEPOT_BIAS_RS232_8TH))begin
//            rd_msg_data <=  msg_array[15];//e
//        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_RS232_8TH) & (rd_msg_addr_d2 < `DEPOT_BIAS_RS485_1ST))begin
//            rd_msg_data <=  msg_array[16];
//        end else if ((rd_msg_addr_d2 >= `DEPOT_BIAS_RS485_1ST) & (rd_msg_addr_d2 < (`DEPOT_BIAS_RS485_1ST + `DEPOT_SIZE_RS485_1ST)))begin
//            rd_msg_data <=  msg_array[17];
        end else begin
            rd_msg_data <=  0;
        end
    end
    
    always @(posedge clk)begin
        send_buf_addra  <=  rd_msg_addr_d3;
        send_buf_dina   <=  rd_msg_data;
        send_buf_wea    <=  rd_msg_addr_en_d3 ? 4'hf : 4'h0;
    end
    assign  send_buf_ena =   1;
    
    always @(posedge clk)begin
        tst_sig <=  1;
    end
endmodule