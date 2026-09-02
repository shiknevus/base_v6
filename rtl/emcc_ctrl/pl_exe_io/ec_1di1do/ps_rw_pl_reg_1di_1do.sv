`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: cgliu
// 
// Create Date: 2026/06/30 11:49:26
// Design Name: 
// Module Name: ps_rw_pl_reg
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
`include"reg_addr_pl.vh"
module ps_rw_pl_reg_1di_1do#(
    parameter  						REG_SPACE_BIAS 	= 	200	,
    parameter  						REG_SPACE_SIZE 	= 	512	
)(
	input							clk_i			
	,input							rst_i			
	
	,input  		            	i_st_wr_en		//ps rw bus
	,input  		 	[19:0]     	i_st_wr_addr	
	,input  		 	[31:0]     	i_st_wr_data	
	,input  		            	i_st_rd_en  	
    ,input  		 	[19:0]     	i_st_rd_addr	
    ,output 	reg  	[31:0]     	o_st_rd_data	
	,output 	reg             	o_st_rd_vld 	

	,output		reg 	 			rst_en_n       	//General parameters
	,output		reg 	[13:0]	 	ec_id          
	,output		reg 	[9:0]	 	sc_id			
	,output		reg 	[3:0]	 	chl_priority	
	,output		reg 	[7:0]	 	unit_id      	
	,output		reg 	[3:0]	 	unit_ectrl     
	,output		reg 	[3:0]	 	unit_st        
	,output		reg 	[7:0]	 	m_id         	
	,output		reg 	[3:0]	 	m_ectrl        
	,output		reg 	[3:0]	 	m_st           
	,output		reg 	[3:0]	 	m_wk_mod       
	,output		reg 	 			m_saf_st       
	,output		reg 	 			link_m_saf_st  
	//,output		reg		[31:0]		bhv_en
	
	,output		reg 	[31:0]	 	a_task_id      	
	,output		reg 	[31:0]	 	a_task_bhv_id	
	,output		reg 	 			a_en				
	,output		reg 	[19:0]	 	a_bhv_ot        	
	,output		reg 	[31:0]	 	a_tsc_result_rpt	
	,output		reg 	 			a_tsc_result_vld	
	,output		reg 	[7:0]	 	a_bhv_id       	
	,output		reg 	 			a_bhv_vld
	
	,output		reg 	 			b_en					
	,output		reg 	[19:0]	 	b_bhv_ot 		
	,output		reg 	[31:0]	 	b_tsc_result_rpt	
	,output		reg 	 			b_tsc_result_vld
	
	,output		reg 	 			c_en				
	,output		reg 	[19:0]	 	c_bhv_ot			
	,output		reg 	[31:0]	 	c_tsc_result_rpt	
	,output		reg 	 			c_tsc_result_vld	
	,output		reg 	[19:0]	 	c_bhv_gap_crl     
 	
	//,output		reg 	[31:0]	 	param1			
	//,output		reg 	[31:0]	 	param2			
	//,output		reg 	[31:0]		param3			
	//,output		reg 	[31:0]		param4			
	//,output		reg 	[31:0]		param5			
	//,output		reg 	[19:0]		param6			
	//,output		reg 	[19:0]		param7			
	//,output		reg 	[19:0]		param8			
	//,output		reg 	[19:0]		param9			
	//,output		reg 	[19:0]		param10			
	//,output		reg 	[19:0]		param11			
	//,output		reg 	[19:0]		param12			
	//,output		reg 	[19:0]		param13			
	//,output		reg 	[19:0]		param14			
	//,output		reg 	[19:0]		param15			
	//,output		reg 	[7:0]		param16			
	//,output		reg 	[7:0]		param17			
	//,output		reg 	[7:0]		param18			
	//,output		reg 	[7:0]		param19			
	//,output		reg 	[7:0]		param20			
	//,output		reg 	[7:0]		param21			
	//,output		reg 	[7:0]		param22			
	//,output		reg 	[7:0]		param23			
	//,output		reg 	[7:0]		param24			
	//,output		reg 	[7:0]		param25			
	//,output		reg 				param26			
	//,output		reg 				param27			
	//,output		reg 				param28			
	//,output		reg 				param29			
	//,output		reg 				param30		
	//,output		reg 	[31:0]		param31	
	//,output		reg 	[31:0]		param32	
	//,output		reg 	[31:0]		param33	
	//,output		reg 	[31:0]		param34	
	//,output		reg 	[31:0]		param35	
	//,output		reg 	[31:0]		param36	
	//,output		reg 	[31:0]		param37	
	//,output		reg 	[31:0]		param38	
	//,output		reg 	[31:0]		param39	
	//,output		reg 	[31:0]		param40	
	,input 				[31:0]		irq_reg1	
	,input 				[31:0]		irq_reg2	

	,input 							a_st 
	,input 				[7:0]		a_alm_num 
	,input 				[7:0]		a_tsc_id   

	,input 							b_st 
	,input 				[7:0]		b_alm_num 
	,input 				[7:0]		b_tsc_id   
	,input 				[7:0]		b_bhv_id  

	,input 							c_st 
	,input 				[7:0]		c_alm_num 
	,input 				[7:0]		c_tsc_id   
	,input 				[7:0]		c_bhv_id    

	//,input 				[31:0]		param51 
	//,input 				[31:0]		param52 
	//,input 				[31:0]		param53   
	//,input 				[31:0]		param54   
	//,input 				[31:0]		param55   
	//,input 				[19:0]		param56   
	//,input 				[19:0]		param57   
	//,input 				[19:0]		param58   
	//,input 				[19:0]		param59   
	//,input 				[19:0]		param60   
	//,input 				[7:0]		param61   
	//,input 				[7:0]		param62   
	//,input 				[7:0]		param63   
	//,input 				[7:0]		param64   
	//,input 				[7:0]		param65   
	,input 							param66   
	,input 							param67   
	//,input 							param68   
	//,input 							param69   
	//,input 							param70   
	,input 				[31:0]		debug_reg1
	,input 				[31:0]		debug_reg2
	//,input 				[31:0]		debug_reg3
	//,input 				[31:0]		debug_reg4
	//,input 				[31:0]		debug_reg5
	);

	reg  		rd_en_d1;
	reg  		rd_en_d2;
	wire 		rd_space_select;
	wire 		wr_space_select;
	wire 		wr_task_vld;
	reg  [8:0]  rd_addr_d1;
	reg  [8:0]  rd_addr_d2;
	wire [8:0]  rd_task_addr;
	wire [8:0]  wr_task_addr;
	
	//================================================================================================//
	//---------------------------------Component address is selected --------------------------------//
	//================================================================================================//

	assign  rd_space_select = ((i_st_rd_addr >= REG_SPACE_BIAS) & (i_st_rd_addr < (REG_SPACE_BIAS + REG_SPACE_SIZE))) ? 1'b1 : 1'b0;
	assign  wr_space_select = ((i_st_wr_addr >= REG_SPACE_BIAS) & (i_st_wr_addr < (REG_SPACE_BIAS + REG_SPACE_SIZE))) ? 1'b1 : 1'b0;
	assign  rd_task_addr 	= i_st_rd_addr - REG_SPACE_BIAS;
	assign  wr_task_addr 	= i_st_wr_addr - REG_SPACE_BIAS;
	assign  wr_task_vld  	= wr_space_select & i_st_wr_en;
   
	always @(posedge clk_i)begin
	if(rst_i)begin
		rd_en_d1  <= 1'd0;
		rd_en_d2  <= 1'd0;
		o_st_rd_vld  <= 1'd0;
	end else begin
		rd_en_d1  <= i_st_rd_en & rd_space_select;
		rd_en_d2  <= rd_en_d1;
		o_st_rd_vld  <= rd_en_d2;
	end
	end

	always @(posedge clk_i)begin
	if(rst_i)begin
		rd_addr_d1  <= 20'd0;
		rd_addr_d2  <= 20'd0;
	end else begin
		rd_addr_d1 <= rd_task_addr;
		rd_addr_d2 <= rd_addr_d1;
	end
	end
	
	//========================================================================================================================//
   //--------------------------------------------- PS writes to PL register------------------------------------------------//
   //========================================================================================================================//

	always@(posedge clk_i) begin
		if(rst_i) begin
			rst_en_n        	<=	1'b0     		;
			ec_id          		<=	14'd0	 		; 
			sc_id				<=	10'd0	 		;
			chl_priority		<=	4'd0			;
			unit_id      		<=	8'h00	 		; 
			unit_ectrl     		<=	4'h0     		;
			unit_st        		<=	4'h0     		;
			m_id         		<=	8'h00	 		;
			m_ectrl        		<=	4'h0     		; 
			m_st           		<=	4'h0     		;
			m_wk_mod       		<=	4'h0     		;
			m_saf_st       		<=	1'b0     		;
			link_m_saf_st  		<=	1'b0     		;
			//bhv_en				<=	32'd0			;
			
			a_task_id      		<=	32'd0		  	;
			a_task_bhv_id		<=	32'd0		  	;
			a_en				<=	1'b1			;
			a_bhv_ot        	<=	20'd0		  	;
			a_tsc_result_rpt	<=	32'd0		  	;
			a_tsc_result_vld	<= 	1'b0			;	
			a_bhv_id       		<=	8'd0		   	;
			a_bhv_vld			<=  1'b0			;
			
			b_en				<=	1'b1		   	;
			b_bhv_ot 			<= 	20'd0		  	;
			b_tsc_result_rpt	<=	32'd0		   	;
			b_tsc_result_vld	<= 	1'b0			;	
			
			c_en				<=	1'b1		   	;
			c_bhv_ot 			<= 	20'd0		   	;
			c_tsc_result_rpt	<=	32'd0		   	;
			c_tsc_result_vld	<= 	1'b0			;	
			c_bhv_gap_crl      	<=	20'd0		   	;

			//param1				<=	32'd0	  	;
			//param2				<=	32'd0	  	;
			//param3				<=	32'd0	  	;
			//param4				<=	32'd0	  	;
			//param5				<=	32'd0   	;
			//param6				<=	20'd0   	;
			//param7				<=	20'd0   	;
			//param8				<=	20'd0   	;
			//param9				<=	20'd0   	;
			//param10				<=	20'd0   	;
			//param11				<=	20'd0   	;
			//param12				<=	20'd0   	;
			//param13				<=	20'd0   	;
			//param14				<=	20'd0   	;
			//param15				<=	20'd0   	;
			//param16				<=	8'd0	   	;
			//param17				<=	8'd0	   	;
			//param18				<=	8'd0	   	;
			//param19				<=	8'd0	   	;
			//param20				<=	8'd0	   	;
			//param21				<=	8'd0	   	;
			//param22				<=	8'd0	   	;
			//param23				<=	8'd0	   	;
			//param24				<=	8'd0	   	;
			//param25				<=	8'd0	   	;
			//param26				<=	1'd0	   	;
			//param27				<=	1'd0	   	;
			//param28				<=	1'd0	   	;
			//param29				<=	1'd0	   	;
			//param30				<=	1'd0	   	;
			//param31             <=	32'd0		;
			//param32             <=	32'd0		;
			//param33             <=	32'd0		;
			//param34             <=	32'd0		;
			//param35             <=	32'd0		;
			//param36             <=	32'd0		;
			//param37             <=	32'd0		;
			//param38             <=	32'd0		;
			//param39             <=	32'd0		;
			//param40             <=	32'd0		;
		end else begin
			rst_en_n	    <=	(wr_task_vld && wr_task_addr == `RST_EN        	) ? i_st_wr_data[0] 	: rst_en_n      ;
			ec_id          	<=	(wr_task_vld && wr_task_addr == `EC_ID         	) ? i_st_wr_data[13:0] 	: ec_id         ;
			sc_id			<=	(wr_task_vld && wr_task_addr == `SC_ID		 	) ? i_st_wr_data[9:0] 	: sc_id			;
			chl_priority	<= 	(wr_task_vld && wr_task_addr == `BHV_PRIORITY	) ? i_st_wr_data[3:0] 	: chl_priority	;
			unit_id      	<=	(wr_task_vld && wr_task_addr == `UNIT_ID       	) ? i_st_wr_data[7:0] 	: unit_id      	;
			unit_ectrl     	<=	(wr_task_vld && wr_task_addr == `UNIT_ECTRL    	) ? i_st_wr_data[3:0] 	: unit_ectrl   	;
			unit_st        	<=	(wr_task_vld && wr_task_addr == `UNIT_ST       	) ? i_st_wr_data[3:0] 	: unit_st       ;
			m_id         	<=	(wr_task_vld && wr_task_addr == `M_ID          	) ? i_st_wr_data[7:0] 	: m_id         	;
			m_ectrl        	<=	(wr_task_vld && wr_task_addr == `M_ECTRL       	) ? i_st_wr_data[3:0] 	: m_ectrl       ;
			m_st           	<=	(wr_task_vld && wr_task_addr == `M_ST          	) ? i_st_wr_data[3:0] 	: m_st          ;
			m_wk_mod       	<=	(wr_task_vld && wr_task_addr == `M_WK_MOD      	) ? i_st_wr_data[3:0] 	: m_wk_mod      ;
			m_saf_st       	<=	(wr_task_vld && wr_task_addr == `M_SAF_ST      	) ? i_st_wr_data[0] 	: m_saf_st      ;
			link_m_saf_st  	<=	(wr_task_vld && wr_task_addr == `LINK_M_SAF_ST 	) ? i_st_wr_data[0] 	: link_m_saf_st ;
			//bhv_en  		<=	(wr_task_vld && wr_task_addr == `BHV_EN	 		) ? i_st_wr_data	 	: bhv_en 		;
			
			a_task_id      	<=	(wr_task_vld && wr_task_addr == `A_TASK_ID     	) ? i_st_wr_data	 	: a_task_id     ;
			a_task_bhv_id   <=	(wr_task_vld && wr_task_addr == `A_TASK_BHV_ID  ) ? i_st_wr_data	 	: a_task_bhv_id ;
			a_en			<=	(wr_task_vld && wr_task_addr == `A_EN			) ? i_st_wr_data[0] 	: a_en  		;
			a_bhv_ot        <=	(wr_task_vld && wr_task_addr == `A_TX_OT       	) ? i_st_wr_data[19:0] 	: a_bhv_ot      ;
			a_tsc_result_rpt<=	(wr_task_vld && wr_task_addr == `A_TX_RSULT_RPT	) ? i_st_wr_data 		: a_tsc_result_rpt;
			a_tsc_result_vld<=	(wr_task_vld && wr_task_addr == `A_TX_RSULT_RPT	) ? 1'b1: 1'b0							;
			a_bhv_id       	<=	(wr_task_vld && wr_task_addr == `A_BHV_ID      	) ? i_st_wr_data[7:0]	: a_bhv_id      ;
			a_bhv_vld       <=	(wr_task_vld && wr_task_addr == `A_BHV_ID      	) ? 1'b1: 1'b0;
			
			b_en			<=	(wr_task_vld && wr_task_addr == `B_EN			) ? i_st_wr_data[0] 	: b_en			 ;
			b_bhv_ot		<=	(wr_task_vld && wr_task_addr == `B_TX_OT		) ? i_st_wr_data[19:0] 	: b_bhv_ot		 ;
			b_tsc_result_rpt<=	(wr_task_vld && wr_task_addr == `B_TX_RSULT_RPT	) ? i_st_wr_data 		: b_tsc_result_rpt;
			b_tsc_result_vld<=	(wr_task_vld && wr_task_addr == `B_TX_RSULT_RPT	) ? 1'b1: 1'b0;
			
			c_en			<=	(wr_task_vld && wr_task_addr == `C_EN			) ? i_st_wr_data[0] 	: c_en			 ;
			c_bhv_ot		<=	(wr_task_vld && wr_task_addr == `C_TX_OT		) ? i_st_wr_data[19:0] 	: c_bhv_ot		 ;
			c_tsc_result_rpt<=	(wr_task_vld && wr_task_addr == `C_TX_RSULT_RPT	) ? i_st_wr_data 		: c_tsc_result_rpt;
			c_tsc_result_vld<=	(wr_task_vld && wr_task_addr == `C_TX_RSULT_RPT	) ? 1'b1: 1'b0							 ;
			c_bhv_gap_crl   <=	(wr_task_vld && wr_task_addr == `C_GAP_CRL     	) ? i_st_wr_data[19:0] 	: c_bhv_gap_crl	;
			
			//param1			<=	(wr_task_vld && wr_task_addr == `PARAM1			) ? i_st_wr_data 		: param1	;
			//param2			<=	(wr_task_vld && wr_task_addr == `PARAM2			) ? i_st_wr_data 		: param2	;
			//param3			<=	(wr_task_vld && wr_task_addr == `PARAM3			) ? i_st_wr_data 		: param3	;
			//param4			<=	(wr_task_vld && wr_task_addr == `PARAM4			) ? i_st_wr_data 		: param4	;
			//param5			<=	(wr_task_vld && wr_task_addr == `PARAM5			) ? i_st_wr_data 		: param5	;
			//param6			<=	(wr_task_vld && wr_task_addr == `PARAM6			) ? i_st_wr_data[19:0]	: param6	;
			//param7			<=	(wr_task_vld && wr_task_addr == `PARAM7			) ? i_st_wr_data[19:0]	: param7	;
			//param8			<=	(wr_task_vld && wr_task_addr == `PARAM8			) ? i_st_wr_data[19:0]	: param8	;
			//param9			<=	(wr_task_vld && wr_task_addr == `PARAM9			) ? i_st_wr_data[19:0]	: param9	;
			//param10			<=	(wr_task_vld && wr_task_addr == `PARAM10		) ? i_st_wr_data[19:0]	: param10	;
			//param11			<=	(wr_task_vld && wr_task_addr == `PARAM11		) ? i_st_wr_data[19:0]	: param11	;
			//param12			<=	(wr_task_vld && wr_task_addr == `PARAM12		) ? i_st_wr_data[19:0]	: param12	;
			//param13			<=	(wr_task_vld && wr_task_addr == `PARAM13		) ? i_st_wr_data[19:0]	: param13	;
			//param14			<=	(wr_task_vld && wr_task_addr == `PARAM14		) ? i_st_wr_data[19:0]	: param14	;
			//param15			<=	(wr_task_vld && wr_task_addr == `PARAM15		) ? i_st_wr_data[19:0]	: param15	;
			//param16			<=	(wr_task_vld && wr_task_addr == `PARAM16		) ? i_st_wr_data[7:0] 	: param16	;
			//param17			<=	(wr_task_vld && wr_task_addr == `PARAM17		) ? i_st_wr_data[7:0] 	: param17	;
			//param18			<=	(wr_task_vld && wr_task_addr == `PARAM18		) ? i_st_wr_data[7:0] 	: param18	;
			//param19			<=	(wr_task_vld && wr_task_addr == `PARAM19		) ? i_st_wr_data[7:0] 	: param19	;
			//param20			<=	(wr_task_vld && wr_task_addr == `PARAM20		) ? i_st_wr_data[7:0] 	: param20	;
			//param21			<=	(wr_task_vld && wr_task_addr == `PARAM21		) ? i_st_wr_data[7:0] 	: param21	;
			//param22			<=	(wr_task_vld && wr_task_addr == `PARAM22		) ? i_st_wr_data[7:0] 	: param22	;
			//param23			<=	(wr_task_vld && wr_task_addr == `PARAM23		) ? i_st_wr_data[7:0] 	: param23	;
			//param24			<=	(wr_task_vld && wr_task_addr == `PARAM24		) ? i_st_wr_data[7:0] 	: param24	;
			//param25			<=	(wr_task_vld && wr_task_addr == `PARAM25		) ? i_st_wr_data[7:0] 	: param25	;
			//param26			<=	(wr_task_vld && wr_task_addr == `PARAM26		) ? i_st_wr_data[0]		: param26	;
			//param27			<=	(wr_task_vld && wr_task_addr == `PARAM27		) ? i_st_wr_data[0]		: param27	;
			//param28			<=	(wr_task_vld && wr_task_addr == `PARAM28		) ? i_st_wr_data[0]		: param28	;
			//param29			<=	(wr_task_vld && wr_task_addr == `PARAM29		) ? i_st_wr_data[0]		: param29	;
			//param30			<=	(wr_task_vld && wr_task_addr == `PARAM30		) ? i_st_wr_data[0]		: param30	;
			//param31         <= 	(wr_task_vld && wr_task_addr == `PARAM31		) ? i_st_wr_data		: param31	;
			//param32         <= 	(wr_task_vld && wr_task_addr == `PARAM32		) ? i_st_wr_data		: param32	;
			//param33         <= 	(wr_task_vld && wr_task_addr == `PARAM33		) ? i_st_wr_data		: param33	;
			//param34         <= 	(wr_task_vld && wr_task_addr == `PARAM34		) ? i_st_wr_data		: param34	;
			//param35         <= 	(wr_task_vld && wr_task_addr == `PARAM35		) ? i_st_wr_data		: param35	;
			//param36         <= 	(wr_task_vld && wr_task_addr == `PARAM36		) ? i_st_wr_data		: param36	;
			//param37         <= 	(wr_task_vld && wr_task_addr == `PARAM37		) ? i_st_wr_data		: param37	;
			//param38         <= 	(wr_task_vld && wr_task_addr == `PARAM38		) ? i_st_wr_data		: param38	;
			//param39         <= 	(wr_task_vld && wr_task_addr == `PARAM39		) ? i_st_wr_data		: param39	;
			//param40         <= 	(wr_task_vld && wr_task_addr == `PARAM40		) ? i_st_wr_data		: param40	;
		end
	end
	
	//========================================================================================================================//
	//---------------------------------------------------PS reads the PL register--------------------------------------------//
	//========================================================================================================================//
	//Distinguish behavior types according to behavior ID.

	always @(posedge clk_i) begin
		
    case ( rd_addr_d2[8:0] )		
		`IRQ_REG1		:	o_st_rd_data <= 		irq_reg1	;
		`IRQ_REG2		:	o_st_rd_data <= 		irq_reg2	;

		`EC_CHA_ST 		: 	o_st_rd_data <= {31'd0,	a_st	 	};	
		`A_ALM_NUM 		: 	o_st_rd_data <= {24'd0,	a_alm_num 	}; 
 		`A_TX_ID   		: 	o_st_rd_data <= {24'd0,	a_tsc_id   	}; 
			
		`EC_CHB_ST 		: 	o_st_rd_data <= {31'd0,	b_st 		}; 
		`B_ALM_NUM 		: 	o_st_rd_data <= {24'd0,	b_alm_num 	}; 
		`B_TX_ID   		: 	o_st_rd_data <= {24'd0,	b_tsc_id   	}; 
		`B_BHV_ID  		: 	o_st_rd_data <= {24'd0,	b_bhv_id  	}; 
			
		`EC_CHC_ST 		: 	o_st_rd_data <= {31'd0,	c_st 		}; 
		`C_ALM_NUM 		: 	o_st_rd_data <= {24'd0,	c_alm_num 	}; 
		`C_TX_ID		: 	o_st_rd_data <= {24'd0,	c_tsc_id   	};
		`C_BHV_ID 		: 	o_st_rd_data <= {24'd0,	c_bhv_id  	}; 

		//`PARAM51		:	o_st_rd_data <= param51     		;
		//`PARAM52		:	o_st_rd_data <= param52     		;
		//`PARAM53		:	o_st_rd_data <= param53     		;
		//`PARAM54		:	o_st_rd_data <= param54     		;
		//`PARAM55		:	o_st_rd_data <= param55     		;
		//`PARAM56		:	o_st_rd_data <= {12'd0,param56		};
		//`PARAM57		:	o_st_rd_data <= {12'd0,param57		};
		//`PARAM58		:	o_st_rd_data <= {12'd0,param58		};
		//`PARAM59		:	o_st_rd_data <= {12'd0,param59		};
		//`PARAM60		:	o_st_rd_data <= {12'd0,param60		};
		//`PARAM61		:	o_st_rd_data <= {24'd0,param61  	};
		//`PARAM62		:	o_st_rd_data <= {24'd0,param62  	};
		//`PARAM63		:	o_st_rd_data <= {24'd0,param63  	};
		//`PARAM64		:	o_st_rd_data <= {24'd0,param64  	};
		//`PARAM65		:	o_st_rd_data <= {24'd0,param65  	};
		`PARAM66		:	o_st_rd_data <= {31'd0,param66  	};
		`PARAM67		:	o_st_rd_data <= {31'd0,param67  	};
		//`PARAM68		:	o_st_rd_data <= {31'd0,param68  	};
		//`PARAM69		:	o_st_rd_data <= {31'd0,param69  	};
		//`PARAM70		:	o_st_rd_data <= {31'd0,param70  	};
		
		`DEBUG_REG1		:	o_st_rd_data <= debug_reg1			;
		`DEBUG_REG2		:	o_st_rd_data <= debug_reg2			;
		//`DEBUG_REG3		:	o_st_rd_data <= debug_reg3			;
		//`DEBUG_REG4		:	o_st_rd_data <= debug_reg4			;
        //`DEBUG_REG5		:	o_st_rd_data <= debug_reg5			;

		`RST_EN        	:	o_st_rd_data <= {31'd0,rst_en_n		};
		`EC_ID         	:	o_st_rd_data <= {18'd0,ec_id		};   
		`SC_ID		 	:	o_st_rd_data <= {22'd0,sc_id		};
		`BHV_PRIORITY	:	o_st_rd_data <= {28'd0,chl_priority	};
		`UNIT_ID       	:	o_st_rd_data <= {24'd0,unit_id		};  
		`UNIT_ECTRL    	:	o_st_rd_data <= {28'd0,unit_ectrl	};
		`UNIT_ST       	:	o_st_rd_data <= {28'd0,unit_st		};   
		`M_ID          	:	o_st_rd_data <= {24'd0,m_id 		};   
		`M_ECTRL       	:	o_st_rd_data <=	{28'd0,m_ectrl		};   
		`M_ST          	:	o_st_rd_data <= {28'd0,m_st  		};   
		`M_WK_MOD      	:	o_st_rd_data <= {28'd0,m_wk_mod 	}; 
		`M_SAF_ST      	:	o_st_rd_data <= {31'd0,m_saf_st 	}; 
		`LINK_M_SAF_ST 	:	o_st_rd_data <= {31'd0,link_m_saf_st};
		//`BHV_EN			:	o_st_rd_data <= bhv_en				;
		`A_TASK_ID     	:	o_st_rd_data <= a_task_id 			;
		`A_TASK_BHV_ID  :	o_st_rd_data <= a_task_bhv_id		; 
		`A_EN			:	o_st_rd_data <= {31'd0,a_en			};
		`A_TX_OT       	:	o_st_rd_data <= {12'd0,a_bhv_ot		};
		`A_TX_RSULT_RPT	:	o_st_rd_data <= a_tsc_result_rpt	;
		`A_BHV_ID      	:	o_st_rd_data <= {24'd0,a_bhv_id 	};
		`B_EN			:	o_st_rd_data <= {31'd0,b_en			};
		`B_TX_OT		:	o_st_rd_data <= {12'd0,b_bhv_ot 	};
		`B_TX_RSULT_RPT	:	o_st_rd_data <= b_tsc_result_rpt	;
		`C_EN			:	o_st_rd_data <= {31'd0,c_en			};
		`C_TX_OT		:	o_st_rd_data <= {12'd0,c_bhv_ot		};
		`C_TX_RSULT_RPT	:	o_st_rd_data <= c_tsc_result_rpt	;
		`C_GAP_CRL     	:	o_st_rd_data <= {12'd0,c_bhv_gap_crl};
		//`PARAM1			:	o_st_rd_data <= param1				;
		//`PARAM2			:	o_st_rd_data <= param2				;
		//`PARAM3			:	o_st_rd_data <= param3				;
		//`PARAM4			:	o_st_rd_data <= param4				;
		//`PARAM5			:	o_st_rd_data <= param5				;
		//`PARAM6			:	o_st_rd_data <= {12'd0,param6		};
		//`PARAM7			:	o_st_rd_data <= {12'd0,param7		};
		//`PARAM8			:	o_st_rd_data <= {12'd0,param8		};
		//`PARAM9			:	o_st_rd_data <= {12'd0,param9		};
		//`PARAM10		:	o_st_rd_data <= {12'd0,param10		};
		//`PARAM11		:	o_st_rd_data <= {12'd0,param11		};
		//`PARAM12		:	o_st_rd_data <= {12'd0,param12		};
		//`PARAM13		:	o_st_rd_data <= {12'd0,param13		};
		//`PARAM14		:	o_st_rd_data <= {12'd0,param14		};
		//`PARAM15		:	o_st_rd_data <= {12'd0,param15		};
		//`PARAM16		:	o_st_rd_data <= {24'd0,param16		};
		//`PARAM17		:	o_st_rd_data <= {24'd0,param17		};
		//`PARAM18		:	o_st_rd_data <= {24'd0,param18		};
		//`PARAM19		:	o_st_rd_data <= {24'd0,param19		};
		//`PARAM20		:	o_st_rd_data <= {24'd0,param20		};
		//`PARAM21		:	o_st_rd_data <= {24'd0,param21		};
		//`PARAM22		:	o_st_rd_data <= {24'd0,param22		};
		//`PARAM23		:	o_st_rd_data <= {24'd0,param23		};
		//`PARAM24		:	o_st_rd_data <= {24'd0,param24		};
		//`PARAM25		:	o_st_rd_data <= {24'd0,param25		};
		//`PARAM26		:	o_st_rd_data <= {31'd0,param26		};
		//`PARAM27		:	o_st_rd_data <= {31'd0,param27		};
		//`PARAM28		:	o_st_rd_data <= {31'd0,param28		};
		//`PARAM29		:	o_st_rd_data <= {31'd0,param29		};
		//`PARAM30		:	o_st_rd_data <= {31'd0,param30		};
		//`PARAM31		:	o_st_rd_data <= param31				;
		//`PARAM32		:	o_st_rd_data <= param32				;
		//`PARAM33		:	o_st_rd_data <= param33				;
		//`PARAM34		:	o_st_rd_data <= param34				;
		//`PARAM35		:	o_st_rd_data <= param35				;
		//`PARAM36		:	o_st_rd_data <= param36				;
		//`PARAM37		:	o_st_rd_data <= param37				;
		//`PARAM38		:	o_st_rd_data <= param38				;
		//`PARAM39		:	o_st_rd_data <= param39				;
		//`PARAM40 		:	o_st_rd_data <= param40				;
		
       default : o_st_rd_data <= 32'h7FFFFFFF;
   endcase    
end   
	
endmodule
