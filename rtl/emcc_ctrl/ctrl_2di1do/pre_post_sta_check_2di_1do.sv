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


module pre_post_sta_check_2di_1do#(
		parameter		A_BHA_NUM		=	2      	
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
		
		,input		[1:0]				di_i
		
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
		a_pre_sta_allow <= 11'b000_0111_1111;
	else if(a_bhv_id == 8 && m_saf_st == 0 && link_m_saf_st == 0)
		a_pre_sta_allow[7] <= 1;
	else if(a_bhv_id == 9 && m_saf_st == 0 && link_m_saf_st == 0)
		a_pre_sta_allow[8] <= 1;
	else if(a_bhv_id == 10 && m_saf_st == 0 && link_m_saf_st == 0)
		a_pre_sta_allow[9] <= 1;
	else if(a_bhv_id == 11 && m_saf_st == 0 && link_m_saf_st == 0)
		a_pre_sta_allow[10] <= 1;
	else
		a_pre_sta_allow <= 11'b000_0111_1111;
	end

	
	//post status
	
	wire [A_BHA_NUM-1:0]	post_sta	;
	
	reg		[1:0]			di1_r;
	reg		[1:0]			di2_r;
	
	reg						flag_di1_exit;
	reg						flag_di2_exit;
	
	always@(posedge clk_i)
	begin
		if(rst_i)begin
			di1_r <= 2'b00;
			di2_r <= 2'b00;
		end else begin
			di1_r <= {di1_r[0],di_i[0]};
			di2_r <= {di2_r[0],di_i[1]};
		end
	end
	
	always@(posedge clk_i)
	begin
		if(rst_i)
			flag_di1_exit <= 1'b0;
		else if(ec_cha_st == 0)
			flag_di1_exit <= 1'b0;
		else if(di1_r == {1'b1,1'b0})
			flag_di1_exit <= 1'b1;
		else 
			flag_di1_exit <= flag_di1_exit;
	end
	
	
	always@(posedge clk_i)
	begin
		if(rst_i)
			flag_di2_exit <= 1'b0;
		else if(ec_cha_st == 0)
			flag_di2_exit <= 1'b0;
		else if(di2_r == {1'b1,1'b0})
			flag_di2_exit <= 1'b1;
		else 
			flag_di2_exit <= flag_di2_exit;
	end

	
	assign	post_sta[0] 	= (a_bhv_id == 1 	&& di_i == {1'b0,1'b1});
	assign	post_sta[1] 	= (a_bhv_id == 2 	&& di_i == {1'b1,1'b0});
	assign	post_sta[2] 	= (a_bhv_id == 3							);
	assign	post_sta[3] 	= (a_bhv_id == 4 	&& di_i == {1'b0,1'b1});
	assign	post_sta[4] 	= (a_bhv_id == 5 	&& di_i == {1'b1,1'b0});
	assign	post_sta[5] 	= (a_bhv_id == 6 	&& di_i == {1'b0,1'b0} && flag_di2_exit);
	assign	post_sta[6] 	= (a_bhv_id == 7 	&& di_i == {1'b0,1'b0} && flag_di1_exit);
	assign	post_sta[7] 	= (a_bhv_id == 8 	&& di_i == {1'b0,1'b1});
	assign	post_sta[8] 	= (a_bhv_id == 9 	&& di_i == {1'b1,1'b0});
	assign	post_sta[9] 	= (a_bhv_id == 10 	&& di_i == {1'b0,1'b0} && flag_di2_exit);
	assign	post_sta[10] 	= (a_bhv_id == 11 	&& di_i == {1'b0,1'b0} && flag_di1_exit);
	
	
	always@(posedge clk_i)begin
	if(rst_i || !a_en)
		a_post_sta_allow <= 11'b000_0000_0000;
	else if(post_sta[0])
		a_post_sta_allow[0] <= 1;
	else if(post_sta[1])
		a_post_sta_allow[1] <= 1;
	else if(post_sta[2])
		a_post_sta_allow[2] <= 1;
	else if(post_sta[3])
		a_post_sta_allow[3] <= 1;
	else if(post_sta[4])
		a_post_sta_allow[4] <= 1;
	else if(post_sta[5])
		a_post_sta_allow[5] <= 1;
	else if(post_sta[6])
		a_post_sta_allow[6] <= 1;
	else if(post_sta[7])
		a_post_sta_allow[7] <= 1;
	else if(post_sta[8])
		a_post_sta_allow[8] <= 1;
	else if(post_sta[9])
		a_post_sta_allow[9] <= 1;
	else if(post_sta[10])
		a_post_sta_allow[10] <= 1;
	else
		a_post_sta_allow <= 7'b000_0000;
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
