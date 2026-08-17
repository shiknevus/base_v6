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
		
		,input		[2:0]				di_i
		
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
	always@(posedge clk_i)
	begin
		if(rst_i || !a_en) begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		end else begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b1}};
		end
	end

	
	//post status
	wire [A_BHA_NUM-1:0]	a_post_sta	;
	
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
		else if(a_en == 0)
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
		else if(a_en == 0)
			flag_di2_exit <= 1'b0;
		else if(di2_r == {1'b1,1'b0})
			flag_di2_exit <= 1'b1;
		else 
			flag_di2_exit <= flag_di2_exit;
	end

	assign	a_post_sta[0 ] = (a_bhv_id == 1 ) && (di_i[1:0] ==2'b01);
	assign	a_post_sta[1 ] = (a_bhv_id == 2 ) && (di_i[1:0] ==2'b10);
	assign	a_post_sta[2 ] = (a_bhv_id == 3 ) ;
	assign	a_post_sta[3 ] = (a_bhv_id == 4 ) && (di_i[1:0] ==2'b01);
	assign	a_post_sta[4 ] = (a_bhv_id == 5 ) && (di_i[1:0] ==2'b10);
	assign	a_post_sta[5 ] = (a_bhv_id == 6 ) && (di_i[1:0] ==2'b00) && flag_di2_exit;
	assign	a_post_sta[6 ] = (a_bhv_id == 7 ) && (di_i[1:0] ==2'b00) && flag_di1_exit;
	assign	a_post_sta[7 ] = (a_bhv_id == 8 ) && (di_i[2] ==1);
	assign	a_post_sta[8 ] = (a_bhv_id == 9 ) && (di_i[2] ==0);
	assign	a_post_sta[9 ] = (a_bhv_id == 10) && (di_i[1:0] ==2'b01);
	assign	a_post_sta[10] = (a_bhv_id == 11) && (di_i[1:0] ==2'b10);
	assign	a_post_sta[11] = (a_bhv_id == 12) && (di_i[1:0] ==2'b00) && flag_di2_exit;
	assign	a_post_sta[12] = (a_bhv_id == 13) && (di_i[1:0] ==2'b00) && flag_di1_exit;


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
