`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: cgliu
// 
// Create Date: 2026/06/29 22:38:10
// Design Name: 
// Module Name: tim_beh
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

module tim_beh_pulmotor_handwheel(
    input                  		clk_i                
	,input                  	rst_i              	
	,input                  	i_time_1ms_vld   	
	,input                  	i_time_1s_vld    	
	
	,output	reg	[19:0]			task_time_cnt	

	,input						pre_sta_allow		
	,input						post_sta_allow	

	,input						c_en				
	,output reg [7:0]			c_bhv_id   
	,input 		[31:0]			c_tx_ot          	
	,input 		[31:0]			c_tx_result_rpt  	
	,input						c_tx_result_vld
	,output		 [3:0]			ec_chc_st	
	,output reg [7:0]			c_tx_id         	
	,output reg [7:0]			c_alm_num
	
	,input 		[19:0]			c_gap_crl

	,output reg              	irq_o 					
	,input                   	irq_ack_i
   );
	
	reg	[7:0]	curr_state		;
	reg	[7:0]	curr_state_1d	;
	reg	[7:0]	next_state		;
	
	reg			timout			;
	reg	[31:0]	timout_cnt		;	
	
	reg [7:0]		ack_beh_id;
	reg [7:0]		ack_tx_id;
	reg [7:0]		ack_tx_result;
	reg	[7:0]		ack_ps_alart_num;
	
	localparam  S_IDLE          = 8'd0; 
    localparam  S_BHA_PRE_DET	= 8'd1; 
	localparam	S_READY_10		= 8'd2;
    localparam  S_READY_10_ACK  = 8'd3; 
    localparam  S_EXE_20     	= 8'd4; 
    localparam  S_EXE_20_ACK	= 8'd5; 
    localparam  S_BHA_POST_DET  = 8'd6; 
    localparam  S_SUCC_30       = 8'd7; 
    localparam  S_SUCC_30_ACK	= 8'd8; 
	localparam 	S_ALERT_40		= 8'd9;
	localparam 	S_ALERT_40_ACK	= 8'd10;
	localparam	S_EXE			= 8'd11;

    localparam  IRQ_OK          = 8'h51;
    localparam  IRQ_NO_OK       = 8'h52;
	
	
	always@(posedge clk_i)begin
	if(rst_i)begin
		ack_beh_id 	 	<=	8'd0;
		ack_tx_id	 	<=	8'd0;
		ack_tx_result	<=	8'd0;
		ack_ps_alart_num<=	8'd0;
	end else if(c_tx_result_vld)begin
		ack_beh_id 		<= 	c_tx_result_rpt[31:24];
		ack_tx_id		<= 	c_tx_result_rpt[23:16];
		ack_tx_result	<= 	c_tx_result_rpt[15:8];
		ack_ps_alart_num<=	c_tx_result_rpt[7:0];
	end else begin
		ack_beh_id 		<= 	ack_beh_id 	  ;
		ack_tx_id		<= 	ack_tx_id	  ;
		ack_tx_result	<= 	ack_tx_result  ;
		ack_ps_alart_num<=	ack_ps_alart_num;
		end
	end
	
	always@(posedge clk_i)begin
	if(rst_i)
		curr_state_1d <= 8'd0;
	else
		curr_state_1d <= curr_state;
	end
	
	//Current behavior number
	always @(posedge clk_i) begin
		if(rst_i)
			c_bhv_id <= 8'd1;
		else
			c_bhv_id <= c_bhv_id;
	end	
	
	reg match_10;
	reg match_20;
	reg match_30;
	reg match_40;
	
	always @(posedge clk_i) begin
    if(rst_i) begin
        match_10 <= 1'b0;
		match_20 <= 1'b0;
		match_30 <= 1'b0;
		match_40 <= 1'b0;
    end else begin
        match_10 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd10 && ack_beh_id == c_bhv_id);
		match_20 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd20 && ack_beh_id == c_bhv_id);
		match_30 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd30 && ack_beh_id == c_bhv_id);
		match_40 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd40 && ack_beh_id == c_bhv_id);
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
                if (c_en || c_gap_crl != 20'd0)	
                    next_state = S_BHA_PRE_DET;
                else
                    next_state = S_IDLE;
            end
			
			S_BHA_PRE_DET: begin
				if(c_bhv_id == 8'd1 && pre_sta_allow)  
					next_state = S_READY_10;	
                else if(timout)
                    next_state = S_ALERT_40;	//Timeout in pre - sufficient condition judgment
                else
                    next_state = S_BHA_PRE_DET;
            end
			
			S_READY_10: begin        //Send 10 interrupt
				next_state = S_READY_10_ACK;
            end
			
			S_READY_10_ACK: begin
				if(match_10)  //Transaction 10 Acknowledged OK
                    next_state = S_EXE_20;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_READY_10_ACK;
			end
			
			S_EXE_20: begin	//Send 20 interrupt
				next_state = S_EXE_20_ACK;
            end
			
			S_EXE_20_ACK: begin
				if(match_20) 	//Transaction 20 Acknowledged OK
                    next_state = S_EXE;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_EXE_20_ACK;
			end
			
			S_EXE:begin
				if(task_time_cnt >= c_gap_crl - 1)
					next_state = S_BHA_POST_DET;
				else
					next_state = S_EXE;
			end
			
			S_BHA_POST_DET: begin
				if(post_sta_allow && c_bhv_id == 8'd1)    //Behavior 1 + Post - sufficient condition satisfied
                    next_state = S_SUCC_30;
                else if(timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_BHA_POST_DET;
            end
			
			S_SUCC_30: begin	//Send Interrupt 30
				next_state = S_SUCC_30_ACK;
            end
			
			S_SUCC_30_ACK:begin
				if(match_30)    //30 response success
                    next_state = S_IDLE;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_SUCC_30_ACK;
			end
			
			S_ALERT_40: begin	//Send Interrupt 40
				next_state = S_ALERT_40_ACK;
            end
			
			S_ALERT_40_ACK:begin
				if(match_40 || timout) //40 response
                    next_state = S_IDLE;
                else
                    next_state = S_ALERT_40_ACK;
			end

            default: begin
                next_state = S_IDLE;
            end

        endcase
    end
			

	//Channel C busy signal
	assign ec_chc_st = (curr_state != S_IDLE)?1'b1:1'b0;
	
	
	 //Channel A transaction ID: 10 20 30 40
    always@(posedge clk_i)begin
        if(rst_i)
            c_tx_id <= 8'd0;
		else if(!c_en)
            c_tx_id <= 8'd0;
        else if(curr_state == S_READY_10)
            c_tx_id <= 8'd10;
        else if(curr_state == S_EXE_20)
            c_tx_id <= 8'd20;
        else if(curr_state == S_SUCC_30)
            c_tx_id <= 8'd30;
        else if(curr_state == S_ALERT_40)
            c_tx_id <= 8'd40;
        else
            c_tx_id <= c_tx_id;
    end
	
	always@(posedge clk_i)begin
        if(rst_i)
            irq_o <= 1'b0;
		else if(!c_en)
            irq_o <= 1'b0;
		else if(irq_ack_i)    //The interrupt arbiter receives the interrupt.
            irq_o <= 1'b0;
        else if(curr_state == S_READY_10)
            irq_o <= 1'b1;
		else if(curr_state == S_EXE_20)
			irq_o <= 1'b1;
		else if(curr_state == S_SUCC_30)
			irq_o <= 1'b1;
		else if(curr_state == S_ALERT_40)
			irq_o <= 1'b1;
        else
            irq_o <= irq_o;
    end
	
	always@(posedge clk_i)begin
        if(rst_i)
            c_alm_num <= 8'd0;
		else if(!c_en)
            c_alm_num <= 8'd0;
        else if(curr_state == S_BHA_PRE_DET && timout)						//The pre - full inspection is not met.
            c_alm_num <= 8'd1;    
        else if(curr_state == S_READY_10_ACK && ack_tx_result == IRQ_NO_OK)	//Transaction 10 ps response error
            c_alm_num <= ack_ps_alart_num;    
        else if(curr_state == S_READY_10_ACK && timout)						//For Transaction 10, waiting for the ps response timed out.
            c_alm_num <= 8'd2;    
		else if(curr_state == S_EXE_20_ACK && ack_tx_result == IRQ_NO_OK)	//Transaction 20 has a ps response error.
            c_alm_num <= ack_ps_alart_num;    
        else if(curr_state == S_EXE_20_ACK && timout)						//For Transaction 20, waiting for the ps response timed out.
            c_alm_num <= 8'd3;    
		else if(curr_state_1d == S_EXE && curr_state == S_ALERT_40 && c_bhv_id == 8'd1)//The execution of Behavior 1 failed.
			c_alm_num <= 8'd4; 
		else if(curr_state_1d == S_EXE && curr_state == S_ALERT_40 && c_bhv_id == 8'd2)//The execution of Behavior 2 failed.
			c_alm_num <= 8'd5;
		else if(curr_state == S_SUCC_30_ACK && ack_tx_result == IRQ_NO_OK)	//Transaction 30 has a ps response error.
			c_alm_num <= ack_ps_alart_num;
		else if(curr_state == S_SUCC_30_ACK && timout)						//For Transaction 30, waiting for the ps response timed out.
            c_alm_num <= 8'd6;
        else
            c_alm_num <= c_alm_num;
    end
	
	//Timeout count
    always@(posedge clk_i)begin
        if(rst_i)
			timout_cnt <= 20'd0;
		else if(!c_en)
            timout_cnt <= 20'd0;
		else if(curr_state != curr_state_1d)
			timout_cnt <= 20'd0;
        else if(timout_cnt >= c_tx_ot-1)
            timout_cnt <= 20'd0;
        else if(i_time_1s_vld)
            timout_cnt <= timout_cnt+1;
    end

    always@(posedge clk_i)begin
        if(rst_i)
            timout <= 1'b0;
        else if(timout_cnt >= c_tx_ot-1)
            timout <= 1'b1;
        else
            timout <= 1'b0;
    end
   
	//================================================================================================//
	//----------------------------------------- 定时计数器 ------------------------------------------//
	//================================================================================================//
   
localparam TASK_IDLE     = 3'd0;
localparam TASK_COUNT    = 3'd1;
localparam TASK_IRQ_WAIT = 3'd2;
localparam TASK_BACK     = 3'd3;

reg [2:0] curr_state1;
reg [2:0] next_state1;

always @(posedge clk_i) begin
    if (rst_i)
        curr_state1 <= TASK_IDLE;
    else
        curr_state1 <= next_state1;
end

always @(*) begin
    next_state1 = TASK_IDLE;
    case (curr_state1)
	
        TASK_IDLE: begin
            if (!c_en || c_gap_crl == 20'd0)
                next_state1 = TASK_IDLE;
            else
                next_state1 = TASK_COUNT;
        end
		
        TASK_COUNT: begin
            if (task_time_cnt >= c_gap_crl - 1)
                next_state1 = TASK_IRQ_WAIT;
            else
                next_state1 = TASK_COUNT;
        end
		
        TASK_IRQ_WAIT: begin
            if (irq_ack_i)		//After the interrupt is responded to, start counting again.
                next_state1 = TASK_BACK;
            else
                next_state1 = TASK_IRQ_WAIT;
        end
		
        TASK_BACK: begin
            next_state1 = TASK_IDLE;
        end
		
        default: next_state1 = TASK_IDLE;
		
    endcase
end

always @(posedge clk_i) begin
    if (rst_i) begin
        task_time_cnt <= 'd0;
    end else begin
        case (curr_state1)
            TASK_IDLE:
                task_time_cnt <= 'd0;
				
            TASK_COUNT: begin
                if (task_time_cnt >= c_gap_crl - 1)
                    task_time_cnt <= 'd0;
                else
                    task_time_cnt <= task_time_cnt + i_time_1s_vld;
            end
			
            TASK_IRQ_WAIT:
                task_time_cnt <= 'd0;
				
            TASK_BACK:
                task_time_cnt <= 'd0;
				
            default:
                task_time_cnt <= 'd0;
        endcase
    end
end


endmodule
