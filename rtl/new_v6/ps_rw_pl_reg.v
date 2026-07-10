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

`include "reg_addr_pl.vh"
module ps_rw_pl_reg#(
    parameter  					REG_SPACE_BIAS 	= 	200	,	//组件基地址
    parameter  					REG_SPACE_SIZE 	= 	512		//组件偏移地址
)(
	input						clk_i			
	,input						rst_i			
	
	,input  		            i_st_wr_en		//bram总线
	,input  		 [19:0]     i_st_wr_addr	
	,input  		 [31:0]     i_st_wr_data	
	,input  		            i_st_rd_en  	
    ,input  		 [19:0]     i_st_rd_addr	
    ,output 	reg  [31:0]     o_st_rd_data	
	,output 	reg             o_st_rd_vld 	
	
	,output 	reg	[7:0]		unit_id        //PS-PL    
	,output 	reg [3:0]		unit_ectrl            
	,output 	reg [3:0]		unit_st               
	,output 	reg [7:0]		m_id                	
	,output 	reg [3:0]		m_ectrl               
	,output 	reg [3:0]		m_st                  
	,output 	reg [3:0]		m_wk_mod              
	,output 	reg 			m_saf_st              
	,output 	reg 			link_m_saf_st       
	,output 	reg [7:0]		sc_id					
	,output 	reg [7:0]		ec_id                 
	,output 	reg 			rst_en_n        	
	,output 	reg	[7:0]		bhv_num			

	,output 	reg [7:0]		a_bhv_id              
	,output 	reg 			a_bhv_en              
	,output 	reg [7:0]		a_task_id             
	,output 	reg [31:0]		a_tx_ot               
	,output 	reg [31:0]		a_tx_result_rpt 
	,output		reg				a_tx_result_vld	
	,output 	reg [31:0]		b_tx_ot               
	,output 	reg [31:0]		b_tx_result_rpt  
	,output		reg				b_tx_result_vld
	,output 	reg 			b_en 			    
	,output 	reg [31:0]		c_tx_ot               
	,output 	reg [31:0]		c_gap_crl             
	,output 	reg [31:0]		c_tx_result_rpt 
	,output		reg				c_tx_result_vld
	,output 	reg 			c_en 			 
	
	,input 						ec_cha_st   	//PL-PS
	,input 						ec_chb_st      
	,input 						ec_chc_st      
	,input 			[7:0]		a_bhv_typ        
	,input 			[7:0]		a_tx_id        
	,input 			[7:0]		a_alm_num      
	,input 			[7:0]		b_bhv_id              
	,input 			[7:0]		b_tx_id        
	,input 			[7:0]		b_alm_num      
	,input 			[7:0]		c_bhv_id          
	,input 			[7:0]		c_tx_id        
	,input 			[7:0]		c_alm_num   
		
	,input			[31:0]		irq_reg1	
	,input			[31:0]		irq_reg2	

	,output 	reg [31:0]		param1		//动态参数PS-PL
	,output 	reg [31:0]		param2		
	,output 	reg [31:0]		param3		
	,output 	reg [31:0]		param4		
	,output 	reg [31:0]		param5		
	,output 	reg [31:0]		param6		
	,output 	reg [31:0]		param7		
	,output 	reg [31:0]		param8		
	,output 	reg [31:0]		param9		
	,output 	reg [31:0]		param10		
	,output 	reg [31:0]		param11		
	,output 	reg [31:0]		param12		
	,output 	reg [31:0]		param13		
	,output 	reg [31:0]		param14		
	,output 	reg [31:0]		param15		
	,output 	reg [31:0]		param16		
	,output 	reg [31:0]		param17		
	,output 	reg [31:0]		param18		
	,output 	reg [31:0]		param19		
	,output 	reg [31:0]		param20		
	,output 	reg [31:0]		param21		
	,output 	reg [31:0]		param22		
	,output 	reg [31:0]		param23		
	,output 	reg [31:0]		param24		
	,output 	reg [31:0]		param25		
	,output 	reg [31:0]		param26		
	,output 	reg [31:0]		param27		
	,output 	reg [31:0]		param28		
	,output 	reg [31:0]		param29		
	,output 	reg [31:0]		param30		
	
	,input 			[31:0]		param50    //动态参数PL-PS
	,input 			[31:0]		param51    
	,input 			[31:0]		param52    
	,input 			[31:0]		param53    
	,input 			[31:0]		param54    
	,input 			[31:0]		param55    
	,input 			[31:0]		param56    
	,input 			[31:0]		param57    
	,input 			[31:0]		param58    
	,input 			[31:0]		param59    
	,input 			[31:0]		param60    
	,input 			[31:0]		param61    
	,input 			[31:0]		param62    
	,input 			[31:0]		param63    
	,input 			[31:0]		param64    
	,input 			[31:0]		param65    
	,input 			[31:0]		param66    
	,input 			[31:0]		param67    
	,input 			[31:0]		param68    
	,input 			[31:0]		param69    
	,input 			[31:0]		param70    
	,input 			[31:0]		param71    
	,input 			[31:0]		param72    
	,input 			[31:0]		param73    
	,input 			[31:0]		param74    
	,input 			[31:0]		param75    
	,input 			[31:0]		param76    
	,input 			[31:0]		param77    
	);	
	
	
	reg  		rd_en_d1;
	reg  		rd_en_d2;
	wire 		rd_space_select;
	wire 		wr_space_select;
	wire 		wr_task_vld;
	reg  [19:0] rd_addr_d1;
	reg  [19:0] rd_addr_d2;
	wire [19:0] rd_task_addr;
	wire [19:0] wr_task_addr;
	
	//================================================================================================//
	//----------------------------------------- 组件地址选中 -----------------------------------------//
	//================================================================================================//

	assign  rd_space_select = ((i_st_rd_addr >= REG_SPACE_BIAS) & (i_st_rd_addr < (REG_SPACE_BIAS + REG_SPACE_SIZE))) ? 1'b1 : 1'b0;
	assign  wr_space_select = ((i_st_wr_addr >= REG_SPACE_BIAS) & (i_st_wr_addr < (REG_SPACE_BIAS + REG_SPACE_SIZE))) ? 1'b1 : 1'b0;
	assign  rd_task_addr = i_st_rd_addr - REG_SPACE_BIAS;
	assign  wr_task_addr = i_st_wr_addr - REG_SPACE_BIAS;
	assign  wr_task_vld  = wr_space_select & i_st_wr_en;
   
	always @(posedge clk_i)begin
	if(rst_i)
		rd_en_d1  <= 1'd0;
	else
		rd_en_d1  <= i_st_rd_en & rd_space_select;
	end
	
	always @(posedge clk_i)begin
	if(rst_i)
		rd_en_d2  <= 1'd0;
	else
		rd_en_d2  <= rd_en_d1;
	end
	
	always @(posedge clk_i)begin
	if(rst_i)
		o_st_rd_vld  <= 1'd0;
	else
		o_st_rd_vld  <= rd_en_d2;
	end
		
	always @(posedge clk_i)begin
	if(rst_i)
		rd_addr_d1  <= 20'd0;
	else
		rd_addr_d1 <= rd_task_addr;
	end
	
	always @(posedge clk_i)begin
	if(rst_i)
		rd_addr_d2  <= 20'd0;
	else
		rd_addr_d2 <= rd_addr_d1;
	end
	
	//========================================================================================================================//
   //--------------------------------------------------PS写PL寄存器----------------------------------------------------------//
   //========================================================================================================================//
   
	always@(posedge clk_i) begin
		if(rst_i) begin
			//基础参数PS-PL
			sc_id			<=	8'h00	       ;	//组件ID			
	        ec_id          	<=	8'h00	       ;    //控件ID
	        rst_en_n        <=	1'b0           ;    //ps控制复位(低有效)
	        unit_id      	<=	8'h00	       ;    //单元ID				生产线编号
	        unit_ectrl     	<=	4'h0           ;    //单元紧急控制			急停/暂停/开线/停线
	        unit_st        	<=	4'h0           ;    //单元状态				空闲/执行中/单元报警
	        m_id         	<=	8'h00	       ;    //设备ID				设备编号
	        m_ectrl        	<=	4'h0           ;    //设备紧急控制			急停/暂停/开线/停线
	        m_st           	<=	4'h0           ;    //设备状态				0=空闲,1=执行中,2=报警
	        m_wk_mod       	<=	4'h0           ;    //设备工作模式			1=单机,2=联线,3=手动
	        m_saf_st       	<=	1'b0           ;    //设备安全状态			本地安全状态
	        link_m_saf_st  	<=	1'b0           ;    //关联设备安全状态		
			bhv_num			<=	8'd0			;	//任务中的行为序号
			
	        a_bhv_id       	<=	8'd0		   ;	//通道A执行信息
	        a_bhv_en       	<=	1'b0           ;	//通道A行为许可
	        a_task_id      	<=	8'h00		   ;	//通道A任务ID
	        a_tx_ot        	<=	32'h00000000   ;	//通道A事务超时
	        a_tx_result_rpt	<=	32'h00000000   ;	//通道A事务结果汇报
			a_tx_result_vld	<= 	1'b0			;
			b_tx_ot 		<= 	32'h00000000   ;	//通道A事务超时
	        b_tx_result_rpt	<=	32'h00000000   ;	//通道B事务结果汇报
			b_tx_result_vld	<= 	1'b0			;
			b_en			<=	1'b0		   ;	//通道B使能
			c_tx_ot 		<= 	32'h00000000   ;	//通道A事务超时
			c_tx_result_rpt	<=	32'h00000000   ;	//通道C事务结果汇报
			c_tx_result_vld	<= 	1'b0			;
			c_en			<=	1'b0		   ;	//通道C使能
	        c_gap_crl      	<=	32'h00000000   ;	//通道C时间周期

			//动态参数PS-PL
			param1			<=	32'h00000000   ;
			param2			<=	32'h00000000   ;
			param3			<=	32'h00000000   ;
			param4			<=	32'h00000000   ;
			param5			<=	32'h00000000   ;
			param6			<=	32'h00000000   ;
			param7			<=	32'h00000000   ;
			param8			<=	32'h00000000   ;
			param9			<=	32'h00000000   ;
			param10			<=	32'h00000000   ;
			param11			<=	32'h00000000   ;
			param12			<=	32'h00000000   ;
			param13			<=	32'h00000000   ;
			param14			<=	32'h00000000   ;
			param15			<=	32'h00000000   ;
			param16			<=	32'h00000000   ;
			param17			<=	32'h00000000   ;
			param18			<=	32'h00000000   ;
			param19			<=	32'h00000000   ;
			param20			<=	32'h00000000   ;
			param21			<=	32'h00000000   ;
			param22			<=	32'h00000000   ;
			param23			<=	32'h00000000   ;
			param24			<=	32'h00000000   ;
			param25			<=	32'h00000000   ;
			param26			<=	32'h00000000   ;
			param27			<=	32'h00000000   ;
			param28			<=	32'h00000000   ;
			param29			<=	32'h00000000   ;
			param30			<=	32'h00000000   ;
		end else begin 	//主动行为ID：0-128
			sc_id			<=	(wr_task_vld && wr_task_addr == `SC_ID		 	) ? i_st_wr_data[7:0] 	: sc_id			;
			ec_id          	<=	(wr_task_vld && wr_task_addr == `EC_ID         	) ? i_st_wr_data[7:0] 	: ec_id         ;
			rst_en_n        <=	(wr_task_vld && wr_task_addr == `RST_EN        	) ? i_st_wr_data[0] 	: rst_en_n      ;
			unit_id      	<=	(wr_task_vld && wr_task_addr == `UNIT_ID       	) ? i_st_wr_data[7:0] 	: unit_id      	;
			unit_ectrl     	<=	(wr_task_vld && wr_task_addr == `UNIT_ECTRL    	) ? i_st_wr_data[3:0] 	: unit_ectrl   	;
			unit_st        	<=	(wr_task_vld && wr_task_addr == `UNIT_ST       	) ? i_st_wr_data[3:0] 	: unit_st       ;
			m_id         	<=	(wr_task_vld && wr_task_addr == `M_ID          	) ? i_st_wr_data[7:0] 	: m_id         	;
			m_ectrl        	<=	(wr_task_vld && wr_task_addr == `M_ECTRL       	) ? i_st_wr_data[3:0] 	: m_ectrl       ;
			m_st           	<=	(wr_task_vld && wr_task_addr == `M_ST          	) ? i_st_wr_data[3:0] 	: m_st          ;
			m_wk_mod       	<=	(wr_task_vld && wr_task_addr == `M_WK_MOD      	) ? i_st_wr_data[3:0] 	: m_wk_mod      ;
			m_saf_st       	<=	(wr_task_vld && wr_task_addr == `M_SAF_ST      	) ? i_st_wr_data[0] 	: m_saf_st      ;
			link_m_saf_st  	<=	(wr_task_vld && wr_task_addr == `LINK_M_SAF_ST 	) ? i_st_wr_data[0] 	: link_m_saf_st ;
			a_bhv_id       	<=	(wr_task_vld && wr_task_addr == `A_BHV_ID      	) ? i_st_wr_data[7:0]	: a_bhv_id      ;
			a_bhv_en       	<=	(wr_task_vld && wr_task_addr == `A_BHV_ID      	) ? 1'b1: 1'b0;
			a_task_id      	<=	(wr_task_vld && wr_task_addr == `A_TASK_ID     	) ? i_st_wr_data[7:0] 	: a_task_id      ;
			a_tx_ot        	<=	(wr_task_vld && wr_task_addr == `A_TX_OT       	) ? i_st_wr_data 		: a_tx_ot        ;
			a_tx_result_rpt	<=	(wr_task_vld && wr_task_addr == `A_TX_RSULT_RPT	) ? i_st_wr_data 		: a_tx_result_rpt;
			a_tx_result_vld	<=	(wr_task_vld && wr_task_addr == `A_TX_RSULT_RPT	) ? 1'b1: 1'b0;
			b_tx_ot			<=	(wr_task_vld && wr_task_addr == `B_TX_OT		) ? i_st_wr_data 		: b_tx_ot		 ;
			b_tx_result_rpt	<=	(wr_task_vld && wr_task_addr == `B_TX_RSULT_RPT	) ? i_st_wr_data 		: b_tx_result_rpt;
			b_tx_result_vld	<=	(wr_task_vld && wr_task_addr == `B_TX_RSULT_RPT	) ? 1'b1: 1'b0;
			b_en			<=	(wr_task_vld && wr_task_addr == `B_EN			) ? i_st_wr_data[0] 	: b_en			 ;
			c_gap_crl      	<=	(wr_task_vld && wr_task_addr == `C_GAP_CRL     	) ? i_st_wr_data 		: c_gap_crl      ;
			c_tx_ot			<=	(wr_task_vld && wr_task_addr == `C_TX_OT		) ? i_st_wr_data 		: c_tx_ot		 ;
			c_tx_result_rpt	<=	(wr_task_vld && wr_task_addr == `C_TX_RSULT_RPT	) ? i_st_wr_data 		: c_tx_result_rpt;
			c_tx_result_vld	<=	(wr_task_vld && wr_task_addr == `C_TX_RSULT_RPT	) ? 1'b1: 1'b0							;
			c_en			<=	(wr_task_vld && wr_task_addr == `C_EN			) ? i_st_wr_data[0] 	: c_en			 ;
			bhv_num			<=	(wr_task_vld && wr_task_addr == `BHV_NUM		) ? i_st_wr_data[7:0] 	: bhv_num		 ;
			
			param1			<=	(wr_task_vld && wr_task_addr == `PARAM1			) ? i_st_wr_data 		: param1	;
			param2			<=	(wr_task_vld && wr_task_addr == `PARAM2			) ? i_st_wr_data 		: param2	;
			param3			<=	(wr_task_vld && wr_task_addr == `PARAM3			) ? i_st_wr_data 		: param3	;
			param4			<=	(wr_task_vld && wr_task_addr == `PARAM4			) ? i_st_wr_data 		: param4	;
			param5			<=	(wr_task_vld && wr_task_addr == `PARAM5			) ? i_st_wr_data 		: param5	;
			param6			<=	(wr_task_vld && wr_task_addr == `PARAM6			) ? i_st_wr_data 		: param6	;
			param7			<=	(wr_task_vld && wr_task_addr == `PARAM7			) ? i_st_wr_data 		: param7	;
			param8			<=	(wr_task_vld && wr_task_addr == `PARAM8			) ? i_st_wr_data 		: param8	;
			param9			<=	(wr_task_vld && wr_task_addr == `PARAM9			) ? i_st_wr_data 		: param9	;
			param10			<=	(wr_task_vld && wr_task_addr == `PARAM10		) ? i_st_wr_data 		: param10	;
			param11			<=	(wr_task_vld && wr_task_addr == `PARAM11		) ? i_st_wr_data 		: param11	;
			param12			<=	(wr_task_vld && wr_task_addr == `PARAM12		) ? i_st_wr_data 		: param12	;
			param13			<=	(wr_task_vld && wr_task_addr == `PARAM13		) ? i_st_wr_data 		: param13	;
			param14			<=	(wr_task_vld && wr_task_addr == `PARAM14		) ? i_st_wr_data 		: param14	;
			param15			<=	(wr_task_vld && wr_task_addr == `PARAM15		) ? i_st_wr_data 		: param15	;
			param16			<=	(wr_task_vld && wr_task_addr == `PARAM16		) ? i_st_wr_data 		: param16	;
			param17			<=	(wr_task_vld && wr_task_addr == `PARAM17		) ? i_st_wr_data 		: param17	;
			param18			<=	(wr_task_vld && wr_task_addr == `PARAM18		) ? i_st_wr_data 		: param18	;
			param19			<=	(wr_task_vld && wr_task_addr == `PARAM19		) ? i_st_wr_data 		: param19	;
			param20			<=	(wr_task_vld && wr_task_addr == `PARAM20		) ? i_st_wr_data 		: param20	;
			param21			<=	(wr_task_vld && wr_task_addr == `PARAM21		) ? i_st_wr_data 		: param21	;
			param22			<=	(wr_task_vld && wr_task_addr == `PARAM22		) ? i_st_wr_data 		: param22	;
			param23			<=	(wr_task_vld && wr_task_addr == `PARAM23		) ? i_st_wr_data 		: param23	;
			param24			<=	(wr_task_vld && wr_task_addr == `PARAM24		) ? i_st_wr_data 		: param24	;
			param25			<=	(wr_task_vld && wr_task_addr == `PARAM25		) ? i_st_wr_data 		: param25	;
			param26			<=	(wr_task_vld && wr_task_addr == `PARAM26		) ? i_st_wr_data 		: param26	;
			param27			<=	(wr_task_vld && wr_task_addr == `PARAM27		) ? i_st_wr_data 		: param27	;
			param28			<=	(wr_task_vld && wr_task_addr == `PARAM28		) ? i_st_wr_data 		: param28	;
			param29			<=	(wr_task_vld && wr_task_addr == `PARAM29		) ? i_st_wr_data 		: param29	;
			param30			<=	(wr_task_vld && wr_task_addr == `PARAM30		) ? i_st_wr_data 		: param30	;
		end
	end
	

	//========================================================================================================================//
	//--------------------------------------------------PS读PL寄存器----------------------------------------------------------//
	//========================================================================================================================//
	//根据行为ID区分行为类型

	always @(posedge clk_i) begin
		
    case ( rd_addr_d2 )
		`EC_CHA_ST 		: 	o_st_rd_data <= {31'd0,ec_cha_st };	//通道A状态 	0:空闲	1：忙碌
 		`A_TX_ID   		: 	o_st_rd_data <= {24'd0,a_tx_id   }; //通道A事务ID	10,20,30,40
		`A_ALM_NUM 		: 	o_st_rd_data <= {24'd0,a_alm_num }; //通道A报警ID	40时，对应的报警编号
		
		`EC_CHB_ST 		: 	o_st_rd_data <= {31'd0,ec_chb_st }; //通道B状态 	0:空闲	1：忙碌
		`B_BHV_ID  		: 	o_st_rd_data <= {24'd0,b_bhv_id  }; //通道B行为ID   				
		`B_TX_ID   		: 	o_st_rd_data <= {24'd0,b_tx_id   }; //通道B事务ID		
		`B_ALM_NUM 		: 	o_st_rd_data <= {24'd0,b_alm_num }; //通道B报警ID
		
		`EC_CHC_ST 		: 	o_st_rd_data <= {31'd0,ec_chc_st }; //通道C状态 	0:空闲	1：忙碌
		`C_BHV_ID 		: 	o_st_rd_data <= {24'd0,c_bhv_id  }; //通道C行为ID   			
		`C_TX_ID		: 	o_st_rd_data <= {24'd0,c_tx_id   }; //通道C事务ID		
		`C_ALM_NUM 		: 	o_st_rd_data <= {24'd0,c_alm_num }; //通道C报警ID		

		//动态参数PL-PS
		`PARAM50		:	o_st_rd_data <= param50     	;
		`PARAM51		:	o_st_rd_data <= param51     	;
		`PARAM52		:	o_st_rd_data <= param52     	;
		`PARAM53		:	o_st_rd_data <= param53     	;
		`PARAM54		:	o_st_rd_data <= param54     	;
		`PARAM55		:	o_st_rd_data <= param55     	;
		`PARAM56		:	o_st_rd_data <= param56     	;
		`PARAM57		:	o_st_rd_data <= param57     	;
		`PARAM58		:	o_st_rd_data <= param58     	;
		`PARAM59		:	o_st_rd_data <= param59     	;
		`PARAM60		:	o_st_rd_data <= param60     	;
		`PARAM61		:	o_st_rd_data <= param61     	;
		`PARAM62		:	o_st_rd_data <= param62     	;
		`PARAM63		:	o_st_rd_data <= param63     	;
		`PARAM64		:	o_st_rd_data <= param64     	;
		`PARAM65		:	o_st_rd_data <= param65     	;
		`PARAM66		:	o_st_rd_data <= param66     	;
		`PARAM67		:	o_st_rd_data <= param67     	;
		`PARAM68		:	o_st_rd_data <= param68     	;
		`PARAM69		:	o_st_rd_data <= param69     	;
		`PARAM70		:	o_st_rd_data <= param70     	;
		`PARAM71		:	o_st_rd_data <= param71     	;
		`PARAM72		:	o_st_rd_data <= param72     	;
		`PARAM73		:	o_st_rd_data <= param73     	;
		`PARAM74		:	o_st_rd_data <= param74     	;
		`PARAM75		:	o_st_rd_data <= param75     	;
		`PARAM76		:	o_st_rd_data <= param76     	;
		`PARAM77		:	o_st_rd_data <= param77     	;
		
		//ps写寄存器可读
		`SC_ID		 	:	o_st_rd_data <= {24'd0,sc_id		};
		`EC_ID         	:	o_st_rd_data <= {24'd0,ec_id		};
		`RST_EN        	:	o_st_rd_data <= {31'd0,rst_en_n		};
		`UNIT_ID       	:	o_st_rd_data <= {24'd0,unit_id		};
		`UNIT_ECTRL    	:	o_st_rd_data <= {28'd0,unit_ectrl	};
		`UNIT_ST       	:	o_st_rd_data <= {28'd0,unit_st		};
		`M_ID          	:	o_st_rd_data <= {24'd0,m_id			};
		`M_ECTRL       	:	o_st_rd_data <= {28'd0,m_ectrl		};
		`M_ST          	:	o_st_rd_data <= {28'd0,m_st			};
		`M_WK_MOD      	:	o_st_rd_data <= {28'd0,m_wk_mod		};
		`M_SAF_ST      	:	o_st_rd_data <= {31'd0,m_saf_st		};
		`LINK_M_SAF_ST 	:	o_st_rd_data <= {31'd0,link_m_saf_st};
		`A_BHV_ID      	:	o_st_rd_data <= {24'd0,a_bhv_id		};
		`A_TASK_ID     	:	o_st_rd_data <= {24'd0,a_task_id	};
		`A_TX_OT       	:	o_st_rd_data <= a_tx_ot        	  ;
		`A_TX_RSULT_RPT	:	o_st_rd_data <= a_tx_result_rpt	  ;
		`B_TX_OT		:	o_st_rd_data <= b_tx_ot			  ;	//通道B行为超时时间
		`B_TX_RSULT_RPT	:	o_st_rd_data <= b_tx_result_rpt	  ;
		`C_GAP_CRL     	:	o_st_rd_data <= c_gap_crl      	  ;
		`C_TX_OT		:	o_st_rd_data <= c_tx_ot			  ;	//通道C行为超时时间
		`C_TX_RSULT_RPT	:	o_st_rd_data <= c_tx_result_rpt	  ;
		`BHV_NUM		:	o_st_rd_data <= {24'd0,bhv_num	};
		
		`IRQ_REG1		:	o_st_rd_data <= irq_reg1		;
		`IRQ_REG2		:	o_st_rd_data <= irq_reg2		 ;
		
		`PARAM1			:	o_st_rd_data <= param1			  ;
		`PARAM2			:	o_st_rd_data <= param2			  ;
		`PARAM3			:	o_st_rd_data <= param3			  ;
		`PARAM4			:	o_st_rd_data <= param4			  ;
		`PARAM5			:	o_st_rd_data <= param5			  ;
		`PARAM6			:	o_st_rd_data <= param6			  ;
		`PARAM7			:	o_st_rd_data <= param7			  ;
		`PARAM8			:	o_st_rd_data <= param8			  ;
		`PARAM9			:	o_st_rd_data <= param9			  ;
		`PARAM10		:	o_st_rd_data <= param10			  ;
		`PARAM11		:	o_st_rd_data <= param11			  ;
		`PARAM12		:	o_st_rd_data <= param12			  ;
		`PARAM13		:	o_st_rd_data <= param13			  ;
		`PARAM14		:	o_st_rd_data <= param14			  ;
		`PARAM15		:	o_st_rd_data <= param15			  ;
		`PARAM16		:	o_st_rd_data <= param16			  ;
		`PARAM17		:	o_st_rd_data <= param17			  ;
		`PARAM18		:	o_st_rd_data <= param18			  ;
		`PARAM19		:	o_st_rd_data <= param19			  ;
		`PARAM20		:	o_st_rd_data <= param20			  ;
		`PARAM21		:	o_st_rd_data <= param21			  ;
		`PARAM22		:	o_st_rd_data <= param22			  ;
		`PARAM23		:	o_st_rd_data <= param23			  ;
		`PARAM24		:	o_st_rd_data <= param24			  ;
		`PARAM25		:	o_st_rd_data <= param25			  ;
		`PARAM26		:	o_st_rd_data <= param26			  ;
		`PARAM27		:	o_st_rd_data <= param27			  ;
		`PARAM28		:	o_st_rd_data <= param28			  ;
		`PARAM29		:	o_st_rd_data <= param29			  ;
		`PARAM30		:	o_st_rd_data <= param30			  ;
		'h34			:	o_st_rd_data <= 32'h34560000			  ;
       default : o_st_rd_data <= 32'h7FFFFFFF;
   endcase    
end   
	
endmodule
