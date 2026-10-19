`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/30 10:25:54
// Design Name: 
// Module Name: ec_dv300_do
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//	参数设置：
//    参数      设置值    		功能 / 现场说明
//    P-000       0       		第零段频率使用 P-051，避免模拟输入自动切换频率来源
//    P-001       1       		外部端子控制：正转/停止、反转/停止
//    P-002       0       		减速停机；实际停机方式需符合设备要求
//    P-003       0       		允许电机反转
//    P-049       0       		关闭自动程序运行，使用外部多段速选择
//    P-051     按工艺设定       第0段频率(主频率, Hz)；X3~X6全断开时运行频率 (出厂50.0Hz)
//    P-052     按负载设定(s)    第0段加速时间；按磨头惯量调节，过短易报加速过流(OC-1)
//    P-053     按负载设定(s)    第0段减速时间；按磨头惯量调节，过短易报减速过压(OU-2)
//    P-056     按工艺设定       第1段频率 (Hz)；对应选速端子组合 0001 (X5接通, 出厂1.0Hz)
//    P-061     按工艺设定       第2段频率 (Hz)；对应选速端子组合 0010 (X6接通, 出厂2.0Hz)
//    P-066     按工艺设定       第3段频率 (Hz)；对应选速端子组合 0011 (X6+X5接通, 出厂3.0Hz)
//    P-071     按工艺设定       第4段频率 (Hz)；对应选速端子组合 0100 (X4接通, 出厂4.0Hz)
//    P-076     按工艺设定       第5段频率 (Hz)；对应选速端子组合 0101 (X4+X5接通, 出厂5.0Hz)
//    P-081     按工艺设定       第6段频率 (Hz)；对应选速端子组合 0110 (X4+X6接通, 出厂6.0Hz)
//    P-086     按工艺设定       第7段频率 (Hz)；对应选速端子组合 0111 (X4+X6+X5接通, 出厂7.0Hz)
//    P-091       0       		关闭 PID 控制
//    P-104      16       		X1: 正转；与 COM 接通时正转，断开时停止
//    P-105      17       		X2: 反转；与 COM 接通时反转，断开时停止
//    P-106      28       		X3: 多段速八，段号权重 8
//    P-107       2       		X4: 多段速四，段号权重 4
//    P-108       0       		X5: 多段速一，段号权重 1
//    P-109       1       		X6: 多段速二，段号权重 2
//    P-113       3       		J2 继电器 (JB1/JB2): 故障输出
//    P-163       0       		输入端子不反相，与 COM 接通有效
//    P-170     按工艺设定       第8段频率 (Hz)；对应选速端子组合 1000 (X3接通, 出厂8.0Hz)
//    P-173     按工艺设定       第9段频率 (Hz)；对应选速端子组合 1001 (X3+X5接通, 出厂9.0Hz)
//    P-176     按工艺设定       第10段频率 (Hz)；对应选速端子组合 1010 (X3+X6接通, 出厂10.0Hz)
//    P-179     按工艺设定       第11段频率 (Hz)；对应选速端子组合 1011 (X3+X6+X5接通, 出厂11.0Hz)
//    P-182     按工艺设定       第12段频率 (Hz)；对应选速端子组合 1100 (X3+X4接通, 出厂12.0Hz)
//    P-185     按工艺设定       第13段频率 (Hz)；对应选速端子组合 1101 (X3+X4+X5接通, 出厂13.0Hz)
//    P-188     按工艺设定       第14段频率 (Hz)；对应选速端子组合 1110 (X3+X4+X6接通, 出厂14.0Hz)
//    P-191     按工艺设定       第15段频率 (Hz)；对应选速端子组合 1111 (X3+X4+X6+X5接通, 出厂15.0Hz)
//  端口与端子接线对应关系：
//    - o_fwd   -> X1: 正转驱动 (P-104=16)
//    - o_rev   -> X2: 反转驱动 (P-105=17)
//    - o_spdx4 -> X3: 多段速选择4，段号权重 8 (P-106=28)
//    - o_spdx3 -> X4: 多段速选择3，段号权重 4 (P-107=2)
//    - o_spdx2 -> X6: 多段速选择2，段号权重 2 (P-109=1)
//    - o_spdx1 -> X5: 多段速选择1，段号权重 1 (P-108=0)
//    - i_error <- JB1/JB2: 变频器故障常开接点 (J2继电器故障输出, P-113=3)
//    * 注意：X3、X4、X5、X6 的段号权重依次为 8、4、1、2，切不可按端子编号设为 1、2、4、8。
//    * 段号 = 8*X3 + 4*X4 + 2*X6 + X5，正好等于本组件 PARAM16[3:0] 的值：
//        PARAM16[0]->o_spdx1->X5(权1)  PARAM16[1]->o_spdx2->X6(权2)
//        PARAM16[2]->o_spdx3->X4(权4)  PARAM16[3]->o_spdx4->X3(权8)
//    * 第零段(段号0)不是停止：X3~X6 全断开时, 只要 X1 或 X2 接通就按 P-051 运行;
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ec_dv300_do#(
		parameter  				REG_SPACE_BIAS 		= 	2000	,	//Component offset address
		parameter  				REG_SPACE_SIZE 		= 	512			//Component register size
)(
		input					clk_i			,
		input					rst				,
		input                   i_time_1ms_vld  ,
		input                   i_time_1s_vld   ,
		
		input					ps_reg_clk		,
		input					ps_reg_reset	,
		input  		            i_st_wr_en		,
		input  		 [19:0]     i_st_wr_addr    ,
		input  		 [31:0]     i_st_wr_data    ,
		input  		            i_st_rd_en      ,
		input  		 [19:0]     i_st_rd_addr    ,
		output 		 [31:0]     o_st_rd_data    ,
		output 		            o_st_rd_vld     ,

		output					o_fwd			,
		output					o_rev			,
		output					o_spdx1			,
		output					o_spdx2			,
		output					o_spdx3			,
		output					o_spdx4			,
		input					i_error			,
		output					o_rst			,
		
		output 	            	o_intr_irq	
    );
	
	localparam		A_BHA_NUM	=	6;	
	localparam		B_BHA_NUM	=	1;	
	
	
	//PS-PL    
	wire 	[7:0]	unit_id         ;     	
	wire 	[3:0]	unit_ectrl      ;       
	wire 	[3:0]	unit_st         ;       
	wire 	[7:0]	m_id            ;     	
	wire 	[3:0]	m_ectrl         ;       
	wire 	[3:0]	m_st            ;       
	wire 	[3:0]	m_wk_mod        ;       
	wire 			m_saf_st        ;       
	wire 			link_m_saf_st   ;     
	wire 	[9:0]	sc_id			;		
	wire 	[13:0]	ec_id           ;       
	wire 			rst_en_n        ;	

	wire	[7:0]	a_bhv_id        ;       
	wire			a_bhv_vld        ;       
	wire	[31:0]	a_task_id       ;       
	wire	[19:0]	a_tx_ot         ;       
	wire	[31:0]	a_tx_result_rpt ;       
	wire	[19:0]	b_tx_ot         ;       
	wire	[31:0]	b_tx_result_rpt ;       
	wire			b_en			;
	wire	[19:0]	c_tx_ot         ;       
	wire	[19:0]	c_gap_crl       ;       
	wire	[31:0]	c_tx_result_rpt ;    
	wire			c_en			;
	
	//PL-PS
	wire 			ec_cha_st     ;		
	wire 			ec_chb_st     ;     
	wire 			ec_chc_st     ;     
	wire	[7:0]	a_bhv_typ     ;       
	wire	[7:0]	a_tx_id       ;     
	wire	[7:0]	a_alm_num     ;     
	wire	[7:0]	b_bhv_id      ;            
	wire	[7:0]	b_tx_id       ;     
	wire	[7:0]	b_alm_num     ;     
	wire	[7:0]	c_bhv_id      ;        
	wire	[7:0]	c_tx_id       ;     
	wire	[7:0]	c_alm_num     ;  
	
	//PS-PL
	wire [31:0]		param1			;
	wire [31:0]		param2			;
	wire [31:0]		param3			;
	wire [31:0]		param4			;
	wire [31:0]		param5			;
	wire [19:0]		param6			;
	wire [19:0]		param7			;
	wire [19:0]		param8			;
	wire [19:0]		param9			;
	wire [19:0]		param10			;
	wire [19:0]		param11			;
	wire [19:0]		param12			;
	wire [19:0]		param13			;
	wire [19:0]		param14			;
	wire [19:0]		param15			;
	wire [7:0]		param16			;
	wire [7:0]		param17			;
	wire [7:0]		param18			;
	wire [7:0]		param19			;
	wire [7:0]		param20			;
	wire [7:0]		param21			;
	wire [7:0]		param22			;
	wire [7:0]		param23			;
	wire [7:0]		param24			;
	wire [7:0]		param25			;
	wire 			param26			;
	wire 			param27			;
	wire 			param28			;
	wire 			param29			;
	wire 			param30			;
	
	//PL-PS
	wire 	[31:0]	param51 ;
	wire 	[31:0]	param52 ;
	wire 	[31:0]	param53 ;
	wire 	[31:0]	param54 ;
	wire 	[31:0]	param55 ;
	wire 	[19:0]	param56 ;
	wire 	[19:0]	param57 ;
	wire 	[19:0]	param58 ;
	wire 	[19:0]	param59 ;
	wire 	[19:0]	param60 ;
	wire 	[7:0]	param61 ;
	wire 	[7:0]	param62 ;
	wire 	[7:0]	param63 ;
	wire 	[7:0]	param64 ;
	wire 	[7:0]	param65 ;
	wire 			param66 ;
	wire 			param67 ;
	wire 			param68 ;
	wire 			param69 ;
	wire 			param70 ;


	wire	[19:0]	task_time_cnt	;

	wire	[31:0]	debug_reg1 ;
	wire	[31:0]	debug_reg2 ;
	wire	[31:0]	debug_reg3 ;
	wire	[31:0]	debug_reg4 ;
	wire	[31:0]	debug_reg5 ;

	
	wire			a_tx_result_vld;
	wire			b_tx_result_vld;
	wire			c_tx_result_vld;
	
	wire 	[A_BHA_NUM-1:0]	a_pre_sta_allow   ;
	wire 	[A_BHA_NUM-1:0]	a_post_sta_allow  ;
	wire 	[B_BHA_NUM-1:0]	b_pre_sta_allow   ;
	wire 	[B_BHA_NUM-1:0]	b_post_sta_allow  ;
	wire 					c_pre_sta_allow   ;
	wire 					c_post_sta_allow  ;
	
	wire	irq_a  ;
	wire	irq_b  ;
	wire	irq_c  ;
	
	wire 	irq_a_grant;
	wire 	irq_b_grant;
	wire 	irq_c_grant;
	
	wire	irq_busy_o	;
	
	wire 	[31:0]	irq_reg1 ;
	wire 	[31:0]	irq_reg2 ;
	
	wire	rst_i;
	assign	rst_i = !rst_en_n;
	
	wire	[3:0]	chl_priority;
	wire	[31:0]	a_task_bhv_id;
	wire			a_en;
	wire 	[31:0]	bhv_en;
	
	wire	[7:0]	a_bhv_id_r;
	

	assign o_spdx1 = param16[0];
    assign o_spdx2 = param16[1];
    assign o_spdx3 = param16[2];
    assign o_spdx4 = param16[3];
	
	
	//valid signal sync
	reg 		r_a_tx_result_vld ;
	reg 		r_b_tx_result_vld ;
	reg 		r_c_tx_result_vld ;
	reg 		r_a_bhv_vld       ;
	
	reg 		sync_a_tx_result_vld ;
	reg 		sync_b_tx_result_vld ;
	reg 		sync_c_tx_result_vld ;
	reg 		sync_a_bhv_vld       ;
	
	always@(posedge clk_i)
	begin
		if(rst_i)begin
			r_a_tx_result_vld 		<= 1'b0;
			r_b_tx_result_vld 		<= 1'b0;
			r_c_tx_result_vld 		<= 1'b0;
			r_a_bhv_vld       		<= 1'b0;
			
			sync_a_tx_result_vld 	<= 1'b0;
			sync_b_tx_result_vld 	<= 1'b0;
			sync_c_tx_result_vld 	<= 1'b0;
			sync_a_bhv_vld       	<= 1'b0;
		end else begin
			r_a_tx_result_vld		<= a_tx_result_vld;
			r_b_tx_result_vld		<= b_tx_result_vld;
			r_c_tx_result_vld		<= c_tx_result_vld;
			r_a_bhv_vld      		<= a_bhv_vld      ;
			
			sync_a_tx_result_vld 	<= r_a_tx_result_vld;
			sync_b_tx_result_vld 	<= r_b_tx_result_vld;
			sync_c_tx_result_vld 	<= r_c_tx_result_vld;
			sync_a_bhv_vld       	<= r_a_bhv_vld      ;
		end
	end
	
	
	ps_rw_pl_reg_dv300_do#(
		.REG_SPACE_BIAS 	(REG_SPACE_BIAS		),
		.REG_SPACE_SIZE 	(REG_SPACE_SIZE		)
)ps_rw_pl_reg_dv300_do_u0(
	.clk_i			        (ps_reg_clk		)
	,.rst_i			        (ps_reg_reset	)
	,.i_st_wr_en		    (i_st_wr_en		)
	,.i_st_wr_addr	        (i_st_wr_addr 	)
	,.i_st_wr_data	        (i_st_wr_data 	)
	,.i_st_rd_en  	        (i_st_rd_en   	)
    ,.i_st_rd_addr	        (i_st_rd_addr 	)
    ,.o_st_rd_data	        (o_st_rd_data 	)
	,.o_st_rd_vld 	        (o_st_rd_vld  	)
	,.rst_en_n              (rst_en_n		)
	,.ec_id                 (ec_id			)
	,.sc_id			        (sc_id			)
	,.chl_priority	        (chl_priority	)
	,.unit_id      	        (unit_id		)
	,.unit_ectrl            (unit_ectrl		)
	,.unit_st               (unit_st		)
	,.m_id         	        (m_id			)
	,.m_ectrl               (m_ectrl		)
	,.m_st                  (m_st			)
	,.m_wk_mod              (m_wk_mod		)
	,.m_saf_st              (m_saf_st		)
	,.link_m_saf_st         (link_m_saf_st	)
	//,.bhv_en                (bhv_en			)
	,.a_task_id      	    (a_task_id		)
	,.a_task_bhv_id	        (a_task_bhv_id	)
	,.a_en				    (a_en			)
	,.a_bhv_ot        	    (a_tx_ot		)
	,.a_tsc_result_rpt	    (a_tx_result_rpt)
	,.a_tsc_result_vld	    (a_tx_result_vld)
	,.a_bhv_id       	    (a_bhv_id		)
	,.a_bhv_vld             (a_bhv_vld		)
	,.b_en					(b_en			)
	,.b_bhv_ot 		        (b_tx_ot		)
	,.b_tsc_result_rpt	    (b_tx_result_rpt)
	,.b_tsc_result_vld      (b_tx_result_vld)
	,.c_en				    (c_en			)
	,.c_bhv_ot			    (c_tx_ot		)
	,.c_tsc_result_rpt	    (c_tx_result_rpt)
	,.c_tsc_result_vld	    (c_tx_result_vld)
	,.c_bhv_gap_crl         (c_gap_crl		)
	//,.param1			    (param1			)
	//,.param2			    (param2			)
	//,.param3			    (param3			)
	//,.param4			    (param4			)
	//,.param5			    (param5			)
	//,.param6			    (param6			)
	//,.param7			    (param7			)
	//,.param8			    (param8			)
	//,.param9			    (param9			)
	//,.param10			    (param10		)
	//,.param11			    (param11		)
	//,.param12			    (param12		)
	//,.param13			    (param13		)
	//,.param14			    (param14		)
	//,.param15			    (param15		)
	,.param16			    (param16		)
	//,.param17			    (param17		)
	//,.param18			    (param18		)
	//,.param19			    (param19		)
	//,.param20			    (param20		)
	//,.param21			    (param21		)
	//,.param22			    (param22		)
	//,.param23			    (param23		)
	//,.param24			    (param24		)
	//,.param25			    (param25		)
	,.param26			    (param26		)
	//,.param27			    (param27		)
	//,.param28			    (param28		)
	//,.param29			    (param29		)
	//,.param30				(param30		)
	
	,.irq_reg1	            (irq_reg1		)
	,.irq_reg2	            (irq_reg2		)
	,.a_st                  (ec_cha_st		)
	,.a_alm_num             (a_alm_num		)
	,.a_tsc_id              (a_tx_id		)
	,.b_st                  (ec_chb_st		)
	,.b_alm_num             (b_alm_num		)
	,.b_tsc_id              (b_tx_id		)
	,.b_bhv_id              (b_bhv_id		)
	,.c_st                  (ec_chc_st 		)
	,.c_alm_num             (c_alm_num 		)
	,.c_tsc_id              (c_tx_id  		)
	,.c_bhv_id              (c_bhv_id 		)
	//,.param51               (param51		)
	//,.param52               (param52		)
	//,.param53               (param53		)
	//,.param54               (param54		)
	//,.param55               (param55		)
	//,.param56               (param56		)
	//,.param57               (param57		)
	//,.param58               (param58		)
	//,.param59               (param59		)
	//,.param60               (param60		)
	//,.param61               (param61		)
	//,.param62               (param62		)
	//,.param63               (param63		)
	//,.param64               (param64		)
	//,.param65               (param65		)
	// ,.param66               (param66		)
	// ,.param67               (param67		)
	//,.param68               (param68		)
	//,.param69               (param69		)
	//,.param70               (param70		)
	,.debug_reg1			(debug_reg1		)
	,.debug_reg2			(debug_reg2		)
	,.debug_reg3			({{24{1'b0}},o_rst,i_error,o_spdx4,o_spdx3,o_spdx2,o_spdx1,o_rev,o_fwd}		)
	//,.debug_reg4			(debug_reg4		)
	//,.debug_reg5			(debug_reg5		)
	);

	proactive_beh_dv300_do#(	
	.BHA_NUM 				(A_BHA_NUM  	 )	//Number of active behaviors
)proactive_beh_dv300_do_u0(
    .clk_i                 	(clk_i				)
    ,.rst_i                	(rst_i				)
    ,.i_time_1ms_vld       	(i_time_1ms_vld 	)
    ,.i_time_1s_vld        	(i_time_1s_vld  	)
    ,.pre_sta_allow        	(a_pre_sta_allow	)
    ,.post_sta_allow       	(a_post_sta_allow	)
	,.a_en			       	(1'b1				)
    ,.a_bhv_id             	(a_bhv_id       	)
    ,.a_bhv_vld            	(sync_a_bhv_vld      	)
    ,.a_tx_ot              	(a_tx_ot        	)
    ,.a_tx_result_rpt	   	(a_tx_result_rpt	)
	,.a_tx_result_vld      	(sync_a_tx_result_vld	)
    ,.ec_cha_st            	(ec_cha_st			)
    ,.a_tx_id              	(a_tx_id        	)
    ,.a_alm_num            	(a_alm_num      	)
    ,.o_fwd					(o_fwd				)
	,.o_rev                 (o_rev				)
	,.a_bhv_id_r			(a_bhv_id_r			)
	,.state_monitor_o		(debug_reg1			)
    ,.irq_o                	(irq_a				)
    ,.irq_ack_i       		(irq_a_grant		)
    );

	status_beh_dv300_do#(
		.BHA_NUM(B_BHA_NUM	)
)status_beh_dv300_do_u0(
	.clk_i			        (clk_i				)
	,.rst_i			        (rst_i				)
	,.i_time_1ms_vld		(i_time_1ms_vld 	)
	,.i_time_1s_vld 		(i_time_1s_vld  	)
	,.pre_sta_allow	        (b_pre_sta_allow	)
	,.post_sta_allow	    (b_post_sta_allow	)
	,.b_en	                (1'b0				)
	,.b_bhv_id              (b_bhv_id			)
	,.b_tx_ot               (b_tx_ot			)
	,.b_tx_result_rpt       (b_tx_result_rpt	)
	,.b_tx_result_vld       (sync_b_tx_result_vld	)
	,.ec_chb_st             (ec_chb_st			)
	,.b_tx_id               (b_tx_id			)
	,.b_alm_num             (b_alm_num			)
	,.irq_o			        (irq_o				)
	,.irq_ack_i	            (irq_ack_i			)	
	,.state_monitor_o		(debug_reg2			)
	,.o_rst					(o_rst				)
    );
	 
	tim_beh_dv300_do tim_beh_dv300_do_u0(
	.clk_i                      (clk_i          	)
	,.rst_i              	    (rst_i         		)
	,.i_time_1ms_vld   	        (i_time_1ms_vld 	)
	,.i_time_1s_vld    	        (i_time_1s_vld  	)
	,.task_time_cnt	            (task_time_cnt		)
	,.pre_sta_allow		        (c_pre_sta_allow	)
	,.post_sta_allow	        (c_post_sta_allow	)
	,.c_en				        (1'b0				)
	,.c_bhv_id                  (c_bhv_id			)
	,.c_tx_ot          	        (c_tx_ot			)
	,.c_tx_result_rpt  	        (c_tx_result_rpt	)
	,.c_tx_result_vld           (sync_c_tx_result_vld	)
	,.ec_chc_st	                (ec_chc_st			)
	,.c_tx_id         	        (c_tx_id			)
	,.c_alm_num                 (c_alm_num			)
	,.c_gap_crl                 (c_gap_crl			)
	,.irq_o 					(irq_o				)
	,.irq_ack_i                 (irq_ack_i			)
	);
	
	pre_post_sta_check_dv300_do#(
		.A_BHA_NUM			(A_BHA_NUM	 )    ,	
		.B_BHA_NUM			(B_BHA_NUM	 )    
)pre_post_sta_check_dv300_do_u0(
		.clk_i				(clk_i			),
		.rst_i				(rst_i			),
		.unit_id         	(unit_id        ),
		.unit_ectrl      	(unit_ectrl     ),
		.unit_st         	(unit_st        ),
		.m_id            	(m_id           ),
		.m_ectrl         	(m_ectrl        ),
		.m_st            	(m_st           ),
		.m_wk_mod        	(m_wk_mod       ),
		.m_saf_st        	(m_saf_st       ),
		.link_m_saf_st   	(link_m_saf_st  ),
		.a_bhv_id			(a_bhv_id_r		),
		.b_bhv_id			(b_bhv_id		),
		.c_bhv_id			(c_bhv_id		),
		.a_en				(1'b1			),
		.b_en				(1'b0			),	
		.c_en				(1'b0			),	
		.ec_cha_st			(ec_cha_st		),
		.ec_chb_st       	(ec_chb_st		),
		.ec_chc_st       	(ec_chc_st		),
		.c_circle_time		(c_gap_crl		),	
		.task_time_cnt		(task_time_cnt	),	
		.a_pre_sta_allow	(a_pre_sta_allow),	
		.a_post_sta_allow	(a_post_sta_allow),	
		.b_pre_sta_allow	(b_pre_sta_allow),	
		.b_post_sta_allow	(b_post_sta_allow),	
		.c_pre_sta_allow	(c_pre_sta_allow),	
		.c_post_sta_allow	(c_post_sta_allow)	
		,.i_error               (i_error			)
		,.rcfg_rst             (param26				)
    );
	
	irq_3i1o_arbitrator irq_3i1o_arbitrator_u0(
		.clk_i              (clk_i            	)
		,.rst_i             (rst_i           	)
		,.sc_id             (sc_id            	)
		,.ec_id             (ec_id            	)
		,.chl_priority		(chl_priority		)
		,.irq_a_i			(irq_a				)
		,.irq_a_grant_o		(irq_a_grant		)
		,.a_bhv_id          (a_bhv_id_r         )
		,.a_tx_id           (a_tx_id          	)
		,.a_alm_num         (a_alm_num        	)
		,.irq_b_i			(irq_b				)
		,.irq_b_grant_o		(irq_b_grant		)
		,.b_bhv_id       	(b_bhv_id       	)
		,.b_tx_id        	(b_tx_id        	)
		,.b_alm_num      	(b_alm_num      	)
		,.irq_c_i			(irq_c				)
		,.irq_c_grant_o		(irq_c_grant		)
		,.c_bhv_id       	(c_bhv_id       	)
		,.c_tx_id        	(c_tx_id        	)
		,.c_alm_num			(c_alm_num			)
		,.irq_reg1_o		(irq_reg1			)
		,.irq_reg2_o		(irq_reg2			)
		,.irq_o				(o_intr_irq			)
		,.irq_busy_o		(irq_busy_o			)
		,.irq_receive_ack_i (sync_a_tx_result_vld || sync_b_tx_result_vld || sync_c_tx_result_vld)	
    );
	
	
	
	
	
	
endmodule
