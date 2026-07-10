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

module tim_beh(
    input                  		clk_i                
	,input                  	rst_i              	
	,input                  	i_time_1ms_vld   	
	,input                  	i_time_1s_vld    	
	
	,output	reg	[31:0]			task_time_cnt	

	,input						pre_sta_allow		//前充分状态允许
	,input						post_sta_allow		//后充分状态允许
	
	,input						c_en_i				//通道c使能  ps-pl
	,input 		[31:0]			c_tx_ot          	
	,input 		[31:0]			c_tx_result_rpt  	
	,input 		[31:0]			c_gap_crl			// 定时周期配置（单位：1ms，需>0才有效）
	
	,output	reg [3:0]			ec_chc_st			
	,output 	[7:0]			c_bhv_id        	
	,output reg [7:0]			c_tx_id         	
	,output reg [7:0]			c_alm_num			
	
	,output reg              	irq_o 					
	,input                   	irq_ack_i			// 中断应答信号
   );
	
	reg	[7:0]	curr_state		;
	reg	[7:0]	curr_state_1d	;
	reg	[7:0]	next_state		;
	
	reg			timout			;
	reg	[31:0]	timout_cnt		;	
	
	always@(posedge clk_i)begin
	if(rst_i)
		curr_state_1d <= 8'd0;
	else
		curr_state_1d <= curr_state;
	end
	
	//10前	检查前充分条件
	//30前	检查后充分条件
	localparam	S_IDLE			=	8'd0;
	localparam	S_READY			=	8'd1;
	localparam	S_BHA_PRE_DET	=	8'd2;
	localparam	S_EXE			=	8'd3;
	localparam	S_BHA_POST_DET	=	8'd4;
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
        case (curr_state)
            S_IDLE: begin
                if (c_en_i || c_gap_crl != 32'd0)	//启动通道C
                    next_state = S_BHA_PRE_DET;
                else
                    next_state = S_IDLE;
            end
			
			S_BHA_PRE_DET: begin
                if (pre_sta_allow)		
                    next_state = S_READY;
				else if(timout)
					next_state = S_ALERT;
                else
                    next_state = S_BHA_PRE_DET;
            end

            S_READY: begin	//发10中断
                if (c_tx_result_rpt == IRQ_OK)	//10应答
                    next_state = S_EXE;
				else if(c_tx_result_rpt == IRQ_NO_OK || timout)
					next_state = S_ALERT;
                else
                    next_state = S_READY;
            end
			
			S_EXE: begin //发20中断
                if (c_tx_result_rpt == IRQ_OK)	//20应答
                    next_state = S_BHA_POST_DET;
				else if(c_tx_result_rpt == IRQ_NO_OK || timout)
					next_state = S_ALERT;
                else
                    next_state = S_EXE;
            end
			
			S_BHA_POST_DET: begin
                if (post_sta_allow)	//后充分条件满足
                    next_state = S_SUCC;
				else if(timout)
					next_state = S_ALERT;
                else
                    next_state = S_BHA_POST_DET;
            end
			
			S_SUCC: begin
                if (c_tx_result_rpt == IRQ_OK)	//30应答
                    next_state = S_IDLE;
				else if(c_tx_result_rpt == IRQ_NO_OK || timout)
					next_state = S_ALERT;
                else
                    next_state = S_SUCC;
            end
			
			S_ALERT: begin
                if (c_tx_result_rpt == IRQ_OK)	//40应答
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
   
   
	always@(posedge clk_i)begin
	if(rst_i)
		ec_chc_st <= 4'd1;
	else if(curr_state == S_IDLE)
		ec_chc_st <= 4'd0;	//通道C空闲
	else
		ec_chc_st <= 4'd1;
	end
	
	assign c_bhv_id = 8'd201;	//定时行为只有一个行为
	
	//通道C事务ID：10 20 30 40
	always@(posedge clk_i)begin
	if(rst_i)
		c_tx_id <= 8'd0;
	else if(curr_state == S_READY)
		c_tx_id <= 8'd10;
	else if(curr_state == S_EXE)
		c_tx_id <= 8'd20;
	else if(curr_state == S_SUCC)
		c_tx_id <= 8'd30;
	else if(curr_state == S_ALERT)
		c_tx_id <= 8'd40;
	else
		c_tx_id <= 8'd0;
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
		c_alm_num <= 8'd0;
	else if(curr_state == S_READY && timout)
		c_alm_num <= 8'd10;	//10阶段超时报警编号
	else if(curr_state == S_READY && c_tx_result_rpt == IRQ_NO_OK)
		c_alm_num <= 8'd11;	//10阶段ps应答错误报警编号
	else if(curr_state == S_EXE && timout)
		c_alm_num <= 8'd20;	//20阶段超时报警编号
	else if(curr_state == S_EXE && c_tx_result_rpt == IRQ_NO_OK)
		c_alm_num <= 8'd21;	//20阶段ps应答错误报警编号
	else if(curr_state == S_SUCC && timout)
		c_alm_num <= 8'd30;	//30阶段超时报警编号
	else if(curr_state == S_SUCC && c_tx_result_rpt == IRQ_NO_OK)
		c_alm_num <= 8'd31;	//30阶段ps应答错误报警编号
	else
		c_alm_num <= c_alm_num;
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
    if (rst_i) begin
        curr_state1 <= TASK_IDLE;
    end else begin
        curr_state1 <= next_state1;
    end
end

always @(*) begin
    next_state1 = TASK_IDLE;
    case (curr_state1)
        TASK_IDLE: begin
            if (!c_en_i || c_gap_crl == 32'd0) begin
                next_state1 = TASK_IDLE;
            end else begin
                next_state1 = TASK_COUNT;
            end
        end
        TASK_COUNT: begin
            if (task_time_cnt >= c_gap_crl - 1) begin
                next_state1 = TASK_IRQ_WAIT;
            end else begin
                next_state1 = TASK_COUNT;
            end
        end
        TASK_IRQ_WAIT: begin
            if (irq_ack_i) begin
                next_state1 = TASK_BACK;
            end else begin
                next_state1 = TASK_IRQ_WAIT;
            end
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
                    task_time_cnt <= task_time_cnt + i_time_1ms_vld;
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
   
   	//超时计数
	always@(posedge clk_i)begin
        if(rst_i)
            timout_cnt <= 32'd0;
		else if(curr_state != curr_state_1d)
			timout_cnt <= 32'd0;
        else if(timout_cnt >= c_tx_ot-1)
            timout_cnt <= 32'd0;
        else 
            timout_cnt <= timout_cnt+i_time_1ms_vld;
    end


    always@(posedge clk_i)begin
        if(rst_i)
            timout <= 1'd0;
        else if(timout_cnt >= c_tx_ot-1)
            timout <= 1'd1;
        else
            timout <= 1'd0;
    end
   
	

endmodule
