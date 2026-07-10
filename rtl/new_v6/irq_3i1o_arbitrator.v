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
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Priority: State behavior > Active behavior > Timing behavior

module irq_3i1o_arbitrator(
	input                   clk_i              
	,input                  rst_i             
	,input		[7:0]		sc_id              
	,input		[7:0]		ec_id              
		
		//irq_a_grant_o irq_a_i同步拉低
	,input					irq_a_i				// Channel A interrupt request
	,output	reg				irq_a_grant_o		// Interrupt grant signal
	,input 		[7:0]		a_bhv_id        
	,input 		[7:0]		a_tx_id         
	,input 		[7:0]		a_alm_num       
	
	,input					irq_b_i				// Channel B interrupt request
	,output	reg				irq_b_grant_o		// Interrupt grant signal
	,input		[7:0]		b_bhv_id       	
	,input		[7:0]		b_tx_id        	
	,input		[7:0]		b_alm_num      	

	,input					irq_c_i				// Channel C interrupt request
	,output	reg				irq_c_grant_o		// Interrupt grant signal
	,input		[7:0]		c_bhv_id       	
	,input 		[7:0]		c_tx_id        	
	,input 		[7:0]		c_alm_num		
	
	,output	reg	[31:0]		irq_reg1_o			// Interrupt Request Register 1
	,output	reg	[31:0]		irq_reg2_o			// Interrupt Request Register 2
	,output	reg				irq_o			
	,output	reg				irq_busy_o		
	,input					irq_receive_ack_i	// PS interrupt receive acknowledge
    );
	
	reg	[7:0]	curr_state		;
	reg	[7:0]	curr_state_1d	;
	reg	[7:0]	next_state		;
	
	reg [7:0] 	irq_cnt;
	
	reg			irq_receive_ack	;
	reg	[1:0]	irq_receive_ack_i_r;
	
	always@(posedge clk_i)begin
	if(rst_i)
		curr_state_1d <= 8'd0;
	else
		curr_state_1d <= curr_state;
	end
	
	always@(posedge clk_i)begin
	if(rst_i)
		irq_receive_ack_i_r <= 2'b00;
	else
		irq_receive_ack_i_r <= {irq_receive_ack_i_r[0],irq_receive_ack_i};
	end
	
	// Rising edge detection of interrupt acknowledge signal
	always@(posedge clk_i)begin
	if(rst_i)
		irq_receive_ack <= 1'b0;
	else
		irq_receive_ack <= (~irq_receive_ack_i_r[1]) && irq_receive_ack_i_r[0];
	end

	
	localparam	S_IDLE			=	8'd0;
	localparam	S_WAIT_IRQ_ACK1	=	8'd1;
	localparam	S_WAIT_IRQ_ACK2	=	8'd2;
	localparam	S_END_DELAY		=	8'd3;
	
	
	always @(posedge clk_i) begin
        if (rst_i)
            curr_state <= S_IDLE;
        else
            curr_state <= next_state;
    end
	
	always @(*) begin
        case (curr_state)
            S_IDLE: begin
                if(irq_b_i)	// State behavior has the highest priority
                    next_state <= S_WAIT_IRQ_ACK1;
                else if(irq_a_i)
                    next_state <= S_WAIT_IRQ_ACK1;
				else if(irq_c_i)
					next_state <= S_WAIT_IRQ_ACK1;
				else
					next_state <= S_IDLE;
            end
			
			S_WAIT_IRQ_ACK1: begin
				if(irq_cnt <= 8'd31)begin
					if(irq_receive_ack)// Interrupt acknowledge received successfully
						next_state <= S_END_DELAY;
					else
						next_state <= S_WAIT_IRQ_ACK1;
				end else
					next_state <= S_WAIT_IRQ_ACK2;
			end
			
			S_WAIT_IRQ_ACK2: begin
				if(irq_receive_ack)// Interrupt acknowledge received successfully
					next_state <= S_END_DELAY;
				else
					next_state <= S_WAIT_IRQ_ACK2;
			end		
						
			S_END_DELAY: begin
				if(irq_cnt >= 8)
					next_state <= S_IDLE;
				else
					next_state <= S_END_DELAY;
			end
			
			default:begin
				next_state <= S_IDLE;
			end
		endcase
	end
	
	always@(posedge clk_i)begin
	if(rst_i)
		irq_cnt <= 8'd0;
	else if(curr_state != curr_state_1d)
		irq_cnt <= 8'd0;
	else if(curr_state == S_WAIT_IRQ_ACK1) begin
		if(irq_cnt > 8'd31)
			irq_cnt <= irq_cnt;
		else
			irq_cnt <= irq_cnt +1;
	end else if(curr_state == S_END_DELAY) begin
		if(irq_cnt >= 8'd8)
			irq_cnt <= irq_cnt;
		else
			irq_cnt <= irq_cnt +1;
	end else
		irq_cnt <= 8'd0;
	end
	
	
	always@(posedge clk_i)begin
	if(rst_i)
		irq_a_grant_o <= 1'b0;
	else if(irq_b_grant_o != 1'b0 && irq_c_grant_o != 1'b0)//三通道中断响应互斥
		irq_a_grant_o <= 1'b0;
	else if(curr_state == S_IDLE && irq_a_i)
		irq_a_grant_o <= 1'b1;
	else if(curr_state == S_END_DELAY && irq_cnt >= 8)
		irq_a_grant_o <= 1'b0;
	else
		irq_a_grant_o <= 1'b0;
	end
	
	always@(posedge clk_i)begin
	if(rst_i)
		irq_b_grant_o <= 1'b0;
	else if(irq_a_grant_o != 1'b0 && irq_c_grant_o != 1'b0)//三通道中断响应互斥
		irq_b_grant_o <= 1'b0;
	else if(curr_state == S_IDLE && irq_b_i)
		irq_b_grant_o <= 1'b1;
	else if(curr_state == S_END_DELAY && irq_cnt >= 8)
		irq_b_grant_o <= 1'b0;
	else
		irq_b_grant_o <= 1'b0;
	end
	
	always@(posedge clk_i)begin
	if(rst_i)
		irq_c_grant_o <= 1'b0;
	else if(irq_a_grant_o != 1'b0 && irq_b_grant_o != 1'b0)//三通道中断响应互斥
		irq_c_grant_o <= 1'b0;
	else if(curr_state == S_IDLE && irq_c_i)
		irq_c_grant_o <= 1'b1;
	else if(curr_state == S_END_DELAY && irq_cnt >= 8)
		irq_c_grant_o <= 1'b0;
	else
		irq_c_grant_o <= 1'b0;
	end

	always@(posedge clk_i)begin
	if(rst_i)
		irq_busy_o <= 1'b0;
	else if(curr_state == S_IDLE)
		irq_busy_o <= 1'b0;
	else
		irq_busy_o <= 1'b1;
	end

	
	always@(posedge clk_i)begin
	if(rst_i)
		irq_o <= 1'b0;
	else if(curr_state == S_IDLE && irq_b_i)
		irq_o <= 1'b1;
	else if(curr_state == S_IDLE && irq_a_i)
		irq_o <= 1'b1;
	else if(curr_state == S_IDLE && irq_c_i)
		irq_o <= 1'b1;
	else if(curr_state == S_WAIT_IRQ_ACK1)
		irq_o <= 1'b1;
	else
		irq_o <= 1'b0;
	end
	
	always@(posedge clk_i)begin
	if(rst_i) 
		irq_reg1_o <= 32'd0;
	else if(curr_state == S_IDLE && irq_b_i)	// Respond to channel B interrupt
		irq_reg1_o <= {ec_id,sc_id,b_bhv_id,b_tx_id};
	else if(curr_state == S_IDLE && irq_a_i)
		irq_reg1_o <= {ec_id,sc_id,a_bhv_id,a_tx_id};
	else if(curr_state == S_IDLE && irq_c_i)
		irq_reg1_o <= {ec_id,sc_id,c_bhv_id,c_tx_id};
	else 
		irq_reg1_o <= irq_reg1_o;
	end
	
	always@(posedge clk_i)begin
	if(rst_i) 
		irq_reg2_o <= 32'd0;
	else if(curr_state == S_IDLE && irq_b_i)	// Respond to channel B interrupt
		irq_reg2_o <= {24'd0,b_alm_num};
	else if(curr_state == S_IDLE && irq_a_i)
		irq_reg2_o <= {24'd0,a_alm_num};
	else if(curr_state == S_IDLE && irq_c_i)
		irq_reg2_o <= {24'd0,c_alm_num};
	else 
		irq_reg2_o <= irq_reg2_o;
	end
	
	
endmodule