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


//

module pre_post_sta_check_sys_sf#(
		parameter		A_BHA_NUM		=	2      	
		,parameter		B_BHA_NUM		=	6  
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

		//control cabinet button
		,input 							i_start
		,input 							i_stop  
		,input 							i_rst  	
		,input							i_estop
		,input							i_manul	
		,input							i_auto	
		
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
		end else if(!unit_st && !m_st && !m_saf_st && !link_m_saf_st) begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b1}};
		end else begin
			a_pre_sta_allow <= {A_BHA_NUM{1'b0}};
		end
	end

	//post status
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

	//pre status
	
	reg		ec_chb_st_r;
	reg		negedge_ec_chb_st;
	
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
			negedge_ec_chb_st <= 1'b0;
		else if({ec_chb_st_r,ec_chb_st} == 2'b10)
			negedge_ec_chb_st <= 1'b1;
		else
			negedge_ec_chb_st <= 1'b0;
	end
	
	//button
	reg	[1:0]		ri_start 		;
	reg	[1:0]		ri_stop  		;
	reg	[1:0]		ri_rst   		;
	reg [1:0]		ri_estop		;
	reg [1:0]		ri_manul		;	
	reg [1:0]		ri_auto			;

	reg 			negedge_i_start ;
	reg 			negedge_i_stop  ;
	reg 			negedge_i_rst   ;
	reg				edge_i_estop	;
	reg				edge_i_manul	;
	reg				edge_i_auto		;
	
	//Detect the rising/falling edge of the input signal
	always@(posedge clk_i)
	begin
        if(rst_i)begin
			ri_start 	<= 2'b00;
			ri_stop  	<= 2'b00;
			ri_rst   	<= 2'b00;
			ri_estop    <= 2'b00;
			ri_manul    <= 2'b00;
			ri_auto	    <= 2'b00;
        end else begin
			ri_start 	<= {ri_start[0],i_start	};
		    ri_stop  	<= {ri_stop [0],i_stop 	};
		    ri_rst   	<= {ri_rst  [0],i_rst  	};
			ri_estop    <= {ri_estop[0],ri_estop};
			ri_manul    <= {ri_manul[0],ri_manul};
			ri_auto	    <= {ri_auto	[0],ri_auto	};
		end
    end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			negedge_i_start <= 1'b0;
		else if(ri_start == 2'b10)
			negedge_i_start <= 1'b1;
		else
			negedge_i_start <= 1'b0;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			negedge_i_stop <= 1'b0;
		else if(ri_stop == 2'b10)
			negedge_i_stop <= 1'b1;
		else
			negedge_i_stop <= 1'b0;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			negedge_i_rst <= 1'b0;
		else if(ri_rst == 2'b10)
			negedge_i_rst <= 1'b1;
		else
			negedge_i_rst <= 1'b0;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			edge_i_estop <= 1'b0;
		else if(ri_estop == 2'b10 || ri_estop == 2'b01)
			edge_i_estop <= 1'b1;
		else
			edge_i_estop <= 1'b0;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			edge_i_manul <= 1'b0;
		else if(ri_manul == 2'b10 || ri_manul == 2'b01)
			edge_i_manul <= 1'b1;
		else
			edge_i_manul <= 1'b0;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			edge_i_auto <= 1'b0;
		else if(ri_auto == 2'b10 || ri_auto == 2'b01)
			edge_i_auto <= 1'b1;
		else
			edge_i_auto <= 1'b0;
	end
	
	//--------------------------------------------------------------------------------
	
	reg		b_pre_sta_allow_act100;
	reg		b_pre_sta_allow_act101;
	reg		b_pre_sta_allow_act102;
	reg		b_pre_sta_allow_act103;
	reg		b_pre_sta_allow_act104;
	reg		b_pre_sta_allow_act105;	//no
	reg		b_pre_sta_allow_act106;
	reg		b_pre_sta_allow_act107;
	
	
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			b_pre_sta_allow_act100 <= 1'b0;
		else if(negedge_i_start)
			b_pre_sta_allow_act100 <= 1'b1;
		else if(negedge_ec_chb_st)
			b_pre_sta_allow_act100 <= 1'b0;
		else
			b_pre_sta_allow_act100 <= b_pre_sta_allow_act100;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			b_pre_sta_allow_act101 <= 1'b0;
		else if(negedge_i_stop)
			b_pre_sta_allow_act101 <= 1'b1;
		else if(negedge_ec_chb_st)
			b_pre_sta_allow_act101 <= 1'b0;
		else
			b_pre_sta_allow_act101 <= b_pre_sta_allow_act101;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			b_pre_sta_allow_act102 <= 1'b0;
		else if(negedge_i_rst)
			b_pre_sta_allow_act102 <= 1'b1;
		else if(negedge_ec_chb_st)
			b_pre_sta_allow_act102 <= 1'b0;
		else
			b_pre_sta_allow_act102 <= b_pre_sta_allow_act102;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			b_pre_sta_allow_act103 <= 1'b0;
		else if(edge_i_estop && i_estop)
			b_pre_sta_allow_act103 <= 1'b1;
		else if(negedge_ec_chb_st)
			b_pre_sta_allow_act103 <= 1'b0;
		else
			b_pre_sta_allow_act103 <= b_pre_sta_allow_act103;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			b_pre_sta_allow_act104 <= 1'b0;
		else if(edge_i_manul && !i_manul)
			b_pre_sta_allow_act104 <= 1'b1;
		else if(negedge_ec_chb_st)
			b_pre_sta_allow_act104 <= 1'b0;
		else
			b_pre_sta_allow_act104 <= b_pre_sta_allow_act104;
	end
	
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			b_pre_sta_allow_act106 <= 1'b0;
		else if(edge_i_auto && !i_auto)
			b_pre_sta_allow_act106 <= 1'b1;
		else if(negedge_ec_chb_st)
			b_pre_sta_allow_act106 <= 1'b0;
		else
			b_pre_sta_allow_act106 <= b_pre_sta_allow_act106;
	end
	
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			b_pre_sta_allow_act107 <= 1'b0;
		else if(edge_i_estop && !i_estop)
			b_pre_sta_allow_act107 <= 1'b1;
		else if(negedge_ec_chb_st)
			b_pre_sta_allow_act107 <= 1'b0;
		else
			b_pre_sta_allow_act107 <= b_pre_sta_allow_act107;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			b_pre_sta_allow_act105 <= 0;
		else
			b_pre_sta_allow_act105 <= 1;
	end
	
	always@(posedge i_clk)
	begin
		if(i_rst)
			b_pre_sta_allow <= {B_BHA_NUM{1'b0}};
		else if(b_en)
			b_pre_sta_allow <= {b_pre_sta_allow_act100,b_pre_sta_allow_act101,b_pre_sta_allow_act102,b_pre_sta_allow_act103,b_pre_sta_allow_act104,b_pre_sta_allow_act105,b_pre_sta_allow_act106,b_pre_sta_allow_act107};
		else
			b_pre_sta_allow <= {B_BHA_NUM{1'b0}};
	end
	
	
	//post status
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
