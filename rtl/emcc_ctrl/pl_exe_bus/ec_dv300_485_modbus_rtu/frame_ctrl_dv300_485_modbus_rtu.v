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
    ,input       [31:0]     i_data        //控制数据帧
    ,input       [7:0]      i_data_len    //数据长度
    ,input       [15:0]     i_start_addr  //起始地址
//
    ,output  reg            o_user_req
    ,input                  i_user_grant
    ,output  reg  [31:0]    o_fb_data_frame
    ,input                  i_chl_a_send_req
    ,output reg             o_chl_a_fb_data_ready_p
    ,output reg  [2:0]      o_chl_a_execu_result
    ,input                  i_chl_c_send_req
    ,output reg             o_chl_c_fb_data_ready_p
    ,output reg  [2:0]      o_chl_c_execu_result
    ,output reg             o_send_start_p
    ,input                  i_send_ready
    ,output reg  [63:0]     o_send_data
    ,output reg  [7:0]      o_send_length 
    ,input       [79:0]     i_recv_data
    ,input                  i_recv_data_ok
);

localparam  Broadcast_ADDR = 8'h00;

reg  chl_a_en;

reg  [2:0]rcv_data_check_result;
wire [0:8*10-1] rcv_data_big;
reg       rcv_data_check_start_p;
reg       rcv_data_check_finish_p;
reg  [7:0] retry_cnt_current;
reg  [15:0] rcv_data_field_1;
reg  [15:0] rcv_data_field_2;
reg  [15:0] rcv_data_field_3;
reg  [15:0] rcv_data_field_4;
reg         fb_data_ready_p ;
//-------------------------- CRC -----------------------

wire [7:0] CRC_HIGH ;
wire [7:0] CRC_LOW ;
reg  [8*6-1:0] crc_check_data;
reg  crc_cal_start;
wire crc_cal_done;
wire[15:0] crc_out;
CRC16_modbus #(
   .RAM_DWIDTH     (RAM_DWIDTH   )
)U_CRC16_modbus(
    .sys_clk(clk_i),   
    .rst_n(~rst_i),
    
    .iv_crc_data     (crc_check_data),
    .i_crc_cal_start (crc_cal_start),
    .iv_data_length  (6),//目前都是6字节
    .o_crc_cal_done  (crc_cal_done),
    .ov_crc_reg      (crc_out)
);


assign CRC_HIGH = crc_out[15:8];
assign CRC_LOW  = crc_out[7:0];

//
always @(posedge clk_i)begin
    if(rst_i)begin
        crc_check_data <= 0;
    end
    else begin
        case(i_func_code)
            8'h03:crc_check_data <= {i_slave_addr,8'h03,i_start_addr,8'h0,i_data_len};//data_len最大为4
            8'h06:crc_check_data <= {i_slave_addr,8'h06,i_start_addr,i_data[15:0]};//ctl_data_field含义是设置内容
            default:crc_check_data <= 0;
        endcase
    end
end

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
        o_fb_data_frame  <= 0;
        o_user_req   <= 0;
        crc_cal_start   <= 0;
        o_send_data   <= 0;
        chl_a_en <= 0;
        o_chl_a_execu_result <= 0;
        o_chl_c_execu_result <= 0;
        rcv_data_check_start_p <= 0;
        retry_cnt_current <= 0;
        fb_data_ready_p <= 0;
    end else begin
        case(curr_state)
            SEND_STA_IDLE:begin
                if(i_chl_a_send_req)begin
                    o_user_req <=  'b1;
                    chl_a_en <= 1'b1;
                    curr_state <= SEND_STA_CRC;
                end
                else if(i_chl_c_send_req)begin
                    o_user_req <=  'b1;
                    chl_a_en <= 1'b0;
                    curr_state <= SEND_STA_CRC;
                end
                else begin
                    o_user_req <= 'b0;
                    chl_a_en <= 1'b0;
                    curr_state <= 4'd0;
                end
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
                o_send_data <= {crc_check_data[8*6-1:0],CRC_LOW,CRC_HIGH};

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
                
                if(i_recv_data_ok)begin//收到反馈数据，要去做校验
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
                o_fb_data_frame <= {rcv_data_field_1,rcv_data_field_2};
                fb_data_ready_p <= 1'b1;
                if(chl_a_en)begin
                    o_chl_a_execu_result <= execu_result;
                end
                else begin
                    o_chl_c_execu_result <= execu_result;
                end
            end
            SEND_STA_FAIL:begin
                curr_state <= SEND_STA_PRE_FINISH;
                o_fb_data_frame <= 0;
                if(chl_a_en)begin
                    o_chl_a_execu_result <= execu_result;
                end
                else begin
                    o_chl_c_execu_result <= execu_result;
                end
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
                fb_data_ready_p <= 0;
                o_user_req <= 0;
                o_send_start_p  <= 0;
                execu_result    <= 3'b00;
                cal_time_cnt    <= 0;
                rcv_data_check_start_p <= 0;
                retry_cnt_current <= 0;
                if(chl_a_en)begin
                    if(i_chl_a_send_req==0)
                        curr_state  <= SEND_STA_FINISH;
                end
                else begin
                    if(i_chl_c_send_req==0)
                        curr_state  <= SEND_STA_FINISH;
                end
            end
            
            SEND_STA_FINISH:begin//后方模块接收完成标志后拉低请求慢一拍，这里要多等一拍再结束
                chl_a_en <= 1'b0;
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
        o_chl_a_fb_data_ready_p <= 0;
        o_chl_c_fb_data_ready_p <= 0;
    end
    else begin
         o_chl_a_fb_data_ready_p <=  fb_data_ready_p & chl_a_en;
         o_chl_c_fb_data_ready_p <=  fb_data_ready_p & ~chl_a_en;
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
reg      rcv_crc_work_en;
reg      rcv_crc_chk_ok;

//------------------- rcv CRC ------------------

reg [15:0] crc_rcv;
reg  [RAM_DWIDTH*RAM_DWIDTH-1-16:0] crc_check_data_rcv;
reg  crc_cal_start_rcv;
wire crc_cal_done_rcv;
wire[15:0] crc_out_rcv;
reg [7:0] crc_data_len_rcv;
reg [7:0] rcv_slave_addr;
reg [7:0] rcv_func_code;
reg [7:0] rcv_err_func_code;
reg       rcv_err_func_code_en;

CRC16_modbus #(
   .RAM_DWIDTH     (RAM_DWIDTH   )
)U_CRC16_modbus_rcv(
    .sys_clk(clk_i),   
    .rst_n(~rst_i),
    
    .iv_crc_data     (crc_check_data_rcv),
    .i_crc_cal_start (crc_cal_start_rcv),
    .iv_data_length  (crc_data_len_rcv),//
    .o_crc_cal_done  (crc_cal_done_rcv),
    .ov_crc_reg      (crc_out_rcv)
);

always @(posedge clk_i)begin
    if(rst_i)begin
        rcv_crc_chk_ok <= 0;
        rcv_slave_addr <= 0;
        rcv_func_code <= 0;
        rcv_err_func_code <= 0;
        rcv_err_func_code_en <= 0;
    end
    else begin
        if(i_recv_data_ok)begin
            rcv_slave_addr = i_recv_data[7:0];
            rcv_func_code <= i_recv_data[15:8];
            rcv_err_func_code <= i_func_code+8'h80;//功能码+0x80是对应的报错功能码
        end

        rcv_err_func_code_en <= (rcv_func_code==rcv_err_func_code);

        if(rcv_data_check_state!=0)begin
            if(crc_cal_done_rcv)begin
                rcv_crc_chk_ok <= (rcv_data_crc_field==crc_out_rcv);
            end
        end
        else begin
            rcv_crc_chk_ok <= 1'b0;
        end
    end
end

//将接收到的数据按字节先后顺序调整为从左到右，才能用于CRC计算
always @(posedge clk_i)begin
    if(rst_i)begin
        crc_check_data_rcv  <= 0;
    end
    else begin
        case(crc_data_len_rcv)
             3:crc_check_data_rcv <={112'h0,rcv_data_big[0:8* 3-1]};
             4:crc_check_data_rcv <={104'h0,rcv_data_big[0:8* 4-1]};
             5:crc_check_data_rcv <= {96'h0,rcv_data_big[0:8* 5-1]};
             6:crc_check_data_rcv <= {88'h0,rcv_data_big[0:8* 6-1]};
             7:crc_check_data_rcv <= {80'h0,rcv_data_big[0:8* 7-1]};
             8:crc_check_data_rcv <= {72'h0,rcv_data_big[0:8* 8-1]};
            default:crc_check_data_rcv  <= 0;
        endcase
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
        crc_cal_start_rcv <= 0;
        crc_data_len_rcv <= 0;
        rcv_crc_work_en <= 0;
        rcv_data_len <= 0;
        rcv_data_check_result <= 0;
        rcv_data_check_finish_p <= 0;
        rcv_data_field_1 <= 0;
        rcv_data_field_2 <= 0;
        rcv_data_field_3 <= 0;
        rcv_data_field_4 <= 0;
    end else begin
        case(rcv_data_check_state)
            RCV_CHK_STA_IDLE:begin
                 if(rcv_data_check_start_p)begin
                    rcv_crc_work_en <= 1'b1;
                    if(i_slave_addr==rcv_slave_addr)begin//从站地址匹配，要去解析功能码
                        case(rcv_func_code)
                            8'h03:begin//read
                                rcv_data_len <= {i_recv_data[23:16],i_recv_data[31:24]};
                                crc_data_len_rcv<= i_recv_data[23:16]+4;//实际读到的业务数据长度+4是需要做crc的字节数（从站地址1Byte+功能码1byte+长度值1Byte）
                                rcv_data_check_state <= RCV_CHK_STA_CRC;//功能码一致，还要等crc校验结果
                            end
                            8'h06:begin//setting,need full compile 写寄存器消息，要整帧校验
                                rcv_data_len <= {i_recv_data[23:16],i_recv_data[31:24]};
                                rcv_data_check_state <= RCV_CHK_STA_FULL_CHK;//功能码一致，要整帧校验
                            end
                            8'h83,8'h86:begin//err func code
                                rcv_data_len <= 0;//反馈报错消息时，长度值填0表示当前是出错回报消息
                                crc_data_len_rcv<= {i_recv_data[23:16],i_recv_data[31:24]}+4;//实际读到的业务数据长度+4是需要做crc的字节数（从站地址1Byte+功能码1byte+长度值2Byte）
                                rcv_data_check_state <= RCV_CHK_STA_CRC;//返回的是业务报错功能码，要提取报错编码
                                rcv_data_check_result <= 3'b010;//010= ack err code
                            end
                            default:begin//其他未识别的帧，报错并结束
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
            RCV_CHK_STA_CRC:begin//crc check
                case(rcv_data_len)
                    0:rcv_data_crc_field <= i_recv_data[8*5-1:8*3];//len=0代表当前是出错反馈消息，crc码在固定第四第五字节
                    2:rcv_data_crc_field <= i_recv_data[8*8-1:8*6];//{crc_hign,crc_low}
                    4:rcv_data_crc_field <= i_recv_data[8*10-1:8*8];
                    default:rcv_data_crc_field<=0;
                endcase
                crc_cal_start_rcv <= 1'b1;
                rcv_data_check_state <= RCV_CHK_STA_CRC_FINISH;
            end
            RCV_CHK_STA_CRC_FINISH:begin
                crc_cal_start_rcv <= 1'b0;
                if(crc_cal_done_rcv)begin
                    rcv_data_check_state <= RCV_CHK_STA_DATA;//crc校验完后，要去提取数据字段
                    if(rcv_data_crc_field==crc_out_rcv)begin
                        if(rcv_err_func_code_en)//反馈的是报错码
                            rcv_data_check_result <= 3'b010;//010 = err FunCode
                        else
                            rcv_data_check_result <= 3'b001;//001 = ok 
                    end
                    else begin
                        rcv_data_check_result <= 3'b111;//111=crc err
                    end
                end
            end
            RCV_CHK_STA_FULL_CHK:begin
                if(rcv_data_big[0:8*8-1]==o_send_data[8*8-1:0])begin//校验结果收发一致
                    rcv_data_check_result <= 3'b001;//001 = ok
                end
                else begin//不一样则报错退出
                    rcv_data_check_result <= 3'b110;//110 = full check err
                end
                rcv_data_check_state <= RCV_CHK_STA_FINISH;
            end
            RCV_CHK_STA_DATA:begin
                rcv_data_check_state <= RCV_CHK_STA_FINISH;
            end
            RCV_CHK_STA_FINISH:begin
                rcv_crc_work_en <= 1'b0;
                rcv_data_check_state <= RCV_CHK_STA_IDLE;
            end
            default:begin
                rcv_crc_work_en <= 1'b0;
                rcv_data_check_state <= RCV_CHK_STA_IDLE;
            end
        endcase
        rcv_data_check_finish_p <= (rcv_data_check_state == RCV_CHK_STA_FINISH);
    end
end

//提取收到的数据字段
always @(posedge clk_i)begin
    if(rst_i)begin
        rcv_data_field_1 <= 0;
        rcv_data_field_2 <= 0;
    end else begin
        if(rcv_err_func_code_en)begin//返回报错功能码，提取错误解释码
            rcv_data_field_1 <= {8'h0,i_recv_data[23:16]};
            rcv_data_field_2 <= 0;
        end
        else if(rcv_func_code==8'h06)begin//0x06,0x10=写寄存器后返回校验帧，不提取数据
            rcv_data_field_1 <= 0;
            rcv_data_field_2 <= 0;
        end
        else begin
            case(rcv_data_len)//按字长,提取有效数据，并将小端转为大端，高位补0。目前只支持最多2个寄存器（4字节）
                0:begin//len=0 特指当前是出错回报消息，报错含义码在第三个字节
                    rcv_data_field_1 <= {8'h0,i_recv_data[23:16]};
                    rcv_data_field_2 <= 0;
                end
                2:begin
                    rcv_data_field_1[15:8] <= i_recv_data[8*4-1:8*3];//big
                    rcv_data_field_1[ 7:0] <= i_recv_data[8*5-1:8*4];//little
                    rcv_data_field_2 <= 0;
                end
                4:begin
                    rcv_data_field_1[15:8] <= i_recv_data[8*4-1:8*3];//big
                    rcv_data_field_1[ 7:0] <= i_recv_data[8*5-1:8*4];//little
                    rcv_data_field_2[15:8] <= i_recv_data[8*6-1:8*5];
                    rcv_data_field_2[ 7:0] <= i_recv_data[8*7-1:8*6];
                end

            default:begin
                    rcv_data_field_1 <= 0;
                    rcv_data_field_2 <= 0;
                end
            endcase
        end
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
assign rcv_data_big[8*8 : 8*9 -1] = i_recv_data[8*9 -1 :8*8 ];
assign rcv_data_big[8*9 : 8*10-1] = i_recv_data[8*10-1 :8*9 ];

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
	.probe11(i_recv_data_ok), // input wire [0:0]  probe11 
	.probe12(rcv_crc_work_en), // input wire [0:0]  probe12 
	.probe13(crc_cal_done_rcv), // input wire [0:0]  probe13 
	.probe14(0), // input wire [0:0]  probe14 
	.probe15(0),// input wire [0:0]  probe15
    .probe16(i_data[15:8]), // input wire [7:0]  probe16
	.probe17(i_data[7:0]), // input wire [7:0]  probe17
	.probe18(crc_out_rcv[15:8]), // input wire [7:0]  probe18
	.probe19(crc_out_rcv[7:0]), // input wire [7:0]  probe19
	.probe20(rcv_data_crc_field[15:8]), // input wire [7:0]  probe20
	.probe21(rcv_data_crc_field[7:0]), // input wire [7:0]  probe21
	.probe22(rcv_slave_addr), // input wire [7:0]  probe22
	.probe23(i_slave_addr) // input wire [7:0]  probe23
);
*/

// ------------- Debug End  -----------------------
endmodule
