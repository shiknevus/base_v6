`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: cgliu
//
// Create Date: 2026/06/29 22:38:46
// Design Name:
// Module Name: proactive_beh
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

module proactive_beh_ocr_camera#(
    parameter                 	BHA_NUM = 2  		//Number of active behaviors (1-128 generic)
)(
    input                       clk_i
    ,input                      rst_i
    ,input                      i_time_1ms_vld      //ms pulse
    ,input                      i_time_1s_vld       //s pulse

    ,input      [BHA_NUM-1:0]   pre_sta_allow   	//Pre - sufficient condition satisfied signal. 0: Not satisfied. 1: Satisfied.
    ,input      [BHA_NUM-1:0]   post_sta_allow  	//Post - sufficient condition satisfied signal

	,input						a_en				//A enable
    ,input      [7:0]           a_bhv_id
    ,input                      a_bhv_vld
    ,input      [19:0]          a_tx_ot
    ,input      [31:0]          a_tx_result_rpt
	,input						a_tx_result_vld
    ,output		                ec_cha_st
    ,output reg [7:0]           a_tx_id
    ,output reg	[7:0]           a_alm_num

	,output reg [7:0]      		a_bhv_id_r
	,output	reg	[31:0]			state_monitor_o
    ,output reg                 irq_o
    ,input                      irq_ack_i       	//Interrupt response pulse

	,input		[3:0]			i_m_wk_mod			//work mode: 3 = manual (reject 204)
	,input						i_link_lock			//link lock (reject 203)
    );

    reg [7:0]    	curr_state;
	reg [7:0]    	curr_state_1d;
    reg [7:0]    	next_state;

    reg         	timout;
    reg [19:0]   	timout_cnt;

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

    localparam  ALARM_BEHATMOUT = 8'd120;	//behavior timeout (same as old framework)
    localparam  ALARM_MANUAL    = 8'd204;	//manual mode (same as old framework)
    localparam  ALARM_LOCK      = 8'd203;	//link lock (same as old framework)

    wire auto_manual = (i_m_wk_mod == 4'd3);	//set_work_mode == 3: manual


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

	//Analyze interrupt response register
	always@(posedge clk_i)begin
	if(rst_i)begin
		ack_beh_id 	 	<=	8'd0;
		ack_tx_id	 	<=	8'd0;
		ack_tx_result	<=	8'd0;
		ack_ps_alart_num<=	8'd0;
	end else if(a_tx_result_vld)begin
		ack_beh_id 		<= 	a_tx_result_rpt[31:24];
		ack_tx_id		<= 	a_tx_result_rpt[23:16];
		ack_tx_result	<= 	a_tx_result_rpt[15:8];
		ack_ps_alart_num<=	a_tx_result_rpt[7:0];
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

    reg			a_bhv_vld_r;

    //Current behavior number
    always@(posedge clk_i)begin
        if(rst_i)begin
            a_bhv_id_r <= 8'd0;
			a_bhv_vld_r <= 1'b0;
		end else if(a_en && ((a_bhv_id >= 8'd1) && (a_bhv_id <= BHA_NUM)) && a_bhv_vld)begin
			a_bhv_id_r <= a_bhv_id;
			a_bhv_vld_r <= a_bhv_vld;
		end else if(curr_state == S_IDLE && curr_state_1d != curr_state)begin
			a_bhv_id_r <= 8'd0;
			a_bhv_vld_r <= 1'b0;
		end else begin
			a_bhv_id_r <= a_bhv_id_r;
			a_bhv_vld_r <= 1'b0;
		end
    end

//------------------------------------------- FSM begin => Control 10/20/30/40 interrupt -----------------------------------------------//

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
        match_10 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd10 && ack_beh_id == a_bhv_id_r);
		//match_20 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd20 && ack_beh_id == a_bhv_id_r);
	else if(curr_state == S_SUCC_30_ACK)
		match_30 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd30 && ack_beh_id == a_bhv_id_r);
	else if(curr_state == S_ALERT_40_ACK)
		match_40 <= (ack_tx_id == 8'd40 && ack_beh_id == a_bhv_id_r);
	else begin
		match_10 <= 1'b0;
		//match_20 <= 1'b0;
		match_30 <= 1'b0;
		match_40 <= 1'b0;
	end
	end

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
            S_IDLE: begin			//curr_state = 0
                if (a_en && ((a_bhv_id_r >= 8'd1) && (a_bhv_id_r <= BHA_NUM)) && a_bhv_vld_r)	//behavior start
                    next_state = S_BHA_PRE_DET;
                else
                    next_state = S_IDLE;
            end

            S_BHA_PRE_DET: begin	//curr_state = 1
				if(pre_sta_allow[a_bhv_id_r - 1'b1]) begin
					next_state = S_READY_10;
				end else if(auto_manual) begin
					next_state = S_ALERT_40;		//manual mode: reject immediately (204)
				end else if(i_link_lock) begin
					next_state = S_ALERT_40;		//link lock: reject immediately (203)
				end else if(timout) begin
					next_state = S_ALERT_40;
				end else begin
					next_state = S_BHA_PRE_DET;
				end
            end

            S_READY_10: begin  		//curr_state = 2
				next_state = S_READY_10_ACK;				//Send 10 interrupt
            end

			S_READY_10_ACK: begin	//curr_state = 3
				if(match_10) 								//Transaction 10 Acknowledged OK
                    next_state = S_EXE_20;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_READY_10_ACK;
			end

            S_EXE_20: begin			//curr_state = 4
				next_state = S_EXE;							//Send 20 interrupt
            end

			S_EXE:begin				//curr_state = 5
				next_state = S_BHA_POST_DET;
			end

			//S_EXE_20_ACK: begin
			//	if(match_20) 								//Transaction 20 Acknowledged OK
            //        next_state = S_EXE;
            //    else if(ack_tx_result == IRQ_NO_OK || timout)
            //        next_state = S_ALERT_40;
            //    else
            //        next_state = S_EXE_20_ACK;
			//end

            S_BHA_POST_DET: begin	//curr_state = 7
				if(post_sta_allow[a_bhv_id_r - 1'b1]) begin
					next_state = S_SUCC_30;
				end else if(timout) begin
					next_state = S_ALERT_40;
				end else begin
					next_state = S_BHA_POST_DET;
				end
            end

            S_SUCC_30: begin		//curr_state = 7
				next_state = S_SUCC_30_ACK;					//Send Interrupt 30
            end

			S_SUCC_30_ACK:begin		//curr_state = 8
				if(match_30)    							//30 response success
                    next_state = S_IDLE;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_SUCC_30_ACK;
			end

            S_ALERT_40: begin		//curr_state = 9
				next_state = S_ALERT_40_ACK;				//Send Interrupt 40
            end

			S_ALERT_40_ACK:begin	//curr_state = 10
				if(match_40 || timout) 						//40 Interrupt response
                    next_state = S_IDLE;
                else
                    next_state = S_ALERT_40_ACK;
			end

            default: begin
                next_state = S_IDLE;
            end

        endcase
    end

//----------------------------------------------------------- FSM end ------------------------------------------------------//

    //Channel A busy signal
	assign ec_cha_st = (curr_state != S_IDLE)?1'b1:1'b0;

    //Channel A transaction ID: 10 20 30 40
    always@(posedge clk_i)begin
        if(rst_i || !a_en)
            a_tx_id <= 8'd0;
        else if(curr_state == S_READY_10)
            a_tx_id <= 8'd10;
        //else if(curr_state == S_EXE_20)
        //    a_tx_id <= 8'd20;
        else if(curr_state == S_SUCC_30)
            a_tx_id <= 8'd30;
        else if(curr_state == S_ALERT_40)
            a_tx_id <= 8'd40;
		else if(curr_state == S_IDLE || curr_state == S_BHA_PRE_DET)
			a_tx_id <= 8'd0;
        else
            a_tx_id <= a_tx_id;
    end

    always@(posedge clk_i)begin
        if(rst_i || !a_en)
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
        if(rst_i || !a_en)
            a_alm_num <= 8'd0;
        else if(curr_state == S_BHA_PRE_DET && auto_manual && !pre_sta_allow[a_bhv_id_r - 1'b1])
            a_alm_num <= ALARM_MANUAL;	//hard alarm: manual mode
        else if(curr_state == S_BHA_PRE_DET && i_link_lock && !pre_sta_allow[a_bhv_id_r - 1'b1])
            a_alm_num <= ALARM_LOCK;	//hard alarm: link lock
        else if(curr_state == S_BHA_PRE_DET && timout)
            a_alm_num <= ALARM_BEHATMOUT;
        else if(curr_state == S_READY_10_ACK && ack_tx_result == IRQ_NO_OK)
            a_alm_num <= ack_ps_alart_num;
        else if(curr_state == S_READY_10_ACK && timout)
            a_alm_num <= ALARM_BEHATMOUT;
		//else if(curr_state == S_EXE_20_ACK && ack_tx_result == IRQ_NO_OK)
        //    a_alm_num <= ack_ps_alart_num;
        //else if(curr_state == S_EXE_20_ACK && timout)
        //    a_alm_num <= 8'd103;
		else if(curr_state == S_BHA_POST_DET && timout)
            a_alm_num <= ALARM_BEHATMOUT;
		else if(curr_state == S_SUCC_30_ACK && ack_tx_result == IRQ_NO_OK)
			a_alm_num <= ack_ps_alart_num;
		else if(curr_state == S_SUCC_30_ACK && timout)
            a_alm_num <= ALARM_BEHATMOUT;
		else if(curr_state == S_IDLE)
			a_alm_num <= 8'd0;
        else
            a_alm_num <= a_alm_num;
    end


    //Timeout count
    always@(posedge clk_i)begin
        if(rst_i)
            timout_cnt <= 20'd0;
		else if(!a_en)
			timout_cnt <= 20'd0;
		else if(curr_state != curr_state_1d)
			timout_cnt <= 20'd0;
        else if(timout_cnt >= a_tx_ot-1)
            timout_cnt <= 20'd0;
        else if(i_time_1s_vld)
            timout_cnt <= timout_cnt+1;
		else
			timout_cnt <= timout_cnt;
    end

    always@(posedge clk_i)begin
        if(rst_i)
            timout <= 1'b0;
        else if(timout_cnt >= a_tx_ot-1)
            timout <= 1'b1;
        else
            timout <= 1'b0;
    end

//==============================================================================================================================//
//----------------------------------------------------- user logic begin -----------------------------------------------------//
//==============================================================================================================================//




//==============================================================================================================================//
//----------------------------------------------------- user logic end -------------------------------------------------------//
//==============================================================================================================================//

endmodule
