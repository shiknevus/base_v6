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

module pre_post_sta_check_lanj_washer#(
		parameter		A_BHA_NUM	=	7
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
	wire auto_manual = (m_wk_mod == 4'd3);		//set_work_mode == 3: manual
	wire pre_ok = !auto_manual  && !unit_st && !m_st && !m_saf_st && !link_m_saf_st;

	always@(posedge clk_i)
	begin
		if(rst_i || !a_en)
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		else
			a_pre_sta_allow <= {A_BHA_NUM{pre_ok}};
	end

	//post status: always pass (execution result is confirmed by PS via irq30/40 ack)
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
