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


module status_beh#(
	parameter	BHA_NUM	=	1
)(
	input						clk_i			
	,input						rst_i			
	,input						i_time_1ms_vld		//ms脉冲
	,input						i_time_1s_vld 		//s脉冲
	
	,input		[BHA_NUM-1:0]	pre_sta_allow		//前充分条件满足信号 0:不满足 1：满足
	,input		[BHA_NUM-1:0]	post_sta_allow		//后充分条件满足信号

	,input 		[31:0]			b_tx_ot         
	,input 		[31:0]			b_tx_result_rpt 
	,input						b_en_i			
	,output	reg 				ec_chb_st   
	,output	reg [7:0]			b_bhv_id    
	,output	reg [7:0]			b_tx_id     
	,output	reg [7:0]			b_alm_num   
	
	,input						di				
	
	,output	reg					irq_o			
	,input						irq_ack_i			//中断应答
    );
	
	reg			[7:0]			curr_state		;
	reg			[7:0]			curr_state_1d	;
	reg			[7:0]			next_state		;
	
	reg							timout			;
	reg			[31:0]			timout_cnt		;	
	
	wire		[BHA_NUM-1:0]	sta_allow		;	//位宽对应行为数量
	
	assign		sta_allow = 0	;
	
	always@(posedge clk_i)begin
	if(rst_i)
		curr_state_1d <= 8'd0;
	else
		curr_state_1d <= curr_state;
	end
	
	//10前	检查前充分条件
	//30前	检查后充分条件
	localparam	S_IDLE			=	8'd0;
	localparam  S_BHA_PRE_DET   = 	8'd1;    //Pre - sufficient condition check state
	localparam	S_READY			=	8'd2;
	localparam	S_EXE			=	8'd3;
	localparam  S_BHA_POST_DET  = 	8'd4;    //Post - sufficient condition check state
	localparam	S_SUCC			=	8'd5;
	localparam	S_ALERT			=	8'd6;
	
	localparam	IRQ_OK		=	51;
	localparam	IRQ_NO_OK	=	52;
	
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
                if (b_en_i && sta_allow)	//状态满足
                    next_state = S_BHA_PRE_DET;
                else
                    next_state = S_IDLE;
            end
			
			S_BHA_PRE_DET: begin
                if (pre_sta_allow[0])    //Pre - sufficient condition for Behavior 1 + Behavior 1
                    next_state = S_READY;
                else if(timout)
                    next_state = S_ALERT;
                else
                    next_state = S_BHA_PRE_DET;
            end

            S_READY: begin
                if (b_tx_result_rpt == IRQ_OK)
                    next_state = S_EXE;
				else if(timout)
					next_state = S_ALERT;
                else
                    next_state = S_READY;
            end
			
			S_EXE: begin
                if (b_tx_result_rpt == IRQ_OK)
                    next_state = S_BHA_POST_DET;
				else if(timout)
					next_state = S_ALERT;
                else
                    next_state = S_EXE;
            end
			
			S_BHA_POST_DET: begin
                if (post_sta_allow[0])
                    next_state = S_SUCC;
				else if(timout)
					next_state = S_ALERT;
                else
                    next_state = S_BHA_POST_DET;
            end
			
			S_SUCC: begin
                if (b_tx_result_rpt == IRQ_OK)
                    next_state = S_IDLE;
				else if(timout)
					next_state = S_ALERT;
                else
                    next_state = S_SUCC;
            end
			
			S_ALERT: begin
                if (b_tx_result_rpt == IRQ_OK)
                    next_state = S_IDLE;
				else if(timout)
					next_state = S_IDLE;
                else
                    next_state = S_ALERT;
            end
			
			default: begin
                next_state = S_IDLE; 
            end

        endcase
    end
	
	//通道B 忙信号
	always@(posedge clk_i)begin
	if(rst_i)
		ec_chb_st <= 1'd1;
	else if(curr_state == S_IDLE)
		ec_chb_st <= 1'd0;
	else
		ec_chb_st <= 1'd1;
	end
	
	
	always@(posedge clk_i)begin
	if(rst_i)
		b_bhv_id <= 8'd0;
	else case(sta_allow)
		8'd0:
			b_bhv_id <= 8'd0;
		8'd1:
			b_bhv_id <= 8'd101;
		default:
			b_bhv_id <= 8'd0;
		endcase
	end
	
	
	//通道B事务ID：10 20 30 40
	always@(posedge clk_i)begin
	if(rst_i)
		b_tx_id <= 8'd0;
	else if(curr_state == S_READY)
		b_tx_id <= 8'd10;
	else if(curr_state == S_EXE)
		b_tx_id <= 8'd20;
	else if(curr_state == S_SUCC)
		b_tx_id <= 8'd30;
	else if(curr_state == S_ALERT)
		b_tx_id <= 8'd40;
	else
		b_tx_id <= 8'd0;
	end
	
	always@(posedge clk_i)begin
        if(rst_i)
            irq_o <= 1'b0;
        else if(curr_state == S_READY && curr_state != curr_state_1d)
            irq_o <= 1'b1;
		else if(curr_state == S_EXE && curr_state != curr_state_1d)
			irq_o <= 1'b1;
		else if(curr_state == S_SUCC && curr_state != curr_state_1d)
			irq_o <= 1'b1;
		else if(curr_state == S_ALERT && curr_state != curr_state_1d)
			irq_o <= 1'b1;
        else if(irq_ack_i)    //ps receives interrupt
            irq_o <= 1'b0;
        else
            irq_o <= 1'b0;
    end
	
	always@(posedge clk_i)begin
	if(rst_i)
		b_alm_num <= 8'd0;
	else if(curr_state == S_READY && timout)
		b_alm_num <= 8'd10;	//10阶段超时报警编号
	else if(curr_state == S_READY && b_tx_result_rpt == IRQ_NO_OK)
		b_alm_num <= 8'd11;	//10阶段ps应答错误报警编号
	else if(curr_state == S_EXE && timout)
		b_alm_num <= 8'd20;	//20阶段超时报警编号
	else if(curr_state == S_EXE && b_tx_result_rpt == IRQ_NO_OK)
		b_alm_num <= 8'd21;	//20阶段ps应答错误报警编号
	else if(curr_state == S_SUCC && timout)
		b_alm_num <= 8'd30;	//30阶段超时报警编号
	else if(curr_state == S_SUCC && b_tx_result_rpt == IRQ_NO_OK)
		b_alm_num <= 8'd31;	//30阶段ps应答错误报警编号
	else if(irq_ack_i)
		b_alm_num <= 8'd0;
	else
		b_alm_num <= b_alm_num;
	end
	
	//Timeout count
    always@(posedge clk_i)begin
        if(rst_i)
            timout_cnt <= 32'd0;
		else if(curr_state != curr_state_1d)
			timout_cnt <= 32'd0;
        else if(timout_cnt >= b_tx_ot-1)
            timout_cnt <= 32'd0;
        else 
            timout_cnt <= timout_cnt+i_time_1ms_vld;
    end


    always@(posedge clk_i)begin
        if(rst_i)
            timout <= 1'd0;
        else if(timout_cnt >= b_tx_ot-1)
            timout <= 1'd1;
        else
            timout <= 1'd0;
    end
	
	
endmodule
