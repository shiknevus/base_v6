`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: cgliu
// 
// Create Date: 2026/06/30 10:12:00
// Design Name: 
// Module Name: pre_post_sta_check
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


module pre_post_sta_check#(
		parameter		A_BHA_NUM	=	2      	
		,parameter		B_BHA_NUM	=	1      		
)(
		input							clk_i			
		,input							rst_i			
		
		,input		[7:0]				unit_id         
		,input 		[3:0]				unit_ectrl      
		,input 		[3:0]				unit_st         
		,input 		[7:0]				m_id            
		,input 		[3:0]				m_ectrl         
		,input 		[3:0]				m_st            
		,input 		[3:0]				m_wk_mod        
		,input 							m_saf_st        
		,input 							link_m_saf_st   
		,input 		[7:0]				sc_id			
		,input 		[7:0]				ec_id           
		
		,input							di				
		
		,input							b_en				//通道B使能 ps-pl
		,input							c_en				//通道C使能 ps-pl
		
		,input							ec_cha_st		
		,input							ec_chb_st       
		,input							ec_chc_st       
		
		,input 		[31:0] 				c_circle_time		//通道C时间周期
		,input 		[31:0]				task_time_cnt		//通道C当前计数值

		,output	reg	[A_BHA_NUM-1:0]		a_pre_sta_allow		//通道A 前充分状态允许
		,output	reg	[A_BHA_NUM-1:0]		a_post_sta_allow	//通道A 后充分状态允许
		,output	reg	[B_BHA_NUM-1:0]		b_pre_sta_allow		//通道B 前充分状态允许
		,output	reg	[B_BHA_NUM-1:0]		b_post_sta_allow	//通道B 后充分状态允许
		,output	reg						c_pre_sta_allow		//通道C 前充分状态允许
		,output	reg						c_post_sta_allow	//通道C 后充分状态允许
    );
	
	//========================================================================================//
	//--------------------------------- 通道A前充分、后充分检查 ------------------------------//
	//========================================================================================//
	
	//前充分条件检查
	always@(posedge clk_i)begin
	if(rst_i)
		a_pre_sta_allow <= 2'b00;
	else
		a_pre_sta_allow <= 2'b11;
	end
	
	//后充分条件检查
	always@(posedge clk_i)begin
	if(rst_i)
		a_post_sta_allow <= 2'b00;
	else
		a_post_sta_allow <= 2'b11;
	end
		
	
	//========================================================================================//
	//--------------------------------- 通道B前充分、后充分检查 ------------------------------//
	//========================================================================================//

	always@(posedge clk_i)begin
	if(rst_i)
		b_pre_sta_allow <= 'd0;
	else if(b_en)
		b_pre_sta_allow <= 'd1;
	else
		b_pre_sta_allow <= 'd0;
	end
	
	always@(posedge clk_i)begin
	if(rst_i)
		b_post_sta_allow <= 'd0;
	else if(b_en)
		b_post_sta_allow <= 'd1;
	else
		b_post_sta_allow <= 'd0;
	end

	//========================================================================================//
	//--------------------------------- 通道C前充分、后充分检查 ------------------------------//
	//========================================================================================//

	always@(posedge clk_i)begin
	if(rst_i)
		c_pre_sta_allow <= 1'b0;
	else if(c_en)
		c_pre_sta_allow <= 1'b1;
	else
		c_pre_sta_allow <= 1'b0;
	end
	
	always@(posedge clk_i)begin
	if(rst_i)
		c_post_sta_allow <= 1'b0;
	else if(c_en && (task_time_cnt >= c_circle_time-1))
		c_post_sta_allow <= 1'b1;
	else
		c_post_sta_allow <= 1'b0;
	end

endmodule
