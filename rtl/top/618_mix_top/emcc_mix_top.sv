
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
    
    //emcc_token_if #(.DATA_WIDTH(TOKEN_DWIDTH))  roller_s00_token_if[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
    //emcc_token_if #(.DATA_WIDTH(TOKEN_DWIDTH))  roller_s01_token_if[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
    //emcc_token_if #(.DATA_WIDTH(TOKEN_DWIDTH))  roller_s02_token_if[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
	
	//emcc_flow_if flow_cfg_if[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
	
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
	
	
	    assign do_mst_msg[0:0] = 1'b1 ;
    assign do_mst_msg[2:2] = 1'b1 ;
    assign do_mst_msg[5:5] = 1'b1 ;
    assign do_mst_msg[15:15] = 1'b1 ;
    assign do_mst_msg[16:16] = 1'b1 ;
    assign do_mst_msg[17:17] = 1'b1 ;
    assign do_mst_msg[18:18] = 1'b1 ;
    assign do_mst_msg[19:19] = 1'b1 ;
    assign do_mst_msg[20:20] = 1'b1 ;
    assign do_mst_msg[21:21] = 1'b1 ;
    assign do_mst_msg[22:22] = 1'b1 ;
    assign do_mst_msg[23:23] = 1'b1 ;
    assign do_mst_msg[24:24] = 1'b1 ;
    assign do_mst_msg[25:25] = 1'b1 ;
    assign do_mst_msg[26:26] = 1'b1 ;
    assign do_mst_msg[27:27] = 1'b1 ;
    assign do_mst_msg[28:28] = 1'b1 ;
    assign do_mst_msg[29:29] = 1'b1 ;
    assign do_mst_msg[30:30] = 1'b1 ;
    assign do_mst_msg[31:31] = 1'b1 ;
    assign do_regoin_r_msg[3][7:7] = 1'b1 ;
    assign do_regoin_r_msg[3][8:8] = 1'b1 ;
    assign do_regoin_r_msg[3][9:9] = 1'b1 ;
    assign do_regoin_r_msg[3][10:10] = 1'b1 ;
    assign do_regoin_r_msg[3][11:11] = 1'b1 ;
    assign do_regoin_r_msg[3][12:12] = 1'b1 ;
    assign do_regoin_r_msg[3][13:13] = 1'b1 ;
    assign do_regoin_r_msg[3][14:14] = 1'b1 ;
    assign do_regoin_r_msg[3][15:15] = 1'b1 ;
    assign do_regoin_r_msg[3][16:16] = 1'b1 ;
    assign do_regoin_r_msg[3][17:17] = 1'b1 ;
    assign do_regoin_r_msg[3][18:18] = 1'b1 ;
    assign do_regoin_r_msg[3][19:19] = 1'b1 ;
    assign do_regoin_r_msg[3][20:20] = 1'b1 ;
    assign do_regoin_r_msg[3][21:21] = 1'b1 ;
    assign do_regoin_r_msg[3][22:22] = 1'b1 ;
    assign do_regoin_r_msg[3][23:23] = 1'b1 ;
    assign do_regoin_r_msg[3][28:28] = 1'b1 ;
    assign do_regoin_r_msg[3][29:29] = 1'b1 ;
    assign do_regoin_r_msg[3][30:30] = 1'b1 ;
    assign do_regoin_r_msg[3][31:31] = 1'b1 ;
    assign do_regoin_r_msg[3][32:32] = 1'b1 ;
    assign do_regoin_r_msg[3][33:33] = 1'b1 ;
    assign do_regoin_r_msg[3][34:34] = 1'b1 ;
    assign do_regoin_r_msg[3][35:35] = 1'b1 ;
    assign do_regoin_r_msg[3][36:36] = 1'b1 ;
    assign do_regoin_r_msg[3][37:37] = 1'b1 ;
    assign do_regoin_r_msg[3][38:38] = 1'b1 ;
    assign do_regoin_r_msg[3][39:39] = 1'b1 ;
    assign do_regoin_r_msg[3][40:40] = 1'b1 ;
    assign do_regoin_r_msg[3][41:41] = 1'b1 ;
    assign do_regoin_r_msg[3][42:42] = 1'b1 ;
    assign do_regoin_r_msg[3][43:43] = 1'b1 ;
    assign do_regoin_r_msg[3][44:44] = 1'b1 ;
    assign do_regoin_r_msg[3][45:45] = 1'b1 ;
    assign do_regoin_r_msg[3][46:46] = 1'b1 ;
    assign do_regoin_r_msg[3][47:47] = 1'b1 ;
    assign do_regoin_r_msg[4][0:0] = 1'b1 ;
    assign do_regoin_r_msg[4][4:4] = 1'b1 ;
    assign do_regoin_r_msg[4][5:5] = 1'b1 ;
    assign do_regoin_r_msg[4][6:6] = 1'b1 ;
    assign do_regoin_r_msg[4][19:19] = 1'b1 ;
    assign do_regoin_r_msg[4][20:20] = 1'b1 ;
    assign do_regoin_r_msg[4][21:21] = 1'b1 ;
    assign do_regoin_r_msg[4][22:22] = 1'b1 ;
    assign do_regoin_r_msg[4][23:23] = 1'b1 ;
    assign do_regoin_r_msg[4][24:24] = 1'b1 ;
    assign do_regoin_r_msg[4][25:25] = 1'b1 ;
    assign do_regoin_r_msg[4][26:26] = 1'b1 ;
    assign do_regoin_r_msg[4][27:27] = 1'b1 ;
    assign do_regoin_r_msg[4][28:28] = 1'b1 ;
    assign do_regoin_r_msg[4][29:29] = 1'b1 ;
    assign do_regoin_r_msg[4][30:30] = 1'b1 ;
    assign do_regoin_r_msg[4][31:31] = 1'b1 ;
    assign do_regoin_r_msg[4][40:40] = 1'b1 ;
    assign do_regoin_r_msg[4][41:41] = 1'b1 ;
    assign do_regoin_r_msg[4][42:42] = 1'b1 ;
    assign do_regoin_r_msg[4][43:43] = 1'b1 ;
    assign do_regoin_r_msg[4][44:44] = 1'b1 ;
    assign do_regoin_r_msg[4][45:45] = 1'b1 ;
    assign do_regoin_r_msg[4][46:46] = 1'b1 ;
    assign do_regoin_r_msg[4][47:47] = 1'b1 ;
    assign do_regoin_r_msg[0][4:4] = 1'b1 ;
    assign do_regoin_r_msg[0][5:5] = 1'b1 ;
    assign do_regoin_r_msg[0][6:6] = 1'b1 ;
    assign do_regoin_r_msg[0][7:7] = 1'b1 ;
    assign do_regoin_r_msg[0][28:28] = 1'b1 ;
    assign do_regoin_r_msg[0][29:29] = 1'b1 ;
    assign do_regoin_r_msg[0][30:30] = 1'b1 ;
    assign do_regoin_r_msg[0][31:31] = 1'b1 ;
    assign do_regoin_r_msg[0][32:32] = 1'b1 ;
    assign do_regoin_r_msg[0][33:33] = 1'b1 ;
    assign do_regoin_r_msg[0][34:34] = 1'b1 ;
    assign do_regoin_r_msg[0][35:35] = 1'b1 ;
    assign do_regoin_r_msg[0][36:36] = 1'b1 ;
    assign do_regoin_r_msg[0][37:37] = 1'b1 ;
    assign do_regoin_r_msg[0][38:38] = 1'b1 ;
    assign do_regoin_r_msg[0][39:39] = 1'b1 ;
    assign do_regoin_r_msg[0][40:40] = 1'b1 ;
    assign do_regoin_r_msg[0][41:41] = 1'b1 ;
    assign do_regoin_r_msg[0][42:42] = 1'b1 ;
    assign do_regoin_r_msg[0][43:43] = 1'b1 ;
    assign do_regoin_r_msg[0][44:44] = 1'b1 ;
    assign do_regoin_r_msg[0][45:45] = 1'b1 ;
    assign do_regoin_r_msg[0][46:46] = 1'b1 ;
    assign do_regoin_r_msg[0][47:47] = 1'b1 ;
    assign do_regoin_r_msg[1][6:6] = 1'b1 ;
    assign do_regoin_r_msg[1][7:7] = 1'b1 ;
    assign do_regoin_r_msg[1][8:8] = 1'b1 ;
    assign do_regoin_r_msg[1][9:9] = 1'b1 ;
    assign do_regoin_r_msg[1][10:10] = 1'b1 ;
    assign do_regoin_r_msg[1][11:11] = 1'b1 ;
    assign do_regoin_r_msg[1][12:12] = 1'b1 ;
    assign do_regoin_r_msg[1][13:13] = 1'b1 ;
    assign do_regoin_r_msg[1][14:14] = 1'b1 ;
    assign do_regoin_r_msg[1][15:15] = 1'b1 ;
    assign do_regoin_r_msg[1][16:16] = 1'b1 ;
    assign do_regoin_r_msg[1][17:17] = 1'b1 ;
    assign do_regoin_r_msg[1][18:18] = 1'b1 ;
    assign do_regoin_r_msg[1][19:19] = 1'b1 ;
    assign do_regoin_r_msg[1][20:20] = 1'b1 ;
    assign do_regoin_r_msg[1][21:21] = 1'b1 ;
    assign do_regoin_r_msg[1][22:22] = 1'b1 ;
    assign do_regoin_r_msg[1][23:23] = 1'b1 ;
    assign do_regoin_r_msg[1][24:24] = 1'b1 ;
    assign do_regoin_r_msg[1][25:25] = 1'b1 ;
    assign do_regoin_r_msg[1][26:26] = 1'b1 ;
    assign do_regoin_r_msg[1][27:27] = 1'b1 ;
    assign do_regoin_r_msg[1][33:33] = 1'b1 ;
    assign do_regoin_r_msg[1][34:34] = 1'b1 ;
    assign do_regoin_r_msg[1][35:35] = 1'b1 ;
    assign do_regoin_r_msg[1][36:36] = 1'b1 ;
    assign do_regoin_r_msg[1][37:37] = 1'b1 ;
    assign do_regoin_r_msg[1][38:38] = 1'b1 ;
    assign do_regoin_r_msg[1][39:39] = 1'b1 ;
    assign do_regoin_r_msg[1][40:40] = 1'b1 ;
    assign do_regoin_r_msg[1][41:41] = 1'b1 ;
    assign do_regoin_r_msg[1][42:42] = 1'b1 ;
    assign do_regoin_r_msg[1][43:43] = 1'b1 ;
    assign do_regoin_r_msg[1][44:44] = 1'b1 ;
    assign do_regoin_r_msg[1][45:45] = 1'b1 ;
    assign do_regoin_r_msg[1][46:46] = 1'b1 ;
    assign do_regoin_r_msg[1][47:47] = 1'b1 ;
    assign do_regoin_r_msg[2][4:4] = 1'b1 ;
    assign do_regoin_r_msg[2][5:5] = 1'b1 ;
    assign do_regoin_r_msg[2][6:6] = 1'b1 ;
    assign do_regoin_r_msg[2][14:14] = 1'b1 ;
    assign do_regoin_r_msg[2][15:15] = 1'b1 ;
    assign do_regoin_r_msg[2][24:24] = 1'b1 ;
    assign do_regoin_r_msg[2][25:25] = 1'b1 ;
    assign do_regoin_r_msg[2][26:26] = 1'b1 ;
    assign do_regoin_r_msg[2][27:27] = 1'b1 ;
    assign do_regoin_r_msg[2][28:28] = 1'b1 ;
    assign do_regoin_r_msg[2][30:30] = 1'b1 ;
    assign do_regoin_r_msg[2][32:32] = 1'b1 ;
    assign do_regoin_r_msg[2][33:33] = 1'b1 ;
    assign do_regoin_r_msg[2][34:34] = 1'b1 ;
    assign do_regoin_r_msg[2][35:35] = 1'b1 ;
    assign do_regoin_r_msg[2][36:36] = 1'b1 ;
    assign do_regoin_r_msg[2][37:37] = 1'b1 ;
    assign do_regoin_r_msg[2][38:38] = 1'b1 ;
    assign do_regoin_r_msg[2][39:39] = 1'b1 ;
    assign do_regoin_r_msg[2][40:40] = 1'b1 ;
    assign do_regoin_r_msg[2][41:41] = 1'b1 ;
    assign do_regoin_r_msg[2][42:42] = 1'b1 ;
    assign do_regoin_r_msg[2][43:43] = 1'b1 ;
    assign do_regoin_r_msg[2][44:44] = 1'b1 ;
    assign do_regoin_r_msg[2][45:45] = 1'b1 ;
    assign do_regoin_r_msg[2][46:46] = 1'b1 ;
    assign do_regoin_r_msg[2][47:47] = 1'b1 ;
	
	
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
    assign  emcc_irq[46]   = map_irq[46];
    assign  emcc_irq[168]   = map_irq[168];
    assign  emcc_irq[169]   = map_irq[169];
    assign  emcc_irq[167]   = map_irq[167];
    assign  emcc_irq[155]   = map_irq[155];
    assign  emcc_irq[180]   = map_irq[180];
    assign  emcc_irq[181]   = map_irq[181];
    assign  emcc_irq[179]   = map_irq[179];
    assign  emcc_irq[189]   = map_irq[189];
    assign  emcc_irq[186]   = map_irq[186];
    assign  emcc_irq[90]   = map_irq[90];
    assign  emcc_irq[185]   = map_irq[185];
    assign  emcc_irq[188]   = map_irq[188];
    assign  emcc_irq[187]   = map_irq[187];
    assign  emcc_irq[184]   = map_irq[184];
    assign  emcc_irq[182]   = map_irq[182];
    assign  emcc_irq[183]   = map_irq[183];
    assign  emcc_irq[109]   = map_irq[109];
    assign  emcc_irq[159]   = map_irq[159];
    assign  emcc_irq[91]   = map_irq[91];
    assign  emcc_irq[161]   = map_irq[161];
    assign  emcc_irq[190]   = map_irq[190];
    assign  emcc_irq[192]   = map_irq[192];
    assign  emcc_irq[193]   = map_irq[193];
    assign  emcc_irq[176]   = map_irq[176];
    assign  emcc_irq[177]   = map_irq[177];
    assign  emcc_irq[178]   = map_irq[178];
    assign  emcc_irq[194]   = map_irq[194];
    assign  emcc_irq[92]   = map_irq[92];
    assign  emcc_irq[108]   = map_irq[108];
    assign  emcc_irq[197]   = map_irq[197];
    assign  emcc_irq[198]   = map_irq[198];
    assign  emcc_irq[199]   = map_irq[199];
    assign  emcc_irq[200]   = map_irq[200];
    assign  emcc_irq[95]   = map_irq[95];
    assign  emcc_irq[96]   = map_irq[96];
    assign  emcc_irq[97]   = map_irq[97];
    assign  emcc_irq[89]   = map_irq[89];
    assign  emcc_irq[104]   = map_irq[104];
    assign  emcc_irq[99]   = map_irq[99];
    assign  emcc_irq[64]   = map_irq[64];
    assign  emcc_irq[100]   = map_irq[100];
    assign  emcc_irq[101]   = map_irq[101];
    assign  emcc_irq[93]   = map_irq[93];
    assign  emcc_irq[103]   = map_irq[103];
    assign  emcc_irq[105]   = map_irq[105];
    assign  emcc_irq[94]   = map_irq[94];
    assign  emcc_irq[106]   = map_irq[106];
    assign  emcc_irq[102]   = map_irq[102];
    assign  emcc_irq[98]   = map_irq[98];
    assign  emcc_irq[82]   = map_irq[82];
    assign  emcc_irq[195]   = map_irq[195];
    assign  emcc_irq[196]   = map_irq[196];
    assign  emcc_irq[123]   = map_irq[123];
    assign  emcc_irq[124]   = map_irq[124];
    assign  emcc_irq[125]   = map_irq[125];
    assign  emcc_irq[126]   = map_irq[126];
    assign  emcc_irq[127]   = map_irq[127];
    assign  emcc_irq[84]   = map_irq[84];
    assign  emcc_irq[131]   = map_irq[131];
    assign  emcc_irq[132]   = map_irq[132];
    assign  emcc_irq[133]   = map_irq[133];
    assign  emcc_irq[128]   = map_irq[128];
    assign  emcc_irq[134]   = map_irq[134];
    assign  emcc_irq[129]   = map_irq[129];
    assign  emcc_irq[135]   = map_irq[135];
    assign  emcc_irq[130]   = map_irq[130];
    assign  emcc_irq[138]   = map_irq[138];
    assign  emcc_irq[139]   = map_irq[139];
    assign  emcc_irq[85]   = map_irq[85];
    assign  emcc_irq[140]   = map_irq[140];
    assign  emcc_irq[141]   = map_irq[141];
    assign  emcc_irq[145]   = map_irq[145];
    assign  emcc_irq[137]   = map_irq[137];
    assign  emcc_irq[144]   = map_irq[144];
    assign  emcc_irq[142]   = map_irq[142];
    assign  emcc_irq[136]   = map_irq[136];
    assign  emcc_irq[110]   = map_irq[110];
    assign  emcc_irq[111]   = map_irq[111];
    assign  emcc_irq[83]   = map_irq[83];
    assign  emcc_irq[112]   = map_irq[112];
    assign  emcc_irq[122]   = map_irq[122];
    assign  emcc_irq[114]   = map_irq[114];
    assign  emcc_irq[115]   = map_irq[115];
    assign  emcc_irq[116]   = map_irq[116];
    assign  emcc_irq[143]   = map_irq[143];
    assign  emcc_irq[154]   = map_irq[154];
    assign  emcc_irq[147]   = map_irq[147];
    assign  emcc_irq[146]   = map_irq[146];
    assign  emcc_irq[86]   = map_irq[86];
    assign  emcc_irq[150]   = map_irq[150];
    assign  emcc_irq[153]   = map_irq[153];
    assign  emcc_irq[148]   = map_irq[148];
    assign  emcc_irq[151]   = map_irq[151];
    assign  emcc_irq[152]   = map_irq[152];
    assign  emcc_irq[149]   = map_irq[149];
    assign  emcc_irq[117]   = map_irq[117];
    assign  emcc_irq[119]   = map_irq[119];
    assign  emcc_irq[118]   = map_irq[118];
    assign  emcc_irq[113]   = map_irq[113];
    assign  emcc_irq[87]   = map_irq[87];
    assign  emcc_irq[191]   = map_irq[191];
    assign  emcc_irq[202]   = map_irq[202];
    assign  emcc_irq[120]   = map_irq[120];
    assign  emcc_irq[121]   = map_irq[121];
    assign  emcc_irq[156]   = map_irq[156];
    assign  emcc_irq[157]   = map_irq[157];
    assign  emcc_irq[158]   = map_irq[158];
    assign  emcc_irq[164]   = map_irq[164];
    assign  emcc_irq[166]   = map_irq[166];
    assign  emcc_irq[88]   = map_irq[88];
    assign  emcc_irq[163]   = map_irq[163];
    assign  emcc_irq[160]   = map_irq[160];
    assign  emcc_irq[165]   = map_irq[165];
    assign  emcc_irq[162]   = map_irq[162];
    assign  emcc_irq[175]   = map_irq[175];
    assign  emcc_irq[174]   = map_irq[174];
    assign  emcc_irq[173]   = map_irq[173];
    assign  emcc_irq[170]   = map_irq[170];
    assign  emcc_irq[171]   = map_irq[171];
    assign  emcc_irq[172]   = map_irq[172];
    
	
	
	// --- flow_comp_1 --A0001_磨床1---
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     ( 20'd25600)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_1
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[46]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[46]    ),
	  .o_intr_irq            ( map_irq[46]       )

    );

	
	
	
	// --- flow_comp_2 --A0002_磨床2---
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     ( 20'd34816)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_2
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[64]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[64]    ),
	  .o_intr_irq            ( map_irq[64]       )

    );

	
	
	
	// --- flow_comp_3 --A0003_磨床3---
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     ( 20'd44032)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_3
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[82]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[82]    ),
	  .o_intr_irq            ( map_irq[82]       )

    );

	
	
	
	// --- flow_comp_4 --A0004_磨床4---
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     ( 20'd45056)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_4
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[84]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[84]    ),
	  .o_intr_irq            ( map_irq[84]       )

    );

	
	
	
	// --- flow_comp_5 --A0005_磨床5---
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     ( 20'd45568)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_5
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[85]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[85]    ),
	  .o_intr_irq            ( map_irq[85]       )

    );

	
	
	
	// --- flow_comp_6 --A0006_磨床6---
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     ( 20'd44544)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_6
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[83]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[83]    ),
	  .o_intr_irq            ( map_irq[83]       )

    );

	
	
	
	// --- flow_comp_7 --A0007_磨床7---
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     ( 20'd46080)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_7
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[86]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[86]    ),
	  .o_intr_irq            ( map_irq[86]       )

    );

	
	
	
	// --- flow_comp_8 --A0008_磨床8---
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     ( 20'd46592)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_8
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[87]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[87]    ),
	  .o_intr_irq            ( map_irq[87]       )

    );

	
	
	
	// --- flow_comp_9 --A0009_磨床9---
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     ( 20'd47104)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_9
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[88]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[88]    ),
	  .o_intr_irq            ( map_irq[88]       )

    );

	
	
	
	// --- flow_comp_11 --A0011_海克斯康三坐标1---
    ec_hex_coordinate
    #(
         .REG_SPACE_BIAS     ( 20'd48128)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_hex_coordinate_11
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[90]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[90]    ),
	  .o_intr_irq            ( map_irq[90]       )

    );

	
	
	
	// --- flow_comp_12 --A0012_海克斯康三坐标2---
    ec_hex_coordinate
    #(
         .REG_SPACE_BIAS     ( 20'd48640)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_hex_coordinate_12
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[91]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[91]    ),
	  .o_intr_irq            ( map_irq[91]       )

    );

	
	
	
	// --- flow_comp_13 --A0013_海克斯康影像测量仪---
    ec_hex_coordinate
    #(
         .REG_SPACE_BIAS     ( 20'd49152)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_hex_coordinate_13
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[92]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[92]    ),
	  .o_intr_irq            ( map_irq[92]       )

    );

	
	
	wire   o_dri1_14;
	wire   o_dri2_14;
	
	// --- flow_comp_14 --A0014_1#三坐标卡盘---
    ec_2di_3do
    #(
         .REG_SPACE_BIAS     ( 20'd50688)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_3do_14
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[95]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[95]    ),
	  .o_intr_irq            ( map_irq[95]       )

       ,.i_pos        ( ~di_mst_msg[50]           )   // 位置到位开关
       ,.o_dri1        ( o_dri1_14           )   // 卡盘开驱动信号
       ,.o_dri2        ( o_dri2_14           )   // 卡盘关驱动信号
       ,.o_dri        (            )   // 
       ,.i_poa        ( 1'b0           )   // 
    );

    assign do_regoin_r_msg[2][17] = ~o_dri1_14;
    assign do_regoin_r_msg[2][16] = ~o_dri2_14;
	
	
	wire   o_dri2_15;
	wire   o_dri1_15;
	
	// --- flow_comp_15 --A0015_2#三坐标卡盘---
    ec_2di_3do
    #(
         .REG_SPACE_BIAS     ( 20'd51200)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_3do_15
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[96]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[96]    ),
	  .o_intr_irq            ( map_irq[96]       )

       ,.i_pos        ( ~di_mst_msg[51]           )   // 位置到位开关
       ,.o_dri1        ( o_dri1_15           )   // 卡盘开驱动信号
       ,.o_dri2        ( o_dri2_15           )   // 卡盘关驱动信号
       ,.o_dri        (            )   // 
       ,.i_poa        ( 1'b0           )   // 
    );

    assign do_regoin_r_msg[2][18] = ~o_dri2_15;
    assign do_regoin_r_msg[2][19] = ~o_dri1_15;
	
	
	wire   o_dri1_16;
	wire   o_dri2_16;
	
	// --- flow_comp_16 --A0016_影像测量仪卡盘---
    ec_2di_3do
    #(
         .REG_SPACE_BIAS     ( 20'd51712)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_3do_16
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[97]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[97]    ),
	  .o_intr_irq            ( map_irq[97]       )

       ,.i_pos        ( ~di_mst_msg[54]           )   // 位置到位开关
       ,.o_dri1        ( o_dri1_16           )   // 卡盘开驱动信号
       ,.o_dri2        ( o_dri2_16           )   // 卡盘关驱动信号
       ,.o_dri        (            )   // 
       ,.i_poa        ( 1'b0           )   // 
    );

    assign do_regoin_r_msg[2][21] = ~o_dri1_16;
    assign do_regoin_r_msg[2][20] = ~o_dri2_16;
	
	
	
	// --- flow_comp_17 --A0017_蓝鲸清洗机---
    ec_lanj_washer
    #(
         .REG_SPACE_BIAS     ( 20'd47616)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_lanj_washer_17
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[89]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[89]    ),
	  .o_intr_irq            ( map_irq[89]       )

    );

	
	
	
	// --- flow_comp_18 --A0018_主地轨搬运机器人---
    ec_fanuc_robot
    #(
         .REG_SPACE_BIAS     ( 20'd55296)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_fanuc_robot_18
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[104]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[104]    ),
	  .o_intr_irq            ( map_irq[104]       )

    );

	
	
	
	// --- flow_comp_19 --A0019_短桁架1#机器人---
    ec_fanuc_robot
    #(
         .REG_SPACE_BIAS     ( 20'd52736)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_fanuc_robot_19
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[99]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[99]    ),
	  .o_intr_irq            ( map_irq[99]       )

    );

	
	
	
	// --- flow_comp_20 --A0020_长桁架1#机器人---
    ec_fanuc_robot
    #(
         .REG_SPACE_BIAS     ( 20'd53248)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_fanuc_robot_20
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[100]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[100]    ),
	  .o_intr_irq            ( map_irq[100]       )

    );

	
	
	
	// --- flow_comp_21 --A0021_长桁架2#机器人---
    ec_fanuc_robot
    #(
         .REG_SPACE_BIAS     ( 20'd53760)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_fanuc_robot_21
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[101]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[101]    ),
	  .o_intr_irq            ( map_irq[101]       )

    );

	
	
	
	// --- flow_comp_22 --A0022_搬运机器人---
    ec_fanuc_robot
    #(
         .REG_SPACE_BIAS     ( 20'd49664)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_fanuc_robot_22
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[93]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[93]    ),
	  .o_intr_irq            ( map_irq[93]       )

    );

	
	
	wire   o_claw_press_23;
	wire   o_claw_unlock_23;
	
	// --- flow_comp_23 --A0023_地轨机器人托盘搬运夹爪---
    ec_trayclaw
    #(
         .REG_SPACE_BIAS     ( 20'd54784)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_trayclaw_23
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[103]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[103]    ),
	  .o_intr_irq            ( map_irq[103]       )

       ,.o_claw_press        ( o_claw_press_23           )   // 增压驱动信号
       ,.i_open_arr        ( ~di_mst_msg[22]           )   // 松开到位开关
       ,.i_material_arr        ( di_mst_msg[17]           )   // 物料感测开关
       ,.o_claw_unlock        ( o_claw_unlock_23           )   // 解锁驱动信号
       ,.i_close_arr        ( ~di_mst_msg[23]           )   // 锁紧到位开关
       ,.o_claw_blow        (            )   // 
       ,.i_airtight_arr        ( 1'b0           )   // 
    );

    assign do_mst_msg[1] = ~o_claw_press_23;
    assign do_mst_msg[12] = ~o_claw_unlock_23;
	
	
	wire   o_dri1_24;
	wire   o_dri2_24;
	
	// --- flow_comp_24 --A0024_地轨机器人砂轮搬运夹爪---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd55808)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_24
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[105]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[105]    ),
	  .o_intr_irq            ( map_irq[105]       )

       ,.i_pos1        ( ~di_mst_msg[19]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_mst_msg[20]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_24           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_24           )   // 驱动信号2
    );

    assign do_mst_msg[13] = ~o_dri1_24;
    assign do_mst_msg[14] = ~o_dri2_24;
	
	
	wire   o_dri1_25;
	wire   o_dri2_25;
	
	// --- flow_comp_25 --A0025_搬运机器人夹爪---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd50176)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_25
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[94]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[94]    ),
	  .o_intr_irq            ( map_irq[94]       )

       ,.i_pos1        ( ~di_regoin_msg[2][16]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[2][14]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_25           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_25           )   // 驱动信号2
    );

    assign do_regoin_r_msg[2][22] = ~o_dri1_25;
    assign do_regoin_r_msg[2][23] = ~o_dri2_25;
	
	
	
	// // --- flow_comp_26 --A0026_地轨机器人_RFID读写器---
    // ec_sp_rfid
    // #(
    //      .REG_SPACE_BIAS     ( 20'd56320)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_sp_rfid_26
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
	//   .o_st_rd_vld           ( sub_comp_rd_vld[106]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[106]    ),
	//   .o_intr_irq            ( map_irq[106]       )

    //    ,.o_user_req        ( rs485_1_user_req[0]           )   // RS485端口
    //    ,.i_user_grant        ( rs485_1_user_grant[0]           )   // 
    //    ,.o_uart_tx        ( rs485_1_user_tx[0]           )   // 
    //    ,.i_uart_rx        ( rs485_1_user_rx[0]           )   // 
    //    ,.o_uart_de        ( rs485_1_user_de[0]           )   // 
    // );
ec_superisys_485_modbus_rtu
#(
        .REG_SPACE_BIAS         (20'hdc00                ), //组件基地址
        .REG_SPACE_SIZE         (`REG_SPACE_SIZE          ), //组件偏移地址
        .CLK_FREQ               (156250000                )  //100MHz = 100000000
)
ec_superisys_485_modbus_rtu_26
(
        .clk_i                  ( clk                     ),
        .rst                    ( reset                   ),
        .i_time_1ms_vld         ( time_1ms_vld            ),
        .i_time_1s_vld          ( time_1s_vld             ),
        .ps_reg_clk             ( ps_reg_clk              ),
        .ps_reg_reset           ( ps_reg_reset            ),
        .i_st_wr_en             ( ps_reg_we               ),//bram总线
        .i_st_wr_addr           ( ps_reg_addr             ),
        .i_st_wr_data           ( ps_reg_wr_dat           ),
        .i_st_rd_en             ( ps_reg_re               ),
        .i_st_rd_addr           ( ps_reg_rd_addr          ),
        .o_st_rd_data           ( sub_comp_rd_dat[106]    ),
        .o_st_rd_vld            ( sub_comp_rd_vld[106]    ),
        .o_intr_irq             ( map_irq[106]            ),//组件中断请求
        
        //--- 主板Uart接口
        .i_uart_rx              ( rs485_1_user_rx[0]      ),
        .o_uart_tx              ( rs485_1_user_tx[0]      ),
        .o_uart_de              ( rs485_1_user_de[0]      ),
        .o_user_req             ( rs485_1_user_req[0]     ),
        .i_user_grant           ( rs485_1_user_grant[0]   ),

         //--- 从板接口 use clk domain 156.25MHz --
        .cur_slv_board_id       ( 0                       ), //
        .slv_board_id           ( slv_board_id            ), 
        .rs485_ch_r_flag        ( rs485_00_r_flag         ), //send en
        .m2s_rs485_msg          ( rs485_00_send_msg[0]    ), //send data
        .rs485_ch_flag          ( rs485_00_flag           ), //recv en
        .s2m_rs485_msg          ( rs485_00_msg[0]         )  //recv data
    );
	
	
	
	// // --- flow_comp_27 --A0027_短桁架1#夹爪RFID读写器---
    // ec_sp_rfid
    // #(
    //      .REG_SPACE_BIAS     ( 20'd54272)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_sp_rfid_27
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
	//   .o_st_rd_vld           ( sub_comp_rd_vld[102]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[102]    ),
	//   .o_intr_irq            ( map_irq[102]       )

    //    ,.o_user_req        ( rs485_1_user_req[1]           )   // RS485端口
    //    ,.i_user_grant        ( rs485_1_user_grant[1]           )   // 
    //    ,.o_uart_tx        ( rs485_1_user_tx[1]           )   // 
    //    ,.i_uart_rx        ( rs485_1_user_rx[1]           )   // 
    //    ,.o_uart_de        ( rs485_1_user_de[1]           )   // 
    // );

ec_superisys_485_modbus_rtu
#(
        .REG_SPACE_BIAS         (20'hd400                ), //组件基地址
        .REG_SPACE_SIZE         (`REG_SPACE_SIZE          ), //组件偏移地址
        .CLK_FREQ               (156250000                )  //100MHz = 100000000
)
ec_superisys_485_modbus_rtu_27
(
        .clk_i                  ( clk                     ),
        .rst                    ( reset                   ),
        .i_time_1ms_vld         ( time_1ms_vld            ),
        .i_time_1s_vld          ( time_1s_vld             ),
        .ps_reg_clk             ( ps_reg_clk              ),
        .ps_reg_reset           ( ps_reg_reset            ),
        .i_st_wr_en             ( ps_reg_we               ),//bram总线
        .i_st_wr_addr           ( ps_reg_addr             ),
        .i_st_wr_data           ( ps_reg_wr_dat           ),
        .i_st_rd_en             ( ps_reg_re               ),
        .i_st_rd_addr           ( ps_reg_rd_addr          ),
        .o_st_rd_data           ( sub_comp_rd_dat[102]    ),
        .o_st_rd_vld            ( sub_comp_rd_vld[102]    ),
        .o_intr_irq             ( map_irq[102]            ),//组件中断请求
        
        //--- 主板Uart接口
        .i_uart_rx              ( rs485_1_user_rx[1]      ),
        .o_uart_tx              ( rs485_1_user_tx[1]      ),
        .o_uart_de              ( rs485_1_user_de[1]      ),
        .o_user_req             ( rs485_1_user_req[1]     ),
        .i_user_grant           ( rs485_1_user_grant[1]   ),

         //--- 从板接口 use clk domain 156.25MHz --
        .cur_slv_board_id      (                          ), //
        .slv_board_id          (                          ), 
        .rs485_ch_r_flag       ( 0                        ), //send en
        .m2s_rs485_msg         (                          ), //send data
        .rs485_ch_flag         (                          ), //recv en
        .s2m_rs485_msg         (                          )  //recv data
    );
	
	
	
	// // --- flow_comp_28 --A0028_固定机器人_RFID读写器---
    // ec_sp_rfid
    // #(
    //      .REG_SPACE_BIAS     ( 20'd52224)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_sp_rfid_28
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
	//   .o_st_rd_vld           ( sub_comp_rd_vld[98]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[98]    ),
	//   .o_intr_irq            ( map_irq[98]       )

    //    ,.o_user_req        ( rs485_1_user_req[2]           )   // RS485端口
    //    ,.i_user_grant        ( rs485_1_user_grant[2]           )   // 
    //    ,.o_uart_tx        ( rs485_1_user_tx[2]           )   // 
    //    ,.i_uart_rx        ( rs485_1_user_rx[2]           )   // 
    //    ,.o_uart_de        ( rs485_1_user_de[2]           )   // 
    // );

ec_superisys_485_modbus_rtu
#(
        .REG_SPACE_BIAS         (20'hcc00                ), //组件基地址
        .REG_SPACE_SIZE         (`REG_SPACE_SIZE          ), //组件偏移地址
        .CLK_FREQ               (156250000                )  //100MHz = 100000000
)
ec_superisys_485_modbus_rtu_28
(
        .clk_i                  ( clk                     ),
        .rst                    ( reset                   ),
        .i_time_1ms_vld         ( time_1ms_vld            ),
        .i_time_1s_vld          ( time_1s_vld             ),
        .ps_reg_clk             ( ps_reg_clk              ),
        .ps_reg_reset           ( ps_reg_reset            ),
        .i_st_wr_en             ( ps_reg_we               ),//bram总线
        .i_st_wr_addr           ( ps_reg_addr             ),
        .i_st_wr_data           ( ps_reg_wr_dat           ),
        .i_st_rd_en             ( ps_reg_re               ),
        .i_st_rd_addr           ( ps_reg_rd_addr          ),
        .o_st_rd_data           ( sub_comp_rd_dat[98]     ),
        .o_st_rd_vld            ( sub_comp_rd_vld[98]     ),
        .o_intr_irq             ( map_irq[98]             ),//组件中断请求
        
        //--- 主板Uart接口
        .i_uart_rx              ( rs485_1_user_rx[2]      ),
        .o_uart_tx              ( rs485_1_user_tx[2]      ),
        .o_uart_de              ( rs485_1_user_de[2]      ),
        .o_user_req             ( rs485_1_user_req[2]     ),
        .i_user_grant           ( rs485_1_user_grant[2]   ),

         //--- 从板接口 use clk domain 156.25MHz --
        .cur_slv_board_id       ( 0                       ), //
        .slv_board_id           ( 0                       ), 
        .rs485_ch_r_flag        ( 0                       ), //send en
        .m2s_rs485_msg          (                         ), //send data
        .rs485_ch_flag          ( 0                       ), //recv en
        .s2m_rs485_msg          ( 0                       )  //recv data
    );

	
	
	
	// --- flow_comp_32 --A0032_砂轮手爪放置组件---
    ec_1di
    #(
         .REG_SPACE_BIAS     ( 20'd101888)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1di_32
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[195]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[195]    ),
	  .o_intr_irq            ( map_irq[195]       )

       ,.i_sign1_check        ( di_mst_msg[27]           )   // 单位检测信号
    );

	
	
	
	// --- flow_comp_33 --A0033_双托盘信号组件---
    ec_2di
    #(
         .REG_SPACE_BIAS     ( 20'd102400)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_33
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[196]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[196]    ),
	  .o_intr_irq            ( map_irq[196]       )

       ,.i_sign1_check        ( di_mst_msg[28]           )   // 感测开关1
       ,.i_sign2_check        ( di_mst_msg[29]           )   // 感测开关2
    );

	
	
	
	// --- flow_comp_35 --A0036_分拣库_X轴---
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     ( 20'd65024)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_35
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[123]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[123]    ),
	  .o_intr_irq            ( map_irq[123]       )

       ,.i_axis_limf        ( ~di_regoin_msg[0][30]           )   // 正限位到位开关
       ,.pul_motor_r_flag        ( pul_motor1_r_flag           )   // 
       ,.cur_slv_board_id        ( 5'd0           )   // 
       ,.slv_board_id        ( slv_board_id           )   // 
       ,.pul_motor_flag        ( pul_motor1_flag           )   // 
       ,.m2s_pulm_msg        ( pul_motor1_r_msg[0]           )   // 
       ,.s2m_pulm_msg        ( pul_motor1_msg[0]           )   // 
       ,.i_axis_limb        ( ~di_regoin_msg[0][32]           )   // 负限位到位开关
       ,.i_axis_zero        ( ~di_regoin_msg[0][31]           )   // 零位到位开关
       ,.i_servo_done        ( ~di_regoin_msg[0][16]           )   // 伺服定位完成
       ,.i_servo_ready        ( ~di_regoin_msg[0][17]           )   // 伺服就绪
    );

	
	
	
	// --- flow_comp_36 --A0037_分拣库_Y轴---
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     ( 20'd65536)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_36
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[124]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[124]    ),
	  .o_intr_irq            ( map_irq[124]       )

       ,.i_axis_limf        ( ~di_regoin_msg[0][33]           )   // 正限位到位开关
       ,.pul_motor_r_flag        ( pul_motor0_r_flag           )   // 
       ,.cur_slv_board_id        ( 5'd0           )   // 
       ,.slv_board_id        ( slv_board_id           )   // 
       ,.pul_motor_flag        ( pul_motor0_flag           )   // 
       ,.m2s_pulm_msg        ( pul_motor0_r_msg[0]           )   // 
       ,.s2m_pulm_msg        ( pul_motor0_msg[0]           )   // 
       ,.i_axis_limb        ( ~di_regoin_msg[0][35]           )   // 负限位到位开关
       ,.i_axis_zero        ( ~di_regoin_msg[0][34]           )   // 零位到位开关
       ,.i_servo_done        ( ~di_regoin_msg[0][14]           )   // 伺服定位完成
       ,.i_servo_ready        ( ~di_regoin_msg[0][15]           )   // 伺服就绪
    );

	
	
	
	// --- flow_comp_37 --A0038_分拣库_Z轴---
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     ( 20'd66048)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_37
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[125]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[125]    ),
	  .o_intr_irq            ( map_irq[125]       )

       ,.i_axis_limf        ( ~di_regoin_msg[0][36]           )   // 正限位到位开关
       ,.pul_motor_r_flag        ( pul_motor2_r_flag           )   // 
       ,.cur_slv_board_id        ( 5'd0           )   // 
       ,.slv_board_id        ( slv_board_id           )   // 
       ,.pul_motor_flag        ( pul_motor2_flag           )   // 
       ,.m2s_pulm_msg        ( pul_motor2_r_msg[0]           )   // 
       ,.s2m_pulm_msg        ( pul_motor2_msg[0]           )   // 
       ,.i_axis_limb        ( ~di_regoin_msg[0][38]           )   // 负限位到位开关
       ,.i_axis_zero        ( ~di_regoin_msg[0][37]           )   // 零位到位开关
       ,.i_servo_done        ( ~di_regoin_msg[0][18]           )   // 伺服定位完成
       ,.i_servo_ready        ( ~di_regoin_msg[0][19]           )   // 伺服就绪
    );

	
	
	
	// --- flow_comp_38 --A0039_分拣库_R轴---
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     ( 20'd66560)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_38
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[126]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[126]    ),
	  .o_intr_irq            ( map_irq[126]       )

       ,.i_axis_limf        ( ~di_regoin_msg[0][39]           )   // 正限位到位开关
       ,.pul_motor_r_flag        ( pul_motor3_r_flag           )   // 
       ,.cur_slv_board_id        ( 5'd0           )   // 
       ,.slv_board_id        ( slv_board_id           )   // 
       ,.pul_motor_flag        ( pul_motor3_flag           )   // 
       ,.m2s_pulm_msg        ( pul_motor3_r_msg[0]           )   // 
       ,.s2m_pulm_msg        ( pul_motor3_msg[0]           )   // 
       ,.i_axis_limb        ( ~di_regoin_msg[0][41]           )   // 负限位到位开关
       ,.i_axis_zero        ( ~di_regoin_msg[0][40]           )   // 零位到位开关
       ,.i_servo_done        ( ~di_regoin_msg[0][20]           )   // 伺服定位完成
       ,.i_servo_ready        ( ~di_regoin_msg[0][21]           )   // 伺服就绪
    );

	
	
	wire   o_dri2_39;
	wire   o_dri1_39;
	
	// --- flow_comp_39 --A0040_分拣库_桁架夹爪---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd67072)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_39
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[127]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[127]    ),
	  .o_intr_irq            ( map_irq[127]       )

       ,.i_pos1        ( ~di_regoin_msg[0][43]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[0][42]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_39           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_39           )   // 驱动信号2
    );

    assign do_regoin_r_msg[0][27] = ~o_dri2_39;
    assign do_regoin_r_msg[0][26] = ~o_dri1_39;
	
	
	wire   o_dri2_40;
	wire   o_dri1_40;
	
	// --- flow_comp_40 --A0041_机器人托盘入口滑台---
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd69120)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3di_2do_40
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[131]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[131]    ),
	  .o_intr_irq            ( map_irq[131]       )

       ,.i_pos1        ( ~di_regoin_msg[1][12]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[1][13]           )   // 位置2到位开关
       ,.i_poa        ( ~di_regoin_msg[0][7]           )   // 
       ,.o_dri1        ( o_dri1_40           )   // 位置1驱动信号
       ,.o_dri2        ( o_dri2_40           )   // 位置2驱动信号
    );

    assign do_regoin_r_msg[0][21] = ~o_dri2_40;
    assign do_regoin_r_msg[0][20] = ~o_dri1_40;
	
	
	wire   o_dri2_41;
	wire   o_dri1_41;
	
	// --- flow_comp_41 --A0042_机器人托盘出口滑台---
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd69632)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3di_2do_41
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[132]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[132]    ),
	  .o_intr_irq            ( map_irq[132]       )

       ,.i_pos1        ( ~di_regoin_msg[1][14]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[1][15]           )   // 位置2到位开关
       ,.i_poa        ( ~di_regoin_msg[0][8]           )   // 
       ,.o_dri1        ( o_dri1_41           )   // 位置1驱动信号
       ,.o_dri2        ( o_dri2_41           )   // 位置2驱动信号
    );

    assign do_regoin_r_msg[0][23] = ~o_dri2_41;
    assign do_regoin_r_msg[0][22] = ~o_dri1_41;
	
	
	wire   o_dri1_42;
	wire   o_dri2_42;
	
	// --- flow_comp_42 --A0043_[1号-A]正常上料滑台---
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd70144)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3di_2do_42
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[133]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[133]    ),
	  .o_intr_irq            ( map_irq[133]       )

       ,.i_pos1        ( ~di_regoin_msg[1][0]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[1][1]           )   // 位置2到位开关
       ,.i_poa        ( ~di_regoin_msg[0][1]           )   // 
       ,.o_dri1        ( o_dri1_42           )   // 位置1驱动信号
       ,.o_dri2        ( o_dri2_42           )   // 位置2驱动信号
    );

    assign do_regoin_r_msg[0][8] = ~o_dri1_42;
    assign do_regoin_r_msg[0][9] = ~o_dri2_42;
	
	
	wire   o_dri1_43;
	wire   o_dri2_43;
	
	// --- flow_comp_43 --A0044_[1号-B]正常上料滑台---
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd67584)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3di_2do_43
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[128]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[128]    ),
	  .o_intr_irq            ( map_irq[128]       )

       ,.i_pos1        ( ~di_regoin_msg[1][2]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[1][3]           )   // 位置2到位开关
       ,.i_poa        ( ~di_regoin_msg[0][2]           )   // 
       ,.o_dri1        ( o_dri1_43           )   // 位置1驱动信号
       ,.o_dri2        ( o_dri2_43           )   // 位置2驱动信号
    );

    assign do_regoin_r_msg[0][10] = ~o_dri1_43;
    assign do_regoin_r_msg[0][11] = ~o_dri2_43;
	
	
	wire   o_dri1_44;
	wire   o_dri2_44;
	
	// --- flow_comp_44 --A0045_[2号-A]正常下料滑台---
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd70656)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3di_2do_44
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[134]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[134]    ),
	  .o_intr_irq            ( map_irq[134]       )

       ,.i_pos1        ( ~di_regoin_msg[1][4]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[1][5]           )   // 位置2到位开关
       ,.i_poa        ( ~di_regoin_msg[0][3]           )   // 
       ,.o_dri1        ( o_dri1_44           )   // 位置1驱动信号
       ,.o_dri2        ( o_dri2_44           )   // 位置2驱动信号
    );

    assign do_regoin_r_msg[0][12] = ~o_dri1_44;
    assign do_regoin_r_msg[0][13] = ~o_dri2_44;
	
	
	wire   o_dri1_45;
	wire   o_dri2_45;
	
	// --- flow_comp_45 --A0046_[2号-B]正常下料滑台---
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd68096)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3di_2do_45
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[129]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[129]    ),
	  .o_intr_irq            ( map_irq[129]       )

       ,.i_pos1        ( ~di_regoin_msg[1][6]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[1][7]           )   // 位置2到位开关
       ,.i_poa        ( ~di_regoin_msg[0][4]           )   // 
       ,.o_dri1        ( o_dri1_45           )   // 位置1驱动信号
       ,.o_dri2        ( o_dri2_45           )   // 位置2驱动信号
    );

    assign do_regoin_r_msg[0][14] = ~o_dri1_45;
    assign do_regoin_r_msg[0][15] = ~o_dri2_45;
	
	
	wire   o_dri2_46;
	wire   o_dri1_46;
	
	// --- flow_comp_46 --A0047_[3号-A]异常下料滑台---
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd71168)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3di_2do_46
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[135]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[135]    ),
	  .o_intr_irq            ( map_irq[135]       )

       ,.i_pos1        ( ~di_regoin_msg[1][8]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[1][9]           )   // 位置2到位开关
       ,.i_poa        ( ~di_regoin_msg[0][5]           )   // 
       ,.o_dri1        ( o_dri1_46           )   // 位置1驱动信号
       ,.o_dri2        ( o_dri2_46           )   // 位置2驱动信号
    );

    assign do_regoin_r_msg[0][17] = ~o_dri2_46;
    assign do_regoin_r_msg[0][16] = ~o_dri1_46;
	
	
	wire   o_dri2_47;
	wire   o_dri1_47;
	
	// --- flow_comp_47 --A0048_[3号-B]异常下料滑台---
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd68608)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3di_2do_47
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[130]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[130]    ),
	  .o_intr_irq            ( map_irq[130]       )

       ,.i_pos1        ( ~di_regoin_msg[1][10]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[1][11]           )   // 位置2到位开关
       ,.i_poa        ( ~di_regoin_msg[0][6]           )   // 
       ,.o_dri1        ( o_dri1_47           )   // 位置1驱动信号
       ,.o_dri2        ( o_dri2_47           )   // 位置2驱动信号
    );

    assign do_regoin_r_msg[0][19] = ~o_dri2_47;
    assign do_regoin_r_msg[0][18] = ~o_dri1_47;
	
	
	
	// --- flow_comp_48 --A0049_分拣库_打标机卡盘R轴---
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     ( 20'd72704)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_48
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[138]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[138]    ),
	  .o_intr_irq            ( map_irq[138]       )

       ,.i_axis_limf        ( ~di_regoin_msg[0][53]           )   // 正限位到位开关
       ,.pul_motor_r_flag        ( pul_motor0_r_flag           )   // 
       ,.cur_slv_board_id        ( 5'd1           )   // 
       ,.slv_board_id        ( slv_board_id           )   // 
       ,.pul_motor_flag        ( pul_motor0_flag           )   // 
       ,.m2s_pulm_msg        ( pul_motor0_r_msg[1]           )   // 
       ,.s2m_pulm_msg        ( pul_motor0_msg[1]           )   // 
       ,.i_axis_limb        ( ~di_regoin_msg[0][55]           )   // 负限位到位开关
       ,.i_axis_zero        ( ~di_regoin_msg[0][54]           )   // 零位到位开关
       ,.i_servo_done        ( ~di_regoin_msg[0][28]           )   // 伺服定位完成
       ,.i_servo_ready        ( ~di_regoin_msg[0][29]           )   // 伺服就绪
    );

	
	
	
	// --- flow_comp_49 --A0050_分拣库_打标机卡盘Y轴---
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     ( 20'd73216)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_49
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[139]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[139]    ),
	  .o_intr_irq            ( map_irq[139]       )

       ,.i_axis_limf        ( ~di_regoin_msg[0][44]           )   // 正限位到位开关
       ,.pul_motor_r_flag        ( pul_motor1_r_flag           )   // 
       ,.cur_slv_board_id        ( 5'd1           )   // 
       ,.slv_board_id        ( slv_board_id           )   // 
       ,.pul_motor_flag        ( pul_motor1_flag           )   // 
       ,.m2s_pulm_msg        ( pul_motor1_r_msg[1]           )   // 
       ,.s2m_pulm_msg        ( pul_motor1_msg[1]           )   // 
       ,.i_axis_limb        ( ~di_regoin_msg[0][46]           )   // 负限位到位开关
       ,.i_axis_zero        ( ~di_regoin_msg[0][45]           )   // 零位到位开关
       ,.i_servo_done        ( ~di_regoin_msg[0][22]           )   // 伺服定位完成
       ,.i_servo_ready        ( ~di_regoin_msg[0][23]           )   // 伺服就绪
    );

	
	
	
	// --- flow_comp_50 --A0051_分拣库_打标机倾角轴---
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     ( 20'd73728)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_50
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[140]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[140]    ),
	  .o_intr_irq            ( map_irq[140]       )

       ,.i_axis_limf        ( ~di_regoin_msg[0][47]           )   // 正限位到位开关
       ,.pul_motor_r_flag        ( pul_motor2_r_flag           )   // 
       ,.cur_slv_board_id        ( 5'd1           )   // 
       ,.slv_board_id        ( slv_board_id           )   // 
       ,.pul_motor_flag        ( pul_motor2_flag           )   // 
       ,.m2s_pulm_msg        ( pul_motor2_r_msg[1]           )   // 
       ,.s2m_pulm_msg        ( pul_motor2_msg[1]           )   // 
       ,.i_axis_limb        ( ~di_regoin_msg[0][49]           )   // 负限位到位开关
       ,.i_axis_zero        ( ~di_regoin_msg[0][48]           )   // 零位到位开关
       ,.i_servo_done        ( ~di_regoin_msg[0][24]           )   // 伺服定位完成
       ,.i_servo_ready        ( ~di_regoin_msg[0][25]           )   // 
    );

	
	
	
	// --- flow_comp_51 --A0052_分拣库_打标机升降Z轴---
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     ( 20'd74240)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_51
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[141]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[141]    ),
	  .o_intr_irq            ( map_irq[141]       )

       ,.i_axis_limf        ( ~di_regoin_msg[0][50]           )   // 正限位到位开关
       ,.pul_motor_r_flag        ( pul_motor3_r_flag           )   // 
       ,.cur_slv_board_id        ( 5'd1           )   // 
       ,.slv_board_id        ( slv_board_id           )   // 
       ,.pul_motor_flag        ( pul_motor3_flag           )   // 
       ,.m2s_pulm_msg        ( pul_motor3_r_msg[1]           )   // 
       ,.s2m_pulm_msg        ( pul_motor3_msg[1]           )   // 
       ,.i_axis_limb        ( ~di_regoin_msg[0][52]           )   // 负限位到位开关
       ,.i_axis_zero        ( ~di_regoin_msg[0][51]           )   // 零位到位开关
       ,.i_servo_done        ( ~di_regoin_msg[0][26]           )   // 伺服定位完成
       ,.i_servo_ready        ( ~di_regoin_msg[0][27]           )   // 伺服就绪
    );

	
	
	
	// --- flow_comp_52 --A0053_打标机---
    ec_feijie_marker
    #(
         .REG_SPACE_BIAS     ( 20'd76288)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_feijie_marker_52
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[145]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[145]    ),
	  .o_intr_irq            ( map_irq[145]       )

    );

	
	
	wire   o_dri1_53;
	wire   o_dri2_53;
	
	// --- flow_comp_53 --A0054_分拣库_打标机卡盘---
    ec_2di_3do
    #(
         .REG_SPACE_BIAS     ( 20'd72192)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_3do_53
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[137]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[137]    ),
	  .o_intr_irq            ( map_irq[137]       )

       ,.i_pos        ( 1'b0           )   // 位置到位开关
       ,.o_dri1        ( o_dri1_53           )   // 卡盘开驱动信号
       ,.o_dri2        ( o_dri2_53           )   // 卡盘关驱动信号
       ,.o_dri        (            )   // 
       ,.i_poa        ( 1'b0           )   // 
    );

    assign do_regoin_r_msg[0][25] = ~o_dri1_53;
    assign do_regoin_r_msg[0][24] = ~o_dri2_53;
	
	
	
	// --- flow_comp_55 --A0056_砂轮有无检测传感器---
    ec_16di
    #(
         .REG_SPACE_BIAS     ( 20'd75776)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_16di_55
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[144]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[144]    ),
	  .o_intr_irq            ( map_irq[144]       )

       ,.i_sign1_check        ( di_mst_msg[36]           )   // 感测开关1
       ,.i_sign10_check        ( di_mst_msg[9]           )   // 感测开关10
       ,.i_sign11_check        ( di_mst_msg[8]           )   // 感测开关11
       ,.i_sign12_check        ( di_mst_msg[7]           )   // 感测开关12
       ,.i_sign13_check        ( di_mst_msg[6]           )   // 感测开关13
       ,.i_sign14_check        ( di_mst_msg[5]           )   // 感测开关14
       ,.i_sign15_check        ( di_mst_msg[4]           )   // 感测开关15
       ,.i_sign16_check        ( di_mst_msg[3]           )   // 感测开关16
       ,.i_sign2_check        ( di_mst_msg[35]           )   // 感测开关2
       ,.i_sign3_check        ( di_mst_msg[61]           )   // 感测开关3
       ,.i_sign4_check        ( di_mst_msg[60]           )   // 感测开关4
       ,.i_sign5_check        ( di_mst_msg[59]           )   // 感测开关5
       ,.i_sign6_check        ( di_mst_msg[58]           )   // 感测开关6
       ,.i_sign7_check        ( di_mst_msg[57]           )   // 感测开关7
       ,.i_sign8_check        ( di_mst_msg[56]           )   // 感测开关8
       ,.i_sign9_check        ( di_mst_msg[10]           )   // 感测开关9
    );

	
	
	wire   o_led_y_56;
	wire   o_bz_56;
	wire   o_led_r_56;
	wire   o_led_g_56;
	
	// --- flow_comp_56 --A0057_分拣库_三色灯蜂鸣器---
    ec_3led_buzzer
    #(
         .REG_SPACE_BIAS     ( 20'd74752)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3led_buzzer_56
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[142]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[142]    ),
	  .o_intr_irq            ( map_irq[142]       )

       ,.o_led_y        ( o_led_y_56           )   // 黄色端口
       ,.o_led_g        ( o_led_g_56           )   // 绿色端口
       ,.o_bz        ( o_bz_56           )   // 蜂鸣端口
       ,.o_led_r        ( o_led_r_56           )   // 红色端口
    );

    assign do_regoin_r_msg[0][1] = ~o_led_y_56;
    assign do_regoin_r_msg[0][3] = ~o_bz_56;
    assign do_regoin_r_msg[0][0] = ~o_led_r_56;
    assign do_regoin_r_msg[0][2] = ~o_led_g_56;
	
	
	
	// --- flow_comp_57 --A0058_分拣库_电子手轮---
    ec_pulmotor_handwheel
    #(
         .REG_SPACE_BIAS     ( 20'd71680)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_pulmotor_handwheel_57
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[136]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[136]    ),
	  .o_intr_irq            ( map_irq[136]       )

       ,.i_axis_4        ( di_regoin_msg[1][51]           )   // 4轴
       ,.i_axis_5        ( di_regoin_msg[1][52]           )   // 5轴
       ,.i_axis_6        ( di_regoin_msg[1][53]           )   // 6轴
       ,.i_axis_7        ( di_regoin_msg[1][54]           )   // 7轴
       ,.i_stp_x10        ( di_regoin_msg[1][47]           )   // X100
       ,.i_stp_x100        ( di_regoin_msg[1][46]           )   // X10
       ,.i_stp_x1        ( di_regoin_msg[1][45]           )   // X1
       ,.i_axis_x        ( di_regoin_msg[1][48]           )   // X轴
       ,.i_axis_y        ( di_regoin_msg[1][49]           )   // Y轴
       ,.i_axis_z        ( di_regoin_msg[1][50]           )   // Z轴
       ,.i_estop        ( di_regoin_msg[1][42]           )   // ESTOP
       ,.i_pulse_a        ( di_regoin_msg[1][43]           )   // A
       ,.i_pulse_b        ( di_regoin_msg[1][44]           )   // B
    );

	
	
	wire   o_dri1_58;
	wire   o_dri2_58;
	
	// --- flow_comp_58 --A0059_三坐标房清洗机侧自动门---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd58368)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_58
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[110]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[110]    ),
	  .o_intr_irq            ( map_irq[110]       )

       ,.i_pos1        ( di_mst_msg[1]           )   // 位置1到位开关
       ,.i_pos2        ( di_mst_msg[2]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_58           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_58           )   // 驱动信号2
    );

    assign do_mst_msg[8] = ~o_dri1_58;
    assign do_mst_msg[9] = ~o_dri2_58;
	
	
	wire   o_dri1_59;
	wire   o_dri2_59;
	
	// --- flow_comp_59 --A0060_三坐标房地轨侧自动门---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd58880)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_59
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[111]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[111]    ),
	  .o_intr_irq            ( map_irq[111]       )

       ,.i_pos1        ( di_mst_msg[62]           )   // 位置1到位开关
       ,.i_pos2        ( di_mst_msg[63]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_59           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_59           )   // 驱动信号2
    );

    assign do_mst_msg[10] = ~o_dri1_59;
    assign do_mst_msg[11] = ~o_dri2_59;
	
	
	wire   o_dri1_60;
	wire   o_dri2_60;
	
	// --- flow_comp_60 --A0061_三坐标房去毛刺机侧自动门---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd59392)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_60
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[112]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[112]    ),
	  .o_intr_irq            ( map_irq[112]       )

       ,.i_pos1        ( di_mst_msg[52]           )   // 位置1到位开关
       ,.i_pos2        ( di_mst_msg[53]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_60           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_60           )   // 驱动信号2
    );

    assign do_mst_msg[3] = ~o_dri1_60;
    assign do_mst_msg[4] = ~o_dri2_60;
	
	
	
	// --- flow_comp_61 --A0062_主机器人地轨---
    ec_can_servo
    #(
         .REG_SPACE_BIAS     ( 20'd64512)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_can_servo_61
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[122]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[122]    ),
	  .o_intr_irq            ( map_irq[122]       )

       ,.i_axis_limf        ( ~di_mst_msg[14]           )   // 正限位开关
       ,.i_axis_limb        ( ~di_mst_msg[16]           )   // 负限位开关
       ,.i_axis_zero        ( ~di_mst_msg[15]           )   // 零位开关
    );

	
	
	
	// --- flow_comp_62 --A0063_短桁架1---
    ec_can_servo
    #(
         .REG_SPACE_BIAS     ( 20'd60416)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_can_servo_62
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[114]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[114]    ),
	  .o_intr_irq            ( map_irq[114]       )

       ,.i_axis_limf        ( ~di_mst_msg[32]           )   // 正限位开关
       ,.i_axis_limb        ( ~di_mst_msg[34]           )   // 负限位开关
       ,.i_axis_zero        ( ~di_mst_msg[33]           )   // 零位开关
    );

	
	
	
	// --- flow_comp_63 --A0064_长桁架1---
    ec_can_servo
    #(
         .REG_SPACE_BIAS     ( 20'd60928)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_can_servo_63
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[115]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[115]    ),
	  .o_intr_irq            ( map_irq[115]       )

       ,.i_axis_zero        ( 1'b0           )   // 
       ,.i_axis_limb        ( 1'b0           )   // 
       ,.i_axis_limf        ( 1'b0           )   // 
    );

	
	
	
	// --- flow_comp_64 --A0065_长桁架2---
    ec_can_servo
    #(
         .REG_SPACE_BIAS     ( 20'd61440)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_can_servo_64
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[116]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[116]    ),
	  .o_intr_irq            ( map_irq[116]       )

       ,.i_axis_zero        ( 1'b0           )   // 
       ,.i_axis_limb        ( 1'b0           )   // 
       ,.i_axis_limf        ( 1'b0           )   // 
    );

	
	
	
	// --- flow_comp_66 --A0067_打磨机器人---
    ec_fanuc_robot
    #(
         .REG_SPACE_BIAS     ( 20'd75264)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_fanuc_robot_66
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[143]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[143]    ),
	  .o_intr_irq            ( map_irq[143]       )

    );

	
	
	wire   o_led_y_67;
	wire   o_bz_67;
	wire   o_led_g_67;
	wire   o_led_r_67;
	
	// --- flow_comp_67 --A0068_去毛刺机_三色灯蜂鸣器---
    ec_3led_buzzer
    #(
         .REG_SPACE_BIAS     ( 20'd80896)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3led_buzzer_67
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[154]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[154]    ),
	  .o_intr_irq            ( map_irq[154]       )

       ,.o_led_y        ( o_led_y_67           )   // 黄色端口
       ,.o_led_g        ( o_led_g_67           )   // 绿色端口
       ,.o_bz        ( o_bz_67           )   // 蜂鸣端口
       ,.o_led_r        ( o_led_r_67           )   // 红色端口
    );

    assign do_regoin_r_msg[2][1] = ~o_led_y_67;
    assign do_regoin_r_msg[2][3] = ~o_bz_67;
    assign do_regoin_r_msg[2][2] = ~o_led_g_67;
    assign do_regoin_r_msg[2][0] = ~o_led_r_67;
	
	
	wire   o_dri1_68;
	wire   o_dri2_68;
	
	// --- flow_comp_68 --A0069_去毛刺卡盘---
    ec_2di_3do
    #(
         .REG_SPACE_BIAS     ( 20'd77312)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_3do_68
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[147]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[147]    ),
	  .o_intr_irq            ( map_irq[147]       )

       ,.i_pos        ( ~di_regoin_msg[2][51]           )   // 位置到位开关
       ,.o_dri1        ( o_dri1_68           )   // 卡盘开驱动信号
       ,.o_dri2        ( o_dri2_68           )   // 卡盘关驱动信号
       ,.o_dri        (            )   // 
       ,.i_poa        ( 1'b0           )   // 
    );

    assign do_regoin_r_msg[2][9] = ~o_dri1_68;
    assign do_regoin_r_msg[2][8] = ~o_dri2_68;
	
	
	wire   o_dri1_69;
	wire   o_dri2_69;
	
	// --- flow_comp_69 --A0070_去毛刺机_磨头夹爪---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd76800)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_69
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[146]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[146]    ),
	  .o_intr_irq            ( map_irq[146]       )

       ,.i_pos1        ( ~di_regoin_msg[2][22]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[2][21]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_69           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_69           )   // 驱动信号2
    );

    assign do_regoin_r_msg[2][13] = ~o_dri1_69;
    assign do_regoin_r_msg[2][12] = ~o_dri2_69;
	
	
	wire   o_dri1_70;
	wire   o_dri2_70;
	
	// --- flow_comp_70 --A0071_去毛刺机_自动门---
    ec_4di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd78848)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_4di_2do_70
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[150]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[150]    ),
	  .o_intr_irq            ( map_irq[150]       )

       ,.i_pos1_1        ( ~di_regoin_msg[2][9]           )   // 左侧门开到位开关
       ,.i_pos1_2        ( ~di_regoin_msg[2][11]           )   // 右侧门开到位开关
       ,.i_pos2_2        ( ~di_regoin_msg[2][12]           )   // 右侧门关到位开关
       ,.i_pos2_1        ( ~di_regoin_msg[2][10]           )   // 左侧门关到位开关
       ,.o_dri1        ( o_dri1_70           )   // 门开驱动信号
       ,.o_dri2        ( o_dri2_70           )   // 门关驱动信号
    );

    assign do_regoin_r_msg[2][11] = ~o_dri1_70;
    assign do_regoin_r_msg[2][10] = ~o_dri2_70;
	
	
	
	// --- flow_comp_138 --A0072_毛刺刀架库信号检测组---
    ec_16di
    #(
         .REG_SPACE_BIAS     ( 20'd80384)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_16di_138
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[153]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[153]    ),
	  .o_intr_irq            ( map_irq[153]       )

       ,.i_sign1_check        ( di_regoin_msg[2][65]           )   // 感测开关1
       ,.i_sign10_check        ( di_regoin_msg[2][74]           )   // 感测开关10
       ,.i_sign11_check        ( di_regoin_msg[2][75]           )   // 感测开关11
       ,.i_sign12_check        ( di_regoin_msg[2][76]           )   // 感测开关12
       ,.i_sign13_check        ( di_regoin_msg[2][77]           )   // 感测开关13
       ,.i_sign14_check        ( di_regoin_msg[2][78]           )   // 感测开关14
       ,.i_sign15_check        ( di_regoin_msg[2][79]           )   // 感测开关15
       ,.i_sign2_check        ( di_regoin_msg[2][66]           )   // 感测开关2
       ,.i_sign3_check        ( di_regoin_msg[2][67]           )   // 感测开关3
       ,.i_sign4_check        ( di_regoin_msg[2][68]           )   // 感测开关4
       ,.i_sign5_check        ( di_regoin_msg[2][69]           )   // 感测开关5
       ,.i_sign6_check        ( di_regoin_msg[2][70]           )   // 感测开关6
       ,.i_sign7_check        ( di_regoin_msg[2][71]           )   // 感测开关7
       ,.i_sign8_check        ( di_regoin_msg[2][72]           )   // 感测开关8
       ,.i_sign9_check        ( di_regoin_msg[2][73]           )   // 感测开关9
       ,.i_sign16_check        ( 1'b0           )   // 
    );
	
	
	// --- flow_comp_72 --A0081_去毛刺机_旋转台伺服电机---
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     ( 20'd77824)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_72
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[148]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[148]    ),
	  .o_intr_irq            ( map_irq[148]       )

       ,.pul_motor_r_flag        ( pul_motor2_r_flag           )   // 
       ,.cur_slv_board_id        ( 5'd2           )   // 
       ,.slv_board_id        ( slv_board_id           )   // 
       ,.pul_motor_flag        ( pul_motor2_flag           )   // 
       ,.m2s_pulm_msg        ( pul_motor2_r_msg[2]           )   // 
       ,.s2m_pulm_msg        ( pul_motor2_msg[2]           )   // 
       ,.i_axis_zero        ( ~di_regoin_msg[2][42]           )   // 零位到位开关
       ,.i_servo_done        ( di_regoin_msg[2][44]           )   // 伺服定位完成
       ,.i_servo_ready        ( di_regoin_msg[2][43]           )   // 伺服就绪
       ,.i_axis_limf        ( 1'b0           )   // 
       ,.i_axis_limb        ( 1'b0           )   // 
    );

	
	
	wire   o_sig_dri_73;
	
	// --- flow_comp_73 --A0074_去毛刺机_防爆除尘器---
    ec_1do
    #(
         .REG_SPACE_BIAS     ( 20'd79360)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1do_73
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[151]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[151]    ),
	  .o_intr_irq            ( map_irq[151]       )

       ,.o_sig_dri        ( o_sig_dri_73           )   // 单驱动信号
    );

    assign do_regoin_r_msg[2][29] = ~o_sig_dri_73;
	
	
	wire   o_sig_dri_74;
	
	// --- flow_comp_74 --A0075_去毛刺机_水冷机---
    ec_1do
    #(
         .REG_SPACE_BIAS     ( 20'd79872)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1do_74
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[152]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[152]    ),
	  .o_intr_irq            ( map_irq[152]       )

       ,.o_sig_dri        ( o_sig_dri_74           )   // 单驱动信号
    );

    assign do_regoin_r_msg[2][31] = ~o_sig_dri_74;
	
	
	
	// // --- flow_comp_75 --A0080_去毛刺机_变频磨头旋转电机---
    // ec_slv_dv300_485
    // #(
    //      .REG_SPACE_BIAS     ( 20'd78336)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_slv_dv300_485_75
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
	//   .o_st_rd_vld           ( sub_comp_rd_vld[149]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[149]    ),
	//   .o_intr_irq            ( map_irq[149]       )

    //    ,.cur_slv_board_id        ( 5'd2           )   // 伺服驱动
    //    ,.slv_board_id        ( slv_board_id           )   // 
    //    ,.rs485_ch_r_flag        ( rs485_00_r_flag           )   // 
    //    ,.rs485_ch_flag        ( rs485_00_flag           )   // 
    //    ,.m2s_rs485_msg        ( rs485_00_send_msg[2]           )   // 
    //    ,.s2m_rs485_msg        ( rs485_00_msg[2]           )   // 
    // );
ec_dv300_485_modbus_rtu
#(
        .REG_SPACE_BIAS         (20'h13200                ), //组件基地址
        .REG_SPACE_SIZE         (`REG_SPACE_SIZE          ), //组件偏移地址
        .CLK_FREQ               (156250000                )  //100MHz = 100000000
)
ec_dv300_485_modbus_rtu_75
(
        .clk_i                  ( clk                     ),
        .rst                    ( reset                   ),
        .i_time_1ms_vld         ( time_1ms_vld            ),
        .i_time_1s_vld          ( time_1s_vld             ),
        .ps_reg_clk             ( ps_reg_clk              ),
        .ps_reg_reset           ( ps_reg_reset            ),
        .i_st_wr_en             ( ps_reg_we               ),//bram总线
        .i_st_wr_addr           ( ps_reg_addr             ),
        .i_st_wr_data           ( ps_reg_wr_dat           ),
        .i_st_rd_en             ( ps_reg_re               ),
        .i_st_rd_addr           ( ps_reg_rd_addr          ),
        .o_st_rd_data           ( sub_comp_rd_dat[149]    ),
        .o_st_rd_vld            ( sub_comp_rd_vld[149]    ),
        .o_intr_irq             ( map_irq[149]            ),//组件中断请求
        
        //--- 主板Uart接口
        .i_uart_rx              ( rs485_1_user_rx[6]      ),
        .o_uart_tx              ( rs485_1_user_tx[6]      ),
        .o_uart_de              ( rs485_1_user_de[6]      ),
        .o_user_req             ( rs485_1_user_req[6]     ),
        .i_user_grant           ( rs485_1_user_grant[6]   )
    );

	
	
	wire   o_dri1_76;
	wire   o_dri2_76;
	
	// --- flow_comp_76 --A0077_短桁架1#机器人夹爪---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd61952)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_76
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[117]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[117]    ),
	  .o_intr_irq            ( map_irq[117]       )

       ,.i_pos1        ( ~di_mst_msg[12]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_mst_msg[11]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_76           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_76           )   // 驱动信号2
    );

    assign do_mst_msg[6] = ~o_dri1_76;
    assign do_mst_msg[7] = ~o_dri2_76;
	
	
	wire   o_dri2_77;
	wire   o_dri1_77;
	
	// --- flow_comp_77 --A0078_长桁架1#机器人夹爪---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd62976)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_77
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[119]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[119]    ),
	  .o_intr_irq            ( map_irq[119]       )

       ,.i_pos1        ( ~di_regoin_msg[3][32]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[3][33]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_77           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_77           )   // 驱动信号2
    );

    assign do_regoin_r_msg[3][25] = ~o_dri2_77;
    assign do_regoin_r_msg[3][24] = ~o_dri1_77;
	
	
	wire   o_dri1_78;
	wire   o_dri2_78;
	
	// --- flow_comp_78 --A0079_长桁架2#机器人夹爪---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd62464)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_78
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[118]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[118]    ),
	  .o_intr_irq            ( map_irq[118]       )

       ,.i_pos1        ( ~di_regoin_msg[3][35]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[3][36]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_78           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_78           )   // 驱动信号2
    );

    assign do_regoin_r_msg[3][26] = ~o_dri1_78;
    assign do_regoin_r_msg[3][27] = ~o_dri2_78;
	
	
	
	// --- flow_comp_79 --A0082_固定机器人夹爪物料检测信号---
    ec_1di
    #(
         .REG_SPACE_BIAS     ( 20'd59904)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1di_79
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[113]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[113]    ),
	  .o_intr_irq            ( map_irq[113]       )

       ,.i_sign1_check        ( di_mst_msg[30]           )   // 单位检测信号
    );

	
	
	wire   o_dri1_80;
	wire   o_dri2_80;
	
	// --- flow_comp_80 --A0083_6号机床旋转机构---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd99840)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_80
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[191]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[191]    ),
	  .o_intr_irq            ( map_irq[191]       )

       ,.i_pos1        ( ~di_regoin_msg[4][64]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[4][65]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_80           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_80           )   // 驱动信号2
    );

    assign do_regoin_r_msg[4][32] = ~o_dri1_80;
    assign do_regoin_r_msg[4][33] = ~o_dri2_80;
	
	
	
	// --- flow_comp_81 --A0084_OCR 字符识别---
    ec_ocr_camera
    #(
         .REG_SPACE_BIAS     ( 20'd105472)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ocr_camera_81
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[202]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[202]    ),
	  .o_intr_irq            ( map_irq[202]       )

    );

	
	
	
	// // --- flow_comp_83 --A0086_长桁架1#夹爪RFID读写器---
    // ec_sp_rfid
    // #(
    //      .REG_SPACE_BIAS     ( 20'd63488)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_sp_rfid_83
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
	//   .o_st_rd_vld           ( sub_comp_rd_vld[120]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[120]    ),
	//   .o_intr_irq            ( map_irq[120]       )

    //    ,.cur_slv_board_id        ( 5'd3           )   // RS485端口
    //    ,.slv_board_id        ( slv_board_id           )   // 
    //    ,.rs485_ch_r_flag        ( rs485_00_r_flag           )   // 
    //    ,.rs485_ch_flag        ( rs485_00_flag           )   // 
    //    ,.m2s_rs485_msg        ( rs485_00_send_msg[3]           )   // 
    //    ,.s2m_rs485_msg        ( rs485_00_msg[3]           )   // 
    // );

	
	
ec_superisys_485_modbus_rtu
#(
        .REG_SPACE_BIAS         (20'hf800                ), //组件基地址
        .REG_SPACE_SIZE         (`REG_SPACE_SIZE          ), //组件偏移地址
        .CLK_FREQ               (156250000                )  //100MHz = 100000000
)
ec_superisys_485_modbus_rtu_83
(
        .clk_i                  ( clk                     ),
        .rst                    ( reset                   ),
        .i_time_1ms_vld         ( time_1ms_vld            ),
        .i_time_1s_vld          ( time_1s_vld             ),
        .ps_reg_clk             ( ps_reg_clk              ),
        .ps_reg_reset           ( ps_reg_reset            ),
        .i_st_wr_en             ( ps_reg_we               ),//bram总线
        .i_st_wr_addr           ( ps_reg_addr             ),
        .i_st_wr_data           ( ps_reg_wr_dat           ),
        .i_st_rd_en             ( ps_reg_re               ),
        .i_st_rd_addr           ( ps_reg_rd_addr          ),
        .o_st_rd_data           ( sub_comp_rd_dat[120]    ),
        .o_st_rd_vld            ( sub_comp_rd_vld[120]    ),
        .o_intr_irq             ( map_irq[120]            ),//组件中断请求
        
        //--- 主板Uart接口
        .i_uart_rx              ( rs485_1_user_rx[3]      ),
        .o_uart_tx              ( rs485_1_user_tx[3]      ),
        .o_uart_de              ( rs485_1_user_de[3]      ),
        .o_user_req             ( rs485_1_user_req[3]     ),
        .i_user_grant           ( rs485_1_user_grant[3]   ),

         //--- 从板接口 use clk domain 156.25MHz --
        .cur_slv_board_id       ( 0                       ), //
        .slv_board_id           ( 0                       ), 
        .rs485_ch_r_flag        ( 0                       ), //send en
        .m2s_rs485_msg          (                         ), //send data
        .rs485_ch_flag          ( 0                       ), //recv en
        .s2m_rs485_msg          ( 0                       )  //recv data
    );

	// // --- flow_comp_84 --A0087_长桁架2#夹爪RFID读写器---
    // ec_sp_rfid
    // #(
    //      .REG_SPACE_BIAS     ( 20'd64000)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_sp_rfid_84
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
	//   .o_st_rd_vld           ( sub_comp_rd_vld[121]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[121]    ),
	//   .o_intr_irq            ( map_irq[121]       )

    //    ,.cur_slv_board_id        ( 5'd3           )   // RS485端口
    //    ,.slv_board_id        ( slv_board_id           )   // 
    //    ,.rs485_ch_r_flag        ( rs485_00_r_flag           )   // 
    //    ,.rs485_ch_flag        ( rs485_00_flag           )   // 
    //    ,.m2s_rs485_msg        ( rs485_00_send_msg[3]           )   // 
    //    ,.s2m_rs485_msg        ( rs485_00_msg[3]           )   // 
    // );

	ec_superisys_485_modbus_rtu
#(
        .REG_SPACE_BIAS         (20'hfa00                ), //组件基地址
        .REG_SPACE_SIZE         (`REG_SPACE_SIZE          ), //组件偏移地址
        .CLK_FREQ               (156250000                )  //100MHz = 100000000
)
ec_superisys_485_modbus_rtu_84
(
        .clk_i                  ( clk                     ),
        .rst                    ( reset                   ),
        .i_time_1ms_vld         ( time_1ms_vld            ),
        .i_time_1s_vld          ( time_1s_vld             ),
        .ps_reg_clk             ( ps_reg_clk              ),
        .ps_reg_reset           ( ps_reg_reset            ),
        .i_st_wr_en             ( ps_reg_we               ),//bram总线
        .i_st_wr_addr           ( ps_reg_addr             ),
        .i_st_wr_data           ( ps_reg_wr_dat           ),
        .i_st_rd_en             ( ps_reg_re               ),
        .i_st_rd_addr           ( ps_reg_rd_addr          ),
        .o_st_rd_data           ( sub_comp_rd_dat[121]    ),
        .o_st_rd_vld            ( sub_comp_rd_vld[121]    ),
        .o_intr_irq             ( map_irq[121]            ),//组件中断请求
        
        //--- 主板Uart接口
        .i_uart_rx              ( rs485_1_user_rx[4]      ),
        .o_uart_tx              ( rs485_1_user_tx[4]      ),
        .o_uart_de              ( rs485_1_user_de[4]      ),
        .o_user_req             ( rs485_1_user_req[4]     ),
        .i_user_grant           ( rs485_1_user_grant[4]   ),

         //--- 从板接口 use clk domain 156.25MHz --
        .cur_slv_board_id       ( 0                       ), //
        .slv_board_id           ( 0                       ), 
        .rs485_ch_r_flag        ( 0                       ), //send en
        .m2s_rs485_msg          (                         ), //send data
        .rs485_ch_flag          ( 0                       ), //recv en
        .s2m_rs485_msg          ( 0                       )  //recv data
    );
	
	
	// --- flow_comp_85 --A0088_1号机床线边托盘检测组---
    ec_5di
    #(
         .REG_SPACE_BIAS     ( 20'd81920)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_5di_85
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[156]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[156]    ),
	  .o_intr_irq            ( map_irq[156]       )

       ,.i_sign1_check        ( di_regoin_msg[2][45]           )   // 感测开关1
       ,.i_sign2_check        ( di_regoin_msg[2][46]           )   // 感测开关2
       ,.i_sign3_check        ( di_regoin_msg[1][17]           )   // 感测开关3
       ,.i_sign4_check        ( di_regoin_msg[1][16]           )   // 感测开关4
       ,.i_sign5_check        ( di_regoin_msg[1][18]           )   // 感测开关5
    );

	
	
	
	// --- flow_comp_86 --A0089_2号机床线边托盘检测组---
    ec_5di
    #(
         .REG_SPACE_BIAS     ( 20'd82432)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_5di_86
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[157]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[157]    ),
	  .o_intr_irq            ( map_irq[157]       )

       ,.i_sign1_check        ( di_regoin_msg[2][47]           )   // 感测开关1
       ,.i_sign2_check        ( di_regoin_msg[2][48]           )   // 感测开关2
       ,.i_sign3_check        ( di_regoin_msg[1][20]           )   // 感测开关3
       ,.i_sign4_check        ( di_regoin_msg[1][19]           )   // 感测开关4
       ,.i_sign5_check        ( di_regoin_msg[1][21]           )   // 感测开关5
    );

	
	
	
	// --- flow_comp_87 --A0090_3号机床线边托盘检测组---
    ec_5di
    #(
         .REG_SPACE_BIAS     ( 20'd82944)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_5di_87
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[158]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[158]    ),
	  .o_intr_irq            ( map_irq[158]       )

       ,.i_sign1_check        ( di_regoin_msg[2][49]           )   // 感测开关1
       ,.i_sign2_check        ( di_regoin_msg[2][50]           )   // 感测开关2
       ,.i_sign3_check        ( di_regoin_msg[1][22]           )   // 感测开关3
       ,.i_sign4_check        ( di_regoin_msg[1][23]           )   // 感测开关4
       ,.i_sign5_check        ( di_regoin_msg[1][24]           )   // 感测开关5
    );

	
	
	
	// --- flow_comp_88 --A0091_4号机床线边托盘检测组---
    ec_5di
    #(
         .REG_SPACE_BIAS     ( 20'd86016)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_5di_88
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[164]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[164]    ),
	  .o_intr_irq            ( map_irq[164]       )

       ,.i_sign1_check        ( di_regoin_msg[3][23]           )   // 感测开关1
       ,.i_sign2_check        ( di_regoin_msg[3][24]           )   // 感测开关2
       ,.i_sign3_check        ( di_regoin_msg[4][28]           )   // 感测开关3
       ,.i_sign4_check        ( di_regoin_msg[4][30]           )   // 感测开关4
       ,.i_sign5_check        ( di_regoin_msg[4][29]           )   // 感测开关5
    );

	
	
	
	// --- flow_comp_89 --A0092_5号机床线边托盘检测组---
    ec_5di
    #(
         .REG_SPACE_BIAS     ( 20'd87040)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_5di_89
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[166]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[166]    ),
	  .o_intr_irq            ( map_irq[166]       )

       ,.i_sign1_check        ( di_regoin_msg[3][25]           )   // 感测开关1
       ,.i_sign2_check        ( di_regoin_msg[3][26]           )   // 感测开关2
       ,.i_sign3_check        ( di_regoin_msg[4][31]           )   // 感测开关3
       ,.i_sign4_check        ( di_regoin_msg[4][32]           )   // 感测开关4
       ,.i_sign5_check        ( di_regoin_msg[4][33]           )   // 感测开关5
    );

	
	
	
	// --- flow_comp_90 --A0093_6号机床线边托盘检测组---
    ec_5di
    #(
         .REG_SPACE_BIAS     ( 20'd85504)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_5di_90
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[163]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[163]    ),
	  .o_intr_irq            ( map_irq[163]       )

       ,.i_sign1_check        ( di_regoin_msg[3][27]           )   // 感测开关1
       ,.i_sign2_check        ( di_regoin_msg[3][28]           )   // 感测开关2
       ,.i_sign3_check        ( di_regoin_msg[4][43]           )   // 感测开关3
       ,.i_sign4_check        ( di_regoin_msg[4][45]           )   // 感测开关4
       ,.i_sign5_check        ( di_regoin_msg[4][44]           )   // 感测开关5
    );

	
	
	
	// --- flow_comp_91 --A0094_7号机床线边托盘检测组---
    ec_5di
    #(
         .REG_SPACE_BIAS     ( 20'd83968)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_5di_91
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[160]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[160]    ),
	  .o_intr_irq            ( map_irq[160]       )

       ,.i_sign1_check        ( di_regoin_msg[3][29]           )   // 感测开关1
       ,.i_sign2_check        ( di_regoin_msg[3][30]           )   // 感测开关2
       ,.i_sign3_check        ( di_regoin_msg[4][34]           )   // 感测开关3
       ,.i_sign4_check        ( di_regoin_msg[4][35]           )   // 感测开关4
       ,.i_sign5_check        ( di_regoin_msg[4][36]           )   // 感测开关5
    );

	
	
	
	// --- flow_comp_92 --A0095_8号机床线边托盘检测组---
    ec_5di
    #(
         .REG_SPACE_BIAS     ( 20'd86528)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_5di_92
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[165]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[165]    ),
	  .o_intr_irq            ( map_irq[165]       )

       ,.i_sign1_check        ( di_regoin_msg[3][31]           )   // 感测开关1
       ,.i_sign2_check        ( di_regoin_msg[3][44]           )   // 感测开关2
       ,.i_sign3_check        ( di_regoin_msg[4][37]           )   // 感测开关3
       ,.i_sign4_check        ( di_regoin_msg[4][38]           )   // 感测开关4
       ,.i_sign5_check        ( di_regoin_msg[4][39]           )   // 感测开关5
    );

	
	
	
	// --- flow_comp_93 --A0096_9号机床线边托盘检测组---
    ec_5di
    #(
         .REG_SPACE_BIAS     ( 20'd84992)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_5di_93
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[162]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[162]    ),
	  .o_intr_irq            ( map_irq[162]       )

       ,.i_sign1_check        ( di_regoin_msg[3][46]           )   // 感测开关1
       ,.i_sign2_check        ( di_regoin_msg[3][45]           )   // 感测开关2
       ,.i_sign3_check        ( di_regoin_msg[4][40]           )   // 感测开关3
       ,.i_sign4_check        ( di_regoin_msg[4][41]           )   // 感测开关4
       ,.i_sign5_check        ( di_regoin_msg[4][42]           )   // 感测开关5
    );

	
	
	wire   o_dri1_94;
	wire   o_dri2_94;
	
	// --- flow_comp_94 --A0097_机床1顶部围栏自动门---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd91648)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_94
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[175]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[175]    ),
	  .o_intr_irq            ( map_irq[175]       )

       ,.i_pos1        ( ~di_regoin_msg[1][56]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[1][55]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_94           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_94           )   // 驱动信号2
    );

    assign do_regoin_r_msg[1][0] = ~o_dri1_94;
    assign do_regoin_r_msg[1][1] = ~o_dri2_94;
	
	
	wire   o_dri2_95;
	wire   o_dri1_95;
	
	// --- flow_comp_95 --A0098_机床2顶部围栏自动门---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd91136)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_95
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[174]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[174]    ),
	  .o_intr_irq            ( map_irq[174]       )

       ,.i_pos1        ( ~di_regoin_msg[1][58]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[1][57]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_95           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_95           )   // 驱动信号2
    );

    assign do_regoin_r_msg[1][3] = ~o_dri2_95;
    assign do_regoin_r_msg[1][2] = ~o_dri1_95;
	
	
	wire   o_dri1_96;
	wire   o_dri2_96;
	
	// --- flow_comp_96 --A0099_机床3顶部围栏自动门---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd90624)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_96
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[173]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[173]    ),
	  .o_intr_irq            ( map_irq[173]       )

       ,.i_pos1        ( ~di_regoin_msg[1][60]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[1][59]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_96           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_96           )   // 驱动信号2
    );

    assign do_regoin_r_msg[1][4] = ~o_dri1_96;
    assign do_regoin_r_msg[1][5] = ~o_dri2_96;
	
	
	wire   o_dri1_97;
	wire   o_dri2_97;
	
	// --- flow_comp_97 --A0100_机床4顶部围栏自动门---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd89088)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_97
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[170]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[170]    ),
	  .o_intr_irq            ( map_irq[170]       )

       ,.i_pos1        ( ~di_regoin_msg[4][48]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[4][47]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_97           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_97           )   // 驱动信号2
    );

    assign do_regoin_r_msg[4][7] = ~o_dri1_97;
    assign do_regoin_r_msg[4][8] = ~o_dri2_97;
	
	
	wire   o_dri1_98;
	wire   o_dri2_98;
	
	// --- flow_comp_98 --A0101_机床5顶部围栏自动门---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd89600)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_98
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[171]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[171]    ),
	  .o_intr_irq            ( map_irq[171]       )

       ,.i_pos1        ( ~di_regoin_msg[4][50]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[4][49]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_98           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_98           )   // 驱动信号2
    );

    assign do_regoin_r_msg[4][9] = ~o_dri1_98;
    assign do_regoin_r_msg[4][10] = ~o_dri2_98;
	
	
	wire   o_dri1_99;
	wire   o_dri2_99;
	
	// --- flow_comp_99 --A0102_机床6顶部围栏自动门---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd90112)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_99
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[172]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[172]    ),
	  .o_intr_irq            ( map_irq[172]       )

       ,.i_pos1        ( ~di_regoin_msg[4][52]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[4][51]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_99           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_99           )   // 驱动信号2
    );

    assign do_regoin_r_msg[4][11] = ~o_dri1_99;
    assign do_regoin_r_msg[4][12] = ~o_dri2_99;
	
	
	wire   o_dri2_100;
	wire   o_dri1_100;
	
	// --- flow_comp_100 --A0103_机床7顶部围栏自动门---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd88064)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_100
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[168]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[168]    ),
	  .o_intr_irq            ( map_irq[168]       )

       ,.i_pos1        ( ~di_regoin_msg[4][54]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[4][53]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_100           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_100           )   // 驱动信号2
    );

    assign do_regoin_r_msg[4][14] = ~o_dri2_100;
    assign do_regoin_r_msg[4][13] = ~o_dri1_100;
	
	
	wire   o_dri2_101;
	wire   o_dri1_101;
	
	// --- flow_comp_101 --A0104_机床8顶部围栏自动门---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd88576)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_101
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[169]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[169]    ),
	  .o_intr_irq            ( map_irq[169]       )

       ,.i_pos1        ( ~di_regoin_msg[3][20]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[4][55]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_101           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_101           )   // 驱动信号2
    );

    assign do_regoin_r_msg[4][16] = ~o_dri2_101;
    assign do_regoin_r_msg[4][15] = ~o_dri1_101;
	
	
	wire   o_dri1_102;
	wire   o_dri2_102;
	
	// --- flow_comp_102 --A0105_机床9顶部围栏自动门---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd87552)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_102
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[167]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[167]    ),
	  .o_intr_irq            ( map_irq[167]       )

       ,.i_pos1        ( ~di_regoin_msg[3][22]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[3][21]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_102           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_102           )   // 驱动信号2
    );

    assign do_regoin_r_msg[4][17] = ~o_dri1_102;
    assign do_regoin_r_msg[4][18] = ~o_dri2_102;
	
	
	
	// --- flow_comp_103 --A0106_检测站缓存单位感测信号---
    ec_1di
    #(
         .REG_SPACE_BIAS     ( 20'd81408)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1di_103
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[155]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[155]    ),
	  .o_intr_irq            ( map_irq[155]       )

       ,.i_sign1_check        ( di_mst_msg[49]           )   // 单位检测信号
    );

	
	
	wire   o_lock_open_105;
	
	// --- flow_comp_105 --A0108_A区1#安全门锁---
    ec_sf_door
    #(
         .REG_SPACE_BIAS     ( 20'd94208)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_sf_door_105
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[180]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[180]    ),
	  .o_intr_irq            ( map_irq[180]       )

       ,.i_lock_monitor        ( ~di_regoin_msg[1][26]           )   // 锁监控常闭DO端口
       ,.i_open_req_key        ( ~di_regoin_msg[1][27]           )   // 开门请求绿色按钮
       ,.o_lock_open        ( o_lock_open_105           )   // 电磁锁A1
       ,.i_close_confirm_key        ( 1'b0           )   // 
       ,.i_door_monitor        ( 1'b0           )   // 
       ,.o_key_light        (            )   // 
    );

    assign do_regoin_r_msg[1][28] = ~o_lock_open_105;
	
	
	wire   o_lock_open_106;
	
	// --- flow_comp_106 --A0109_A区2#安全门锁---
    ec_sf_door
    #(
         .REG_SPACE_BIAS     ( 20'd94720)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_sf_door_106
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[181]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[181]    ),
	  .o_intr_irq            ( map_irq[181]       )

       ,.i_lock_monitor        ( di_regoin_msg[1][29]           )   // 锁监控常闭DO端口
       ,.i_open_req_key        ( ~di_regoin_msg[1][30]           )   // 开门请求绿色按钮
       ,.o_lock_open        ( o_lock_open_106           )   // 电磁锁A1
       ,.i_close_confirm_key        ( 1'b0           )   // 
       ,.i_door_monitor        ( 1'b0           )   // 
       ,.o_key_light        (            )   // 
    );

    assign do_regoin_r_msg[1][29] = ~o_lock_open_106;
	
	
	wire   o_lock_open_107;
	
	// --- flow_comp_107 --A0110_A区3#安全门锁---
    ec_sf_door
    #(
         .REG_SPACE_BIAS     ( 20'd93696)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_sf_door_107
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[179]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[179]    ),
	  .o_intr_irq            ( map_irq[179]       )

       ,.i_lock_monitor        ( ~di_regoin_msg[1][32]           )   // 锁监控常闭DO端口
       ,.i_open_req_key        ( ~di_regoin_msg[1][33]           )   // 开门请求绿色按钮
       ,.o_lock_open        ( o_lock_open_107           )   // 电磁锁A1
       ,.i_close_confirm_key        ( 1'b0           )   // 
       ,.i_door_monitor        ( 1'b0           )   // 
       ,.o_key_light        (            )   // 
    );

    assign do_regoin_r_msg[1][30] = ~o_lock_open_107;
	
	
	wire   o_lock_open_108;
	
	// --- flow_comp_108 --A0111_B区1#安全门锁---
    ec_sf_door
    #(
         .REG_SPACE_BIAS     ( 20'd98816)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_sf_door_108
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[189]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[189]    ),
	  .o_intr_irq            ( map_irq[189]       )

       ,.i_lock_monitor        ( ~di_regoin_msg[3][4]           )   // 锁监控常闭DO端口
       ,.i_open_req_key        ( ~di_regoin_msg[3][5]           )   // 开门请求绿色按钮
       ,.o_lock_open        ( o_lock_open_108           )   // 电磁锁A1
       ,.i_close_confirm_key        ( 1'b0           )   // 
       ,.i_door_monitor        ( 1'b0           )   // 
       ,.o_key_light        (            )   // 
    );

    assign do_regoin_r_msg[4][1] = ~o_lock_open_108;
	
	
	wire   o_lock_open_109;
	
	// --- flow_comp_109 --A0112_B区2#安全门锁---
    ec_sf_door
    #(
         .REG_SPACE_BIAS     ( 20'd97280)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_sf_door_109
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[186]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[186]    ),
	  .o_intr_irq            ( map_irq[186]       )

       ,.i_lock_monitor        ( ~di_regoin_msg[3][7]           )   // 锁监控常闭DO端口
       ,.i_open_req_key        ( ~di_regoin_msg[3][8]           )   // 开门请求绿色按钮
       ,.o_lock_open        ( o_lock_open_109           )   // 电磁锁A1
       ,.i_close_confirm_key        ( 1'b0           )   // 
       ,.i_door_monitor        ( 1'b0           )   // 
       ,.o_key_light        (            )   // 
    );

    assign do_regoin_r_msg[4][2] = ~o_lock_open_109;
	
	
	wire   o_lock_open_110;
	
	// --- flow_comp_110 --A0113_B区3#安全门锁---
    ec_sf_door
    #(
         .REG_SPACE_BIAS     ( 20'd96768)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_sf_door_110
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[185]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[185]    ),
	  .o_intr_irq            ( map_irq[185]       )

       ,.i_lock_monitor        ( ~di_regoin_msg[3][10]           )   // 锁监控常闭DO端口
       ,.i_open_req_key        ( ~di_regoin_msg[3][11]           )   // 开门请求绿色按钮
       ,.o_lock_open        ( o_lock_open_110           )   // 电磁锁A1
       ,.i_close_confirm_key        ( 1'b0           )   // 
       ,.i_door_monitor        ( 1'b0           )   // 
       ,.o_key_light        (            )   // 
    );

    assign do_regoin_r_msg[4][3] = ~o_lock_open_110;
	
	
	wire   o_lock_open_111;
	
	// --- flow_comp_111 --A0114_C区1#安全门锁---
    ec_sf_door
    #(
         .REG_SPACE_BIAS     ( 20'd98304)
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[188]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[188]    ),
	  .o_intr_irq            ( map_irq[188]       )

       ,.i_lock_monitor        ( ~di_regoin_msg[3][13]           )   // 锁监控常闭DO端口
       ,.i_open_req_key        ( ~di_regoin_msg[3][47]           )   // 开门请求绿色按钮
       ,.o_lock_open        ( o_lock_open_111           )   // 电磁锁A1
       ,.i_close_confirm_key        ( 1'b0           )   // 
       ,.i_door_monitor        ( 1'b0           )   // 
       ,.o_key_light        (            )   // 
    );

    assign do_regoin_r_msg[3][4] = ~o_lock_open_111;
	
	
	wire   o_lock_open_112;
	
	// --- flow_comp_112 --A0115_C区2#安全门锁---
    ec_sf_door
    #(
         .REG_SPACE_BIAS     ( 20'd97792)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_sf_door_112
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[187]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[187]    ),
	  .o_intr_irq            ( map_irq[187]       )

       ,.i_lock_monitor        ( ~di_regoin_msg[3][49]           )   // 锁监控常闭DO端口
       ,.i_open_req_key        ( ~di_regoin_msg[3][50]           )   // 开门请求绿色按钮
       ,.o_lock_open        ( o_lock_open_112           )   // 电磁锁A1
       ,.i_close_confirm_key        ( 1'b0           )   // 
       ,.i_door_monitor        ( 1'b0           )   // 
       ,.o_key_light        (            )   // 
    );

    assign do_regoin_r_msg[3][5] = ~o_lock_open_112;
	
	
	wire   o_lock_open_113;
	
	// --- flow_comp_113 --A0116_C区3#安全门锁---
    ec_sf_door
    #(
         .REG_SPACE_BIAS     ( 20'd96256)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_sf_door_113
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[184]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[184]    ),
	  .o_intr_irq            ( map_irq[184]       )

       ,.i_lock_monitor        ( ~di_regoin_msg[3][52]           )   // 锁监控常闭DO端口
       ,.i_open_req_key        ( ~di_regoin_msg[3][53]           )   // 开门请求绿色按钮
       ,.o_lock_open        ( o_lock_open_113           )   // 电磁锁A1
       ,.i_close_confirm_key        ( 1'b0           )   // 
       ,.i_door_monitor        ( 1'b0           )   // 
       ,.o_key_light        (            )   // 
    );

    assign do_regoin_r_msg[3][6] = ~o_lock_open_113;
	
	
	wire   o_lock_open_114;
	
	// --- flow_comp_114 --A0117_地轨首端安全门锁---
    ec_sf_door
    #(
         .REG_SPACE_BIAS     ( 20'd95232)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_sf_door_114
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[182]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[182]    ),
	  .o_intr_irq            ( map_irq[182]       )

       ,.i_lock_monitor        ( ~di_regoin_msg[1][38]           )   // 锁监控常闭DO端口
       ,.i_open_req_key        ( ~di_regoin_msg[1][39]           )   // 开门请求绿色按钮
       ,.o_lock_open        ( o_lock_open_114           )   // 电磁锁A1
       ,.i_close_confirm_key        ( 1'b0           )   // 
       ,.i_door_monitor        ( 1'b0           )   // 
       ,.o_key_light        (            )   // 
    );

    assign do_regoin_r_msg[1][32] = ~o_lock_open_114;
	
	
	wire   o_lock_open_115;
	
	// --- flow_comp_115 --A0118_地轨尾端安全门锁---
    ec_sf_door
    #(
         .REG_SPACE_BIAS     ( 20'd95744)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_sf_door_115
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[183]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[183]    ),
	  .o_intr_irq            ( map_irq[183]       )

       ,.i_lock_monitor        ( ~di_regoin_msg[1][35]           )   // 锁监控常闭DO端口
       ,.i_open_req_key        ( ~di_regoin_msg[1][36]           )   // 开门请求绿色按钮
       ,.o_lock_open        ( o_lock_open_115           )   // 电磁锁A1
       ,.i_close_confirm_key        ( 1'b0           )   // 
       ,.i_door_monitor        ( 1'b0           )   // 
       ,.o_key_light        (            )   // 
    );

    assign do_regoin_r_msg[1][31] = ~o_lock_open_115;
	
	
	wire   o_sig_dri_116;
	
	// --- flow_comp_116 --A0119_清洗机吹气---
    ec_1do
    #(
         .REG_SPACE_BIAS     ( 20'd57856)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1do_116
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[109]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[109]    ),
	  .o_intr_irq            ( map_irq[109]       )

       ,.o_sig_dri        ( o_sig_dri_116           )   // 单驱动信号
    );

    assign do_regoin_r_msg[2][7] = ~o_sig_dri_116;
	
	
	wire   o_bz_118;
	wire   o_led_g_118;
	wire   o_led_r_118;
	wire   o_led_y_118;
	
	// --- flow_comp_118 --A0121_6号机床_三色灯蜂鸣器---
    ec_3led_buzzer
    #(
         .REG_SPACE_BIAS     ( 20'd83456)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3led_buzzer_118
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[159]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[159]    ),
	  .o_intr_irq            ( map_irq[159]       )

       ,.o_led_y        ( o_led_y_118           )   // 黄色端口
       ,.o_led_g        ( o_led_g_118           )   // 绿色端口
       ,.o_bz        ( o_bz_118           )   // 蜂鸣端口
       ,.o_led_r        ( o_led_r_118           )   // 红色端口
    );

    assign do_regoin_r_msg[3][3] = ~o_bz_118;
    assign do_regoin_r_msg[3][2] = ~o_led_g_118;
    assign do_regoin_r_msg[3][0] = ~o_led_r_118;
    assign do_regoin_r_msg[3][1] = ~o_led_y_118;
	
	
	wire   o_dri1_122;
	wire   o_dri2_122;
	
	// --- flow_comp_122 --A0340_7号机床旋转机构---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd84480)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_122
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[161]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[161]    ),
	  .o_intr_irq            ( map_irq[161]       )

       ,.i_pos1        ( ~di_regoin_msg[4][66]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[4][67]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_122           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_122           )   // 驱动信号2
    );

    assign do_regoin_r_msg[4][34] = ~o_dri1_122;
    assign do_regoin_r_msg[4][35] = ~o_dri2_122;
	
	
	wire   o_dri1_123;
	wire   o_dri2_123;
	
	// --- flow_comp_123 --A0342_8号机床旋转机构---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd99328)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_123
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[190]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[190]    ),
	  .o_intr_irq            ( map_irq[190]       )

       ,.i_pos1        ( ~di_regoin_msg[4][68]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[4][69]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_123           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_123           )   // 驱动信号2
    );

    assign do_regoin_r_msg[4][36] = ~o_dri1_123;
    assign do_regoin_r_msg[4][37] = ~o_dri2_123;
	
	
	wire   o_dri1_124;
	wire   o_dri2_124;
	
	// --- flow_comp_124 --A0344_9号机床旋转机构---
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     ( 20'd100352)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_2di_2do_124
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[192]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[192]    ),
	  .o_intr_irq            ( map_irq[192]       )

       ,.i_pos1        ( ~di_regoin_msg[4][70]           )   // 位置1到位开关
       ,.i_pos2        ( ~di_regoin_msg[4][71]           )   // 位置2到位开关
       ,.o_dri1        ( o_dri1_124           )   // 驱动信号1
       ,.o_dri2        ( o_dri2_124           )   // 驱动信号2
    );

    assign do_regoin_r_msg[4][38] = ~o_dri1_124;
    assign do_regoin_r_msg[4][39] = ~o_dri2_124;
	
	
	
	// // --- flow_comp_125 --A0124_EMCC60主控板---
    // ec_emcc60_board
    // #(
    //      .REG_SPACE_BIAS     ( 20'd100864)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // ec_emcc60_board_125
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
	//   .o_st_rd_vld           ( sub_comp_rd_vld[193]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[193]    ),
	//   .o_intr_irq            ( map_irq[193]       )

    // );

	
	
	
	// // --- flow_comp_126 --A0161_B区C区控制柜1#分控板---
    // eecc30
    // #(
    //      .REG_SPACE_BIAS     ( 20'd92160)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // eecc30_126
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
	//   .o_st_rd_vld           ( sub_comp_rd_vld[176]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[176]    ),
	//   .o_intr_irq            ( map_irq[176]       )

    // );

	
	
	
	// // --- flow_comp_127 --A0162_B区C区控制柜2#分控板---
    // eecc30
    // #(
    //      .REG_SPACE_BIAS     ( 20'd92672)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // eecc30_127
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
	//   .o_st_rd_vld           ( sub_comp_rd_vld[177]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[177]    ),
	//   .o_intr_irq            ( map_irq[177]       )

    // );

	
	
	
	// // --- flow_comp_128 --A0172_装卸站控制柜1#分控板---
    // eecc30
    // #(
    //      .REG_SPACE_BIAS     ( 20'd93184)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // eecc30_128
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
	//   .o_st_rd_vld           ( sub_comp_rd_vld[178]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[178]    ),
	//   .o_intr_irq            ( map_irq[178]       )

    // );

	
	
	
	// // --- flow_comp_129 --A0173_装卸站控制柜2#分控板---
    // eecc30
    // #(
    //      .REG_SPACE_BIAS     ( 20'd101376)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // eecc30_129
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
	//   .o_st_rd_vld           ( sub_comp_rd_vld[194]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[194]    ),
	//   .o_intr_irq            ( map_irq[194]       )

    // );

	
	
	
	// // --- flow_comp_130 --A0245_去毛刺机分控板---
    // eecc30
    // #(
    //      .REG_SPACE_BIAS     ( 20'd57344)
    //     ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    // )
    // eecc30_130
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
	//   .o_st_rd_vld           ( sub_comp_rd_vld[108]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[108]    ),
	//   .o_intr_irq            ( map_irq[108]       )

    // );

	
	
	
	// --- flow_comp_134 --A0268_6#设备工装8电驱动---
    ec_s7_plc
    #(
         .REG_SPACE_BIAS     ( 20'd102912)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_s7_plc_134
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[197]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[197]    ),
	  .o_intr_irq            ( map_irq[197]       )

    );

	
	
	
	// --- flow_comp_135 --A0269_7#设备工装8电驱动---
    ec_s7_plc
    #(
         .REG_SPACE_BIAS     ( 20'd103424)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_s7_plc_135
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[198]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[198]    ),
	  .o_intr_irq            ( map_irq[198]       )

    );

	
	
	
	// --- flow_comp_136 --A0270_8#设备工装8电驱动---
    ec_s7_plc
    #(
         .REG_SPACE_BIAS     ( 20'd103936)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_s7_plc_136
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[199]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[199]    ),
	  .o_intr_irq            ( map_irq[199]       )

    );

	
	
	
	// --- flow_comp_137 --A0271_9#设备工装8电驱动---
    ec_s7_plc
    #(
         .REG_SPACE_BIAS     ( 20'd104448)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_s7_plc_137
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[200]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[200]    ),
	  .o_intr_irq            ( map_irq[200]       )

    );

	

	`endif

	
endmodule