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


module pre_post_sta_check_stacker_cage_check#(
		parameter		A_BHA_NUM	=	2      	
		,parameter		B_BHA_NUM	=	1   
		,parameter		C_BHA_NUM	=	1     		
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
		
		,input							di		

		,input 		[7:0]				a_bhv_id
        ,input 		[7:0]				b_bhv_id
		,input 		[7:0]				c_bhv_id
		
		,input							a_en
		,input							b_en			
		,input							c_en			
		
		,input							ec_cha_st		
		,input							ec_chb_st       
		,input							ec_chc_st       
		
		,input 		[19:0] 				c_circle_time	
		,input 		[19:0]				task_time_cnt	
		
		,input		[3:0]				i_selchan	
		
		,input 							i_right_far_cage_mat_check 
		,input 							i_right_hori_overrange     
		,input 							i_left_near_cage_mat_check 
		,input 							i_left_far_cage_mat_check  
		,input 							i_left_hori_overrange      
		,input 							i_right_near_cage_mat_cher 
		,input 							i_mat_arr                  
		,input 							i_left_verti_overrange     
		,input 							i_height_overrange         
		,input 							i_right_verti_overrange    

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

	wire slot_mat = (i_selchan==1) ? i_right_near_cage_mat_cher   :
					(i_selchan==2) ? i_right_far_cage_mat_check  	:
					(i_selchan==3) ? i_left_near_cage_mat_check	:
					(i_selchan==4) ? i_left_far_cage_mat_check	: 1'b0;
					
	wire over = i_left_hori_overrange  | i_left_verti_overrange
				| i_right_hori_overrange | i_right_verti_overrange | i_height_overrange;

	//pre status
	always@(posedge clk_i)
	begin
		if(rst_i || !a_en)
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		else
			//yes Material Detected
			if(i_mat_arr)
				a_pre_sta_allow[0] <= 1;
			else
				a_pre_sta_allow[0] <= 0;
		
			//no Material Detected
			if(~i_mat_arr)
				a_pre_sta_allow[1] <= 1;
			else
				a_pre_sta_allow[1] <= 0;
		
			//yes Left-Right Material Detected
			if(slot_mat)
				a_pre_sta_allow[2] <= 1;
			else
				a_pre_sta_allow[2] <= 0;
		
			//no Left-Right Material Detected
			if(~slot_mat)
				a_pre_sta_allow[3] <= 1;
			else
				a_pre_sta_allow[3] <= 0;
		
			//Over-limit Detection
			if(~over)
				a_pre_sta_allow[4] <= 1;
			else
				a_pre_sta_allow[4] <= 0;
	end

	//post status 
	always@(posedge clk_i)
	begin
		if(rst_i || !a_en) begin
			a_post_sta_allow <= {A_BHA_NUM{1'b0}};
		end else if(a_en) begin
			a_post_sta_allow <= {A_BHA_NUM{1'b1}};
		end
	end
		
	
	//========================================================================================//
	//---------------------------------  Channel B check -------------------------------------//
	//========================================================================================//

	always@(posedge clk_i)
	begin
		if(rst_i) begin
			b_pre_sta_allow <= {B_BHA_NUM{1'b0}};
		end else if(b_en) begin
			b_pre_sta_allow <= {B_BHA_NUM{1'b1}};
		end else begin
			b_pre_sta_allow <= {B_BHA_NUM{1'b0}};
		end
	end

	always@(posedge clk_i)
	begin
		if(rst_i) begin
			b_post_sta_allow <= {B_BHA_NUM{1'b0}};
		end else if(b_en) begin
			b_post_sta_allow <= {B_BHA_NUM{1'b1}};
		end else begin
			b_post_sta_allow <= {B_BHA_NUM{1'b0}};
		end
	end

	//========================================================================================//
	//---------------------------------  Channel C check -------------------------------------//
	//========================================================================================//

	always@(posedge clk_i)
	begin
		if(rst_i) begin
			c_pre_sta_allow <= {C_BHA_NUM{1'b0}};
		end else if(c_en) begin
			c_pre_sta_allow <= {C_BHA_NUM{1'b1}};
		end else begin
			c_pre_sta_allow <= {C_BHA_NUM{1'b0}};
		end
	end
	
	always@(posedge clk_i)
	begin
		if(rst_i) begin
			c_post_sta_allow <= {C_BHA_NUM{1'b0}};
		end else if(c_en) begin
			c_post_sta_allow <= {C_BHA_NUM{1'b1}};
		end else begin
			c_post_sta_allow <= {C_BHA_NUM{1'b0}};
		end
	end

endmodule
