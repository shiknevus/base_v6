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


module ec_dv300_485_modbus_rtu#(
		parameter  				REG_SPACE_BIAS 	= 	2000	,	//组件基地址
		parameter  				REG_SPACE_SIZE 	= 	1024	,	//组件偏移地址
		parameter 				A_BHA_NUM		=	7    ,
		parameter 				B_BHA_NUM		=	1    ,
		parameter 				CLK_FREQ        =   100000000   //100MHz = 100000000
		
)(
		input					clk_i			,
		input					rst				,
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
		output 	            	o_intr_irq		,//组件中断请求

    	input  wire             i_uart_rx        ,
    	output wire             o_uart_tx        ,
    	output wire             o_uart_de        ,    
		output wire             o_user_req       ,
    	input  wire             i_user_grant
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
	wire 	[9:0]	sc_id			;		
	wire 	[14:0]	ec_id           ;       
	wire 	[3:0]	chl_priority	;
	wire 			rst_en_n        ;	
	wire	[31:0]	bhv_num			;
	wire			bhv_en			;
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
	
	wire	[31:0]	debug_reg1 ;
	wire	[31:0]	debug_reg2 ;
	wire	[31:0]	debug_reg3 ;
	wire	[31:0]	debug_reg4 ;
	wire	[31:0]	debug_reg5 ;

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
	wire		[31:0]		ctl_data_field;//控制数据帧
	wire		[7:0]		add_filt_mod;//地址过滤模式
	wire		[7:0]		flow_ctrl;//收发控制模式
	wire		[7:0]		func_code;//功能码
	wire		[7:0]		data_len;//数据长度
	wire		[15:0]		err_check;//校验码
	wire		[7:0]		check_method;//校验方式
	wire		[7:0]		byte_order;//字节顺序
	wire		[7:0]		start_delim;
	wire		[7:0]		end_delim;
	wire		[15:0]		start_addr;//起始地址

	wire		[63:0]		fb_data_frame;//反馈数据



	wire            uart_send_start_p;
	wire            uart_send_finish_p;
	wire            uart_send_ready;
    wire [7:0]      uart_send_length;
    wire [127:0]    uart_send_data;
    wire [127:0]    uart_rcv_data;
	wire [127:0]    uart_rcv_data_big;
    wire            uart_rcv_data_ok;
    wire            chl_a_send_req;
	wire            chl_a_fb_data_ready_p;
	wire [2:0]      chl_a_execu_result;
    wire            chl_c_send_req;
	wire            chl_c_fb_data_ready_p;
    wire [2:0]      chl_c_execu_result;

	wire [7:0]      chl_a_data_send_func;
	wire [15:0]     chl_a_data_send_start_addr;
	wire [15:0]     chl_a_data_send_data;

	wire            chl_a_exe_suc;

	assign ec_chb_st   =0;
	assign b_bhv_id    =0;
	assign b_tx_id     =0;
	assign b_alm_num   =0;
	assign irq_b       =0;

	assign ec_chc_st   =0;
	assign c_bhv_id    =0;
	assign c_tx_id     =0;
	assign c_alm_num   =0;
	assign irq_c       =0;


// ---- 元资源参数，在配置值为0时，要采用默认值 ------
		assign	baud_rate      = 9600;// (param1[31:0]==0)?9600:param1[31:0];//串口波特率
		assign	stop_bit       = param2[7:0];//停止位
		assign	parity         = 2;//param3[7:0];//校验位
		assign	flow_ctl       = param4[7:0];//流控模式
		assign	com_port       = param5[7:0];//串口号
		assign	slave_addr     = param6[7:0];//(param6[7:0]==0)?8'h01:param6[7:0];//从站地址
		assign	frame_gap      = param7[15:0];//帧间隔时间
		assign	resp_tout      = (param8[15:0]==0)?16'd1000:param8[15:0];//响应超时时间
		assign	retry_cnt      = (param9[15:0]==0)?16'd3:param9[15:0];//重试次数
		assign	poll_cycle     = (param10[15:0]==0)?16'd100:param10[15:0];//轮询周期
		assign	max_frame_len  = param11[7:0];//最大帧长度
		assign	ctl_data_field = param12[19:0];//控制数据帧
		assign	add_filt_mod   = param13[7:0];//地址过滤模式

		assign	func_code      = param16[7:0];//功能码
		assign	data_len       = param17[7:0];//数据长度
		assign	err_check      = param18[15:0];//校验码
		assign  end_delim      = (param19[7:0]==0)?8'h16:param19[7:0];//结束符
		assign	check_method   = param20[7:0];//校验方式
		assign	byte_order      = param21[7:0];//字节顺序
		assign	start_addr[15:8]= param22[7:0];//起始地址H
		assign	start_addr[7:0] = param23[7:0];//起始地址L
		assign  start_delim    = (param24[7:0])==0?8'h68:param24[7:0];//起始符
		assign	flow_ctrl      = param25[7:0];//收发控制模式


	ps_rw_pl_reg#(
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
	,.m_id         	        (m_id			)
	,.m_ectrl               (m_ectrl		)
	,.m_st                  (m_st			)
	,.m_wk_mod              (m_wk_mod		)
	,.m_saf_st              (m_saf_st		)
	,.link_m_saf_st         (link_m_saf_st	)
	,.bhv_en                (bhv_en			)
	,.a_task_id      	    (a_task_id		)
	,.a_task_bhv_id	        (a_task_bhv_id	)
	,.a_en				    (a_en			)
	,.a_bhv_ot        	    (a_bhv_ot		)
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
	,.param1			    (param1			)
	,.param2			    (param2			)
	,.param3			    (param3			)
	,.param4			    (param4			)
	,.param5			    (param5			)
	,.param6			    (param6			)
	,.param7			    (param7			)
	,.param8			    (param8			)
	,.param9			    (param9			)
	,.param10			    (param10		)
	,.param11			    (param11		)
	,.param12			    (param12		)
	,.param13			    (param13		)
	,.param14			    (param14		)
	,.param15			    (param15		)
	,.param16			    (param16		)
	,.param17			    (param17		)
	,.param18			    (param18		)
	,.param19			    (param19		)
	,.param20			    (param20		)
	,.param21			    (param21		)
	,.param22			    (param22		)
	,.param23			    (param23		)
	,.param24			    (param24		)
	,.param25			    (param25		)
	,.param26			    (param26		)
	,.param27			    (param27		)
	,.param28			    (param28		)
	,.param29			    (param29		)
	,.param30				(param30		)
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
	,.param51               (param51		)
	,.param52               (param52		)
	,.param53               (param53		)
	,.param54               (param54		)
	,.param55               (param55		)
	,.param56               (param56		)
	,.param57               (param57		)
	,.param58               (param58		)
	,.param59               (param59		)
	,.param60               (param60		)
	,.param61               (param61		)
	,.param62               (param62		)
	,.param63               (param63		)
	,.param64               (param64		)
	,.param65               (param65		)
	,.param66               (param66		)
	,.param67               (param67		)
	,.param68               (param68		)
	,.param69               (param69		)
	,.param70               (param70		)
	,.debug_reg1			(debug_reg1		)
	,.debug_reg2			(debug_reg2		)
	,.debug_reg3			(debug_reg3		)
	,.debug_reg4			(debug_reg4		)
	,.debug_reg5			(debug_reg5		)
	
	);


	assign 	param51   =	fb_data_frame[31:0];
	assign 	param52   =	fb_data_frame[63:32];
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


proactive_beh_dv300_485_modbus_rtu#(	
	.BHA_NUM 				(A_BHA_NUM  	 	)	//Number of active behaviors
//	.ARV_SIG_DET_TIM		(ARV_SIG_DET_TIM	)		//In - place signal detection time
)proactive_beh_dv300_485_modbus_rtu_u0(
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
	,.i_ctrl_data           (param1[15:0]       )
	,.o_data_send_func      (chl_a_data_send_func )
	,.o_data_send_start_addr(chl_a_data_send_start_addr )
	,.o_data_send_data      (chl_a_data_send_data)
    ,.o_data_send_req       (chl_a_send_req     )
	,.i_rcv_data_finish_p   (chl_a_fb_data_ready_p )//接收数据完成
    ,.i_execu_result        (chl_a_execu_result )
    ,.o_exe_suc             (chl_a_exe_suc      )
    ,.irq_o                	(irq_a              )
    ,.irq_ack_i             (irq_a_grant        )
    );

/*
	tim_beh_osm41_485 tim_beh_osm41_485_u0(
    .clk_i                      (clk_i          	)
	,.rst_i              	    (rst_i         		)
	,.i_time_1ms_vld   	        (i_time_1ms_vld 	)
	,.i_time_1s_vld    	        (i_time_1s_vld  	)
	,.task_time_cnt	            (task_time_cnt		)
	,.pre_sta_allow		        (c_pre_sta_allow	)
	,.post_sta_allow	        (c_post_sta_allow	)
	,.c_en				        (c_en				)
	,.c_bhv_id                  (c_bhv_id			)
	,.c_tx_ot          	        (c_tx_ot			)
	,.c_tx_result_rpt  	        (c_tx_result_rpt	)
	,.c_tx_result_vld           (c_tx_result_vld	)
	,.ec_chc_st	                (ec_chc_st			)
	,.c_tx_id         	        (c_tx_id			)
	,.c_alm_num                 (c_alm_num			)
	,.c_gap_crl                 (c_gap_crl			)
    ,.o_data_send_req			(chl_c_send_req		)
    ,.i_data_send_finish_p		(chl_c_send_finish_p)
	,.i_execu_result            (chl_c_execu_result )
	,.i_rcv_data_finish_p		(uart_rcv_data_ok	)//接收数据完成
	,.irq_o 					(irq_c				)
	,.irq_ack_i                 (irq_c_grant		)
   );
*/

pre_post_sta_check_dv300_485_modbus_rtu#(
        .A_BHA_NUM          (A_BHA_NUM      ),
        .B_BHA_NUM          (B_BHA_NUM      ),
        .C_BHA_NUM          (1              )
)pre_post_sta_check_dv300_485_modbus_rtu_u0(
        .clk_i              (clk_i          ),
        .rst_i              (rst_i          ),
        .unit_id            (unit_id        ),
        .unit_ectrl         (unit_ectrl     ),
        .unit_st            (unit_st        ),
        .m_id               (m_id           ),
        .m_ectrl            (m_ectrl        ),
        .m_st               (m_st           ),
        .m_wk_mod           (m_wk_mod       ),
        .m_saf_st           (m_saf_st       ),
        .link_m_saf_st      (link_m_saf_st  ),
        .a_en               (a_en            ), //通道A使能 ps-pl
        .b_en               (b_en            ), //通道B使能 ps-pl
        .c_en               (c_en            ), //通道C使能 ps-pl
        .a_bhv_id           (a_bhv_id_r      ),
        .b_bhv_id           (b_bhv_id        ),
        .c_bhv_id           (c_bhv_id        ),
        .ec_cha_st          (ec_cha_st       ),
        .ec_chb_st          (ec_chb_st       ),
        .ec_chc_st          (ec_chc_st       ),
        .a_exe_suc          (chl_a_exe_suc   ),
        .c_circle_time      (c_gap_crl       ), //通道C时间周期
        .task_time_cnt      (task_time_cnt   ), //通道C当前计数值
        .a_pre_sta_allow    (a_pre_sta_allow ), //通道A 前充分状态允许
        .a_post_sta_allow   (a_post_sta_allow), //通道A 后充分状态允许
        .b_pre_sta_allow    (b_pre_sta_allow ), //通道B 前充分状态允许
        .b_post_sta_allow   (b_post_sta_allow), //通道B 后充分状态允许
        .c_pre_sta_allow    (c_pre_sta_allow ), //通道C 前充分状态允许
        .c_post_sta_allow   (c_post_sta_allow)  //通道C 后充分状态允许
    );
	
	irq_3i1o_arbitrator irq_3i1o_arbitrator_u0(
        .clk_i              (clk_i             ),
        .rst_i              (rst_i             ),	
        .sc_id              (sc_id             ),
        .ec_id              (ec_id             ),	
        .irq_a_i            (irq_a             ),	//通道A中断请求
        .irq_a_grant_o		(irq_a_grant       ),
        .a_bhv_id           (a_bhv_id_r        ),
        .a_tx_id            (a_tx_id           ),
        .a_alm_num          (a_alm_num         ),
        .irq_b_i            (irq_b             ),	//通道B中断请求
        .irq_b_grant_o      (irq_b_grant       ),
        .b_bhv_id           (b_bhv_id          ),
        .b_tx_id            (b_tx_id           ),
        .b_alm_num          (b_alm_num         ),
        .irq_c_i            (irq_c             ),	//通道C中断请求
        .irq_c_grant_o	    (irq_c_grant       ),
        .c_bhv_id           (c_bhv_id          ),
        .c_tx_id            (c_tx_id           ),
        .c_alm_num          (c_alm_num         ),
        .irq_reg1_o	        (irq_reg1          ),
        .irq_reg2_o         (irq_reg2          ),
        .irq_o              (o_intr_irq        ),
        .irq_busy_o         (irq_busy_o        ),
        .irq_receive_ack_i  (a_tx_result_vld || b_tx_result_vld || c_tx_result_vld)	
    );
	

// --------- uart ----------
frame_ctrl_dv300_485_modbus_rtu
 frame_ctrl_dv300_485_modbus_rtu_i(
    .clk_i                  ( clk_i                        ),
    .rst_i                  ( rst_i                        ),
    .i_time_1s_vld          ( i_time_1s_vld                ),
    .i_time_1ms_vld         ( i_time_1ms_vld               ),
//输入参数
    .i_slave_addr           ( slave_addr                   ),//从站地址
    .i_resp_tout            ( resp_tout                    ),//响应超时时间
    .i_retry_cnt            ( retry_cnt                    ),//重试次数
    .i_func_code            ( chl_a_data_send_func         ),//功能码
    .i_data                 ( {16'h0,chl_a_data_send_data} ),//数据
    .i_data_len             ( data_len                     ),//数据长度
    .i_start_addr           ( chl_a_data_send_start_addr   ),//起始地址
//
    .o_user_req             (o_user_req                    ),
    .i_user_grant           (i_user_grant                  ),
    .o_fb_data_frame        (fb_data_frame                 ),
    .i_chl_a_send_req       (chl_a_send_req                ),
    .o_chl_a_fb_data_ready_p(chl_a_fb_data_ready_p         ),
    .o_chl_a_execu_result   (chl_a_execu_result            ),
    .i_chl_c_send_req       (chl_c_send_req                ),
    .o_chl_c_fb_data_ready_p(chl_c_fb_data_ready_p         ),
    .o_chl_c_execu_result   (chl_c_execu_result            ),
    .o_send_start_p         ( uart_send_start_p            ),
    .i_send_ready           ( uart_send_ready              ),
    .o_send_data            ( uart_send_data               ),
    .o_send_length          ( uart_send_length             ),
    .i_recv_data            ( uart_rcv_data                ),
    .i_recv_data_ok         ( uart_rcv_data_ok             )
);

  uart_driver_modbus_rtu#(
   .RAM_DWIDTH           ( 12                 ),
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
    .i_send_start        (uart_send_start_p   ),
    .o_send_ready        (uart_send_ready     ),
    .i_send_length       (uart_send_length    ),
    .i_data_send         (uart_send_data      ),
    .o_data_pack_ok      (uart_rcv_data_ok    ),
    .o_data_rcv          (uart_rcv_data       )
);

/*
ila_0 ila_0_i2 (
	.clk(clk_i), // input wire clk


	.probe0(o_uart_de), // input wire [0:0]  probe0  
	.probe1(i_uart_rx), // input wire [0:0]  probe1 
	.probe2(o_uart_tx), // input wire [0:0]  probe2 
	.probe3(uart_send_start_p), // input wire [0:0]  probe3 
	.probe4(uart_rcv_data_ok), // input wire [0:0]  probe4 
	.probe5(irq_a), // input wire [0:0]  probe5 
	.probe6(rst_i), // input wire [0:0]  probe6 
	.probe7(o_intr_irq), // input wire [0:0]  probe7 
	.probe8(i_time_1ms_vld), // input wire [0:0]  probe8 
	.probe9(i_time_1s_vld), // input wire [0:0]  probe9 
	.probe10(ps_reg_clk), // input wire [0:0]  probe10 
	.probe11(ps_reg_reset), // input wire [0:0]  probe11 
	.probe12(uart_rcv_data[31:0]), // input wire [31:0]  probe12 
	.probe13(uart_rcv_data[63:32]), // input wire [31:0]  probe13 
	.probe14(uart_send_data[31:0]), // input wire [31:0]  probe14 
	.probe15(uart_send_length) // input wire [31:0]  probe15
);	
*/
endmodule