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
		parameter		A_BHA_NUM		=	1
		,parameter		B_BHA_NUM		=	1
		,parameter		C_BHA_NUM		=	1
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
		,output	reg	[C_BHA_NUM-1:0]		c_pre_sta_allow	
		,output	reg	[C_BHA_NUM-1:0]		c_post_sta_allow

//----------------------------------------------------- user logic begin -----------------------------------------------------//
		,input							i_servo_limf
		,input							i_servo_limb
		,input							i_servo_zero
//----------------------------------------------------- user logic end -------------------------------------------------------//
    );

	//========================================================================================//
	//---------------------------------  Channel A check -------------------------------------//
	//========================================================================================//
	
	//pre status
	wire device_safe;
	assign device_safe =(~unit_st && ~m_st && ~m_saf_st && ~link_m_saf_st);
	wire axis_safe;
	assign axis_safe = (~i_servo_limf && ~i_servo_limb );
	wire [A_BHA_NUM-1:0]	a_pre_sta	;

	assign	a_pre_sta[0 ] = (a_bhv_id == 1 );    // HOME: always allowed
	assign	a_pre_sta[1 ] = (a_bhv_id == 2 ) && axis_safe;
	assign	a_pre_sta[2 ] = (a_bhv_id == 3 ) && axis_safe;
	assign	a_pre_sta[19] = (a_bhv_id == 20) && axis_safe && device_safe;//[safe]
	assign	a_pre_sta[20] = (a_bhv_id == 21) && axis_safe && device_safe;//[safe]
	assign	a_pre_sta[29] = (a_bhv_id == 30);   // GETPOS: always allowed

	always@(posedge clk_i)
	begin
		integer i;
		if(rst_i && !a_en)
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		else begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
			for(i = 0; i < A_BHA_NUM; i = i + 1) begin
				if(a_pre_sta[i])
					a_pre_sta_allow[i] <= 1'b1;
			end
		end
	end
	
	//post status
	wire [A_BHA_NUM-1:0]	a_post_sta	;

	assign	a_post_sta[0 ] = (a_bhv_id == 1 );
	assign	a_post_sta[1 ] = (a_bhv_id == 2 );
	assign	a_post_sta[2 ] = (a_bhv_id == 3 );
	assign	a_post_sta[19] = (a_bhv_id == 20);
	assign	a_post_sta[20] = (a_bhv_id == 21);
	assign	a_post_sta[29] = (a_bhv_id == 30);

	reg [7:0] a_bhv_id_d;
	always@(posedge clk_i) a_bhv_id_d <= a_bhv_id;

	always@(posedge clk_i)
	begin
		integer i;
		if(rst_i || !a_en )
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
