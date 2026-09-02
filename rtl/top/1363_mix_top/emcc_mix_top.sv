
`include  "./../include_files/components_param.vh"
`include  "./../include_files/depot_addr_map.vh"
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
   
    assign ov_dbg_enable = 0;
	assign do_relay_mst_msg = do_mst_msg;
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
    assign  emcc_irq[45]   = map_irq[45];
    assign  emcc_irq[46]   = map_irq[46];
    assign  emcc_irq[47]   = map_irq[47];
    assign  emcc_irq[48]   = map_irq[48];
    assign  emcc_irq[49]   = map_irq[49];
    assign  emcc_irq[50]   = map_irq[50];
    assign  emcc_irq[51]   = map_irq[51];
    assign  emcc_irq[52]   = map_irq[52];
    assign  emcc_irq[53]   = map_irq[53];
    assign  emcc_irq[54]   = map_irq[54];
    assign  emcc_irq[55]   = map_irq[55];
    assign  emcc_irq[56]   = map_irq[56];
    assign  emcc_irq[12]   = map_irq[12];
    assign  emcc_irq[13]   = map_irq[13];
    assign  emcc_irq[14]   = map_irq[14];
    assign  emcc_irq[15]   = map_irq[15];
    assign  emcc_irq[16]   = map_irq[16];
    assign  emcc_irq[17]   = map_irq[17];
    assign  emcc_irq[57]   = map_irq[57];
    assign  emcc_irq[58]   = map_irq[58];
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
    assign  emcc_irq[18]   = map_irq[18];
    assign  emcc_irq[19]   = map_irq[19];
    assign  emcc_irq[20]   = map_irq[20];
    assign  emcc_irq[21]   = map_irq[21];
    assign  emcc_irq[22]   = map_irq[22];
    assign  emcc_irq[23]   = map_irq[23];
    assign  emcc_irq[24]   = map_irq[24];
    assign  emcc_irq[25]   = map_irq[25];
    assign  emcc_irq[26]   = map_irq[26];
    assign  emcc_irq[27]   = map_irq[27];
    assign  emcc_irq[28]   = map_irq[28];
    assign  emcc_irq[29]   = map_irq[29];
    assign  emcc_irq[30]   = map_irq[30];
    assign  emcc_irq[31]   = map_irq[31];
    assign  emcc_irq[32]   = map_irq[32];
    assign  emcc_irq[33]   = map_irq[33];
    assign  emcc_irq[34]   = map_irq[34];
    assign  emcc_irq[35]   = map_irq[35];
    assign  emcc_irq[36]   = map_irq[36];
    assign  emcc_irq[37]   = map_irq[37];
    assign  emcc_irq[38]   = map_irq[38];
    assign  emcc_irq[39]   = map_irq[39];
    assign  emcc_irq[40]   = map_irq[40];
    assign  emcc_irq[41]   = map_irq[41];
    assign  emcc_irq[42]   = map_irq[42];
    assign  emcc_irq[43]   = map_irq[43];
    assign  emcc_irq[44]   = map_irq[44];
    
	
	
	// --- flow_comp_14 --EECC30控制板组件---
    // eecc30
    // #(
    //      .REG_SPACE_BIAS     ( 20'd8192)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // eecc30_14
    // (
      
	//   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk        ),
    //   .ps_reg_reset          ( ps_reg_reset      ),
	  
	//   .i_time_1ms_vld        ( time_1ms_vld      ),
	//   .i_time_1s_vld         ( time_1s_vld       ),

	//   .i_st_wr_en            ( ps_reg_we         ),
	//   .i_st_wr_addr          ( ps_reg_addr       ),
    //   .i_st_wr_data          ( ps_reg_wr_dat     ),
    //   .i_st_rd_en            ( ps_reg_re         ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr    ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[12]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[12]    ),
	//   .o_intr_irq            ( map_irq[12]       )

    // );

	
	
	
	// --- flow_comp_15 --直线脉冲伺服电机从板组件---
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     ( 20'd8704)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_15
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[13]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[13]    ),
	  .o_intr_irq            ( map_irq[13]       )

       ,.i_axis_limf        ( ~di_regoin_msg[0][20]           )   // 正限位到位开关
       ,.i_axis_limb        ( ~di_regoin_msg[0][22]           )   // 负限位到位开关
       ,.i_axis_zero        ( ~di_regoin_msg[0][21]           )   // 零位到位开关
       ,.i_servo_stop        ( ~di_regoin_msg[0][19]           )   // 伺服定位完成
       ,.i_servo_ok        ( ~di_regoin_msg[0][23]           )   // 伺服就绪
				,.cur_slv_board_id		(1'b0                   )
				,.slv_board_id			(slv_board_id           )
				,.pul_motor_r_flag		(pul_motor0_r_flag      )
		    	,.pul_motor_flag		(pul_motor0_flag	    )
				,.m2s_pulm_msg			(pul_motor0_r_msg[0]    )
				,.s2m_pulm_msg			(pul_motor0_msg[0]      )
    );

	
	
	
	// --- flow_comp_16 --16位感知组件---
    ec_16di
    #(
         .REG_SPACE_BIAS     ( 20'd9216)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_16di_16
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[14]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[14]    ),
	  .o_intr_irq            ( map_irq[14]       )

       ,.i_sign1_check        ( ~di_regoin_msg[0][24]           )   // 感测开关1
       ,.i_sign10_check        ( ~di_regoin_msg[0][33]           )   // 感测开关10
       ,.i_sign11_check        ( ~di_regoin_msg[0][34]           )   // 感测开关11
       ,.i_sign12_check        ( ~di_regoin_msg[0][35]           )   // 感测开关12
       ,.i_sign13_check        ( ~di_regoin_msg[0][36]           )   // 感测开关13
       ,.i_sign14_check        ( ~di_regoin_msg[0][37]           )   // 感测开关14
       ,.i_sign15_check        ( ~di_regoin_msg[0][38]           )   // 感测开关15
       ,.i_sign16_check        ( ~di_regoin_msg[0][39]           )   // 感测开关16
       ,.i_sign2_check        ( ~di_regoin_msg[0][25]           )   // 感测开关2
       ,.i_sign3_check        ( ~di_regoin_msg[0][26]           )   // 感测开关3
       ,.i_sign4_check        ( ~di_regoin_msg[0][27]           )   // 感测开关4
       ,.i_sign5_check        ( ~di_regoin_msg[0][28]           )   // 感测开关5
       ,.i_sign6_check        ( ~di_regoin_msg[0][29]           )   // 感测开关6
       ,.i_sign7_check        ( ~di_regoin_msg[0][30]           )   // 感测开关7
       ,.i_sign8_check        ( ~di_regoin_msg[0][31]           )   // 感测开关8
       ,.i_sign9_check        ( ~di_regoin_msg[0][32]           )   // 感测开关9
    );

	
	
	wire   o_dri1_17;
	wire   o_dri2_17;
	
	// --- flow_comp_17 --四位两电控制组件---
    ec_4di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd9728)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_4di_2do_17
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[15]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[15]    ),
	  .o_intr_irq            ( map_irq[15]       )

       ,.i_pos1_1        ( ~di_regoin_msg[0][4]           )   // 左侧门开到位开关
       ,.i_pos1_2        ( ~di_regoin_msg[0][5]           )   // 右侧门开到位开关
       ,.i_pos2_2        ( ~di_regoin_msg[0][7]           )   // 右侧门关到位开关
       ,.i_pos2_1        ( ~di_regoin_msg[0][6]           )   // 左侧门关到位开关
       ,.o_dri1        ( o_dri1_17           )   // 自动门开驱动信号
       ,.o_dri2        ( o_dri2_17           )   // 自动门关驱动信号
    );

    assign do_regoin_r_msg[ 0][2] = ~o_dri1_17;
    assign do_regoin_r_msg[ 0][3] = ~o_dri2_17;
	
	
	
	// --- flow_comp_18 --思谷RFID读写器组件---
    // ec_sg_rfid
    // #(
    //      .REG_SPACE_BIAS     ( 20'd10240)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_sg_rfid_18
    // (
      
	//   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk        ),
    //   .ps_reg_reset          ( ps_reg_reset      ),
	  
	//   .i_time_1ms_vld        ( time_1ms_vld      ),
	//   .i_time_1s_vld         ( time_1s_vld       ),

	//   .i_st_wr_en            ( ps_reg_we         ),
	//   .i_st_wr_addr          ( ps_reg_addr       ),
    //   .i_st_wr_data          ( ps_reg_wr_dat     ),
    //   .i_st_rd_en            ( ps_reg_re         ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr    ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[16]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[16]    ),
	//   .o_intr_irq            ( map_irq[16]       )

    // );

	
	
	
	// --- flow_comp_19 --电气比例阀组件---
    // ec_1avi_1avo
    // #(
    //      .REG_SPACE_BIAS     ( 20'd10752)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_1avi_1avo_19
    // (
      
	//   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk        ),
    //   .ps_reg_reset          ( ps_reg_reset      ),
	  
	//   .i_time_1ms_vld        ( time_1ms_vld      ),
	//   .i_time_1s_vld         ( time_1s_vld       ),

	//   .i_st_wr_en            ( ps_reg_we         ),
	//   .i_st_wr_addr          ( ps_reg_addr       ),
    //   .i_st_wr_data          ( ps_reg_wr_dat     ),
    //   .i_st_rd_en            ( ps_reg_re         ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr    ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[17]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[17]    ),
	//   .o_intr_irq            ( map_irq[17]       )

    // );

	
	
	
	// --- flow_comp_59 --RS485变频器组件---
    // ec_slv_dv300_485
    // #(
    //      .REG_SPACE_BIAS     ( 20'd31232)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_slv_dv300_485_59
    // (
      
	//   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk        ),
    //   .ps_reg_reset          ( ps_reg_reset      ),
	  
	//   .i_time_1ms_vld        ( time_1ms_vld      ),
	//   .i_time_1s_vld         ( time_1s_vld       ),

	//   .i_st_wr_en            ( ps_reg_we         ),
	//   .i_st_wr_addr          ( ps_reg_addr       ),
    //   .i_st_wr_data          ( ps_reg_wr_dat     ),
    //   .i_st_rd_en            ( ps_reg_re         ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr    ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[57]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[57]    ),
	//   .o_intr_irq            ( map_irq[57]       )

    //    ,.SLAVE_PCB_NUM        ( 0           )   // 
    //    ,.LOCK_SCAN_ADDR        ( DEPOT_BIAS_RS485           )   // 
    //    ,.sys_addra        ( sys_addra[0]           )   // 
    //    ,.sys_wea        ( sys_wea[0]           )   // 
    //    ,.rs485_msg        (  rs485_msg[0]           )   // 
    //    ,.slv_cfg_msg_rden        ( slv_cfg_msg_rden           )   // 
    //    ,.slv_cfg_msg_addr        ( slv_cfg_msg_addr           )   // 
    //    ,.ov_rs485_send_msg        (  rs485_send_msg[0]           )   // 
    // );

	
	
	wire   o_dri7_60;
	wire   o_dri3_60;
	wire   o_dri4_60;
	wire   o_dri8_60;
	wire   o_dri5_60;
	wire   o_dri6_60;
	wire   o_dri2_60;
	wire   o_dri1_60;
	
	// --- flow_comp_60 --8电驱动组件---
    ec_8do
    #(
         .REG_SPACE_BIAS     ( 20'd31744)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_8do_60
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[58]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[58]    ),
	  .o_intr_irq            ( map_irq[58]       )

       ,.o_dri1        ( o_dri1_60           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_60           )   // 驱动信号2
       ,.o_dri3        ( o_dri3_60           )   // 驱动信号3
       ,.o_dri4        ( o_dri4_60           )   // 驱动信号4
       ,.o_dri7        ( o_dri7_60           )   // 驱动信号7
       ,.o_dri5        ( o_dri5_60           )   // 驱动信号5
       ,.o_dri6        ( o_dri6_60           )   // 驱动信号6
       ,.o_dri8        ( o_dri8_60           )   // 驱动信号8
    );

    assign do_regoin_r_msg[ 0][14] = ~o_dri7_60;
    assign do_regoin_r_msg[ 0][12] = ~o_dri3_60;
    assign do_regoin_r_msg[ 0][16] = ~o_dri4_60;
    assign do_regoin_r_msg[ 0][18] = ~o_dri8_60;
    assign do_regoin_r_msg[ 0][13] = ~o_dri5_60;
    assign do_regoin_r_msg[ 0][17] = ~o_dri6_60;
    assign do_regoin_r_msg[ 0][15] = ~o_dri2_60;
    assign do_regoin_r_msg[ 0][11] = ~o_dri1_60;
	
	
	
	// --- flow_comp_61 --EMCC60控制板组件---
    // ec_emcc60_board
    // #(
    //      .REG_SPACE_BIAS     ( 20'd2048)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_emcc60_board_61
    // (
      
	//   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk        ),
    //   .ps_reg_reset          ( ps_reg_reset      ),
	  
	//   .i_time_1ms_vld        ( time_1ms_vld      ),
	//   .i_time_1s_vld         ( time_1s_vld       ),

	//   .i_st_wr_en            ( ps_reg_we         ),
	//   .i_st_wr_addr          ( ps_reg_addr       ),
    //   .i_st_wr_data          ( ps_reg_wr_dat     ),
    //   .i_st_rd_en            ( ps_reg_re         ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr    ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[0]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[0]    ),
	//   .o_intr_irq            ( map_irq[0]       )

    // );

	
	
	
	// --- flow_comp_62 --海克斯康三坐标设备组件---
    ec_hex_coordinate
    #(
         .REG_SPACE_BIAS     ( 20'd2560)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_hex_coordinate_62
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[1]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[1]    ),
	  .o_intr_irq            ( map_irq[1]       )

    );

	
	
	
	// --- flow_comp_63 --直线位置模式/3DI/测距全闭环/EtherCAT汇川伺服驱动组件---
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd3072)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ethercat_servo_dis_63
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[2]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[2]    ),
	  .o_intr_irq            ( map_irq[2]       )

       ,.i_axis_limf        ( ~di_mst_msg[14]           )   // 正限位开关
       ,.i_axis_limb        ( ~di_mst_msg[16]           )   // 负限位开关
       ,.i_axis_zero        ( ~di_mst_msg[15]           )   // 零位开关
    );

	
	
	
	// --- flow_comp_64 --海康视觉工控机组件---
    ec_hik_ipc
    #(
         .REG_SPACE_BIAS     ( 20'd3584)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_hik_ipc_64
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[3]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[3]    ),
	  .o_intr_irq            ( map_irq[3]       )

    );

	
	
	
	// --- flow_comp_65 --双位感知组件---
    ec_2di
    #(
         .REG_SPACE_BIAS     ( 20'd4096)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_65
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[4]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[4]    ),
	  .o_intr_irq            ( map_irq[4]       )

       ,.i_sign1_check        ( ~di_mst_msg[26]           )   // 感测开关1
       ,.i_sign2_check        ( ~di_mst_msg[27]           )   // 感测开关2
    );

	
	
	
	// --- flow_comp_66 --多圈位置模式/单DI/EtherCAT/汇川伺服驱动组件---
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd4608)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ecat_multi_turn_angle_spin_servo_66
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[5]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[5]    ),
	  .o_intr_irq            ( map_irq[5]       )

       ,.i_axis_zero        ( ~di_mst_msg[7]           )   // 零位开关
    );

	
	
	
	// --- flow_comp_67 --大族OCR字符识别相机组件---
    ec_ocr_camera
    #(
         .REG_SPACE_BIAS     ( 20'd5120)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ocr_camera_67
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[6]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[6]    ),
	  .o_intr_irq            ( map_irq[6]       )

    );

	
	
	wire   o_bz_68;
	wire   o_led_g_68;
	wire   o_led_r_68;
	wire   o_led_y_68;
	
	// --- flow_comp_68 --三色灯组件---
    ec_3led_buzzer
    #(
         .REG_SPACE_BIAS     ( 20'd5632)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3led_buzzer_68
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[7]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[7]    ),
	  .o_intr_irq            ( map_irq[7]       )

       ,.o_led_y        ( o_led_y_68           )   // 黄色驱动信号
       ,.o_led_g        ( o_led_g_68           )   // 绿色驱动信号
       ,.o_bz        ( o_bz_68           )   // 蜂鸣驱动信号
       ,.o_led_r        ( o_led_r_68           )   // 红色驱动信号
    );

    assign do_mst_msg[1] = ~o_bz_68;
    assign do_mst_msg[2] = ~o_led_g_68;
    assign do_mst_msg[3] = ~o_led_r_68;
    assign do_mst_msg[4] = ~o_led_y_68;
	
	
	
	// --- flow_comp_69 --西门子系统加工中心组件---
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     ( 20'd6144)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_69
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[8]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[8]    ),
	  .o_intr_irq            ( map_irq[8]       )

    );

	
	
	
	// --- flow_comp_70 --PL_RS485_modbus_RTU组件---
    // ec_pl_rs485_modbus_rtu
    // #(
    //      .REG_SPACE_BIAS     ( 20'd6656)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_pl_rs485_modbus_rtu_70
    // (
      
	//   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk        ),
    //   .ps_reg_reset          ( ps_reg_reset      ),
	  
	//   .i_time_1ms_vld        ( time_1ms_vld      ),
	//   .i_time_1s_vld         ( time_1s_vld       ),

	//   .i_st_wr_en            ( ps_reg_we         ),
	//   .i_st_wr_addr          ( ps_reg_addr       ),
    //   .i_st_wr_data          ( ps_reg_wr_dat     ),
    //   .i_st_rd_en            ( ps_reg_re         ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr    ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[9]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[9]    ),
	//   .o_intr_irq            ( map_irq[9]       )

    //    ,.o_user_req        ( null_user_req[null]           )   // RS485端口
    //    ,.i_user_grant        ( null_user_grant[null]           )   // 
    //    ,.o_uart_tx        ( null_user_tx[null]           )   // 
    //    ,.i_uart_rx        ( null_user_rx[null]           )   // 
    //    ,.o_uart_de        ( null_user_de[null]           )   // 
    // );

	
	
	
	// --- flow_comp_71 --FANUC焊接机器人组件---
    ec_fanuc_hj_robot
    #(
         .REG_SPACE_BIAS     ( 20'd7168)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_fanuc_hj_robot_71
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[10]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[10]    ),
	  .o_intr_irq            ( map_irq[10]       )

    );

	
	
	
	// --- flow_comp_72 --宜科线扫组件---
    ec_lvm_ls
    #(
         .REG_SPACE_BIAS     ( 20'd7680)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_lvm_ls_72
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[11]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[11]    ),
	  .o_intr_irq            ( map_irq[11]       )

    );

	
	
	
	// --- flow_comp_73 --OSM41激光测距组件---
    // ec_osm41_485_laser_distance
    // #(
    //      .REG_SPACE_BIAS     ( 20'd11264)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_osm41_485_laser_distance_73
    // (
      
	//   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk        ),
    //   .ps_reg_reset          ( ps_reg_reset      ),
	  
	//   .i_time_1ms_vld        ( time_1ms_vld      ),
	//   .i_time_1s_vld         ( time_1s_vld       ),

	//   .i_st_wr_en            ( ps_reg_we         ),
	//   .i_st_wr_addr          ( ps_reg_addr       ),
    //   .i_st_wr_data          ( ps_reg_wr_dat     ),
    //   .i_st_rd_en            ( ps_reg_re         ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr    ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[18]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[18]    ),
	//   .o_intr_irq            ( map_irq[18]       )

    //    ,.o_user_req        ( null_user_req[null]           )   // 
    //    ,.i_user_grant        ( null_user_grant[null]           )   // 
    //    ,.o_uart_tx        ( null_user_tx[null]           )   // 
    //    ,.i_uart_rx        ( null_user_rx[null]           )   // 
    //    ,.o_uart_de        ( null_user_de[null]           )   // 
    // );

	
	
	wire   o_dri1_74;
	wire   o_dri2_74;
	
	// --- flow_comp_74 --单位两电驱动组件---
    ec_1di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd11776)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1di_2do_74
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[19]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[19]    ),
	  .o_intr_irq            ( map_irq[19]       )

       ,.i_pos        ( ~di_mst_msg[38]           )   // 位置到位开关
       ,.o_dri1        ( o_dri1_74           )   // 位置1驱动信号
       ,.o_dri2        ( o_dri2_74           )   // 位置2驱动信号
    );

    assign do_mst_msg[14] = ~o_dri1_74;
    assign do_mst_msg[15] = ~o_dri2_74;
	
	
	
	// --- flow_comp_75 --直线地轨组件---
    ec_can_servo
    #(
         .REG_SPACE_BIAS     ( 20'd12288)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_can_servo_75
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[20]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[20]    ),
	  .o_intr_irq            ( map_irq[20]       )

       ,.i_axis_limf        ( ~di_mst_msg[23]           )   // 正限位开关
       ,.i_axis_limb        ( ~di_mst_msg[25]           )   // 负限位开关
       ,.i_axis_zero        ( ~di_mst_msg[24]           )   // 零位开关
    );

	
	
	
	// --- flow_comp_76 --清洗机组件---
    ec_lanj_washer
    #(
         .REG_SPACE_BIAS     ( 20'd12800)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_lanj_washer_76
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[21]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[21]    ),
	  .o_intr_irq            ( map_irq[21]       )

    );

	
	
	
	// --- flow_comp_77 --单位感知控件V6.0调试组件---
    ec_1di
    #(
         .REG_SPACE_BIAS     ( 20'd13312)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1di_77
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[22]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[22]    ),
	  .o_intr_irq            ( map_irq[22]       )

       ,.i_sign1_check        ( ~di_mst_msg[0]           )   // 物料感测端口
    );

	
	
	
	// --- flow_comp_78 --扭矩模式/扭矩闭环/EtherCAT汇川伺服驱动组件---
    // ec_ethercat_servo_tor
    // #(
    //      .REG_SPACE_BIAS     ( 20'd13824)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_ethercat_servo_tor_78
    // (
      
	//   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk        ),
    //   .ps_reg_reset          ( ps_reg_reset      ),
	  
	//   .i_time_1ms_vld        ( time_1ms_vld      ),
	//   .i_time_1s_vld         ( time_1s_vld       ),

	//   .i_st_wr_en            ( ps_reg_we         ),
	//   .i_st_wr_addr          ( ps_reg_addr       ),
    //   .i_st_wr_data          ( ps_reg_wr_dat     ),
    //   .i_st_rd_en            ( ps_reg_re         ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr    ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[23]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[23]    ),
	//   .o_intr_irq            ( map_irq[23]       )

    //    ,.o_user_req        ( null_user_req[null]           )   // 扭力感测
    //    ,.i_user_grant        ( null_user_grant[null]           )   // 
    //    ,.o_uart_tx        ( null_user_tx[null]           )   // 
    //    ,.i_uart_rx        ( null_user_rx[null]           )   // 
    //    ,.o_uart_de        ( null_user_de[null]           )   // 
    // );

	
	
	
	// --- flow_comp_79 --多圈位置模式/单DI/双测距/EtherCAT/汇川伺服驱动组件---
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd14336)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ecat_multi_turn_angle_spin_servo_2dis_79
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[24]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[24]    ),
	  .o_intr_irq            ( map_irq[24]       )

    //    ,.o_user_req        ( null_user_req[null]           )   // 激光测距1
    //    ,.i_user_grant        ( null_user_grant[null]           )   // 
    //    ,.o_uart_tx        ( null_user_tx[null]           )   // 
    //    ,.i_uart_rx        ( null_user_rx[null]           )   // 
    //    ,.o_uart_de        ( null_user_de[null]           )   // 
    //    ,.o_user_req        ( null_user_req[null]           )   // 激光测距2
    //    ,.i_user_grant        ( null_user_grant[null]           )   // 
    //    ,.o_uart_tx        ( null_user_tx[null]           )   // 
    //    ,.i_uart_rx        ( null_user_rx[null]           )   // 
    //    ,.o_uart_de        ( null_user_de[null]           )   // 
       ,.i_axis_zero        ( ~di_mst_msg[17]           )   // 零位开关
    );

	
	
	
	// --- flow_comp_80 --飞捷打标机组件---
    ec_feijie_marker
    #(
         .REG_SPACE_BIAS     ( 20'd14848)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_feijie_marker_80
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[25]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[25]    ),
	  .o_intr_irq            ( map_irq[25]       )

    );

	
	
	wire   o_dri_81;
	
	// --- flow_comp_81 --单位单电驱动组件---
    ec_1di_1do
    #(
         .REG_SPACE_BIAS     ( 20'd15360)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1di_1do_81
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[26]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[26]    ),
	  .o_intr_irq            ( map_irq[26]       )

       ,.i_pos        ( ~di_mst_msg[37]           )   // 位置到位开关
       ,.o_dri        ( o_dri_81           )   // 单电驱动信号
    );

    assign do_mst_msg[13] = ~o_dri_81;
	
	
	
	// --- flow_comp_82 --海克斯康影像测量仪组件---
    ec_hex_optiv
    #(
         .REG_SPACE_BIAS     ( 20'd15872)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_hex_optiv_82
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[27]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[27]    ),
	  .o_intr_irq            ( map_irq[27]       )

    );

	
	
	wire   o_dri2_83;
	wire   o_dri1_83;
	
	// --- flow_comp_83 --双电驱动组件---
    ec_2do
    #(
         .REG_SPACE_BIAS     ( 20'd16384)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2do_83
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[28]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[28]    ),
	  .o_intr_irq            ( map_irq[28]       )

       ,.o_dri1        ( o_dri1_83           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_83           )   // 驱动信号2
    );

    assign do_mst_msg[12] = ~o_dri2_83;
    assign do_mst_msg[11] = ~o_dri1_83;
	
	
	
	// --- flow_comp_84 --电子手轮组件---
    ec_pulmotor_handwheel
    #(
         .REG_SPACE_BIAS     ( 20'd16896)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_pulmotor_handwheel_84
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[29]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[29]    ),
	  .o_intr_irq            ( map_irq[29]       )

       ,.i_axis_4        ( ~di_mst_msg[48]           )   // 4轴
       ,.i_axis_5        ( ~di_mst_msg[49]           )   // 5轴
       ,.i_axis_6        ( ~di_mst_msg[50]           )   // 6轴
       ,.i_axis_7        ( ~di_mst_msg[51]           )   // 7轴
       ,.i_stp_x10        ( ~di_mst_msg[44]           )   // X100
       ,.i_stp_x100        ( ~di_mst_msg[43]           )   // X10
       ,.i_stp_x1        ( ~di_mst_msg[42]           )   // X1
       ,.i_axis_x        ( ~di_mst_msg[45]           )   // X轴
       ,.i_axis_y        ( ~di_mst_msg[46]           )   // Y轴
       ,.i_axis_z        ( ~di_mst_msg[47]           )   // Z轴
    //    ,.i_estop        ( di_mst_msg[54]           )   // ESTOP
       ,.i_pulse_a        ( ~di_mst_msg[52]           )   // A
       ,.i_pulse_b        ( ~di_mst_msg[53]           )   // B
    );

	
	
	
	// --- flow_comp_85 --单AVI感知组件---
    ec_1avi
    #(
         .REG_SPACE_BIAS     ( 20'd17408)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1avi_85
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[30]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[30]    ),
	  .o_intr_irq            ( map_irq[30]       )

    );

	
	
	
	// --- flow_comp_86 --系统安全组件---
    ec_sys_sf
    #(
         .REG_SPACE_BIAS     ( 20'd17920)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_sys_sf_86
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[31]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[31]    ),
	  .o_intr_irq            ( map_irq[31]       )

       ,.i_stop        ( ~di_mst_msg[2]           )   // 停止按钮开关
       ,.i_start        ( ~di_mst_msg[1]           )   // 启动按钮开关
       ,.i_rst        ( ~di_mst_msg[3]           )   // 复位按钮开关
       ,.i_estop        ( di_mst_msg[4]           )   // 急停旋钮开关
       ,.i_manul        ( ~di_mst_msg[5]           )   // 手动选择档L
       ,.i_auto        ( ~di_mst_msg[6]           )   // 自动选择档R
    );

	
	
	
	// --- flow_comp_87 --直线脉冲伺服电机组件---
    ec_pul_axis
    #(
         .REG_SPACE_BIAS     ( 20'd18432)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_pul_axis_87
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[32]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[32]    ),
	  .o_intr_irq            ( map_irq[32]       )

       ,.i_servo_stop        ( ~di_mst_msg[28]           )   // 伺服定位完成
       ,.i_servo_ok        ( ~di_mst_msg[32]           )   // 伺服就绪
       ,.i_axis_limf        ( ~di_mst_msg[29]           )   // 正限位到位开关
       ,.i_axis_limb        ( ~di_mst_msg[31]           )   // 负限位到位开关
       ,.i_axis_zero        ( ~di_mst_msg[30]           )   // 零位到位开关

		    	,.o_dv_pulse			(o_dv_pulse[0]		    )
		    	,.o_dv_dir				(o_dv_dir[0]		    )
		    	,.o_dv_reset			(o_dv_reset[0]		    )
		    	,.o_dv_son				(o_dv_son[0]		    )
    );

	
	
	
	// --- flow_comp_88 --FANUC机器人组件---
    ec_fanuc_robot
    #(
         .REG_SPACE_BIAS     ( 20'd18944)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_fanuc_robot_88
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[33]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[33]    ),
	  .o_intr_irq            ( map_irq[33]       )

    );

	
	
	
	// --- flow_comp_89 --单AVO驱动组件---
    // ec_1avo
    // #(
    //      .REG_SPACE_BIAS     ( 20'd19456)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_1avo_89
    // (
      
	//   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk        ),
    //   .ps_reg_reset          ( ps_reg_reset      ),
	  
	//   .i_time_1ms_vld        ( time_1ms_vld      ),
	//   .i_time_1s_vld         ( time_1s_vld       ),

	//   .i_st_wr_en            ( ps_reg_we         ),
	//   .i_st_wr_addr          ( ps_reg_addr       ),
    //   .i_st_wr_data          ( ps_reg_wr_dat     ),
    //   .i_st_rd_en            ( ps_reg_re         ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr    ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[34]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[34]    ),
	//   .o_intr_irq            ( map_irq[34]       )

    //    ,.ao_dri        ( ai_regoin_msg[1][0]           )   // 模拟量驱动信号
    // );

	
	
	wire   o_sig_dri_90;
	
	// --- flow_comp_90 --单电驱动组件---
    ec_1do
    #(
         .REG_SPACE_BIAS     ( 20'd19968)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1do_90
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[35]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[35]    ),
	  .o_intr_irq            ( map_irq[35]       )

       ,.o_sig_dri        ( o_sig_dri_90           )   // 单电驱动信号
    );

    assign do_mst_msg[10] = ~o_sig_dri_90;
	
	
	wire   o_dri2_91;
	wire   o_dri1_91;
	
	// --- flow_comp_91 --夹爪组件---
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd20480)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3di_2do_91
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[36]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[36]    ),
	  .o_intr_irq            ( map_irq[36]       )

       ,.i_pos1        ( ~di_mst_msg[20]           )   // 张开到位开关
       ,.i_pos2        ( ~di_mst_msg[21]           )   // 闭合到位开关
       ,.i_poa        ( ~di_mst_msg[22]           )   // 物料感测开关
       ,.o_dri1        ( o_dri1_91           )   // 张开驱动信号
       ,.o_dri2        ( o_dri2_91           )   // 闭合驱动信号
    );

    assign do_mst_msg[6] = ~o_dri2_91;
    assign do_mst_msg[5] = ~o_dri1_91;
	
	
	
	// --- flow_comp_92 --西门子PLC/S7组件---
    ec_s7_plc
    #(
         .REG_SPACE_BIAS     ( 20'd20992)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_s7_plc_92
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[37]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[37]    ),
	  .o_intr_irq            ( map_irq[37]       )

    );

	
	
	
	// --- flow_comp_93 --PL_RS232_modbus_RTU组件---
    // ec_pl_rs232_modbus_rtu
    // #(
    //      .REG_SPACE_BIAS     ( 20'd21504)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_pl_rs232_modbus_rtu_93
    // (
      
	//   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk        ),
    //   .ps_reg_reset          ( ps_reg_reset      ),
	  
	//   .i_time_1ms_vld        ( time_1ms_vld      ),
	//   .i_time_1s_vld         ( time_1s_vld       ),

	//   .i_st_wr_en            ( ps_reg_we         ),
	//   .i_st_wr_addr          ( ps_reg_addr       ),
    //   .i_st_wr_data          ( ps_reg_wr_dat     ),
    //   .i_st_rd_en            ( ps_reg_re         ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr    ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[38]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[38]    ),
	//   .o_intr_irq            ( map_irq[38]       )

    //    ,.o_uart_tx        ( RS232_0_tx           )   // 
    //    ,.i_uart_rx        ( RS232_0_rx           )   // 
    // );

	
	
	
	// --- flow_comp_94 --RS485苏培RFID组件---
    // ec_sp_rfid
    // #(
    //      .REG_SPACE_BIAS     ( 20'd22016)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_sp_rfid_94
    // (
      
	//   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk        ),
    //   .ps_reg_reset          ( ps_reg_reset      ),
	  
	//   .i_time_1ms_vld        ( time_1ms_vld      ),
	//   .i_time_1s_vld         ( time_1s_vld       ),

	//   .i_st_wr_en            ( ps_reg_we         ),
	//   .i_st_wr_addr          ( ps_reg_addr       ),
    //   .i_st_wr_data          ( ps_reg_wr_dat     ),
    //   .i_st_rd_en            ( ps_reg_re         ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr    ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[39]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[39]    ),
	//   .o_intr_irq            ( map_irq[39]       )

    //    ,.o_user_req        ( null_user_req[null]           )   // RS485端口
    //    ,.i_user_grant        ( null_user_grant[null]           )   // 
    //    ,.o_uart_tx        ( null_user_tx[null]           )   // 
    //    ,.i_uart_rx        ( null_user_rx[null]           )   // 
    //    ,.o_uart_de        ( null_user_de[null]           )   // 
    // );

	
	
	
	// --- flow_comp_95 --环线速度模式/3DI/扫码/测距/EtherCAT汇川伺服驱动组件---
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd22528)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ethercat_servo_circle_scan_dis_95
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[40]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[40]    ),
	  .o_intr_irq            ( map_irq[40]       )

       ,.i_axis_limb        ( ~di_mst_msg[13]           )   // 停止触发开关
       ,.i_axis_limf        ( ~di_mst_msg[11]           )   // 减速触发开关
    //    ,.i_scan_valid        ( ~di_mst_msg[12]           )   // 扫码触发开关
    //    ,.o_user_req        ( null_user_req[null]           )   // 
    //    ,.i_user_grant        ( null_user_grant[null]           )   // 
    //    ,.o_uart_tx        ( null_user_tx[null]           )   // 
    //    ,.i_uart_rx        ( null_user_rx[null]           )   // 
    //    ,.o_uart_de        ( null_user_de[null]           )   // 
    );

	
	
	
	// --- flow_comp_96 --单圈位置模式/3DI/EtherCAT汇川伺服驱动组件---
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd23040)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ethercat_1c_servo_96
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[41]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[41]    ),
	  .o_intr_irq            ( map_irq[41]       )

       ,.i_axis_limf        ( ~di_mst_msg[8]           )   // 正限位开关
       ,.i_axis_limb        ( ~di_mst_msg[10]           )   // 负限位开关
       ,.i_axis_zero        ( ~di_mst_msg[9]           )   // 零位开关
    );

	
	
	
	// --- flow_comp_97 --直线位置模式/3DI/EtherCAT汇川伺服驱动组件---
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd23552)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ethercat_servo_97
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[42]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[42]    ),
	  .o_intr_irq            ( map_irq[42]       )

       ,.i_axis_limf        ( ~di_mst_msg[39]           )   // 正限位开关
       ,.i_axis_limb        ( ~di_mst_msg[41]           )   // 负限位开关
       ,.i_axis_zero        ( ~di_mst_msg[40]           )   // 零位开关
    );

	
	
	
	// --- flow_comp_98 --西门子PLC/ModBus-TCP组件---
    ec_siemens_plc_modbus_tcp
    #(
         .REG_SPACE_BIAS     ( 20'd24064)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_siemens_plc_modbus_tcp_98
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[43]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[43]    ),
	  .o_intr_irq            ( map_irq[43]       )

    );

	
	
	wire   o_claw_blow_99;
	wire   o_claw_press_99;
	wire   o_claw_unlock_99;
	
	// --- flow_comp_99 --托盘夹爪组件---
    ec_trayclaw
    #(
         .REG_SPACE_BIAS     ( 20'd24576)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_trayclaw_99
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[44]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[44]    ),
	  .o_intr_irq            ( map_irq[44]       )

       ,.o_claw_blow        ( o_claw_blow_99           )   // 吹气驱动信号
       ,.o_claw_press        ( o_claw_press_99           )   // 增压驱动信号
       ,.i_open_arr        ( ~di_mst_msg[33]           )   // 松开到位开关
       ,.i_airtight_arr        ( ~di_mst_msg[36]           )   // 气密检测开关
       ,.i_material_arr        ( ~di_mst_msg[35]           )   // 物料感测开关
       ,.o_claw_unlock        ( o_claw_unlock_99           )   // 解锁驱动信号
       ,.i_close_arr        ( ~di_mst_msg[34]           )   // 锁紧到位开关
    );

    assign do_mst_msg[7] = ~o_claw_blow_99;
    assign do_mst_msg[9] = ~o_claw_press_99;
    assign do_mst_msg[8] = ~o_claw_unlock_99;
	
	
	
	// --- flow_comp_100 --FANUC系统加工中心组件---
    ec_fanuc_cnc
    #(
         .REG_SPACE_BIAS     ( 20'd25088)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_fanuc_cnc_100
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[45]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[45]    ),
	  .o_intr_irq            ( map_irq[45]       )

    );

	
	
	
	// --- flow_comp_101 --西克激光测距组件---
    // ec_sick_DX50_laser_distance
    // #(
    //      .REG_SPACE_BIAS     ( 20'd25600)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_sick_DX50_laser_distance_101
    // (
      
	//   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk        ),
    //   .ps_reg_reset          ( ps_reg_reset      ),
	  
	//   .i_time_1ms_vld        ( time_1ms_vld      ),
	//   .i_time_1s_vld         ( time_1s_vld       ),

	//   .i_st_wr_en            ( ps_reg_we         ),
	//   .i_st_wr_addr          ( ps_reg_addr       ),
    //   .i_st_wr_data          ( ps_reg_wr_dat     ),
    //   .i_st_rd_en            ( ps_reg_re         ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr    ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[46]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[46]    ),
	//   .o_intr_irq            ( map_irq[46]       )

    //    ,.o_user_req        ( null_user_req[null]           )   // RS485端口
    //    ,.i_user_grant        ( null_user_grant[null]           )   // 
    //    ,.o_uart_tx        ( null_user_tx[null]           )   // 
    //    ,.i_uart_rx        ( null_user_rx[null]           )   // 
    //    ,.o_uart_de        ( null_user_de[null]           )   // 
    // );

	
	
	wire   o_dri1_102;
	wire   o_dri_102;
	wire   o_dri2_102;
	
	// --- flow_comp_102 --两位三电驱动组件---
    ec_2di_3do
    #(
         .REG_SPACE_BIAS     ( 20'd26112)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_3do_102
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[47]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[47]    ),
	  .o_intr_irq            ( map_irq[47]       )

       ,.i_pos        ( ~di_regoin_msg[0][42]           )   // 位置到位开关
       ,.o_dri1        ( o_dri1_102           )   // 位置1驱动信号
       ,.o_dri        ( o_dri_102           )   // 单驱信号
       ,.o_dri2        ( o_dri2_102           )   // 位置2驱动信号
       ,.i_poa        ( ~di_regoin_msg[0][43]           )   // 物料感测开关
    );

    assign do_regoin_r_msg[ 0][22] = ~o_dri1_102;
    assign do_regoin_r_msg[ 0][21] = ~o_dri_102;
    assign do_regoin_r_msg[ 0][23] = ~o_dri2_102;
	
	
	wire   o_dri_103;
	
	// --- flow_comp_103 --两位单电驱动组件---
    ec_2di_1do
    #(
         .REG_SPACE_BIAS     ( 20'd26624)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_1do_103
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[48]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[48]    ),
	  .o_intr_irq            ( map_irq[48]       )

       ,.i_pos1        ( ~di_regoin_msg[0][44]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[0][45]           )   // 位置2到位开关
       ,.o_dri        ( o_dri_103           )   // 单电驱动信号
    );

    assign do_regoin_r_msg[ 0][24] = ~o_dri_103;
	
	
	
	// --- flow_comp_104 --五位感知组件---
    ec_5di
    #(
         .REG_SPACE_BIAS     ( 20'd27136)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_5di_104
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[49]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[49]    ),
	  .o_intr_irq            ( map_irq[49]       )

       ,.i_sign1_check        ( ~di_regoin_msg[0][8]           )   // 感测开关1
       ,.i_sign2_check        ( ~di_regoin_msg[0][9]           )   // 感测开关2
       ,.i_sign3_check        ( ~di_regoin_msg[0][10]           )   // 感测开关3
       ,.i_sign4_check        ( ~di_regoin_msg[0][11]           )   // 感测开关4
       ,.i_sign5_check        ( ~di_regoin_msg[0][12]           )   // 感测开关5
    );

	
	
	wire   o_dri_105;
	
	// --- flow_comp_105 --三位单电驱动组件---
    ec_3di_1do
    #(
         .REG_SPACE_BIAS     ( 20'd27648)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3di_1do_105
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[50]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[50]    ),
	  .o_intr_irq            ( map_irq[50]       )

       ,.i_pos1        ( ~di_regoin_msg[0][46]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[0][47]           )   // 位置2到位开关
       ,.i_poa        ( ~di_regoin_msg[0][48]           )   // 物料感测开关
       ,.o_dri        ( o_dri_105           )   // 单电驱动信号
    );

    assign do_regoin_r_msg[ 0][25] = ~o_dri_105;
	
	
	wire   o_lock_106;
	wire   o_mag_106;
	wire   o_demag_106;
	
	// --- flow_comp_106 --悍威磁吸组件---
    ec_hw_sdcx
    #(
         .REG_SPACE_BIAS     ( 20'd28160)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_hw_sdcx_106
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[51]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[51]    ),
	  .o_intr_irq            ( map_irq[51]       )

       ,.o_mag        ( o_mag_106           )   // 充磁驱动信号
       ,.i_mgs        ( ~di_regoin_msg[0][49]           )   // 退磁成功反馈
       ,.o_demag        ( o_demag_106           )   // 退磁驱动信号
       ,.i_dmgs        ( ~di_regoin_msg[0][50]           )   // 充磁成功反馈
       ,.o_lock        ( o_lock_106           )   // 锁定驱动信号
    );

    assign do_regoin_r_msg[ 0][27] = ~o_lock_106;
    assign do_regoin_r_msg[ 0][28] = ~o_mag_106;
    assign do_regoin_r_msg[ 0][26] = ~o_demag_106;
	
	
	
	// --- flow_comp_107 --三线接近开关组件---
    ec_1di
    #(
         .REG_SPACE_BIAS     ( 20'd28672)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1di_107
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[52]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[52]    ),
	  .o_intr_irq            ( map_irq[52]       )

       ,.i_sign1_check        ( ~di_regoin_msg[0][0]           )   // 物料感测端口
    );

	
	
	wire   o_dri1_108;
	wire   o_dri_108;
	wire   o_dri2_108;
	
	// --- flow_comp_108 --卡盘定位器(有传感器)组件---
    ec_2di_3do
    #(
         .REG_SPACE_BIAS     ( 20'd29184)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_3do_108
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[53]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[53]    ),
	  .o_intr_irq            ( map_irq[53]       )

       ,.i_pos        ( ~di_regoin_msg[0][13]           )   // 位置到位开关
       ,.o_dri1        ( o_dri1_108           )   // 张开驱动信号
       ,.o_dri        ( o_dri_108           )   // 吹气驱动信号
       ,.o_dri2        ( o_dri2_108           )   // 闭合驱动信号
       ,.i_poa        ( ~di_regoin_msg[0][14]           )   // 物料感测开关
    );

    assign do_regoin_r_msg[ 0][5] = ~o_dri1_108;
    assign do_regoin_r_msg[ 0][4] = ~o_dri_108;
    assign do_regoin_r_msg[ 0][6] = ~o_dri2_108;
	
	
	wire   o_dri1_109;
	wire   o_dri2_109;
	
	// --- flow_comp_109 --夹爪组件2---
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd29696)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3di_2do_109
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[54]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[54]    ),
	  .o_intr_irq            ( map_irq[54]       )

       ,.i_pos1        ( ~di_regoin_msg[0][1]           )   // 张开到位开关
       ,.i_pos2        ( ~di_regoin_msg[0][2]           )   // 闭合到位开关
       ,.i_poa        ( ~di_regoin_msg[0][3]           )   // 物料感测开关
       ,.o_dri1        ( o_dri1_109           )   // 张开驱动信号
       ,.o_dri2        ( o_dri2_109           )   // 闭合驱动信号
    );

    assign do_regoin_r_msg[ 0][0] = ~o_dri1_109;
    assign do_regoin_r_msg[ 0][1] = ~o_dri2_109;
	
	
	wire   o_dri1_110;
	wire   o_dri2_110;
	
	// --- flow_comp_110 --两位两电控制组件---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd30208)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_110
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[55]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[55]    ),
	  .o_intr_irq            ( map_irq[55]       )

       ,.i_pos1        ( ~di_regoin_msg[0][40]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[0][41]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_110           )   // 位置1驱动信号
       ,.o_dri2        ( o_dri2_110           )   // 位置2驱动信号
    );

    assign do_regoin_r_msg[ 0][19] = ~o_dri1_110;
    assign do_regoin_r_msg[ 0][20] = ~o_dri2_110;
	
	
	wire   o_lock_open_111;
	wire   o_key_light_111;
	
	// --- flow_comp_111 --安全铰链门组件---
    ec_sf_door
    #(
         .REG_SPACE_BIAS     ( 20'd30720)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_sf_door_111
    (
      
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk        ),
      .ps_reg_reset          ( ps_reg_reset      ),
	  
	  .i_time_1ms_vld        ( time_1ms_vld      ),
	  .i_time_1s_vld         ( time_1s_vld       ),

	  .i_st_wr_en            ( ps_reg_we         ),
	  .i_st_wr_addr          ( ps_reg_addr       ),
      .i_st_wr_data          ( ps_reg_wr_dat     ),
      .i_st_rd_en            ( ps_reg_re         ),
      .i_st_rd_addr          ( ps_reg_rd_addr    ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[56]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[56]    ),
	  .o_intr_irq            ( map_irq[56]       )

    //    ,.o_key_light        ( o_key_light_111           )   // 
       ,.i_lock_monitor        ( ~di_mst_msg[63]           )   // 锁监控常闭DO端口
       ,.i_close_confirm_key        ( ~di_regoin_msg[0][18]           )   // 门关确认黄色按钮
       ,.i_open_req_key        ( ~di_mst_msg[64]           )   // 开门请求绿色按钮
    //    ,.i_door_monitor        ( di_regoin_msg[0][15]           )   // 门监控常闭DO端口
       ,.o_lock_open        ( o_lock_open_111           )   // 电磁锁A1
    );

    assign do_regoin_r_msg[ 0][7] = ~o_lock_open_111;
    assign do_regoin_r_msg[ 0][9] = ~o_key_light_111;
	

	`endif

	
endmodule