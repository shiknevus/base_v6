`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: cgliu
// 
// Create Date: 2026/07/14 22:38:46
// Design Name: 
// Module Name: 
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


module proactive_beh_8do#(
    parameter                 	BHA_NUM = 2   //Number of active behaviors
)(
    input                       clk_i
    ,input                      rst_i
    ,input                      i_time_1ms_vld      //ms pulse
    ,input                      i_time_1s_vld       //s pulse

    ,input      [BHA_NUM-1:0]   pre_sta_allow   //Pre - sufficient condition satisfied signal. 0: Not satisfied. 1: Satisfied.
    ,input      [BHA_NUM-1:0]   post_sta_allow  //Post - sufficient condition satisfied signal
	
	,input						a_en			//A enable
    ,input      [7:0]           a_bhv_id
    ,input                      a_bhv_vld
    ,input      [19:0]          a_tx_ot
    ,input      [31:0]          a_tx_result_rpt	
	,input						a_tx_result_vld
    ,output		                ec_cha_st
    ,output reg [7:0]           a_tx_id
    ,output reg	[7:0]           a_alm_num

    ,output reg [7:0]           do_o

    ,output reg                 irq_o
    ,input                      irq_ack_i       //Interrupt response
    );

    reg  [7:0]      a_bhv_id_r;

    reg [7:0]    	curr_state;
	reg [7:0]    	curr_state_1d;
    reg [7:0]    	next_state;

    reg         	timout;
    reg [19:0]   	timout_cnt;
	
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
	
	always@(posedge clk_i)begin
	if(rst_i)
		curr_state_1d <= 8'd0;
	else
		curr_state_1d <= curr_state;
	end
	
    //Current behavior number
    always@(posedge clk_i)begin
        if(rst_i)
            a_bhv_id_r <= 8'd0;
        else if(a_bhv_vld)
            a_bhv_id_r <= a_bhv_id;
        else
            a_bhv_id_r <= a_bhv_id_r;
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
    

    always @(posedge clk_i) begin
        if (rst_i)
            curr_state <= S_IDLE;
        else
            curr_state <= next_state;
    end

    always @(*) begin
        case (curr_state)
            S_IDLE: begin	//0
                if (a_en && a_bhv_id != 8'd0 && a_bhv_vld)    //ps behavior execution instruction
                    next_state = S_BHA_PRE_DET;
                else
                    next_state = S_IDLE;
            end

            S_BHA_PRE_DET: begin	//curr_state = 1
				if( ((a_bhv_id_r >= 8'd1) && (a_bhv_id_r <= BHA_NUM)) ? pre_sta_allow[a_bhv_id_r - 1'b1] : 1'b0 ) begin
					next_state = S_READY_10;
				end else if(timout) begin
					next_state = S_ALERT_40;			
				end else begin
					next_state = S_BHA_PRE_DET;
				end
            end

            S_READY_10: begin  //2      						//Send 10 interrupt
				next_state = S_READY_10_ACK;
            end

			S_READY_10_ACK: begin	//3
				if(match_10) 								//Transaction 10 Acknowledged OK
                    next_state = S_EXE_20;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_READY_10_ACK;
			end

            S_EXE_20: begin		//4							//Send 20 interrupt
				//next_state = S_EXE_20_ACK;
				next_state = S_EXE;
            end
			
			//S_EXE_20_ACK: begin
			//	if(match_20) 								//Transaction 20 Acknowledged OK
            //        next_state = S_EXE;
            //    else if(ack_tx_result == IRQ_NO_OK || timout)
            //        next_state = S_ALERT_40;
            //    else
            //        next_state = S_EXE_20_ACK;
			//end
			
			S_EXE:begin		//11								//active Execution
				next_state = S_BHA_POST_DET;
			end
			
            S_BHA_POST_DET: begin	//curr_state = 6
				if( ((a_bhv_id_r >= 8'd1) && (a_bhv_id_r <= BHA_NUM)) ? post_sta_allow[a_bhv_id_r - 1'b1] : 1'b0 ) begin
					next_state = S_SUCC_30;
				end else if(timout) begin
					next_state = S_ALERT_40;			
				end else begin
					next_state = S_BHA_POST_DET;
				end
            end

            S_SUCC_30: begin		//7						//Send Interrupt 30
				next_state = S_SUCC_30_ACK;
            end
			
			S_SUCC_30_ACK:begin	//8
				if(match_30)    							//30 response success
                    next_state = S_IDLE;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_SUCC_30_ACK;
			end

            S_ALERT_40: begin		//9						//Send Interrupt 40
				next_state = S_ALERT_40_ACK;
            end
			
			S_ALERT_40_ACK:begin	//10
				if(match_40 || timout) 						//40 response
                    next_state = S_IDLE;
                else
                    next_state = S_ALERT_40_ACK;
			end

            default: begin
                next_state = S_IDLE;
            end

        endcase
    end

    //Channel A busy signal
	assign ec_cha_st = (curr_state != S_IDLE)?1'b1:1'b0;

    //Channel A transaction ID: 10 20 30 40
    always@(posedge clk_i)begin
        if(rst_i)
            a_tx_id <= 8'd0;
		else if(!a_en)
			a_tx_id <= 8'd0;
        else if(curr_state == S_READY_10)
            a_tx_id <= 8'd10;
        //else if(curr_state == S_EXE_20)
        //    a_tx_id <= 8'd20;
        else if(curr_state == S_SUCC_30)
            a_tx_id <= 8'd30;
        else if(curr_state == S_ALERT_40)
            a_tx_id <= 8'd40;
		else if(match_40)
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
		else if(curr_state == S_IDLE)
			a_alm_num <= 8'd0;
        else if(curr_state == S_BHA_PRE_DET && timout)
            a_alm_num <= 8'd101;    
        else if(curr_state == S_READY_10_ACK && ack_tx_result == IRQ_NO_OK)	
            a_alm_num <= ack_ps_alart_num;    
        else if(curr_state == S_READY_10_ACK && timout)						
            a_alm_num <= 8'd102;    
		//else if(curr_state == S_EXE_20_ACK && ack_tx_result == IRQ_NO_OK)	
        //    a_alm_num <= ack_ps_alart_num;    
        //else if(curr_state == S_EXE_20_ACK && timout)						
        //    a_alm_num <= 8'd103;    
		//else if(curr_state_1d == S_EXE && curr_state == S_ALERT_40 && a_bhv_id_r == 8'd1)
		//	a_alm_num <= 8'd104; 
		//else if(curr_state_1d == S_EXE && curr_state == S_ALERT_40 && a_bhv_id_r == 8'd2)
		//	a_alm_num <= 8'd105;
		else if(curr_state == S_BHA_POST_DET && timout)
            a_alm_num <= 8'd103;    
		else if(curr_state == S_SUCC_30_ACK && ack_tx_result == IRQ_NO_OK)	
			a_alm_num <= ack_ps_alart_num;
		else if(curr_state == S_SUCC_30_ACK && timout)						
            a_alm_num <= 8'd104;
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
    end

    always@(posedge clk_i)begin
        if(rst_i)
            timout <= 1'b0;
        else if(timout_cnt >= a_tx_ot-1)
            timout <= 1'b1;
        else
            timout <= 1'b0;
    end
	
	
	
	//===============================================================================================================
	//------------------------------------------------ user logic start ---------------------------------------------
	//===============================================================================================================
	always@(posedge clk_i)
	begin
		if(rst_i)
			do_o <= 8'd0;
		else if(curr_state == S_EXE)begin
			do_o <= do_o;
			case(a_bhv_id_r)
				1 		:	do_o[0] <= 1'b1;
				2 		:	do_o[1] <= 1'b1;
				3 		:	do_o[2] <= 1'b0;
				4 		:	do_o[3] <= 1'b0;
				5 		:	do_o[4] <= 1'b0;
				6 		:	do_o[5] <= 1'b0;
				7 		:	do_o[6] <= 1'b0;
				8 		:	do_o[7] <= 1'b0;
				9 		:	do_o[0] <= 1'b0;
				10		:	do_o[1] <= 1'b0;
				11		:	do_o[2] <= 1'b0;
				12		:	do_o[3] <= 1'b0;
				13		:	do_o[4] <= 1'b0;
				14		:	do_o[5] <= 1'b0;
				15		:	do_o[6] <= 1'b0;
				16		:	do_o[7] <= 1'b0;
				default	:	do_o <= do_o;
			endcase
		end else
			do_o <= do_o;
	end
	
	//===============================================================================================================
	//------------------------------------------------ user logic start ---------------------------------------------
	//===============================================================================================================
	
	
endmodule