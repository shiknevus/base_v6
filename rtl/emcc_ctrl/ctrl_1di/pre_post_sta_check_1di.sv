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


module pre_post_sta_check_1di#(
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
		
		,input							a_en
		,input							b_en			
		,input							c_en			
		
		,input							ec_cha_st		
		,input							ec_chb_st       
		,input							ec_chc_st       
		
		,input 		[19:0] 				c_circle_time	
		,input 		[19:0]				task_time_cnt	

		,output	reg	[A_BHA_NUM-1:0]		a_pre_sta_allow	
		,output	reg	[A_BHA_NUM-1:0]		a_post_sta_allow
		,output	reg	[B_BHA_NUM-1:0]		b_pre_sta_allow	
		,output	reg	[B_BHA_NUM-1:0]		b_post_sta_allow
		,output	reg						c_pre_sta_allow	
		,output	reg						c_post_sta_allow
    );
	
	//========================================================================================//
	//---------------------------------  Channel A check -------------------------------------//
	//========================================================================================//
	
	always@(posedge clk_i)begin
	if(rst_i)
		a_pre_sta_allow <= 2'b00;
	else if(a_en)
		a_pre_sta_allow <= 2'b11;
	else
		a_pre_sta_allow <= 2'b00;
	end
	
	always@(posedge clk_i)begin
	if(rst_i)
		a_post_sta_allow <= 2'b00;
	else if(a_en)
		a_post_sta_allow <= 2'b11;
	else
		a_post_sta_allow <= 2'b00;
	end
		
	
	//========================================================================================//
	//---------------------------------  Channel B check -------------------------------------//
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
	//---------------------------------  Channel C check -------------------------------------//
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
	else if(c_en)
		c_post_sta_allow <= 1'b1;
	else
		c_post_sta_allow <= 1'b0;
	end

endmodule
