
`include  "components_param.vh"
`include  "depot_addr_map.vh"
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
    
	assign do_relay_mst_msg =  di_mst_msg[12]?do_mst_msg_force:do_mst_msg ;
	
	vio_0 vio (
   .clk(clk),     
  . probe_out0 ( do_mst_msg_force[0 ]  )
  ,.probe_out1 ( do_mst_msg_force[1 ]  )
  ,.probe_out2 ( do_mst_msg_force[2 ]  )
  ,.probe_out3 ( do_mst_msg_force[3 ]  )
  ,.probe_out4 ( do_mst_msg_force[4 ]  )
  ,.probe_out5 ( do_mst_msg_force[5 ]  )
  ,.probe_out6 ( do_mst_msg_force[6 ]  )
  ,.probe_out7 ( do_mst_msg_force[7 ]  )
  ,.probe_out8 ( do_mst_msg_force[8 ]  )
  ,.probe_out9 ( do_mst_msg_force[9 ]  )
  ,.probe_out10( do_mst_msg_force[10]  )
  ,.probe_out11( do_mst_msg_force[11]  )
  ,.probe_out12( do_mst_msg_force[12]  )
  ,.probe_out13( do_mst_msg_force[13]  )
  ,.probe_out14( do_mst_msg_force[14]  )
  ,.probe_out15( do_mst_msg_force[15]  )
  ,.probe_out16( do_mst_msg_force[16]  )
  ,.probe_out17( do_mst_msg_force[17]  )
  ,.probe_out18( do_mst_msg_force[18]  )
  ,.probe_out19( do_mst_msg_force[19]  )
  ,.probe_out20( do_mst_msg_force[20]  )
  ,.probe_out21( do_mst_msg_force[21]  )
  ,.probe_out22( do_mst_msg_force[22]  )
  ,.probe_out23( do_mst_msg_force[23]  )
  ,.probe_out24( do_mst_msg_force[24]  )
  ,.probe_out25( do_mst_msg_force[25]  )
  ,.probe_out26( do_mst_msg_force[26]  )
  ,.probe_out27( do_mst_msg_force[27]  )
  ,.probe_out28( do_mst_msg_force[28]  )
  ,.probe_out29( do_mst_msg_force[29]  )
  ,.probe_out30( do_mst_msg_force[30]  )
  ,.probe_out31( do_mst_msg_force[31]  )
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
    assign  emcc_irq[0]   = map_irq[0];
    assign  emcc_irq[1]   = map_irq[1];
    assign  emcc_irq[2]   = map_irq[2];
    assign  emcc_irq[3]   = map_irq[3];
    assign  emcc_irq[4]   = map_irq[4];
    assign  emcc_irq[5]   = map_irq[5];
    assign  emcc_irq[6]   = map_irq[6];
    assign  emcc_irq[7]   = map_irq[7];
    assign  emcc_irq[8]   = map_irq[8];
    assign  emcc_irq[9]   = map_irq[9];
    assign  emcc_irq[10]   = map_irq[10];
    assign  emcc_irq[11]   = map_irq[11];
    assign  emcc_irq[12]   = map_irq[12];
    assign  emcc_irq[13]   = map_irq[13];
    assign  emcc_irq[14]   = map_irq[14];
    assign  emcc_irq[15]   = map_irq[15];
    assign  emcc_irq[16]   = map_irq[16];
    assign  emcc_irq[17]   = map_irq[17];
    assign  emcc_irq[18]   = map_irq[18];
    assign  emcc_irq[19]   = map_irq[19];
    assign  emcc_irq[20]   = map_irq[20];
    assign  emcc_irq[21]   = map_irq[21];
    assign  emcc_irq[22]   = map_irq[22];
    assign  emcc_irq[23]   = map_irq[23];
    assign  emcc_irq[25]   = map_irq[25];
    assign  emcc_irq[26]   = map_irq[26];
	assign  emcc_irq[27]   = map_irq[27];
	
	// --- component_v6_inst-----//
	
        ec_1di_check #
        (
			.REG_SPACE_BIAS (20'h0000),	
			.REG_SPACE_SIZE (10'h200),
			.A_BHA_NUM      (2),
			.B_BHA_NUM      (1)
		) 
		ec_1di_check_u0 
		(
			.clk_i           (clk   ),
			.rst             (reset ),
			.aurora_reset    (1'b0  ),     // unuse
			.i_time_1ms_vld  (i_time_1ms_vld),
			.i_time_1s_vld   (1'd0),
			.ps_reg_clk		 (ps_reg_clk),
			.ps_reg_reset    (ps_reg_reset   ),
			.i_st_wr_en      (ps_reg_we),
			.i_st_wr_addr    (ps_reg_addr),
			.i_st_wr_data    (ps_reg_wr_dat),
			.i_st_rd_en      (ps_reg_re),
			.i_st_rd_addr    (ps_reg_rd_addr),
			.o_st_rd_data    (sub_comp_rd_dat[27]),
			.o_st_rd_vld     (sub_comp_rd_vld[27]),
			.di              (di_mst_msg[31:31]),
			.o_intr_irq      (map_irq[27] )
		);
		
		
		
	// --- don't care next context-----//
	
	
	
	
	
	// --- flow_comp_1 x_axis-----
   
/*

   ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     (20'd2048)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd1                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_ethercat_servo_1
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[0]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[0]    ),
	  .o_intr_irq            ( map_irq[0]       )
	  
      ,.i_servo_limb          (~di_mst_msg[0]  )                
      ,.i_servo_limf          (~di_mst_msg[1]  )                
      ,.i_servo_zero          (~di_mst_msg[2]  )                
      
//      ,.i_emerge_stop_signal  (di_mst_msg[9]    )
//      ,.i_reset_signal        (~di_mst_msg[10]   )
//      ,.i_stop_start_singal   (~di_mst_msg[11]   )
//      ,.i_auto_manual_singal  (~di_mst_msg[12]   )

        
    );
	*/
	
		//=================================================================================================================
		// --- flow_comp_2 z_axis-----
    /*
	
	ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     (20'd2560)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd2                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_ethercat_servo_2
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[1]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[1]    ),
	  .o_intr_irq            ( map_irq[1]       )

      ,.i_servo_limb          (~di_mst_msg[6]  )                
      ,.i_servo_limf          (~di_mst_msg[7]  )                
      ,.i_servo_zero          (~di_mst_msg[8]  )                
      
//      ,.i_emerge_stop_signal  (di_mst_msg[9]    )
//      ,.i_reset_signal        (~di_mst_msg[10]   )
//      ,.i_stop_start_singal   (~di_mst_msg[11]   )
//      ,.i_auto_manual_singal  (~di_mst_msg[12]   )
    );
	
		
	
	// --- flow_comp_3 y_axis-----
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     (20'd3072)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd3                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_ethercat_servo_3
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[2]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[2]    ),
	  .o_intr_irq            ( map_irq[2]       )

      ,.i_servo_limb          (~di_mst_msg[3]  )               
      ,.i_servo_limf          (~di_mst_msg[4]  )               
      ,.i_servo_zero          (~di_mst_msg[5]  )             
      
//      ,.i_emerge_stop_signal  (di_mst_msg[9]    )
//      ,.i_reset_signal        (~di_mst_msg[10]   )
//      ,.i_stop_start_singal   (~di_mst_msg[11]   )
//      ,.i_auto_manual_singal  (~di_mst_msg[12]   )
    );

	
	
	
	// --- flow_comp_4 -----
    ec_emcc60_board
    #(
         .REG_SPACE_BIAS     (20'd3584)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd4                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_emcc60_board_4
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[3]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[3]    ),
	  .o_intr_irq            ( map_irq[3]       )                   
    ,.iv_do_mst_msg              (                 )
    ,.iv_di_mst_msg              (!di_mst_msg       )
    ,.iv_board_temperature       (                 )
    ,.iv_adc_value               (                 )
    ,.iv_dac_value               (                 )

    );

	
	
	wire   o_led_yellow_5;
	wire   o_led_red_5;
	wire   o_led_green_5;
	wire   o_buzzer_5;
	
	// --- flow_comp_5 -----
    ec_equipment
    #(
         .REG_SPACE_BIAS     (20'd4096)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd5                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_equipment_5
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[4]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[4]    ),
	  .o_intr_irq            ( map_irq[4]       )

       ,.i_auto_manual_singal ( ~di_mst_msg[12]     )
       ,.o_led_yellow         ( o_led_yellow_5      )
       ,.i_emerge_stop_signal ( ~di_mst_msg[9]      )
       ,.o_led_red            ( o_led_red_5         )
       ,.i_reset_signal       ( ~di_mst_msg[10]     )
       ,.o_led_green          ( o_led_green_5       )
       ,.o_buzzer             ( o_buzzer_5          )
       ,.i_stop_start_singal  ( ~di_mst_msg[11]     )
    );

    assign do_mst_msg[3]=~o_led_yellow_5;
    assign do_mst_msg[2]=~o_led_red_5;
    assign do_mst_msg[1]=~o_led_green_5;
    assign do_mst_msg[0]=~o_buzzer_5;
	
	
	wire   o_bp_speed_2_6;
	wire   o_bp_start_6;
	wire   o_estop_6;
	wire   o_bp_speed_1_6;
	wire   o_bp_dir_6;
	
	
	// --- flow_comp_6 -----
	ec_js_2p_bpss
    #(
         .REG_SPACE_BIAS     (20'd4608)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd6                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_js_2p_bpss_6
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[5]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[5]    ),
	  .o_intr_irq            ( map_irq[5]       )

       ,.o_bp_start         ( o_bp_start_6      )
       ,.o_estop            ( o_estop_6         )
       ,.o_bp_speed_1       ( o_bp_speed_1_6    )
       ,.o_bp_speed_2       ( o_bp_speed_2_6    )
       ,.o_bp_dir           ( o_bp_dir_6        )
       ,.i_spd_1_arr        ( ~di_mst_msg[14]   )
       ,.i_pos_1_arr        ( ~di_mst_msg[14]   )
       ,.i_spd_2_arr        ( ~di_mst_msg[16]   )
       ,.i_pos_2_arr        ( ~di_mst_msg[13]   )
       ,.i_bp_err           ( ~di_mst_msg[19]   )
      
      ,.i_emerge_stop_signal  (di_mst_msg[9]    )
      ,.i_reset_signal        (~di_mst_msg[10]   )
      ,.i_stop_start_singal   (~di_mst_msg[11]   )
      ,.i_auto_manual_singal  (~di_mst_msg[12]   )
       
    );

    assign do_mst_msg[7]=~o_bp_speed_2_6;
    assign do_mst_msg[4]=~o_bp_dir_6;
    assign do_mst_msg[8]=~o_estop_6;
    assign do_mst_msg[6]=~o_bp_speed_1_6;
    assign do_mst_msg[5]=~o_bp_start_6;
	
	
	wire   o_bp_speed_1_7;
	wire   o_bp_start_7;
	wire   o_bp_speed_2_7;
	wire   o_estop_7;
	wire   o_bp_dir_7;
	
	// --- flow_comp_7 -----
    ec_js_2p_bpss
    #(
         .REG_SPACE_BIAS     (20'd5120)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd7                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_js_2p_bpss_7
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[6]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[6]    ),
	  .o_intr_irq            ( map_irq[6]       )
	  
       ,.o_bp_speed_1       ( o_bp_speed_1_7    )
       ,.o_bp_speed_2       ( o_bp_speed_2_7    )
       ,.i_spd_1_arr        ( ~di_mst_msg[24]   )
       ,.i_pos_1_arr        ( ~di_mst_msg[21]   )
       ,.i_spd_2_arr        ( ~di_mst_msg[32]   )
       ,.i_pos_2_arr        ( ~di_mst_msg[29]   )
       ,.o_bp_start         ( o_bp_start_7      )
       ,.o_estop            ( o_estop_7         )
       ,.o_bp_dir           ( o_bp_dir_7        )
       ,.i_bp_err           ( ~di_mst_msg[27]   )
      
      ,.i_emerge_stop_signal  (di_mst_msg[9]    )
      ,.i_reset_signal        (~di_mst_msg[10]   )
      ,.i_stop_start_singal   (~di_mst_msg[11]   )
      ,.i_auto_manual_singal  (~di_mst_msg[12]   )
    );

    assign do_mst_msg[11]=~o_bp_speed_1_7;
    assign do_mst_msg[9]=~o_bp_start_7;
    assign do_mst_msg[12]=~o_bp_speed_2_7;
    assign do_mst_msg[13]=~o_estop_7;
    assign do_mst_msg[10]=~o_bp_dir_7;
	
	
	wire   o_bp_speed_1_8;
	wire   o_estop_8;
	wire   o_bp_start_8;
	wire   o_bp_dir_8;
	wire   o_bp_speed_2_8;
	wire   o_cylineder_ack_8;
	wire   o_cylineder_rst_8;
	
	// --- flow_comp_8 -----
    ec_js_2p_bpss
    #(
         .REG_SPACE_BIAS     (20'd5632)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd8                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_js_2p_bpss_8
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[7]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[7]    ),
	  .o_intr_irq            ( map_irq[7]       )
	  
       ,.o_bp_speed_1       ( o_bp_speed_1_8      )
       ,.o_estop            ( o_estop_8           )
       ,.o_bp_start         ( o_bp_start_8        )
       ,.o_bp_dir           ( o_bp_dir_8          )
       ,.o_bp_speed_2       ( o_bp_speed_2_8      )
       ,.i_bp_err           ( ~di_mst_msg[35]     )
       ,.i_pos_1_arr        ( ~di_mst_msg[29]     )
       ,.i_spd_1_arr        ( ~di_mst_msg[32]    )
       ,.i_pos_2_arr        ( ~di_mst_msg[37]     )
       ,.i_spd_2_arr        ( ~di_mst_msg[40]    )
       
      
      ,.i_emerge_stop_signal  (di_mst_msg[9]    )
      ,.i_reset_signal        (~di_mst_msg[10]   )
      ,.i_stop_start_singal   (~di_mst_msg[11]   )
      ,.i_auto_manual_singal  (~di_mst_msg[12]   )

    );

    assign do_mst_msg[16]=~o_bp_speed_1_8;
    assign do_mst_msg[18]=~o_estop_8;
    assign do_mst_msg[14]=~o_bp_start_8;
    assign do_mst_msg[15]=~o_bp_dir_8;
    assign do_mst_msg[17]=~o_bp_speed_2_8;
    
		
	
	wire   o_bp_speed_1_9;
	wire   o_bp_start_9;
	wire   o_bp_speed_2_9;
	wire   o_bp_dir_9;
	wire   o_estop_9;
	
	// --- flow_comp_9 -----
    ec_js_2p_bpss
    #(
         .REG_SPACE_BIAS     (20'd6144)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd9                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_js_2p_bpss_9
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[8]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[8]    ),
	  .o_intr_irq            ( map_irq[8]       )
	  
       ,.o_bp_speed_1       ( o_bp_speed_1_9        )
       ,.o_bp_start         ( o_bp_start_9          )
       
       ,.i_pos_1_arr        ( ~di_mst_msg[29]       )
       ,.i_spd_1_arr        ( ~di_mst_msg[32]       )
       ,.i_pos_2_arr        ( ~di_mst_msg[37]       )
       ,.i_spd_2_arr        ( ~di_mst_msg[40]       )
       
       ,.o_bp_speed_2       ( o_bp_speed_2_9        )
       ,.i_bp_err           ( ~di_mst_msg[43]       )
       ,.o_bp_dir           ( o_bp_dir_9            )
       ,.o_estop            ( o_estop_9             )
       
      
      ,.i_emerge_stop_signal  (di_mst_msg[9]    )
      ,.i_reset_signal        (~di_mst_msg[10]   )
      ,.i_stop_start_singal   (~di_mst_msg[11]   )
      ,.i_auto_manual_singal  (~di_mst_msg[12]   )
    );
    assign do_mst_msg[21]=~o_bp_speed_1_9;
    assign do_mst_msg[19]=~o_bp_start_9;
    assign do_mst_msg[22]=~o_bp_speed_2_9;
    assign do_mst_msg[20]=~o_bp_dir_9;
    assign do_mst_msg[23]=~o_estop_9;
	
	
	// --- flow_comp_10 -----
    ec_1_in_button
    #(
         .REG_SPACE_BIAS     (20'd6656)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd10                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1_in_button_10
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[9]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[9]    ),
	  .o_intr_irq            ( map_irq[9]       )

   ,.  i_sign1_check         ()

    );

	
	
	
	// --- flow_comp_11 -----
    ec_1_in_button
    #(
         .REG_SPACE_BIAS     (20'd7168)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd11                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1_in_button_11
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[10]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[10]    ),
	  .o_intr_irq            ( map_irq[10]       )

   ,.  i_sign1_check         ()
    );

	
	
    wire [1:0]reg_execu_result_1;
	// --- flow_comp_12 -----
    ec_osm41_485_laser_distance
    #(
         .REG_SPACE_BIAS     (20'd7680)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd12                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_osm41_485_laser_distance_12
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[11]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[11]    ),
	  .o_intr_irq            ( map_irq[11]       )

       ,.o_user_req     (rs485_2_user_req  [0])            
       ,.i_user_grant   (rs485_2_user_grant[0])            
       ,.o_uart_tx      (rs485_2_user_tx   [0])            
       ,.i_uart_rx      (rs485_2_user_rx   [0])            
       ,.o_uart_de      (rs485_2_user_de   [0])      
       
    );
    
    
	// --- flow_comp_13 -----
    ec_osm41_485_laser_distance
    #(
         .REG_SPACE_BIAS     (20'd12288)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd13                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_osm41_485_laser_distance_13
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[20]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[20]    ),
	  .o_intr_irq            ( map_irq[20]       )

       ,.o_user_req     (rs485_2_user_req  [1])
       ,.i_user_grant   (rs485_2_user_grant[1])
       ,.o_uart_tx      (rs485_2_user_tx   [1])
       ,.i_uart_rx      (rs485_2_user_rx   [1])
       ,.o_uart_de      (rs485_2_user_de   [1])
       
    );



	// --- flow_comp_20 -----
    ec_1io_check
    #(
         .REG_SPACE_BIAS     (20'd8192)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd20                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1io_check_20
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[12]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[12]    ),
	  .o_intr_irq            ( map_irq[12]       )

       ,.i_sign1_check        ( di_mst_msg[48]           )
    );

	
	
	
	// --- flow_comp_21 -----
    ec_1io_check
    #(
         .REG_SPACE_BIAS     (20'd8704)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd21                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1io_check_21
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[13]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[13]    ),
	  .o_intr_irq            ( map_irq[13]       )

       ,.i_sign1_check        ( di_mst_msg[49]           )
    );

	
	
	
	// --- flow_comp_22 -----
    ec_1io_check
    #(
         .REG_SPACE_BIAS     (20'd9216)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd22                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1io_check_22
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[14]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[14]    ),
	  .o_intr_irq            ( map_irq[14]       )

       ,.i_sign1_check        ( di_mst_msg[50]           )
    );

	
	
	
	// --- flow_comp_23 -----
    ec_1io_check
    #(
         .REG_SPACE_BIAS     (20'd9728)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd23                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1io_check_23
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[15]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[15]    ),
	  .o_intr_irq            ( map_irq[15]       )

       ,.i_sign1_check        ( di_mst_msg[51]           )
    );

	
	
	
	// --- flow_comp_24 -----
    ec_1io_check
    #(
         .REG_SPACE_BIAS     (20'd10240)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd24                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1io_check_24
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[16]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[16]    ),
	  .o_intr_irq            ( map_irq[16]       )

       ,.i_sign1_check        ( di_mst_msg[52]           )
    );

	
	
	
	// --- flow_comp_25 -----
    ec_1io_check
    #(
         .REG_SPACE_BIAS     (20'd10752)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd25                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1io_check_25
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[17]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[17]    ),
	  .o_intr_irq            ( map_irq[17]       )

       ,.i_sign1_check        ( di_mst_msg[53]           )
    );

	
	
	
	// --- flow_comp_26 -----
    ec_1io_check
    #(
         .REG_SPACE_BIAS     (20'd11264)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd26                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1io_check_26
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[18]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[18]    ),
	  .o_intr_irq            ( map_irq[18]       )

       ,.i_sign1_check        ( di_mst_msg[54]           )
    );

	
	
	
	// --- flow_comp_27 -----
    ec_1io_check
    #(
         .REG_SPACE_BIAS     (20'd11776)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd27                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1io_check_27
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[19]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[19]    ),
	  .o_intr_irq            ( map_irq[19]       )

       ,.i_sign1_check        ( di_mst_msg[55]           )
    );

	// --- flow_comp_28 -----
    ec_io_2p2e
    #(
         .REG_SPACE_BIAS     (20'd12800)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd28                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_io_2p2e_28
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[21]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[21]    ),
	  .o_intr_irq            ( map_irq[21]       )
       
       ,.i_open_arr          (~di_mst_msg[31]   )
       ,.i_close_arr         (~di_mst_msg[34]   )
       ,.o_ctl_open          (o_cylineder_ack_8)
       ,.o_ctl_close         (o_cylineder_rst_8)
      
      ,.i_emerge_stop_signal  (di_mst_msg[9]    )
      ,.i_reset_signal        (~di_mst_msg[10]   )
      ,.i_stop_start_singal   (~di_mst_msg[11]   )
      ,.i_auto_manual_singal  (~di_mst_msg[12]   )
       
    );               
    
    assign do_mst_msg[24]=~o_cylineder_ack_8;
    assign do_mst_msg[25]=~o_cylineder_rst_8;
  
	                   
	// --- flow_comp_29 -----
    ec_1io_check
    #(
         .REG_SPACE_BIAS     (20'd13312)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd29                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1io_check_29
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[22]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[22]    ),
	  .o_intr_irq            ( map_irq[22]       )
	  
       ,.i_sign1_check        ( !di_mst_msg[15]           )
    );
    
    // --- flow_comp_30 -----
    ec_set_switch
    #(
         .REG_SPACE_BIAS     (20'd13824)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd30                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_set_switch_30
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[23]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[23]    ),
	  .o_intr_irq            ( map_irq[23]       )

    );

	
	// --- flow_comp_31 -----
    ec_1io_check
    #(
         .REG_SPACE_BIAS     (20'd14848)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd31                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1io_check_31
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[25]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[25]    ),
	  .o_intr_irq            ( map_irq[25]       )
	  
       ,.i_sign1_check        ( di_mst_msg[17]           )
    );

//	 --- flow_comp_32 -----
    ec_keli_rs485
    #(
         .REG_SPACE_BIAS     (20'd15360)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        ,.P_MODULE_ID        (8'd32                      )
        ,.P_SEAT_NUM         (4'd0                      )
    )
    ec_keli_rs485_32
    (
      .clk                   ( ps_reg_clk               ),
      .reset                 ( ps_reg_reset             ),
	  .aurora_clk            ( clk               ),
      .aurora_reset          ( reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[26]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[26]    ),
	  .o_intr_irq            ( map_irq[26]       )

   ,.o_user_req              (rs485_1_user_req  [0]   )
   ,.i_user_grant            (rs485_1_user_grant[0]   )
   ,.i_uart_rx               (rs485_1_user_rx   [0]   )
   ,.o_uart_tx               (rs485_1_user_tx   [0]   )
   ,.o_uart_de               (rs485_1_user_de   [0]   )
    );
    */
	`endif

	
endmodule