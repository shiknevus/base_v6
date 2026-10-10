
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
	
	
//	localparam                          ARB_CH_PER_BOARD = 4;   // ÿ�Ӱ���� 485 ģ����
//    wire                                ch_rs485_r_flag  [RAM_DWIDTH-1:0][ARB_CH_PER_BOARD-1:0];
//    wire                                ch_rs485_flag    [RAM_DWIDTH-1:0][ARB_CH_PER_BOARD-1:0];
//    wire    [RAM_DWIDTH-1:0]            ch_rs485_s2m_msg [RAM_DWIDTH-1:0][ARB_CH_PER_BOARD-1:0];
//    wire    [RAM_DWIDTH-1:0]            ch_rs485_m2s_msg [RAM_DWIDTH-1:0][ARB_CH_PER_BOARD-1:0];
//    wire    [4:0]                       ch_board_id[RAM_DWIDTH-1:0];
//    genvar arb_bi;
//    generate
//        for (arb_bi=0; arb_bi<RAM_DWIDTH; arb_bi=arb_bi+1) begin: gen_arb_bid
//            assign ch_board_id[arb_bi] = arb_bi[4:0];
//        end
//    endgenerate
    

//    slave_rs485_arbiter
//    #(
//         .RAM_DWIDTH            ( RAM_DWIDTH                   )
//        ,.NUM_BOARDS            ( RAM_DWIDTH                   )
//        ,.CH_PER_BOARD          ( ARB_CH_PER_BOARD             )
//        ,.RFLAG_BOARD_W         ( RAM_AWIDTH - 9               )
//    )
//    u_slave_rs485_arbiter
//    (
//         .clk                   ( clk                          )
//        ,.rst                   ( reset                        )

//        // Shared side (pkg_route) - ȫ�������
//        ,.sh_rs485_r_flag       ( rs485_00_r_flag              )
//        ,.sh_rs485_r_flag_board ( slv_cfg_msg_addr[RAM_AWIDTH-1:9] )
//        ,.sh_rs485_flag         ( rs485_00_flag                )
//        ,.sh_rs485_s2m_msg      ( rs485_00_msg                 )
//        ,.sh_rs485_m2s_msg      ( rs485_00_send_msg            )

//        // Channel side - [�Ӱ��][ģ���ٲú�]
//        ,.ch_rs485_r_flag       ( ch_rs485_r_flag              )
//        ,.ch_rs485_flag         ( ch_rs485_flag                )
//        ,.ch_rs485_s2m_msg      ( ch_rs485_s2m_msg             )
//        ,.ch_rs485_m2s_msg      ( ch_rs485_m2s_msg             )
//    );
	
	
	
	    assign do_mst_msg[5:5] = 1'b1 ;
    assign do_mst_msg[6:6] = 1'b1 ;
    assign do_mst_msg[7:7] = 1'b1 ;
    assign do_mst_msg[8:8] = 1'b1 ;
    assign do_mst_msg[9:9] = 1'b1 ;
    assign do_mst_msg[10:10] = 1'b1 ;
    assign do_mst_msg[11:11] = 1'b1 ;
    assign do_mst_msg[12:12] = 1'b1 ;
    assign do_mst_msg[13:13] = 1'b1 ;
    assign do_mst_msg[14:14] = 1'b1 ;
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
    assign  emcc_irq[9]   = map_irq[9];
    assign  emcc_irq[10]   = map_irq[10];
    assign  emcc_irq[11]   = map_irq[11];
    assign  emcc_irq[14]   = map_irq[14];
    assign  emcc_irq[12]   = map_irq[12];
    assign  emcc_irq[13]   = map_irq[13];
    assign  emcc_irq[1]   = map_irq[1];
    assign  emcc_irq[2]   = map_irq[2];
    assign  emcc_irq[3]   = map_irq[3];
    assign  emcc_irq[4]   = map_irq[4];
    assign  emcc_irq[5]   = map_irq[5];
    assign  emcc_irq[6]   = map_irq[6];
    assign  emcc_irq[7]   = map_irq[7];
    assign  emcc_irq[8]   = map_irq[8];
    
	
	
	// --- flow_comp_1 --A0006_D�������˻���-1��A����ת---
//    ec_ecat_multi_turn_angle_spin_servo
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd2048)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
//    ec_ecat_multi_turn_angle_spin_servo_1
    ec_ethercat_servo_1
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[0]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[0]    ),
	  .o_intr_irq            ( map_irq[0]       )

 //      ,.i_axis_zero        ( di_mst_msg[12]           )   // ��ɫ
    );

	
	
	
	// --- flow_comp_2 --A0856_1��������������---
    ec_1do
    #(
         .REG_SPACE_BIAS     ( 20'd2560)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1do_2
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

	
	
	
	// --- flow_comp_3 --A0005_D�������˻���-2��Z��---
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd3072)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ethercat_servo_3
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

    //   ,.i_axis_limf        ( di_mst_msg[10]           )   // ��ɫ
    //   ,.i_axis_limb        ( di_mst_msg[11]           )   // ��ɫ
    //   ,.i_axis_zero        ( di_mst_msg[9]           )   // ��ɫ
    );

	
	
	
	// --- flow_comp_4 --A0857_2��������������---
    ec_1do
    #(
         .REG_SPACE_BIAS     ( 20'd3584)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_1do_4
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

	
	
	
	// --- flow_comp_5 --A0588_D�������˻���-1��X��---
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd4096)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ethercat_servo_5
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

     //  ,.i_axis_limf        ( di_mst_msg[15]           )   // ��ɫ
     //  ,.i_axis_limb        ( di_mst_msg[16]           )   // ��ɫ
     //  ,.i_axis_zero        ( di_mst_msg[14]           )   // ��ɫ
    );

	
	
	
	// --- flow_comp_6 --A0822_��������---
    ec_pulmotor_handwheel
    #(
         .REG_SPACE_BIAS     ( 20'd4608)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_pulmotor_handwheel_6
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

    );

	
	
	
	// --- flow_comp_7 --A0007_D�������˻���-2��A����ת---
//    ec_ecat_multi_turn_angle_spin_servo
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd5120)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
//    ec_ecat_multi_turn_angle_spin_servo_7
    ec_ethercat_servo_7
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

      // ,.i_axis_zero        ( di_mst_msg[13]           )   // ��ɫ
    );

	
	
	
	// --- flow_comp_8 --A0819_2���������---
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd5632)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ethercat_servo_8
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

     //  ,.i_axis_limf        ( di_mst_msg[18]           )   // ��ɫ
     //  ,.i_axis_limb        ( di_mst_msg[19]           )   // ��ɫ
     //  ,.i_axis_zero        ( di_mst_msg[17]           )   // ��ɫ
    );

	
	
	
	// --- flow_comp_9 --A0003_D�������˻���-2��X��---
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd6144)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ethercat_servo_9
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

     //  ,.i_axis_limf        ( di_mst_msg[4]           )   // ��ɫ
     //  ,.i_axis_limb        ( di_mst_msg[5]           )   // ��ɫ
     //  ,.i_axis_zero        ( di_mst_msg[3]           )   // ��ɫ
    );

	
	
	
	// --- flow_comp_10 --A0001_1���������---
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd6656)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ethercat_servo_10
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[9]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[9]    ),
	  .o_intr_irq            ( map_irq[9]       )

      ,.i_axis_limf        ( ~di_mst_msg[1]           )   // ��ɫ
      ,.i_axis_limb        ( ~di_mst_msg[2]           )   // ��ɫ
      ,.i_axis_zero        ( ~di_mst_msg[0]           )   // ��ɫ
    );

	
	
	
	// --- flow_comp_11 --A0193_���²�����---
//    ec_hd_zxcl
    ec_s7_plc
    #(
         .REG_SPACE_BIAS     ( 20'd7168)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
//    ec_hd_zxcl_11
    ec_s7_plc_11
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

	
	
	
	// --- flow_comp_12 --A0004_D�������˻���-1��Z��---
    ec_ethercat_servo
    #(
         .REG_SPACE_BIAS     ( 20'd7680)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_ethercat_servo_12
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

    //   ,.i_axis_limf        ( di_mst_msg[7]           )   // ��ɫ
    //   ,.i_axis_limb        ( di_mst_msg[8]           )   // ��ɫ
    //   ,.i_axis_zero        ( di_mst_msg[6]           )   // ��ɫ
    );

	
	
	
//	// --- flow_comp_15 --A0890_EMCC60���ư�ģ��ECAT-D����---
//    ec_emcc60_board
//    #(
//         .REG_SPACE_BIAS     ( 20'd9216)
//        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
//    )
//    ec_emcc60_board_15
//    (
      
//	  .clk                   ( clk               ),
//      .reset                   ( reset             ),
////	  .ps_reg_clk            ( ps_reg_clk        ),
////      .ps_reg_reset          ( ps_reg_reset      ),
	  
//	  .i_time_1ms_vld        ( time_1ms_vld      ),
//	  .i_time_1s_vld         ( time_1s_vld       ),

//	  .i_st_wr_en            ( ps_reg_we         ),
//	  .i_st_wr_addr          ( ps_reg_addr       ),
//      .i_st_wr_data          ( ps_reg_wr_dat     ),
//      .i_st_rd_en            ( ps_reg_re         ),
//      .i_st_rd_addr          ( ps_reg_rd_addr    ),
//	  .o_st_rd_vld           ( sub_comp_rd_vld[14]    ),
//      .o_st_rd_data          ( sub_comp_rd_dat[14]    ),
//	  .o_intr_irq            ( map_irq[14]       )

//    );

	
	
	wire   o_bz_16;
	wire   o_led_g_16;
	wire   o_led_r_16;
	wire   o_led_y_16;
	
	// --- flow_comp_16 --A0894_��ɫ��ģ��[����]_����---
    ec_3led_buzzer
    #(
         .REG_SPACE_BIAS     ( 20'd8192)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_3led_buzzer_16
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
	  .o_st_rd_vld           ( sub_comp_rd_vld[12]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[12]    ),
	  .o_intr_irq            ( map_irq[12]       )

       ,.o_led_y        ( o_led_y_16           )   // ��ɫ�����ź�
       ,.o_led_g        ( o_led_g_16           )   // ��ɫ�����ź�
       ,.o_bz        ( o_bz_16           )   // ���������ź�
       ,.o_led_r        ( o_led_r_16           )   // ��ɫ�����ź�
    );

    assign do_mst_msg[1] = o_bz_16;
    assign do_mst_msg[2] = o_led_g_16;
    assign do_mst_msg[3] = o_led_r_16;
    assign do_mst_msg[4] = o_led_y_16;
	
	
	
	// --- flow_comp_17 --A0895_ϵͳ��ȫģ��[����]_����---
    ec_sys_sf
    #(
         .REG_SPACE_BIAS     ( 20'd8704)
        ,.REG_SPACE_SIZE     ( `REG_SPACE_SIZE           )
    )
    ec_sys_sf_17
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

       ,.i_stop        ( di_mst_msg[35]           )   // ֹͣ��ť����
       ,.i_start        ( di_mst_msg[34]           )   // ������ť����
       ,.i_rst        ( di_mst_msg[36]           )   // ��λ��ť����
       ,.i_estop        ( di_mst_msg[37]           )   // ��ͣ��ť����
       ,.i_manul        ( di_mst_msg[38]           )   // �ֶ�ѡ��L
       ,.i_auto        ( di_mst_msg[39]           )   // �Զ�ѡ��R
    );

	

	`endif

	
endmodule