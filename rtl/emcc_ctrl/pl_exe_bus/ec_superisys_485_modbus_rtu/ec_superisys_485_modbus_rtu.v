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


module ec_superisys_485_modbus_rtu#(
		parameter  				REG_SPACE_BIAS 	= 	2000	,	//组件基地址
		parameter  				REG_SPACE_SIZE 	= 	1024	,	//组件偏移地址
		parameter 				A_BHA_NUM		=	4    ,
		parameter 				B_BHA_NUM		=	1    ,
		parameter 				CLK_FREQ        =   100000000   //100MHz = 100000000
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
		output 	            	o_intr_irq		,//组件中断请求
	//--- 主板Uart接口
    	input  wire             i_uart_rx        ,
    	output wire             o_uart_tx        ,
    	output wire             o_uart_de        ,    
		output wire   			o_user_req       ,
    	input  wire     		i_user_grant     ,
	//--- 从板接口 use clk domain 156.25MHz --
		input  wire [4:0]       cur_slv_board_id , //
		input  wire [4:0]       slv_board_id     , 
		input  wire             rs485_ch_r_flag  , //send en
		output wire [31:0]      m2s_rs485_msg    , //send data
		input  wire             rs485_ch_flag    , //recv en
		input  wire [31:0]      s2m_rs485_msg      //recv data

    );
	
	wire            slaver_en       ;
	//PS-PL    
	wire 	[7:0]	unit_id         ;     	
	wire 	[3:0]	unit_ectrl      ;       
	wire 	[3:0]	unit_st         ;       
//	wire 	[7:0]	m_id            ;     	
//	wire 	[3:0]	m_ectrl         ;       
	wire 	[3:0]	m_st            ;       
//	wire 	[3:0]	m_wk_mod        ;       
	wire 			m_saf_st        ;       
	wire 			link_m_saf_st   ;     
	wire 	[9:0]	sc_id			;		
	wire 	[14:0]	ec_id           ;       
	wire 	[3:0]	chl_priority	;
	wire 			rst_en_n        ;	
	wire	[31:0]	bhv_num			;
//	wire			bhv_en			;
	wire	[7:0]	a_bhv_id_r      ;
	wire	[7:0]	a_bhv_id        ;       
	wire			a_bhv_en        ;       
	wire	[7:0]	a_task_id       ;       
	wire	[31:0]	a_bhv_ot        ;       
	wire	[31:0]	a_tx_result_rpt ;       
	wire	[31:0]	b_tx_ot         ;       
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
	
	//动态参数PS-PL
	wire [31:0]	param1			;
	wire [31:0]	param2			;
//	wire [31:0]	param3			;
//	wire [31:0]	param4			;
//	wire [31:0]	param5			;
	wire [31:0]	param6			;
	wire [31:0]	param7			;
	wire [31:0]	param8			;
//	wire [31:0]	param9			;
//	wire [31:0]	param10			;
//	wire [31:0]	param11			;
//	wire [31:0]	param12			;
//	wire [31:0]	param13			;
//	wire [31:0]	param14			;
//	wire [31:0]	param15			;
	wire [ 7:0]	param16			;
	wire [ 7:0]	param17			;
	wire [ 7:0]	param18			;
//	wire [ 7:0]	param19			;
//	wire [ 7:0]	param20			;
//	wire [ 7:0]	param21			;
//	wire [ 7:0]	param22			;
//	wire [ 7:0]	param23			;
//	wire [ 7:0]	param24			;
//	wire [ 7:0]	param25			;
	wire        param26         ;
//	wire        param27         ;
//	wire        param28         ;
//	wire        param29         ;
//	wire        param30         ;
	
	//动态参数PL-PS
    wire    [31:0]  param50       ;
    wire    [31:0]  param51       ;
    wire    [31:0]  param52       ;
//  wire    [31:0]  param53       ;
//  wire    [31:0]  param54       ;
//  wire    [31:0]  param55       ;
//  wire    [19:0]  param56       ;
//  wire    [19:0]  param57       ;
//  wire    [19:0]  param58       ;
//  wire    [19:0]  param59       ;
//  wire    [19:0]  param60       ;
//  wire    [7:0]   param61       ;
//  wire    [7:0]   param62       ;
//  wire    [7:0]   param63       ;
//  wire    [7:0]   param64       ;
//  wire    [7:0]   param65       ;
//  wire            param66       ;
//  wire            param67       ;
//  wire            param68       ;
//  wire            param69       ;
//  wire            param70       ;
    wire   [31:0]   debug_reg1    ;
//  wire   [31:0]   debug_reg2    ;
//  wire   [31:0]   debug_reg3    ;
//  wire   [31:0]   debug_reg4    ;
//  wire   [31:0]   debug_reg5    ;

	wire	[31:0]	task_time_cnt	;
	
	wire			a_tx_result_vld;
//	wire			b_tx_result_vld;
//	wire			c_tx_result_vld;
	
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

	//元资源参数
	wire		[31:0]		baud_rate ;//串口波特率
	wire		[19:0]		stop_bit  ;//停止位
	wire		[7:0]		parity   ; //校验位
	wire					flow_ctl ;//流控模式
	wire		[7:0]		com_port ;//串口号
	wire		[7:0]		slave_addr;//从站地址
	wire		[7:0]		frame_gap;//帧间隔时间
	wire		[15:0]		resp_tout;//响应超时时间
	wire		[7:0]		retry_cnt;//重试次数
	wire		[15:0]		poll_cycle;//轮询周期
	wire		[7:0]		max_frame_len;//最大帧长度
	wire		[31:0]		send_data_field_1;//控制数据1
	wire		[31:0]		send_data_field_2;//控制数据2
//	wire		[31:0]		send_data_field_3;//控制数据3
	wire		[7:0]		add_filt_mod;//地址过滤模式
	wire		[7:0]		flow_ctrl;//收发控制模式
	wire		[7:0]		func_code;//功能码
	wire		[7:0]		data_len;//数据长度
	wire		[15:0]		err_check;//校验码
	wire		[7:0]		check_method;//校验方式
	wire		[7:0]		yte_order;//字节顺序
	wire		[7:0]		start_delim;
	wire		[7:0]		end_delim;
	wire		[15:0]		start_addr;//起始地址

	wire        [31:0]      target_value;//目标值

	wire		[31:0]		fb_data_frame_1;//反馈数据区1
	wire		[31:0]		fb_data_frame_2;//反馈数据区2
//	wire		[31:0]		fb_data_frame_3;//反馈数据区3

	wire            send_start_p        ;
    wire            mst_send_start_p    ;
    wire            mst_send_ready      ;
    wire [7:0]      mst_send_length     ;
    wire [21*8-1:0] mst_send_data       ;
    wire [21*8-1:0] mst_recv_data       ;
    wire            mst_recv_finish_p   ;

    wire            slv_send_req_p       ;//发送请求（电平）
    wire            slv_send_finish_p    ;//发送完成（脉冲）
	wire [ 4*8-1:0] slv_send_data_head   ;
	wire [21*8-1:0] slv_send_data        ;
    wire [21*8-1:0] slv_recv_data        ;
    wire            slv_recv_finish_p    ;
	wire [7:0]      slv_err_code         ;

	wire [21*8-1:0] recv_data            ;
	wire            recv_data_finish_p   ;

    wire            chl_a_send_req       ;
    wire            chl_a_fb_data_ready_p;
    wire [2:0]      chl_a_execu_result   ;

    wire            chl_a_exe_suc        ;
    wire            chl_a_mat_err        ;

	assign  mst_send_start_p  = send_start_p &(~slaver_en);
    assign  slv_send_req_p    = send_start_p &  slaver_en;
	assign recv_data          = (slaver_en) ? slv_recv_data     : mst_recv_data    ;
	assign recv_data_finish_p = (slaver_en) ? slv_recv_finish_p : mst_recv_finish_p;

	assign ec_chb_st   =0;
	assign b_bhv_id    =0;
	assign b_tx_id     =0;
	assign b_alm_num   =0;
	assign irq_b       =0;
	assign b_pre_sta_allow  =0 ;
	assign b_post_sta_allow =0 ;


	assign ec_chc_st   =0;
	assign c_bhv_id    =0;
	assign c_tx_id     =0;
	assign c_alm_num   =0;
	assign irq_c       =0;
	assign c_pre_sta_allow  =0 ;
	assign c_post_sta_allow =0 ;


// ---- 元资源参数，在配置值为0时，要采用默认值 ------
		assign	ctl_data_field =  param1[31:0];//控制数据帧
		assign	baud_rate      = (param6[19:0]==0)?115200:param6[19:0];//串口波特率
		assign	stop_bit       = 0;//停止位
		assign	flow_ctl       = 0;//流控模式
		assign	com_port       = 0;//串口号
		assign	frame_gap      = 0;//帧间隔时间
		assign	resp_tout      = (param7[19:0]==0)?16'd1000:param7[19:0];//响应超时时间
		assign	start_addr[15:0]= param8[15:0];//起始地址
		assign	parity         = (param16[7:0]==0)?2:param16[7:0];//奇偶校验位
		assign	retry_cnt      = (param17==0)?8'd3:param17;//重试次数
		assign	slave_addr     =  param18[7:0];//从站地址
		assign	func_code      = 0;//param19[7:0];//功能码
		assign	data_len       = 0;//param20[7:0];//数据长度
		assign	poll_cycle     = 0;//轮询周期
		assign	max_frame_len  = 0;//最大帧长度

		assign	add_filt_mod   = 0;//地址过滤模式
		assign	err_check      = 0;
		assign  end_delim      = 0;
		assign	check_method   = 0;//param20[7:0];//校验方式
		assign	yte_order      = 0;
		assign  start_delim    = 0;
		assign	flow_ctrl      = 0;
		assign  slaver_en      = param26;//0=主板模式，1=从板模式


ps_rw_pl_reg_superisys_485#(
		.REG_SPACE_BIAS 	(REG_SPACE_BIAS		),//组件基地址
		.REG_SPACE_SIZE 	(REG_SPACE_SIZE		) //组件偏移地址
)ps_rw_pl_reg_u0(
	.clk_i			        (ps_reg_clk		)
	,.rst_i			        (ps_reg_reset	)
	,.i_st_wr_en		    (i_st_wr_en		)
	,.i_st_wr_addr	        (i_st_wr_addr 	)
	,.i_st_wr_data	        (i_st_wr_data 	)
	,.i_st_rd_en  	        (i_st_rd_en   	)
    ,.i_st_rd_addr	        (i_st_rd_addr 	)
    ,.o_st_rd_data	        (o_st_rd_data 	)
	,.o_st_rd_vld 	        (o_st_rd_vld  	)
	,.rst_en_n              (rst_en_n		)	//board error
	,.ec_id                 (ec_id			)
	,.sc_id			        (sc_id			)
	,.chl_priority	        (chl_priority	)
	,.unit_id      	        (unit_id		)
	,.unit_ectrl            (unit_ectrl		)
	,.unit_st               (unit_st		)
//	,.m_id         	        (m_id			)
//	,.m_ectrl               (m_ectrl		)
	,.m_st                  (m_st			)
//	,.m_wk_mod              (m_wk_mod		)
	,.m_saf_st              (m_saf_st		)
	,.link_m_saf_st         (link_m_saf_st	)
//	,.bhv_en                (bhv_en			)
	,.a_task_id      	    (a_task_id		)
	,.a_task_bhv_id	        (a_task_bhv_id	)
	,.a_en				    (a_en			)
	,.a_bhv_ot        	    (a_bhv_ot		)
	,.a_tsc_result_rpt	    (a_tx_result_rpt)
	,.a_tsc_result_vld	    (a_tx_result_vld)
	,.a_bhv_id       	    (a_bhv_id		)
	,.a_bhv_vld             (a_bhv_vld		)
//	,.b_en					(b_en			)
//	,.b_bhv_ot 		        (b_tx_ot		)
//	,.b_tsc_result_rpt	    (b_tx_result_rpt)
//	,.b_tsc_result_vld      (b_tx_result_vld)
//	,.c_en				    (c_en			)
//	,.c_bhv_ot			    (c_tx_ot		)
//	,.c_tsc_result_rpt	    (c_tx_result_rpt)
//	,.c_tsc_result_vld	    (c_tx_result_vld)
//	,.c_bhv_gap_crl         (c_gap_crl		)
	,.param1			    (param1			)
	,.param2			    (param2			)
//	,.param3			    (param3			)
//	,.param4			    (param4			)
//	,.param5			    (param5			)
	,.param6			    (param6			)
	,.param7			    (param7			)
	,.param8			    (param8			)
//	,.param9			    (param9			)
//	,.param10			    (param10		)
//	,.param11			    (param11		)
//	,.param12			    (param12		)
//	,.param13			    (param13		)
//	,.param14			    (param14		)
//	,.param15			    (param15		)
	,.param16			    (param16		)
	,.param17			    (param17		)
	,.param18			    (param18		)
//	,.param19			    (param19		)
//	,.param20			    (param20		)
//	,.param21			    (param21		)
//	,.param22			    (param22		)
//	,.param23			    (param23		)
//	,.param24			    (param24		)
//	,.param25			    (param25		)
	,.param26			    (param26		)
//	,.param27			    (param27		)
//	,.param28			    (param28		)
//	,.param29			    (param29		)
//	,.param30				(param30		)
	,.irq_reg1	            (irq_reg1		)
	,.irq_reg2	            (irq_reg2		)
	,.a_st                  (ec_cha_st		)
	,.a_alm_num             (a_alm_num		)
	,.a_tsc_id              (a_tx_id		)
//	,.b_st                  (ec_chb_st		)
//	,.b_alm_num             (b_alm_num		)
//	,.b_tsc_id              (b_tx_id		)
//	,.b_bhv_id              (b_bhv_id		)
//	,.c_st                  (ec_chc_st 		)
//	,.c_alm_num             (c_alm_num 		)
//	,.c_tsc_id              (c_tx_id  		)
//	,.c_bhv_id              (c_bhv_id 		)
	,.param51               (param51		)
	,.param52               (param52		)
//	,.param53               (param53		)
//	,.param54               (param54		)
//	,.param55               (param55		)
//	,.param56               (param56		)
//	,.param57               (param57		)
//	,.param58               (param58		)
//	,.param59               (param59		)
//	,.param60               (param60		)
//	,.param61               (param61		)
//	,.param62               (param62		)
//	,.param63               (param63		)
//	,.param64               (param64		)
//	,.param65               (param65		)
//	,.param66               (param66		)
//	,.param67               (param67		)
//	,.param68               (param68		)
//	,.param69               (param69		)
//	,.param70               (param70		)
	,.debug_reg1			(debug_reg1		)
//	,.debug_reg2			(debug_reg2		)
//	,.debug_reg3			(debug_reg3		)
//	,.debug_reg4			(debug_reg4		)
//	,.debug_reg5			(debug_reg5		)
	
	);

	assign send_data_field_1 = param1;
	assign target_value      = param2;//目标值
//  assign send_data_field_2 = param3;
//	assign send_data_field_3 = param4;


	assign 	param51   =	fb_data_frame_1;
	assign 	param52   =	fb_data_frame_2;
//	assign 	param53   =	fb_data_frame_3;
//	assign 	param54   =	32'd0;
//	assign 	param55   =	32'd0;
//	assign 	param56   =	32'd0;
//	assign 	param57   =	32'd0;
//	assign 	param58   =	32'd0;
//	assign 	param59   =	32'd0;
//	assign 	param60   =	32'd0;
//	assign 	param61   =	32'd0;
//	assign 	param62   =	32'd0;
//	assign 	param63   =	32'd0;
//	assign 	param64   =	32'd0;
//	assign 	param65   =	32'd0;
//	assign 	param66   =	32'd0;
//	assign 	param67   =	32'd0;
//	assign 	param68   =	32'd0;
//	assign 	param69   =	32'd0;
//	assign 	param70   =	32'd0;


proactive_beh_superisys_485#(	
	.BHA_NUM 				(A_BHA_NUM  	 	)	//Number of active behaviors
//	.ARV_SIG_DET_TIM		(ARV_SIG_DET_TIM	)		//In - place signal detection time
)proactive_beh_u0(
    .clk_i                 	(clk_i              )
    ,.rst_i                	(rst_i              )
    ,.i_time_1ms_vld       	(i_time_1ms_vld     )
    ,.i_time_1s_vld        	(i_time_1s_vld      )
    ,.pre_sta_allow        	(a_pre_sta_allow    )
    ,.post_sta_allow       	(a_post_sta_allow   )
	,.a_en                  (a_en               )
    ,.a_bhv_id             	(a_bhv_id           )
    ,.a_bhv_vld            	(a_bhv_vld          )
    ,.a_tx_ot              	(a_bhv_ot           )
    ,.a_tx_result_rpt	   	(a_tx_result_rpt    )
	,.a_tx_result_vld      	(a_tx_result_vld    )
    ,.ec_cha_st            	(ec_cha_st          )
    ,.a_tx_id              	(a_tx_id            )
    ,.a_alm_num            	(a_alm_num          )
    ,.a_bhv_id_r            (a_bhv_id_r         )
    ,.state_monitor_o       (debug_reg1         )
	,.target_value          (target_value       )//目标值
    ,.o_data_send_req       (chl_a_send_req     )
    ,.i_execu_result        (chl_a_execu_result )
    ,.i_rcv_data            (fb_data_frame_1    )
    ,.i_rcv_data_finish_p   (chl_a_fb_data_ready_p)//接收数据完成
    ,.o_exe_suc             (chl_a_exe_suc      )
    ,.o_mat_err             (chl_a_mat_err      )
    ,.irq_o                	(irq_a              )
    ,.irq_ack_i             (irq_a_grant        )
    );

pre_post_sta_check_superisys_485#(
		.A_BHA_NUM			(A_BHA_NUM	 )    ,	
		.B_BHA_NUM			(B_BHA_NUM	 )    ,
		.C_BHA_NUM			(1)
)pre_post_sta_check_u0(
		.clk_i				(clk_i			),
		.rst_i				(rst_i			),
		.unit_id         	(unit_id        ),
		.unit_ectrl      	(unit_ectrl     ),
		.unit_st         	(unit_st        ),
		.m_id            	(0              ),//m_id           ),
		.m_ectrl         	(0              ),//m_ectrl        ),
		.m_st            	(m_st           ),
		.m_wk_mod        	( 0             ),//m_wk_mod       ),
		.m_saf_st        	(m_saf_st       ),
		.link_m_saf_st   	(link_m_saf_st  ),
		.sc_id				(sc_id			),
		.ec_id           	(ec_id          ),
		.c_bhv_ot			(c_tx_ot		),
		.a_en				(a_en			),	//通道A使能 ps-pl
		.b_en				(b_en			),	//通道B使能 ps-pl
		.c_en				(c_en			),	//通道C使能 ps-pl
		.a_bhv_id        	(a_bhv_id_r     ),	
		.b_bhv_id        	(b_bhv_id       ),	
		.c_bhv_id         	(c_bhv_id       ),	
		.ec_cha_st			(ec_cha_st		),
		.ec_chb_st       	(ec_chb_st		),
		.ec_chc_st       	(ec_chc_st		),
		.a_exe_suc          (chl_a_exe_suc  ),
		.a_mat_err          (chl_a_mat_err  ),
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
		.clk_i              (clk_i             ),
		.rst_i              (rst_i             ),
		.sc_id              (sc_id             ),
		.ec_id              (ec_id             ),
		.chl_priority		(chl_priority      ),
		.irq_a_i			(irq_a             ),//通道A中断请求
		.irq_a_grant_o		(irq_a_grant       ),
		.a_bhv_id           (a_bhv_id_r        ),
		.a_tx_id            (a_tx_id           ),
		.a_alm_num          (a_alm_num         ),
		.irq_b_i            (irq_b             ),//通道B中断请求
		.irq_b_grant_o      (irq_b_grant       ),
		.b_bhv_id           (b_bhv_id          ),
		.b_tx_id            (b_tx_id           ),
		.b_alm_num          (b_alm_num         ),
		.irq_c_i            (irq_c             ),//通道C中断请求
		.irq_c_grant_o      (irq_c_grant       ),
		.c_bhv_id           (c_bhv_id          ),
		.c_tx_id            (c_tx_id           ),
		.c_alm_num          (c_alm_num         ),
		.irq_reg1_o         (irq_reg1          ),
		.irq_reg2_o         (irq_reg2          ),
		.irq_o              (o_intr_irq        ),
		.irq_busy_o         (irq_busy_o        ),
		.irq_receive_ack_i  (a_tx_result_vld   ) //|| b_tx_result_vld || c_tx_result_vld)	
    );
	

// --------- uart ----------
frame_ctrl_superisys_485 frame_ctrl_i(
    .i_clk                 ( clk_i               ),
    .i_rst                 ( rst_i               ),
    .i_time_1s_vld         ( i_time_1s_vld       ),
    .i_time_1ms_vld        ( i_time_1ms_vld      ),
//输入参数
    .i_slave_addr          ( slave_addr           ),//从站地址
    .i_resp_tout           ( resp_tout            ),//响应超时时间
    .i_retry_cnt           ( retry_cnt            ),//重试次数
    .i_send_data_field_1   ( send_data_field_1    ),//发送数据1
    .i_send_data_field_2   ( 0                    ),//发送数据2
    .i_send_data_field_3   ( 0                    ),//发送数据3
    .i_start_addr          ( start_addr           ),//起始地址

    .o_user_req            ( o_user_req           ),
    .i_user_grant          ( i_user_grant         ),
    .o_fb_data_frame_1     ( fb_data_frame_1      ), //返回数据1
    .o_fb_data_frame_2     ( fb_data_frame_2      ), //返回数据2
    .o_fb_data_frame_3     (                      ), //返回数据3
    
    .i_chl_a_send_req      ( chl_a_send_req       ),
    .i_bhv_a_id            ( a_bhv_id_r           ),
    .o_chl_a_fb_data_ready_p(chl_a_fb_data_ready_p),
    .o_chl_a_execu_result  (chl_a_execu_result    ),
	
    //数据收发（主从模式公用）
    .o_send_start_p        ( send_start_p         ),//发送请求（脉冲）
	.i_recv_data           ( recv_data            ),
    .i_recv_finish_p       ( recv_data_finish_p   ),
    // 主板uart数据接口
    .i_send_ready          ( mst_send_ready       ),//空闲，可以发送的标志
    .o_send_data           ( mst_send_data        ),
    .o_send_length         ( mst_send_length      ),
    //从板数据接口
    .i_send_finish_p       ( slv_send_finish_p    ), //发送完成（脉冲）
	.i_slv_err_code        ( slv_err_code         ), //报错编码
	.o_send_data_head      ( slv_send_data_head   ),
	.o_send_data_little    ( slv_send_data        ) //little-end

);

// ----------主板 uart 接口 ----------
  uart_driver_modbus_rtu#(
   .RAM_DWIDTH           ( 13                 ),
   .CLK_FREQ             ( CLK_FREQ           )
)uart_driver_modbus_rtu_u0(
    .clk                 (clk_i               ),
    .reset               (rst_i               ),
	.i_uart_bps          (baud_rate           ),
	.i_frame_gap         (frame_gap           ),
	.i_parity            (parity              ), //奇偶校验，0=无校验 1=奇校验 2=偶校验
    .i_uart_rx           (i_uart_rx           ),
    .o_uart_tx           (o_uart_tx           ),
    .o_uart_de           (o_uart_de           ),
    .i_send_start        ( mst_send_start_p   ),// level or pulse all right , just detect drising edge
    .o_send_ready        (mst_send_ready      ),
    .i_send_length       (mst_send_length     ),
    .i_data_send         (mst_send_data       ),
    .o_data_pack_ok      (mst_recv_finish_p   ),
    .o_data_rcv          (mst_recv_data       )
);

// ----------- slaver 从板接口  ---------------
  superisys_rfid_485_slaver_driver  superisys_rfid_485_slaver_driver_i(
    .i_clk               ( clk_i                ),// user clk （100MHz or 156.25MHz）
    .i_rst               ( rst_i                ),
    .i_prot_clk          ( clk_i                ),// 156.25MHz
    .i_prot_rst          ( rst_i                ),
    .i_baud_rate         ( baud_rate            ),//串口波特率 

//--- 从板接口 use clk domain 156.25MHz --
    .i_cur_slv_board_id  ( cur_slv_board_id     ), //
    .i_slv_board_id      ( slv_board_id         ), 
    .i_rs485_ch_r_flag   ( rs485_ch_r_flag      ), //send en
    .o_m2s_rs485_msg     ( m2s_rs485_msg        ), //send data
    .i_rs485_ch_flag     ( rs485_ch_flag        ), //recv en
    .i_s2m_rs485_msg     ( s2m_rs485_msg        ), //recv data

    //--- 对接业务模块 clk domain 100MHz --
    .i_send_req_p        ( slv_send_req_p       ),
    .i_send_data         ( slv_send_data        ),// little-end
    .i_send_data_head    ( slv_send_data_head   ),
    .o_send_finish_p     ( slv_send_finish_p    ),
    .o_recv_data         ( slv_recv_data        ),
    .o_recv_finish_p     ( slv_recv_finish_p    ),
    .i_uart_inspect      ( 0                    ),
    .o_modbus_err_code   ( slv_err_code         ) //1 = ok ; 5 = SG_CRC_ERR ; 6 = SG_TIME_OUT
);

	
endmodule