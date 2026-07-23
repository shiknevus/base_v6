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


module pre_post_sta_check_3di_2do#(
		parameter		A_BHA_NUM		=	13      	
		,parameter		B_BHA_NUM		=	1  
)(
		input							clk_i			
		,input							rst_i	

		,input							i_time_1ms_vld
		,input							i_time_1s_vld 
		
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
		
		,input		[0:0]				di_i//invaild
		,input		[3:0]				do_i
		
		,input							valid_sig_1
		,input							valid_sig_2
		,input							valid_sig_3
		,input							a_en
		,input							b_en			
		,input							c_en	
			
		,input		[7:0]				a_bhv_id
		,input		[7:0]				b_bhv_id
		,input		[7:0]				c_bhv_id
		
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
	
	

	//pre status
	always@(posedge clk_i)begin
	if(rst_i && !a_en)
		a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
	else
		a_pre_sta_allow <= {A_BHA_NUM{1'b1}};
	end

	wire [A_BHA_NUM-1:0]	post_sta	;

	assign	post_sta[0 ] = (a_bhv_id == 1 );
	assign	post_sta[1 ] = (a_bhv_id == 2 );
	assign	post_sta[2 ] = (a_bhv_id == 3 );
	assign	post_sta[3 ] = (a_bhv_id == 4 );
	assign	post_sta[4 ] = (a_bhv_id == 5 );
	assign	post_sta[5 ] = (a_bhv_id == 6 );
	assign	post_sta[6 ] = (a_bhv_id == 7 );
	assign	post_sta[7 ] = (a_bhv_id == 8 );


	always@(posedge clk_i) 
	begin
		if(rst_i || !a_en)
			a_post_sta_allow <= {A_BHA_NUM{1'b0}};
		else if(post_sta[0] && A_BHA_NUM > 0)
			a_post_sta_allow[0] <= 1;
		else if(post_sta[1] && A_BHA_NUM > 1)
			a_post_sta_allow[1] <= 1;
		else if(post_sta[2] && A_BHA_NUM > 2)
			a_post_sta_allow[2] <= 1;
		else if(post_sta[3] && A_BHA_NUM > 3)
			a_post_sta_allow[3] <= 1;
		else if(post_sta[4] && A_BHA_NUM > 4)
			a_post_sta_allow[4] <= 1;
		else if(post_sta[5] && A_BHA_NUM > 5)
			a_post_sta_allow[5] <= 1;
		else if(post_sta[6] && A_BHA_NUM > 6)
			a_post_sta_allow[6] <= 1;
		else if(post_sta[7] && A_BHA_NUM > 7)
			a_post_sta_allow[7] <= 1;
		else
			a_post_sta_allow <= {A_BHA_NUM{1'b0}};
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
		c_pre_sta_allow <= 'd0;
	else if(c_en)
		c_pre_sta_allow <= 'd1;
	else
		c_pre_sta_allow <= 'd0;
	end
	
	always@(posedge clk_i)begin
	if(rst_i)
		c_post_sta_allow <= 'd0;
	else if(c_en)
		c_post_sta_allow <= 'd0;
	else
		c_post_sta_allow <= 'd0;
	end

endmodule
