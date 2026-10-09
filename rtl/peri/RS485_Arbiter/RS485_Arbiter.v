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
    end else begin
        if(abiter_cnt==USER_NUMBER)begin
            abiter_cnt <= 'd0;
            o_user_grant <= 'd0;
        end else begin
            if(i_user_req[abiter_cnt])begin
                o_user_grant[abiter_cnt] <= 'b1;
            end else begin
                abiter_cnt <= abiter_cnt + 1;
                o_user_grant <= 'd0;
            end
        end
    end
end


//rx direct pass-through: every user always follows the physical line (registered, reset low).
//old: only the granted user got i_uart_rx, all others were forced to idle-high; on a bus that
//physically idles low, the grant handover made o_user_rx fall 1->0 - a phantom start bit that
//the user's uart_rx received as a junk 0x00 byte on every query. a direct connection never
//synthesizes a level, so o_user_rx has no edge the line itself doesn't have. non-granted users
//simply see the shared bus, same as a real rs485 line; their frame checks (addr match) ignore it.
//note: line low during own tx = transceiver /RE disabled by de, that is real line behavior.
always @(posedge clk)begin
    if(reset)
        o_user_rx <= 'd0;
    else
        o_user_rx <= {USER_NUMBER{i_uart_rx}};
end


//pass user tx/de to the bus only while that user is granted(o_user_grant is registered,
//so the gate itself is glitch-free);
//when the bus is idle(arbiter scanning, no grant) force UART mark level(tx=1, de=0),
//so the scanning mux never leaks 1-cycle slices / glitches of unconnected users to the port.
//old: direct combinational mux, idle bus outputs 1-cycle slices of unconnected users(tx pulses every USER_NUMBER+1 cycles)
//assign o_uart_de = i_user_de[abiter_cnt];
//assign o_uart_tx = i_user_tx[abiter_cnt];
assign o_uart_de = (|o_user_grant) ? i_user_de[abiter_cnt] : 1'b0;
assign o_uart_tx = (|o_user_grant) ? i_user_tx[abiter_cnt] : 1'b1;


endmodule
