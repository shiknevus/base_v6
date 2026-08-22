`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/28 12:42:13
// Design Name: 
// Module Name: uart_top
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
   module uart_top
   (
	    input 		            clk
	   ,input 		            reset
		
	   ,input  wire [2:0]	    i_bps_sel
	   ,input  wire [1:0]	    i_odd_even_check
	   ,output wire  		    uart_txd
       ,input  wire 		    uart_rxd
	   ,input  wire [7:0]	    tx_data
       ,output wire [7:0]	    rx_data
	   ,output wire		        tx_ready 
       ,output wire		        rx_ready
       ,input  wire		        tx_en
    );

   uart_rx uart_rx_u
   (
        .i_clk			    (clk                 ),
        .i_rstn			    (~reset              ),
		
        .i_bps_sel	        (i_bps_sel           ),
        .i_odd_even_check	(i_odd_even_check    ),
        .i_uart_rx		    (uart_rxd            ),
        .o_rx_data		    (rx_data             ),
	    .o_rx_done		    (rx_ready            ),
	    .o_rx_idle          (                    )
    );

    uart_tx uart_tx_u
    (
        .i_clk			    (clk                 ),
        .i_rstn			    (~reset              ),
       
        .i_bps_sel	        (i_bps_sel           ),          
	    .i_odd_even_check	(i_odd_even_check    ),
        .o_uart_tx          (uart_txd            ),
        .i_tx_data		    (tx_data             ),
	    .o_tx_done		    (tx_ready            ),
	    .o_tx_idle		    (                    ),
	    .i_tx_en		    (tx_en               )
    );
	
endmodule
            