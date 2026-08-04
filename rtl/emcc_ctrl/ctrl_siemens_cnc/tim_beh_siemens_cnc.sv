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
// Description: 3 periodic timers (behavior 129/130/131), one shared channel C.
//              Timer expires -> irq30 (beh_id = 129+idx); PS ack -> restart.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module tim_beh_siemens_cnc(
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

	,input 		[19:0]			c_gap_crl0		//timer0 period (ms), 0 = disabled
	,input 		[19:0]			c_gap_crl1		//timer1 period (ms), 0 = disabled
	,input 		[19:0]			c_gap_crl2		//timer2 period (ms), 0 = disabled

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
	localparam	S_IRQ			= 8'd1;

	localparam  IRQ_OK          = 8'h51;
	localparam  IRQ_NO_OK       = 8'h52;

	localparam  ALARM_BEHATMOUT = 8'd120;

	//timer counters (1ms tick)
	reg [19:0]	timer_cnt0;
	reg [19:0]	timer_cnt1;
	reg [19:0]	timer_cnt2;

	wire		expire0 = (c_gap_crl0 != 20'd0) && (timer_cnt0 >= c_gap_crl0 - 1'b1);
	wire		expire1 = (c_gap_crl1 != 20'd0) && (timer_cnt1 >= c_gap_crl1 - 1'b1);
	wire		expire2 = (c_gap_crl2 != 20'd0) && (timer_cnt2 >= c_gap_crl2 - 1'b1);

	reg	[1:0]	src;	//expired timer index 0/1/2, valid in S_IRQ

	//ack match: PS reply for the current timer behavior
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

	wire ack_match_any = c_tx_result_vld && (ack_beh_id == c_bhv_id);
	wire ack_match_ok  = ack_match_any && (ack_tx_id == 8'd30) && (ack_tx_result == IRQ_OK);

	always@(posedge clk_i)begin
	if(rst_i)
		curr_state_1d <= 8'd0;
	else
		curr_state_1d <= curr_state;
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
				if (c_en && (expire0 || expire1 || expire2))
					next_state = S_IRQ;
				else
					next_state = S_IDLE;
			end
			S_IRQ: begin
				if(ack_match_any || timout)
					next_state = S_IDLE;
				else
					next_state = S_IRQ;
			end
			default: next_state = S_IDLE;
		endcase
	end

	//expired source latch (priority timer0 > timer1 > timer2)
	always@(posedge clk_i) begin
		if(rst_i || !c_en)
			src <= 2'd0;
		else if(curr_state == S_IDLE) begin
			if(expire0)      src <= 2'd0;
			else if(expire1) src <= 2'd1;
			else if(expire2) src <= 2'd2;
		end
	end

	//current timer behavior number
	always@(posedge clk_i) begin
		if(rst_i || !c_en)
			c_bhv_id <= 8'd0;
		else if(curr_state == S_IRQ)
			c_bhv_id <= 8'd129 + src;
		else
			c_bhv_id <= 8'd0;
	end

	//timer counters: count while enabled, hold when expired, clear on ack
	always@(posedge clk_i) begin
		if(rst_i || !c_en) begin
			timer_cnt0 <= 20'd0;
			timer_cnt1 <= 20'd0;
			timer_cnt2 <= 20'd0;
		end else begin
			//clear the acknowledged source
			if(ack_match_any && src == 2'd0)
				timer_cnt0 <= 20'd0;
			else if(!expire0 && !(curr_state == S_IRQ && src == 2'd0))
				timer_cnt0 <= timer_cnt0 + i_time_1ms_vld;

			if(ack_match_any && src == 2'd1)
				timer_cnt1 <= 20'd0;
			else if(!expire1 && !(curr_state == S_IRQ && src == 2'd1))
				timer_cnt1 <= timer_cnt1 + i_time_1ms_vld;

			if(ack_match_any && src == 2'd2)
				timer_cnt2 <= 20'd0;
			else if(!expire2 && !(curr_state == S_IRQ && src == 2'd2))
				timer_cnt2 <= timer_cnt2 + i_time_1ms_vld;
		end
	end

	assign task_time_cnt = timer_cnt0;

	//Channel C busy signal
	assign ec_chc_st = (curr_state != S_IDLE) ? 4'h1 : 4'h0;

	//Channel C transaction ID
	always@(posedge clk_i)begin
		if(rst_i || !c_en)
			c_tx_id <= 8'd0;
		else if(curr_state == S_IRQ)
			c_tx_id <= 8'd30;
		else
			c_tx_id <= 8'd0;
	end

	always@(posedge clk_i)begin
		if(rst_i || !c_en)
			irq_o <= 1'b0;
		else if(irq_ack_i)    //the interrupt arbiter receives the interrupt.
			irq_o <= 1'b0;
		else if(curr_state == S_IRQ)
			irq_o <= 1'b1;
		else
			irq_o <= irq_o;
	end

	always@(posedge clk_i)begin
		if(rst_i || !c_en)
			c_alm_num <= 8'd0;
		else if(curr_state == S_IRQ && ack_match_any && ack_tx_result == IRQ_NO_OK)
			c_alm_num <= ack_ps_alart_num;
		else if(curr_state == S_IRQ && timout)
			c_alm_num <= ALARM_BEHATMOUT;
		else if(curr_state == S_IDLE)
			c_alm_num <= 8'd0;
		else
			c_alm_num <= c_alm_num;
	end

	//Timeout count (waiting for PS ack of the timer irq30)
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
		else
			timout_cnt <= timout_cnt;
	end

	always@(posedge clk_i)begin
		if(rst_i)
			timout <= 1'b0;
		else if(timout_cnt >= c_tx_ot-1)
			timout <= 1'b1;
		else
			timout <= 1'b0;
	end

endmodule
