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
	,input		[7:0]		sc_id              
	,input		[7:0]		ec_id   
		
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
	
	reg	[7:0]	curr_state		;
	reg	[7:0]	curr_state_1d	;
	reg	[7:0]	next_state		;
	
	reg [7:0] 	irq_cnt;
	
	reg			irq_receive_ack	;
	reg	[1:0]	irq_receive_ack_i_r;

reg sel_irq_a;
reg sel_irq_b;
reg sel_irq_c;

	localparam	S_IDLE			=	8'd0;
	localparam	S_WAIT_IRQ_ACK1	=	8'd1;
	localparam	S_WAIT_IRQ_ACK2	=	8'd2;
	localparam	S_END_DELAY		=	8'd3;

always @(*) begin
    sel_irq_a = 1'b0;
    sel_irq_b = 1'b0;
    sel_irq_c = 1'b0;
    case(chl_priority)
        4'd0: begin // abc
            if(irq_a_i && curr_state == S_IDLE)
                sel_irq_a = 1'b1;
            else if(irq_b_i && curr_state == S_IDLE)
                sel_irq_b = 1'b1;
            else if(irq_c_i && curr_state == S_IDLE)
                sel_irq_c = 1'b1;
        end
        4'd1: begin // acb
            if(irq_a_i && curr_state == S_IDLE)
                sel_irq_a = 1'b1;
            else if(irq_c_i && curr_state == S_IDLE)
                sel_irq_c = 1'b1;
            else if(irq_b_i && curr_state == S_IDLE)
                sel_irq_b = 1'b1;
        end
        4'd2: begin // bac
            if(irq_b_i && curr_state == S_IDLE)
                sel_irq_b = 1'b1;
            else if(irq_a_i && curr_state == S_IDLE)
                sel_irq_a = 1'b1;
            else if(irq_c_i && curr_state == S_IDLE)
                sel_irq_c = 1'b1;
        end
        4'd3: begin // bca
            if(irq_b_i && curr_state == S_IDLE)
                sel_irq_b = 1'b1;
            else if(irq_c_i && curr_state == S_IDLE)
                sel_irq_c = 1'b1;
            else if(irq_a_i && curr_state == S_IDLE)
                sel_irq_a = 1'b1;
        end
        4'd4: begin // cab
            if(irq_c_i && curr_state == S_IDLE)
                sel_irq_c = 1'b1;
            else if(irq_a_i && curr_state == S_IDLE)
                sel_irq_a = 1'b1;
            else if(irq_b_i && curr_state == S_IDLE)
                sel_irq_b = 1'b1;
        end
        4'd5: begin // cba
            if(irq_c_i && curr_state == S_IDLE)
                sel_irq_c = 1'b1;
            else if(irq_b_i && curr_state == S_IDLE)
                sel_irq_b = 1'b1;
            else if(irq_a_i && curr_state == S_IDLE)
                sel_irq_a = 1'b1;
        end
        default: begin // default bac
            if(irq_b_i && curr_state == S_IDLE)
                sel_irq_b = 1'b1;
            else if(irq_a_i && curr_state == S_IDLE)
                sel_irq_a = 1'b1;
            else if(irq_c_i && curr_state == S_IDLE)
                sel_irq_c = 1'b1;
        end
    endcase
end

reg sel_irq_a_d;
reg sel_irq_b_d;
reg sel_irq_c_d;

always @(posedge clk_i) begin
    if(rst_i) begin
        sel_irq_a_d <= 1'b0;
        sel_irq_b_d <= 1'b0;
        sel_irq_c_d <= 1'b0;
    end else begin
        sel_irq_a_d <= sel_irq_a;
        sel_irq_b_d <= sel_irq_b;
        sel_irq_c_d <= sel_irq_c;
    end
end

always @(posedge clk_i) begin
    if(rst_i) begin
        irq_a_grant_o <= 1'b0;
        irq_b_grant_o <= 1'b0;
        irq_c_grant_o <= 1'b0;
    end else begin
        irq_a_grant_o <= 1'b0;
        irq_b_grant_o <= 1'b0;
        irq_c_grant_o <= 1'b0;
        if(sel_irq_a && !sel_irq_a_d) begin
            irq_a_grant_o <= 1'b1;
        end else if(sel_irq_b && !sel_irq_b_d) begin
            irq_b_grant_o <= 1'b1;
        end else if(sel_irq_c && !sel_irq_c_d) begin
            irq_c_grant_o <= 1'b1;
        end
    end
end
// ======================================================================
	
	always@(posedge clk_i)begin
	if(rst_i)
		curr_state_1d <= 8'd0;
	else
		curr_state_1d <= curr_state;
	end
	
	always@(posedge clk_i)begin
	if(rst_i)begin
		irq_receive_ack_i_r <= 2'b00;
		irq_receive_ack		<= 1'b0;
	end else begin
		irq_receive_ack_i_r <= {irq_receive_ack_i_r[0],irq_receive_ack_i};
		irq_receive_ack 	<= (~irq_receive_ack_i_r[1]) && irq_receive_ack_i_r[0];
	end
	end

	always @(posedge clk_i) begin
        if (rst_i)
            curr_state <= S_IDLE;
        else
            curr_state <= next_state;
    end
	
	always @(*) begin
        case (curr_state)
            S_IDLE: begin
				if(chl_priority == 4'd0)begin
					if(irq_a_i) 
						next_state = S_WAIT_IRQ_ACK1;
					else if(irq_b_i)
						next_state = S_WAIT_IRQ_ACK1;
					else if(irq_c_i)
						next_state = S_WAIT_IRQ_ACK1;
					else
						next_state = S_IDLE;
				end else if(chl_priority == 4'd1)begin
					if(irq_a_i)
						next_state = S_WAIT_IRQ_ACK1;
					else if(irq_c_i)
						next_state = S_WAIT_IRQ_ACK1;
					else if(irq_b_i)
						next_state = S_WAIT_IRQ_ACK1;
					else begin
						next_state = S_IDLE;
					end
				end else if(chl_priority == 4'd2)begin
					if(irq_b_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else if(irq_a_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else if(irq_c_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else		
						next_state = S_IDLE;		
				end else if(chl_priority == 4'd3)begin
					if(irq_b_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else if(irq_c_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else if(irq_a_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else		
						next_state = S_IDLE;
				end else if(chl_priority == 4'd4)begin
					if(irq_c_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else if(irq_a_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else if(irq_b_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else		
						next_state = S_IDLE;		
				end else if(chl_priority == 4'd5)begin
					if(irq_c_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else if(irq_b_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else if(irq_a_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else		
						next_state = S_IDLE;		
				end else begin
					if(irq_b_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else if(irq_a_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else if(irq_c_i)		
						next_state = S_WAIT_IRQ_ACK1;		
					else		
						next_state = S_IDLE;	
				end
			end

			S_WAIT_IRQ_ACK1: begin
				if(irq_cnt <= 8'd31)begin
					if(irq_receive_ack)// Interrupt acknowledge received successfully
						next_state = S_END_DELAY;
					else
						next_state = S_WAIT_IRQ_ACK1;
				end else begin
						next_state = S_WAIT_IRQ_ACK2;
				end
			end
			
			S_WAIT_IRQ_ACK2: begin	//irq_
				if(irq_receive_ack)// Interrupt acknowledge received successfully
					next_state = S_END_DELAY;
				else
					next_state = S_WAIT_IRQ_ACK2;
			end		
						
			S_END_DELAY: begin
				if(irq_cnt >= 8)
					next_state = S_IDLE; 
				else
					next_state = S_END_DELAY;
			end
			
			default:
				next_state = S_IDLE;
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
		irq_busy_o <= 1'b0;
	else if(curr_state == S_IDLE)
		irq_busy_o <= 1'b0;
	else
		irq_busy_o <= 1'b1;
	end

	
	always@(posedge clk_i)begin
	if(rst_i)
		irq_o <= 1'b0;
	else if(curr_state == S_IDLE && (sel_irq_a || sel_irq_b || sel_irq_c))
		irq_o <= 1'b1;
	else if(curr_state == S_WAIT_IRQ_ACK1)
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
        irq_reg1_o <= {ec_id,sc_id,a_bhv_id,a_tx_id};
        irq_reg2_o <= {a_alm_num,24'd0};
	end else if(irq_b_grant_o)begin
        irq_reg1_o <= {ec_id,sc_id,b_bhv_id,b_tx_id};
        irq_reg2_o <= {b_alm_num,24'd0};
	end else if(irq_c_grant_o)begin
        irq_reg1_o <= {ec_id,sc_id,c_bhv_id,c_tx_id};
        irq_reg2_o <= {c_alm_num,24'd0};
	end else begin
		irq_reg1_o <= irq_reg1_o;
        irq_reg2_o <= irq_reg2_o;
    end
end
	
endmodule

