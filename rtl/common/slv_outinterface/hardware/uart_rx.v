`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/27 16:34:44
// Design Name: 
// Module Name: uart_rx
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
module uart_rx(
	input wire            i_clk,                  //100M-10ns
	input wire            i_rstn,
		
	input wire [2:0]      i_bps_sel,
	input wire [1:0]      i_odd_even_check,       //2'b0x:no check;2'b11:odd check;2'b10:even check; 
	input wire            i_uart_rx,
	output reg [7:0]      o_rx_data,
	output reg            o_rx_done,
	output reg            o_rx_idle
);

localparam bps4800          = 16'd20832;
localparam bps9600          = 16'd10416;
localparam bps19200         = 16'd5208;
localparam bps38400         = 16'd2604;
localparam bps57600         = 16'd1736;
localparam bps115200        = 16'd868;
localparam RX_IDLE      	= 4'd0;		
localparam RX_START_BIT 	= 4'd1;//start bit						
localparam RX_FIRST_BIT  	= 4'd2;//1 bit
localparam RX_SECOND_BIT  	= 4'd3;//2 bit
localparam RX_THIRD_BIT  	= 4'd4;//3 bit
localparam RX_FOURTH_BIT  	= 4'd5;//4 bit						
localparam RX_FIFTH_BIT  	= 4'd6;//5 bit
localparam RX_SIXTH_BIT  	= 4'd7;//6 bit
localparam RX_SEVENTH_BIT  	= 4'd8;//7 bit
localparam RX_EIGHTH_BIT  	= 4'd9;//8 bit						
localparam RX_CHECK_BIT 	= 4'd10;
localparam RX_STOP_BIT  	= 4'd11;

reg [3:0] 	 cur_state;
reg [3:0] 	 nxt_state;
reg 		 i_uart_rx_1clk;
reg 		 i_uart_rx_2clk;	
reg 		 bps_clk;
reg [31:0]   bps_count;
reg [31:0]   bps_para;
reg 		  check_error;
(* mark_debug = "true" *) reg          check_bit;
(* mark_debug = "true" *) wire 		 odd_check;
wire 		even_check;

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
		i_uart_rx_1clk <= 1'b1;
		i_uart_rx_2clk <= 1'b1;
	end
	else begin
		i_uart_rx_1clk <= i_uart_rx;
		i_uart_rx_2clk <= i_uart_rx_1clk;
	end
end

always @(posedge i_clk or negedge i_rstn)begin
	if(!i_rstn)begin
		cur_state <= RX_IDLE;
	end
	else begin
		cur_state <= nxt_state;
	end
end

always @(*)begin
	if(!i_rstn)begin
		nxt_state = RX_IDLE;
	end
	else begin
		case(cur_state)
			RX_IDLE:begin
				if(!i_uart_rx_1clk && i_uart_rx_2clk)begin
					nxt_state = RX_START_BIT;
				end
				else begin
					nxt_state = RX_IDLE;
				end
			end
			RX_START_BIT:begin//recv start bit
				if(bps_clk)begin
					if(i_uart_rx_2clk)begin
						nxt_state = RX_IDLE;
					end
					else begin
						nxt_state = RX_FIRST_BIT;
					end
				end
				else begin
					nxt_state = RX_START_BIT;
				end
			end
			RX_FIRST_BIT:begin//recv 1 bit
				if(bps_clk)begin
					nxt_state = RX_SECOND_BIT;
				end
				else begin
					nxt_state = RX_FIRST_BIT;
				end
			end
			RX_SECOND_BIT:begin//recv 2 bit
				if(bps_clk)begin
					nxt_state = RX_THIRD_BIT;
				end
				else begin
					nxt_state = RX_SECOND_BIT;
				end
			end
			RX_THIRD_BIT:begin//recv 3 bit
				if(bps_clk)begin
					nxt_state = RX_FOURTH_BIT;
				end
				else begin
					nxt_state = RX_THIRD_BIT;
				end
			end
			RX_FOURTH_BIT:begin//recv 4 bit
				if(bps_clk)begin
					nxt_state = RX_FIFTH_BIT;
				end
				else begin
					nxt_state = RX_FOURTH_BIT;
				end
			end
			RX_FIFTH_BIT:begin//recv 5 bit
				if(bps_clk)begin
					nxt_state = RX_SIXTH_BIT;
				end
				else begin
					nxt_state = RX_FIFTH_BIT;
				end
			end
			RX_SIXTH_BIT:begin//recv 6 bit
				if(bps_clk)begin
					nxt_state = RX_SEVENTH_BIT;
				end
				else begin
					nxt_state = RX_SIXTH_BIT;
				end
			end
			RX_SEVENTH_BIT:begin//recv 7 bit
				if(bps_clk)begin
					nxt_state = RX_EIGHTH_BIT;
				end
				else begin
					nxt_state = RX_SEVENTH_BIT;
				end
			end
			RX_EIGHTH_BIT:begin//recv 8 bit
				if(bps_clk)begin
					if(i_odd_even_check[1])begin
						nxt_state = RX_CHECK_BIT;
					end
					else begin
						nxt_state = RX_STOP_BIT;
					end
				end
				else begin
					nxt_state = RX_EIGHTH_BIT;
				end
			end
			RX_CHECK_BIT:begin
				if(bps_clk)begin
					nxt_state = RX_STOP_BIT;
				end
				else begin
					nxt_state = RX_CHECK_BIT;
				end
			end
			RX_STOP_BIT:begin
				if(bps_clk)begin
					nxt_state = RX_IDLE;
				end
				else begin
					nxt_state = RX_STOP_BIT;
				end
			end
			default:begin
				nxt_state = RX_IDLE;
			end
		endcase
	end
end
always @(posedge i_clk or negedge i_rstn)begin
	if(!i_rstn)begin
		bps_count <= 32'd1;
	end
	else begin
		case(cur_state)
			RX_IDLE:begin
				bps_count <= 32'd1;
			end
			RX_START_BIT,RX_FIRST_BIT,RX_SECOND_BIT,RX_THIRD_BIT,RX_FOURTH_BIT,RX_FIFTH_BIT,RX_SIXTH_BIT,RX_SEVENTH_BIT,RX_EIGHTH_BIT,RX_CHECK_BIT,RX_STOP_BIT:begin
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
		o_rx_data <= 8'd0;
	end
	else begin
		case(cur_state)
			RX_IDLE:begin
				o_rx_data <= o_rx_data;
			end
			RX_START_BIT:begin
				o_rx_data <= 8'd0;			
			end
			RX_FIRST_BIT:begin
				if(bps_clk)begin
					o_rx_data[0] <= i_uart_rx_2clk;
				end
				else begin
					o_rx_data <= o_rx_data;
				end
			end
			RX_SECOND_BIT:begin
				if(bps_clk)begin
					o_rx_data[1] <= i_uart_rx_2clk;
				end
				else begin
					o_rx_data <= o_rx_data;
				end
			end
			RX_THIRD_BIT:begin
				if(bps_clk)begin
					o_rx_data[2] <= i_uart_rx_2clk;
				end
				else begin
					o_rx_data <= o_rx_data;
				end
			end
			RX_FOURTH_BIT:begin
				if(bps_clk)begin
					o_rx_data[3] <= i_uart_rx_2clk;
				end
				else begin
					o_rx_data <= o_rx_data;
				end
			end
			RX_FIFTH_BIT:begin
				if(bps_clk)begin
					o_rx_data[4] <= i_uart_rx_2clk;
				end
				else begin
					o_rx_data <= o_rx_data;
				end
			end
			RX_SIXTH_BIT:begin
				if(bps_clk)begin
					o_rx_data[5] <= i_uart_rx_2clk;
				end
				else begin
					o_rx_data <= o_rx_data;
				end
			end
			RX_SEVENTH_BIT:begin
				if(bps_clk)begin
					o_rx_data[6] <= i_uart_rx_2clk;
				end
				else begin
					o_rx_data <= o_rx_data;
				end
			end
			RX_EIGHTH_BIT:begin
				if(bps_clk)begin
					o_rx_data[7] <= i_uart_rx_2clk;
				end
				else begin
					o_rx_data <= o_rx_data;
				end
			end
			RX_CHECK_BIT:begin
				o_rx_data <= o_rx_data;
			end
			RX_STOP_BIT:begin
				o_rx_data <= o_rx_data;
			end
			default:begin
				o_rx_data <= 8'd0;
			end
		endcase
	end
end
always @(posedge i_clk or negedge i_rstn)begin
	if(!i_rstn)begin
		o_rx_done <= 1'b0;
	end
	else if(cur_state == RX_STOP_BIT && bps_clk)begin
		if(i_odd_even_check[1])begin
			if(check_error)begin
				o_rx_done <= 1'b0;					
			end
			else begin
				o_rx_done <= 1'b1;				
			end
		end
		else begin
			o_rx_done <= 1'b1;
		end
	end
	else begin
	    o_rx_done <= 1'b0;		
	end
end
always @(posedge i_clk or negedge i_rstn)begin
	if(!i_rstn)begin
		check_bit <= 1'b0;
	end
	else if(bps_clk && cur_state == RX_CHECK_BIT)begin
		check_bit <= i_uart_rx_2clk;
	end
	else begin
		check_bit <= check_bit;
	end
end

assign odd_check = o_rx_data[0]^o_rx_data[1]^o_rx_data[2]^o_rx_data[3]^o_rx_data[4]^o_rx_data[5]^o_rx_data[6]^o_rx_data[7]^1'b1;
assign even_check = o_rx_data[0]^o_rx_data[1]^o_rx_data[2]^o_rx_data[3]^o_rx_data[4]^o_rx_data[5]^o_rx_data[6]^o_rx_data[7]^1'b0;

always @(posedge i_clk or negedge i_rstn)begin
	if(!i_rstn)begin
		check_error <= 1'b0;
	end
	else if(cur_state == RX_STOP_BIT)begin
		if(i_odd_even_check[0])begin//odd check
			check_error <= odd_check == check_bit? 1'b0:1'b1;
		end
		else begin
			check_error <= even_check == check_bit? 1'b0:1'b1;
		end
	end
	else begin
		check_error <= 1'b0;
	end
end

always @(posedge i_clk or negedge i_rstn)begin
	if(!i_rstn)begin
		o_rx_idle <= 1'b1;
	end
	else begin
		case(cur_state)
			RX_IDLE:begin
				o_rx_idle <= 1'b1;
			end
			default:begin
				o_rx_idle <= 1'b0;
			end
		endcase
    end
end

endmodule

