`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/15 15:20:14
// Design Name: 
// Module Name: osm61_laser_distance_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module frame_ctrl_dv300_485_modbus_rtu#(
    parameter  RAM_DEPTH   =   32768
    ,parameter  RAM_DWIDTH  =   12
) (
     input  wire      clk_i
    ,input  wire      rst_i
    
    ,input               i_time_1s_vld 
    ,input               i_time_1ms_vld
    
//输入参数
    ,input       [7:0]      i_slave_addr  //从站地址
    ,input       [15:0]     i_resp_tout   //响应超时时间
    ,input       [7:0]      i_retry_cnt   //重试次数
    ,input       [7:0]      i_func_code   //功能码
    ,input       [15:0]     i_data        //数据
    ,input       [7:0]      i_data_len    //数据长度
    ,input       [15:0]     i_start_addr  //起始地址
//
    ,output  reg            o_user_req
    ,input                  i_user_grant
    ,output      [31:0]     o_fb_data_frame
    ,input                  i_chl_a_send_req
    ,output reg             o_chl_a_fb_data_ready_p
    ,output reg  [2:0]      o_chl_a_execu_result

     //数据收发（主从模式公用）
    ,output  reg             o_send_start_p 
    ,output  reg  [7:0]      o_send_length
    ,input   wire [8*8-1:0]  i_recv_data
    ,input   wire            i_recv_finish_p
    // 主板uart数据接口
    ,input   wire            i_send_ready    //空闲，可以发送的标志
    ,output  reg  [0:8*8-1]  o_send_data
    //从板数据接口
    ,input   wire            i_send_finish_p //发送完成（脉冲）
    ,input   wire [7:0]      i_slv_err_code
    ,output  wire [7:0]      o_exp_recv_num //预期接收的字节数
    ,output  wire [8*8-1:0]  o_send_data_little
);

localparam  Broadcast_ADDR = 8'h00;


reg  [2:0]rcv_data_check_result;
wire [0:8*8-1] rcv_data_big;
reg       rcv_data_check_start_p;
reg       rcv_data_check_finish_p;
reg  [7:0] retry_cnt_current;
wire [7:0] send_crc_high ;
wire [7:0] send_crc_low ;
wire [8*6-1:0] crc_check_data;
reg  crc_cal_start;
wire crc_cal_done;
wire[15:0] crc_out;

assign send_crc_high = crc_out[15:8];
assign send_crc_low  = crc_out[7:0];
assign o_fb_data_frame = 0;
assign crc_check_data = {i_slave_addr,8'h06,i_start_addr,i_data[15:0]};//ctl_data_field含义是设置内容

// ------------- slaver frame head ---------------
assign o_exp_recv_num = 8; //目前接受的消息格式只有一种，长度固定8

//将大端数据转为小端数据，从板接口用
assign o_send_data_little[ 1*8-1:   0] = o_send_data[   0: 1*8-1];
assign o_send_data_little[ 2*8-1: 1*8] = o_send_data[ 1*8: 2*8-1];
assign o_send_data_little[ 3*8-1: 2*8] = o_send_data[ 2*8: 3*8-1];
assign o_send_data_little[ 4*8-1: 3*8] = o_send_data[ 3*8: 4*8-1];
assign o_send_data_little[ 5*8-1: 4*8] = o_send_data[ 4*8: 5*8-1];
assign o_send_data_little[ 6*8-1: 5*8] = o_send_data[ 5*8: 6*8-1];
assign o_send_data_little[ 7*8-1: 6*8] = o_send_data[ 6*8: 7*8-1];
assign o_send_data_little[ 8*8-1: 7*8] = o_send_data[ 7*8: 8*8-1];


// ------------------------------------------------------------------------------------------------------------------------
//     ---------------------------------------- send data   -----------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------

	localparam  SEND_STA_IDLE  = 4'd0;
    localparam  SEND_STA_CRC   = 4'd1;
    localparam  SEND_STA_SEND  = 4'd2;
    localparam  SEND_STA_ACK   = 4'd3;
    localparam  SEND_STA_CHECK = 4'd4;
    localparam  SEND_STA_SUCESS= 4'd5;
    localparam  SEND_STA_FAIL  = 4'd6;
    localparam  SEND_STA_RETRY = 4'd7;
    localparam  SEND_STA_PRE_FINISH = 4'd8;
    localparam  SEND_STA_FINISH = 4'd9;


reg [1:0] execu_result;
reg [3:0] curr_state;
reg [15:0] cal_time_cnt;
reg  [15:0] cfg_timeout;
//reg [7:0] wait_ack_cnt;

always @(posedge clk_i)begin
    if(rst_i)begin
        curr_state   <= 0;
        execu_result <= 0; // 00: None; 01:Success; 10:Timeout; 11:ACK Error
        o_send_start_p   <= 0;
        cal_time_cnt <= 0;
        o_user_req   <= 0;
        crc_cal_start   <= 0;
        o_send_data   <= 0;
        o_chl_a_execu_result <= 0;
        rcv_data_check_start_p <= 0;
        retry_cnt_current <= 0;
        o_chl_a_fb_data_ready_p <= 0;
    end else begin
        case(curr_state)
            SEND_STA_IDLE:begin
                if(i_chl_a_send_req)begin
                    o_user_req <=  'b1;
                    curr_state <= SEND_STA_CRC;
                end
                else
                curr_state <= 4'd0;
                crc_cal_start <= 0;
                o_send_start_p <= 0;
                execu_result <= 3'b000;
                cal_time_cnt <= 0;
            end
            SEND_STA_CRC:begin
                crc_cal_start <= 1'b1;
                curr_state <= crc_cal_done ? SEND_STA_SEND : curr_state;
                o_send_start_p <= 1'b0;
                execu_result <= 3'b000;
                cal_time_cnt <= 0;
            end
            SEND_STA_SEND:begin
                o_send_data <= {crc_check_data[8*6-1:0],send_crc_low,send_crc_high};

                if(i_send_ready & i_user_grant)begin
                    curr_state <= SEND_STA_ACK;
                    o_send_start_p <= 1'b1;
                end else begin 
                    curr_state <= curr_state;
                    o_send_start_p <= 1'b0;
                end
                crc_cal_start <= 1'b0;
                execu_result <= 3'b000;
                cal_time_cnt <= 0;
            end
            SEND_STA_ACK:begin
                o_send_start_p <= 1'b0;
                
                if(i_recv_finish_p)begin//收到反馈数据，要去做校验
                    curr_state <= SEND_STA_CHECK;
                    rcv_data_check_start_p <= 1'b1;
                end
                else begin//等不到完成标志时，要做超时判断
                    if(cal_time_cnt<cfg_timeout-1)begin//等待还未超时
                        curr_state <= curr_state;
                        cal_time_cnt <= cal_time_cnt + i_time_1s_vld;
                    end
                    else begin//超时了
                        if(i_slave_addr==Broadcast_ADDR)begin//如果是广播帧，不会有反馈，广播结束
                            curr_state <= SEND_STA_FAIL;
                            execu_result <= 3'b000;// 000: None; 001:Success; 010:Timeout; 011:ACK Error,000:Broadcast Finish
                        end
                        else begin
                            curr_state <= SEND_STA_RETRY;//需要重传
                            execu_result <= 3'b010;// 000: None; 001:Success; 010:Timeout; 011:ACK Error
                            cal_time_cnt <= 1'b0;
                        end
                    end
                end
            end
            SEND_STA_CHECK:begin
                rcv_data_check_start_p <= 1'b0;
                if(rcv_data_check_finish_p)begin
                    case(rcv_data_check_result)
                        3'b001:begin//001=no err
                            curr_state <= SEND_STA_SUCESS;
                            execu_result <= 3'b001;// 000: None; 001:Success; 010:Timeout; 011:ACK Error
                        end
                        3'b110,3'b111:begin//110=full/head cmp err ; 111 = crc err
                        //  curr_state <= SEND_STA_RETRY;//need retry 需要重传
                            curr_state <= SEND_STA_ACK;//继续等待下一帧数据
                        end
                        3'b100,3'b101,3'b010:begin//100=addr err ; 101=func code err ；010= err FunCode
                        //  curr_state <= SEND_STA_FAIL;//no need retry 不需重传
                            curr_state <= SEND_STA_ACK;//继续等待下一帧数据
                            execu_result <= 3'b011;// 000: None; 001:Success; 010:Timeout; 011:ACK Error
                        end
                        default:begin//other err
                        //  curr_state <= SEND_STA_FAIL;
                            curr_state <= SEND_STA_ACK;//继续等待下一帧数据
                            cal_time_cnt <= 'd0;
                            execu_result <= 3'b011;// 000: None; 001:Success; 010:Timeout; 011:ACK Error
                        end
                    endcase
                end
            end
            SEND_STA_SUCESS:begin//校验反馈数据完毕，解析收到的数据
                curr_state <= SEND_STA_PRE_FINISH;
                o_chl_a_fb_data_ready_p <= 1'b1;
                o_chl_a_execu_result <= execu_result;
            end
            SEND_STA_FAIL:begin
                curr_state <= SEND_STA_PRE_FINISH;
                o_chl_a_execu_result <= execu_result;
            end
            SEND_STA_RETRY:begin
                if(retry_cnt_current>=i_retry_cnt)begin
                    curr_state <= SEND_STA_PRE_FINISH;
                    execu_result <= 3'b011;// 000: None; 001:Success; 010:Timeout; 011:ACK Error
                end
                else begin
                    retry_cnt_current <= retry_cnt_current + 1'b1;
                    curr_state <= SEND_STA_SEND;
                end
            end
            SEND_STA_PRE_FINISH:begin
                o_chl_a_fb_data_ready_p <= 0;
                o_user_req <= 0;
                o_send_start_p  <= 0;
                execu_result    <= 3'b00;
                cal_time_cnt    <= 0;
                rcv_data_check_start_p <= 0;
                retry_cnt_current <= 0;
                if(i_chl_a_send_req==0)begin
                    curr_state  <= SEND_STA_FINISH;
                end
            end
            
            SEND_STA_FINISH:begin//后方模块接收完成标志后拉低请求慢一拍，这里要多等一拍再结束
                curr_state      <= 4'd0;
            end
            default:begin
                curr_state      <= 4'd0;
                o_send_start_p  <= 0;
                execu_result    <= 3'b00;
                cal_time_cnt    <= 0;
            end
        endcase
    end
end

always @(posedge clk_i)begin
    if(rst_i)begin
        o_send_length  <= 8'b0;
        cfg_timeout <= 'd0;
    end else begin
        o_send_length <= 8'd8;
        cfg_timeout <= i_resp_tout;
    end
end

// ------------------------------------------------------------------------------------------------------------------------
//     ---------------------------------------- recv data   -----------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------

reg [2:0]rcv_data_check_state;
reg [15:0]rcv_data_len;
reg [15:0]rcv_data_crc_field;

//------------------- rcv CRC ------------------

reg [7:0] rcv_slave_addr;
reg [7:0] rcv_func_code;

always @(posedge clk_i)begin
    if(rst_i)begin
        rcv_slave_addr <= 0;
        rcv_func_code <= 0;
    end
    else begin
        if(i_recv_finish_p)begin
            rcv_slave_addr = i_recv_data[7:0];
            rcv_func_code <= i_recv_data[15:8];
        end

    end
end

	localparam  RCV_CHK_STA_IDLE  = 3'd0;
    localparam  RCV_CHK_STA_CRC  = 3'd1;
    localparam  RCV_CHK_STA_CRC_FINISH  = 3'd2;
    localparam  RCV_CHK_STA_FULL_CHK= 3'd3; 
    localparam  RCV_CHK_STA_HEAD_CHK= 3'd4; 
    localparam  RCV_CHK_STA_DATA= 3'd5; 
    localparam  RCV_CHK_STA_FINISH	= 3'd6; 


always @(posedge clk_i)begin
    if(rst_i)begin
        rcv_data_check_state <= RCV_CHK_STA_IDLE;
        rcv_data_len <= 0;
        rcv_data_check_result <= 0;
        rcv_data_check_finish_p <= 0;
    end else begin
        case(rcv_data_check_state)
            RCV_CHK_STA_IDLE:begin
                 if(rcv_data_check_start_p)begin
                    if(i_slave_addr==rcv_slave_addr)begin//从站地址匹配，要去解析功能码
                        case(rcv_func_code)
                            8'h06:begin//setting,need full compile 写寄存器消息，要整帧校验
                                rcv_data_len <= {i_recv_data[23:16],i_recv_data[31:24]};
                                rcv_data_check_state <= RCV_CHK_STA_FULL_CHK;//功能码一致，要整帧校验
                            end
                            default:begin//未识别的消息类型，报错并结束
                                rcv_data_check_state <= RCV_CHK_STA_FINISH;
                                rcv_data_check_result <= 3'b101;//110=i_func_code miss match
                            end
                        endcase
                    end
                    else begin//从站地址不匹配，报错并结束
                        rcv_data_check_state <= RCV_CHK_STA_FINISH;
                        rcv_data_check_result <= 3'b100;//100=slave addr miss match
                    end
                 end
            end
            RCV_CHK_STA_FULL_CHK:begin
                if(rcv_data_big[0:8*8-1]==o_send_data[0:8*8-1])begin//校验结果收发一致
                    rcv_data_check_result <= 3'b001;//001 = ok
                end
                else begin//不一样则报错退出
                    rcv_data_check_result <= 3'b110;//110 = full check err
                end
                rcv_data_check_state <= RCV_CHK_STA_FINISH;
            end
            RCV_CHK_STA_FINISH:begin
                rcv_data_check_state <= RCV_CHK_STA_IDLE;
            end
            default:begin
                rcv_data_check_state <= RCV_CHK_STA_IDLE;
            end
        endcase
        rcv_data_check_finish_p <= (rcv_data_check_state == RCV_CHK_STA_FINISH);
    end
end

// ------------------ big -------------- little ------------
assign rcv_data_big[  0 : 8*1 -1] = i_recv_data[8*1 -1 :  0 ];
assign rcv_data_big[8*1 : 8*2 -1] = i_recv_data[8*2 -1 :8*1 ];
assign rcv_data_big[8*2 : 8*3 -1] = i_recv_data[8*3 -1 :8*2 ];
assign rcv_data_big[8*3 : 8*4 -1] = i_recv_data[8*4 -1 :8*3 ];
assign rcv_data_big[8*4 : 8*5 -1] = i_recv_data[8*5 -1 :8*4 ];
assign rcv_data_big[8*5 : 8*6 -1] = i_recv_data[8*6 -1 :8*5 ];
assign rcv_data_big[8*6 : 8*7 -1] = i_recv_data[8*7 -1 :8*6 ];
assign rcv_data_big[8*7 : 8*8 -1] = i_recv_data[8*8 -1 :8*7 ];


//-------------------------- CRC -----------------------

CRC16_modbus #(
   .RAM_DWIDTH       (7               ) //7*7=49bit >  8*6=48bit
)U_CRC16_modbus(
    .sys_clk         (clk_i           ),
    .rst_n           (~rst_i          ),
    .iv_crc_data     (crc_check_data  ),
    .i_crc_cal_start (crc_cal_start   ),
    .iv_data_length  (6               ),
    .o_crc_cal_done  (crc_cal_done    ),
    .ov_crc_reg      (crc_out         )
);

// ------------- Debug Start  -----------------------
/*
ila_1 ila_1_u1 (
	.clk(clk_i), // input wire clk

	.probe0(i_chl_a_send_req), // input wire [0:0]  probe0  
	.probe1(o_send_start_p), // input wire [0:0]  probe1 
	.probe2(i_send_ready), // input wire [0:0]  probe2 
	.probe3(rcv_data_check_start_p), // input wire [0:0]  probe3 
	.probe4(i_func_code), // input wire [3:0]  probe4 
	.probe5(i_data_len), // input wire [7:0]  probe5 
	.probe6({1'b0,rcv_data_check_state,curr_state}), // input wire [7:0]  probe6 
	.probe7({execu_result,o_chl_a_execu_result,rcv_data_check_result}), // input wire [7:0]  probe7 
	.probe8(o_user_req), // input wire [0:0]  probe8 
	.probe9(i_user_grant), // input wire [0:0]  probe9 
	.probe10(rcv_crc_chk_ok), // input wire [0:0]  probe10 
	.probe11(i_recv_finish_p), // input wire [0:0]  probe11 
	.probe12(rcv_crc_work_en), // input wire [0:0]  probe12 
	.probe13(0), // input wire [0:0]  probe13 
	.probe14(0), // input wire [0:0]  probe14 
	.probe15(0),// input wire [0:0]  probe15
    .probe16(i_data[15:8]), // input wire [7:0]  probe16
	.probe17(i_data[7:0]), // input wire [7:0]  probe17
	.probe18(crc_out[15:8]), // input wire [7:0]  probe18
	.probe19(crc_out[7:0]), // input wire [7:0]  probe19
	.probe20(rcv_data_crc_field[15:8]), // input wire [7:0]  probe20
	.probe21(rcv_data_crc_field[7:0]), // input wire [7:0]  probe21
	.probe22(rcv_slave_addr), // input wire [7:0]  probe22
	.probe23(i_slave_addr) // input wire [7:0]  probe23
);
*/

// ------------- Debug End  -----------------------
endmodule
