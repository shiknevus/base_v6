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


module frame_ctrl_superisys_485#(
    parameter  RAM_DWIDTH  =   11
) (
     input   wire            i_clk
    ,input   wire            i_rst
    ,input   wire            i_time_1s_vld 
    ,input   wire            i_time_1ms_vld
//输入参数
    ,input   wire [7:0]      i_slave_addr    //从站地址
    //,input   wire [15:0]     i_resp_tout     //响应超时时间		s
    //,input   wire [7:0]      i_retry_cnt     //重试次数
    ,input   wire [31:0]     i_send_data_field_1//发送数据1
    //,input   wire [31:0]     i_send_data_field_2//发送数据2
    //,input   wire [31:0]     i_send_data_field_3//发送数据3
    //,input   wire [15:0]     i_start_addr    //起始地址

    ,output  reg             o_user_req
    ,input   wire            i_user_grant
    ,output  reg  [31:0]     o_fb_data_frame_1 //返回数据1
    ,output  reg  [31:0]     o_fb_data_frame_2 //返回数据2
    //,output  wire [31:0]     o_fb_data_frame_3 //返回数据3
    
    ,input   wire            i_chl_a_send_req
    ,input   wire [7:0]      i_bhv_a_id            //1=写入行为; 2=读UID;  3=读取行为; 4=读取比对行为
    ,output  reg             o_chl_a_fb_data_ready_p
    ,output  reg  [2:0]      o_chl_a_execu_result

     //数据收发（主从模式公用）
    ,output  reg             o_send_start_p 
    ,output  reg  [7:0]      o_send_length
    ,input   wire [8*13-1:0] i_recv_data
    ,input   wire            i_recv_finish_p
    // 主板uart数据接口
    ,input   wire            i_send_ready    //空闲，可以发送的标志
    ,output  reg  [8*13-1:0] o_send_data//主板模式发送数据。写行为帧长13字节，此处必须≥13字节，否则高16bit（从站地址+功能码）会被截断
    //从板数据接口
    ,input   wire            i_send_finish_p //发送完成（脉冲）
    ,input   wire [7:0]      i_slv_err_code
    ,output  reg  [7:0]      o_exp_recv_num //预期接收的字节数
    ,output  wire [8*13-1:0] o_send_data_little

);

	wire [15:0]	i_start_addr	= 16'h0000;

    localparam  Broadcast_ADDR = 8'hFF;
    localparam  UID_Start_ADDR = 16'hE000;
    localparam  RESP_TOUT_S    = 16'd2;//应答等待超时（秒）。超时后广播结束/重传，不能设太长，否则主动行为状态机会长时间停在状态7

    localparam  WRITE_TAG = 8'd1;//1=写入行为
    localparam  READ_UID  = 8'd2;//2=读UID
    localparam  READ_TAG  = 8'd3;//3=读取行为
    localparam  READ_AND_COMP = 8'd4;//4=读取比对行为

    //assign o_fb_data_frame_3 = 0;
reg  [7:0]      bhv_id                 ;
reg             work_start_p           ;
reg  [7:0]      func_code              ;
reg  [2:0]      rcv_data_check_result  ;
wire [0:8*13-1] rcv_data_big           ;
reg             rcv_data_check_start_p ;
reg             rcv_data_check_finish_p;
reg             rcv_crc_work_en        ;
reg  [7:0]      retry_cnt_current      ;
reg  [15:0]     rcv_data_field_1       ;
reg  [15:0]     rcv_data_field_2       ;
reg  [15:0]     rcv_data_field_3       ;
reg  [15:0]     rcv_data_field_4       ;
reg  [0:8*13-1] send_frame             ;
reg             crc_cal_start_send     ;
reg  [8*11-1:0]  crc_check_data_send    ;
reg  [7:0]      crc_data_length_send   ;
wire            crc_cal_done           ;
wire[15:0]      crc_out                ;
reg [7:0]       send_crc_high          ;
reg [7:0]       send_crc_low           ;
// ------------- slaver frame head ---------------
    wire [7:0]    m2s_tail_symbol;   //结束符
//  reg  [7:0]    m2s_send_num   ;   //发送的字节数
    wire [3:0]    m2s_start_send ;   //开始发送
    wire [3:0]    m2s_baud_rate  ;   //波特率

   assign m2s_baud_rate = 4'd0;         //0:115200
   assign m2s_tail_symbol = 8'h00;
   assign m2s_start_send  = 0;


//covn bhv_id to func_code
//由行为ID转换为功能码
always @(posedge i_clk)begin
    if(i_rst)begin
        func_code <= 0;
    end
    else begin
            case(bhv_id)
                READ_UID     : func_code <= 8'h03;//读UID      = 读命令0x03 
                READ_TAG     : func_code <= 8'h03;//读标签内容  = 读命令0x03
                READ_AND_COMP: func_code <= 8'h03;//读标签并比对 = 读命令0x03
                WRITE_TAG    : func_code <= 8'h10;//写标签 = 写多个命令0x10
                default      : func_code <= 8'h00;
            endcase
        end
    end

always @(*)begin
    case(bhv_id)
        READ_UID     :crc_check_data_send = {40'd0,i_slave_addr,8'h03,UID_Start_ADDR,16'h4};
        READ_TAG,
        READ_AND_COMP:crc_check_data_send = {40'd0,i_slave_addr,8'h03,i_start_addr,16'h2};
        WRITE_TAG    :crc_check_data_send = {i_slave_addr,8'h10,i_start_addr,16'h2,8'h4,i_send_data_field_1};
        default      :crc_check_data_send = 0;
    endcase
end

//由行为ID，生成待做crc计算的数据（大端格式），组合逻辑输出
//always @(posedge i_clk)begin
//    if(i_rst)begin
//        crc_check_data_send <= 0;
//    end
//    else begin
//        case(bhv_id)
//            READ_UID     :crc_check_data_send <= {40'd0,i_slave_addr,8'h03,UID_Start_ADDR,16'h4};//读UID时是定长消息，{设备地址，命令码0x03,固定地址起点0x800E,data_len固定为4}
//            READ_TAG,
//            READ_AND_COMP:crc_check_data_send <= {40'd0,i_slave_addr,8'h03,i_start_addr,16'h2};//目前支持读2个寄存器组 （4字节）
//            WRITE_TAG    :crc_check_data_send <= {i_slave_addr,8'h10,i_start_addr,16'h2,8'h4,i_send_data_field_1};//i_ctl_data_field 高16bit是数据1，低16bit是数据2
//            default      :crc_check_data_send <= 0;
//        endcase
//    end
//end

//给大端格式的数据末尾添加CRC值，并补0
always @(posedge i_clk)begin
    if(i_rst)begin
        send_frame <= 0;
    end
    else begin
            if(bhv_id==WRITE_TAG)
                send_frame <= {crc_check_data_send,send_crc_low,send_crc_high};//写行为，固定13字节长
            else
                send_frame <= {crc_check_data_send,send_crc_low,send_crc_high,40'h0};//其他行为是固定10字节
        end
end

//将大端数据转为小端数据，从板接口用
assign o_send_data_little[ 1*8-1:   0] = send_frame[   0: 1*8-1];
assign o_send_data_little[ 2*8-1: 1*8] = send_frame[ 1*8: 2*8-1];
assign o_send_data_little[ 3*8-1: 2*8] = send_frame[ 2*8: 3*8-1];
assign o_send_data_little[ 4*8-1: 3*8] = send_frame[ 3*8: 4*8-1];
assign o_send_data_little[ 5*8-1: 4*8] = send_frame[ 4*8: 5*8-1];
assign o_send_data_little[ 6*8-1: 5*8] = send_frame[ 5*8: 6*8-1];
assign o_send_data_little[ 7*8-1: 6*8] = send_frame[ 6*8: 7*8-1];
assign o_send_data_little[ 8*8-1: 7*8] = send_frame[ 7*8: 8*8-1];
assign o_send_data_little[ 9*8-1: 8*8] = send_frame[ 8*8: 9*8-1];
assign o_send_data_little[10*8-1: 9*8] = send_frame[ 9*8:10*8-1];
assign o_send_data_little[11*8-1:10*8] = send_frame[10*8:11*8-1];
assign o_send_data_little[12*8-1:11*8] = send_frame[11*8:12*8-1];
assign o_send_data_little[13*8-1:12*8] = send_frame[12*8:13*8-1];


//用行为ID推算出发送长度值和计算CRC的长度值
always @(posedge i_clk)begin
    if(i_rst)begin
        o_send_length  <= 0; //发送长度值
        crc_data_length_send <= 0;//计算crc长度值
    end else begin
        case(bhv_id)//1=写入行为; 2=读UID;  3=读取行为; 4=读取比对行为
            READ_UID:begin
                o_send_length   <= 8'd8;
                crc_data_length_send <= 8'd6;
            end
			READ_TAG,READ_AND_COMP:begin//0x03读请求固定8字节（地址+功能码+起始地址+寄存器数+CRC），与读取的寄存器数无关
                o_send_length   <= 8'd8;
                crc_data_length_send <= 8'd6;
            end
            WRITE_TAG:begin
                o_send_length   <= 8'd13;
                crc_data_length_send <= 8'd11;
            end
            default:begin
                o_send_length   <= 8'd8;//for safe,default 8
                crc_data_length_send <= 8'd6;
            end
        endcase
    end
end

//用行为ID推算出发送和接收的消息字节数，用于组成报文头 （只在从板模式下使用）  
always @(posedge i_clk)begin
    if(i_rst)begin
        // m2s_send_num <= 8;
            o_exp_recv_num <= 15;
       end
       else begin
            case(bhv_id)//1=读UID; 2=读取比对行为;  3=写入行为; 4=读取行为
                READ_UID: begin //Modbus Func = 0x03 读寄存器
                //  m2s_send_num <= 8;
                    o_exp_recv_num <= 13;
                end
                READ_TAG,READ_AND_COMP: begin //Modbus Func = 0x03 读寄存器
                //  m2s_send_num <= 8;
                    o_exp_recv_num <= 9;
                end
                WRITE_TAG: begin //Modbus Func = 0x10 写单
                //  m2s_send_num <= 11;
                    o_exp_recv_num <= 8;//0x10回显帧固定8字节：地址+功能码+起始地址+寄存器数+CRC，与写入的寄存器数无关
                end
                default: begin
                //  m2s_send_num <= 8;
                    o_exp_recv_num <= 10;
                end
            endcase
       end
   end

//用行为ID推算出发送和接收的消息字节数，用于组成报文头 （只在从板模式下使用）  
always @(posedge i_clk)begin
    if(i_rst)begin
        send_crc_high <= 0;
        send_crc_low <= 0;
    end
    else begin
        if(crc_cal_done&(~rcv_crc_work_en))begin
            send_crc_high <= crc_out[15:8];
            send_crc_low  <= crc_out[7:0];
        end
    end
end


// -------------- Send Status-----------------

	localparam  SEND_STA_IDLE  = 4'd0;
	localparam  SEND_STA_START = 4'd1;
    localparam  SEND_STA_CRC   = 4'd2;
    localparam  SEND_STA_SEND  = 4'd3;
    localparam  SEND_STA_ACK   = 4'd4;
    localparam  SEND_STA_CHECK = 4'd5;
    localparam  SEND_STA_SUCESS= 4'd6;
    localparam  SEND_STA_FAIL  = 4'd7;
    localparam  SEND_STA_RETRY = 4'd8;
    localparam  SEND_STA_PRE_FINISH = 4'd9;
    localparam  SEND_STA_FINISH = 4'd10;
    localparam  SEND_STA_EXCPT = 4'd11;   //从站异常帧结束（不重传）


reg [1:0] execu_result;
reg [3:0] curr_state;
reg [19:0] cal_time_cnt;
//reg [7:0] wait_ack_cnt;
reg [7:0] rec_data_number;
always @(posedge i_clk)begin
    if(i_rst)begin
        curr_state   <= 0;
        execu_result <= 0; // 00: None; 01:Success; 10:Timeout; 11:ACK Error
        work_start_p <= 0;
        o_send_start_p   <= 0;
        cal_time_cnt <= 0;
        bhv_id <= 0;
        o_fb_data_frame_1  <= 0;
        o_fb_data_frame_2  <= 0;
        o_user_req   <= 0;
        rec_data_number   <= 0;
        crc_cal_start_send  <= 0;
//      crc_check_data_send   <= 0;
        o_send_data   <= 0;
        o_chl_a_execu_result <= 0;
        rcv_data_check_start_p <= 0;
        retry_cnt_current <= 0;
        o_chl_a_fb_data_ready_p <= 0;
    end else begin
        case(curr_state)
            SEND_STA_IDLE:begin
                if(i_chl_a_send_req)begin
                    work_start_p <= 1'b1;
                    o_user_req <=  'b1;
                    bhv_id <= i_bhv_a_id;
                    curr_state <= SEND_STA_START;
                end
                crc_cal_start_send <= 0;
                o_send_start_p <= 0;
                execu_result <= 3'b000;
                cal_time_cnt <= 0;
            end
            SEND_STA_START:begin
                curr_state <= SEND_STA_CRC; //Wait CRC data for 1 clk
            end
            SEND_STA_CRC:begin
                //crc_check_data_send <= {SUB_ADDR,8'h03,8'h00,8'h00,8'h00,8'h01};
                //crc_check_data_send <= {i_slave_addr,i_func_code,i_data_len,i_ctl_data_field[7:0]};
                work_start_p <= 1'b0;
                crc_cal_start_send <= 1'b1;
                curr_state <= crc_cal_done ? SEND_STA_SEND : curr_state;
                o_send_start_p <= 1'b0;
                execu_result <= 3'b000;
                cal_time_cnt <= 0;
            end
            SEND_STA_SEND:begin
                o_send_data <= {crc_check_data_send[8*11-1:0],send_crc_low,send_crc_high};
                if(i_send_ready & i_user_grant)begin
                    curr_state <= SEND_STA_ACK;
                    o_send_start_p <= 1'b1;
                end else begin 
                    curr_state <= curr_state;
                    o_send_start_p <= 1'b0;
                end
                crc_cal_start_send <= 1'b0;
                execu_result <= 3'b000;
                cal_time_cnt <= 0;
                rec_data_number <= 0;
            end
            SEND_STA_ACK:begin
                o_send_start_p <= 1'b0;

                if(i_recv_finish_p)begin//收到反馈数据，要去做校验
                    curr_state <= SEND_STA_CHECK;
                    rcv_data_check_start_p <= 1'b1;
                end
                else begin//等不到完成标志时，要做超时判断
                    //if(cal_time_cnt<i_resp_tout-1)begin//等待还未超时
					if(cal_time_cnt<RESP_TOUT_S-1)begin//等待还未超时
                        curr_state <= curr_state;
                        cal_time_cnt <= cal_time_cnt + i_time_1s_vld;
                    end
                    else begin//超时了
                        if(i_slave_addr==8'hFF)begin//如果是广播帧，不会有反馈，广播结束
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
                        3'b010:begin//010 = 从站应答异常帧（手册§7，如0BH=标签不在读取区域），重传无意义，直接结束
                            curr_state <= SEND_STA_EXCPT;//按执行失败结束，让主动行为状态机走40报警
                            execu_result <= 3'b011;// 000: None; 001:Success; 010:Timeout; 011:ACK Error
                        end
                        3'b100,3'b101:begin//100=addr err ; 101=func code err ；总线上其他设备的数据帧
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
                //field_1~4依次对应报文中第1~4个寄存器（大端），32bit拼接时保持寄存器顺序：低地址寄存器放在高位
                //行为2读UID：PARAM51={U0,U1,U2,U3}，PARAM52={U4,U5,U6,U7}，与标签真实UID字节顺序一致
                o_fb_data_frame_1 <= {rcv_data_field_1,rcv_data_field_2};
                o_fb_data_frame_2 <= {rcv_data_field_3,rcv_data_field_4};
                o_chl_a_fb_data_ready_p <= 1'b1;
                o_chl_a_execu_result <= execu_result;
            end
            SEND_STA_FAIL:begin
                curr_state <= SEND_STA_PRE_FINISH;
                o_fb_data_frame_1 <= 0;
                o_fb_data_frame_2 <= 0;
                o_chl_a_fb_data_ready_p <= 1'b1;//广播结束也要发完成脉冲，主动行为状态机才能离开后充分检查状态（状态7）
                o_chl_a_execu_result <= execu_result;
            end
            SEND_STA_EXCPT:begin//从站返回异常帧（如无标签时异常码0BH）：不重传，保留异常码并通知主动行为状态机
                curr_state <= SEND_STA_PRE_FINISH;
                o_fb_data_frame_1 <= {16'h0,rcv_data_field_1};//低8bit = MODBUS异常码（0BH=标签不在读取区域）
                o_fb_data_frame_2 <= 0;
                o_chl_a_fb_data_ready_p <= 1'b1;//发完成脉冲，主动行为状态机据此离开后充分检查状态
                o_chl_a_execu_result <= 3'b011;// 011:ACK Error，主动行为侧据此跳40报警、报警号110
            end
            SEND_STA_RETRY:begin
                //if(retry_cnt_current>=i_retry_cnt)begin
				 if(retry_cnt_current>=3)begin
                    o_user_req <= 0;
                    curr_state <= SEND_STA_PRE_FINISH;
                    execu_result <= 3'b11;// 000: None; 001:Success; 010:Timeout; 011:ACK Error
                    o_chl_a_fb_data_ready_p <= 1'b1;//重试耗尽也要发完成脉冲，主动行为状态机才能离开后充分检查状态（状态7）
                    o_chl_a_execu_result <= 3'b010;// 010:Timeout，主动行为侧据此跳40报警（报警号110）
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
                work_start_p    <= 1'b0;
                o_send_start_p  <= 0;
                execu_result    <= 3'b00;
                cal_time_cnt    <= 0;
                rec_data_number <= 0;
            end
        endcase
    end
end

// ------------------------------------------------------------------------------------------------------------------------
//     ---------------------------------------- recv data   -----------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------
reg [2:0]       rcv_data_check_state;
reg [7:0]       rcv_data_len        ;
reg [15:0]      rcv_data_crc_field  ;
reg             rcv_crc_chk_ok      ;
reg             rcv_crc_comp_finish ;
reg  [8*11-1:0] crc_check_data_rcv  ;
reg             crc_cal_start_rcv   ;


reg [7:0] crc_data_len_rcv    ;
reg [7:0] rcv_slave_addr      ;
reg [7:0] rcv_func_code       ;
reg [7:0] rcv_err_func_code   ;
reg       rcv_err_func_code_en;

always @(posedge i_clk)begin
    if(i_rst)begin
        rcv_crc_chk_ok <= 0;
        rcv_slave_addr <= 0;
        rcv_func_code <= 0;
        rcv_err_func_code <= 0;
        rcv_err_func_code_en <= 0;
        rcv_crc_comp_finish <= 0;
    end
    else begin
        rcv_crc_comp_finish <= crc_cal_done & rcv_crc_work_en;//crc模块分时复用，要区分是不是返回帧校验
        if(i_recv_finish_p)begin
            rcv_slave_addr = i_recv_data[7:0];
            rcv_func_code <= i_recv_data[15:8];
            rcv_err_func_code <= func_code+8'h80;//功能码+0x80是对应的报错功能码
        end

        rcv_err_func_code_en <= (rcv_func_code==rcv_err_func_code);

        if(crc_cal_done & rcv_crc_work_en)begin//crc模块分时复用，要区分是不是返回帧校验
            rcv_crc_chk_ok <= (rcv_data_crc_field==crc_out);
        end
    end
end

//将接收到的数据按字节先后顺序调整为从左到右，才能用于CRC计算
always @(posedge i_clk)begin
    if(i_rst)begin
        crc_check_data_rcv  <= 0;
    end
    else begin
        case(crc_data_len_rcv)//行为2读UID时为11，行为3和4读TAG（2寄存器）时是7; 行为1写TAG是6；反馈报错消息时是3
             3:crc_check_data_rcv <= {64'h0,rcv_data_big[0:8* 3-1]};
             5:crc_check_data_rcv <= {48'h0,rcv_data_big[0:8* 5-1]};
             6:crc_check_data_rcv <= {40'h0,rcv_data_big[0:8* 6-1]};
             7:crc_check_data_rcv <= {32'h0,rcv_data_big[0:8* 7-1]};//行为3/4读2个寄存器：地址+功能码+长度+4字节数据
            11:crc_check_data_rcv <=        rcv_data_big[0:8*11-1];
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

always @(posedge i_clk)begin
    if(i_rst)begin
        rcv_data_check_state <= RCV_CHK_STA_IDLE;
        crc_cal_start_rcv <= 0;
        crc_data_len_rcv <= 0;
        rcv_crc_work_en <= 0;
        rcv_data_len <= 0;
        rcv_data_crc_field <= 0;
        rcv_data_check_result <= 0;
        rcv_data_check_finish_p <= 0;
    end else begin
        case(rcv_data_check_state)
            RCV_CHK_STA_IDLE:begin
                 if(rcv_data_check_start_p)begin
                    rcv_crc_work_en <= 1'b1;
                    if(i_slave_addr==rcv_slave_addr)begin//从站地址匹配，要去解析功能码
                        case(rcv_func_code)
                            8'h03:begin//read
                                rcv_data_len <= i_recv_data[23:16];
                                crc_data_len_rcv<= i_recv_data[23:16]+3;//实际读到的业务数据长度+3是需要做crc的字节数（从地址1Byte+功能码1byte+长度值1Byte）,目前只可能是行为2读UID时为11，和行为3和4时的5
                                rcv_data_check_state <= RCV_CHK_STA_CRC;//功能码一致，还要等crc校验结果
                            end
                            8'h10:begin//setting,need full compile 写寄存器消息，要校验消息头
                                rcv_data_len <= 8'd3;//长度值固定
                                crc_data_len_rcv<= 8'd6;//长度值固定
                                rcv_data_check_state <= RCV_CHK_STA_HEAD_CHK;//功能码一致，要校验消息头
                            end
                            8'h83,8'h90:begin//err func code
                                rcv_data_len <= 0;//反馈报错消息时，长度值填0表示当前是出错回报消息
                                crc_data_len_rcv<= 3;//反馈报错消息时，是固定长度
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
                case(rcv_data_len)//依据协议，读取时字节数是读写寄存器数量的两倍，所以这里是双数。写命令的应答帧除外
                    0:rcv_data_crc_field <= i_recv_data[8*5-1:8*3];//len=0代表当前是出错反馈消息，crc码在固定第四第五字节
                    2:rcv_data_crc_field <= i_recv_data[8*7-1:8*5];//读1个寄存器2字节
                    3:rcv_data_crc_field <= i_recv_data[8*8-1:8*6];//func=0x10写命令的反馈帧，crc字段位置在第7第8字节处
                    4:rcv_data_crc_field <= i_recv_data[8*9-1:8*7];//行为3和行为4读2个寄存器4字节，应答帧共9字节，crc在最后两字节
                    8:rcv_data_crc_field <= i_recv_data[8*13-1:8*11];//目前行为2读UID是固定读4个寄存器8字节
                    default:rcv_data_crc_field<=0;//其他情况都是从出错了
                endcase
                crc_cal_start_rcv <= 1'b1;
                rcv_data_check_state <= RCV_CHK_STA_CRC_FINISH;
            end
            RCV_CHK_STA_CRC_FINISH:begin
                crc_cal_start_rcv <= 1'b0;
                if(rcv_crc_comp_finish)begin
                    rcv_data_check_state <= RCV_CHK_STA_DATA;//crc校验完后，要去提取数据字段
                    if(rcv_crc_chk_ok)begin
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
            RCV_CHK_STA_HEAD_CHK:begin
                if(rcv_data_big[0:8*6-1]==send_frame[0:8*6-1])begin//前六字节消息头校验结果收发一致
                    rcv_data_check_result <= 3'b001;//001 = ok
                    rcv_data_check_state <= RCV_CHK_STA_CRC;//严谨考虑，还需要看收到消息的CRC值正确与否
                end
                else begin//不一样则报错退出
                    rcv_data_check_result <= 3'b110;//110 = full/head check err
                    rcv_data_check_state <= RCV_CHK_STA_FINISH;
                end
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
always @(posedge i_clk)begin
    if(i_rst)begin
        rcv_data_field_1 <= 0;
        rcv_data_field_2 <= 0;
        rcv_data_field_3 <= 0;
        rcv_data_field_4 <= 0;
    end else begin
        if(rcv_err_func_code_en)begin//返回报错功能码，提取错误解释码
            rcv_data_field_1 <= {8'h0,i_recv_data[23:16]};
            rcv_data_field_2 <= 0;
            rcv_data_field_3 <= 0;
            rcv_data_field_4 <= 0;
        end
        else if(rcv_func_code==8'h10)begin//0x10=写寄存器后返回校验帧，不提取数据
            rcv_data_field_1 <= 0;
            rcv_data_field_2 <= 0;
            rcv_data_field_3 <= 0;
            rcv_data_field_4 <= 0;
        end
        else begin
            case(rcv_data_len)//按字长,提取有效数据，并将小端转为大端，高位补0。目前只支持最多4个寄存器（8字节）
                0:begin//len=0 特指当前是出错回报消息，报错含义码在第三个字节
                    rcv_data_field_1 <= {8'h0,i_recv_data[23:16]};
                    rcv_data_field_2 <= 0;
                    rcv_data_field_3 <= 0;
                    rcv_data_field_4 <= 0;
                end
                2:begin//读1个寄存器2字节
                    rcv_data_field_1[15:8] <= i_recv_data[8*4-1:8*3];//big
                    rcv_data_field_1[ 7:0] <= i_recv_data[8*5-1:8*4];//little
                    rcv_data_field_2 <= 0;
                    rcv_data_field_3 <= 0;
                    rcv_data_field_4 <= 0;
                end
                4:begin//行为3和行为4读2个寄存器4字节
                    rcv_data_field_1[15:8] <= i_recv_data[8*4-1:8*3];//big
                    rcv_data_field_1[ 7:0] <= i_recv_data[8*5-1:8*4];//little
                    rcv_data_field_2[15:8] <= i_recv_data[8*6-1:8*5];
                    rcv_data_field_2[ 7:0] <= i_recv_data[8*7-1:8*6];
                    rcv_data_field_3 <= 0;
                    rcv_data_field_4 <= 0;
                end
                8:begin//目前行为2读UID是固定读4个寄存器8字节
                    rcv_data_field_1[15:8] <= i_recv_data[8*4-1:8*3];//big
                    rcv_data_field_1[ 7:0] <= i_recv_data[8*5-1:8*4];//little
                    rcv_data_field_2[15:8] <= i_recv_data[8*6-1:8*5];
                    rcv_data_field_2[ 7:0] <= i_recv_data[8*7-1:8*6];
                    rcv_data_field_3[15:8] <= i_recv_data[8*8-1:8*7];
                    rcv_data_field_3[ 7:0] <= i_recv_data[8*9-1:8*8];
                    rcv_data_field_4[15:8] <= i_recv_data[8*10-1:8*9];
                    rcv_data_field_4[ 7:0] <= i_recv_data[8*11-1:8*10];
                end
            default:begin
                    rcv_data_field_1 <= 0;
                    rcv_data_field_2 <= 0;
                    rcv_data_field_3 <= 0;
                    rcv_data_field_4 <= 0;
                end
            endcase
        end
    end
end

// ------------------ big ------------ little ---------
assign rcv_data_big[   0 : 8* 1-1] = i_recv_data[8* 1-1 :   0];
assign rcv_data_big[8* 1 : 8* 2-1] = i_recv_data[8* 2-1 :8* 1];
assign rcv_data_big[8* 2 : 8* 3-1] = i_recv_data[8* 3-1 :8* 2];
assign rcv_data_big[8* 3 : 8* 4-1] = i_recv_data[8* 4-1 :8* 3];
assign rcv_data_big[8* 4 : 8* 5-1] = i_recv_data[8* 5-1 :8* 4];
assign rcv_data_big[8* 5 : 8* 6-1] = i_recv_data[8* 6-1 :8* 5];
assign rcv_data_big[8* 6 : 8* 7-1] = i_recv_data[8* 7-1 :8* 6];
assign rcv_data_big[8* 7 : 8* 8-1] = i_recv_data[8* 8-1 :8* 7];
assign rcv_data_big[8* 8 : 8* 9-1] = i_recv_data[8* 9-1 :8* 8];
assign rcv_data_big[8* 9 : 8*10-1] = i_recv_data[8*10-1 :8* 9];
assign rcv_data_big[8*10 : 8*11-1] = i_recv_data[8*11-1 :8*10];
assign rcv_data_big[8*11 : 8*12-1] = i_recv_data[8*12-1 :8*11];
assign rcv_data_big[8*12 : 8*13-1] = i_recv_data[8*13-1 :8*12];


// --------------------------- CRC -------------------------
wire  [8*13-1:0]crc_check_data  ;
wire  [7:0]     crc_data_length ;
wire            crc_cal_start   ;

assign crc_cal_start   = crc_cal_start_send|crc_cal_start_rcv;
//assign crc_check_data  = (rcv_crc_work_en) ? crc_check_data_rcv : {16'h0,crc_check_data_send} ;
assign crc_check_data  = (rcv_crc_work_en) ? crc_check_data_rcv : crc_check_data_send ;
assign crc_data_length = (rcv_crc_work_en) ? crc_data_len_rcv   : crc_data_length_send;

CRC16_modbus #(
   .RAM_DWIDTH       (11      ) //11*11=121bit >  8*13=104bit
)U_CRC16_modbus(
    .sys_clk         (i_clk           ),
    .rst_n           (~i_rst          ),
    .iv_crc_data     (crc_check_data  ),
    .i_crc_cal_start (crc_cal_start   ),
    .iv_data_length  (crc_data_length ),
    .o_crc_cal_done  (crc_cal_done    ),
    .ov_crc_reg      (crc_out         )
);

// ------------- Debug Start  -----------------------

//ila_1 ila_1_u1 (
//	.clk(i_clk), // input wire clk
//
//	.probe0(i_chl_a_send_req), // input wire [0:0]  probe0  
//	.probe1(o_send_start_p), // input wire [0:0]  probe1 
//	.probe2(i_send_ready), // input wire [0:0]  probe2 
//	.probe3(rcv_data_check_start_p), // input wire [0:0]  probe3 
//	.probe4(func_code), // input wire [3:0]  probe4 
//	.probe5(i_bhv_a_id), // input wire [7:0]  probe5 
//	.probe6({1'b0,rcv_data_check_state,curr_state}), // input wire [7:0]  probe6 
//	.probe7({execu_result,o_chl_a_execu_result,rcv_data_check_result}), // input wire [7:0]  probe7 
//	.probe8(o_user_req), // input wire [0:0]  probe8 
//	.probe9(i_user_grant), // input wire [0:0]  probe9 
//	.probe10(rcv_crc_chk_ok), // input wire [0:0]  probe10 
//	.probe11(i_recv_finish_p), // input wire [0:0]  probe11 
//	.probe12(rcv_crc_work_en), // input wire [0:0]  probe12 
//	.probe13(0), // input wire [0:0]  probe13 
//	.probe14(0), // input wire [0:0]  probe14 
//	.probe15(0),// input wire [0:0]  probe15
//    .probe16(bhv_id), // input wire [7:0]  probe16
//	.probe17(func_code), // input wire [7:0]  probe17
//	.probe18(crc_out[15:8]), // input wire [7:0]  probe18
//	.probe19(crc_out[7:0]), // input wire [7:0]  probe19
//	.probe20(rcv_data_crc_field[15:8]), // input wire [7:0]  probe20
//	.probe21(rcv_data_crc_field[7:0]), // input wire [7:0]  probe21
//	.probe22(rcv_slave_addr), // input wire [7:0]  probe22
//	.probe23(i_slave_addr) // input wire [7:0]  probe23
//);

// ------------- Debug End  -----------------------

endmodule
