`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: cgliu
// 
// Create Date: 2026/06/29 22:42:53
// Design Name: 
// Module Name: irq_3i1o_arbitrator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.02 - Add irq_a_grant_o / irq_b_grant_o / irq_c_grant_o pulse logic
// Additional Comments:
// Priority rule: 0:abc	1:acb	2:bac	3:bca	4:cab	5:cba
//////////////////////////////////////////////////////////////////////////////////

module irq_3i1o_arbitrator(
	input                   clk_i              
	,input                  rst_i             
	
	,input		[9:0]		sc_id              
	,input		[13:0]		ec_id   
		
	,input		[3:0]		chl_priority
		
	,input					irq_a_i				// Channel A interrupt request
	,output	reg				irq_a_grant_o		// Interrupt grant single cycle pulse
	,input 		[7:0]		a_bhv_id        
	,input 		[7:0]		a_tx_id         
	,input 		[7:0]		a_alm_num   
	
	,input					irq_b_i				// Channel B interrupt request
	,output	reg				irq_b_grant_o		// Interrupt grant single cycle pulse
	,input		[7:0]		b_bhv_id       	
	,input		[7:0]		b_tx_id        	
	,input		[7:0]		b_alm_num      	

	,input					irq_c_i				// Channel C interrupt request
	,output	reg				irq_c_grant_o		// Interrupt grant single cycle pulse
	,input		[7:0]		c_bhv_id       	
	,input 		[7:0]		c_tx_id        	
	,input 		[7:0]		c_alm_num		
	
	,output	reg	[31:0]		irq_reg1_o			// Interrupt Request Register 1
	,output	reg	[31:0]		irq_reg2_o			// Interrupt Request Register 2
	
	,output	reg				irq_o			
	,output	reg				irq_busy_o		
	,input					irq_receive_ack_i	// PS interrupt receive acknowledge
);
	
	
	reg [7:0] 	irq_cnt;
	
	reg			irq_receive_ack	;
	reg	[1:0]	irq_receive_ack_i_r;

	localparam	S_IDLE			=	8'd0;
	localparam	S_DELAY1		=	8'd1;
	localparam	S_DELAY2		=	8'd2;
	localparam	S_WAIT_IRQ_ACK1	=	8'd3;
	localparam	S_WAIT_IRQ_ACK2	=	8'd4;
	localparam	S_END_DELAY		=	8'd5;
	
	reg		[7:0]	s_sta;
	
	//delect posedge irq_receive_ack_i
	always@(posedge clk_i)begin
	if(rst_i)begin
		irq_receive_ack_i_r <= 2'b00;
		irq_receive_ack		<= 1'b0;
	end else begin
		irq_receive_ack_i_r <= {irq_receive_ack_i_r[0],irq_receive_ack_i};
		irq_receive_ack 	<= (~irq_receive_ack_i_r[1]) && irq_receive_ack_i_r[0];
	end
	end
	
	//sync register
	reg 			r_irq_a_i	 ;
	reg 	[7:0]	r_a_bhv_id   ;
	reg 	[7:0]	r_a_tx_id    ;
	reg 	[7:0]	r_a_alm_num  ;
	
	reg 			r_irq_b_i	 ;
	reg 	[7:0]	r_b_bhv_id   ;
	reg 	[7:0]	r_b_tx_id    ;
	reg 	[7:0]	r_b_alm_num  ;
	
	reg 			r_irq_c_i	 ;
	reg 	[7:0]	r_c_bhv_id   ;
	reg 	[7:0]	r_c_tx_id    ;
	reg 	[7:0]	r_c_alm_num  ;
	
	always@(posedge clk_i)
	begin
		if(rst_i)
			r_irq_a_i <= 1'b0;
		else
			r_irq_a_i <= irq_a_i;
	end
	
	always@(posedge clk_i)
	begin
		if(rst_i)begin
			r_a_bhv_id  <= 8'd0;
			r_a_tx_id   <= 8'd0;
			r_a_alm_num <= 8'd0;
		end else if({r_irq_a_i,irq_a_i} == 2'b01)begin
			r_a_bhv_id  <= a_bhv_id ;
			r_a_tx_id   <= a_tx_id  ;
			r_a_alm_num <= a_alm_num;
		end else begin
			r_a_bhv_id  <= r_a_bhv_id ;
			r_a_tx_id   <= r_a_tx_id  ;
			r_a_alm_num <= r_a_alm_num;
		end	
	end
	
	always@(posedge clk_i)
	begin
		if(rst_i)
			r_irq_b_i <= 1'b0;
		else
			r_irq_b_i <= irq_b_i;
	end
	
	always@(posedge clk_i)
	begin
		if(rst_i)begin
			r_b_bhv_id  <= 8'd0;
			r_b_tx_id   <= 8'd0;
			r_b_alm_num <= 8'd0;
		end else if({r_irq_b_i,irq_b_i} == 2'b01)begin
			r_b_bhv_id  <= b_bhv_id ;
			r_b_tx_id   <= b_tx_id  ;
			r_b_alm_num <= b_alm_num;
		end else begin
			r_b_bhv_id  <= r_b_bhv_id ;
			r_b_tx_id   <= r_b_tx_id  ;
			r_b_alm_num <= r_b_alm_num;
		end	
	end
	
	always@(posedge clk_i)
	begin
		if(rst_i)
			r_irq_c_i <= 1'b0;
		else
			r_irq_c_i <= irq_c_i;
	end
	
	always@(posedge clk_i)
	begin
		if(rst_i)begin
			r_c_bhv_id  <= 8'd0;
			r_c_tx_id   <= 8'd0;
			r_c_alm_num <= 8'd0;
		end else if({r_irq_c_i,irq_c_i} == 2'b01)begin
			r_c_bhv_id  <= c_bhv_id ;
			r_c_tx_id   <= c_tx_id  ;
			r_c_alm_num <= c_alm_num;
		end else begin
			r_c_bhv_id  <= r_c_bhv_id ;
			r_c_tx_id   <= r_c_tx_id  ;
			r_c_alm_num <= r_c_alm_num;
		end	
	end
	
	//The channel currently being handled by the state machine
	reg	[3:0]	cur_chan;
	

always @(posedge clk_i) begin
	if(rst_i) begin
		s_sta <= S_IDLE;
		irq_a_grant_o <= 1'b0;
        irq_b_grant_o <= 1'b0;
        irq_c_grant_o <= 1'b0;
		cur_chan <= 4'h0;
	end else
		case(s_sta)
			S_IDLE:begin
			
				case(chl_priority)
					4'd0: begin // abc
						if(irq_a_i)begin
							irq_a_grant_o <= 1'b1;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hA;
							s_sta <= S_DELAY1;
						end else if(irq_b_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b1;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hB;
							s_sta <= S_DELAY1;
						end else if(irq_c_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b1;
							cur_chan <= 4'hC;
							s_sta <= S_DELAY1;
						end else begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'h0;
							s_sta <= S_IDLE;
						end
					end
					4'd1: begin // acb
						if(irq_a_i)begin
							irq_a_grant_o <= 1'b1;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hA;
							s_sta <= S_DELAY1;
						end else if(irq_c_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b1;
							cur_chan <= 4'hC;
							s_sta <= S_DELAY1;
						end else if(irq_b_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b1;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hB;
							s_sta <= S_DELAY1;
						end else begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'h0;
							s_sta <= S_IDLE;
						end
					end
					4'd2: begin // bac
						if(irq_b_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b1;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hB;
							s_sta <= S_DELAY1;
						end else if(irq_a_i)begin
							irq_a_grant_o <= 1'b1;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hA;
							s_sta <= S_DELAY1;
						end else if(irq_c_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b1;
							cur_chan <= 4'hC;
							s_sta <= S_DELAY1;
						end else begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'h0;
							s_sta <= S_IDLE;
						end
					end
					4'd3: begin // bca
						if(irq_b_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b1;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hB;
							s_sta <= S_DELAY1;
						end else if(irq_c_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b1;
							cur_chan <= 4'hC;
							s_sta <= S_DELAY1;
						end else if(irq_a_i)begin
							irq_a_grant_o <= 1'b1;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hA;
							s_sta <= S_DELAY1;
						end else begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'h0;
							s_sta <= S_IDLE;
						end
					end
					4'd4: begin // cab
						if(irq_c_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b1;
							cur_chan <= 4'hC;
							s_sta <= S_DELAY1;
						end else if(irq_a_i)begin
							irq_a_grant_o <= 1'b1;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hA;
							s_sta <= S_DELAY1;
						end else if(irq_b_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b1;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hB;
							s_sta <= S_DELAY1;
						end else begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'h0;
							s_sta <= S_IDLE;
						end
					end
					4'd5: begin // cba
						if(irq_c_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b1;
							cur_chan <= 4'hC;
							s_sta <= S_DELAY1;
						end else if(irq_b_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b1;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hB;
							s_sta <= S_DELAY1;
						end else if(irq_a_i)begin
							irq_a_grant_o <= 1'b1;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hA;
							s_sta <= S_DELAY1;
						end else begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'h0;
							s_sta <= S_IDLE;
						end
					end
					default: begin // default bac
						if(irq_b_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b1;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hB;
							s_sta <= S_DELAY1;
						end else if(irq_a_i)begin
							irq_a_grant_o <= 1'b1;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'hA;
							s_sta <= S_DELAY1;
						end else if(irq_c_i)begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b1;
							cur_chan <= 4'hC;
							s_sta <= S_DELAY1;
						end else begin
							irq_a_grant_o <= 1'b0;
							irq_b_grant_o <= 1'b0;
							irq_c_grant_o <= 1'b0;
							cur_chan <= 4'h0;
							s_sta <= S_IDLE;
						end
					end
				endcase
			end
			
			S_DELAY1:begin
				irq_a_grant_o <= 1'b0;
				irq_b_grant_o <= 1'b0;
				irq_c_grant_o <= 1'b0;
				s_sta <= S_DELAY2;
			end
			
			S_DELAY2:begin
				irq_a_grant_o <= 1'b0;
				irq_b_grant_o <= 1'b0;
				irq_c_grant_o <= 1'b0;
				s_sta <= S_WAIT_IRQ_ACK1;
			end
			
			S_WAIT_IRQ_ACK1:begin
				irq_a_grant_o <= 1'b0;
				irq_b_grant_o <= 1'b0;
				irq_c_grant_o <= 1'b0;
				
				if(irq_cnt <= 8'd31)begin
					if(irq_receive_ack)// Interrupt acknowledge received successfully
						s_sta <= S_END_DELAY;
					else
						s_sta <= S_WAIT_IRQ_ACK1;
				end else begin
						s_sta <= S_WAIT_IRQ_ACK2;
				end
			end
			
			S_WAIT_IRQ_ACK2:begin
				if(irq_receive_ack)// Interrupt acknowledge received successfully
					s_sta <= S_END_DELAY;
				else if(cur_chan == 4'hA && a_tx_id == 8'd40)	//A channel timeout
					s_sta <= S_END_DELAY;
				else if(cur_chan == 4'hB && b_tx_id == 8'd40)	//B channel timeout
					s_sta <= S_END_DELAY;
				else if(cur_chan == 4'hC && c_tx_id == 8'd40)	//C channel timeout
					s_sta <= S_END_DELAY;
				else
					s_sta <= S_WAIT_IRQ_ACK2;
			end
			
			S_END_DELAY: begin
				if(end_cnt >= 4'd8)begin
					cur_chan <= 4'h0;
					s_sta <= S_IDLE; 
				end else begin
					s_sta <= S_END_DELAY;
				end
			end
			
			default:
				s_sta <= S_IDLE;
		endcase
end

	always@(posedge clk_i)begin
	if(rst_i)
		irq_cnt <= 8'd0;
	else if(s_sta == S_WAIT_IRQ_ACK1) begin
		if(irq_cnt >= 8'd32) 
			irq_cnt <= irq_cnt;
		else
			irq_cnt <= irq_cnt +1;
	end else if(s_sta == S_WAIT_IRQ_ACK2) begin
		if(irq_cnt >= 8'd64)
			irq_cnt <= irq_cnt;
		else
			irq_cnt <= irq_cnt +1;
	end else
		irq_cnt <= 8'd0;
	end


	reg [3:0] end_cnt;
	always@(posedge clk_i)begin
	if(rst_i)
		end_cnt <= 4'd0;
	else if(s_sta == S_END_DELAY) begin
		if(end_cnt >= 4'd8)
			end_cnt <= end_cnt;
		else
			end_cnt <= end_cnt + 4'd1;
	end else
		end_cnt <= 4'd0;
	end	
	always@(posedge clk_i)begin
	if(rst_i)
		irq_busy_o <= 1'b0;
	else if(s_sta == S_IDLE)
		irq_busy_o <= 1'b0;
	else
		irq_busy_o <= 1'b1;
	end

	
	always@(posedge clk_i)begin
	if(rst_i)
		irq_o <= 1'b0;
	else if(s_sta == S_WAIT_IRQ_ACK1)
		irq_o <= 1'b1;
	else
		irq_o <= 1'b0;
	end

always @(posedge clk_i)
begin
    if(rst_i) begin
        irq_reg1_o <= 32'd0;
        irq_reg2_o <= 32'd0;
    end else if(irq_a_grant_o)begin
        irq_reg1_o <= {ec_id,sc_id,r_a_bhv_id};
        irq_reg2_o <= {r_a_tx_id,r_a_alm_num,16'd0};
	end else if(irq_b_grant_o)begin
        irq_reg1_o <= {ec_id,sc_id,r_b_bhv_id};
        irq_reg2_o <= {r_b_tx_id,r_b_alm_num,16'd0};
	end else if(irq_c_grant_o)begin
        irq_reg1_o <= {ec_id,sc_id,r_c_bhv_id};
        irq_reg2_o <= {r_c_tx_id,r_c_alm_num,16'd0};
	// end else if(s_sta == S_END_DELAY)begin
	// 	irq_reg1_o <= 32'd0;
    //     irq_reg2_o <= 32'd0;
	end else begin
		irq_reg1_o <= irq_reg1_o;
        irq_reg2_o <= irq_reg2_o;
    end
end

	
endmodule

