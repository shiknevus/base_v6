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


module pre_post_sta_check_test#(
		parameter		A_BHA_NUM		=	2      	
		,parameter		B_BHA_NUM		=	1  
		,parameter		C_BHA_NUM		=	1  
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
		
		,input 							i_open_req_key    
		,input 							i_close_confirm_key
		//,input 							i_door_monitor	
		,input 							i_lock_monitor  	//close = 1

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
	
	wire	i_clk = clk_i;
	wire	i_rst = rst_i;
	
	reg 	b_pre_sta_allow_act100;
	reg 	b_pre_sta_allow_act101;
	
	reg 	b_post_sta_allow_act100;
	reg 	b_post_sta_allow_act101;
	
	reg		ec_chb_st_r;
	reg		ec_chb_st_negedge;
	
	reg		ri_open_req_key;
	reg		open_req_key_posedge;
	reg		ri_close_confirm_key;
	reg		close_confirm_key_posedge;
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			ec_chb_st_r <= 1'b0;
		else
			ec_chb_st_r <= ec_chb_st;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			ec_chb_st_negedge <= 0;
		else if({ri_open_req_key,i_open_req_key} == 2'b01)
			ec_chb_st_negedge <= 1;
		else
			ec_chb_st_negedge <= 0;
	end
	
	//========================================================================================//
	//---------------------------------  Channel A check -------------------------------------//
	//========================================================================================//

	always@(posedge clk_i)
	begin
		if(rst_i) begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		end else if(a_en) begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b1}};
		end else begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		end
	end
	
	always@(posedge clk_i)
	begin
		if(rst_i) begin
			a_post_sta_allow <= {A_BHA_NUM{1'b0}};
		end else if(a_en) begin
			a_post_sta_allow <= {A_BHA_NUM{1'b1}};
		end else begin
			a_post_sta_allow <= {A_BHA_NUM{1'b0}};
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
