`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/30 10:25:54
// Design Name: 
// Module Name: ec_1di_check
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


module ec_1di_check#(
		parameter  				REG_SPACE_BIAS 	= 	2000	,	//组件基地址
		parameter  				REG_SPACE_SIZE 	= 	512	,	//组件偏移地址
		parameter 				A_BHA_NUM		=	2    ,
		parameter 				B_BHA_NUM		=	1    
		
)(
		input					clk_i			,
		input					rst				,
		input					aurora_reset	,	//unuse
		input                   i_time_1ms_vld  ,
		input                   i_time_1s_vld   ,
		
		input					ps_reg_clk		,
		input					ps_reg_reset	,
		input  		            i_st_wr_en		,//bram总线
		input  		 [19:0]     i_st_wr_addr    ,
		input  		 [31:0]     i_st_wr_data    ,
		input  		            i_st_rd_en      ,
		input  		 [19:0]     i_st_rd_addr    ,
		output 		 [31:0]     o_st_rd_data    ,
		output 		            o_st_rd_vld     ,

		input					di				,
		output 	            	o_intr_irq		//组件中断请求
    );
	
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
	wire 	[7:0]	sc_id			;		
	wire 	[7:0]	ec_id           ;       
	wire 			rst_en_n        ;	
	wire	[31:0]	bhv_num			;

	wire	[7:0]	a_bhv_id        ;       
	wire			a_bhv_en        ;       
	wire	[7:0]	a_task_id       ;       
	wire	[31:0]	a_tx_ot         ;       
	wire	[31:0]	a_tx_result_rpt ;       
	wire	[31:0]	b_tx_ot         ;       
	wire	[31:0]	b_tx_result_rpt ;       
	wire			b_en			;
	wire	[31:0]	c_tx_ot         ;       
	wire	[31:0]	c_gap_crl       ;       
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
	
	//动态参数PS-PL
	wire [31:0]	param1			;
	wire [31:0]	param2			;
	wire [31:0]	param3			;
	wire [31:0]	param4			;
	wire [31:0]	param5			;
	wire [31:0]	param6			;
	wire [31:0]	param7			;
	wire [31:0]	param8			;
	wire [31:0]	param9			;
	wire [31:0]	param10			;
	wire [31:0]	param11			;
	wire [31:0]	param12			;
	wire [31:0]	param13			;
	wire [31:0]	param14			;
	wire [31:0]	param15			;
	wire [31:0]	param16			;
	wire [31:0]	param17			;
	wire [31:0]	param18			;
	wire [31:0]	param19			;
	wire [31:0]	param20			;
	wire [31:0]	param21			;
	wire [31:0]	param22			;
	wire [31:0]	param23			;
	wire [31:0]	param24			;
	wire [31:0]	param25			;
	wire [31:0]	param26			;
	wire [31:0]	param27			;
	wire [31:0]	param28			;
	wire [31:0]	param29			;
	wire [31:0]	param30			;
	
	//动态参数PL-PS
	wire	[31:0]	param50       ;
	wire	[31:0]	param51       ;
	wire	[31:0]	param52       ;
	wire	[31:0]	param53       ;
	wire	[31:0]	param54       ;
	wire	[31:0]	param55       ;
	wire	[31:0]	param56       ;
	wire	[31:0]	param57       ;
	wire	[31:0]	param58       ;
	wire	[31:0]	param59       ;
	wire	[31:0]	param60       ;
	wire	[31:0]	param61       ;
	wire	[31:0]	param62       ;
	wire	[31:0]	param63       ;
	wire	[31:0]	param64       ;
	wire	[31:0]	param65       ;
	wire	[31:0]	param66       ;
	wire	[31:0]	param67       ;
	wire	[31:0]	param68       ;
	wire	[31:0]	param69       ;
	wire	[31:0]	param70       ;
	wire	[31:0]	param71       ;
	wire	[31:0]	param72       ;
	wire	[31:0]	param73       ;
	wire	[31:0]	param74       ;
	wire	[31:0]	param75       ;
	wire	[31:0]	param76       ;
	wire	[31:0]	param77       ;
	
	wire	[31:0]	task_time_cnt	;
	
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
	
	//a_tx_result_rpt:a_bhv_id[7:0]+a_tx_id[7:0]+OK/NO_OK
	
ps_rw_pl_reg#(
    .REG_SPACE_BIAS 	(REG_SPACE_BIAS	),	//组件基地址
    .REG_SPACE_SIZE 	(REG_SPACE_SIZE	)	//组件偏移地址
)ps_rw_pl_reg_u0(
		.clk_i			(ps_reg_clk		),                   //		input
		.rst_i			(ps_reg_reset),                   //		input
		.i_st_wr_en		(i_st_wr_en		),//bram总线     //                input 
		.i_st_wr_addr	(i_st_wr_addr 	),                   // [19:0]     input 
		.i_st_wr_data	(i_st_wr_data 	),                   // [31:0]     input 
		.i_st_rd_en  	(i_st_rd_en   	),                   //            input 
		.i_st_rd_addr	(i_st_rd_addr 	),                   // [19:0]     input 
		.o_st_rd_data	(o_st_rd_data 	),                   // [31:0]     output
		.o_st_rd_vld 	(o_st_rd_vld  	),                   //            output
		.unit_id        (unit_id      ) , //PS-PL           //[7:0]		output
		.unit_ectrl     (unit_ectrl   ) ,                   //[3:0]		output
		.unit_st        (unit_st      ) ,                   //[3:0]		output
		.m_id           (m_id         ) ,    	            //[7:0]		output
		.m_ectrl        (m_ectrl      ) ,                   //[3:0]		output
		.m_st           (m_st         ) ,                   //[3:0]		output
		.m_wk_mod       (m_wk_mod     ) ,                   //[3:0]		output
		.m_saf_st       (m_saf_st     ) ,                   //			output
		.link_m_saf_st  (link_m_saf_st) ,                   //			output
		.sc_id			(sc_id		),		            //[7:0]		    output
		.ec_id          (ec_id        ) ,                   //[7:0]		output
		.rst_en_n       (rst_en_n) ,	                //			output
		.bhv_num		(bhv_num)	,                   //[7:0]		output
		.a_bhv_id       (a_bhv_id       ) ,                   //[7:0]		output
		.a_bhv_en       (a_bhv_en       ) ,                   //			output
		.a_task_id      (a_task_id      ) ,                   //[7:0]		output
		.a_tx_ot        (a_tx_ot        ) ,                   //[31:0]		output
		.a_tx_result_rpt(a_tx_result_rpt) ,                   //[31:0]		output
		.a_tx_result_vld(a_tx_result_vld)	,
		.b_tx_ot        (b_tx_ot        ) ,                   //[31:0]		output
		.b_tx_result_rpt(b_tx_result_rpt) ,                   //[31:0]		output
		.b_tx_result_vld(b_tx_result_vld)	,
		.b_en 			(b_en 			),                   //			output
		.c_tx_ot        (c_tx_ot        ) ,                   //[31:0]		output
		.c_gap_crl      (c_gap_crl      ) ,                   //[31:0]		output
		.c_tx_result_rpt(c_tx_result_rpt) ,                   //[31:0]		output
		.c_tx_result_vld(c_tx_result_vld)	,
		.c_en 			(c_en			),                   //			output
		.ec_cha_st     	(ec_cha_st),	//PL-PS             //			input 
		.ec_chb_st     	(ec_chb_st),                     //			input 
		.ec_chc_st     	(ec_chc_st),                     //			input 
		.a_bhv_typ     	(a_bhv_typ ),                 //	[7:0]       input 
		.a_tx_id       	(a_tx_id   ),                 //	[7:0]       input 
		.a_alm_num     	(a_alm_num ),                 //	[7:0]       input 
		.b_bhv_id      	(b_bhv_id  ),                 //	[7:0]       input 
		.b_tx_id       	(b_tx_id   ),                 //	[7:0]       input 
		.b_alm_num     	(b_alm_num ),                 //	[7:0]       input 
		.c_bhv_id      	(c_bhv_id  ),                 //	[7:0]       input 
		.c_tx_id       	(c_tx_id   ),                 //	[7:0]       input 
		.c_alm_num     	(c_alm_num ),                 //	[7:0]       input 
		.irq_reg1		(irq_reg1),
		.irq_reg2		(irq_reg2),
		.param1			(param1	),//动态参数PS-PL    //	[31:0]	output
		.param2			(param2	),                   //	[31:0]  output
		.param3			(param3	),                   //	[31:0]  output
		.param4			(param4	),                   //	[31:0]  output
		.param5			(param5	),                   //	[31:0]  output
		.param6			(param6	),                   //	[31:0]  output
		.param7			(param7	),                   //	[31:0]  output
		.param8			(param8	),                   //	[31:0]  output
		.param9			(param9	),                   //	[31:0]  output
		.param10		(param10),                   //	[31:0]  output
		.param11		(param11),                   //	[31:0]  output
		.param12		(param12),                   //	[31:0]  output
		.param13		(param13),                   //	[31:0]  output
		.param14		(param14),                   //	[31:0]  output
		.param15		(param15),                   //	[31:0]  output
		.param16		(param16),                   //	[31:0]  output
		.param17		(param17),                   //	[31:0]  output
		.param18		(param18),                   //	[31:0]  output
		.param19		(param19),                   //	[31:0]  output
		.param20		(param20),                   //	[31:0]  output
		.param21		(param21),                   //	[31:0]  output
		.param22		(param22),                   //	[31:0]  output
		.param23		(param23),                   //	[31:0]  output
		.param24		(param24),                   //	[31:0]  output
		.param25		(param25),                   //	[31:0]  output
		.param26		(param26),                   //	[31:0]  output
		.param27		(param27),                   //	[31:0]  output
		.param28		(param28),                   //	[31:0]  output
		.param29		(param29),                   //	[31:0]  output
		.param30		(param30),                   //	[31:0]  output
		.param50    	(param50),//动态参数PL-PS     //	[31:0]  input
		.param51    	(param51),                    //	[31:0]  input 
		.param52    	(param52),                    //	[31:0]  input 
		.param53    	(param53),                    //	[31:0]  input 
		.param54    	(param54),                    //	[31:0]  input 
		.param55    	(param55),                    //	[31:0]  input 
		.param56    	(param56),                    //	[31:0]  input 
		.param57    	(param57),                    //	[31:0]  input 
		.param58    	(param58),                    //	[31:0]  input 
		.param59    	(param59),                    //	[31:0]  input 
		.param60    	(param60),                    //	[31:0]  input 
		.param61    	(param61),                    //	[31:0]  input 
		.param62    	(param62),                    //	[31:0]  input 
		.param63    	(param63),                    //	[31:0]  input 
		.param64    	(param64),                    //	[31:0]  input 
		.param65    	(param65),                    //	[31:0]  input 
		.param66    	(param66),                    //	[31:0]  input 
		.param67    	(param67),                    //	[31:0]  input 
		.param68    	(param68),                    //	[31:0]  input 
		.param69    	(param69),                    //	[31:0]  input 
		.param70    	(param70),                    //	[31:0]  input 
		.param71    	(param71),                    //	[31:0]  input 
		.param72    	(param72),                    //	[31:0]  input 
		.param73    	(param73),                    //	[31:0]  input 
		.param74    	(param74),                    //	[31:0]  input 
		.param75    	(param75),                    //	[31:0]  input 
		.param76    	(param76),                    //	[31:0]  input 
		.param77    	(param77)                     //	[31:0]  input 
	);                                                       
	
	assign 	param50   =	32'd0;
	assign 	param51   =	32'd0;
	assign 	param52   =	32'd0;
	assign 	param53   =	32'd0;
	assign 	param54   =	32'd0;
	assign 	param55   =	32'd0;
	assign 	param56   =	32'd0;
	assign 	param57   =	32'd0;
	assign 	param58   =	32'd0;
	assign 	param59   =	32'd0;
	assign 	param60   =	32'd0;
	assign 	param61   =	32'd0;
	assign 	param62   =	32'd0;
	assign 	param63   =	32'd0;
	assign 	param64   =	32'd0;
	assign 	param65   =	32'd0;
	assign 	param66   =	32'd0;
	assign 	param67   =	32'd0;
	assign 	param68   =	32'd0;
	assign 	param69   =	32'd0;
	assign 	param70   =	32'd0;
	assign 	param71   =	32'd0;
	assign 	param72   =	32'd0;
	assign 	param73   =	32'd0;
	assign 	param74   =	32'd0;
	assign 	param75   =	32'd0;
	assign 	param76   =	32'd0;
	assign 	param77   =	32'd0;
	
	
proactive_beh#(
	.BHA_NUM		(2			)
)proactive_beh_u0(
	.clk_i					(clk_i				)	
	,.rst_i					(rst_i				)	
	,.i_time_1ms_vld		(i_time_1ms_vld 	)		//ms脉冲
	,.i_time_1s_vld 		(i_time_1s_vld  	)		//s脉冲
	,.pre_sta_allow			(a_pre_sta_allow	)		//前充分条件满足信号 0:不满足 1：满足
	,.post_sta_allow		(a_post_sta_allow	)		//后充分条件满足信号
	,.valid_sig				(param1[0]			)		//信号有效性 ps
	,.a_bhv_id        		(a_bhv_id       	)		//1:无效检测	2：有效检测
	,.a_bhv_en        		(a_bhv_en       	)	
	,.a_tx_ot         		(a_tx_ot        	)	
	,.a_tx_result_rpt 		(a_tx_result_rpt	)		
	,.a_tx_result_vld		(a_tx_result_vld	)	
	,.ec_cha_st				(ec_cha_st			)	
	,.a_tx_id         		(a_tx_id        	)	
	,.a_alm_num       		(a_alm_num      	)	
	,.di					(di					)	
	,.irq_o					(irq_a				)	
	,.irq_ack_i				(irq_a_grant		)		//中断应答
    );
    
	status_beh#(
		.BHA_NUM			(1				)
)status_beh_u0(
		.clk_i				(clk_i			)	,
		.rst_i				(rst_i			)	,
		.i_time_1ms_vld		(i_time_1ms_vld )	,	//ms脉冲
		.i_time_1s_vld 		(i_time_1s_vld  )	,	//s脉冲
		.pre_sta_allow		(b_pre_sta_allow)	,	//前充分条件满足信号 0:不满足 1：满足
		.post_sta_allow		(b_post_sta_allow)	,	//后充分条件满足信号
	 	.b_tx_ot         	(b_tx_ot        )	,
	 	.b_tx_result_rpt 	(b_tx_result_rpt)	,
	 	.b_en_i				(b_en			)	,
	 	.ec_chb_st       	(ec_chb_st      )	,
	 	.b_bhv_id        	(b_bhv_id       )	,
	 	.b_tx_id         	(b_tx_id        )	,
	 	.b_alm_num      	(b_alm_num      )	,
	 	.di					(di				)	,
	 	.irq_o				(irq_b			)	,
	 	.irq_ack_i			(irq_b_grant	)		//中断应答
     );
	 
   
   tim_beh tim_beh_u0(
		.clk_i                	(clk_i          )	,
		.rst_i              	(rst_i         )	,	
		.i_time_1ms_vld   		(i_time_1ms_vld )	,
		.i_time_1s_vld    		(i_time_1s_vld  )	,
		.pre_sta_allow			(c_pre_sta_allow)	,	//前充分状态允许
		.post_sta_allow			(c_post_sta_allow)	,	//后充分状态允许
		.irq_o 					(irq_c)	,	
		.irq_ack_i				(irq_c_grant)	,	// 中断应答信号
		.task_time_cnt			(task_time_cnt)	,	//当前计数值
		.c_en_i					(c_en)	,	//通道c使能(启停) ps
		.c_tx_ot          		(c_tx_ot)	,
		.c_tx_result_rpt  		(c_tx_result_rpt)	,
		.c_gap_crl				(c_gap_crl)	,
		.ec_chc_st				(ec_chc_st)	,
		.c_bhv_id        		(c_bhv_id)	,
		.c_tx_id         		(c_tx_id)	,
		.c_alm_num              (c_alm_num)	
   );
	
	pre_post_sta_check#(
		.A_BHA_NUM			(A_BHA_NUM	 )    ,	
		.B_BHA_NUM			(B_BHA_NUM	 )    
)pre_post_sta_check_u0(
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
		.sc_id				(sc_id			),
		.ec_id           	(ec_id          ),
		.di					(di				),
		.b_en				(b_en			),	//通道B使能 ps-pl
		.c_en				(c_en			),	//通道C使能 ps-pl
		.ec_cha_st			(ec_cha_st		),
		.ec_chb_st       	(ec_chb_st		),
		.ec_chc_st       	(ec_chc_st		),
		.c_circle_time		(c_gap_crl		),	//通道C时间周期
		.task_time_cnt		(task_time_cnt	),	//通道C当前计数值
		.a_pre_sta_allow	(a_pre_sta_allow),	//通道A 前充分状态允许
		.a_post_sta_allow	(a_post_sta_allow),	//通道A 后充分状态允许
		.b_pre_sta_allow	(b_pre_sta_allow),	//通道B 前充分状态允许
		.b_post_sta_allow	(b_post_sta_allow),	//通道B 后充分状态允许
		.c_pre_sta_allow	(c_pre_sta_allow),	//通道C 前充分状态允许
		.c_post_sta_allow	(c_post_sta_allow)	//通道C 后充分状态允许
    );
	
	irq_3i1o_arbitrator irq_3i1o_arbitrator_u0(
		.clk_i              (clk_i            )	,
		.rst_i             (rst_i           )	,	
		.sc_id              (sc_id            )	,
		.ec_id              (ec_id            )	,	
		.irq_a_i			(irq_a			)	,	//通道A中断请求
		.irq_a_grant_o		(irq_a_grant		)	,
		.a_bhv_id           (a_bhv_id         )	,
		.a_tx_id            (a_tx_id          )	,
		.a_alm_num          (a_alm_num        )	,
		.irq_b_i			(irq_b			)	,	//通道B中断请求
		.irq_b_grant_o		(irq_b_grant		)	,
		.b_bhv_id       	(b_bhv_id       	)	,
		.b_tx_id        	(b_tx_id        	)	,
		.b_alm_num      	(b_alm_num      	)	,
		.irq_c_i			(irq_c			)	,	//通道C中断请求
		.irq_c_grant_o		(irq_c_grant		)	,
		.c_bhv_id       	(c_bhv_id       	)	,
		.c_tx_id        	(c_tx_id        	)	,
		.c_alm_num			(c_alm_num			)	,
		.irq_reg1_o			(irq_reg1			)	,
		.irq_reg2_o			(irq_reg2			)	,
		.irq_o				(o_intr_irq			)	,
		.irq_busy_o			(irq_busy_o			)	,
		.irq_receive_ack_i  (a_tx_result_vld || b_tx_result_vld || c_tx_result_vld)	
    );
	
	
	
	
	
	
endmodule
