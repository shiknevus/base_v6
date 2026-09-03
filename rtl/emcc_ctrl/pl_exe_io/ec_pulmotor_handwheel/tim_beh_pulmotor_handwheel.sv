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

module tim_beh_pulmotor_handwheel#(
	parameter					BHA_NUM = 1
)(
    input                  		clk_i                
	,input                  	rst_i              	
	,input                  	i_time_1ms_vld   	
	,input                  	i_time_1s_vld    	
	
	,output	reg	[19:0]			task_time_cnt	

	,input	[BHA_NUM-1:0]		pre_sta_allow		
	,input	[BHA_NUM-1:0]		post_sta_allow	

	,input						c_en				
	,output reg [7:0]			c_bhv_id   
	,input 		[19:0]			c_tx_ot          	
	,input 		[31:0]			c_tx_result_rpt  	
	,input						c_tx_result_vld
	,output		 [3:0]			ec_chc_st	
	,output reg [7:0]			c_tx_id         	
	,output reg [7:0]			c_alm_num
	
	,input 		[19:0]			c_gap_crl
	
	,input						i_estop
	,input 	            		i_pulse_a
	,input 	            		i_pulse_b
	,input 	            		i_stp_x1
	,input 	            		i_stp_x10
	,input 	            		i_stp_x100
	,input 	            		i_axis_x
	,input 	            		i_axis_y
	,input 	            		i_axis_z
	,input 	            		i_axis_4
	,input 	            		i_axis_5
	,input 	            		i_axis_6
	,input 	            		i_axis_7
	,output	[3:0]       		o_axis_number
	,output	[31:0]				o_pulse_cnt
	,output	[7:0]				o_speed_gear
	,output	            		o_wheel_dir
	
	,output	reg	[31:0]			state_monitor_o
	,output reg              	irq_o 					
	,input                   	irq_ack_i
   );
   
	reg	[7:0]	curr_state		;
	reg	[7:0]	curr_state_1d	;
	reg	[7:0]	next_state		;
	
	reg			timout			;
	reg	[19:0]	timout_cnt		;	
	
	reg [7:0]	ack_beh_id;
	reg [7:0]	ack_tx_id;
	reg [7:0]	ack_tx_result;
	reg	[7:0]	ack_ps_alart_num;
	
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
	end else if(c_tx_result_vld)begin
		ack_beh_id 		<= 	c_tx_result_rpt[31:24];
		ack_tx_id		<= 	c_tx_result_rpt[23:16];
		ack_tx_result	<= 	c_tx_result_rpt[15:8];
		ack_ps_alart_num<=	c_tx_result_rpt[7:0];
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
			c_bhv_id <= 8'd1;
		else
			c_bhv_id <= 8'd150;
	end	
	
	reg match_10;
	//reg match_20;
	reg match_30;
	reg match_40;
	
	always @(posedge clk_i) begin
    if(rst_i) 
		begin
        	match_10 <= 1'b0;
			//match_20 <= 1'b0;
			match_30 <= 1'b0;
			match_40 <= 1'b0;
    	end 
	else if(curr_state == S_READY_10_ACK)
        match_10 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd10 && ack_beh_id == c_bhv_id);
		//match_20 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd20 && ack_beh_id == a_bhv_id_r);
	else if(curr_state == S_SUCC_30_ACK)
		match_30 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd30 && ack_beh_id == c_bhv_id);
	else if(curr_state == S_ALERT_40_ACK)
		match_40 <= (ack_tx_id == 8'd40 && ack_beh_id == c_bhv_id);
	else 
		begin
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
	
	reg	[31:0]	loop_time_ms;
	always@(posedge clk_i)
	begin
		if(rst_i)
			loop_time_ms <= 0;
		else
			loop_time_ms <=(c_gap_crl << 9) + (c_gap_crl << 8) + (c_gap_crl << 7) + (c_gap_crl << 6) + (c_gap_crl << 5) + (c_gap_crl << 3);	
	end
	
	
	always @(*) begin
        case (curr_state)
            S_IDLE: begin
                if (c_en && c_gap_crl != 20'd0 && (o_axis_number != 0))	
                    next_state = S_BHA_PRE_DET;
                else
                    next_state = S_IDLE;
            end
			
			S_BHA_PRE_DET: begin	//curr_state = 1
				if(pre_sta_allow[0]) begin	//行为id 150
					next_state = S_READY_10;
				end else if(timout) begin
					next_state = S_ALERT_40;			
				end else begin
					next_state = S_BHA_PRE_DET;
				end
            end
			
			S_READY_10: begin        //2
				next_state = S_READY_10_ACK;
            end
			
			S_READY_10_ACK: begin	//3
				if(match_10)  
                    next_state = S_EXE_20;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_READY_10_ACK;
			end
			
			S_EXE_20: begin	//4
				next_state = S_EXE;
            end
			
			S_EXE:begin	//5
				if(task_time_cnt >= loop_time_ms - 1)		//Timer finished
					next_state = S_BHA_POST_DET;
				else
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

			
			S_BHA_POST_DET: begin	//curr_state = 6
				if(post_sta_allow[0]) begin
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
        //else if(curr_state == S_EXE_20)
        //    c_tx_id <= 8'd20;
        else if(curr_state == S_SUCC_30)
            c_tx_id <= 8'd30;
        else if(curr_state == S_ALERT_40)
            c_tx_id <= 8'd40;
		else if(match_40)
			c_tx_id <= 8'd0;
        else
            c_tx_id <= c_tx_id;
    end
	
	always@(posedge clk_i)begin
        if(rst_i)
            irq_o <= 1'b0;
		else if(!c_en)
			irq_o <= 1'b0;
		else if(irq_ack_i)    		//interrupt arbiter receives the interrupt.
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
        if(rst_i || !c_en)
            c_alm_num <= 8'd0;
        else if(curr_state == S_BHA_PRE_DET && timout)						//The pre - full inspection is not met.
            c_alm_num <= 8'd100;    
        else if(curr_state == S_READY_10_ACK && ack_tx_result == IRQ_NO_OK)	//Transaction 10 ps response error
            c_alm_num <= ack_ps_alart_num;    
        else if(curr_state == S_READY_10_ACK && timout)						//For Transaction 10, waiting for the ps response timed out.
            c_alm_num <= 8'd101;     
		else if(curr_state == S_BHA_POST_DET && timout)//The execution of Behavior 1 failed.
			c_alm_num <= 8'd102; 
		else if(curr_state == S_SUCC_30_ACK && ack_tx_result == IRQ_NO_OK)	//Transaction 30 has a ps response error.
			c_alm_num <= ack_ps_alart_num;
		else if(curr_state == S_SUCC_30_ACK && timout)						//For Transaction 30, waiting for the ps response timed out.
            c_alm_num <= 8'd103;
		else if(curr_state == S_ACT_END_1)
			c_alm_num <= 8'd0;
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
        else if(timout_cnt > c_tx_ot)
            timout_cnt <= 20'd0;
        else if(i_time_1s_vld)
            timout_cnt <= timout_cnt+1;
    end

    always@(posedge clk_i)begin
        if(rst_i)
            timout <= 1'b0;
        else if(timout_cnt > c_tx_ot)
            timout <= 1'b1;
        else
            timout <= 1'b0;
    end
	
	always@(posedge clk_i)
	begin
		if(rst_i)
			task_time_cnt <= 'd0;
		else if(curr_state != S_EXE)
			task_time_cnt <= 'd0;
		else if(i_time_1ms_vld)
			task_time_cnt <= task_time_cnt + 1;
		else
			task_time_cnt <= task_time_cnt;
	end
	
	
	
	//===============================================================================================================
	//------------------------------------------------ user logic start ---------------------------------------------
	//===============================================================================================================

	reg	sample_vld;
	
	always@(posedge clk_i)
	begin
		if(rst_i)
			sample_vld <= 1'b0;
		else if(task_time_cnt >= loop_time_ms-1)
			sample_vld <= 1'b1;
		else
			sample_vld <= 1'b0;
	end

	man_handwheel man_handwheel_u0(
		.clk             (clk_i			)
		,.reset          (rst_i			)
		,.i_pulse_a      (i_pulse_a		)
		,.i_pulse_b      (i_pulse_b		)
		,.i_stp_x1       (i_stp_x1		)
		,.i_stp_x10      (i_stp_x10		)
		,.i_stp_x100     (i_stp_x100	)
		,.i_axis_x       (i_axis_x		)
		,.i_axis_y       (i_axis_y		)
		,.i_axis_z       (i_axis_z		)
		,.i_axis_4       (i_axis_4		)
		,.i_axis_5       (i_axis_5		)
		,.i_axis_6       (i_axis_6		)
		,.i_axis_7       (i_axis_7		)
		,.o_axis_number  (o_axis_number	)
		,.o_speed_gear   (o_speed_gear	)
		,.o_pulse_cnt    (o_pulse_cnt	)
		,.o_wheel_dir    (o_wheel_dir	)
		,.sample_vld     (sample_vld	)
	);
				
	//===============================================================================================================
	//------------------------------------------------ user logic start ---------------------------------------------
	//===============================================================================================================


endmodule
