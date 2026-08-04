`include "./../include_files/components_param.vh"
`include "./../include_files/depot_addr_map.vh"
`define RLL_ENB
`define FLOW_ENB

module emcc_mix_top 
#(
     parameter  PS_REG_AWIDTH   =   20
    ,parameter  PS_REG_DWIDTH   =   32
    ,parameter  RAM_DEPTH       =   4096
    ,parameter  RAM_DWIDTH      =   32
    ,parameter  RAM_AWIDTH      =   $clog2(RAM_DEPTH)
    ,parameter  BAG_LENGTH      =   512  
    ,parameter  SIMULATION_SOFT =   0  
    ,parameter  RS485_1_USER_NUMBER =   32  
    ,parameter  RS485_2_USER_NUMBER =   32  
)
(
     input                               clk
    ,input                               reset
    ,input                               clk_10m
    ,input  wire    [63:0]              di_mst_msg
    ,output wire    [31:0]              do_relay_mst_msg
    ,input  wire    [31:0]              ai_mst_msg
    ,input  wire                        slv_cfg_msg_rden
    ,input  wire    [RAM_AWIDTH-1:0]    slv_cfg_msg_addr
    ,output wire    [RAM_DWIDTH-1:0]    slv_cfg_msg_dat

    ,input  wire    [3:0]               slv_sta_msg_vld     
    ,input  wire    [RAM_AWIDTH-1:0]    slv_sta_msg_addr
    ,input  wire    [RAM_DWIDTH-1:0]    slv_sta_msg_dat
    ,input  wire                        ps_reg_clk
    ,input  wire                        ps_reg_reset
    ,input  wire                        ps_reg_we
    ,input  wire    [PS_REG_AWIDTH-1:0] ps_reg_addr
    ,input  wire    [PS_REG_DWIDTH-1:0] ps_reg_wr_dat
    ,input  wire                        ps_reg_re
    ,input  wire    [PS_REG_AWIDTH-1:0] ps_reg_rd_addr
    ,output wire                        ps_flow_rd_vld
    ,output wire    [PS_REG_DWIDTH-1:0] ps_flow_rd_dat
    ,output wire                        ps_comp_rd_vld
    ,output wire    [PS_REG_DWIDTH-1:0] ps_comp_rd_dat
    ,output wire    [511:0]             emcc_irq  // components irp
    ,output wire    [511:0]             flow_irq  // flow irp,One control flow corresponds to one interrupt number,
                                                   // ensuring that component interrupts and flow interrupts are not repeated
	
    ,output wire [RS485_1_USER_NUMBER-1:0] rs485_1_user_req
    ,input  wire [RS485_1_USER_NUMBER-1:0] rs485_1_user_grant
    ,input  wire [RS485_1_USER_NUMBER-1:0] rs485_1_user_rx
    ,output wire [RS485_1_USER_NUMBER-1:0] rs485_1_user_tx
    ,output wire [RS485_1_USER_NUMBER-1:0] rs485_1_user_de


    
    ,output wire [RS485_1_USER_NUMBER-1:0] rs485_2_user_req
    ,input  wire [RS485_1_USER_NUMBER-1:0] rs485_2_user_grant
    ,input  wire [RS485_1_USER_NUMBER-1:0] rs485_2_user_rx
    ,output wire [RS485_1_USER_NUMBER-1:0] rs485_2_user_tx
    ,output wire [RS485_1_USER_NUMBER-1:0] rs485_2_user_de
	
    ,input  wire                        main_232_rxd
    ,output wire                        main_232_txd
	
    ,output  wire                       o_spi_cs_n // ADC
    ,output  wire                       o_spi_clk 
    ,output  wire                       o_spi_mosi
    ,input   wire                       i_spi_miso
	
    ,input  wire                        i_wr_cfg_data_done
    ,input  wire                        i_do_dbg_data_vld
    ,input  wire    [31:0]              iv_io_mode_cfg // set and select mode and type of io
    ,output wire    [31:0]              ov_rd_io_data  // read input or output io data
    ,input  wire    [31:0]              iv_do_dbg_data // write output io data
	
    ,output  wire [3:0]    ov_dbg_enable
	
	,input   wire          i_time_1ms_vld
    ,input   wire          i_time_10ms_vld
    ,input   wire          i_time_100ms_vld
    ,input   wire          i_time_1s_vld
    
    ,input  wire    [7:0]               i_dv_alarm      
    ,output wire    [7:0]               o_dv_pulse
    ,output wire    [7:0]               o_dv_dir
    ,output wire    [7:0]               o_dv_reset
    ,output wire    [7:0]               o_dv_son
	
	    
    ,output   wire  [RAM_DWIDTH*3-1:0] ov_di_slv_msg[RAM_DWIDTH-1:0]
    ,output   wire  [RAM_DWIDTH*3-1:0] ov_do_slv_msg[RAM_DWIDTH-1:0]
    ,input    wire  [RAM_DWIDTH*3-1:0] iv_di_slv_msg[RAM_DWIDTH-1:0]
    ,input    wire  [RAM_DWIDTH*3-1:0] iv_do_slv_msg[RAM_DWIDTH-1:0]
    ,input    wire  [RAM_DWIDTH-1:0]   iv_di_debug
    ,input    wire  [RAM_DWIDTH-1:0]   iv_do_debug
	
);
    localparam  TOKEN_DWIDTH   =   32  ;
    localparam  BIAS_NUM       =   0   ;
    localparam  COMP_BIAS_NUM  =   0   ;
    localparam  COMP_NUM       =   512 ;
    
    wire    [BIAS_NUM+COMP_NUM-1:BIAS_NUM]              map_irq;
    wire                        sub_comp_rd_vld[COMP_BIAS_NUM+COMP_NUM-1:COMP_BIAS_NUM];
    wire    [PS_REG_DWIDTH-1:0] sub_comp_rd_dat[COMP_BIAS_NUM+COMP_NUM-1:COMP_BIAS_NUM];
    
//    emcc_token_if #(.DATA_WIDTH(TOKEN_DWIDTH))  roller_s00_token_if[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
//    emcc_token_if #(.DATA_WIDTH(TOKEN_DWIDTH))  roller_s01_token_if[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
//    emcc_token_if #(.DATA_WIDTH(TOKEN_DWIDTH))  roller_s02_token_if[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
	
//	emcc_flow_if flow_cfg_if[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
	
	wire time_1ms_vld   = i_time_1ms_vld  ;
    wire time_10ms_vld  = i_time_10ms_vld ;
    wire time_100ms_vld = i_time_100ms_vld;
    wire time_1s_vld    = i_time_1s_vld   ;
	

    wire    [RAM_DWIDTH*2-1:0]          do_regoin_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH*3-1:0]          di_regoin_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH*3-1:0]          di_regoin_msg_p[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH*4-1:0]          ai_regoin_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_00_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_01_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_02_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_03_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_04_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_05_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_06_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_07_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs485_00_msg[RAM_DWIDTH-1:0];
    wire                                rs232_00_flag;
    wire                                rs232_01_flag;
    wire                                rs232_02_flag;
    wire                                rs232_03_flag;
    wire                                rs232_04_flag;
    wire                                rs232_05_flag;
    wire                                rs232_06_flag;
    wire                                rs232_07_flag;
    wire                                rs485_00_flag;
    wire    [RAM_DWIDTH-1:0]            pul_motor0_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            pul_motor1_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            pul_motor2_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            pul_motor3_msg[RAM_DWIDTH-1:0];
    wire                                pul_motor0_flag;
    wire                                pul_motor1_flag;
    wire                                pul_motor2_flag;
    wire                                pul_motor3_flag;
    
	
    wire    [3:0]                       sys_wea[RAM_DWIDTH-1:0];
    wire    [RAM_AWIDTH-1:0]            sys_addra[RAM_DWIDTH-1:0];

    wire    [RAM_DWIDTH-1:0]            pre_r_uuid[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH*2-1:0]          do_regoin_r_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH*2-1:0]          do_regoin_r_msg_n[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH*3-1:0]          di_regoin_r_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH*4-1:0]          ai_regoin_r_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_00_send_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_01_send_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_02_send_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_03_send_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_04_send_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_05_send_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_06_send_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs232_07_send_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            rs485_00_send_msg[RAM_DWIDTH-1:0];
    wire                                rs232_00_r_flag;
    wire                                rs232_01_r_flag;
    wire                                rs232_02_r_flag;
    wire                                rs232_03_r_flag;
    wire                                rs232_04_r_flag;
    wire                                rs232_05_r_flag;
    wire                                rs232_06_r_flag;
    wire                                rs232_07_r_flag;
    wire                                rs485_00_r_flag;
    wire    [RAM_DWIDTH-1:0]            pul_motor0_r_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            pul_motor1_r_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            pul_motor2_r_msg[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]            pul_motor3_r_msg[RAM_DWIDTH-1:0];
    wire                                pul_motor0_r_flag;
    wire                                pul_motor1_r_flag;
    wire                                pul_motor2_r_flag;
    wire                                pul_motor3_r_flag;
    

    wire    [31:0]              do_mst_msg      ;
    wire    [31:0]              do_mst_msg_force      ;
    assign ov_dbg_enable = 0;
    
	assign do_relay_mst_msg = ~di_mst_msg[0]?do_mst_msg_force:do_mst_msg;
	
    vio_0 vio (
      .clk(clk),                // input wire clk
      .probe_in0 (di_mst_msg),    // input wire [63 : 0] probe_in0
      .probe_out0(do_mst_msg_force)  // output wire [31 : 0] probe_out0
    );

	pkg_route
    #(
         .RAM_DEPTH             (RAM_DEPTH          )
        ,.RAM_DWIDTH            (RAM_DWIDTH         )
        ,.BAG_LENGTH            (BAG_LENGTH         )
    )
    pkg_route_u
    (
         .clk                   (clk                )
        ,.rst                   (reset              )

        ,.slv_cfg_msg_rden      (slv_cfg_msg_rden   )
        ,.slv_cfg_msg_addr      (slv_cfg_msg_addr   )
        ,.slv_cfg_msg_dat       (slv_cfg_msg_dat    )
        ,.slv_sta_msg_vld       (slv_sta_msg_vld    )
        ,.slv_sta_msg_addr      (slv_sta_msg_addr   )
        ,.slv_sta_msg_dat       (slv_sta_msg_dat    )

        //slave to master
        ,.do_regoin_msg         (do_regoin_msg      )
        ,.di_regoin_msg         (di_regoin_msg_p    )
        ,.ai_regoin_msg         (ai_regoin_msg      )
        ,.rs232_1st_msg         (rs232_00_msg        )
        ,.rs232_2nd_msg         (rs232_01_msg        )
        ,.rs232_3rd_msg         (rs232_02_msg        )
        ,.rs232_4th_msg         (rs232_03_msg        )
        ,.rs232_5th_msg         (rs232_04_msg        )
        ,.rs232_6th_msg         (rs232_05_msg        )
        ,.rs232_7th_msg         (rs232_06_msg        )
        ,.rs232_8th_msg         (rs232_07_msg        )
        ,.rs485_1st_msg         (rs485_00_msg       ) 
        ,.rs232_1st_flag        (rs232_00_flag     )
        ,.rs232_2nd_flag        (rs232_01_flag     )
        ,.rs232_3rd_flag        (rs232_02_flag     )
        ,.rs232_4th_flag        (rs232_03_flag     )
        ,.rs232_5th_flag        (rs232_04_flag     )
        ,.rs232_6th_flag        (rs232_05_flag     )
        ,.rs232_7th_flag        (rs232_06_flag     )
        ,.rs232_8th_flag        (rs232_07_flag     )
        ,.rs485_1st_flag        (rs485_00_flag     )
        ,.pul_motor0_msg        (pul_motor0_msg     )
        ,.pul_motor1_msg        (pul_motor1_msg     )
        ,.pul_motor2_msg        (pul_motor2_msg     )
        ,.pul_motor3_msg        (pul_motor3_msg     )
        ,.pul_motor0_flag       (pul_motor0_flag    )
        ,.pul_motor1_flag       (pul_motor1_flag    )
        ,.pul_motor2_flag       (pul_motor2_flag    )
        ,.pul_motor3_flag       (pul_motor3_flag    )

        //master to slave
        ,.pre_r_uuid            (pre_r_uuid            )
        ,.do_regoin_r_msg       (do_regoin_r_msg_n     )
        ,.di_regoin_r_msg       (di_regoin_r_msg       )
        ,.ai_regoin_r_msg       (ai_regoin_r_msg       )
        ,.rs232_1st_r_msg       (rs232_00_send_msg       )
        ,.rs232_2nd_r_msg       (rs232_01_send_msg       )
        ,.rs232_3rd_r_msg       (rs232_02_send_msg       )
        ,.rs232_4th_r_msg       (rs232_03_send_msg       )
        ,.rs232_5th_r_msg       (rs232_04_send_msg       )
        ,.rs232_6th_r_msg       (rs232_05_send_msg       )
        ,.rs232_7th_r_msg       (rs232_06_send_msg       )
        ,.rs232_8th_r_msg       (rs232_07_send_msg       )
        ,.rs485_1st_r_msg       (rs485_00_send_msg     )
        ,.rs232_1st_r_flag      (rs232_00_r_flag       )
        ,.rs232_2nd_r_flag      (rs232_01_r_flag       )
        ,.rs232_3rd_r_flag      (rs232_02_r_flag       )
        ,.rs232_4th_r_flag      (rs232_03_r_flag       )
        ,.rs232_5th_r_flag      (rs232_04_r_flag       )
        ,.rs232_6th_r_flag      (rs232_05_r_flag       )
        ,.rs232_7th_r_flag      (rs232_06_r_flag       )
        ,.rs232_8th_r_flag      (rs232_07_r_flag       )
        ,.rs485_1st_r_flag      (rs485_00_r_flag       )
        ,.pul_motor0_r_msg      (pul_motor0_r_msg      )
        ,.pul_motor1_r_msg      (pul_motor1_r_msg      )
        ,.pul_motor2_r_msg      (pul_motor2_r_msg      )
        ,.pul_motor3_r_msg      (pul_motor3_r_msg      )
        ,.pul_motor0_r_flag     (pul_motor0_r_flag     )
        ,.pul_motor1_r_flag     (pul_motor1_r_flag     )
        ,.pul_motor2_r_flag     (pul_motor2_r_flag     )
        ,.pul_motor3_r_flag     (pul_motor3_r_flag     )
													   
        ,.sys_addra             (sys_addra             )
        ,.sys_wea               (sys_wea               )
    );
    
	assign di_regoin_msg[0] = iv_di_debug[0] ? iv_di_slv_msg[0] : di_regoin_msg_p[0];
    assign di_regoin_msg[1] = iv_di_debug[1] ? iv_di_slv_msg[1] : di_regoin_msg_p[1];
    assign di_regoin_msg[2] = iv_di_debug[2] ? iv_di_slv_msg[2] : di_regoin_msg_p[2];
    assign di_regoin_msg[3] = iv_di_debug[3] ? iv_di_slv_msg[3] : di_regoin_msg_p[3];
    assign di_regoin_msg[4] = iv_di_debug[4] ? iv_di_slv_msg[4] : di_regoin_msg_p[4];
    assign di_regoin_msg[5] = iv_di_debug[5] ? iv_di_slv_msg[5] : di_regoin_msg_p[5];
    assign di_regoin_msg[6] = iv_di_debug[6] ? iv_di_slv_msg[6] : di_regoin_msg_p[6];
    assign di_regoin_msg[7] = iv_di_debug[7] ? iv_di_slv_msg[7] : di_regoin_msg_p[7];
    assign di_regoin_msg[8] = iv_di_debug[8] ? iv_di_slv_msg[8] : di_regoin_msg_p[8];
    assign di_regoin_msg[9] = iv_di_debug[9] ? iv_di_slv_msg[9] : di_regoin_msg_p[9];
    assign do_regoin_r_msg_n[0] = iv_do_debug[0] ? iv_do_slv_msg[0] : do_regoin_r_msg[0];
    assign do_regoin_r_msg_n[1] = iv_do_debug[1] ? iv_do_slv_msg[1] : do_regoin_r_msg[1];
    assign do_regoin_r_msg_n[2] = iv_do_debug[2] ? iv_do_slv_msg[2] : do_regoin_r_msg[2];
    assign do_regoin_r_msg_n[3] = iv_do_debug[3] ? iv_do_slv_msg[3] : do_regoin_r_msg[3];
    assign do_regoin_r_msg_n[4] = iv_do_debug[4] ? iv_do_slv_msg[4] : do_regoin_r_msg[4];
    assign do_regoin_r_msg_n[5] = iv_do_debug[5] ? iv_do_slv_msg[5] : do_regoin_r_msg[5];
    assign do_regoin_r_msg_n[6] = iv_do_debug[6] ? iv_do_slv_msg[6] : do_regoin_r_msg[6];
    assign do_regoin_r_msg_n[7] = iv_do_debug[7] ? iv_do_slv_msg[7] : do_regoin_r_msg[7];
    assign do_regoin_r_msg_n[8] = iv_do_debug[8] ? iv_do_slv_msg[8] : do_regoin_r_msg[8];
    assign do_regoin_r_msg_n[9] = iv_do_debug[9] ? iv_do_slv_msg[9] : do_regoin_r_msg[9];
    
    assign ov_di_slv_msg[0] = di_regoin_msg[0];
    assign ov_di_slv_msg[1] = di_regoin_msg[1];
    assign ov_di_slv_msg[2] = di_regoin_msg[2];
    assign ov_di_slv_msg[3] = di_regoin_msg[3];
    assign ov_di_slv_msg[4] = di_regoin_msg[4];
    assign ov_di_slv_msg[5] = di_regoin_msg[5];
    assign ov_di_slv_msg[6] = di_regoin_msg[6];
    assign ov_di_slv_msg[7] = di_regoin_msg[7];
    assign ov_di_slv_msg[8] = di_regoin_msg[8];
    assign ov_di_slv_msg[9] = di_regoin_msg[9];
    assign ov_do_slv_msg[0] = do_regoin_r_msg_n[0];
    assign ov_do_slv_msg[1] = do_regoin_r_msg_n[1];
    assign ov_do_slv_msg[2] = do_regoin_r_msg_n[2];
    assign ov_do_slv_msg[3] = do_regoin_r_msg_n[3];
    assign ov_do_slv_msg[4] = do_regoin_r_msg_n[4];
    assign ov_do_slv_msg[5] = do_regoin_r_msg_n[5];
    assign ov_do_slv_msg[6] = do_regoin_r_msg_n[6];
    assign ov_do_slv_msg[7] = do_regoin_r_msg_n[7];
    assign ov_do_slv_msg[8] = do_regoin_r_msg_n[8];
    assign ov_do_slv_msg[9] = do_regoin_r_msg_n[9];
	
    ps_rd_dat_route
    #(
         .CHANNEL_BIAS          (COMP_BIAS_NUM      )
        ,.CHANNEL_NUM           (COMP_NUM           )
        ,.PS_REG_DWIDTH         (PS_REG_DWIDTH      )
    )
    ps_rd_dat_route_u2
    (
         .ps_reg_clk            (ps_reg_clk         )
        ,.ps_reg_reset          (ps_reg_reset       )
        ,.ps_reg_rd_vld         (ps_comp_rd_vld     )
        ,.ps_reg_rd_dat         (ps_comp_rd_dat     )

        ,.ds_rd_vld             (sub_comp_rd_vld    )
        ,.ds_rd_dat             (sub_comp_rd_dat    )
    );
	wire    [4:0]                       slv_board_id;
    assign  slv_board_id = slv_sta_msg_addr[RAM_AWIDTH-1:9];
	wire ext_emerg_stop;
	wire ext_pause_sig ;
	`ifdef RLL_ENB
	// --------------------------------------------------------------------------------------------------------------------------------------
	// -------------------------------- The following is the roller components --------------------------------------------------------------
	// --------------------------------------------------------------------------------------------------------------------------------------
	`endif
	`ifdef FLOW_ENB
    // ------------------------------------------------------------------------------------------------------------------------------------
    // -------------------------------- The following is the flow components --------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------------------------------------------
    assign  emcc_irq[0]   	= map_irq[0];
    assign  emcc_irq[1]   	= map_irq[1];
    assign  emcc_irq[2]   	= map_irq[2];
    assign  emcc_irq[3]   	= map_irq[3];
    assign  emcc_irq[4]   	= map_irq[4];
    assign  emcc_irq[5]   	= map_irq[5];
    assign  emcc_irq[6]   	= map_irq[6];
    assign  emcc_irq[7]   	= map_irq[7];
    assign  emcc_irq[8]   	= map_irq[8];
    assign  emcc_irq[9]   	= map_irq[9];
    assign  emcc_irq[10]   	= map_irq[10];
    assign  emcc_irq[11]   	= map_irq[11];
    assign  emcc_irq[12]   	= map_irq[12];
    assign  emcc_irq[13]   	= map_irq[13];
    assign  emcc_irq[14]   	= map_irq[14];
    assign  emcc_irq[15]   	= map_irq[15];
    assign  emcc_irq[16]   	= map_irq[16];
    assign  emcc_irq[17]   	= map_irq[17];
    assign  emcc_irq[18]   	= map_irq[18];
    assign  emcc_irq[19]   	= map_irq[19];
    assign  emcc_irq[20]   	= map_irq[20];
    assign  emcc_irq[21]   	= map_irq[21];
    assign  emcc_irq[22]   	= map_irq[22];
    assign  emcc_irq[23]   	= map_irq[23];
    assign  emcc_irq[25]   	= map_irq[25];
    assign  emcc_irq[26]   	= map_irq[26];
	assign  emcc_irq[27]   	= map_irq[27];
	
	//==========================================================================================================//
	// --------------------------------------------user component_v6_inst---------------------------------------//
	//==========================================================================================================//

	
			ec_1di #(
				.REG_SPACE_BIAS 		(20'h800)	//B010_0800
				,.REG_SPACE_SIZE 		(512					)
			) ec_1di_u0 (	
				.clk_i           		(clk					)
				,.rst             		(reset					)
				,.i_time_1ms_vld  		(time_1ms_vld			)
				,.i_time_1s_vld   		(time_1s_vld			)
				,.ps_reg_clk			(ps_reg_clk				)
				,.ps_reg_reset   		(ps_reg_reset   		)
				,.i_st_wr_en      		(ps_reg_we				)
				,.i_st_wr_addr    		(ps_reg_addr			)
				,.i_st_wr_data    		(ps_reg_wr_dat			)
				,.i_st_rd_en      		(ps_reg_re				)
				,.i_st_rd_addr    		(ps_reg_rd_addr			)
				,.o_st_rd_data    		(sub_comp_rd_dat[0]		)
				,.o_st_rd_vld     		(sub_comp_rd_vld[0]		)
				,.di              		(~di_mst_msg[0]         )
				,.o_intr_irq      		(map_irq[0] 			)
			);

			wire m_1do_do;
			ec_1do#(
				.REG_SPACE_BIAS 		(20'ha00	),	//Component offset address
				.REG_SPACE_SIZE 		(512					)	//Component register size
			)ec_1do_u0(
				.clk_i					(clk					)
				,.rst					(reset					)
				,.i_time_1ms_vld		(time_1ms_vld			)
				,.i_time_1s_vld 		(time_1s_vld			)
				,.ps_reg_clk			(ps_reg_clk				)
				,.ps_reg_reset			(ps_reg_reset			)
				,.i_st_wr_en			(ps_reg_we				)
				,.i_st_wr_addr  		(ps_reg_addr			)
				,.i_st_wr_data  		(ps_reg_wr_dat			)
				,.i_st_rd_en    		(ps_reg_re				)
				,.i_st_rd_addr  		(ps_reg_rd_addr			)
				,.o_st_rd_data  		(sub_comp_rd_dat[1]		)
				,.o_st_rd_vld   		(sub_comp_rd_vld[1]		)
				,.do_o					(m_1do_do			    )
				,.o_intr_irq			(map_irq[1]			    )
			);
            assign   do_mst_msg[0] = ~m_1do_do;

			wire [1:0] m_2di_2do_do;
			ec_2di_2do#(
				.REG_SPACE_BIAS			(20'hc00	),	//Component offset address
				.REG_SPACE_SIZE			(512					)
			)ec_2di_2do_u0(
				.clk_i					(clk					)
				,.rst					(reset					)
				,.i_time_1ms_vld		(time_1ms_vld			)
				,.i_time_1s_vld 		(time_1s_vld			)
				,.ps_reg_clk			(ps_reg_clk				)
				,.ps_reg_reset			(ps_reg_reset			)
				,.i_st_wr_en			(ps_reg_we				)
				,.i_st_wr_addr  		(ps_reg_addr			)
				,.i_st_wr_data  		(ps_reg_wr_dat			)
				,.i_st_rd_en    		(ps_reg_re				)
				,.i_st_rd_addr  		(ps_reg_rd_addr			)
				,.o_st_rd_data  		(sub_comp_rd_dat[2]		)
				,.o_st_rd_vld   		(sub_comp_rd_vld[2]		)
				,.di_i					(~di_mst_msg[5:3]	    )
				,.do_o					(m_2di_2do_do			)
				,.o_intr_irq			(map_irq[2]				)
			);
            assign   do_mst_msg[2:1] = ~m_2di_2do_do;

            wire [1:0] m_3di_2do_do;
			ec_3di_2do#(
				.REG_SPACE_BIAS			(20'he00 ),	//Component offset address h'800
				.REG_SPACE_SIZE			(`REG_SPACE_SIZE        )
			)ec_3di_2do_u0(
				.clk_i					(clk					)
				,.rst					(reset					)
				,.i_time_1ms_vld		(time_1ms_vld			)
				,.i_time_1s_vld 		(time_1s_vld			)
				,.ps_reg_clk			(ps_reg_clk				)
				,.ps_reg_reset			(ps_reg_reset			)
				,.i_st_wr_en			(ps_reg_we				)
				,.i_st_wr_addr  		(ps_reg_addr			)
				,.i_st_wr_data  		(ps_reg_wr_dat			)
				,.i_st_rd_en    		(ps_reg_re				)
				,.i_st_rd_addr  		(ps_reg_rd_addr			)
				,.o_st_rd_data  		(sub_comp_rd_dat[3]		)
				,.o_st_rd_vld   		(sub_comp_rd_vld[3]		)
				,.di_i					(~di_mst_msg[5:3]	    )
				,.do_o					(m_3di_2do_do	        )
				,.o_intr_irq			(map_irq[3]		        )
			);
            assign   do_mst_msg[4:3] = ~m_3di_2do_do;

            wire [0:0] m_3di_1do_do;
			ec_3di_1do#(
				.REG_SPACE_BIAS			(20'h1000  ),	//Component offset address h'a00
				.REG_SPACE_SIZE			(`REG_SPACE_SIZE        )
			)ec_3di_1do_u0(
				.clk_i					(clk					)
				,.rst					(reset					)
				,.i_time_1ms_vld		(time_1ms_vld			)
				,.i_time_1s_vld 		(time_1s_vld			)
				,.ps_reg_clk			(ps_reg_clk				)
				,.ps_reg_reset			(ps_reg_reset			)
				,.i_st_wr_en			(ps_reg_we				)
				,.i_st_wr_addr  		(ps_reg_addr			)
				,.i_st_wr_data  		(ps_reg_wr_dat			)
				,.i_st_rd_en    		(ps_reg_re				)
				,.i_st_rd_addr  		(ps_reg_rd_addr			)
				,.o_st_rd_data  		(sub_comp_rd_dat[4]		)
				,.o_st_rd_vld   		(sub_comp_rd_vld[4]		)
				,.di_i					(~di_mst_msg[8:6]	    )
				,.do_o					(m_3di_1do_do	        )
				,.o_intr_irq			(map_irq[4]		        )
			);
            assign   do_mst_msg[5] = ~m_3di_1do_do;

            wire [0:0] m_1di_1do_do;
			ec_1di_1do#(
				.REG_SPACE_BIAS			(20'h1200  ),	//Component offset address h'a00
				.REG_SPACE_SIZE			(`REG_SPACE_SIZE        )
			)ec_1di_1do_u0(
				.clk_i					(clk					)
				,.rst					(reset					)
				,.i_time_1ms_vld		(time_1ms_vld			)
				,.i_time_1s_vld 		(time_1s_vld			)
				,.ps_reg_clk			(ps_reg_clk				)
				,.ps_reg_reset			(ps_reg_reset			)
				,.i_st_wr_en			(ps_reg_we				)
				,.i_st_wr_addr  		(ps_reg_addr			)
				,.i_st_wr_data  		(ps_reg_wr_dat			)
				,.i_st_rd_en    		(ps_reg_re				)
				,.i_st_rd_addr  		(ps_reg_rd_addr			)
				,.o_st_rd_data  		(sub_comp_rd_dat[5]		)
				,.o_st_rd_vld   		(sub_comp_rd_vld[5]		)
				,.di_i					(~di_mst_msg[9]	        )
				,.do_o					(m_1di_1do_do	        )
				,.o_intr_irq			(map_irq[5]		        )
			);
            assign   do_mst_msg[6] = ~m_1di_1do_do;

            wire [1:0] m_4di_2do_do;
			ec_4di_2do#(
				.REG_SPACE_BIAS			(20'h1400  ),	//Component offset address h'c00
				.REG_SPACE_SIZE			(`REG_SPACE_SIZE        )
			)ec_4di_2do_u0(
				.clk_i					(clk					)
				,.rst					(reset					)
				,.i_time_1ms_vld		(time_1ms_vld			)
				,.i_time_1s_vld 		(time_1s_vld			)
				,.ps_reg_clk			(ps_reg_clk				)
				,.ps_reg_reset			(ps_reg_reset			)
				,.i_st_wr_en			(ps_reg_we				)
				,.i_st_wr_addr  		(ps_reg_addr			)
				,.i_st_wr_data  		(ps_reg_wr_dat			)
				,.i_st_rd_en    		(ps_reg_re				)
				,.i_st_rd_addr  		(ps_reg_rd_addr			)
				,.o_st_rd_data  		(sub_comp_rd_dat[6]		)
				,.o_st_rd_vld   		(sub_comp_rd_vld[6]		)
				,.di_i					(~di_mst_msg[13:10]	    )
				,.do_o					(m_4di_2do_do	        )
				,.o_intr_irq			(map_irq[6]		        )
			);
            assign   do_mst_msg[8:7] = ~m_4di_2do_do;

            wire [3:0] m_3led_do;
			ec_3led#(
				.REG_SPACE_BIAS			(20'h1600  ),	//Component offset address h'c00
				.REG_SPACE_SIZE			(`REG_SPACE_SIZE        )
            )ec_3led_u0(
				.clk_i					(clk					)
				,.rst					(reset					)
				,.i_time_1ms_vld		(time_1ms_vld			)
				,.i_time_1s_vld 		(time_1s_vld			)
				,.ps_reg_clk			(ps_reg_clk				)
				,.ps_reg_reset			(ps_reg_reset			)
				,.i_st_wr_en			(ps_reg_we				)
				,.i_st_wr_addr  		(ps_reg_addr			)
				,.i_st_wr_data  		(ps_reg_wr_dat			)
				,.i_st_rd_en    		(ps_reg_re				)
				,.i_st_rd_addr  		(ps_reg_rd_addr			)
				,.o_st_rd_data  		(sub_comp_rd_dat[7]		)
				,.o_st_rd_vld   		(sub_comp_rd_vld[7]		)
				,.do_o					(m_3led_do	            )
				,.o_intr_irq			(map_irq[7]		        )
			);
            assign   do_mst_msg[12:9] = ~m_3led_do;


			ec_5di#(
				.REG_SPACE_BIAS			(20'h1800  ),	//Component offset address h'c00
				.REG_SPACE_SIZE			(`REG_SPACE_SIZE        )
            )ec_5di_u0(
				.clk_i					(clk					)
				,.rst					(reset					)
				,.i_time_1ms_vld		(time_1ms_vld			)
				,.i_time_1s_vld 		(time_1s_vld			)
				,.ps_reg_clk			(ps_reg_clk				)
				,.ps_reg_reset			(ps_reg_reset			)
				,.i_st_wr_en			(ps_reg_we				)
				,.i_st_wr_addr  		(ps_reg_addr			)
				,.i_st_wr_data  		(ps_reg_wr_dat			)
				,.i_st_rd_en    		(ps_reg_re				)
				,.i_st_rd_addr  		(ps_reg_rd_addr			)
				,.o_st_rd_data  		(sub_comp_rd_dat[8]		)
				,.o_st_rd_vld   		(sub_comp_rd_vld[8]		)
				,.di_i					(~di_mst_msg[18:14]	    )
				,.o_intr_irq			(map_irq[8]		        )
			);

		    ec_pul_axis#(
		    	.REG_SPACE_BIAS			(20'h1a00  )	//B010_1A00
		    	,.REG_SPACE_SIZE		(`REG_SPACE_SIZE    )
		    )ec_pul_axis_u0(
		    	.clk_i					(clk					)
		    	,.rst					(reset					)
		    	,.i_time_1ms_vld		(time_1ms_vld			)
		    	,.i_time_1s_vld 		(time_1s_vld			)
		    	,.ps_reg_clk			(ps_reg_clk				)
		    	,.ps_reg_reset			(ps_reg_reset			)
		    	,.i_st_wr_en			(ps_reg_we				)
		    	,.i_st_wr_addr  		(ps_reg_addr			)
		    	,.i_st_wr_data  		(ps_reg_wr_dat			)
		    	,.i_st_rd_en    		(ps_reg_re				)
		    	,.i_st_rd_addr  		(ps_reg_rd_addr			)
		    	,.o_st_rd_data  		(sub_comp_rd_dat[9]		)
		    	,.o_st_rd_vld   		(sub_comp_rd_vld[9]		)
		    	,.i_servo_notok			(~di_mst_msg[19]	    )
		    	,.i_servo_stop			(~di_mst_msg[20]	    )
		    	,.i_axis_limf			(~di_mst_msg[21]	    )
		    	,.i_axis_org			(~di_mst_msg[22]	    )
		    	,.i_axis_limb			(~di_mst_msg[23]	    )
		    	,.i_emerge_stop_signal	(~di_mst_msg[24]	    )
		    	,.i_safe_status			(~di_mst_msg[25]	    )
		    	,.i_axis_point			(~di_mst_msg[26]	    )
		    	,.i_axis_reset			(~di_mst_msg[27]	    )
		    	,.i_dv_alarm			(~di_mst_msg[28]	    )
		    	,.o_dv_pulse			(o_dv_pulse[0]		    )
		    	,.o_dv_dir				(o_dv_dir[0]		    )
		    	,.o_dv_reset			(o_dv_reset[0]		    )
		    	,.o_dv_son				(o_dv_son[0]		    )
		    	,.o_intr_irq			(map_irq[9]		        )
		    );

		    ec_slv_pul_axis#(
		    	.REG_SPACE_BIAS			(20'h1c00  )	//B010_1C00
		    	,.REG_SPACE_SIZE		(`REG_SPACE_SIZE    )
		    )ec_slv_pul_axis_u0(
		    	.clk_i					(clk					)
		    	,.rst					(reset					)
		    	,.i_time_1ms_vld		(time_1ms_vld			)
		    	,.i_time_1s_vld 		(time_1s_vld			)
		    	,.ps_reg_clk			(ps_reg_clk				)
		    	,.ps_reg_reset			(ps_reg_reset			)
		    	,.i_st_wr_en			(ps_reg_we				)
		    	,.i_st_wr_addr  		(ps_reg_addr			)
		    	,.i_st_wr_data  		(ps_reg_wr_dat			)
		    	,.i_st_rd_en    		(ps_reg_re				)
		    	,.i_st_rd_addr  		(ps_reg_rd_addr			)
		    	,.o_st_rd_data  		(sub_comp_rd_dat[10]	)
		    	,.o_st_rd_vld   		(sub_comp_rd_vld[10]	)
		    	,.i_servo_notok			(~di_mst_msg[29]	    )
		    	,.i_servo_stop			(~di_mst_msg[30]	    )
		    	,.i_axis_limf			(~di_mst_msg[31]	    )
		    	,.i_axis_org			(~di_mst_msg[32]	    )
		    	,.i_axis_limb			(~di_mst_msg[33]	    )
		    	,.i_emerge_stop_signal	(~di_mst_msg[34]	    )
		    	,.i_safe_status			(~di_mst_msg[38]	    )
		    	,.i_axis_point			(~di_mst_msg[39]	    )
		    	,.i_axis_reset			(~di_mst_msg[40]	    )
		    	,.cur_slv_board_id		(slv_board_id[0]		)
		    	,.slv_board_id			(slv_board_id[0]		)
		    	,.pul_motor_r_flag		(pul_motor0_r_flag		)
		    	,.pul_motor_flag		(pul_motor0_flag		)
		    	,.m2s_pulm_msg			(pul_motor0_r_msg[0]	)
		    	,.s2m_pulm_msg			(pul_motor0_msg[0]	)
		    	,.o_intr_irq			(map_irq[10]		        )
		    );

		    ec_ethercat_servo#(
		    	.REG_SPACE_BIAS			(20'h1e00  )	//B010_1E00
		    	,.REG_SPACE_SIZE		(`REG_SPACE_SIZE    )
		    )ec_ethercat_servo_u0(
		    	.clk_i					(clk					)
		    	,.rst					(reset					)
		    	,.i_time_1ms_vld		(time_1ms_vld			)
		    	,.i_time_1s_vld 		(time_1s_vld			)
		    	,.ps_reg_clk			(ps_reg_clk				)
		    	,.ps_reg_reset			(ps_reg_reset			)
		    	,.i_st_wr_en			(ps_reg_we				)
		    	,.i_st_wr_addr  		(ps_reg_addr			)
		    	,.i_st_wr_data  		(ps_reg_wr_dat			)
		    	,.i_st_rd_en    		(ps_reg_re				)
		    	,.i_st_rd_addr  		(ps_reg_rd_addr			)
		    	,.o_st_rd_data  		(sub_comp_rd_dat[11]	)
		    	,.o_st_rd_vld   		(sub_comp_rd_vld[11]	)
		    	,.i_servo_limf			(~di_mst_msg[35]	    )
		    	,.i_servo_limb			(~di_mst_msg[36]	    )
		    	,.i_servo_zero			(~di_mst_msg[37]	    )
		    	,.o_intr_irq			(map_irq[11]		        )
		    );


	//==========================================================================================================//
	// ----------------------------------- don't care next context----------------------------------------------//
	//===========================================================================================================//
	`endif
endmodule