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
		parameter		A_BHA_NUM		=	200
		,parameter		B_BHA_NUM		=	200
		,parameter		C_BHA_NUM		=	200
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
		,output	reg	[C_BHA_NUM-1:0]		c_pre_sta_allow
		,output	reg	[C_BHA_NUM-1:0]		c_post_sta_allow

//----------------------------------------------------- user logic begin -----------------------------------------------------//
		,input							action_busy
		,input							action_done
		,input							action_error

		,input							rctrl_drive_on
		,input							rctrl_drive_reset
		,input							rctrl_resume
		,input							rctrl_pause
		,input							rctrl_stop
		,input							rserv_dir
		,output	reg						b_clr_pause  	//clear PS pause request after beh 100 done
		,output	reg						b_clr_resume 	//clear PS resume request after beh 101 done
		,output	reg						b_clr_stop   	//clear PS stop request after beh 103 done
//----------------------------------------------------- user logic end -------------------------------------------------------//
    );

	//========================================================================================//
	//---------------------------------  Channel A check -------------------------------------//
	//========================================================================================//

	//limit rising-edge latch
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

	//home completed: beh1 passes post-check -> set; b_bhv_id==105 (soff) clears
	reg home_completed;
	always@(posedge clk_i) begin
		if(rst_i || !a_en)
			home_completed <= 1'b0;
		else if(a_bhv_id == 8'd1 && action_done && ~action_error)
			home_completed <= 1'b1;
		else if(b_bhv_id == 8'd105 && action_error)
			home_completed <= 1'b0;
	end

	//pre status (aligned with master ec_pul_axis behavior numbering):
	//  1=home  2=jog  3=move  20=jog[safe]  21=move[safe]  30=getpos
	wire device_safe = (~unit_st && ~m_st && ~m_saf_st && ~link_m_saf_st);
	wire axis_ok = !i_servo_notok && !i_emerge_stop_signal && !i_safe_status
	            && !unit_st && !m_st && !m_saf_st && !link_m_saf_st;
	always@(posedge clk_i)begin
		if(rst_i || !a_en)
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		else begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
			a_pre_sta_allow[0] <= axis_ok;                                           // beh1 home
			a_pre_sta_allow[1] <= home_completed && axis_ok && !servo_limit_alarm;   // beh2 jog
			a_pre_sta_allow[2] <= home_completed && axis_ok && !servo_limit_alarm;   // beh3 move
			a_pre_sta_allow[19] <= device_safe;                                      // beh20 jog[safe]
			a_pre_sta_allow[20] <= home_completed && device_safe;                    // beh21 move[safe]
			a_pre_sta_allow[29] <= 1'b1;                                              // beh30 getpos
		end
	end

	//post status (aligned with master ec_pul_axis)
	wire [A_BHA_NUM-1:0]	a_post_sta	;
	assign	a_post_sta[0 ] = (a_bhv_id == 1 )&&action_done&&(~action_error);
	assign	a_post_sta[1 ] = (a_bhv_id == 2 )&&action_done&&(~action_error);
	assign	a_post_sta[2 ] = (a_bhv_id == 3 )&&action_done&&(~action_error);
	assign	a_post_sta[19] = (a_bhv_id == 20)&&action_done&&(~action_error);
	assign	a_post_sta[20] = (a_bhv_id == 21)&&action_done&&(~action_error);
	assign	a_post_sta[29] = (a_bhv_id == 30);

	reg [7:0] a_bhv_id_d;
	always@(posedge clk_i) a_bhv_id_d <= a_bhv_id;

	always@(posedge clk_i)
	begin
		integer i;
		if(rst_i || !a_en || action_busy || (a_bhv_id != a_bhv_id_d))
			a_post_sta_allow <= {A_BHA_NUM{1'b0}};
		else begin
			for(i = 0; i < A_BHA_NUM; i = i + 1) begin
				if(a_post_sta[i])
					a_post_sta_allow[i] <= 1'b1;
			end
		end
	end

	//========================================================================================//
	//---------------------------------  Channel B check -------------------------------------//
	//========================================================================================//

	//pre status
	wire [B_BHA_NUM-1:0]	b_pre_sta	;
	assign	b_pre_sta[99 ] = rctrl_pause && ~rctrl_resume && ~rctrl_stop && ec_cha_st; // pause
	assign	b_pre_sta[100] = rctrl_pause && rctrl_resume && ec_cha_st; // resume
	assign	b_pre_sta[101] = rctrl_drive_reset;    // reset
	assign	b_pre_sta[102] = rctrl_pause && rctrl_stop && ec_cha_st;  // stop
	assign	b_pre_sta[103] = rctrl_drive_on;       // enable
	assign	b_pre_sta[104] = ~rctrl_drive_on;      // disable

	reg ec_chb_st_d1;
	always@(posedge clk_i) begin
		if(rst_i || !b_en) begin
			ec_chb_st_d1 <= 1'b0;
			b_clr_pause  <= 1'b0;
			b_clr_resume <= 1'b0;
			b_clr_stop   <= 1'b0;
		end else begin
			ec_chb_st_d1 <= ec_chb_st;
			if(!rctrl_pause)  b_clr_pause  <= 1'b0;
			if(!rctrl_resume) b_clr_resume <= 1'b0;
			if(!rctrl_stop)   b_clr_stop   <= 1'b0;
			if(ec_chb_st_d1 && ~ec_chb_st) begin
				if(b_bhv_id == 8'd100)
					b_clr_pause  <= 1'b1;
				else if(b_bhv_id == 8'd103) begin
					b_clr_pause  <= 1'b1;
					b_clr_stop   <= 1'b1;
				end
				else if(b_bhv_id == 8'd101) begin
					b_clr_pause  <= 1'b1;
					b_clr_resume <= 1'b1;
				end
			end
		end
	end

	reg [B_BHA_NUM-1:0]	b_executed;
	always@(posedge clk_i) begin
		if(rst_i || !b_en) begin
			b_executed <= {B_BHA_NUM{1'b0}};
		end else begin
			if(ec_chb_st && ~ec_chb_st_d1) begin
				if(b_bhv_id >= 8'd100 && b_bhv_id <= 8'd105)
					b_executed[b_bhv_id - 8'd1] <= 1'b1;
			end
			for(integer i = 0; i < B_BHA_NUM; i = i + 1) begin
				if(!b_pre_sta[i])
					b_executed[i] <= 1'b0;
			end
		end
	end

	always@(posedge clk_i)
	begin
		integer i;
		if(rst_i)
			b_pre_sta_allow <= {B_BHA_NUM{1'b0}};
		else if(!b_en)
			b_pre_sta_allow <= {B_BHA_NUM{1'b0}};
		else begin
			b_pre_sta_allow <= {B_BHA_NUM{1'b0}};
			for(i = 0; i < B_BHA_NUM; i = i + 1) begin
				if(b_pre_sta[i] && ~b_executed[i])
					b_pre_sta_allow[i] <= 1'b1;
			end
		end
	end

	//post status
	wire [B_BHA_NUM-1:0]	b_post_sta	;
	assign	b_post_sta[99 ] = (b_bhv_id == 100);
	assign	b_post_sta[100] = (b_bhv_id == 101);
	assign	b_post_sta[101] = (b_bhv_id == 102);
	assign	b_post_sta[102] = (b_bhv_id == 103);
	assign	b_post_sta[103] = (b_bhv_id == 104);
	assign	b_post_sta[104] = (b_bhv_id == 105);

	always@(posedge clk_i)
	begin
		integer i;
		if(rst_i)
			b_post_sta_allow <= {B_BHA_NUM{1'b0}};
		else if(!b_en)
			b_post_sta_allow <= {B_BHA_NUM{1'b0}};
		else begin
			b_post_sta_allow <= {B_BHA_NUM{1'b0}};
			for(i = 0; i < B_BHA_NUM; i = i + 1) begin
				if(b_post_sta[i])
					b_post_sta_allow[i] <= 1'b1;
			end
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