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


module status_beh_safety_door#(
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
	,input 		[19:0]			b_tx_ot         
	,input 		[31:0]			b_tx_result_rpt 
	,input						b_tx_result_vld
	,output	reg	 				ec_chb_st   
	,output	reg [7:0]			b_tx_id     
	,output	reg [7:0]			b_alm_num   
	
	
	,input 						i_open_req_key    
	,input 						i_close_confirm_key
	//,input 						i_door_monitor  
	,input 						i_lock_monitor       
	//,output	reg					o_key_light
	,output	reg					o_lock_open
	
	,output	reg	[31:0]			state_monitor_o
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
	
	reg		ec_chb_st_r;
	reg		ec_chb_st_negedge;
	
	reg		ri_open_req_key;
	reg		open_req_key_posedge;
	reg		open_req_key_negedge;
	reg		ri_close_confirm_key;
	reg		close_confirm_key_posedge;
	reg		close_confirm_key_negedge;
	
	reg		[31:0]	delay_cnt;
	
	
	//State machine state
	localparam  S_IDLE          = 8'd0; 
    localparam  S_BHA_PRE_DET	= 8'd1; 
	localparam	S_READY_10		= 8'd2;	
    localparam  S_READY_10_ACK  = 8'd3; 
    localparam  S_EXE_20     	= 8'd4; 
	localparam	S_EXE			= 8'd5;	
    localparam  S_EXE_20_ACK	= 8'd6;	
    localparam  S_BHA_POST_DET  = 8'd7; 
    localparam  S_SUCC_30       = 8'd8; 
    localparam  S_SUCC_30_ACK	= 8'd9; 
	localparam 	S_ALERT_40		= 8'd10;
	localparam 	S_ALERT_40_ACK	= 8'd11;
	localparam 	S_ACT_END_1		= 8'd12;
	localparam 	S_ACT_END_2		= 8'd13;
	
    localparam  IRQ_OK          = 8'h51;	//ps ack:OK
    localparam  IRQ_NO_OK       = 8'h52;	//ps ack:NO OK
	
	//state monitor
	reg [7:0]	curr_state_m1;
	reg [7:0]	curr_state_m2;
	reg [7:0]	curr_state_m3;
	
    always @(posedge clk_i) 
	begin
        if (rst_i)begin
			curr_state_m1 <= 8'b0;
			curr_state_m2 <= 8'b0;
			curr_state_m3 <= 8'b0;
			state_monitor_o <= 32'b0;
			end
        else if (curr_state != curr_state_m1) begin
            curr_state_m1 <= curr_state;
            curr_state_m2 <= curr_state_m1;
            curr_state_m3 <= curr_state_m2;
			state_monitor_o <= {curr_state_m3,curr_state_m2,curr_state_m1, curr_state};
		end
    end
	
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
	reg		b_bhv_id_vld;
	
	always @(posedge clk_i) begin
		if(rst_i || !b_en)begin
			b_bhv_id <= 8'd0;
			//b_bhv_id_vld <= 1'b0;
		end else if(curr_state == S_ACT_END_1)begin
			b_bhv_id <= 8'd0;
			//b_bhv_id_vld <= 1'b0;
		end else if(open_req_key_posedge)begin	//open door press
			b_bhv_id <= 8'd100;
			//b_bhv_id_vld <= 1'b1;
		end else if(close_confirm_key_posedge)begin	//close door press
			b_bhv_id <= 8'd101;
			//b_bhv_id_vld <= 1'b1;
		end else begin
			b_bhv_id <= b_bhv_id;
			//b_bhv_id_vld <= 1'b0;
		end
	end
	
	reg match_10;
	//reg match_20;
	reg match_30;
	reg match_40;
	
	always @(posedge clk_i) begin
    if(rst_i) begin
        match_10 <= 1'b0;
		//match_20 <= 1'b0;
		match_30 <= 1'b0;
		match_40 <= 1'b0;
    end else if(curr_state == S_READY_10_ACK)
        match_10 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd10 && ack_beh_id == b_bhv_id);
		//match_20 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd20 && ack_beh_id == a_bhv_id_r);
	else if(curr_state == S_SUCC_30_ACK)
		match_30 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd30 && ack_beh_id == b_bhv_id);
	else if(curr_state == S_ALERT_40_ACK)
		match_40 <= (ack_tx_id == 8'd40 && ack_beh_id == b_bhv_id);
	else begin
		match_10 <= 1'b0;
		//match_20 <= 1'b0;
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
                if (b_en && b_bhv_id_vld)	//pre state allow
                    next_state = S_BHA_PRE_DET;
                else
                    next_state = S_IDLE;
            end
			
			S_BHA_PRE_DET: begin	//curr_state = 1
				if(pre_sta_allow[b_bhv_id - 100]) begin
					next_state = S_READY_10;
				end else if(timout) begin
					next_state = S_ALERT_40;			
				end else begin
					next_state = S_BHA_PRE_DET;
				end
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
			
			S_EXE:begin
				next_state = S_BHA_POST_DET;
			end
			
			S_BHA_POST_DET: begin	//curr_state = 6
				if(post_sta_allow[b_bhv_id - 100]) begin
					next_state = S_SUCC_30;
				end else if(timout) begin
					next_state = S_ALERT_40;			
				end else begin
					next_state = S_BHA_POST_DET;
				end
            end
			
			S_SUCC_30: begin	//Send Interrupt 30
				next_state = S_SUCC_30_ACK;
            end
			
			S_SUCC_30_ACK:begin
				if(match_30)    //30 response success
                    next_state = S_ACT_END_1;
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
                    next_state = S_ACT_END_1;
                else
                    next_state = S_ALERT_40_ACK;
			end
			
			S_ACT_END_1:begin
				next_state = S_ACT_END_2;
			end
			
			S_ACT_END_2:begin
				next_state = S_IDLE;
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
        //else if(curr_state == S_EXE_20)
        //    b_tx_id <= 8'd20;
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
			//else if(curr_state == S_EXE_20)
			//	irq_o <= 1'b1;
			else if(curr_state == S_SUCC_30)
				irq_o <= 1'b1;
			else if(curr_state == S_ALERT_40)
				irq_o <= 1'b1;
			else
				irq_o <= irq_o;
		end
	

	always@(posedge clk_i)begin
        if(rst_i || !b_en)
            b_alm_num <= 8'd0;
        else if(curr_state == S_BHA_PRE_DET && timout)						
            b_alm_num <= 8'd100;    
        else if(curr_state == S_READY_10_ACK && ack_tx_result == IRQ_NO_OK)	
            b_alm_num <= ack_ps_alart_num;    
        else if(curr_state == S_READY_10_ACK && timout)						
            b_alm_num <= 8'd101;    
		else if(curr_state == S_BHA_POST_DET && timout)						
			b_alm_num <= 8'd102;
		else if(curr_state == S_SUCC_30_ACK && ack_tx_result == IRQ_NO_OK)	
			b_alm_num <= ack_ps_alart_num;
		else if(curr_state == S_SUCC_30_ACK && timout)						
            b_alm_num <= 8'd103;
		else if(curr_state == S_ACT_END_1)
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
        else if(timout_cnt > b_tx_ot)
            timout_cnt <= 20'd0;
        else if(i_time_1s_vld)
            timout_cnt <= timout_cnt+1;
    end

    always@(posedge clk_i)begin
        if(rst_i)
            timout <= 1'b0;
        else if(timout_cnt > b_tx_ot)
            timout <= 1'b1;
        else
            timout <= 1'b0;
    end
	
	
	//===============================================================================================================
	//------------------------------------------------ user logic start ---------------------------------------------
	//===============================================================================================================

	reg	[19:0]	cnt;
	reg	[7:0]	sta;
	
	always@(posedge clk_i)
	begin
		if(rst_i)begin
			cnt <= 0;
			sta <= 0;
			b_bhv_id_vld <= 0;
		end else
			case(sta)
				0:begin
					b_bhv_id_vld <= 0;
					if(open_req_key_posedge || close_confirm_key_posedge)
						sta <= 1;
					else
						sta <= 0;
				end
				1:begin
					b_bhv_id_vld <= 0;
					if(open_req_key_negedge || close_confirm_key_negedge)begin
						sta <= 0;
						cnt <= 0;
					end else if(cnt >= 999)begin
						sta <= 2;
						cnt <= 0;
					end else if(i_time_1ms_vld)begin
						sta <= sta;
						cnt <= cnt+1;
					end else begin
						sta <= sta;
						cnt <= cnt;
					end
				end
				2:begin
					b_bhv_id_vld <= 1;
					sta <= 3;
				end
				3:begin
					b_bhv_id_vld <= 0;
					sta <= 0;
				end
				default:begin
					cnt 			<= cnt 		;
				    sta 			<= sta 		;
				    b_bhv_id_vld 	<= b_bhv_id_vld;
				end
			endcase
	end

	always@(posedge clk_i)
	begin
		if(rst_i)
			ri_open_req_key <= 0;
		else
			ri_open_req_key <= i_open_req_key;
	end
	
	always@(posedge clk_i)
	begin
		if(rst_i)begin
			open_req_key_posedge <= 0;
			open_req_key_negedge <= 0;
		end else if({ri_open_req_key,i_open_req_key} == 2'b01)begin
			open_req_key_posedge <= 1;
			open_req_key_negedge <= 0;
		end else if({ri_open_req_key,i_open_req_key} == 2'b10)begin
			open_req_key_posedge <= 0;
			open_req_key_negedge <= 1;
		end else begin
			open_req_key_posedge <= 0;
			open_req_key_negedge <= 0;
		end
	end
	
	always@(posedge clk_i)
	begin
		if(rst_i)
			ri_close_confirm_key <= 0;
		else
			ri_close_confirm_key <= i_close_confirm_key;
	end
	
	always@(posedge clk_i)
	begin
		if(rst_i)begin
			close_confirm_key_posedge <= 0;
			close_confirm_key_negedge <= 0;
		end else if({ri_close_confirm_key,i_close_confirm_key} == 2'b01)begin
			close_confirm_key_posedge <= 1;
			close_confirm_key_negedge <= 0;
		end else if({ri_close_confirm_key,i_close_confirm_key} == 2'b10)begin
			close_confirm_key_posedge <= 0;
			close_confirm_key_negedge <= 1;
		end else begin
			close_confirm_key_posedge <= 0;
			close_confirm_key_negedge <= 0;
		end
	end
	
	always @(posedge clk_i) begin
		if (rst_i) 
			o_lock_open <= 1'b0;
		else if(curr_state == S_EXE)
			case(b_bhv_id)
				8'd100: o_lock_open <= 1'b1;
				8'd101: o_lock_open <= 1'b0;
				default: o_lock_open <= o_lock_open;
			endcase
		else
			o_lock_open <= o_lock_open;
	end

	//===============================================================================================================
	//------------------------------------------------ user logic end ---------------------------------------------
	//===============================================================================================================
	
endmodule
