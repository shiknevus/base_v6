`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/19 16:27:32
// Design Name: 
// Module Name: RS485_Arbiter
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


module RS485_Arbiter#(
    parameter USER_NUMBER = 32
)(
    input                   clk
   ,input                   reset

   ,output  wire            o_uart_tx
   ,input   wire            i_uart_rx
   ,output  wire            o_uart_de
   
   ,input   wire [USER_NUMBER-1:0] i_user_req
   ,output  reg  [USER_NUMBER-1:0] o_user_grant
   ,input   wire [USER_NUMBER-1:0] i_user_tx
   ,output  reg [USER_NUMBER-1:0] o_user_rx
   ,input   wire [USER_NUMBER-1:0] i_user_de
);

reg [7:0] abiter_cnt;
always @(posedge clk)begin
    if(reset)begin
        abiter_cnt <= 'd0;
        o_user_grant <= 'd0;
        o_user_rx <= 32'hFFFFFFFF;
    end else begin
        if(abiter_cnt==USER_NUMBER)begin
            abiter_cnt <= 'd0;
            o_user_grant <= 'd0;
        end else begin
            if(i_user_req[abiter_cnt])begin
                o_user_grant[abiter_cnt] <= 'b1;
                o_user_rx[abiter_cnt] <= i_uart_rx;
            end else begin
                abiter_cnt <= abiter_cnt + 1;
                o_user_grant <= 'd0;
                o_user_rx[abiter_cnt] <= 1'b1;
            end
        end
    end
end


assign o_uart_de = i_user_de[abiter_cnt];
assign o_uart_tx = i_user_tx[abiter_cnt];


endmodule
