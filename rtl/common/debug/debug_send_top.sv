`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/27 17:50:33
// Design Name: 
// Module Name: debug_send_top
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
`include "components_param.vh"
`include "para_reg_addr.vh"
module debug_send_top#(

     parameter  P_MODULE_ID    = 8'd1
    ,parameter  P_SEAT_NUM     = 4'd1
    ,parameter  TIME_1MS_TIMER = 100000
    ,parameter  RAM_DEPTH   =   32768
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
   ,parameter  CLK_FREQ = 100000000
   ,parameter  UART_BPS = 115200
)
(
    input                   ps_reg_clk
   ,input                   ps_reg_reset
   ,input                   i_time_1ms_vld
   // flow interface
   
   // io interface
   ,output  wire             o_user_req
   ,input   wire             i_user_grant
   ,input   wire             i_uart_rx
   ,output  wire             o_uart_tx
   ,output  reg              o_uart_de
   
   ,output  reg             o_di_debug
   ,output  reg             o_do_debug
   
   ,input   wire  [63:0]     iv_do_mst_msg
   ,input   wire  [95:0]     iv_di_mst_msg
   
   ,output   reg   [63:0]     ov_do_mst_msg
   ,output   reg   [95:0]     ov_di_mst_msg
   ,input    wire  [7:0]      iv_slv_sta_num
   
   ,input    wire             i_debug_mode
   
   ,input    wire  [RAM_DWIDTH*3-1:0] iv_di_slv_msg[RAM_DWIDTH-1:0]
   ,input    wire  [RAM_DWIDTH*3-1:0] iv_do_slv_msg[RAM_DWIDTH-1:0]
   ,output    reg  [RAM_DWIDTH*3-1:0] ov_di_slv_msg[RAM_DWIDTH-1:0]
   ,output    reg  [RAM_DWIDTH*3-1:0] ov_do_slv_msg[RAM_DWIDTH-1:0]
   ,output   reg   [RAM_DWIDTH-1:0]   ov_di_debug
   ,output   reg   [RAM_DWIDTH-1:0]   ov_do_debug
   
 );

wire clk = ps_reg_clk;
wire reset = ps_reg_reset;

assign o_user_req = 1;
//assign o_uart_de = 1;



wire       rx_done;    
wire [7:0] rx_data;    
reg rx_done_n;
wire rx_vld = (~rx_done_n) & rx_done;
always @(posedge clk)begin
    if(reset)begin
        rx_done_n <= 0;
    end else begin
        rx_done_n <= rx_done;
    end    
end

reg       rx_data_ok;
reg [7:0] debug_board;
reg [7:0] rx_data1;
reg [7:0] rx_data2;
always @(posedge clk)begin
    if(reset)begin
        o_di_debug <= 'b0;
        o_do_debug <= 'b0;
        ov_di_debug <= 'b0;
        ov_do_debug <= 'b0;
        debug_board <= 'b0;
    end else begin
        if(rx_data_ok)begin
            if((rx_data2[7:6]==2'b01)&&(rx_data1==8'd170))begin
                if(debug_board==0)begin
                    o_di_debug <= rx_data2[0];
                    o_do_debug <= o_do_debug;
                end else begin
                    ov_di_debug[debug_board-1] <= rx_data2[0];
                    ov_do_debug <= ov_do_debug;
                end
                debug_board <= debug_board;
            end else if((rx_data2[7:6]==2'b01)&&(rx_data1==8'd234))begin
                if(debug_board==0)begin
                    o_di_debug <= o_di_debug;
                    o_do_debug <= rx_data2[0];
                end else begin
                    ov_di_debug <= ov_di_debug;
                    ov_do_debug[debug_board-1] <= rx_data2[0];
                end
                debug_board <= debug_board;
            end else if((rx_data2[7:6]==2'b01)&&(rx_data1==8'd90))begin
                o_di_debug <= 0;
                o_do_debug <= 0;
                ov_di_debug <= 0;
                ov_do_debug <= 0;
                debug_board <= rx_data2[5:0];
            end else begin
                o_di_debug <= o_di_debug;
                o_do_debug <= o_do_debug;
                ov_di_debug <= ov_di_debug;
                ov_do_debug <= ov_do_debug;
                debug_board <= debug_board;
            end
        end else begin
            if(i_debug_mode)begin
                o_di_debug <= o_di_debug;
                o_do_debug <= o_do_debug;
                ov_di_debug <= ov_di_debug;
                ov_do_debug <= ov_do_debug;
            end else begin
                o_di_debug <= 0;
                o_do_debug <= 0;
                ov_di_debug <= 0;
                ov_do_debug <= 0;
            end
            debug_board <= debug_board;
        end
    end
end

wire di_debug;
wire do_debug;

assign di_debug  = (debug_board==0)? o_di_debug:
                    (debug_board==1)? ov_di_debug[0]:
                    (debug_board==2)? ov_di_debug[1]:
                    (debug_board==3)? ov_di_debug[2]:
                    (debug_board==4)? ov_di_debug[3]:
                    (debug_board==5)? ov_di_debug[4]:
                    (debug_board==6)? ov_di_debug[5]:
                    (debug_board==7)? ov_di_debug[6]:
                    (debug_board==8)? ov_di_debug[7]:
                    (debug_board==9)? ov_di_debug[8]:0;
             

reg  [95:0]     debug_di_mst_msg;
always @(posedge clk)begin
    if(reset)begin
        debug_di_mst_msg <= 0;
    end else begin
        case(debug_board)
            0:begin
                if(o_di_debug)begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b11)begin
                            debug_di_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_di_mst_msg <= debug_di_mst_msg;
                        end
                    end else begin
                        debug_di_mst_msg <= debug_di_mst_msg;
                    end
                end else begin
                        debug_di_mst_msg <= iv_di_mst_msg;
                end
            end
            1:begin
                if(ov_di_debug[0])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b11)begin
                            debug_di_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_di_mst_msg <= debug_di_mst_msg;
                        end
                    end else begin
                        debug_di_mst_msg <= debug_di_mst_msg;
                    end
                end else begin
                        debug_di_mst_msg <= iv_di_slv_msg[0];
                end
            end
            2:begin
                if(ov_di_debug[1])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b11)begin
                            debug_di_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_di_mst_msg <= debug_di_mst_msg;
                        end
                    end else begin
                        debug_di_mst_msg <= debug_di_mst_msg;
                    end
                end else begin
                        debug_di_mst_msg <= iv_di_slv_msg[1];
                end
            end
            3:begin
                if(ov_di_debug[2])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b11)begin
                            debug_di_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_di_mst_msg <= debug_di_mst_msg;
                        end
                    end else begin
                        debug_di_mst_msg <= debug_di_mst_msg;
                    end
                end else begin
                        debug_di_mst_msg <= iv_di_slv_msg[2];
                end
            end
            4:begin
                if(ov_di_debug[3])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b11)begin
                            debug_di_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_di_mst_msg <= debug_di_mst_msg;
                        end
                    end else begin
                        debug_di_mst_msg <= debug_di_mst_msg;
                    end
                end else begin
                        debug_di_mst_msg <= iv_di_slv_msg[3];
                end
            end
            5:begin
                if(ov_di_debug[4])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b11)begin
                            debug_di_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_di_mst_msg <= debug_di_mst_msg;
                        end
                    end else begin
                        debug_di_mst_msg <= debug_di_mst_msg;
                    end
                end else begin
                        debug_di_mst_msg <= iv_di_slv_msg[4];
                end
            end
            6:begin
                if(ov_di_debug[5])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b11)begin
                            debug_di_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_di_mst_msg <= debug_di_mst_msg;
                        end
                    end else begin
                        debug_di_mst_msg <= debug_di_mst_msg;
                    end
                end else begin
                        debug_di_mst_msg <= iv_di_slv_msg[5];
                end
            end
            7:begin
                if(ov_di_debug[6])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b11)begin
                            debug_di_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_di_mst_msg <= debug_di_mst_msg;
                        end
                    end else begin
                        debug_di_mst_msg <= debug_di_mst_msg;
                    end
                end else begin
                        debug_di_mst_msg <= iv_di_slv_msg[6];
                end
            end
            8:begin
                if(ov_di_debug[7])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b11)begin
                            debug_di_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_di_mst_msg <= debug_di_mst_msg;
                        end
                    end else begin
                        debug_di_mst_msg <= debug_di_mst_msg;
                    end
                end else begin
                        debug_di_mst_msg <= iv_di_slv_msg[7];
                end
            end
            9:begin
                if(ov_di_debug[8])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b11)begin
                            debug_di_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_di_mst_msg <= debug_di_mst_msg;
                        end
                    end else begin
                        debug_di_mst_msg <= debug_di_mst_msg;
                    end
                end else begin
                        debug_di_mst_msg <= iv_di_slv_msg[8];
                end
            end
            10:begin
                if(ov_di_debug[9])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b11)begin
                            debug_di_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_di_mst_msg <= debug_di_mst_msg;
                        end
                    end else begin
                        debug_di_mst_msg <= debug_di_mst_msg;
                    end
                end else begin
                        debug_di_mst_msg <= iv_di_slv_msg[9];
                end
            end
        endcase
    end
end

assign do_debug  = (debug_board==0)?  o_do_debug:
                    (debug_board==1)? ov_do_debug[0]:
                    (debug_board==2)? ov_do_debug[1]:
                    (debug_board==3)? ov_do_debug[2]:
                    (debug_board==4)? ov_do_debug[3]:
                    (debug_board==5)? ov_do_debug[4]:
                    (debug_board==6)? ov_do_debug[5]:
                    (debug_board==7)? ov_do_debug[6]:
                    (debug_board==8)? ov_do_debug[7]:
                    (debug_board==9)? ov_do_debug[8]:0;
                    
reg  [63:0]     debug_do_mst_msg;
always @(posedge clk)begin 
    if(reset)begin
        debug_do_mst_msg <= 0;
    end else begin
        case(debug_board)
            0:begin
                if(o_do_debug)begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b10)begin
                            debug_do_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_do_mst_msg <= debug_do_mst_msg;
                        end
                    end else begin
                        debug_do_mst_msg <= debug_do_mst_msg;
                    end
                end else begin
                        debug_do_mst_msg <= iv_do_mst_msg;
                end
            end
            1:begin
                if(ov_do_debug[0])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b10)begin
                            debug_do_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_do_mst_msg <= debug_do_mst_msg;
                        end
                    end else begin
                        debug_do_mst_msg <= debug_do_mst_msg;
                    end
                end else begin
                        debug_do_mst_msg <= iv_do_slv_msg[0];
                end
            end
            2:begin
                if(ov_do_debug[1])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b10)begin
                            debug_do_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_do_mst_msg <= debug_do_mst_msg;
                        end
                    end else begin
                        debug_do_mst_msg <= debug_do_mst_msg;
                    end
                end else begin
                        debug_do_mst_msg <= iv_do_slv_msg[1];
                end
            end
            3:begin
                if(ov_do_debug[2])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b10)begin
                            debug_do_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_do_mst_msg <= debug_do_mst_msg;
                        end
                    end else begin
                        debug_do_mst_msg <= debug_do_mst_msg;
                    end
                end else begin
                        debug_do_mst_msg <= iv_do_slv_msg[2];
                end
            end
            4:begin
                if(ov_do_debug[3])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b10)begin
                            debug_do_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_do_mst_msg <= debug_do_mst_msg;
                        end
                    end else begin
                        debug_do_mst_msg <= debug_do_mst_msg;
                    end
                end else begin
                        debug_do_mst_msg <= iv_do_slv_msg[3];
                end
            end
            5:begin
                if(ov_do_debug[4])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b10)begin
                            debug_do_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_do_mst_msg <= debug_do_mst_msg;
                        end
                    end else begin
                        debug_do_mst_msg <= debug_do_mst_msg;
                    end
                end else begin
                        debug_do_mst_msg <= iv_do_slv_msg[4];
                end
            end
            6:begin
                if(ov_do_debug[5])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b10)begin
                            debug_do_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_do_mst_msg <= debug_do_mst_msg;
                        end
                    end else begin
                        debug_do_mst_msg <= debug_do_mst_msg;
                    end
                end else begin
                        debug_do_mst_msg <= iv_do_slv_msg[5];
                end
            end
            7:begin
                if(ov_do_debug[6])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b10)begin
                            debug_do_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_do_mst_msg <= debug_do_mst_msg;
                        end
                    end else begin
                        debug_do_mst_msg <= debug_do_mst_msg;
                    end
                end else begin
                        debug_do_mst_msg <= iv_do_slv_msg[6];
                end
            end
            8:begin
                if(ov_do_debug[7])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b10)begin
                            debug_do_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_do_mst_msg <= debug_do_mst_msg;
                        end
                    end else begin
                        debug_do_mst_msg <= debug_do_mst_msg;
                    end
                end else begin
                        debug_do_mst_msg <= iv_do_slv_msg[7];
                end
            end
            9:begin
                if(ov_do_debug[8])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b10)begin
                            debug_do_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_do_mst_msg <= debug_do_mst_msg;
                        end
                    end else begin
                        debug_do_mst_msg <= debug_do_mst_msg;
                    end
                end else begin
                        debug_do_mst_msg <= iv_do_slv_msg[8];
                end
            end
            10:begin
                if(ov_do_debug[9])begin
                    if(rx_data_ok)begin
                        if(rx_data2[7:6] == 2'b10)begin
                            debug_do_mst_msg[rx_data1] <= rx_data2[0];
                        end else begin
                            debug_do_mst_msg <= debug_do_mst_msg;
                        end
                    end else begin
                        debug_do_mst_msg <= debug_do_mst_msg;
                    end
                end else begin
                        debug_do_mst_msg <= iv_do_slv_msg[9];
                end
            end
        endcase
    end
end




always @(posedge clk)begin
    if(reset)begin
        ov_di_mst_msg    <= 'd0;
        ov_do_mst_msg    <= 'd0;
        ov_di_slv_msg[0] <= 'd0;
        ov_do_slv_msg[0] <= 'd0;
        ov_di_slv_msg[1] <= 'd0;
        ov_do_slv_msg[1] <= 'd0;
        ov_di_slv_msg[2] <= 'd0;
        ov_do_slv_msg[2] <= 'd0;
        ov_di_slv_msg[3] <= 'd0;
        ov_do_slv_msg[3] <= 'd0;
        ov_di_slv_msg[4] <= 'd0;
        ov_do_slv_msg[4] <= 'd0;
        ov_di_slv_msg[5] <= 'd0;
        ov_do_slv_msg[5] <= 'd0;
        ov_di_slv_msg[6] <= 'd0;
        ov_do_slv_msg[6] <= 'd0;
        ov_di_slv_msg[7] <= 'd0;
        ov_do_slv_msg[7] <= 'd0;
        ov_di_slv_msg[8] <= 'd0;
        ov_do_slv_msg[8] <= 'd0;
        ov_di_slv_msg[9] <= 'd0;
        ov_do_slv_msg[9] <= 'd0;
    end else begin
        case(debug_board)
            0:begin
                ov_di_mst_msg <= debug_di_mst_msg;
                ov_do_mst_msg <= debug_do_mst_msg;
                ov_di_slv_msg[0] <= iv_di_slv_msg[0];
                ov_do_slv_msg[0] <= iv_do_slv_msg[0];
                ov_di_slv_msg[1] <= iv_di_slv_msg[1];
                ov_do_slv_msg[1] <= iv_do_slv_msg[1];
                ov_di_slv_msg[2] <= iv_di_slv_msg[2];
                ov_do_slv_msg[2] <= iv_do_slv_msg[2];
                ov_di_slv_msg[3] <= iv_di_slv_msg[3];
                ov_do_slv_msg[3] <= iv_do_slv_msg[3];
                ov_di_slv_msg[4] <= iv_di_slv_msg[4];
                ov_do_slv_msg[4] <= iv_do_slv_msg[4];
                ov_di_slv_msg[5] <= iv_di_slv_msg[5];
                ov_do_slv_msg[5] <= iv_do_slv_msg[5];
                ov_di_slv_msg[6] <= iv_di_slv_msg[6];
                ov_do_slv_msg[6] <= iv_do_slv_msg[6];
                ov_di_slv_msg[7] <= iv_di_slv_msg[7];
                ov_do_slv_msg[7] <= iv_do_slv_msg[7];
                ov_di_slv_msg[8] <= iv_di_slv_msg[8];
                ov_do_slv_msg[8] <= iv_do_slv_msg[8];
                ov_di_slv_msg[9] <= iv_di_slv_msg[9];
                ov_do_slv_msg[9] <= iv_do_slv_msg[9];
            end
            1:begin
                ov_di_mst_msg    <= iv_di_mst_msg;
                ov_do_mst_msg    <= iv_do_mst_msg;
                ov_di_slv_msg[0] <= debug_di_mst_msg;
                ov_do_slv_msg[0] <= debug_do_mst_msg;
                ov_di_slv_msg[1] <= iv_di_slv_msg[1];
                ov_do_slv_msg[1] <= iv_do_slv_msg[1];
                ov_di_slv_msg[2] <= iv_di_slv_msg[2];
                ov_do_slv_msg[2] <= iv_do_slv_msg[2];
                ov_di_slv_msg[3] <= iv_di_slv_msg[3];
                ov_do_slv_msg[3] <= iv_do_slv_msg[3];
                ov_di_slv_msg[4] <= iv_di_slv_msg[4];
                ov_do_slv_msg[4] <= iv_do_slv_msg[4];
                ov_di_slv_msg[5] <= iv_di_slv_msg[5];
                ov_do_slv_msg[5] <= iv_do_slv_msg[5];
                ov_di_slv_msg[6] <= iv_di_slv_msg[6];
                ov_do_slv_msg[6] <= iv_do_slv_msg[6];
                ov_di_slv_msg[7] <= iv_di_slv_msg[7];
                ov_do_slv_msg[7] <= iv_do_slv_msg[7];
                ov_di_slv_msg[8] <= iv_di_slv_msg[8];
                ov_do_slv_msg[8] <= iv_do_slv_msg[8];
                ov_di_slv_msg[9] <= iv_di_slv_msg[9];
                ov_do_slv_msg[9] <= iv_do_slv_msg[9];
            end
            2:begin
                ov_di_mst_msg    <= iv_di_mst_msg;
                ov_do_mst_msg    <= iv_do_mst_msg;
                ov_di_slv_msg[0] <= iv_di_slv_msg[0];
                ov_do_slv_msg[0] <= iv_do_slv_msg[0];
                ov_di_slv_msg[1] <= debug_di_mst_msg;
                ov_do_slv_msg[1] <= debug_do_mst_msg;
                ov_di_slv_msg[2] <= iv_di_slv_msg[2];
                ov_do_slv_msg[2] <= iv_do_slv_msg[2];
                ov_di_slv_msg[3] <= iv_di_slv_msg[3];
                ov_do_slv_msg[3] <= iv_do_slv_msg[3];
                ov_di_slv_msg[4] <= iv_di_slv_msg[4];
                ov_do_slv_msg[4] <= iv_do_slv_msg[4];
                ov_di_slv_msg[5] <= iv_di_slv_msg[5];
                ov_do_slv_msg[5] <= iv_do_slv_msg[5];
                ov_di_slv_msg[6] <= iv_di_slv_msg[6];
                ov_do_slv_msg[6] <= iv_do_slv_msg[6];
                ov_di_slv_msg[7] <= iv_di_slv_msg[7];
                ov_do_slv_msg[7] <= iv_do_slv_msg[7];
                ov_di_slv_msg[8] <= iv_di_slv_msg[8];
                ov_do_slv_msg[8] <= iv_do_slv_msg[8];
                ov_di_slv_msg[9] <= iv_di_slv_msg[9];
                ov_do_slv_msg[9] <= iv_do_slv_msg[9];
            end
            3:begin
                ov_di_mst_msg    <= iv_di_mst_msg;
                ov_do_mst_msg    <= iv_do_mst_msg;
                ov_di_slv_msg[0] <= iv_di_slv_msg[0];
                ov_do_slv_msg[0] <= iv_do_slv_msg[0];
                ov_di_slv_msg[1] <= iv_di_slv_msg[1];
                ov_do_slv_msg[1] <= iv_do_slv_msg[1];
                ov_di_slv_msg[2] <= debug_di_mst_msg;
                ov_do_slv_msg[2] <= debug_do_mst_msg;
                ov_di_slv_msg[3] <= iv_di_slv_msg[3];
                ov_do_slv_msg[3] <= iv_do_slv_msg[3];
                ov_di_slv_msg[4] <= iv_di_slv_msg[4];
                ov_do_slv_msg[4] <= iv_do_slv_msg[4];
                ov_di_slv_msg[5] <= iv_di_slv_msg[5];
                ov_do_slv_msg[5] <= iv_do_slv_msg[5];
                ov_di_slv_msg[6] <= iv_di_slv_msg[6];
                ov_do_slv_msg[6] <= iv_do_slv_msg[6];
                ov_di_slv_msg[7] <= iv_di_slv_msg[7];
                ov_do_slv_msg[7] <= iv_do_slv_msg[7];
                ov_di_slv_msg[8] <= iv_di_slv_msg[8];
                ov_do_slv_msg[8] <= iv_do_slv_msg[8];
                ov_di_slv_msg[9] <= iv_di_slv_msg[9];
                ov_do_slv_msg[9] <= iv_do_slv_msg[9];
            end
            4:begin
                ov_di_mst_msg    <= iv_di_mst_msg;
                ov_do_mst_msg    <= iv_do_mst_msg;
                ov_di_slv_msg[0] <= iv_di_slv_msg[0];
                ov_do_slv_msg[0] <= iv_do_slv_msg[0];
                ov_di_slv_msg[1] <= iv_di_slv_msg[1];
                ov_do_slv_msg[1] <= iv_do_slv_msg[1];
                ov_di_slv_msg[2] <= iv_di_slv_msg[2];
                ov_do_slv_msg[2] <= iv_do_slv_msg[2];
                ov_di_slv_msg[3] <= debug_di_mst_msg;
                ov_do_slv_msg[3] <= debug_do_mst_msg;
                ov_di_slv_msg[4] <= iv_di_slv_msg[4];
                ov_do_slv_msg[4] <= iv_do_slv_msg[4];
                ov_di_slv_msg[5] <= iv_di_slv_msg[5];
                ov_do_slv_msg[5] <= iv_do_slv_msg[5];
                ov_di_slv_msg[6] <= iv_di_slv_msg[6];
                ov_do_slv_msg[6] <= iv_do_slv_msg[6];
                ov_di_slv_msg[7] <= iv_di_slv_msg[7];
                ov_do_slv_msg[7] <= iv_do_slv_msg[7];
                ov_di_slv_msg[8] <= iv_di_slv_msg[8];
                ov_do_slv_msg[8] <= iv_do_slv_msg[8];
                ov_di_slv_msg[9] <= iv_di_slv_msg[9];
                ov_do_slv_msg[9] <= iv_do_slv_msg[9];
            end
            5:begin
                ov_di_mst_msg    <= iv_di_mst_msg;
                ov_do_mst_msg    <= iv_do_mst_msg;
                ov_di_slv_msg[0] <= iv_di_slv_msg[0];
                ov_do_slv_msg[0] <= iv_do_slv_msg[0];
                ov_di_slv_msg[1] <= iv_di_slv_msg[1];
                ov_do_slv_msg[1] <= iv_do_slv_msg[1];
                ov_di_slv_msg[2] <= iv_di_slv_msg[2];
                ov_do_slv_msg[2] <= iv_do_slv_msg[2];
                ov_di_slv_msg[3] <= iv_di_slv_msg[3];
                ov_do_slv_msg[3] <= iv_do_slv_msg[3];
                ov_di_slv_msg[4] <= debug_di_mst_msg;
                ov_do_slv_msg[4] <= debug_do_mst_msg;
                ov_di_slv_msg[5] <= iv_di_slv_msg[5];
                ov_do_slv_msg[5] <= iv_do_slv_msg[5];
                ov_di_slv_msg[6] <= iv_di_slv_msg[6];
                ov_do_slv_msg[6] <= iv_do_slv_msg[6];
                ov_di_slv_msg[7] <= iv_di_slv_msg[7];
                ov_do_slv_msg[7] <= iv_do_slv_msg[7];
                ov_di_slv_msg[8] <= iv_di_slv_msg[8];
                ov_do_slv_msg[8] <= iv_do_slv_msg[8];
                ov_di_slv_msg[9] <= iv_di_slv_msg[9];
                ov_do_slv_msg[9] <= iv_do_slv_msg[9];
            end
            6:begin
                ov_di_mst_msg    <= iv_di_mst_msg;
                ov_do_mst_msg    <= iv_do_mst_msg;
                ov_di_slv_msg[0] <= iv_di_slv_msg[0];
                ov_do_slv_msg[0] <= iv_do_slv_msg[0];
                ov_di_slv_msg[1] <= iv_di_slv_msg[1];
                ov_do_slv_msg[1] <= iv_do_slv_msg[1];
                ov_di_slv_msg[2] <= iv_di_slv_msg[2];
                ov_do_slv_msg[2] <= iv_do_slv_msg[2];
                ov_di_slv_msg[3] <= iv_di_slv_msg[3];
                ov_do_slv_msg[3] <= iv_do_slv_msg[3];
                ov_di_slv_msg[4] <= iv_di_slv_msg[4];
                ov_do_slv_msg[4] <= iv_do_slv_msg[4];
                ov_di_slv_msg[5] <= debug_di_mst_msg;
                ov_do_slv_msg[5] <= debug_do_mst_msg;
                ov_di_slv_msg[6] <= iv_di_slv_msg[6];
                ov_do_slv_msg[6] <= iv_do_slv_msg[6];
                ov_di_slv_msg[7] <= iv_di_slv_msg[7];
                ov_do_slv_msg[7] <= iv_do_slv_msg[7];
                ov_di_slv_msg[8] <= iv_di_slv_msg[8];
                ov_do_slv_msg[8] <= iv_do_slv_msg[8];
                ov_di_slv_msg[9] <= iv_di_slv_msg[9];
                ov_do_slv_msg[9] <= iv_do_slv_msg[9];
            end
            7:begin
                ov_di_mst_msg    <= iv_di_mst_msg;
                ov_do_mst_msg    <= iv_do_mst_msg;
                ov_di_slv_msg[0] <= iv_di_slv_msg[0];
                ov_do_slv_msg[0] <= iv_do_slv_msg[0];
                ov_di_slv_msg[1] <= iv_di_slv_msg[1];
                ov_do_slv_msg[1] <= iv_do_slv_msg[1];
                ov_di_slv_msg[2] <= iv_di_slv_msg[2];
                ov_do_slv_msg[2] <= iv_do_slv_msg[2];
                ov_di_slv_msg[3] <= iv_di_slv_msg[3];
                ov_do_slv_msg[3] <= iv_do_slv_msg[3];
                ov_di_slv_msg[4] <= iv_di_slv_msg[4];
                ov_do_slv_msg[4] <= iv_do_slv_msg[4];
                ov_di_slv_msg[5] <= iv_di_slv_msg[5];
                ov_do_slv_msg[5] <= iv_do_slv_msg[5];
                ov_di_slv_msg[6] <= debug_di_mst_msg;
                ov_do_slv_msg[6] <= debug_do_mst_msg;
                ov_di_slv_msg[7] <= iv_di_slv_msg[7];
                ov_do_slv_msg[7] <= iv_do_slv_msg[7];
                ov_di_slv_msg[8] <= iv_di_slv_msg[8];
                ov_do_slv_msg[8] <= iv_do_slv_msg[8];
                ov_di_slv_msg[9] <= iv_di_slv_msg[9];
                ov_do_slv_msg[9] <= iv_do_slv_msg[9];
            end
            8:begin
                ov_di_mst_msg    <= iv_di_mst_msg;
                ov_do_mst_msg    <= iv_do_mst_msg;
                ov_di_slv_msg[0] <= iv_di_slv_msg[0];
                ov_do_slv_msg[0] <= iv_do_slv_msg[0];
                ov_di_slv_msg[1] <= iv_di_slv_msg[1];
                ov_do_slv_msg[1] <= iv_do_slv_msg[1];
                ov_di_slv_msg[2] <= iv_di_slv_msg[2];
                ov_do_slv_msg[2] <= iv_do_slv_msg[2];
                ov_di_slv_msg[3] <= iv_di_slv_msg[3];
                ov_do_slv_msg[3] <= iv_do_slv_msg[3];
                ov_di_slv_msg[4] <= iv_di_slv_msg[4];
                ov_do_slv_msg[4] <= iv_do_slv_msg[4];
                ov_di_slv_msg[5] <= iv_di_slv_msg[5];
                ov_do_slv_msg[5] <= iv_do_slv_msg[5];
                ov_di_slv_msg[6] <= iv_di_slv_msg[6];
                ov_do_slv_msg[6] <= iv_do_slv_msg[6];
                ov_di_slv_msg[7] <= debug_di_mst_msg;
                ov_do_slv_msg[7] <= debug_do_mst_msg;
                ov_di_slv_msg[8] <= iv_di_slv_msg[8];
                ov_do_slv_msg[8] <= iv_do_slv_msg[8];
                ov_di_slv_msg[9] <= iv_di_slv_msg[9];
                ov_do_slv_msg[9] <= iv_do_slv_msg[9];
            end
            9:begin
                ov_di_mst_msg    <= iv_di_mst_msg;
                ov_do_mst_msg    <= iv_do_mst_msg;
                ov_di_slv_msg[0] <= iv_di_slv_msg[0];
                ov_do_slv_msg[0] <= iv_do_slv_msg[0];
                ov_di_slv_msg[1] <= iv_di_slv_msg[1];
                ov_do_slv_msg[1] <= iv_do_slv_msg[1];
                ov_di_slv_msg[2] <= iv_di_slv_msg[2];
                ov_do_slv_msg[2] <= iv_do_slv_msg[2];
                ov_di_slv_msg[3] <= iv_di_slv_msg[3];
                ov_do_slv_msg[3] <= iv_do_slv_msg[3];
                ov_di_slv_msg[4] <= iv_di_slv_msg[4];
                ov_do_slv_msg[4] <= iv_do_slv_msg[4];
                ov_di_slv_msg[5] <= iv_di_slv_msg[5];
                ov_do_slv_msg[5] <= iv_do_slv_msg[5];
                ov_di_slv_msg[6] <= iv_di_slv_msg[6];
                ov_do_slv_msg[6] <= iv_do_slv_msg[6];
                ov_di_slv_msg[7] <= iv_di_slv_msg[7];
                ov_do_slv_msg[7] <= iv_do_slv_msg[7];
                ov_di_slv_msg[8] <= debug_di_mst_msg;
                ov_do_slv_msg[8] <= debug_do_mst_msg;
                ov_di_slv_msg[9] <= iv_di_slv_msg[9];
                ov_do_slv_msg[9] <= iv_do_slv_msg[9];
            end
            10:begin
                ov_di_mst_msg    <= iv_di_mst_msg;
                ov_do_mst_msg    <= iv_do_mst_msg;
                ov_di_slv_msg[0] <= iv_di_slv_msg[0];
                ov_do_slv_msg[0] <= iv_do_slv_msg[0];
                ov_di_slv_msg[1] <= iv_di_slv_msg[1];
                ov_do_slv_msg[1] <= iv_do_slv_msg[1];
                ov_di_slv_msg[2] <= iv_di_slv_msg[2];
                ov_do_slv_msg[2] <= iv_do_slv_msg[2];
                ov_di_slv_msg[3] <= iv_di_slv_msg[3];
                ov_do_slv_msg[3] <= iv_do_slv_msg[3];
                ov_di_slv_msg[4] <= iv_di_slv_msg[4];
                ov_do_slv_msg[4] <= iv_do_slv_msg[4];
                ov_di_slv_msg[5] <= iv_di_slv_msg[5];
                ov_do_slv_msg[5] <= iv_do_slv_msg[5];
                ov_di_slv_msg[6] <= iv_di_slv_msg[6];
                ov_do_slv_msg[6] <= iv_do_slv_msg[6];
                ov_di_slv_msg[7] <= iv_di_slv_msg[7];
                ov_do_slv_msg[7] <= iv_do_slv_msg[7];
                ov_di_slv_msg[8] <= iv_di_slv_msg[8];
                ov_do_slv_msg[8] <= iv_do_slv_msg[8];
                ov_di_slv_msg[9] <= debug_di_mst_msg;
                ov_do_slv_msg[9] <= debug_do_mst_msg;
            end
            default:begin
                ov_di_mst_msg    <= iv_di_mst_msg;
                ov_do_mst_msg    <= iv_do_mst_msg;
                ov_di_slv_msg[0] <= iv_di_slv_msg[0];
                ov_do_slv_msg[0] <= iv_do_slv_msg[0];
                ov_di_slv_msg[1] <= iv_di_slv_msg[1];
                ov_do_slv_msg[1] <= iv_do_slv_msg[1];
                ov_di_slv_msg[2] <= iv_di_slv_msg[2];
                ov_do_slv_msg[2] <= iv_do_slv_msg[2];
                ov_di_slv_msg[3] <= iv_di_slv_msg[3];
                ov_do_slv_msg[3] <= iv_do_slv_msg[3];
                ov_di_slv_msg[4] <= iv_di_slv_msg[4];
                ov_do_slv_msg[4] <= iv_do_slv_msg[4];
                ov_di_slv_msg[5] <= iv_di_slv_msg[5];
                ov_do_slv_msg[5] <= iv_do_slv_msg[5];
                ov_di_slv_msg[6] <= iv_di_slv_msg[6];
                ov_do_slv_msg[6] <= iv_do_slv_msg[6];
                ov_di_slv_msg[7] <= iv_di_slv_msg[7];
                ov_do_slv_msg[7] <= iv_do_slv_msg[7];
                ov_di_slv_msg[8] <= iv_di_slv_msg[8];
                ov_do_slv_msg[8] <= iv_do_slv_msg[8];
                ov_di_slv_msg[9] <= iv_di_slv_msg[9];
                ov_do_slv_msg[9] <= iv_do_slv_msg[9];
            end
        endcase
    end
end

reg [3:0] rx_state;
reg [7:0] rx_cnt;
reg [7:0] rx_data1_tmp;
reg [7:0] rx_data2_tmp;
reg [16:0] delay_cnt;
reg [7:0] check;
always @(posedge clk)begin
    if(reset)begin
        rx_state <= 'd0;
        rx_cnt   <= 'd0;
        rx_data_ok   <= 1'b0;
        delay_cnt   <= 'd0;
        rx_data1    <= 'd0;
        rx_data2    <= 'd0;
        rx_data1_tmp    <= 'd0;
        rx_data2_tmp    <= 'd0;
        check    <= 'd0;
    end else begin
        case(rx_state)
            0:begin
                if(rx_vld && (rx_data==8'hA5))begin
                    rx_state <= 'd1;
                end else begin
                    rx_state <= rx_state;
                end
                rx_data_ok   <= 1'b0;
                delay_cnt    <= 'd0;
                rx_cnt       <= 'd0;
                rx_data1     <= 'd0;
                rx_data2     <= 'd0;
                rx_data1_tmp <= 'd0;
                rx_data2_tmp <= 'd0;
            end
            1:begin
                if(rx_vld)begin
                    rx_data1_tmp <= rx_data;
                    rx_state <= 'd2;
                    rx_cnt   <= rx_cnt + 1;
                    delay_cnt   <= 'd0;
                end else if(delay_cnt>10)begin
                    rx_state <= 0;
                    rx_cnt   <= 0;
                    delay_cnt   <= 'd0;
                    rx_data1_tmp   <= 'd0;
                end else begin
                    rx_state <= rx_state;
                    rx_cnt   <= rx_cnt;
                    delay_cnt   <= delay_cnt + i_time_1ms_vld;
                    rx_data1_tmp   <= 'd0;
                end
                rx_data_ok   <= 1'b0;
                rx_data1     <= 'd0;
                rx_data2     <= 'd0;
                rx_data2_tmp <= 'd0;
                check <= 'd0;
            end
            2:begin
                if(rx_vld)begin
                    rx_data2_tmp <= rx_data;
                    rx_state <= 'd3;
                    rx_cnt   <= rx_cnt + 1;
                    delay_cnt   <= 'd0;
                end else if(delay_cnt>10)begin
                    rx_state <= 0;
                    rx_cnt   <= 0;
                    delay_cnt   <= 'd0;
                end else begin
                    rx_state <= rx_state;
                    rx_cnt   <= rx_cnt;
                    delay_cnt   <= delay_cnt + i_time_1ms_vld;
                end
                rx_data1     <= 'd0;
                rx_data2     <= 'd0;
                rx_data_ok   <= 1'b0;
                check     <= 'd0;
            end
            3:begin
                if(rx_vld)begin
                    check <= rx_data;
                    rx_state <= 'd4;
                    rx_cnt   <= rx_cnt + 1;
                    delay_cnt   <= 'd0;
                end else if(delay_cnt>10)begin
                    rx_state <= 0;
                    rx_cnt   <= 0;
                    delay_cnt   <= 'd0;
                end else begin
                    rx_state <= rx_state;
                    rx_cnt   <= rx_cnt;
                    delay_cnt   <= delay_cnt + i_time_1ms_vld;
                end
                rx_data1     <= 'd0;
                rx_data2     <= 'd0;
                rx_data_ok   <= 1'b0;
            end
            4:begin // delay
                if((8'hA5 + rx_data1_tmp + rx_data2_tmp)==check)begin
                    rx_data1     <= rx_data1_tmp;
                    rx_data2     <= rx_data2_tmp;
                    rx_data_ok   <= 1'b1;
                end else begin
                    rx_data1     <= 'd0;
                    rx_data2     <= 'd0;
                    rx_data_ok   <= 1'b0;
                end
                rx_state <= 'd0;
                rx_cnt   <= 'd0;
            end
            default:begin
                rx_state <= 'd0;
                rx_cnt   <= 'd0;
            end
        endcase
    end    
end



//ila_cal U_ila_cal(
//.clk(clk)
//,.probe0({o_di_debug,o_do_debug,reset,rx_data_ok,rx_vld,o_user_req,i_uart_rx,o_uart_tx,i_time_1ms_vld})
//,.probe1(ov_di_mst_msg)
//,.probe2(ov_do_mst_msg)
//,.probe3({rx_data1,rx_data2,rx_data,rx_cnt})
//,.probe4({rx_data1_tmp,rx_data2_tmp,check,rx_state})
//);

reg [95:0] di_send_to_app;
reg [63:0] do_send_to_app;

always @(posedge clk)begin
    if(reset)begin
        di_send_to_app <= 0;
        do_send_to_app <= 0;
    end else begin
        di_send_to_app <= ~debug_di_mst_msg;
        do_send_to_app <= ~debug_do_mst_msg;
    end
 end

reg       o_send_ready;         
reg       tx_en;         
reg [7:0] tx_data;    
wire      tx_ready;

reg [7:0] rs232_data_send_buf[RAM_DWIDTH*4-1:0];
reg [3:0] send_state;
integer for_i;
reg [7:0] send_cnt;
reg [7:0] send_length;
reg [7:0] tx_end_wait_cnt;
always @(posedge clk)begin
    if(reset)begin
        send_state <= 0;
        send_cnt <= 'h0;
        send_length <= 0;
        o_send_ready <= 0;
        tx_en <= 0;
        tx_data <= 0;
        tx_end_wait_cnt <= 0;
        o_uart_de <= 0;
    end else begin
        case(send_state)
            0:begin
                send_state <= 1;
                o_uart_de <= 1;
                o_send_ready <= 0;
                send_length <= 0;
                send_cnt <= 0;
                tx_en <= 0;
                tx_data <= 0;
                tx_end_wait_cnt <= 0;
            end
            1:begin
                rs232_data_send_buf[ 0] <= "d";
                rs232_data_send_buf[ 1] <= "i";
                rs232_data_send_buf[ 2] <= "d";
                rs232_data_send_buf[ 3] <= "o";
                rs232_data_send_buf[ 4] <= "=";
                rs232_data_send_buf[ 5] <= di_send_to_app[ 7: 0];
                rs232_data_send_buf[ 6] <= di_send_to_app[15: 8];
                rs232_data_send_buf[ 7] <= di_send_to_app[23:16];
                rs232_data_send_buf[ 8] <= di_send_to_app[31:24];
                rs232_data_send_buf[ 9] <= di_send_to_app[39:32];
                rs232_data_send_buf[10] <= di_send_to_app[47:40];
                rs232_data_send_buf[11] <= di_send_to_app[55:48];
                rs232_data_send_buf[12] <= di_send_to_app[63:56];
                rs232_data_send_buf[13] <= di_send_to_app[71:64];
                rs232_data_send_buf[14] <= di_send_to_app[79:72];
                rs232_data_send_buf[15] <= di_send_to_app[87:80];
                rs232_data_send_buf[16] <= di_send_to_app[95:88];
                
                rs232_data_send_buf[17] <= do_send_to_app[ 7: 0];
                rs232_data_send_buf[18] <= do_send_to_app[15: 8];
                rs232_data_send_buf[19] <= do_send_to_app[23:16];
                rs232_data_send_buf[20] <= do_send_to_app[31:24];
                rs232_data_send_buf[21] <= do_send_to_app[39:32];
                rs232_data_send_buf[22] <= do_send_to_app[47:40];
                rs232_data_send_buf[23] <= do_send_to_app[55:48];
                rs232_data_send_buf[24] <= do_send_to_app[63:56];
                rs232_data_send_buf[25] <= {6'd1+iv_slv_sta_num[6:0],do_debug,di_debug};
                rs232_data_send_buf[26] <= debug_board;
                rs232_data_send_buf[27] <= 8'h0d;
                rs232_data_send_buf[28] <= 8'h0a;
                
                send_state <= tx_ready ? 2 : 1;
                send_length <= 29;
                send_cnt <= 0;
                tx_end_wait_cnt <= 0;
                o_uart_de <= 1;
            end
            2:begin
                send_state <= 3;
                tx_en <= 1;
                tx_data <= rs232_data_send_buf[send_cnt];
                send_cnt <= send_cnt + 1;
                tx_end_wait_cnt <= 0;
                o_uart_de <= 1;
            end
            3:begin
                send_state <= 4;
                tx_en <= 0;
                tx_data <= tx_data;
                send_cnt <= send_cnt;
                tx_end_wait_cnt <= 0;
                o_uart_de <= 1;
            end
            4:begin
                if(tx_ready)begin
                    if(send_cnt==send_length)send_state <= 5;
                    else send_state <= 2;
                end else begin
                    send_state <= 4;
                end
                tx_en <= 0;
                tx_data <= tx_data;
                send_cnt <= send_cnt;
                tx_end_wait_cnt <= 0;
                o_uart_de <= 1;
            end
            5:begin
                if(tx_end_wait_cnt >= 50)begin // 1ms
                    send_state <= 0;
                    tx_end_wait_cnt <= 0;
                end else begin
                    send_state <= 5;
                    tx_end_wait_cnt <= tx_end_wait_cnt + i_time_1ms_vld;
                end
                o_uart_de <= 0;
            end
            default:begin
                send_state <= 0;
                tx_en <= 0;
                tx_data <= tx_data;
                send_cnt <= send_cnt;
                o_uart_de <= 0;
            end
        endcase
    end
end


uart_recv #(                    
    .CLK_FREQ       (CLK_FREQ),   
    .UART_BPS       (UART_BPS))   
u_uart_recv(                 
    .sys_clk        (clk   ), 
    .sys_rst_n      (~reset),
    
    .uart_rxd       (i_uart_rx),
    .uart_done      (rx_done),
    .uart_data      (rx_data)
    );
    
 
 
uart_send #(                          
    .CLK_FREQ       (CLK_FREQ),       
    .UART_BPS       (UART_BPS))     
u_uart_send(                 
    .sys_clk        (clk   ),
    .sys_rst_n      (~reset),
     
    .uart_en        (tx_en),
    .uart_din       (tx_data),
    .uart_tx_ready  (tx_ready),
    .uart_txd       (o_uart_tx)
    );
    
 
endmodule
