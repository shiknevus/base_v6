`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: cgliu
// 
// Create Date: 2026/06/29 22:38:46
// Design Name: 
// Module Name: status_beh
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


module status_beh_pulmotor_handwheel#(
	parameter	BHA_NUM	=	1
)(
	input						clk_i			
	,input						rst_i			
	,input						i_time_1ms_vld		
	,input						i_time_1s_vld 		
	
	,input		[BHA_NUM-1:0]	pre_sta_allow	
	,input		[BHA_NUM-1:0]	post_sta_allow	

	,input						b_en	
	,output	reg [7:0]			b_bhv_id    
	,input 		[31:0]			b_tx_ot         
	,input 		[31:0]			b_tx_result_rpt 
	,input						b_tx_result_vld
	,output		 				ec_chb_st   
	,output	reg [7:0]			b_tx_id     
	,output	reg [7:0]			b_alm_num   
	
	,input						di				
	
	//,output	reg	[31:0]			state_monitor_o
	,output	reg					irq_o			
	,input						irq_ack_i	
    );
	
	reg			[7:0]			curr_state		;
	reg			[7:0]			curr_state_1d	;
	reg			[7:0]			next_state		;
	
	reg							timout			;
	reg			[31:0]			timout_cnt		;	
	
	reg [7:0]		ack_beh_id;
	reg [7:0]		ack_tx_id;
	reg [7:0]		ack_tx_result;
	reg	[7:0]		ack_ps_alart_num;

	
	//State machine state
	localparam  S_IDLE          = 8'd0; 	//idle
    localparam  S_BHA_PRE_DET	= 8'd1; 	//Pre-condition check
	localparam	S_READY_10		= 8'd2;		//ready
    localparam  S_READY_10_ACK  = 8'd3; 	//ready ok/no ok
    localparam  S_EXE_20     	= 8'd4; 	//Action begin
	localparam	S_EXE			= 8'd5;		//Action execute
    localparam  S_EXE_20_ACK	= 8'd6;		//Action end
    localparam  S_BHA_POST_DET  = 8'd7; 	//Post-condition check
    localparam  S_SUCC_30       = 8'd8; 	//success
    localparam  S_SUCC_30_ACK	= 8'd9; 	//success ack
	localparam 	S_ALERT_40		= 8'd10;	//Alert
	localparam 	S_ALERT_40_ACK	= 8'd11;	//Alert ack
	
    localparam  IRQ_OK          = 8'h51;	//ps ack:OK
    localparam  IRQ_NO_OK       = 8'h52;	//ps ack:NO OK
	
	//state monitor
	//	reg [7:0]	curr_state_m1;
	//	reg [7:0]	curr_state_m2;
	//	reg [7:0]	curr_state_m3;
	//	
    //	always @(posedge clk_i) 
	//	begin
    //	    if (rst_i)begin
	//			curr_state_m1 <= 8'b0;
	//			curr_state_m2 <= 8'b0;
	//			curr_state_m3 <= 8'b0;
	//			state_monitor_o <= 32'b0;
	//			end
    //	    else if (curr_state != curr_state_m1) begin
    //	        curr_state_m1 <= curr_state;
    //	        curr_state_m2 <= curr_state_m1;
    //	        curr_state_m3 <= curr_state_m2;
	//			state_monitor_o <= {curr_state_m3,curr_state_m2,curr_state_m1, curr_state};
	//		end
    //	end
	
	always@(posedge clk_i)begin
	if(rst_i)begin
		ack_beh_id 	 	<=	8'd0;
		ack_tx_id	 	<=	8'd0;
		ack_tx_result	<=	8'd0;
		ack_ps_alart_num<=	8'd0;
	end else if(b_tx_result_vld)begin
		ack_beh_id 		<= 	b_tx_result_rpt[31:24];
		ack_tx_id		<= 	b_tx_result_rpt[23:16];
		ack_tx_result	<= 	b_tx_result_rpt[15:8];
		ack_ps_alart_num<=	b_tx_result_rpt[7:0];
	end else if(curr_state == S_IDLE)begin
		ack_beh_id 		<= 	8'd0;
		ack_tx_id		<= 	8'd0;
		ack_tx_result	<= 	8'd0;
		ack_ps_alart_num<=	8'd0;
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
			b_bhv_id <= 8'd0;
		else
			b_bhv_id <= 8'd1;
	end
	
	reg match_10;
	reg match_30;
	reg match_40;
	
	always @(posedge clk_i) begin
    if(rst_i) begin
        match_10 <= 1'b0;
		match_30 <= 1'b0;
		match_40 <= 1'b0;
    end else if(curr_state == S_READY_10_ACK)
        match_10 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd10 && ack_beh_id == b_bhv_id);
	else if(curr_state == S_SUCC_30_ACK)
		match_30 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd30 && ack_beh_id == b_bhv_id);
	else if(curr_state == S_ALERT_40_ACK)
		match_40 <= (ack_tx_id == 8'd40 && ack_beh_id == b_bhv_id);
	else begin
		match_10 <= 1'b0;
		match_30 <= 1'b0;
		match_40 <= 1'b0;
	end
	end

	always @(posedge clk_i) begin
        if (rst_i)
            curr_state <= S_IDLE;
        else
            curr_state <= next_state;
    end
	
	always @(*) begin
        next_state = curr_state;
        case (curr_state)
            S_IDLE: begin
                if (b_en && pre_sta_allow != 0)
                    next_state = S_READY_10;
                else
                    next_state = S_IDLE;
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
				next_state = S_EXE;
            end
			
			//S_EXE_20_ACK: begin
			//	if(match_20) 	//Transaction 20 Acknowledged OK
            //        next_state = S_EXE;
            //    else if(ack_tx_result == IRQ_NO_OK || timout)
            //        next_state = S_ALERT_40;
            //    else
            //        next_state = S_EXE_20_ACK;
			//end
			
			S_EXE:begin
				next_state = S_BHA_POST_DET;	//Behavior 1/Behavior 2 failed
			end
			
			S_BHA_POST_DET: begin
				if(post_sta_allow[0] && b_bhv_id == 8'd101)    //Behavior 1 + Post - sufficient condition satisfied
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
	
	//Channel B busy signal
	assign ec_chb_st = (curr_state != S_IDLE)?1'b1:1'b0;
	
	//Channel B transaction ID: 10 20 30 40
    always@(posedge clk_i)begin
        if(rst_i)
            b_tx_id <= 8'd0;
		else if(!b_en)
			b_tx_id <= 8'd0;
        else if(curr_state == S_READY_10)
            b_tx_id <= 8'd10;
        // else if(curr_state == S_EXE_20)
            //     b_tx_id <= 8'd20;
        else if(curr_state == S_SUCC_30)
            b_tx_id <= 8'd30;
        else if(curr_state == S_ALERT_40)
            b_tx_id <= 8'd40;
		else if(match_40)
			b_tx_id <= 8'd0;
        else
               b_tx_id <= b_tx_id;
    end

	always@(posedge clk_i)begin
        if(rst_i)
            irq_o <= 1'b0;
		else if(!b_en)
			irq_o <= 1'b0;
		else if(irq_ack_i)    //The interrupt arbiter receives the interrupt.
            irq_o <= 1'b0;
        else if(curr_state == S_READY_10)
            irq_o <= 1'b1;
		// else if(curr_state == S_EXE_20)
			// 	irq_o <= 1'b1;
		else if(curr_state == S_SUCC_30)
			irq_o <= 1'b1;
		else if(curr_state == S_ALERT_40)
			irq_o <= 1'b1;
        else
            irq_o <= irq_o;
    end
	

	always@(posedge clk_i)begin
        if(rst_i)
            b_alm_num <= 8'd0;
		else if(!b_en)
			b_alm_num <= 8'd0;
        else if(curr_state == S_BHA_PRE_DET && timout)						//The pre - full inspection is not met.
            b_alm_num <= 8'd1;    
        else if(curr_state == S_READY_10_ACK && ack_tx_result == IRQ_NO_OK)	//Transaction 10 ps response error
            b_alm_num <= ack_ps_alart_num;    
        else if(curr_state == S_READY_10_ACK && timout)						//For Transaction 10, waiting for the ps response timed out.
            b_alm_num <= 8'd2;    
		// else if(curr_state == S_EXE_20_ACK && ack_tx_result == IRQ_NO_OK)	//Transaction 20 has a ps response error.
            //     b_alm_num <= ack_ps_alart_num;
        else if(curr_state == S_EXE_20_ACK && timout)						//For Transaction 20, waiting for the ps response timed out.
            b_alm_num <= 8'd3;    
		else if(curr_state_1d == S_EXE && curr_state == S_ALERT_40 && b_bhv_id == 8'd1)//The execution of Behavior 1 failed.
			b_alm_num <= 8'd4; 
		else if(curr_state_1d == S_EXE && curr_state == S_ALERT_40 && b_bhv_id == 8'd2)//The execution of Behavior 2 failed.
			b_alm_num <= 8'd5;
		else if(curr_state == S_SUCC_30_ACK && ack_tx_result == IRQ_NO_OK)	//Transaction 30 has a ps response error.
			b_alm_num <= ack_ps_alart_num;
		else if(curr_state == S_SUCC_30_ACK && timout)						//For Transaction 30, waiting for the ps response timed out.
            b_alm_num <= 8'd6;
		else if(curr_state == S_IDLE)
			b_alm_num <= 8'd0;
        else
               b_alm_num <= b_alm_num;
    end
	

	//Timeout count
    always@(posedge clk_i)begin
        if(rst_i)
            timout_cnt <= 20'd0;
		else if(!b_en)
			timout_cnt <= 20'd0;
		else if(curr_state != curr_state_1d)
			timout_cnt <= 20'd0;
        else if(timout_cnt >= b_tx_ot-1)
            timout_cnt <= 20'd0;
        else if(i_time_1s_vld)
            timout_cnt <= timout_cnt+1;
    end


    always@(posedge clk_i)begin
        if(rst_i)
            timout <= 1'b0;
        else if(timout_cnt >= b_tx_ot-1)
            timout <= 1'b1;
        else
            timout <= 1'b0;
    end
	
	
	//===============================================================================================================
	//------------------------------------------------ user logic start ---------------------------------------------
	//===============================================================================================================

	
	
	
	
	//===============================================================================================================
	//------------------------------------------------ user logic start ---------------------------------------------
	//===============================================================================================================

	
	
endmodule
