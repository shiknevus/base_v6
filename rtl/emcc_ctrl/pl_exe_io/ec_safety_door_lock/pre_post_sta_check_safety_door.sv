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


module pre_post_sta_check_safety_door#(
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
		,output		[B_BHA_NUM-1:0]		b_pre_sta_allow	
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

	//pre status
	
	wire	safe_allow = !unit_st && !m_st && !m_saf_st && !link_m_saf_st;
	
	reg		a_post_sta_allow1;
	reg		a_post_sta_allow2;
	wire	a_post_sta_allow3;
	wire	a_post_sta_allow4;
	
	always@(posedge clk_i)
	begin
		if(rst_i || !a_en) begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		end else if(safe_allow) begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b1}};
		end else begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		end
	end
	
	
	//post status
	
	//action 1
	always@(posedge clk_i)
	begin
		if(rst_i || !a_en) begin
			a_post_sta_allow1 <= 1'b0;
		end else if(!i_lock_monitor) begin
			a_post_sta_allow1 <= 1'b1;
		end else if(ec_chb_st_negedge)begin
			a_post_sta_allow1 <= 1'b0;
		end else begin
			a_post_sta_allow1 <= a_post_sta_allow1;
		end
	end
	
	//action 2
	always@(posedge clk_i)
	begin
		if(rst_i || !a_en) begin
			a_post_sta_allow2 <= 1'b0;
		end else if(i_lock_monitor) begin
			a_post_sta_allow2 <= 1'b1;
		end else if(ec_chb_st_negedge)begin
			a_post_sta_allow2 <= 1'b0;
		end else
			a_post_sta_allow2 <= a_post_sta_allow2; 
	end
	
	//action 3
	assign a_post_sta_allow3 = 1;
	
	//action 4
	assign a_post_sta_allow4 = 1;
	
	assign a_post_sta_allow = {a_post_sta_allow1,a_post_sta_allow2,a_post_sta_allow3,a_post_sta_allow4};
	
	//========================================================================================//
	//---------------------------------  Channel B check -------------------------------------//
	//========================================================================================//

	
	//pre status

	always@(posedge i_clk)
	begin
		if(i_rst)
			ri_open_req_key <= 0;
		else
			ri_open_req_key <= i_open_req_key;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			open_req_key_posedge <= 0;
		else if({ri_open_req_key,i_open_req_key} == 2'b01)
			open_req_key_posedge <= 1;
		else
			open_req_key_posedge <= 0;
	end
	
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			ri_close_confirm_key <= 0;
		else
			ri_close_confirm_key <= i_close_confirm_key;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			close_confirm_key_posedge <= 0;
		else if({ri_close_confirm_key,i_close_confirm_key} == 2'b01)
			close_confirm_key_posedge <= 1;
		else
			close_confirm_key_posedge <= 0;
	end
	
	
	//action 100 pre-status
	always@(posedge i_clk)
	begin
		if(i_rst || !b_en)
			b_pre_sta_allow_act100 <= 1'b0;
		else if(safe_allow && open_req_key_posedge)
			b_pre_sta_allow_act100 <= 1'b1;
		else if(ec_chb_st_negedge)
			b_pre_sta_allow_act100 <= 1'b0;
		else
			b_pre_sta_allow_act100 <= b_pre_sta_allow_act100;
	end
	
	//action 101 pre-status
	always@(posedge i_clk)
	begin
		if(i_rst || !b_en)
			b_pre_sta_allow_act101 <= 1'b0;
		else if(safe_allow && close_confirm_key_posedge)
			b_pre_sta_allow_act101 <= 1'b1;
		else if(ec_chb_st_negedge)
			b_pre_sta_allow_act101 <= 1'b0;
		else
			b_pre_sta_allow_act101 <= b_pre_sta_allow_act101;
	end
	
	
	assign b_pre_sta_allow = {b_pre_sta_allow_act101,b_pre_sta_allow_act100};

	
	//post status
	
	//action 100 post-status
	always@(posedge i_clk)
	begin
		if(i_rst)
			b_post_sta_allow_act100 <= 1'b0;
		else if(!i_lock_monitor)	//0:open
			b_post_sta_allow_act100 <= 1'b1;
		else if(ec_chb_st_negedge)
			b_post_sta_allow_act100 <= 1'b0;
		else
			b_post_sta_allow_act100 <= b_post_sta_allow_act100;
	end
	
	//action 101 post-status
	always@(posedge i_clk)
	begin
		if(i_rst)
			b_post_sta_allow_act101 <= 1'b0;
		else if(i_lock_monitor)	//1:close
			b_post_sta_allow_act101 <= 1'b1;
		else if(ec_chb_st_negedge)
			b_post_sta_allow_act101 <= 1'b0;
		else
			b_post_sta_allow_act101 <= b_post_sta_allow_act101;
	end
	
	
	assign b_post_sta_allow = {b_post_sta_allow_act101,b_post_sta_allow_act100};


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
