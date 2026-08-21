`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/23 13:54:41
// Design Name: 
// Module Name: debug_uart_arbitor
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


module debug_uart_arbitor#(
    parameter  CLK_FREQ = 100000000
   ,parameter  UART_BPS = 115200
)(
    input                   ps_reg_clk
   ,input                   ps_reg_reset
   ,input                   i_time_1ms_vld
   
   // io interface

   ,input   wire             i_uart1_rx
   ,output  wire             o_uart1_tx
   ,output  wire             o_uart1_de
   
   ,input   wire             i_uart2_rx
   ,output  wire             o_uart2_tx
   ,output  wire             o_uart2_de
   
   ,input   wire             i_uart3_rx
   ,output  wire             o_uart3_tx
   ,output  wire             o_uart3_de
   
   ,output   wire            o_debug_uart_rx
   ,input   wire             i_debug_uart_tx
   ,input   wire             i_debug_uart_de
   
   ,output   wire            o_user_uart1_rx
   ,input   wire             i_user_uart1_tx
   ,input   wire             i_user_uart1_de
   
   ,output   wire            o_user_uart2_rx
   ,input   wire             i_user_uart2_tx
   ,input   wire             i_user_uart2_de
   
   ,output   wire            o_user_uart3_rx
   ,input   wire             i_user_uart3_tx
   ,input   wire             i_user_uart3_de
   
   ,output   wire            o_debug_mode
        
);

wire clk = ps_reg_clk;
wire reset = ps_reg_reset;
     
wire [3:0] uart1_heat_cnt;
uart_debug_req #(                          
    .CLK_FREQ       (CLK_FREQ),       
    .UART_BPS       (UART_BPS))     
 U_uart1_debug_req(
     .ps_reg_clk        (ps_reg_clk        )
    ,.ps_reg_reset      (ps_reg_reset      )
    ,.i_time_1ms_vld    (i_time_1ms_vld    )
    ,.i_uart_rx         (i_uart1_rx        )
    ,.ov_uart_heat_cnt  (uart1_heat_cnt    )
   
);

wire [3:0] uart2_heat_cnt;
uart_debug_req #(                          
    .CLK_FREQ       (CLK_FREQ),       
    .UART_BPS       (UART_BPS))     
 U_uart2_debug_req(
     .ps_reg_clk        (ps_reg_clk        )
    ,.ps_reg_reset      (ps_reg_reset      )
    ,.i_time_1ms_vld    (i_time_1ms_vld    )
    ,.i_uart_rx         (i_uart2_rx        )
    ,.ov_uart_heat_cnt  (uart2_heat_cnt    )
);

wire [3:0] uart3_heat_cnt;
uart_debug_req #(                          
    .CLK_FREQ       (CLK_FREQ),       
    .UART_BPS       (UART_BPS))     
 U_uart3_debug_req(
     .ps_reg_clk        (ps_reg_clk        )
    ,.ps_reg_reset      (ps_reg_reset      )
    ,.i_time_1ms_vld    (i_time_1ms_vld    )
    ,.i_uart_rx         (i_uart3_rx        )
    ,.ov_uart_heat_cnt  (uart3_heat_cnt    )
);

reg [2:0] uart_debug_enb;
always @(posedge clk)begin
    if(reset)begin
        uart_debug_enb <= 0;
    end else begin
        if(&uart1_heat_cnt)begin
            uart_debug_enb <= 3'b001;
        end else if(&uart2_heat_cnt)begin
            uart_debug_enb <= 3'b010;
        end else if(&uart3_heat_cnt)begin
            uart_debug_enb <= 3'b100;
        end else begin
            uart_debug_enb <= 3'b000;
        end
    end
end

assign o_debug_mode = |uart_debug_enb;

assign o_debug_uart_rx = 
                        uart_debug_enb[0] ? i_uart1_rx : 
                        uart_debug_enb[1] ? i_uart2_rx : 
                        uart_debug_enb[2] ? i_uart3_rx : 0;
                        
 assign o_user_uart1_rx = uart_debug_enb[0] ? 0 : i_uart1_rx;
 assign o_uart1_tx      = uart_debug_enb[0] ? i_debug_uart_tx : i_user_uart1_tx;
 assign o_uart1_de      = uart_debug_enb[0] ? i_debug_uart_de : i_user_uart1_de;

 assign o_user_uart2_rx = uart_debug_enb[1] ? 0 : i_uart2_rx;
 assign o_uart2_tx      = uart_debug_enb[1] ? i_debug_uart_tx : i_user_uart2_tx;
 assign o_uart2_de      = uart_debug_enb[1] ? i_debug_uart_de : i_user_uart2_de;
 
 assign o_user_uart3_rx = uart_debug_enb[2] ? 0 : i_uart3_rx;
 assign o_uart3_tx      = uart_debug_enb[2] ? i_debug_uart_tx : i_user_uart3_tx;
 assign o_uart3_de      = uart_debug_enb[2] ? i_debug_uart_de : i_user_uart3_de;
endmodule
