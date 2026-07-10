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


module osm61_laser_distance_ctrl#(
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
    ,output reg  [63:0] ov_distance
    
    ,input wire       i_cmd_start 
    ,input wire [2:0] iv_act_cmd 
    
    ,output wire [1:0] ov_execu_result    // 00: None; 01:Scan Success; 10:Scan Timeout; 11:ACK Error
    ,output wire       o_execu_result_vld

);


reg cmd_start   ;
reg cmd_start_n   ;
reg [2:0]  act_cmd ;
always @(posedge ps_reg_clk)begin
    if(ps_reg_reset)begin
        cmd_start    <= 1'b0;
        act_cmd      <= 'd0;
        cmd_start_n  <= 'd0;
    end else begin
        cmd_start_n <= i_cmd_start;
        cmd_start   <= (cmd_start_n!=i_cmd_start)&&(cmd_start_n==1'b0);  // rising edge
        act_cmd     <= iv_act_cmd;
    end
end

wire [7:0] SUB_ADDR = iv_station_select[7:0];

wire [7:0] CRC_HIGH ;
wire [7:0] CRC_LOW ;


reg                   send_start;
reg  [RAM_DWIDTH*RAM_DWIDTH-1:0] rs232_send_data;
reg  [RAM_DWIDTH*RAM_DWIDTH-1-16:0] crc_check_data;
wire                  rs232_data_pack_ok;
wire [RAM_DWIDTH*RAM_DWIDTH-1:0] rs232_rcv_data;


reg [7:0] send_length;
reg  crc_cal_start;
wire crc_cal_done;
wire[15:0] crc_reg;
CRC16_modbus #(
   .RAM_DWIDTH     (RAM_DWIDTH   )
)U_CRC16_modbus(
    .sys_clk(ps_reg_clk),   
    .rst_n(~ps_reg_reset),
    
    .iv_crc_data     (crc_check_data),
    .i_crc_cal_start (crc_cal_start),
    .iv_data_length  (send_length-2),
    .o_crc_cal_done  (crc_cal_done),
    .ov_crc_reg      (crc_reg)
);

reg [7:0] CMD_CODE ;
reg [15:0] REG_ADDR ;
reg [15:0] REG_NUM ;

assign CRC_HIGH = crc_reg[15:8];
assign CRC_LOW  = crc_reg[7:0];
/*
always @(posedge ps_reg_clk)begin
    if(ps_reg_reset)begin
       CMD_CODE <= 'h0 ;
       REG_ADDR <= 'h0 ;
       REG_NUM  <= 'h0 ;
    
    end else begin
        case(act_cmd)
            3'b001:begin  // Reading distance
                CMD_CODE <= 8'h03 ;
                REG_ADDR [15:8] <= 8'h00;
                REG_ADDR [7:0]  <= 8'h00;
                REG_NUM [15:8]  <= 8'h00;
                REG_NUM [7:0]   <= 8'h01;   
            end
            3'b010:begin  //            
            end
            3'b011:begin  //               
            end
            3'b100:begin  //               
            end
            default:begin           
            end
        endcase
    end
end
*/
wire      send_ready;
reg [1:0] execu_result;
reg       result_vld;
reg [3:0] curr_state;
reg [7:0] cal_time_cnt;
//reg [7:0] wait_ack_cnt;
reg [7:0] rec_data_number;
always @(posedge ps_reg_clk)begin
    if(ps_reg_reset)begin
        curr_state   <= 0;
        result_vld   <= 0;
        execu_result <= 0; // 00: None; 01:Success; 10:Timeout; 11:ACK Error
        send_start   <= 0;
        send_length  <= 0;
        cal_time_cnt <= 0;
        ov_distance  <= 0;
        o_user_req   <= 0;
        rec_data_number   <= 0;
        crc_cal_start   <= 0;
        crc_check_data   <= 0;
        rs232_send_data   <= 0;
    end else begin
        case(curr_state)
            0:begin
                if(cmd_start)begin 
                    o_user_req <=  'b1;
                    case(act_cmd)
                        3'b001:begin  // 
                            curr_state <= 'd2;
                        end
                        3'b010:begin  // 
                            curr_state <= 'd2;
                        end
                        3'b011:begin  // stop
                            curr_state <= 'd0;
                        end
                        3'b100:begin // read temperature
                            curr_state <= 'd0;
                        end
                        default:begin
                            curr_state <= 'd0;
                        end
                    endcase
                end else begin
                    curr_state <= 4'd0;
                    o_user_req <= 'b0;
                end
                crc_cal_start <= 0;
                send_start <= 0;
                result_vld <= 0;
                execu_result <= 2'b00;
                cal_time_cnt <= 0;
                rec_data_number <= 0;
            end
            1:begin
                crc_check_data <= {SUB_ADDR,8'h03,8'h00,8'h00,8'h00,8'h01};
                crc_cal_start <= 1'b1;
                curr_state <= crc_cal_done ? 3 : curr_state;
                send_start <= 1'b0;
                send_length  <= 'd8;
                result_vld   <= 0;
                execu_result <= 2'b00;
                cal_time_cnt <= 0;
                rec_data_number <= 0;
            end
            2:begin
                crc_check_data <= {SUB_ADDR,8'h03,8'h00,8'h00,8'h00,8'h02};     //01 03 00 00 00 02 C4 0B
                crc_cal_start <= 1'b1;
                curr_state <= crc_cal_done ? 3 : curr_state;
                send_start <= 1'b0;
                send_length <= 'd8;
                result_vld <= 0;
                execu_result <= 2'b00;
                cal_time_cnt <= 0;
                rec_data_number <= 0;
            end
            3:begin
                rs232_send_data <= {crc_check_data,CRC_LOW,CRC_HIGH};
                //rs232_send_data <= {crc_check_data,CRC_LOW,CRC_HIGH};
                //rs232_send_data <= {SUB_ADDR,CMD_CODE,REG_ADDR[15:8],REG_ADDR[7:0],REG_NUM[15:8],REG_NUM[7:0],CRC_LOW,CRC_HIGH};              
                if(send_ready & i_user_grant)begin
                    curr_state <= 4'd5;
                    send_start <= 1'b1;
                end else begin 
                    curr_state <= curr_state;
                    send_start <= 1'b0;
                end
                send_length  <= 'd8;
                crc_cal_start <= 1'b0;
                result_vld   <= 0;
                execu_result <= 2'b00;
                cal_time_cnt <= 0;
                rec_data_number <= 0;
            end
            5:begin
                if(rs232_data_pack_ok)begin
                    //if((SUB_ADDR==rs232_rcv_data[7:0])&&(CMD_CODE==rs232_rcv_data[15:8]))begin
                    if(SUB_ADDR==rs232_rcv_data[7:0])begin
                        curr_state <= 4'd6;
                        result_vld <= 1'b1;
                        cal_time_cnt <= 'd0;
                        rec_data_number <= 8;
                        rec_data_number <= rs232_rcv_data[23:16];
                        execu_result <= 2'b00;// 00: None; 01:Success; 10:Timeout; 11:ACK Error
                    end else begin
                        curr_state <= 4'd0;
                        result_vld <= 1'b1;
                        cal_time_cnt <= 'd0;
                        execu_result <= 2'b11; 
                    end
                end else if(cal_time_cnt<rcfg_timeout-1)begin
                    curr_state <= curr_state;
                    result_vld <= 1'b0;
                    cal_time_cnt <= cal_time_cnt + i_time_1s_vld;
                end else begin
                    curr_state <= 4'd0;
                    result_vld <= 1'b1;
                    execu_result <= 2'b10;// 00: None; 01:Success; 10:Timeout; 11:ACK Error
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
                        ov_distance[7:0]  <= rs232_rcv_data[31:24];
                    end
                    2:begin
                        ov_distance[7 :0]  <= rs232_rcv_data[31:24];
                        ov_distance[15:8]  <= rs232_rcv_data[39:32];
                    end
                    //01 03 04 D3 D4 D1 D2 CL CH;   0xD1D2D3D4乘以传感器分辨率
                    4:begin
                        ov_distance[7 :0]   <= rs232_rcv_data[39:32];
                        ov_distance[15:8]   <= rs232_rcv_data[31:24];
                        ov_distance[23:16]  <= rs232_rcv_data[55:48];
                        ov_distance[31:24]  <= rs232_rcv_data[47:40];
                    end                  
                    default:begin
                        ov_distance  <= 0;
                    end
                    
                endcase
                curr_state      <= 4'd0;  
                send_start      <= 0;
                result_vld      <= 1'b1;
                execu_result    <= 2'b01;// 00: None; 01:Success; 10:Timeout; 11:ACK Error
                cal_time_cnt    <= 0;
                rec_data_number <= 0;
            end
            default:begin
                curr_state      <= 4'd0;
                ov_distance     <= 'd0;  
                send_start      <= 0;
                result_vld      <= 1'b0;
                execu_result    <= 2'b00;
                cal_time_cnt    <= 0;
                rec_data_number <= 0;
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
//,.probe1({cmd_start_clk_domain_2,send_start,result_vld,i_uart_rx,send_ready,execu_result,rs232_data_pack_ok})
//,.probe2({o_uart_tx,o_uart_de,send_length,rec_data_number})
//,.probe3({o_user_req,i_user_grant,SUB_ADDR})
//,.probe4(ov_distance)
//,.probe5(rs232_rcv_data[255:0])
//,.probe6(buffer)
//,.probe7({SUM_CHECK_2,SUM_CHECK})
//);
// ------------- Debug End  -----------------------

uart_osm61_driver #(
   .RAM_DWIDTH     (RAM_DWIDTH   )
  ,.UART_BPS       (115200         )
)U_uart_osm61_driver(
  .clk                  (ps_reg_clk       )
 ,.reset                (ps_reg_reset     )
 
,.i_uart_rx              (i_uart_rx       )
,.o_uart_tx              (o_uart_tx       )
,.o_uart_de              (o_uart_de       )
 
 ,.iv_sub_addr           (SUB_ADDR           )
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
