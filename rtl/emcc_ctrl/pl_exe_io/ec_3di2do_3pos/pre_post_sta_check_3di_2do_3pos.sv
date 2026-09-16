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


module pre_post_sta_check_3di_2do_3pos#(
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
	
	localparam	A_BHA_NUM1 = A_BHA_NUM - 5;
	
	always@(posedge clk_i)
	begin
		if(rst_i || !a_en)
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		else if(!unit_st && !m_st && !m_saf_st && !link_m_saf_st)
			a_pre_sta_allow <= {A_BHA_NUM{1'b1}};
		else
			a_pre_sta_allow <= {5'b00000,{A_BHA_NUM1{1'b1}}};
	end

	
	//post status
	wire	[A_BHA_NUM-1:0]	r_a_post_sta_allow;

	assign	r_a_post_sta_allow[0 ] = (a_bhv_id == 1 ) && (di_i ==3'b001);//open
	assign	r_a_post_sta_allow[1 ] = (a_bhv_id == 2 ) && (di_i ==3'b010);//close pos1
	assign	r_a_post_sta_allow[2 ] = (a_bhv_id == 3 ) && (di_i ==3'b100);//close pos2
	assign	r_a_post_sta_allow[3 ] = (a_bhv_id == 4 ) ;
	assign	r_a_post_sta_allow[4 ] = (a_bhv_id == 5 ) && (di_i ==3'b001);
	assign	r_a_post_sta_allow[5 ] = (a_bhv_id == 6 ) && (di_i ==3'b010);
	assign	r_a_post_sta_allow[6 ] = (a_bhv_id == 7 ) && (di_i ==3'b100);
	assign	r_a_post_sta_allow[7 ] = (a_bhv_id == 8 )	;
	assign	r_a_post_sta_allow[8 ] = (a_bhv_id == 9 )	;
	assign	r_a_post_sta_allow[9 ] = (a_bhv_id == 10) && (di_i ==3'b001);
	assign	r_a_post_sta_allow[10] = (a_bhv_id == 11) && (di_i ==3'b010);
	assign	r_a_post_sta_allow[11] = (a_bhv_id == 12) && (di_i ==3'b100);
	assign	r_a_post_sta_allow[12] = (a_bhv_id == 13)	;
	assign	r_a_post_sta_allow[13] = (a_bhv_id == 14)	;

	always@(posedge clk_i)
	begin
		a_post_sta_allow <= r_a_post_sta_allow;
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
