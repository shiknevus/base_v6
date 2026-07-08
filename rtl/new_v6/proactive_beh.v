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


module proactive_beh#(
    parameter                 BHA_NUM = 2   //Number of active behaviors
)(
    input                       clk_i
    ,input                      rst_i
    ,input                      i_time_1ms_vld      //ms pulse
    ,input                      i_time_1s_vld       //s pulse

    ,input      [BHA_NUM-1:0]   pre_sta_allow   //Pre - sufficient condition satisfied signal. 0: Not satisfied. 1: Satisfied.
    ,input      [BHA_NUM-1:0]   post_sta_allow  //Post - sufficient condition satisfied signal

    ,input                      valid_sig       //Signal validity ps-pl

    ,input      [7:0]           a_bhv_id
    ,input                      a_bhv_en
    ,input      [31:0]          a_tx_ot
    ,input      [31:0]          a_tx_result_rpt	//ps中断响应寄存器
	,input						a_tx_result_vld	//ps写中断响应寄存器有效信号
    ,output		                ec_cha_st
    ,output reg [7:0]           a_tx_id
    ,output reg	[7:0]           a_alm_num

    ,input                      di

    ,output reg                 irq_o
    ,input                      irq_ack_i       //Interrupt response
    );

    reg  [7:0]      a_bhv_id_r;

    reg [7:0]    	curr_state;
	reg [7:0]    	curr_state_1d;
    reg [7:0]    	next_state;

    reg         	timout;
    reg [31:0]   	timout_cnt;
	
	reg [7:0]		ack_beh_id;
	reg [7:0]		ack_tx_id;
	reg [7:0]		ack_tx_result;
	
	
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

    localparam  IRQ_OK          = 8'h51;
    localparam  IRQ_NO_OK       = 8'h52;
	
	always@(posedge clk_i)begin
	if(rst_i)begin
		ack_beh_id 	 	<= 8'd0;
		ack_tx_id	 	<= 8'd0;
		ack_tx_result	<= 8'd0;
	end else if(a_tx_result_vld)begin	//根据事务ID可以知道是谁的应答
		ack_beh_id 		<= a_tx_result_rpt[31:24];
		ack_tx_id		<= a_tx_result_rpt[23:16];
		ack_tx_result	<= a_tx_result_rpt[15:8];
	end else begin
		ack_beh_id 		<= ack_beh_id 	  ;
		ack_tx_id		<= ack_tx_id	  ;
		ack_tx_result	<= ack_tx_result  ;
		end
	end
	
	always@(posedge clk_i)begin
	if(rst_i)
		curr_state_1d <= 8'd0;
	else
		curr_state_1d <= curr_state;
	end
	
    //a_bhv_id
    always@(posedge clk_i)begin
        if(rst_i)
            a_bhv_id_r <= 8'd0;
        else if(a_bhv_en)
            a_bhv_id_r <= a_bhv_id;
        else
            a_bhv_id_r <= a_bhv_id_r;
    end

    //10 before: Check the pre - sufficient conditions
    //30 before: Check the post - sufficient conditions
	
	
	reg match_10;
always @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        match_10 <= 1'b0;
    end else begin
        match_10 <= (ack_tx_result == IRQ_OK && ack_tx_id == 8'd10 && ack_beh_id == a_bhv_id_r);
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
                if (a_bhv_id != 8'd0 && a_bhv_en)    //ps behavior execution instruction
                    next_state = S_BHA_PRE_DET;
                else
                    next_state = S_IDLE;
            end

            S_BHA_PRE_DET: begin
                if (pre_sta_allow[0] && a_bhv_id_r == 8'd1)    //行为1的前充分满足
                    next_state = S_READY_10;
				else if(pre_sta_allow[1] && a_bhv_id_r == 8'd2)	//行为2的前充分满足
					next_state = S_READY_10;
                else if(timout)
                    next_state = S_ALERT_40;	//前充分判断超时
                else
                    next_state = S_BHA_PRE_DET;
            end

            S_READY_10: begin        //Send 10 interrupt
				next_state = S_READY_10_ACK;
            end

			S_READY_10_ACK: begin
				if (match_10)  //10事务应答OK
                    next_state = S_EXE_20;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_READY_10_ACK;
			end

            S_EXE_20: begin	//Send 20 interrupt
				if (valid_sig != di && a_bhv_id_r == 8'd1) 	//行为1无效检测
					next_state = S_EXE_20_ACK;
				else if(valid_sig == di && a_bhv_id_r == 8'd2)	//行为2有效检测
					next_state = S_EXE_20_ACK;
				else
					next_state = S_ALERT_40;	//检测失败
            end
			
			S_EXE_20_ACK: begin
				if (ack_tx_result == IRQ_OK && ack_tx_id == 8'd20 && ack_beh_id == a_bhv_id_r) 	//20响应
                    next_state = S_BHA_POST_DET;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_EXE_20_ACK;
			end

            S_BHA_POST_DET: begin
                if (post_sta_allow[0] && a_bhv_id_r == 8'd1)    //Behavior 1 + Post - sufficient condition satisfied
                    next_state = S_SUCC_30;
                else if(post_sta_allow[1] && a_bhv_id_r == 8'd2) //Behavior 2 + Post - sufficient condition satisfied
                    next_state = S_SUCC_30;
                else if(timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_BHA_POST_DET;
            end

            S_SUCC_30: begin	//发30
                next_state = S_SUCC_30_ACK;
            end
			
			S_SUCC_30_ACK:begin
				if (ack_tx_result == IRQ_OK  && ack_tx_id == 8'd30 && ack_beh_id == a_bhv_id_r)    //30 response
                    next_state = S_IDLE;
                else if(ack_tx_result == IRQ_NO_OK || timout)
                    next_state = S_ALERT_40;
                else
                    next_state = S_SUCC_30_ACK;
			end

            S_ALERT_40: begin	//发40中断
                next_state = S_ALERT_40_ACK;
            end
			
			S_ALERT_40_ACK:begin
				if ((ack_tx_result == IRQ_OK && ack_tx_id == 8'd40 && ack_beh_id == a_bhv_id_r) || timout) //40 response
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
        else if(curr_state == S_READY_10)
            a_tx_id <= 8'd10;
        else if(curr_state == S_EXE_20)
            a_tx_id <= 8'd20;
        else if(curr_state == S_SUCC_30)
            a_tx_id <= 8'd30;
        else if(curr_state == S_ALERT_40)
            a_tx_id <= 8'd40;
        else
            a_tx_id <= a_tx_id;
    end

    always@(posedge clk_i)begin
        if(rst_i)
            irq_o <= 1'b0;
		else if(irq_ack_i)    //ps receives interrupt
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
            a_alm_num <= 8'd0;
        else if(curr_state == S_BHA_PRE_DET && timout)
            a_alm_num <= 8'd100;    //前充分检查不满足
        else if(curr_state == S_READY_10_ACK && ack_tx_result == IRQ_NO_OK)
            a_alm_num <= 8'd101;    //事务10 ps应答错误
        else if(curr_state == S_READY_10_ACK && timout)
            a_alm_num <= 8'd102;    //事务10 等待ps应答超时
        else if(curr_state == S_ALERT_40 && curr_state_1d == S_EXE_20)
            a_alm_num <= 8'd103;    //事务20 执行错误
        else if(curr_state == S_EXE_20_ACK && ack_tx_result == IRQ_NO_OK)
            a_alm_num <= 8'd104;    //事务20 ps应答错误
        else if(curr_state == S_EXE_20_ACK && timout)
            a_alm_num <= 8'd105;    //事务20 等待ps应答超时
		else if(curr_state == S_BHA_POST_DET && timout)
            a_alm_num <= 8'd106;    //后充分检查不满足
        else if(curr_state == S_SUCC_30_ACK && ack_tx_result == IRQ_NO_OK)
            a_alm_num <= 8'd107;    //事务30 ps应答错误
		else if(curr_state == S_SUCC_30_ACK && timout)
            a_alm_num <= 8'd107;    //事务30 等待ps应答超时
        else
            a_alm_num <= a_alm_num;
    end

    //Timeout count
    always@(posedge clk_i)begin
        if(rst_i)
            timout_cnt <= 32'd0;
		else if(curr_state != curr_state_1d)
			timout_cnt <= 32'd0;
        else if(timout_cnt >= a_tx_ot-1)
            timout_cnt <= 32'd0;
        else if(i_time_1ms_vld)
            timout_cnt <= timout_cnt+1;
    end


    always@(posedge clk_i)begin
        if(rst_i)
            timout <= 1'd0;
        else if(timout_cnt >= a_tx_ot-1)
            timout <= 1'd1;
        else
            timout <= 1'd0;
    end

endmodule