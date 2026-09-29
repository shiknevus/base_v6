
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
	
	// emcc_flow_if flow_cfg_if[BIAS_NUM+COMP_NUM-1:BIAS_NUM]();
	
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
	
	reg    [RAM_DWIDTH*2-1:0]          do_regoin_r_msg_n_r[RAM_DWIDTH-1:0];
    

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
        ,.do_regoin_r_msg       (do_regoin_r_msg_n_r     )
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
	
	always @(*) begin
  for(int i=0;i<RAM_DWIDTH;i++) begin
    do_regoin_r_msg_n_r[i] = ~ do_regoin_r_msg_n[i];
  end
end
	
	
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



    // --- RS485 Arbiter: per-channel side wires (flow_comp <-> arbiter) ---
    // 模板静态区：导出后不修改。
    // 通道二维索引：ch_rs485_XX[从板号][模块仲裁号]
    // ch_board_id[k] = k：从板号查找表（cur_slv_board_id 用）
    localparam                          ARB_CH_PER_BOARD = 4;   // 每从板最大 485 模块数
    wire                                ch_rs485_r_flag  [RAM_DWIDTH-1:0][ARB_CH_PER_BOARD-1:0];
    wire                                ch_rs485_flag    [RAM_DWIDTH-1:0][ARB_CH_PER_BOARD-1:0];
    wire    [RAM_DWIDTH-1:0]            ch_rs485_s2m_msg [RAM_DWIDTH-1:0][ARB_CH_PER_BOARD-1:0];
    wire    [RAM_DWIDTH-1:0]            ch_rs485_m2s_msg [RAM_DWIDTH-1:0][ARB_CH_PER_BOARD-1:0];
    wire    [4:0]                       ch_board_id[RAM_DWIDTH-1:0];
    genvar arb_bi;
    generate
        for (arb_bi=0; arb_bi<RAM_DWIDTH; arb_bi=arb_bi+1) begin: gen_arb_bid
            assign ch_board_id[arb_bi] = arb_bi[4:0];
        end
    endgenerate
    

    slave_rs485_arbiter
    #(
         .RAM_DWIDTH            ( RAM_DWIDTH                   )
        ,.NUM_BOARDS            ( RAM_DWIDTH                   )
        ,.CH_PER_BOARD          ( ARB_CH_PER_BOARD             )
        ,.RFLAG_BOARD_W         ( RAM_AWIDTH - 9               )
    )
    u_slave_rs485_arbiter
    (
         .clk                   ( clk                          )
        ,.rst                   ( reset                        )

        // Shared side (pkg_route) — 全板号数组
        ,.sh_rs485_r_flag       ( rs485_00_r_flag              )
        ,.sh_rs485_r_flag_board ( slv_cfg_msg_addr[RAM_AWIDTH-1:9] )
        ,.sh_rs485_flag         ( rs485_00_flag                )
        ,.sh_rs485_s2m_msg      ( rs485_00_msg                 )
        ,.sh_rs485_m2s_msg      ( rs485_00_send_msg            )

        // Channel side — [从板号][模块仲裁号]
        ,.ch_rs485_r_flag       ( ch_rs485_r_flag              )
        ,.ch_rs485_flag         ( ch_rs485_flag                )
        ,.ch_rs485_s2m_msg      ( ch_rs485_s2m_msg             )
        ,.ch_rs485_m2s_msg      ( ch_rs485_m2s_msg             )
    );


ec_superisys_485_modbus_rtu
#(
    //  .REG_SPACE_BIAS         (20'd54272                ), //组件基地址
        .REG_SPACE_BIAS         (20'h3000                 ), //组件基地址
        .REG_SPACE_SIZE         (512          ) //组件偏移地址
       // .CLK_FREQ               (156250000                )  //100MHz = 100000000
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
        .cur_slv_board_id      ( ch_board_id[0]           ), // RS485端口 - 从板0
        .slv_board_id          ( slv_board_id             ), 
        .rs485_ch_r_flag       ( ch_rs485_r_flag[0][0]    ),// rs485_00_r_flag[0][0]    ), //send en    // 仲裁器[从板0][仲裁号0]
        .m2s_rs485_msg         ( ch_rs485_m2s_msg[0][0]   ),// rs485_00_send_msg[0][0]  ), //send data
        .rs485_ch_flag         ( ch_rs485_flag[0][0]      ),// rs485_00_flag[0][0]      ), //recv en
        .s2m_rs485_msg         ( ch_rs485_s2m_msg[0][0]   ) // rs485_00_msg[0][0]       )  //recv data
    );
	
	
	
	`endif

	
endmodule