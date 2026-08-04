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

module pre_post_sta_check_ethercat_servo#(
		parameter		A_BHA_NUM	=	16
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

		,input							i_servo_limf
		,input							i_servo_limb
		,input							i_servo_zero
	
		,input 		[7:0]				a_bhv_id
		,input							a_bhv_vld
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

		,output	reg	[A_BHA_NUM-1:0]		a_pre_sta_allow	
		,output	reg	[A_BHA_NUM-1:0]		a_post_sta_allow
		,output	reg	[B_BHA_NUM-1:0]		b_pre_sta_allow
		,output	reg	[B_BHA_NUM-1:0]		b_post_sta_allow
		,output	reg						c_pre_sta_allow
		,output	reg						c_post_sta_allow

		,output	reg						o_pre_sta_fail	// hard alarm: limit triggered
    );

	//========================================================================================//
	//---------------------------------  Channel A check -------------------------------------//
	//========================================================================================//
	
	//limit rising-edge detect + latch (latched alarm; cleared on new behavior issue)
	reg limf_d1;
	reg limb_d1;
	wire limf_rise = i_servo_limf & ~limf_d1;
	wire limb_rise = i_servo_limb & ~limb_d1;
	always@(posedge clk_i) begin
		limf_d1 <= i_servo_limf;
		limb_d1 <= i_servo_limb;
	end

	//per-direction limit latch: limf blocks POS motion, limb blocks NEG motion
	reg limf_alarm;
	reg limb_alarm;
	always@(posedge clk_i) begin
		if(rst_i || !a_en) begin
			limf_alarm <= 1'b0;
			limb_alarm <= 1'b0;
		end else if(limf_rise) begin
			limf_alarm <= 1'b1;				// latch positive-limit alarm
		end else if(limb_rise) begin
			limb_alarm <= 1'b1;				// latch negative-limit alarm
		end else if(a_bhv_vld && !(i_servo_limf | i_servo_limb)) begin
			limf_alarm <= 1'b0;				// clear: new behavior issued AND limits released
			limb_alarm <= 1'b0;
		end
	end

	//latched alarm OR live limit level (level backstop even after latch cleared)
	wire servo_limit_alarm = limf_alarm | limb_alarm | (i_servo_limf | i_servo_limb);

	//home completed: beh1 (home) passes post-check -> set; reset clears
	reg home_completed;
	always@(posedge clk_i) begin
		if(rst_i || !a_en)
			home_completed <= 1'b0;
		else if(a_bhv_id == 8'd1 && a_post_sta_allow[0])
			home_completed <= 1'b1;
	end

	wire servo_safe = !unit_st && !m_st && !m_saf_st && !link_m_saf_st;

	always@(posedge clk_i)
	begin
		if(rst_i || !a_en) begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		end else begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
			a_pre_sta_allow[0]  <= servo_safe;                                          // beh1 home (allowed at limit: homing leaves the limit)
			a_pre_sta_allow[1]  <= servo_safe && !servo_limit_alarm;                    // beh2 zero
			a_pre_sta_allow[2]  <= home_completed && servo_safe && !servo_limit_alarm;  // beh3 pos move
			a_pre_sta_allow[3]  <= home_completed && servo_safe && !servo_limit_alarm;  // beh4 point move
			a_pre_sta_allow[4]  <= home_completed && servo_safe && !servo_limit_alarm;  // beh5 rel move
			a_pre_sta_allow[5]  <= home_completed && servo_safe && !servo_limit_alarm;  // beh6 vel move
			a_pre_sta_allow[6]  <= 1'b1;                                                // beh7 vel stop (always)
			a_pre_sta_allow[7]  <= 1'b1;                                                // beh8 vel read
			a_pre_sta_allow[8]  <= 1'b1;                                                // beh9 pos read
			a_pre_sta_allow[9]  <= 1'b1;                                                // beh10 status
			a_pre_sta_allow[14] <= servo_safe && !servo_limit_alarm;                    // beh15 torque move
			a_pre_sta_allow[15] <= 1'b1;                                                // beh16 torque read
		end
	end

	//hard alarm output: latched alarm OR live limit level
	always@(posedge clk_i)
	begin
		if(rst_i || !a_en)
			o_pre_sta_fail <= 1'b0;
		else
			o_pre_sta_fail <= servo_limit_alarm;
	end

	//post status: EXE completes directly (servo exec result confirmed by drive/PS via EtherCAT)
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
