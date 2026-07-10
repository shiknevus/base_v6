`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/20 15:20:14
// Design Name: 
// Module Name: osm41_laser_distance_ctrl
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


module osm41_laser_distance_ctrl#(
     parameter  RAM_DEPTH   =   32768
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
) (
     input  wire      ps_reg_clk
    ,input  wire      ps_reg_reset
    
    ,input               i_time_1s_vld 
    ,input               i_time_1ms_vld 
    ,input wire  [31:0] rcfg_timeout 
    
    ,output  reg     o_user_req
    ,input  wire     i_user_grant
    ,input  wire     i_uart_rx
    ,output wire     o_uart_tx
    ,output wire     o_uart_de
    
    ,input  wire [7:0]  iv_station_select
    ,output reg  [31:0] ov_distance
    
    ,input wire       i_cmd_start 
    ,input wire [2:0] iv_act_cmd 
    
    ,output wire [1:0] ov_execu_result    // 00: None; 01:Scan Success; 10:Scan Timeout; 11:ACK Error
    ,output wire       o_execu_result_vld

);


reg cmd_start   ;
reg cmd_start_n1;
reg cmd_start_n2;
reg cmd_start_n3;
always @(posedge ps_reg_clk)begin
    if(ps_reg_reset)begin
        cmd_start    <= 1'b0;
        cmd_start_n1 <= 1'b0;
        cmd_start_n2 <= 1'b0;
        cmd_start_n3 <= 1'b0;
    end else begin
        cmd_start_n1 <= i_cmd_start;
        cmd_start_n2 <= cmd_start_n1;
        cmd_start_n3 <= cmd_start_n2;
        cmd_start <= i_cmd_start || cmd_start_n1 || cmd_start_n2 || cmd_start_n3;
    end
end

reg cmd_start_always;
reg cmd_start_clk_domain_2;
reg cmd_start_n1_clk_domain_2;
reg cmd_start_n2_clk_domain_2;
always @(posedge ps_reg_clk)begin
    if(ps_reg_reset)begin
        cmd_start_clk_domain_2    <= 1'b0;
        cmd_start_n1_clk_domain_2 <= 1'b0;
        cmd_start_n2_clk_domain_2 <= 1'b0;
    end else begin
        cmd_start_always <= cmd_start;
        cmd_start_n1_clk_domain_2 <= cmd_start;
        cmd_start_n2_clk_domain_2 <= cmd_start_n1_clk_domain_2;
        cmd_start_clk_domain_2 <= (cmd_start_n1_clk_domain_2 != cmd_start_n2_clk_domain_2)&&(cmd_start_n1_clk_domain_2==1);//rising edge 
    end
end


reg [2:0]  act_cmd               ;
reg [7:0]  station_select        ;
always @(posedge ps_reg_clk)begin
    if(ps_reg_reset)begin
        act_cmd               <= 'd0;
        station_select        <= 'd0;
    end else begin
        act_cmd               <= iv_act_cmd;
        station_select        <= iv_station_select;
    end
end


// Start : 7E 01 30 30 30 30 23 53 43 4E 54 52 47 31 3B 03
// res   : 02 01 30 30 30 30 23 53 43 4E 54 52 47 31 06 3B 03

localparam [7:0]STX = 8'h68;
wire [7:0] SUB_ADDR = station_select;
reg [7:0] BYTE_LENGTH;
reg [7:0] CMD_CODE;
reg [15:0] SUM_CHECK;
localparam [7:0]ETX = 8'h16;

reg [7:0] cnt_length;

always @(posedge ps_reg_clk)begin
    if(ps_reg_reset)begin
        BYTE_LENGTH  <= 8'h00;
        CMD_CODE     <= 8'h00;
        SUM_CHECK    <= 16'h0000;
        cnt_length <= 0;
    end else begin
        case(act_cmd)
            3'b001:begin  // Reading distance
                BYTE_LENGTH <= 8'h03;
                CMD_CODE    <= 8'h00;
                SUM_CHECK   <= SUB_ADDR + BYTE_LENGTH + CMD_CODE;
                cnt_length  <= BYTE_LENGTH + 4;
            end
            3'b010:begin  // 
                BYTE_LENGTH <= 8'h03;
                CMD_CODE    <= 8'h00;
                SUM_CHECK   <= SUB_ADDR + BYTE_LENGTH + CMD_CODE;
                cnt_length  <= BYTE_LENGTH + 4;
            end
            3'b011:begin  // 
                BYTE_LENGTH <= 8'h03;
                CMD_CODE    <= 8'h00;
                SUM_CHECK   <= SUB_ADDR + BYTE_LENGTH + CMD_CODE;
                cnt_length  <= BYTE_LENGTH + 4;
            end
            3'b100:begin // 
                BYTE_LENGTH <= 8'h03;
                CMD_CODE    <= 8'h00;
                SUM_CHECK   <= SUB_ADDR + BYTE_LENGTH + CMD_CODE;
                cnt_length  <= BYTE_LENGTH + 4;
            end
            default:begin
            
            end
        endcase
    end
end


reg                   send_start;
reg  [RAM_DWIDTH*RAM_DWIDTH-1:0] rs232_send_data;
wire                  rs232_data_pack_ok;
wire [RAM_DWIDTH*RAM_DWIDTH-1:0] rs232_rcv_data;

wire [15:0] SUM_CHECK_2 = SUB_ADDR + BYTE_LENGTH + 8'h01;

wire      send_ready;
reg [1:0] execu_result;
reg       result_vld;
reg [3:0] curr_state;
reg [7:0] send_length;
reg [15:0] cal_time_cnt;
reg [7:0] wait_ack_cnt;
reg [7:0] rec_data_number;
always @(posedge ps_reg_clk)begin
    if(ps_reg_reset)begin
        curr_state   <= 0;
        result_vld   <= 0;
        execu_result <= 0; // 00: None; 01:Success; 10:Timeout; 11:ACK Error
        send_start   <= 0;
        send_length  <= 0;
        cal_time_cnt <= 0;
        wait_ack_cnt <= 0;
        ov_distance  <= 0;
        o_user_req   <= 0;
        rec_data_number   <= 0;
    end else begin
        case(curr_state)
            0:begin
                if(cmd_start_always)begin 
                    o_user_req <=  'b1;
                    case(act_cmd)
                        3'b001:begin  // read distence
                            curr_state <= 'd1;
                        end
//                        3'b010:begin  // start
//                            curr_state <= 'd2;
//                        end
//                        3'b011:begin  // stop
//                            curr_state <= 'd3;
//                        end
//                        3'b100:begin // read temperature
//                            curr_state <= 'd4;
//                        end
                        default:begin
                            curr_state <= 'd0;
                        end
                    endcase
                end else begin
                    curr_state <= 4'd0;
                    o_user_req <= 'b0;
                end
                send_start <= 0;
                result_vld <= 0;
                cal_time_cnt <= 0;
                wait_ack_cnt <= 0;
                rec_data_number <= 0;
            end
            1,2,3,4:begin
                rs232_send_data <= {STX,SUB_ADDR,BYTE_LENGTH, CMD_CODE,SUM_CHECK[7:0],SUM_CHECK[15:8],ETX};
                if(send_ready & i_user_grant)begin
                    curr_state <= 4'd5;
                    send_start <= 1'b1;
                end else begin 
                    curr_state <= curr_state;
                    send_start <= 1'b0;
                end
                send_length <= cnt_length;
                result_vld <= 0;
                cal_time_cnt <= 0;
                wait_ack_cnt <= 0;
                rec_data_number <= 0;
            end
            
            //  recv return data
            5:begin
                if(rs232_data_pack_ok)begin
                    if((SUB_ADDR==rs232_rcv_data[15:8])&&(CMD_CODE==rs232_rcv_data[31:24]))begin
                        curr_state <= 4'd6;
                        result_vld <= 1'b0;
                        cal_time_cnt <= 'd0;
                        rec_data_number <= rs232_rcv_data[23:16]-3;
//                        execu_result <= 2'b01;// 00: None; 01:Success; 10:Timeout; 11:ACK Error
                    end else begin
                        curr_state <= 4'd10;
                        result_vld <= 1'b0;
                        cal_time_cnt <= 'd0;
                        execu_result <= 2'b00; 
                    end
                end else if(cal_time_cnt<500)begin
                    curr_state <= 4'd5;
                    result_vld <= 1'b0;
                    execu_result <= 2'b00;// 00: None; 01:Success; 10:Timeout; 11:ACK Error
                    cal_time_cnt <= cal_time_cnt + i_time_1ms_vld;
                end else begin
                    curr_state <= 4'd10;
                    result_vld <= 1'b0;
                    execu_result <= 2'b00;// 00: None; 01:Success; 10:Timeout; 11:ACK Error
                    cal_time_cnt <= 1'b0;
                end
                send_start <= 0;
            end
            6:begin
                case(rec_data_number)
                    0:begin
                        ov_distance  <= 0;
                    end
                    1:begin
                        ov_distance[7:0]  <= rs232_rcv_data[39:32];
                    end
                    2:begin
                        ov_distance[7 :0]  <= rs232_rcv_data[39:32];
                        ov_distance[15:8]  <= rs232_rcv_data[47:40];
                    end
                    3:begin
                        ov_distance[7 :0 ] <= rs232_rcv_data[39:32];
                        ov_distance[15:8 ] <= rs232_rcv_data[47:40];
                        ov_distance[23:16] <= rs232_rcv_data[55:48];
                    end
                    default:begin
                        ov_distance  <= 0;
                    end
                endcase
                rs232_send_data <= {STX,SUB_ADDR,BYTE_LENGTH, 8'h01,SUM_CHECK_2[7:0],SUM_CHECK_2[15:8],ETX};  //Reading distance unit
//                curr_state <= 4'd11;  //Reading distance unit
//                result_vld <= 0;
                curr_state <= 4'd10;
                result_vld <= 1;
                execu_result <= 2'b01;// 00: None; 01:Success; 10:Timeout; 11:ACK Error
                send_start <= 0;
                cal_time_cnt <= 0;
                wait_ack_cnt <= 0;
                rec_data_number <= 0;
            end
            7:begin
                rs232_send_data <= {STX,SUB_ADDR,BYTE_LENGTH, 8'h01,SUM_CHECK_2[7:0],SUM_CHECK_2[15:8],ETX};  //Reading distance unit
                if(send_ready)begin
                    curr_state <= 4'd8;
                    send_start <= 1'b1;
                end else begin 
                    curr_state <= curr_state;
                    send_start <= 1'b0;
                end
                send_length <= cnt_length;
                result_vld <= 0;
                cal_time_cnt <= 0;
                wait_ack_cnt <= 0;
                rec_data_number <= 0;
            end
            8:begin
                if(rs232_data_pack_ok)begin
                    if((SUB_ADDR==rs232_rcv_data[15:8])&&(8'h01==rs232_rcv_data[31:24]))begin
                        curr_state <= 4'd9;
                        result_vld <= 1'b0;
                        cal_time_cnt <= 'd0;
                        rec_data_number <= rs232_rcv_data[23:16]-3;
//                        execu_result <= 2'b01;// 00: None; 01:Success; 10:Timeout; 11:ACK Error
                    end else begin
                        curr_state <= 4'd10;
                        result_vld <= 1'b0;
                        cal_time_cnt <= 'd0;
                        execu_result <= 2'b00; // 00: None; 01:Success; 10:Timeout; 11:ACK Error
                    end
                end else if(cal_time_cnt<200)begin
                    curr_state <= 4'd8;
                    result_vld <= 1'b0;
                    execu_result <= 2'b00;// 00: None; 01:Success; 10:Timeout; 11:ACK Error
                    cal_time_cnt <= cal_time_cnt + i_time_1ms_vld;
                end else begin
                    curr_state <= 4'd10;
                    result_vld <= 1'b0;
                    execu_result <= 2'b00;// 00: None; 01:Success; 10:Timeout; 11:ACK Error
                    cal_time_cnt <= 1'b0;
                end
                send_start <= 0;
            end
            9:begin
                case(rec_data_number)
                    1:begin
                        ov_distance[31:24]  <= rs232_rcv_data[39:32];
                    end
                    default:begin
                        ov_distance  <= 0;
                    end
                endcase
                curr_state <= 4'd10;
                send_start <= 0;
                result_vld <= 1;
                execu_result <= 2'b01;// 00: None; 01:Success; 10:Timeout; 11:ACK Error
                cal_time_cnt <= 0;
                wait_ack_cnt <= 0;
                rec_data_number <= 0;
            end
            10:begin
                if(cal_time_cnt < 5)begin
                    cal_time_cnt    <= cal_time_cnt + i_time_1ms_vld;
                    curr_state      <= curr_state;
                end else begin
                    curr_state      <= 4'd0 ;
                    cal_time_cnt    <=  'd0 ;
                end  
            end
            11:begin
                if(cal_time_cnt < 50)begin
                    cal_time_cnt    <= cal_time_cnt + i_time_1ms_vld;
                    curr_state      <= curr_state;
                end else begin
                    curr_state      <= 4'd7 ;
                    cal_time_cnt    <=  'd0 ;
                end  
            end
        endcase
    end
end

assign ov_execu_result = execu_result;
assign o_execu_result_vld = result_vld;


// ------------- Debug Start  -----------------------
//wire [255:0] buffer = rs232_send_data[255:0];

//ila_xt2010 U_ila_xt2010(
// .clk(ps_reg_clk)
//,.probe0({act_cmd,curr_state[3:0]})
//,.probe1({send_start,result_vld,i_uart_rx,send_ready,execu_result,rs232_data_pack_ok})
//,.probe2({o_uart_tx,o_uart_de,send_length,rec_data_number})
//,.probe3({o_user_req,i_user_grant,SUB_ADDR})
//,.probe4(ov_distance)
//,.probe5(rs232_rcv_data[255:0])
//,.probe6(buffer)
//,.probe7({CRC_LOW,CRC_HIGH})
//);
//------------- Debug End  -----------------------

uart_osm41_driver #(
   .RAM_DWIDTH     (RAM_DWIDTH   )
  ,.STX            (STX          )
  ,.ETX            (ETX          )
  ,.UART_BPS       (9600         )
)U_uart_osm41_driver(
  .clk                  (ps_reg_clk       )
 ,.reset                (ps_reg_reset     )
 
,.i_uart_rx              (i_uart_rx       )
,.o_uart_tx              (o_uart_tx       )
,.o_uart_de              (o_uart_de       )
 
 ,.i_send_start          (send_start         )
 ,.o_send_ready          (send_ready         )
 ,.iv_send_length        (send_length        )
 ,.iv_rs232_data_send    (rs232_send_data    )
 ,.o_rs232_data_pack_ok  (rs232_data_pack_ok )
 ,.ov_rs232_data_rcv     (rs232_rcv_data     )
);

// ------------- Debug Start  -----------------------
//reg [255:0] buffer;
//always @(posedge clk)begin
//    buffer <= rs232_send_data[1023-:256];
//end
//ila_xt2010 U_ila_xt2010(
// .clk(clk)
//,.probe0({cmd_start_clk_domain_2,curr_state[3:0]})
//,.probe1({result_vld,send_start,sys_wea[0],slv_cfg_msg_rden,execu_result,rs232_data_pack_ok})
//,.probe2(sys_addra)
//,.probe3(slv_cfg_msg_addr)
//,.probe4(ov_rs232_send_msg)
//,.probe5(rs232_msg)
//,.probe6(rs232_rcv_data[1023-:256])
//,.probe7(buffer)
//);
// ------------- Debug End  -----------------------
endmodule
