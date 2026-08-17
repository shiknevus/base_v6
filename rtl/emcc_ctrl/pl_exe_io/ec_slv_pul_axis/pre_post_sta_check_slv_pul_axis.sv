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


module pre_post_sta_check_slv_pul_axis#(
		parameter		A_BHA_NUM		=	8
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
		
		,input		[3:0]				di_i
		,input		[1:0]				do_i

		//io port start
		,input		[0:0]				i_servo_notok			
		,input		[0:0]				i_servo_stop			
		,input		[0:0]				i_axis_limf			
		,input		[0:0]				i_axis_org			
		,input		[0:0]				i_axis_limb			
		,input		[0:0]				i_emerge_stop_signal
		,input		[0:0]				i_safe_status
		,input		[0:0]				i_axis_point
		,input		[0:0]				i_axis_reset
		//io port end
		
		,input							a_en
		,input							a_bhv_vld
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
	
	

	//limit rising-edge latch (same as ctrl_ethercat_servo): latch on edge, clear when
	//a new behavior starts and both limits released; level fallback below.
	reg			limf_d1, limb_d1;
	reg			limf_alarm, limb_alarm;
	wire		limf_rise = i_axis_limf & ~limf_d1;
	wire		limb_rise = i_axis_limb & ~limb_d1;
	always@(posedge clk_i) begin
		if(rst_i || !a_en) begin
			limf_d1    <= 1'b0;
			limb_d1    <= 1'b0;
			limf_alarm <= 1'b0;
			limb_alarm <= 1'b0;
		end else begin
			limf_d1 <= i_axis_limf;
			limb_d1 <= i_axis_limb;
			if(limf_rise)
				limf_alarm <= 1'b1;
			else if(limb_rise)
				limb_alarm <= 1'b1;
			else if(a_bhv_vld && !(i_axis_limf|i_axis_limb)) begin
				limf_alarm <= 1'b0;
				limb_alarm <= 1'b0;
			end
		end
	end
	wire servo_limit_alarm = limf_alarm | limb_alarm | (i_axis_limf|i_axis_limb);  //level fallback

	//home completed: beh1 (home) passes post-check -> set; beh7 (soff) clears
	reg home_completed;
	always@(posedge clk_i) begin
		if(rst_i || !a_en)
			home_completed <= 1'b0;
		else if(a_bhv_id == 8'd1 && a_post_sta_allow[0])
			home_completed <= 1'b1;
		else if(a_bhv_id == 8'd7)
			home_completed <= 1'b0;
	end

	//pre status per behavior (same as ctrl_ethercat_servo):
	// beh1 home:                 axis ok (limit-exempt: home hits limit)
	// beh2 move0/3 jog/4 moveabs: home_completed + axis ok + no limit alarm
	// beh5 getpoint/6 son/7 soff/8 reset: always
	wire axis_ok = !i_servo_notok && !i_emerge_stop_signal && !i_safe_status
	            && !unit_st && !m_st && !m_saf_st && !link_m_saf_st;
	always@(posedge clk_i)begin
		if(rst_i || !a_en)
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		else begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
			a_pre_sta_allow[0] <= axis_ok;                                           // beh1 home
			a_pre_sta_allow[1] <= home_completed && axis_ok && !servo_limit_alarm;   // beh2 move0
			a_pre_sta_allow[2] <= home_completed && axis_ok && !servo_limit_alarm;   // beh3 jog
			a_pre_sta_allow[3] <= home_completed && axis_ok && !servo_limit_alarm;   // beh4 move abs
			a_pre_sta_allow[4] <= 1'b1;                                              // beh5 get point
			a_pre_sta_allow[5] <= 1'b1;                                              // beh6 son
			a_pre_sta_allow[6] <= 1'b1;                                              // beh7 soff
			a_pre_sta_allow[7] <= 1'b1;                                              // beh8 reset
		end
	end

	//post status: EXE completes directly (motion result confirmed by master via slave message)
	always@(posedge clk_i)
	begin
		if(rst_i || !a_en)
			a_post_sta_allow <= {A_BHA_NUM{1'b0}};
		else
			a_post_sta_allow <= {A_BHA_NUM{1'b1}};
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
