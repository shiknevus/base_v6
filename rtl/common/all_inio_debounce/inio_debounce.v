`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 2020/08/28 15:09:48
// Design Name: 
// Module Name: in_debounce
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Dependencies: 
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module inio_debounce
(
		 input wire				clk
		,input wire 			reset
		,input wire 			sample_en
		
		,input wire 			i_data
		,output reg 			o_data
);
		//localparam SAMP_SIZE = 18;
		localparam SAMP_SIZE = 10;
		reg [SAMP_SIZE-1:0] i_data_buf;
		
		always @(posedge clk)begin
		    if(reset) begin
                i_data_buf <= {SAMP_SIZE{1'b1}};
		    end else if(sample_en) begin
		        i_data_buf <= {i_data_buf[SAMP_SIZE-2:0],i_data};
            end
        end
        
        always @(posedge clk)begin
            if(reset) begin
                o_data <= 1'b1;
            end else if(sample_en && {SAMP_SIZE{i_data}}==i_data_buf) begin
		        o_data <= i_data;
		    end
        end
        
endmodule
