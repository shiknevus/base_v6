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

module pre_post_sta_check_dv300_485_modbus_rtu#(
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

		,input							a_exe_suc  //1=success 0=fail
	
		,input 		[7:0]				a_bhv_id
		,input 		[7:0]				b_bhv_id
		,input 		[7:0]				c_bhv_id
		
		,input							a_en    //通道A使能 ps-pl
		,input							b_en	//通道B使能 ps-pl
		,input							c_en	//通道C使能 ps-pl
		
		,input							ec_cha_st		
		,input							ec_chb_st       
		,input							ec_chc_st       
		
		,input 		[19:0] 				c_circle_time	//通道C时间周期
		,input 		[19:0]				task_time_cnt	//通道C当前计数值

		,output	reg	[A_BHA_NUM-1:0]		a_pre_sta_allow	
		,output	reg	[A_BHA_NUM-1:0]		a_post_sta_allow
		,output	reg	[B_BHA_NUM-1:0]		b_pre_sta_allow	
		,output	reg	[B_BHA_NUM-1:0]		b_post_sta_allow
		,output	reg	[C_BHA_NUM-1:0]		c_pre_sta_allow	
		,output	reg	[C_BHA_NUM-1:0]		c_post_sta_allow
    );

	//========================================================================================//
	//---------------------------------  Channel A check -------------------------------------//
	//========================================================================================//
	
	//pre status
	always@(posedge clk_i)
	begin
		if(rst_i || !a_en) begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		end
		else begin
			a_pre_sta_allow[0] <= 1'b1;
			a_pre_sta_allow[1] <= 1'b1;
			a_pre_sta_allow[2] <= 1'b1;
			a_pre_sta_allow[3] <= 1'b1;
			a_pre_sta_allow[4] <= 1'b1;
			a_pre_sta_allow[5] <= (!unit_st && !m_st && !m_saf_st && !link_m_saf_st);
			a_pre_sta_allow[6] <= (!unit_st && !m_st && !m_saf_st && !link_m_saf_st);
		end
	end
	
	//post status
	wire [A_BHA_NUM-1:0]	a_post_sta	;
//	wire [15:0] error_bit = signal_vld & (~di);
//	wire	err;
//	assign err  = |error_bit;

	
	assign	a_post_sta[0 ] = (a_bhv_id == 1 )&& a_exe_suc;
	assign	a_post_sta[1 ] = (a_bhv_id == 2 )&& a_exe_suc;
	assign	a_post_sta[2 ] = (a_bhv_id == 3 )&& a_exe_suc;
	assign	a_post_sta[3 ] = (a_bhv_id == 4 )&& a_exe_suc;
	assign	a_post_sta[4 ] = (a_bhv_id == 5 )&& a_exe_suc;
	assign	a_post_sta[5 ] = (a_bhv_id == 6 )&& a_exe_suc;
	assign	a_post_sta[6 ] = (a_bhv_id == 7 )&& a_exe_suc;
	
	always@(posedge clk_i) 
	begin
		if(rst_i || !a_en)
			a_post_sta_allow <= {A_BHA_NUM{1'b0}};
		else
			a_post_sta_allow <= a_post_sta;
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
