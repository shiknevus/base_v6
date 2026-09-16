`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/30 10:25:54
// Design Name: 
// Module Name: ec_pul_axis
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


module ec_pul_axis#(
		parameter  				REG_SPACE_BIAS 		= 	2000	,
		parameter  				REG_SPACE_SIZE 		= 	512	
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
//----------------------------------------------------- user logic begin -----------------------------------------------------//
    	input					i_servo_ready       //servo ready
    	,input					i_servo_done        //servo move done
    	,input					i_axis_limf         //axis limit forward
    	,input					i_axis_zero          //axis origin
    	,input					i_axis_limb         //axis limit backward
    	,input					i_emerge_stop_signal//emergency stop signal


   		,input  	            i_dv_alarm			//drive alarm
   		,output 	            o_dv_pulse			//axi pulse
   		,output 	            o_dv_dir			//axis dir
   		,output 	            o_dv_reset			//servo reset
   		,output 	            o_dv_son			//servo en
//----------------------------------------------------- user logic end -------------------------------------------------------//
		
		,output 	            o_intr_irq	
    );
	
//----------------------------------------------------- user logic begin -----------------------------------------------------//
	localparam		A_BHA_NUM	=	200;
	localparam		B_BHA_NUM	=	200;
	localparam		C_BHA_NUM	=	200;
//----------------------------------------------------- user logic end -------------------------------------------------------//
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

	wire	[31:0]	debug_reg1 ;
	wire	[31:0]	debug_reg2 ;
	wire	[31:0]	debug_reg3 ;
	wire	[31:0]	debug_reg4 ;
	wire	[31:0]	debug_reg5 ;

	wire	[19:0]	task_time_cnt	;

	wire			a_tx_result_vld;
	wire			b_tx_result_vld;
	wire			c_tx_result_vld;

	wire 	[A_BHA_NUM-1:0]	a_pre_sta_allow   ;
	wire 	[A_BHA_NUM-1:0]	a_post_sta_allow  ;
	wire 	[B_BHA_NUM-1:0]	b_pre_sta_allow   ;
	wire 	[B_BHA_NUM-1:0]	b_post_sta_allow  ;
	wire 	[C_BHA_NUM-1:0] c_pre_sta_allow   ;
	wire 	[C_BHA_NUM-1:0] c_post_sta_allow  ;

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
	
	wire	i_clk = clk_i;
	wire	i_rst = rst_i;
	
		reg			ro_intr_irq;
		reg	[7:0]	irq_posedge_cnt;
		reg	[7:0]	irq_negedge_cnt;
		
		always@(posedge i_clk)
		begin
			ro_intr_irq <= o_intr_irq;
		end
		
		
		always@(posedge i_clk)
		begin
			if(i_rst)begin
				irq_posedge_cnt <= 8'd0;
				irq_negedge_cnt <= 8'd0;
			end else if(a_bhv_vld)begin
				irq_posedge_cnt <= 8'd0;
				irq_negedge_cnt <= 8'd0;
			end else begin
				if({ro_intr_irq,o_intr_irq} == 2'b01)begin	//rising
					irq_posedge_cnt <= irq_posedge_cnt+1;
				end else begin
					irq_posedge_cnt <= irq_posedge_cnt;
				end
				
				if({ro_intr_irq,o_intr_irq} == 2'b10)begin	//falling
					irq_negedge_cnt <= irq_negedge_cnt+1;
				end else begin
					irq_negedge_cnt <= irq_negedge_cnt;
				end
			end
		end
	
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
	
//----------------------------------------------------- user logic begin -----------------------------------------------------//
	wire 	[31:0]	param31		;
	wire 	[31:0]	param32		;
	wire 	[31:0]	param33		;
	wire 	[31:0]	param34		;
	wire 	[31:0]	param35		;
	wire 	[31:0]	param36		;
	wire 	[31:0]	param37		;
	wire 	[31:0]	param38		;
	wire 	[31:0]	param39		;
	wire 	[31:0]	param40		;
	wire 	[0:0]	action_busy	;
	wire 	[0:0]	action_done	;
	wire 	[0:0]	action_error;
	wire 			b_clr_pause	;
	wire 			b_clr_resume;
	wire 			b_clr_stop	;
	wire 			b_pause		;
	wire 			b_stop		;
//----------------------------------------------------- user logic end -------------------------------------------------------//

	ps_rw_pl_reg_pul_axis#(
		.REG_SPACE_BIAS 	(REG_SPACE_BIAS		),
		.REG_SPACE_SIZE 	(REG_SPACE_SIZE		)
)ps_rw_pl_reg_pul_axis_u0(
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
	,.param1			    (param1			)
	,.param2			    (param2			)
	,.param3			    (param3			)
	,.param4			    (param4			)
	,.param5			    (param5			)
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
	,.param21			    (param21		)
	//,.param22			    (param22		)
	//,.param23			    (param23		)
	//,.param24			    (param24		)
	//,.param25			    (param25		)
	,.param26			    (param26		)
	,.param27			    (param27		)
	,.param28			    (param28		)
	,.param29			    (param29		)
	// ,.param30				(param30		)
//----------------------------------------------------- user logic begin -----------------------------------------------------//
	,.param31				(param31		)
	,.param32				(param32		)
	,.param33				(param33		)
	,.param34				(param34		)
	,.param35				(param35		)
	,.param36				(param36		)
	,.param37				(param37		)
	//,.param38				(param38		)
	//,.param39				(param39		)
	//,.param40				(param40		)
	,.clr_pause				(b_clr_pause	)
	,.clr_resume			(b_clr_resume	)
	,.clr_stop				(b_clr_stop		)
//----------------------------------------------------- user logic end -------------------------------------------------------//
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
	,.param52               ({29'd0,o_dv_reset,o_dv_dir,o_dv_pulse}	)	//diff out [1]dir [0]pulse
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
	,.param64               ({7'd0,i_axis_limf}	)	//fwd limit
	,.param65               ({7'd0,i_servo_ready}	)	//servo ready
	,.param66               (i_servo_done		)	//servo done
	,.param67               (i_axis_limb		)	//bwd limit
	,.param68               (i_axis_zero		)	//origin
	,.param69               (i_dv_alarm		)	//drive input alm
	,.param70               (o_dv_son		)	//drive output son
	,.debug_reg1			(debug_reg1		)
	,.debug_reg2			(debug_reg2		)
	,.debug_reg3			(debug_reg3		)
	//,.debug_reg4			(debug_reg4		)
	//,.debug_reg5			(debug_reg5		)
	);

	proactive_beh_pul_axis#(
	.BHA_NUM 				(A_BHA_NUM  	 	)	//Number of active behaviors
)proactive_beh_pul_axis_u0(
    .clk_i                 	(clk_i				)
    ,.rst_i                	(rst_i				)
    ,.i_time_1ms_vld       	(i_time_1ms_vld 	)
    ,.i_time_1s_vld        	(i_time_1s_vld  	)
    ,.pre_sta_allow        	(a_pre_sta_allow	)
    ,.post_sta_allow       	(a_post_sta_allow	)
	,.a_en			       	(a_en				)
    ,.a_bhv_id             	(a_bhv_id       	)
    ,.a_bhv_vld            	(sync_a_bhv_vld      	)
    ,.a_tx_ot              	(a_tx_ot        	)
    ,.a_tx_result_rpt	   	(a_tx_result_rpt	)
	,.a_tx_result_vld      	(sync_a_tx_result_vld	)
    ,.ec_cha_st            	(ec_cha_st			)
    ,.a_tx_id              	(a_tx_id        	)
    ,.a_alm_num            	(a_alm_num      	)
	,.a_bhv_id_r			(a_bhv_id_r			)
	,.state_monitor_o		(debug_reg1			)
    ,.irq_o                	(irq_a				)
    ,.irq_ack_i       		(irq_a_grant		)
//----------------------------------------------------- user logic begin -----------------------------------------------------//
	,.i_servo_ready			(i_servo_ready      )
    ,.i_servo_done			(i_servo_done       )
    ,.i_axis_limf			(i_axis_limf        )
    ,.i_axis_zero			(i_axis_zero         )
    ,.i_axis_limb			(i_axis_limb        )
    ,.i_emerge_stop_signal	(i_emerge_stop_signal)
    ,.i_dv_alarm			(i_dv_alarm			)
    ,.o_dv_pulse			(o_dv_pulse			)
    ,.o_dv_dir				(o_dv_dir			)
    ,.i_pause				(b_pause			)
    ,.i_stop				(b_stop				)	
	,.action_busy			(action_busy)
	,.action_done			(action_done)
	,.action_error			(action_error)

    ,.rserv_dir				(param16[0]			    )
    ,.rserv_step_pulse		(param37				)
    ,.rserv_target_pulse	(param36				)
    ,.rcfg_home_spd			(param35				)
    ,.rcfg_home_acc			(param5					)
    ,.rcfg_home_dec			(param34				)
    ,.rcfg_jog_spd			(param35				)
    ,.rcfg_jog_acc			(param5					)
    ,.rcfg_jog_dec			(param34				)
    ,.rcfg_move_spd			(param35				)
    ,.rcfg_move_acc			(param5					)
    ,.rcfg_move_dec			(param34				)
    ,.rcfg_spd_max			(param1					)
    ,.rcfg_acc_max			(param2					)
    ,.rcfg_dec_max			(param3					)
    ,.rcfg_touch_spd		(param33				)

	,.r_pf_abspos			(param51				)
//----------------------------------------------------- user logic end -------------------------------------------------------//
    );


	status_beh_pul_axis#(
		.BHA_NUM(B_BHA_NUM	)
)status_beh_pul_axis_u0(
	.clk_i			        (clk_i				)
	,.rst_i			        (rst_i				)
	,.i_time_1ms_vld		(i_time_1ms_vld 	)
	,.i_time_1s_vld 		(i_time_1s_vld  	)
	,.pre_sta_allow	        (b_pre_sta_allow	)
	,.post_sta_allow	    (b_post_sta_allow	)
	,.b_en	                (b_en				)
	,.b_bhv_id              (b_bhv_id			)
	,.state_monitor_o		(debug_reg2			)
	,.b_tx_ot               (b_tx_ot			)
	,.b_tx_result_rpt       (b_tx_result_rpt	)
	,.b_tx_result_vld       (sync_b_tx_result_vld	)
	,.ec_chb_st             (ec_chb_st			)
	,.b_tx_id               (b_tx_id			)
	,.b_alm_num             (b_alm_num			)
	,.irq_o			        (irq_b				)
	,.irq_ack_i	            (irq_b_grant		)	

//----------------------------------------------------- user logic begin -----------------------------------------------------//
    ,.dv_alarm				(i_dv_alarm			)
    ,.o_dv_reset			(o_dv_reset			)
    ,.o_dv_son				(o_dv_son			)
    ,.b_pause				(b_pause			)
    ,.b_stop				(b_stop				)
//----------------------------------------------------- user logic end -------------------------------------------------------//
    );

	tim_beh_pul_axis#(
		.BHA_NUM(C_BHA_NUM	)
	) tim_beh_pul_axis_u0(
    .clk_i                      (clk_i          	)
	,.rst_i              	    (rst_i         		)
	,.i_time_1ms_vld   	        (i_time_1ms_vld 	)
	,.i_time_1s_vld    	        (i_time_1s_vld  	)
	,.task_time_cnt	            (task_time_cnt		)
	,.pre_sta_allow		        (c_pre_sta_allow	)
	,.post_sta_allow	        (c_post_sta_allow	)
	,.c_en				        (c_en				)
	,.c_bhv_id                  (c_bhv_id			)
	,.state_monitor_o			(debug_reg3			)
	,.c_tx_ot          	        (c_tx_ot			)
	,.c_tx_result_rpt  	        (c_tx_result_rpt	)
	,.c_tx_result_vld           (sync_c_tx_result_vld	)
	,.ec_chc_st	                (ec_chc_st			)
	,.c_tx_id         	        (c_tx_id			)
	,.c_alm_num                 (c_alm_num			)
	,.c_gap_crl                 (c_gap_crl			)
	,.irq_o 					(irq_c				)
	,.irq_ack_i                 (irq_c_grant		)
   );

	pre_post_sta_check_pul_axis#(
			.A_BHA_NUM			(A_BHA_NUM	 		)    ,
			.B_BHA_NUM			(B_BHA_NUM	 		),
			.C_BHA_NUM			(C_BHA_NUM	 		)
	)pre_post_sta_check_pul_axis_u0(
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
			.a_en				(a_en			),
			.b_en				(b_en			),
			.c_en				(c_en			),
			.a_bhv_id			(a_bhv_id_r		),
			.b_bhv_id			(b_bhv_id		),
			.c_bhv_id			(c_bhv_id		),
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

//----------------------------------------------------- user logic begin -----------------------------------------------------//
		,.action_busy			(action_busy		)
		,.action_done			(action_done		)
		,.action_error			(action_error		)
		,.dv_alarm				(i_dv_alarm			)
		,.i_emerge_stop_signal	(i_emerge_stop_signal)

		,.rctrl_drive_on		(param21			)
		,.rctrl_drive_reset		(param29			)
		,.rctrl_resume			(param28			)
		,.rctrl_pause			(param26			)
		,.rctrl_stop			(param27			)
		
		,.b_clr_pause			(b_clr_pause		)
		,.b_clr_resume			(b_clr_resume		)
		,.b_clr_stop			(b_clr_stop			)

		,.i_servo_ready			(i_servo_ready      )
    	,.i_servo_done			(i_servo_done       )

		,.i_axis_limf			(i_axis_limf        )
		,.i_axis_limb			(i_axis_limb        )
//----------------------------------------------------- user logic end -------------------------------------------------------//
    );

	irq_3i1o_arbitrator_pul_axis irq_3i1o_arbitrator_u0(
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
		,.irq_ack_a_i		(sync_a_tx_result_vld	)
		,.irq_ack_b_i		(sync_b_tx_result_vld	)
		,.irq_ack_c_i		(sync_c_tx_result_vld	)
    );

endmodule
