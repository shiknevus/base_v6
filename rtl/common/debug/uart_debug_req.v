`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/23 15:10:58
// Design Name: 
// Module Name: uart_debug_req
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


module uart_debug_req#(
    parameter  CLK_FREQ = 100000000
   ,parameter  UART_BPS = 115200
)(
    input                   ps_reg_clk
   ,input                   ps_reg_reset
   ,input                   i_time_1ms_vld
   
   ,input   wire           i_uart_rx
   ,output reg [3:0]       ov_uart_heat_cnt

    );
    
wire clk = ps_reg_clk;
wire reset = ps_reg_reset;


wire       uart_rx_vld ;
wire [7:0] uart_rx_data;
reg  [7:0] uart_rx_data_n1;
reg  [7:0] uart_rx_data_n2;
reg  [7:0] uart_rx_data_n3;

wire uart_done;                        
wire [7:0] rx_data;    
reg        rx_done_n;
assign uart_rx_vld = (~rx_done_n) & uart_done;
always @(posedge clk)begin
    if(reset)begin
        rx_done_n <= 0;
    end else begin
        rx_done_n <= uart_done;
    end    
end                                                
       
uart_recv #(                    
    .CLK_FREQ       (CLK_FREQ),   
    .UART_BPS       (UART_BPS))   
u_uart_recv(                 
    .sys_clk        (clk   ), 
    .sys_rst_n      (~reset),
    
    .uart_rxd       (i_uart_rx   ),
    .uart_done      (uart_done   ),
    .uart_data      (uart_rx_data)
);
reg uart_heart;
always @(posedge clk)begin
    if(reset)begin
        uart_rx_data_n1 <= 'd0;
        uart_rx_data_n2 <= 'd0;
        uart_rx_data_n3 <= 'd0;
        uart_heart <= 'b0;
    end else begin
        if(uart_rx_vld)begin
            uart_rx_data_n1 <= uart_rx_data;
            uart_rx_data_n2 <= uart_rx_data_n1;
            uart_rx_data_n3 <= uart_rx_data_n2;
            if((uart_rx_data_n3==8'd165)&&(uart_rx_data_n2==8'd124)&&(uart_rx_data_n1==8'd204)&&(uart_rx_data==8'd237))begin
                uart_heart <= 1;
            end else begin
                uart_heart <= 0;
            end
        end else begin
            uart_heart <= 0;
        end
    end
end


reg [11:0] uart_debug_timeout_cnt;
always @(posedge clk)begin
    if(reset)begin
        uart_debug_timeout_cnt <= 2000;
        ov_uart_heat_cnt <= 'd0;
    end else begin
        if(uart_heart)begin
            uart_debug_timeout_cnt <= 0;
            ov_uart_heat_cnt <= {ov_uart_heat_cnt[2:0],1'b1};
        end else if(uart_debug_timeout_cnt<1800)begin
            uart_debug_timeout_cnt <= uart_debug_timeout_cnt + i_time_1ms_vld;
            ov_uart_heat_cnt <= ov_uart_heat_cnt;
        end else begin
            uart_debug_timeout_cnt <= 2000;
            ov_uart_heat_cnt <= 0;
        end
    end
end
    
endmodule
