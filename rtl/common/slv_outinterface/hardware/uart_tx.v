`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/27 16:34:44
// Design Name: 
// Module Name: uart_tx
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
module uart_tx(
	input wire 			   i_clk,
	input wire 			   i_rstn,
	
	input wire [2:0]      i_bps_sel,
	input wire 	[1:0]	   i_odd_even_check,
	output reg 			   o_uart_tx,
	input wire [7:0] 	   i_tx_data,
	output reg 			   o_tx_done,
	output reg 			   o_tx_idle,
	input wire 			   i_tx_en
);

localparam bps4800          = 16'd20832;
localparam bps9600          = 16'd10416;
localparam bps19200         = 16'd5208;
localparam bps38400         = 16'd2604;
localparam bps57600         = 16'd1736;
localparam bps115200        = 16'd868;
localparam TX_IDLE      	= 4'b0000; 
localparam TX_START_BIT 	= 4'b0001;//start bit
localparam TX_FIRST_BIT  	= 4'b0010;//1 bit
localparam TX_SECOND_BIT  	= 4'b0011;//2 bit
localparam TX_THIRD_BIT  	= 4'b0100;//3 bit
localparam TX_FOURTH_BIT  	= 4'b0101;//4 bit
localparam TX_FIFTH_BIT  	= 4'b0110;//5 bit
localparam TX_SIXTH_BIT  	= 4'b0111;//6 bit
localparam TX_SEVENTH_BIT  	= 4'b1000;//7 bit
localparam TX_EIGHTH_BIT  	= 4'b1001;//8 bit
localparam TX_CHECK_BIT 	= 4'b1010;
localparam TX_STOP_BIT  	= 4'b1011;
localparam TX_DONE          = 4'b1100;
localparam TX_BEAT          = 4'b1101;

reg [3:0]    cur_state;
reg [3:0]    nxt_state;
reg [7:0]    tx_data;
reg [31:0]   bps_count;
reg [31:0]   bps_para;
reg          bps_clk;
wire 		 odd_check;
wire 		 even_check;

always @(posedge i_clk)begin
	case(i_bps_sel)
		3'b000:begin
			bps_para <= bps115200;
		end
		3'b001:begin
			bps_para <= bps9600;
		end
		3'b010:begin
			bps_para <= bps19200;
		end
		3'b011:begin
			bps_para <= bps38400;
		end
		3'b100:begin
			bps_para <= bps57600;
		end
		3'b101:begin
			bps_para <= bps4800;
		end
		default:begin
			bps_para <= bps115200;
		end
	endcase
end

always @(posedge i_clk or negedge i_rstn)begin
	if(!i_rstn)begin
		tx_data <= 8'd0;
	end
	else if(i_tx_en)begin
		tx_data <= i_tx_data;
	end
	else begin
		tx_data <= tx_data;
	end
end

always @(posedge i_clk or negedge i_rstn)begin
	if(!i_rstn)begin
		cur_state <= TX_IDLE;
	end
	else begin
		cur_state <= nxt_state;
	end
end

always @(*)begin
	if(!i_rstn)begin
		nxt_state = TX_IDLE;
	end
	else begin
		case(cur_state)
		TX_IDLE:begin
			if(i_tx_en)begin
				nxt_state = TX_START_BIT;
			end
			else begin
				nxt_state = TX_IDLE;
			end
		end
		TX_START_BIT:begin
			if(bps_clk)begin
				nxt_state = TX_FIRST_BIT;
			end
			else begin
				nxt_state = TX_START_BIT;
			end
		end
		TX_FIRST_BIT:begin
			if(bps_clk)begin
				nxt_state = TX_SECOND_BIT;
			end
			else begin
				nxt_state = TX_FIRST_BIT;
			end
		end
		TX_SECOND_BIT:begin
			if(bps_clk)begin
				nxt_state = TX_THIRD_BIT;
			end
			else begin
				nxt_state = TX_SECOND_BIT;
			end
		end
		TX_THIRD_BIT:begin
			if(bps_clk)begin
				nxt_state = TX_FOURTH_BIT;
			end
			else begin
				nxt_state = TX_THIRD_BIT;
			end
		end
		TX_FOURTH_BIT:begin
			if(bps_clk)begin
				nxt_state = TX_FIFTH_BIT;
			end
			else begin
				nxt_state = TX_FOURTH_BIT;
			end
		end
		TX_FIFTH_BIT:begin
			if(bps_clk)begin
				nxt_state = TX_SIXTH_BIT;
			end
			else begin
				nxt_state = TX_FIFTH_BIT;
			end
		end
		TX_SIXTH_BIT:begin
			if(bps_clk)begin
				nxt_state = TX_SEVENTH_BIT;
			end
			else begin
				nxt_state = TX_SIXTH_BIT;
			end
		end
		TX_SEVENTH_BIT:begin
			if(bps_clk)begin
				nxt_state = TX_EIGHTH_BIT;
			end
			else begin
				nxt_state = TX_SEVENTH_BIT;
			end
		end
		TX_EIGHTH_BIT:begin
			if(bps_clk)begin
				if(i_odd_even_check[1])begin
					nxt_state = TX_CHECK_BIT;
				end
				else begin
					nxt_state = TX_STOP_BIT;
				end
			end
			else begin
				nxt_state = TX_EIGHTH_BIT;
			end
		end
		TX_CHECK_BIT:begin
			if(bps_clk)begin
				nxt_state = TX_STOP_BIT;
			end
			else begin
				nxt_state = TX_CHECK_BIT;
			end
		end
		TX_STOP_BIT:begin
			if(bps_clk)begin
				nxt_state = TX_DONE;
			end
			else begin
				nxt_state = TX_STOP_BIT;
			end
		end
		TX_DONE:begin
			if(bps_clk)begin
				nxt_state = TX_BEAT;
			end
			else begin
				nxt_state = TX_DONE;
			end
		end
		TX_BEAT:begin
		    nxt_state = TX_IDLE;
		end
		default:begin
			nxt_state = TX_IDLE;
		end
		endcase
	end
end
always @(posedge i_clk or negedge i_rstn)begin
	if(!i_rstn)begin
		o_uart_tx <= 1'b1;
	end
	else begin
		case(cur_state)
			TX_IDLE:begin
				o_uart_tx <= 1'b1;
			end
			TX_START_BIT:begin
				if(bps_clk)begin
					o_uart_tx <= 1'b0;
				end
				else begin
					o_uart_tx <= o_uart_tx;
				end
			end
			TX_FIRST_BIT:begin
				if(bps_clk)begin
					o_uart_tx <= tx_data[0];
				end
				else begin
					o_uart_tx <= o_uart_tx;
				end
			end
			TX_SECOND_BIT:begin
				if(bps_clk)begin
					o_uart_tx <= tx_data[1];
				end
				else begin
					o_uart_tx <= o_uart_tx;
				end
			end
			TX_THIRD_BIT:begin
				if(bps_clk)begin
					o_uart_tx <= tx_data[2];
				end
				else begin
					o_uart_tx <= o_uart_tx;
				end
			end
			TX_FOURTH_BIT:begin
				if(bps_clk)begin
					o_uart_tx <= tx_data[3];
				end
				else begin
					o_uart_tx <= o_uart_tx;
				end
			end
			TX_FIFTH_BIT:begin
				if(bps_clk)begin
					o_uart_tx <= tx_data[4];
				end
				else begin
					o_uart_tx <= o_uart_tx;
				end
			end
			TX_SIXTH_BIT:begin
				if(bps_clk)begin
					o_uart_tx <= tx_data[5];
				end
				else begin
					o_uart_tx <= o_uart_tx;
				end
			end
			TX_SEVENTH_BIT:begin
				if(bps_clk)begin
					o_uart_tx <= tx_data[6];
				end
				else begin
					o_uart_tx <= o_uart_tx;
				end
			end
			TX_EIGHTH_BIT:begin
				if(bps_clk)begin
					o_uart_tx <= tx_data[7];
				end
				else begin
					o_uart_tx <= o_uart_tx;
				end
			end
			TX_CHECK_BIT:begin
				if(bps_clk)begin
					if(i_odd_even_check[0])begin//odd check
						o_uart_tx <= odd_check;
					end
					else begin
						o_uart_tx <= even_check;
					end
				end
				else begin
					o_uart_tx <= o_uart_tx;
				end
			end
			TX_STOP_BIT:begin
				if(bps_clk)begin
					o_uart_tx <= 1'b1;
				end
				else begin
					o_uart_tx <= o_uart_tx;
				end
			end
			TX_DONE:begin
				if(bps_clk)begin
					o_uart_tx <= 1'b1;
				end
				else begin
					o_uart_tx <= o_uart_tx;
				end
			end
			default:begin
				o_uart_tx <= 1'b1;
			end
		endcase
	end
end
assign odd_check  = tx_data[0]^tx_data[1]^tx_data[2]^tx_data[3]^tx_data[4]^tx_data[5]^tx_data[6]^tx_data[7]^1'b1;
assign even_check = tx_data[0]^tx_data[1]^tx_data[2]^tx_data[3]^tx_data[4]^tx_data[5]^tx_data[6]^tx_data[7]^1'b0;

always @(posedge i_clk or negedge i_rstn)begin
	if(!i_rstn)begin
		bps_count <= 32'd1;
	end
	else begin
		case(cur_state)
			TX_IDLE:begin
				bps_count <= 32'd1;
			end
			TX_FIRST_BIT,TX_SECOND_BIT,TX_THIRD_BIT,TX_FOURTH_BIT,TX_FIFTH_BIT,TX_SIXTH_BIT,TX_SEVENTH_BIT,TX_EIGHTH_BIT:begin
				if(bps_count == (bps_para-1))begin
					bps_count <= 32'd1;
				end
				else begin
					bps_count <= bps_count + 32'd1;
				end
			end
			TX_START_BIT,TX_CHECK_BIT,TX_STOP_BIT,TX_DONE:begin
				if(bps_count == (bps_para-1))begin
					bps_count <= 32'd1;
				end
				else begin
					bps_count <= bps_count + 32'd1;
				end
			end
			default:begin
				bps_count <= 32'd1;
			end
		endcase
	end
end
always @(posedge i_clk or negedge i_rstn)begin
	if(!i_rstn)begin
		bps_clk <= 1'b0;
	end
	else if(bps_count == ((bps_para>>1)-1))begin
		bps_clk <= 1'b1;
	end
	else begin
		bps_clk <= 1'b0;
	end
end
always @(posedge i_clk or negedge i_rstn)begin
	if(!i_rstn)begin
		o_tx_done <= 1'b0;
	end
	else if(cur_state == TX_DONE && nxt_state == TX_BEAT)begin
		o_tx_done <= 1'b1;
	end
	else begin
		o_tx_done <= 1'b0;
	end
end
always @(posedge i_clk or negedge i_rstn)begin
	if(!i_rstn)begin
		o_tx_idle <= 1'b1;
	end
	else if(i_tx_en)begin
		o_tx_idle <= 1'b0;
	end
	else if(o_tx_done)begin
		o_tx_idle <= 1'b1;
	end
	else begin
		o_tx_idle <= o_tx_idle;
	end
end
endmodule