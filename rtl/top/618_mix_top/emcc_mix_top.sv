
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
    
	
	
	// --- flow_comp_1 -----磨床1
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     (20'd25600)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )       
    )
    ec_siemens_cnc_1
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[46]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[46]    ),
	  .o_intr_irq            ( map_irq[46]       )

    );

	
	
	
	// --- flow_comp_2 -----磨床2
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     (20'd34816)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_2
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[64]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[64]    ),
	  .o_intr_irq            ( map_irq[64]       )

    );

	
	
	
	// --- flow_comp_3 -----磨床3
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     (20'd44032)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_3
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[82]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[82]    ),
	  .o_intr_irq            ( map_irq[82]       )

    );


	
	
	
	// --- flow_comp_4 -----磨床4
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     (20'd45056)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_4
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[84]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[84]    ),
	  .o_intr_irq            ( map_irq[84]       )

    );

	
	
	
	// --- flow_comp_5 -----磨床5
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     (20'd45568)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_5
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[85]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[85]    ),
	  .o_intr_irq            ( map_irq[85]       )

    );
	
	
	
	// --- flow_comp_6 -----磨床6
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     (20'd44544)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_6
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[83]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[83]    ),
	  .o_intr_irq            ( map_irq[83]       )

    );

	
	
	
	// --- flow_comp_7 -----磨床7
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     (20'd46080)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_7
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[86]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[86]    ),
	  .o_intr_irq            ( map_irq[86]       )

    );

	
	
	
	// --- flow_comp_8 -----磨床8
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     (20'd46592)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_8
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[87]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[87]    ),
	  .o_intr_irq            ( map_irq[87]       )

    );

	
	
	
	// --- flow_comp_9 -----磨床9
    ec_siemens_cnc
    #(
         .REG_SPACE_BIAS     (20'd47104)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_siemens_cnc_9
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[88]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[88]    ),
	  .o_intr_irq            ( map_irq[88]       )

    );

	
	
	
	// --- flow_comp_11 -----海克斯康三坐标1
    ec_hex_coordinate
    #(
         .REG_SPACE_BIAS     (20'd48128)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_hex_coordinate_11
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[90]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[90]    ),
	  .o_intr_irq            ( map_irq[90]       )

    );

	
	
	
	// --- flow_comp_12 -----海克斯康三坐标2
    ec_hex_coordinate
    #(
         .REG_SPACE_BIAS     (20'd48640)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_hex_coordinate_12
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[91]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[91]    ),
	  .o_intr_irq            ( map_irq[91]       )

    );

	
	
	
	// --- flow_comp_13 -----海克斯康影像测量仪
    ec_hex_coordinate
    #(
         .REG_SPACE_BIAS     (20'd49152)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_hex_coordinate_13
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[92]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[92]    ),
	  .o_intr_irq            ( map_irq[92]       )

    );

	
	
	wire o_dri1_14;
	wire o_dri2_14;
	// --- flow_comp_14 -----1#三坐标卡盘
    ec_2di_3do
    #(
         .REG_SPACE_BIAS     (20'd50688)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_3do_14
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[95]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[95]    ),
	  .o_intr_irq            ( map_irq[95]       )
	  
	  //位置到位开关
	  ,.i_pos			( ~di_mst_msg[50] )
	  //有无感测开关
	  ,.i_poa			( 1'b0 )
	  //单驱动信号
	  ,.o_dri			( 1'b0 )
	  //双驱驱动信号1
	  ,.o_dri1			( o_dri1_14 )
	  //双驱驱动信号2
	  ,.o_dri2			( o_dri2_14 )

    );
	assign do_regoin_r_msg[2][17] = o_dri1_14;
    assign do_regoin_r_msg[2][16] = o_dri2_14;
	
	
	wire o_dri1_15;
	wire o_dri2_15;
	// --- flow_comp_15 -----2#三坐标卡盘
    ec_2di_3do
    #(
         .REG_SPACE_BIAS     (20'd51200)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_3do_15
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[96]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[96]    ),
	  .o_intr_irq            ( map_irq[96]       )
	  
	  //位置到位开关
	  ,.i_pos			( ~di_mst_msg[51] )
	  //有无感测开关
	  ,.i_poa			( 1'b0 )
	  //单驱动信号
	  ,.o_dri			( 1'b0 )
	  //双驱驱动信号1
	  ,.o_dri1			( o_dri1_15 )
	  //双驱驱动信号2
	  ,.o_dri2			( o_dri2_15 )

    );
	assign do_regoin_r_msg[2][19] = o_dri1_15;
    assign do_regoin_r_msg[2][18] = o_dri2_15;
	
	
	wire o_dri1_16;
	wire o_dri2_16;
	// --- flow_comp_16 -----影像测量仪卡盘
    ec_2di_3do
    #(
         .REG_SPACE_BIAS     (20'd51712)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_3do_16
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[97]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[97]    ),
	  .o_intr_irq            ( map_irq[97]       )
	  
	  //位置到位开关
	  ,.i_pos			( ~di_mst_msg[54] )
	  //有无感测开关
	  ,.i_poa			( 1'b0 )
	  //单驱动信号
	  ,.o_dri			( 1'b0 )
	  //双驱驱动信号1
	  ,.o_dri1			( o_dri1_16 )
	  //双驱驱动信号2
	  ,.o_dri2			( o_dri2_16 )

    );
	assign do_regoin_r_msg[2][21] = o_dri1_16;
    assign do_regoin_r_msg[2][20] = o_dri2_16;
	
	
	
	// --- flow_comp_17 -----蓝鲸清洗机
    ec_lanj_washer
    #(
         .REG_SPACE_BIAS     (20'd47616)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_lanj_washer_17
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[89]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[89]    ),
	  .o_intr_irq            ( map_irq[89]       )

    );

	
	
	
	// --- flow_comp_18 -----主地轨搬运机器人
    ec_fanuc_robot
    #(
         .REG_SPACE_BIAS     (20'd55296)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_fanuc_robot_18
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[104]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[104]    ),
	  .o_intr_irq            ( map_irq[104]       )

    );

	
	
	
	// --- flow_comp_19 -----短桁架1#机器人
    ec_fanuc_robot
    #(
         .REG_SPACE_BIAS     (20'd52736)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_fanuc_robot_19
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[99]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[99]    ),
	  .o_intr_irq            ( map_irq[99]       )

    );

	
	
	
	// --- flow_comp_20 -----长桁架2#机器人
    ec_fanuc_robot
    #(
         .REG_SPACE_BIAS     (20'd53248)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_fanuc_robot_20
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[100]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[100]    ),
	  .o_intr_irq            ( map_irq[100]       )

    );

	
	
	
	// --- flow_comp_21 -----长桁架3#机器人
    ec_fanuc_robot
    #(
         .REG_SPACE_BIAS     (20'd53760)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_fanuc_robot_21
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[101]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[101]    ),
	  .o_intr_irq            ( map_irq[101]       )

    );

	
	
	
	// --- flow_comp_22 -----搬运机器人
    ec_fanuc_robot
    #(
         .REG_SPACE_BIAS     (20'd49664)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_fanuc_robot_22
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[93]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[93]    ),
	  .o_intr_irq            ( map_irq[93]       )

    );

	
	
	wire   o_claw_press_23;
	wire   o_claw_unlock_23;
	// --- flow_comp_23 -----地轨机器人托盘搬运夹爪
    ec_trayclaw
    #(
         .REG_SPACE_BIAS     (20'd54784)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_trayclaw_23
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[103]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[103]    ),
	  .o_intr_irq            ( map_irq[103]       )
	  
	  ,.i_close_arr         ( ~di_mst_msg[23]          )
      ,.i_open_arr          ( ~di_mst_msg[22]          )
      ,.i_material_arr      ( ~di_mst_msg[17]          )   //~di_mst_msg[21]
      ,.i_airtight_arr      ( 1'b0        )
      ,.o_claw_unlock       ( o_claw_unlock_23          )
      ,.o_claw_press        ( o_claw_press_23           )
      ,.o_claw_blow         (             )

    );
	assign do_mst_msg[1] = o_claw_press_23;
    assign do_mst_msg[12] = o_claw_unlock_23;

	
	
	wire   o_dri1_24;
	wire   o_dri2_24;
	// --- flow_comp_24 -----地轨机器人砂轮搬运夹爪
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd55808)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_24
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[105]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[105]    ),
	  .o_intr_irq            ( map_irq[105]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_mst_msg[19]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_mst_msg[20]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_24           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_24           )

    );
	assign do_mst_msg[13]=o_dri1_24;
    assign do_mst_msg[14]=o_dri2_24;

	
	
	wire   o_dri1_25;
	wire   o_dri2_25;
	// --- flow_comp_25 -----搬运机器人夹爪
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd50176)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_25
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[94]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[94]    ),
	  .o_intr_irq            ( map_irq[94]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[2][16] )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[2][15] )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_25 )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_25 )

    );
	assign do_regoin_r_msg[2][22] = o_dri1_25;
    assign do_regoin_r_msg[2][23] = o_dri2_25;

	
	
	
	// // --- flow_comp_26 -----地轨机器人_RFID读写器
    // ec_sp_rfid
    // #(
    //      .REG_SPACE_BIAS     (20'd56320)
    //     ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    // )
    // ec_sp_rfid_26
    // (
    //   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk               ),
    //   .ps_reg_reset          ( ps_reg_reset             ),
	  
	//   .i_time_1ms_vld        (time_1ms_vld         ),
	//   .i_time_1s_vld         (time_1s_vld          ),

	//   .i_st_wr_en            ( ps_reg_we                ),
	//   .i_st_wr_addr          ( ps_reg_addr              ),
    //   .i_st_wr_data          ( ps_reg_wr_dat            ),
    //   .i_st_rd_en            ( ps_reg_re                ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr           ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[106]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[106]    ),
	//   .o_intr_irq            ( map_irq[106]       )

    // );

ec_superisys_485_modbus_rtu
#(
        .REG_SPACE_BIAS         (20'd56320                ), //组件基地址
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

	
	
	// // --- flow_comp_27 -----短桁架1#夹爪RFID读写器
    // ec_sp_rfid
    // #(
    //      .REG_SPACE_BIAS     (20'd54272)
    //     ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    // )
    // ec_sp_rfid_27
    // (
    //   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk               ),
    //   .ps_reg_reset          ( ps_reg_reset             ),
	  
	//   .i_time_1ms_vld        (time_1ms_vld         ),
	//   .i_time_1s_vld         (time_1s_vld          ),

	//   .i_st_wr_en            ( ps_reg_we                ),
	//   .i_st_wr_addr          ( ps_reg_addr              ),
    //   .i_st_wr_data          ( ps_reg_wr_dat            ),
    //   .i_st_rd_en            ( ps_reg_re                ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr           ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[102]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[102]    ),
	//   .o_intr_irq            ( map_irq[102]       )

    // );

ec_superisys_485_modbus_rtu
#(
        .REG_SPACE_BIAS         (20'd54272                ), //组件基地址
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
  
	
	
	// // --- flow_comp_28 -----固定机器人_RFID读写器
    // ec_sp_rfid
    // #(
    //      .REG_SPACE_BIAS     (20'd52224)
    //     ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    // )
    // ec_sp_rfid_28
    // (
    //   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk               ),
    //   .ps_reg_reset          ( ps_reg_reset             ),
	  
	//   .i_time_1ms_vld        (time_1ms_vld         ),
	//   .i_time_1s_vld         (time_1s_vld          ),

	//   .i_st_wr_en            ( ps_reg_we                ),
	//   .i_st_wr_addr          ( ps_reg_addr              ),
    //   .i_st_wr_data          ( ps_reg_wr_dat            ),
    //   .i_st_rd_en            ( ps_reg_re                ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr           ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[98]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[98]    ),
	//   .o_intr_irq            ( map_irq[98]       )

    // );
	
ec_superisys_485_modbus_rtu
#(
        .REG_SPACE_BIAS         (20'd52224                ), //组件基地址
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
  

    
	// --- flow_comp_32 -----
    ec_1di
    #(
         .REG_SPACE_BIAS     (20'd101888)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        //,.P_MODULE_ID        (8'd32                      )
        //,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1di_32
    (
      //.clk                   ( ps_reg_clk               ),
      //.reset                 ( ps_reg_reset             ),
	  //.aurora_clk            ( clk               ),
      //.aurora_reset          ( reset             ),
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[195]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[195]    ),
	  .o_intr_irq            ( map_irq[195]       )

       ,.i_sign1_check        ( di_mst_msg[27]           )
    );

	
	
	
	// --- flow_comp_33 -----
    ec_2di
    #(
         .REG_SPACE_BIAS     (20'd102400)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        //,.P_MODULE_ID        (8'd33                      )
        //,.P_SEAT_NUM         (4'd0                      )
    )
    ec_2di_33
    (
      //.clk                   ( ps_reg_clk               ),
      //.reset                 ( ps_reg_reset             ),
	  //.aurora_clk            ( clk               ),
      //.aurora_reset          ( reset             ),
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[196]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[196]    ),
	  .o_intr_irq            ( map_irq[196]       )

       ,.i_sign2_check        ( di_mst_msg[29]           )
       ,.i_sign1_check        ( di_mst_msg[28]           )
    );


	
	
	
	// --- flow_comp_35 -----分拣库_X轴
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     (20'd65024)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_35
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[123]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[123]    ),
	  .o_intr_irq            ( map_irq[123]       )
	  
	//   ,.prot_clk            ( clk                      )
    //    ,.prot_rst            ( reset                    )
       ,.pul_motor_r_flag    ( pul_motor1_r_flag        )
       ,.cur_slv_board_id    ( 5'd0                     )
       ,.slv_board_id        ( slv_board_id             )
       ,.pul_motor_flag      ( pul_motor1_flag          )
       ,.m2s_pulm_msg        ( pul_motor1_r_msg[0]      )
       ,.s2m_pulm_msg        ( pul_motor1_msg[0]        )
       ,.i_axis_zero          ( ~di_regoin_msg[0][31]    )
       ,.i_axis_limf         ( ~di_regoin_msg[0][30]    )
       ,.i_axis_limb         ( ~di_regoin_msg[0][32]    )
    //    ,.i_quickstop         ( motor_quickstop          )   
       ,.i_servo_ready       ( di_regoin_msg[0][17]     )
       ,.i_servo_done        ( ~di_regoin_msg[0][16]    )
	   
       //,.set_wheel_gear      ( 8'b0000_0001             )
       //,.i_wheel_prog        ( man_wheel_prog           )
       //,.i_wheel_run         ( man_wheel_run            )
       //,.i_wheel_dir         ( man_wheel_dir            )
       //,.i_wheel_speed       ( man_wheel_speed          )

    );

	
	
	
	// --- flow_comp_36 -----分拣库_Y轴
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     (20'd65536)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_36
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[124]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[124]    ),
	  .o_intr_irq            ( map_irq[124]       )
	  
	//   ,.prot_clk            ( clk                      )
    //    ,.prot_rst            ( reset                    )
       ,.pul_motor_r_flag    ( pul_motor0_r_flag        )
       ,.cur_slv_board_id    ( 5'd0                     )
       ,.slv_board_id        ( slv_board_id             )
       ,.pul_motor_flag      ( pul_motor0_flag          )
       ,.m2s_pulm_msg        ( pul_motor0_r_msg[0]      )
       ,.s2m_pulm_msg        ( pul_motor0_msg[0]        )
       ,.i_axis_zero          ( ~di_regoin_msg[0][34]    )
       ,.i_axis_limf         ( ~di_regoin_msg[0][33]    )
       ,.i_axis_limb         ( ~di_regoin_msg[0][35]    )
    //    ,.i_quickstop         ( motor_quickstop          )
       ,.i_servo_ready       ( di_regoin_msg[0][15]     )
       ,.i_servo_done        ( ~di_regoin_msg[0][14]    )
	   
       //,.set_wheel_gear      ( 8'b0000_0010             )
       //,.i_wheel_prog        ( man_wheel_prog           )
       //,.i_wheel_run         ( man_wheel_run            )
       //,.i_wheel_dir         ( man_wheel_dir            )
       //,.i_wheel_speed       ( man_wheel_speed          )

    );

	
	
	
	// --- flow_comp_37 -----分拣库_Z轴
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     (20'd66048)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_37
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[125]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[125]    ),
	  .o_intr_irq            ( map_irq[125]       )
	  
	//   ,.prot_clk            ( clk                      )
    //    ,.prot_rst            ( reset                    )
       ,.pul_motor_r_flag    ( pul_motor2_r_flag        )
       ,.cur_slv_board_id    ( 5'd0                     )
       ,.slv_board_id        ( slv_board_id             )
       ,.pul_motor_flag      ( pul_motor2_flag          )
       ,.m2s_pulm_msg        ( pul_motor2_r_msg[0]      )
       ,.s2m_pulm_msg        ( pul_motor2_msg[0]        )
       ,.i_axis_zero          ( ~di_regoin_msg[0][37]    )
       ,.i_axis_limf         ( ~di_regoin_msg[0][36]    )
       ,.i_axis_limb         ( ~di_regoin_msg[0][38]    )
    //    ,.i_quickstop         ( motor_quickstop          )
       ,.i_servo_ready       ( di_regoin_msg[0][19]     )
       ,.i_servo_done        ( ~di_regoin_msg[0][18]    )
	   
       //,.set_wheel_gear      ( 8'b0000_0100             )
       //,.i_wheel_prog        ( man_wheel_prog           )
       //,.i_wheel_run         ( man_wheel_run            )
       //,.i_wheel_dir         ( man_wheel_dir            )
       //,.i_wheel_speed       ( man_wheel_speed          )

    );

	
	
	
	// --- flow_comp_38 -----分拣库_R轴
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     (20'd66560)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_38
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[126]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[126]    ),
	  .o_intr_irq            ( map_irq[126]       )
	  
	//   ,.prot_clk            ( clk                      )
    //    ,.prot_rst            ( reset                    )
       ,.pul_motor_r_flag    ( pul_motor3_r_flag        )
       ,.cur_slv_board_id    ( 5'd0                     )
       ,.slv_board_id        ( slv_board_id             )
       ,.pul_motor_flag      ( pul_motor3_flag          )
       ,.m2s_pulm_msg        ( pul_motor3_r_msg[0]      )
       ,.s2m_pulm_msg        ( pul_motor3_msg[0]        )
       ,.i_axis_zero          ( ~di_regoin_msg[0][40]    )
       ,.i_axis_limf         ( ~di_regoin_msg[0][39]    )
       ,.i_axis_limb         ( ~di_regoin_msg[0][41]    )
    //    ,.i_quickstop         ( motor_quickstop          )
       ,.i_servo_ready       ( di_regoin_msg[0][21]     )
       ,.i_servo_done        ( ~di_regoin_msg[0][20]    )
	   
       //,.set_wheel_gear      ( 8'b0000_1000             )
       //,.i_wheel_prog        ( man_wheel_prog           )
       //,.i_wheel_run         ( man_wheel_run            )
       //,.i_wheel_dir         ( man_wheel_dir            )
       //,.i_wheel_speed       ( man_wheel_speed          )

    );

	
	
	wire   o_dri2_39;
	wire   o_dri1_39;
	// --- flow_comp_39 -----分拣库_桁架夹爪
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd67072)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_39
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[127]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[127]    ),
	  .o_intr_irq            ( map_irq[127]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[0][43]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[0][42]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_39          )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_39           )

    );
	assign do_regoin_r_msg[ 0][27] = o_dri2_39;
    assign do_regoin_r_msg[ 0][26] = o_dri1_39;

	
	
	wire   o_dri2_40;
	wire   o_dri1_40;
	// --- flow_comp_40 -----机器人托盘入口滑台
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     (20'd69120)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_3di_2do_40
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[131]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[131]    ),
	  .o_intr_irq            ( map_irq[131]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[1][12]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[1][13]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_40           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_40           )
	  //有无感测端口
	  ,.i_poa               ( ~di_regoin_msg[1][7]  )

    );
	assign do_regoin_r_msg[ 0][21] = o_dri2_40;
    assign do_regoin_r_msg[ 0][20] = o_dri1_40;

	
	
	wire   o_dri2_41;
	wire   o_dri1_41;
	// --- flow_comp_41 -----机器人托盘出口滑台
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     (20'd69632)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_3di_2do_41
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[132]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[132]    ),
	  .o_intr_irq            ( map_irq[132]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[1][14]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[1][15]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_41           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_41           )
	  //有无感测端口
	  ,.i_poa               ( ~di_regoin_msg[1][8]  )

    );
	assign do_regoin_r_msg[ 0][23] = o_dri2_41;
    assign do_regoin_r_msg[ 0][22] = o_dri1_41;
 
	
	
	wire   o_dri1_42;
	wire   o_dri2_42;
	// --- flow_comp_42 -----[1号-A]正常上料滑台
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     (20'd70144)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_3di_2do_42
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[133]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[133]    ),
	  .o_intr_irq            ( map_irq[133]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[1][0]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[1][1]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_42           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_42           )
	  //有无感测端口
	  ,.i_poa               ( ~di_regoin_msg[1][1]  )

    );
	assign do_regoin_r_msg[0][8] = o_dri1_42;
    assign do_regoin_r_msg[0][9] = o_dri2_42;
	
	
	wire   o_dri1_43;
	wire   o_dri2_43;
	// --- flow_comp_43 -----[1号-B]正常上料滑台
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     (20'd67584)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_3di_2do_43
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[128]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[128]    ),
	  .o_intr_irq            ( map_irq[128]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[1][2]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[1][3]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_43           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_43           )
	  //有无感测端口
	  ,.i_poa               ( ~di_regoin_msg[1][2]  )

    );
	assign do_regoin_r_msg[0][10] = o_dri1_43;
    assign do_regoin_r_msg[0][11] = o_dri2_43;

	
	
	wire   o_dri1_44;
	wire   o_dri2_44;
	// --- flow_comp_44 -----[2号-A]正常上料滑台
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     (20'd70656)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_3di_2do_44
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[134]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[134]    ),
	  .o_intr_irq            ( map_irq[134]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[1][4]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[1][5]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_44           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_44           )
	  //有无感测端口
	  ,.i_poa               ( ~di_regoin_msg[1][3]  )

    );
	assign do_regoin_r_msg[ 0][12] = o_dri1_44;
    assign do_regoin_r_msg[ 0][13] = o_dri2_44;

	
	
	wire   o_dri1_45;
	wire   o_dri2_45;
	// --- flow_comp_45 -----[2号-B]正常上料滑台
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     (20'd68096)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_3di_2do_45
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[129]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[129]    ),
	  .o_intr_irq            ( map_irq[129]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[1][6]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[1][7]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_45           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_45           )
	  //有无感测端口
	  ,.i_poa               ( ~di_regoin_msg[1][4]  )

    );
	assign do_regoin_r_msg[0][14] = o_dri1_45;
    assign do_regoin_r_msg[0][15] = o_dri2_45;

	
	
	wire   o_dri2_46;
	wire   o_dri1_46;
	// --- flow_comp_46 -----[3号-A]异常下料滑台
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     (20'd71168)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_3di_2do_46
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[135]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[135]    ),
	  .o_intr_irq            ( map_irq[135]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[1][8]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[1][9]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_46           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_46           )
	  //有无感测端口
	  ,.i_poa               ( ~di_regoin_msg[1][5]  )

    );
	assign do_regoin_r_msg[0][17] = o_dri2_46;
    assign do_regoin_r_msg[0][16] = o_dri1_46;

	
	
	wire   o_dri2_47;
	wire   o_dri1_47;
	// --- flow_comp_47 -----[3号-B]异常下料滑台
    ec_3di_2do
    #(
         .REG_SPACE_BIAS     (20'd68608)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_3di_2do_47
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[130]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[130]    ),
	  .o_intr_irq            ( map_irq[130]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[1][10]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[1][11]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_47           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_47           )
	  //有无感测端口
	  ,.i_poa               ( ~di_regoin_msg[1][6]  )

    );
	assign do_regoin_r_msg[0][19] = o_dri2_47;
    assign do_regoin_r_msg[0][18] = o_dri1_47;

	
	
	
	// --- flow_comp_48 -----分拣库_打标机卡盘R轴
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     (20'd72704)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_48
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[138]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[138]    ),
	  .o_intr_irq            ( map_irq[138]       )
	  
	//   ,.prot_clk            ( clk                      )
    //    ,.prot_rst            ( reset                    )
       ,.pul_motor_r_flag    ( pul_motor0_r_flag        )
       ,.cur_slv_board_id    ( 5'd1                     )
       ,.slv_board_id        ( slv_board_id             )
       ,.pul_motor_flag      ( pul_motor0_flag          )
       ,.m2s_pulm_msg        ( pul_motor0_r_msg[1]      )
       ,.s2m_pulm_msg        ( pul_motor0_msg[1]        )
       ,.i_axis_zero          ( ~di_regoin_msg[0][54]    )
       ,.i_axis_limf         ( ~di_regoin_msg[0][53]    )
       ,.i_axis_limb         ( ~di_regoin_msg[0][55]    )
    //    ,.i_quickstop         ( motor_quickstop          )
       ,.i_servo_ready       ( di_regoin_msg[0][29]     )
       ,.i_servo_done        ( ~di_regoin_msg[0][28]    )
	   
       //,.set_wheel_gear      ( 8'b0001_0000             )
       //,.i_wheel_prog        ( man_wheel_prog           )
       //,.i_wheel_run         ( man_wheel_run            )
       //,.i_wheel_dir         ( man_wheel_dir            )
       //,.i_wheel_speed       ( man_wheel_speed          )

    );

	
	
	
	// --- flow_comp_49 -----分拣库_打标机卡盘Y轴
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     (20'd73216)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_49
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[139]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[139]    ),
	  .o_intr_irq            ( map_irq[139]       )
	  
	//   ,.prot_clk            ( clk                      )
    //    ,.prot_rst            ( reset                    )
       ,.pul_motor_r_flag    ( pul_motor1_r_flag        )
       ,.cur_slv_board_id    ( 5'd1                     )
       ,.slv_board_id        ( slv_board_id             )
       ,.pul_motor_flag      ( pul_motor1_flag          )
       ,.m2s_pulm_msg        ( pul_motor1_r_msg[1]      )
       ,.s2m_pulm_msg        ( pul_motor1_msg[1]        )
       ,.i_axis_zero          ( ~di_regoin_msg[0][45]    )
       ,.i_axis_limf         ( ~di_regoin_msg[0][44]    )
       ,.i_axis_limb         ( ~di_regoin_msg[0][46]    )
       //,.i_quickstop         ( motor_quickstop          )
       ,.i_servo_ready       ( di_regoin_msg[0][23]     )
       ,.i_servo_done        ( ~di_regoin_msg[0][22]    )
	   
       //,.set_wheel_gear      ( 8'b0010_0000             )
       //,.i_wheel_prog        ( man_wheel_prog           )
       //,.i_wheel_run         ( man_wheel_run            )
       //,.i_wheel_dir         ( man_wheel_dir            )
       //,.i_wheel_speed       ( man_wheel_speed          )

    );

	
	
	
	// --- flow_comp_50 -----分拣库_打标机倾角轴
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     (20'd73728)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_50
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[140]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[140]    ),
	  .o_intr_irq            ( map_irq[140]       )
	  
	//   ,.prot_clk            ( clk                      )
    //    ,.prot_rst            ( reset                    )
       ,.pul_motor_r_flag    ( pul_motor2_r_flag        )
       ,.cur_slv_board_id    ( 5'd1                     )
       ,.slv_board_id        ( slv_board_id             )
       ,.pul_motor_flag      ( pul_motor2_flag          )
       ,.m2s_pulm_msg        ( pul_motor2_r_msg[1]      )
       ,.s2m_pulm_msg        ( pul_motor2_msg[1]        )
       ,.i_axis_zero          ( ~di_regoin_msg[0][48]    )
       ,.i_axis_limf         ( ~di_regoin_msg[0][47]    )
       ,.i_axis_limb         ( ~di_regoin_msg[0][49]    )
       //,.i_quickstop         ( motor_quickstop          )
       ,.i_servo_ready       ( di_regoin_msg[0][25]     )
       ,.i_servo_done        ( ~di_regoin_msg[0][24]    )
	   
       //,.set_wheel_gear      ( 8'b1000_0000             )
       //,.i_wheel_prog        ( man_wheel_prog           )
       //,.i_wheel_run         ( man_wheel_run            )
       //,.i_wheel_dir         ( man_wheel_dir            )
       //,.i_wheel_speed       ( man_wheel_speed          )

    );

	
	
	
	// --- flow_comp_51 -----分拣库_打标机升降Z轴
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     (20'd74240)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_51
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[141]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[141]    ),
	  .o_intr_irq            ( map_irq[141]       )
	  
	//   ,.prot_clk            ( clk                      )
    //    ,.prot_rst            ( reset                    )
       ,.pul_motor_r_flag    ( pul_motor3_r_flag        )
       ,.cur_slv_board_id    ( 5'd1                     )
       ,.slv_board_id        ( slv_board_id             )
       ,.pul_motor_flag      ( pul_motor3_flag          )
       ,.m2s_pulm_msg        ( pul_motor3_r_msg[1]      )
       ,.s2m_pulm_msg        ( pul_motor3_msg[1]        )
       ,.i_axis_zero          ( ~di_regoin_msg[0][51]    )
       ,.i_axis_limf         ( ~di_regoin_msg[0][50]    )
       ,.i_axis_limb         ( ~di_regoin_msg[0][52]    )
    //    ,.i_quickstop         ( motor_quickstop          )
       ,.i_servo_ready       ( di_regoin_msg[0][27]     )
       ,.i_servo_done        ( ~di_regoin_msg[0][26]    )
	   
       //,.set_wheel_gear      ( 8'b0100_0000             )
       //,.i_wheel_prog        ( man_wheel_prog           )
       //,.i_wheel_run         ( man_wheel_run            )
       //,.i_wheel_dir         ( man_wheel_dir            )
       //,.i_wheel_speed       ( man_wheel_speed          )

    );

	
	
	
	// --- flow_comp_52 -----打标机
    ec_feijie_marker
    #(
         .REG_SPACE_BIAS     (20'd75264)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_feijie_marker_52
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[143]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[143]    ),
	  .o_intr_irq            ( map_irq[143]       )

    );

	
	
	wire   o_dri2_53;
	wire   o_dri1_53;
	// --- flow_comp_53 -----分拣库_打标机卡盘
    ec_2di_3do
    #(
         .REG_SPACE_BIAS     (20'd72192)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_3do_53
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[137]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[137]    ),
	  .o_intr_irq            ( map_irq[137]       )
	  
	  //位置到位开关
	  ,.i_pos			( do_regoin_r_msg[0][25] ? 1'b0 : 1'b1 )
	  //有无感测开关
	  ,.i_poa			( 1'b0 )
	  //单驱动信号
	  ,.o_dri			( 1'b0 )
	  //双驱驱动信号1
	  ,.o_dri1			( o_dri1_53 )
	  //双驱驱动信号2
	  ,.o_dri2			( o_dri2_53 )

    );
	assign do_regoin_r_msg[0][24] = o_dri2_53;
    assign do_regoin_r_msg[0][25] = o_dri1_53;

	
	
	
	// --- flow_comp_55 -----砂轮有无检测传感器
    ec_16di
    #(
         .REG_SPACE_BIAS     (20'd75776)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_16di_54
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[144]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[144]    ),
	  .o_intr_irq            ( map_irq[144]       )
	  
	  ,.i_sign1_check          ( di_mst_msg[36] )
	  ,.i_sign2_check          ( di_mst_msg[35] )
	  ,.i_sign3_check          ( di_mst_msg[61] )
	  ,.i_sign4_check          ( di_mst_msg[60] )
	  ,.i_sign5_check          ( di_mst_msg[59] )
	  ,.i_sign6_check          ( di_mst_msg[58] )
	  ,.i_sign7_check          ( di_mst_msg[57] )
	  ,.i_sign8_check          ( di_mst_msg[56] )
	  ,.i_sign9_check          ( di_mst_msg[10] )
	  ,.i_sign10_check         ( di_mst_msg[9] )
	  ,.i_sign11_check         ( di_mst_msg[8] )
	  ,.i_sign12_check         ( di_mst_msg[7] )
	  ,.i_sign13_check         ( di_mst_msg[6] )
	  ,.i_sign14_check         ( di_mst_msg[5] )
	  ,.i_sign15_check         ( di_mst_msg[4] )
	  ,.i_sign16_check         ( di_mst_msg[3] )  

    );

	
	
	wire   o_led_y_56;
	wire   o_led_r_56;
	wire   o_bz_56;
	wire   o_led_g_56;
	// --- flow_comp_56 -----分拣库_三色灯蜂鸣器
    ec_3led_buzzer
    #(
         .REG_SPACE_BIAS     (20'd74752)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_3led_buzzer_56
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[142]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[142]    ),
	  .o_intr_irq            ( map_irq[142]       )
	  
	   ,.o_led_y        ( o_led_y_56           )
       ,.o_led_r        ( o_led_r_56           )
       ,.o_bz           ( o_bz_56              )
       ,.o_led_g        ( o_led_g_56           )

    );
	assign do_regoin_r_msg[ 0][1]=o_led_y_56;
    assign do_regoin_r_msg[ 0][0]=o_led_r_56;
    assign do_regoin_r_msg[ 0][3]=o_bz_56;
    assign do_regoin_r_msg[ 0][2]=o_led_g_56;

	
	
	
	// --- flow_comp_57 -----分拣库_电子手轮
    ec_pulmotor_handwheel
    #(
         .REG_SPACE_BIAS     (20'd71680)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_pulmotor_handwheel_57
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[136]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[136]    ),
	  .o_intr_irq            ( map_irq[136]       )
	  
	//    ,.i_estop             ( di_regoin_msg[1][42]     )
       ,.i_pulse_a           ( di_regoin_msg[1][43]     )
       ,.i_pulse_b           ( di_regoin_msg[1][44]     )
       ,.i_stp_x1            ( ~di_regoin_msg[1][45]    )
       ,.i_stp_x10           ( ~di_regoin_msg[1][46]    )
       ,.i_stp_x100          ( ~di_regoin_msg[1][47]    )
       ,.i_axis_x            ( ~di_regoin_msg[1][48]    )
       ,.i_axis_y            ( ~di_regoin_msg[1][49]    )
       ,.i_axis_z            ( ~di_regoin_msg[1][50]    )
       ,.i_axis_4            ( ~di_regoin_msg[1][51]    )
       ,.i_axis_5            ( ~di_regoin_msg[1][52]    )
       ,.i_axis_6            ( ~di_regoin_msg[1][53]    )
       ,.i_axis_7            ( ~di_regoin_msg[1][54]    )
	   
    //    ,.o_wheel_prog        ( man_wheel_prog           )
    //    ,.o_wheel_run         ( man_wheel_run            )
    //    ,.o_wheel_dir         ( man_wheel_dir            )
    //    ,.o_wheel_speed       ( man_wheel_speed          )

    );

	
	
	wire   o_dri2_58;
	wire   o_dri1_58;
	// --- flow_comp_58 -----三坐标房清洗机侧自动门
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd58368)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_58
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[110]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[110]    ),
	  .o_intr_irq            ( map_irq[110]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_mst_msg[1]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_mst_msg[2]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_58          )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_58          )

    );
	assign do_mst_msg[9] = o_dri2_58;
    assign do_mst_msg[8] = o_dri1_58;
	
	
	wire   o_dri1_59;
	wire   o_dri2_59;
	// --- flow_comp_59 -----三坐标房地轨侧自动门
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd58880)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_59
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[111]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[111]    ),
	  .o_intr_irq            ( map_irq[111]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_mst_msg[62]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_mst_msg[63]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_59           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_59           )

    );
	assign do_mst_msg[10] = o_dri1_59;
    assign do_mst_msg[11] = o_dri2_59;
	
	
	wire   o_dri1_60;
	wire   o_dri2_60;
	// --- flow_comp_60 -----三坐标房去毛刺机侧自动门
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd59392)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_60
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[112]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[112]    ),
	  .o_intr_irq            ( map_irq[112]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_mst_msg[52]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_mst_msg[53]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_60           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_60           )

    );
	assign do_mst_msg[3] = o_dri1_60;
    assign do_mst_msg[4] = o_dri2_60;

	
	
	
	// --- flow_comp_61 -----主机器人地轨
    ec_can_servo
    #(
         .REG_SPACE_BIAS     (20'd64512)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_can_servo_61
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[122]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[122]    ),
	  .o_intr_irq            ( map_irq[122]       )
	  
	  //,.i_estop             ( 1'b0                     )
       ,.i_axis_zero              ( ~di_mst_msg[15]          )
       ,.i_axis_limb              ( ~di_mst_msg[16]|~di_mst_msg[18] )
       ,.i_axis_limf              ( ~di_mst_msg[14]          )

    );

	
	
	
	// --- flow_comp_62 -----短桁架1
    ec_can_servo
    #(
         .REG_SPACE_BIAS     (20'd60416)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_can_servo_62
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[114]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[114]    ),
	  .o_intr_irq            ( map_irq[114]       )
	  
	  //,.i_estop             ( 1'b0                     )
       ,.i_axis_zero              ( ~di_mst_msg[33]          )
       ,.i_axis_limb              ( ~di_mst_msg[34] )
       ,.i_axis_limf              ( ~di_mst_msg[32]          )

    );

	
	
	
	// --- flow_comp_63 -----长桁架1
    ec_can_servo
    #(
         .REG_SPACE_BIAS     (20'd60928)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_can_servo_63
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[115]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[115]    ),
	  .o_intr_irq            ( map_irq[115]       )
	  
	  //,.i_estop             ( 1'b0                     )
       ,.i_axis_zero             ( ~di_regoin_msg[3][15]          )
       ,.i_axis_limb             ( ~di_regoin_msg[3][16] 		  )
       ,.i_axis_limf             ( ~di_regoin_msg[3][14]          )

    );

	
	
	
	// --- flow_comp_64 -----长桁架2
    ec_can_servo
    #(
         .REG_SPACE_BIAS     (20'd61440)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_can_servo_64
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[116]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[116]    ),
	  .o_intr_irq            ( map_irq[116]       )
	  
	  //,.i_estop             ( 1'b0                     )
       ,.i_axis_zero             ( ~di_regoin_msg[3][18]          )
       ,.i_axis_limb             ( ~di_regoin_msg[3][19] 		  )
       ,.i_axis_limf             ( ~di_regoin_msg[3][17]          )

    );

	
	
	
	// --- flow_comp_66 -----打磨机器人
    ec_fanuc_robot
    #(
         .REG_SPACE_BIAS     (20'd76288)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_fanuc_robot_66
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[145]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[145]    ),
	  .o_intr_irq            ( map_irq[145]       )
	  
	  /*
	  ,.i_quickstop          ( ~di_regoin_msg[2][0]     )
	  ,.i_robot_data         ( ~di_regoin_msg[2][28]    )
	  ,.i_robot_alarm        ( ~di_regoin_msg[2][29]    )
	  ,.i_robot_active       ( ~di_regoin_msg[2][30]    )
	  ,.i_robot_pause        ( ~di_regoin_msg[2][32]    )
	  ,.o_robot_data         (                          )
	  ,.o_robot_estop        ( do_regoin_r_msg[2][32]   )
	  ,.o_robot_pause        ( do_regoin_r_msg[2][33]   )
	  ,.o_robot_filter       ( do_regoin_r_msg[2][34]   )
	  ,.o_robot_reset        ( do_regoin_r_msg[2][35]   )
	  ,.o_robot_pause_start  ( do_regoin_r_msg[2][36]   )
	  ,.o_robot_program      ( do_regoin_r_msg[2][37]   )
	  ,.o_robot_enable       ( do_regoin_r_msg[2][39]   )
      ,.o_robot_init_start   ( do_regoin_r_msg[2][40]   )
	  */

    );

	
	
	wire   o_led_y_67;
	wire   o_bz_67;
	wire   o_led_g_67;
	wire   o_led_r_67;
	// --- flow_comp_67 -----去毛刺机_三色灯蜂鸣器
    ec_3led_buzzer
    #(
         .REG_SPACE_BIAS     (20'd80896)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_3led_buzzer_67
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[154]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[154]    ),
	  .o_intr_irq            ( map_irq[154]       )
	  
	   ,.o_led_y        ( o_led_y_67           )
       ,.o_bz           ( o_bz_67           )
       ,.o_led_g        ( o_led_g_67           )
       ,.o_led_r        ( o_led_r_67           )

    );
	assign do_regoin_r_msg[ 2][1]=o_led_y_67;
    assign do_regoin_r_msg[ 2][3]=o_bz_67;
    assign do_regoin_r_msg[ 2][2]=o_led_g_67;
    assign do_regoin_r_msg[ 2][0]=o_led_r_67;

	
	
	wire   o_dri1_68;
	wire   o_dri2_68;
	// --- flow_comp_68 -----去毛刺卡盘
    ec_2di_3do
    #(
         .REG_SPACE_BIAS     (20'd77312)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_3do_68
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[147]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[147]    ),
	  .o_intr_irq            ( map_irq[147]       )
	  
	  //位置到位开关
	  ,.i_pos			( ~di_regoin_msg[2][51] )
	  //有无感测开关
	  ,.i_poa			( 1'b0 )
	  //单驱动信号
	  ,.o_dri			( 1'b0 )
	  //双驱驱动信号1
	  ,.o_dri1			( o_dri1_68 )
	  //双驱驱动信号2
	  ,.o_dri2			( o_dri2_68 )

    );
	assign do_regoin_r_msg[2][9] = o_dri1_68;
    assign do_regoin_r_msg[2][8] = o_dri2_68;

	
	
	wire   o_dri1_69;
	wire   o_dri2_69;
	// --- flow_comp_69 -----去毛刺机_磨头夹爪
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd76800)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_69
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[146]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[146]    ),
	  .o_intr_irq            ( map_irq[146]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[2][22]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[2][21]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_69           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_69           )

    );
	assign do_regoin_r_msg[2][13] = o_dri1_69;
    assign do_regoin_r_msg[2][12] = o_dri2_69;

	
	
	wire   o_dri1_70;
	wire   o_dri2_70;
	// --- flow_comp_70 -----去毛刺机_自动门
    ec_4di_2do
    #(
         .REG_SPACE_BIAS     (20'd78848)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_4di_2do_70
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[150]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[150]    ),
	  .o_intr_irq            ( map_irq[150]       )
	  
	  ,.i_pos1_1   		     ( di_regoin_msg[2][9] )
	  ,.i_pos1_2			 ( di_regoin_msg[2][11] )
	  ,.i_pos2_1          	 ( di_regoin_msg[2][10] )
	  ,.i_pos2_2			 ( di_regoin_msg[2][12] )
	  ,.o_dri1				 ( o_dri1_70 )
	  ,.o_dri2  			     ( o_dri2_70 )

    );
	assign do_regoin_r_msg[2][11] = o_dri1_70;
    assign do_regoin_r_msg[2][10] = o_dri2_70;
	
	
	
	// --- flow_comp_71 -----毛刺刀架库信号检测组
    ec_16di
    #(
         .REG_SPACE_BIAS     (20'd80384)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_16di_71
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[153]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[153]    ),
	  .o_intr_irq            ( map_irq[153]       )
	  
	  ,.i_sign1_check        ( di_regoin_msg[3][65] )
	  ,.i_sign2_check        ( di_regoin_msg[3][66] )
	  ,.i_sign3_check        ( di_regoin_msg[3][67] )
	  ,.i_sign4_check        ( di_regoin_msg[3][68] )
	  ,.i_sign5_check        ( di_regoin_msg[3][69] )
	  ,.i_sign6_check        ( di_regoin_msg[3][70] )
	  ,.i_sign7_check        ( di_regoin_msg[3][71] )
	  ,.i_sign8_check        ( di_regoin_msg[3][72] )
	  ,.i_sign9_check        ( di_regoin_msg[3][73] )
	  ,.i_sign10_check        ( di_regoin_msg[3][74] )
	  ,.i_sign11_check        ( di_regoin_msg[3][75] )
	  ,.i_sign12_check        ( di_regoin_msg[3][76] )
	  ,.i_sign13_check        ( di_regoin_msg[3][77] )
	  ,.i_sign14_check        ( di_regoin_msg[3][78] )
	  ,.i_sign15_check        ( di_regoin_msg[3][79] )
	  //,.i_sign16_check        (  )
	  
	  //,.i_sign_check        ( di_regoin_msg[3][79:60]         )

    );

	
	
	
	// --- flow_comp_72 -----去毛刺机_旋转台伺服电机
    ec_slv_pul_axis
    #(
         .REG_SPACE_BIAS     (20'd77824)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_slv_pul_axis_72
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[148]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[148]    ),
	  .o_intr_irq            ( map_irq[148]       )
	  
	//   ,.prot_clk            ( clk                      )
    //    ,.prot_rst            ( reset                    )
       ,.pul_motor_r_flag    ( pul_motor2_r_flag        )
       ,.cur_slv_board_id    ( 5'd2                     )
       ,.slv_board_id        ( slv_board_id             )
       ,.pul_motor_flag      ( pul_motor2_flag          )
       ,.m2s_pulm_msg        ( pul_motor2_r_msg[2]      )
       ,.s2m_pulm_msg        ( pul_motor2_msg[2]        )
       ,.i_axis_zero          ( ~di_regoin_msg[2][42]    )
       ,.i_axis_limf         ( 1'b0                     )
       ,.i_axis_limb         ( 1'b0                     )
    //    ,.i_quickstop         ( 1'b0                     )
       ,.i_servo_ready       ( di_regoin_msg[2][43]     )
       ,.i_servo_done        ( ~di_regoin_msg[2][44]    )

    );

	
	
	wire   o_sig_dri_73;
	// --- flow_comp_73 -----去毛刺机_防爆除尘器
    ec_1do
    #(
         .REG_SPACE_BIAS     (20'd79360)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_1do_73
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[151]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[151]    ),
	  .o_intr_irq            ( map_irq[151]       )
				
	 ,.o_sig_dri             ( o_sig_dri_73           )			

    );
	assign do_regoin_r_msg[ 2][29]=o_sig_dri_73;
	
	
	wire   o_sig_dri_74;
	// --- flow_comp_74 -----去毛刺机_水冷机
    ec_1do
    #(
         .REG_SPACE_BIAS     (20'd79872)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_1do_74
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[152]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[152]    ),
	  .o_intr_irq            ( map_irq[152]       )
	  
	  ,.o_sig_dri        ( o_sig_dri_74           )

    );
	assign do_regoin_r_msg[ 2][31]=o_sig_dri_74;


	
	// --- flow_comp_75 -----去毛刺机_磨头旋转电机
    // ec_slv_dv300_485
    // #(
    //      .REG_SPACE_BIAS     (20'd78336)
    //     ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    // )
    // ec_slv_dv300_485_75
    // (
    //   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk               ),
    //   .ps_reg_reset          ( ps_reg_reset             ),
	  
	//   .i_time_1ms_vld        (time_1ms_vld         ),
	//   .i_time_1s_vld         (time_1s_vld          ),

	//   .i_st_wr_en            ( ps_reg_we                ),
	//   .i_st_wr_addr          ( ps_reg_addr              ),
    //   .i_st_wr_data          ( ps_reg_wr_dat            ),
    //   .i_st_rd_en            ( ps_reg_re                ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr           ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[149]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[149]    ),
	//   .o_intr_irq            ( map_irq[149]       )
	  
	//   ,.prot_clk             ( clk                       )
    //   ,.prot_rst             ( reset                     )
	//   ,.rs485_ch_r_flag      ( rs485_00_r_flag          )
    //   ,.cur_slv_board_id     ( 5'd2                      )
    //   ,.slv_board_id         ( slv_board_id              )
    //   ,.rs485_ch_flag        ( rs485_00_flag            )
    //   ,.m2s_rs485_msg        ( rs485_00_send_msg[2]        )
    //   ,.s2m_rs485_msg        ( rs485_00_msg[2]          )

    // );

ec_dv300_485_modbus_rtu
#(
        .REG_SPACE_BIAS         (20'd78336                ), //组件基地址
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
	// --- flow_comp_76 -----短桁架1#机器人夹爪
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd61952)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_76
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[117]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[117]    ),
	  .o_intr_irq            ( map_irq[117]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_mst_msg[12]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_mst_msg[11] | di_mst_msg[13]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_76           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_76           )

    );
	assign do_mst_msg[6] = o_dri1_76;
    assign do_mst_msg[7] = o_dri2_76;
	
	
	wire   o_dri2_77;
	wire   o_dri1_77;
	// --- flow_comp_77 -----长桁架1#机器人夹爪
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd62464)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_77
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[118]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[118]    ),
	  .o_intr_irq            ( map_irq[118]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[3][32]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[3][33] | di_regoin_msg[3][56]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_77           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_77           )

    );
	assign do_regoin_r_msg[3][25] = o_dri2_77;
    assign do_regoin_r_msg[3][24] = o_dri1_77;

	
	
	wire   o_dri1_78;
	wire   o_dri2_78;
	// --- flow_comp_78 -----长桁架2#机器人夹爪
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd62976)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_78
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[119]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[119]    ),
	  .o_intr_irq            ( map_irq[119]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[3][35]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[3][36] | di_regoin_msg[3][57]       )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_78           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_78           )

    );
	assign do_regoin_r_msg[3][26] = o_dri1_78;
    assign do_regoin_r_msg[3][27] = o_dri2_78;

	
	
	
	// --- flow_comp_79 -----固定机器人夹爪物料检测信号
	
	ec_1di
    #(
         .REG_SPACE_BIAS     (20'd59904)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
        //,.P_MODULE_ID        (8'd32                      )
        //,.P_SEAT_NUM         (4'd0                      )
    )
    ec_1di_79
    (
      //.clk                   ( ps_reg_clk               ),
      //.reset                 ( ps_reg_reset             ),
	  //.aurora_clk            ( clk               ),
      //.aurora_reset          ( reset             ),
	  .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[113]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[113]    ),
	  .o_intr_irq            ( map_irq[113]       )

       ,.i_sign1_check        ( di_mst_msg[30]           )
    );
	
	
	wire   o_dri1_80;
	wire   o_dri2_80;
	// --- flow_comp_80 -----6号机床旋转机构
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd84480)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_80
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[161]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[161]    ),
	  .o_intr_irq            ( map_irq[161]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[4][64]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[4][65]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_80           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_80           )

    );
	assign do_regoin_r_msg[4][32] = o_dri1_80;
    assign do_regoin_r_msg[4][33] = o_dri2_80;

	
	
	
	// // --- flow_comp_83 -----长桁架1#夹爪RFID读写器
    // ec_sp_rfid
    // #(
    //      .REG_SPACE_BIAS     (20'd63488)
    //     ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    // )
    // ec_sp_rfid_83
    // (
    //   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk               ),
    //   .ps_reg_reset          ( ps_reg_reset             ),
	  
	//   .i_time_1ms_vld        (time_1ms_vld         ),
	//   .i_time_1s_vld         (time_1s_vld          ),

	//   .i_st_wr_en            ( ps_reg_we                ),
	//   .i_st_wr_addr          ( ps_reg_addr              ),
    //   .i_st_wr_data          ( ps_reg_wr_dat            ),
    //   .i_st_rd_en            ( ps_reg_re                ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr           ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[120]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[120]    ),
	//   .o_intr_irq            ( map_irq[120]       )

    // );

ec_superisys_485_modbus_rtu
#(
        .REG_SPACE_BIAS         (20'd63488                ), //组件基地址
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
  
	
	
	// // --- flow_comp_84 -----长桁架2#夹爪RFID读写器
    // ec_sp_rfid
    // #(
    //      .REG_SPACE_BIAS     (20'd64000)
    //     ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    // )
    // ec_sp_rfid_84
    // (
    //   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk               ),
    //   .ps_reg_reset          ( ps_reg_reset             ),
	  
	//   .i_time_1ms_vld        (time_1ms_vld         ),
	//   .i_time_1s_vld         (time_1s_vld          ),

	//   .i_st_wr_en            ( ps_reg_we                ),
	//   .i_st_wr_addr          ( ps_reg_addr              ),
    //   .i_st_wr_data          ( ps_reg_wr_dat            ),
    //   .i_st_rd_en            ( ps_reg_re                ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr           ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[121]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[121]    ),
	//   .o_intr_irq            ( map_irq[121]       )

    // );

ec_superisys_485_modbus_rtu
#(
        .REG_SPACE_BIAS         (20'd64000                ), //组件基地址
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
  	
	
	
	// --- flow_comp_85 -----1号机床线边托盘检测组
    ec_5di
    #(
         .REG_SPACE_BIAS     (20'd81920)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_5di_85
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[156]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[156]    ),
	  .o_intr_irq            ( map_irq[156]       )
	  
	  ,.i_sign1_check        ( di_regoin_msg[2][45] )
	  ,.i_sign2_check        ( di_regoin_msg[2][46] )
	  ,.i_sign3_check        ( di_regoin_msg[1][17] )
	  ,.i_sign4_check        ( di_regoin_msg[1][16] )
	  ,.i_sign5_check        ( di_regoin_msg[1][18] )

    );

	
	
	
	// --- flow_comp_86 -----2号机床线边托盘检测组
    ec_5di
    #(
         .REG_SPACE_BIAS     (20'd82432)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_5di_86
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[157]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[157]    ),
	  .o_intr_irq            ( map_irq[157]       )
	  
	  ,.i_sign1_check        ( di_regoin_msg[2][47] )
	  ,.i_sign2_check        ( di_regoin_msg[2][48] )
	  ,.i_sign3_check        ( di_regoin_msg[1][20] )
	  ,.i_sign4_check        ( di_regoin_msg[1][19] )
	  ,.i_sign5_check        ( di_regoin_msg[1][21] )
	  
	  

    );

	
	
	
	// --- flow_comp_87 -----3号机床线边托盘检测组
    ec_5di
    #(
         .REG_SPACE_BIAS     (20'd82944)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_5di_87
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[158]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[158]    ),
	  .o_intr_irq            ( map_irq[158]       )
	  
	  ,.i_sign1_check        ( di_regoin_msg[2][49] )
	  ,.i_sign2_check        ( di_regoin_msg[2][50] )
	  ,.i_sign3_check        ( di_regoin_msg[1][22] )
	  ,.i_sign4_check        ( di_regoin_msg[1][23] )
	  ,.i_sign5_check        ( di_regoin_msg[1][24] )

    );

	// --- flow_comp_88 -----4号机床线边托盘检测组
    ec_5di
    #(
         .REG_SPACE_BIAS     (20'd84992)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_5di_88
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[162]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[162]    ),
	  .o_intr_irq            ( map_irq[162]       )
	  
	  ,.i_sign1_check        ( di_regoin_msg[3][23] )
	  ,.i_sign2_check        ( di_regoin_msg[3][24] )
	  ,.i_sign3_check        ( di_regoin_msg[4][28] )
	  ,.i_sign4_check        ( di_regoin_msg[4][30] )
	  ,.i_sign5_check        ( di_regoin_msg[4][29] )

    );

	
	
	
	// --- flow_comp_89 -----5号机床线边托盘检测组
    ec_5di
    #(
         .REG_SPACE_BIAS     (20'd85504)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_5di_89
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[163]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[163]    ),
	  .o_intr_irq            ( map_irq[163]       )
	  
	  ,.i_sign1_check        ( di_regoin_msg[3][25] )
	  ,.i_sign2_check        ( di_regoin_msg[3][26] )
	  ,.i_sign3_check        ( di_regoin_msg[4][31] )
	  ,.i_sign4_check        ( di_regoin_msg[4][32] )
	  ,.i_sign5_check        ( di_regoin_msg[4][33] )

    );

	
	
	
	// --- flow_comp_90 -----6号机床线边托盘检测组
    ec_5di
    #(
         .REG_SPACE_BIAS     (20'd83968)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_5di_90
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[160]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[160]    ),
	  .o_intr_irq            ( map_irq[160]       )
	  
	  ,.i_sign1_check        ( di_regoin_msg[3][27] )
	  ,.i_sign2_check        ( di_regoin_msg[3][28] )
	  ,.i_sign3_check        ( di_regoin_msg[4][43] )
	  ,.i_sign4_check        ( di_regoin_msg[4][45] )
	  ,.i_sign5_check        ( di_regoin_msg[4][44] )

    );

	
	
	
	// --- flow_comp_91 -----7号机床线边托盘检测组
    ec_5di
    #(
         .REG_SPACE_BIAS     (20'd86016)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_5di_91
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[164]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[164]    ),
	  .o_intr_irq            ( map_irq[164]       )
	  
	  ,.i_sign1_check        ( di_regoin_msg[3][29] )
	  ,.i_sign2_check        ( di_regoin_msg[3][30] )
	  ,.i_sign3_check        ( di_regoin_msg[4][34] )
	  ,.i_sign4_check        ( di_regoin_msg[4][35] )
	  ,.i_sign5_check        ( di_regoin_msg[4][36] )

    );

	
	
	
	// --- flow_comp_92 -----8号机床线边托盘检测组
    ec_5di
    #(
         .REG_SPACE_BIAS     (20'd86528)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_5di_92
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[165]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[165]    ),
	  .o_intr_irq            ( map_irq[165]       )
	  
	  ,.i_sign1_check        ( di_regoin_msg[3][31] )
	  ,.i_sign2_check        ( di_regoin_msg[3][44] )
	  ,.i_sign3_check        ( di_regoin_msg[4][37] )
	  ,.i_sign4_check        ( di_regoin_msg[4][38] )
	  ,.i_sign5_check        ( di_regoin_msg[4][39] )

    );

	
	
	
	// --- flow_comp_93 -----9号机床线边托盘检测组
    ec_5di
    #(
         .REG_SPACE_BIAS     (20'd87040)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_5di_93
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[166]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[166]    ),
	  .o_intr_irq            ( map_irq[166]       )
	  
	  ,.i_sign1_check        ( di_regoin_msg[3][46] )
	  ,.i_sign2_check        ( di_regoin_msg[3][45] )
	  ,.i_sign3_check        ( di_regoin_msg[4][40] )
	  ,.i_sign4_check        ( di_regoin_msg[4][41] )
	  ,.i_sign5_check        ( di_regoin_msg[4][42] )

    );

	
	
	wire   o_dri2_94;
	wire   o_dri1_94;
	// --- flow_comp_94 -----机床1顶部围栏自动门
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd87552)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_94
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[167]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[167]    ),
	  .o_intr_irq            ( map_irq[167]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( di_regoin_msg[1][56]          )
	  //位置2到位端口
	  ,.i_pos2				( di_regoin_msg[1][55]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_94           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_94           )

    );
	assign do_regoin_r_msg[1][1] = o_dri2_94;
    assign do_regoin_r_msg[1][0] = o_dri1_94;

	
	
	wire   o_dri2_95;
	wire   o_dri1_95;
	// --- flow_comp_95 -----机床2顶部围栏自动门
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd88064)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_95
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[168]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[168]    ),
	  .o_intr_irq            ( map_irq[168]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( di_regoin_msg[1][58]          )
	  //位置2到位端口
	  ,.i_pos2				( di_regoin_msg[1][57]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_95           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_95           )

    );
	assign do_regoin_r_msg[1][3] = o_dri2_95;
    assign do_regoin_r_msg[1][2] = o_dri1_95;

	
	
	wire   o_dri1_96;
	wire   o_dri2_96;
	// --- flow_comp_96 -----机床3顶部围栏自动门
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd88576)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_96
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[169]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[169]    ),
	  .o_intr_irq            ( map_irq[169]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( di_regoin_msg[1][60]          )
	  //位置2到位端口
	  ,.i_pos2				( di_regoin_msg[1][59]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_96           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_96           )

    );
	assign do_regoin_r_msg[1][4] = o_dri1_96;
    assign do_regoin_r_msg[1][5] = o_dri2_96;

	
	
	wire   o_dri1_97;
	wire   o_dri2_97;
	// --- flow_comp_97 -----机床4顶部围栏自动门
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd89088)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_97
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[170]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[170]    ),
	  .o_intr_irq            ( map_irq[170]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( di_regoin_msg[4][48]          )
	  //位置2到位端口
	  ,.i_pos2				( di_regoin_msg[4][47]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_97          )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_97          )

    );
	assign do_regoin_r_msg[4][7] = o_dri1_97;
    assign do_regoin_r_msg[4][8] = o_dri2_97;
	
	
	wire   o_dri1_98;
	wire   o_dri2_98;
	// --- flow_comp_98 -----机床5顶部围栏自动门
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd89600)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_98
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[171]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[171]    ),
	  .o_intr_irq            ( map_irq[171]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( di_regoin_msg[4][50]          )
	  //位置2到位端口
	  ,.i_pos2				( di_regoin_msg[4][49]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_98           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_98           )

    );
	assign do_regoin_r_msg[4][9] = o_dri1_98;
    assign do_regoin_r_msg[4][10] = o_dri2_98;

	
	
	wire   o_dri1_99;
	wire   o_dri2_99;
	// --- flow_comp_99 -----机床6顶部围栏自动门
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd90112)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_99
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[172]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[172]    ),
	  .o_intr_irq            ( map_irq[172]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( di_regoin_msg[4][52]          )
	  //位置2到位端口
	  ,.i_pos2				( di_regoin_msg[4][51]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_99           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_99           )

    );
	assign do_regoin_r_msg[4][11] = o_dri1_99;
    assign do_regoin_r_msg[4][12] = o_dri2_99;

	
	wire   o_dri2_100;
	wire   o_dri1_100;
	// --- flow_comp_100 -----机床7顶部围栏自动门
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd90624)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_100
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[173]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[173]    ),
	  .o_intr_irq            ( map_irq[173]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( di_regoin_msg[4][54]          )
	  //位置2到位端口
	  ,.i_pos2				( di_regoin_msg[4][53]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_100           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_100           )

    );
	assign do_regoin_r_msg[ 4][14]=o_dri2_100;
    assign do_regoin_r_msg[ 4][13]=o_dri1_100;

	
	
	wire   o_dri2_101;
	wire   o_dri1_101;
	// --- flow_comp_101 -----机床8顶部围栏自动门
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd91136)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_101
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[174]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[174]    ),
	  .o_intr_irq            ( map_irq[174]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( di_regoin_msg[3][20]          )
	  //位置2到位端口
	  ,.i_pos2				( di_regoin_msg[4][55]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_101           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_101           )

    );
	assign do_regoin_r_msg[ 4][16] = o_dri2_101;
    assign do_regoin_r_msg[ 4][15] = o_dri1_101;

	
	
	wire   o_dri1_102;
	wire   o_dri2_102;
	// --- flow_comp_102 -----机床9顶部围栏自动门
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd91648)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_102
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[175]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[175]    ),
	  .o_intr_irq            ( map_irq[175]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( di_regoin_msg[3][22]          )
	  //位置2到位端口
	  ,.i_pos2				( di_regoin_msg[3][21]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_102           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_102           )

    );
	assign do_regoin_r_msg[ 4][17] = o_dri1_102;
    assign do_regoin_r_msg[ 4][18] = o_dri2_102;

	
	
	
	// --- flow_comp_103 -----检测站缓存台托盘检测信号
    ec_5di
    #(
         .REG_SPACE_BIAS     (20'd81408)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_5di_103
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[155]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[155]    ),
	  .o_intr_irq            ( map_irq[155]       )
	  
	  ,.i_sign1_check        ( di_mst_msg[49]          )

    );

	
	
	
	// // --- flow_comp_104 -----分拣库思谷_RFID读写器
    // ec_sg_rfid
    // #(
    //      .REG_SPACE_BIAS     (20'd57344)
    //     ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    // )
    // ec_sg_rfid_104
    // (
    //   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk               ),
    //   .ps_reg_reset          ( ps_reg_reset             ),
	  
	//   .i_time_1ms_vld        (time_1ms_vld         ),
	//   .i_time_1s_vld         (time_1s_vld          ),

	//   .i_st_wr_en            ( ps_reg_we                ),
	//   .i_st_wr_addr          ( ps_reg_addr              ),
    //   .i_st_wr_data          ( ps_reg_wr_dat            ),
    //   .i_st_rd_en            ( ps_reg_re                ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr           ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[108]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[108]    ),
	//   .o_intr_irq            ( map_irq[108]       )

    // );

ec_superisys_485_modbus_rtu
#(
        .REG_SPACE_BIAS         (20'd57344                ), //组件基地址
        .REG_SPACE_SIZE         (`REG_SPACE_SIZE          ), //组件偏移地址
        .CLK_FREQ               (156250000                )  //100MHz = 100000000
)
ec_superisys_485_modbus_rtu_104
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
        .o_st_rd_data           ( sub_comp_rd_dat[108]    ),
        .o_st_rd_vld            ( sub_comp_rd_vld[108]    ),
        .o_intr_irq             ( map_irq[108]            ),//组件中断请求
        
        //--- 主板Uart接口
        .i_uart_rx              ( rs485_1_user_rx[5]      ),
        .o_uart_tx              ( rs485_1_user_tx[5]      ),
        .o_uart_de              ( rs485_1_user_de[5]      ),
        .o_user_req             ( rs485_1_user_req[5]     ),
        .i_user_grant           ( rs485_1_user_grant[5]   ),

         //--- 从板接口 use clk domain 156.25MHz --
        .cur_slv_board_id       ( 0                       ), //
        .slv_board_id           ( 0                       ), 
        .rs485_ch_r_flag        ( 0                       ), //send en
        .m2s_rs485_msg          (                         ), //send data
        .rs485_ch_flag          ( 0                       ), //recv en
        .s2m_rs485_msg          ( 0                       )  //recv data
    );
  
	
	
	wire   o_lock_open_105;
	// --- flow_comp_105 -----A区1#安全门锁
    ec_sf_door
    #(
         .REG_SPACE_BIAS     (20'd93696)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_sf_door_105
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[179]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[179]    ),
	  .o_intr_irq            ( map_irq[179]       )
	  
	  ,.i_open_req_key       ( ~di_regoin_msg[1][27]    )
	  ,.i_close_confirm_key  ( ~di_regoin_msg[3][55]    )
	//   ,.i_door_monitor       ( 1'b1                     )
	  ,.i_lock_monitor       ( ~di_regoin_msg[1][26]    )
	  ,.o_lock_open          ( o_lock_open_105   )
	  //,.o_key_light          (                          )

    );
	assign do_regoin_r_msg[ 1][28] = o_lock_open_105;

	
	
	wire   o_lock_open_106;
	// --- flow_comp_106 -----A区2#安全门锁
    ec_sf_door
    #(
         .REG_SPACE_BIAS     (20'd94208)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_sf_door_106
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[180]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[180]    ),
	  .o_intr_irq            ( map_irq[180]       )
	  
	  
	  ,.i_open_req_key       ( ~di_regoin_msg[1][30]    )
	  ,.i_close_confirm_key  ( ~di_regoin_msg[3][55]    )
	//   ,.i_door_monitor       ( 1'b1                     )
	  ,.i_lock_monitor       ( ~di_regoin_msg[1][29]    )
	  ,.o_lock_open          ( o_lock_open_106   )
	//   ,.o_key_light          (                          )

    );
	assign do_regoin_r_msg[ 1][29] = o_lock_open_106;

	
	
	wire   o_lock_open_107;
	// --- flow_comp_107 -----A区3#安全门锁
    ec_sf_door
    #(
         .REG_SPACE_BIAS     (20'd94720)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_sf_door_107
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[181]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[181]    ),
	  .o_intr_irq            ( map_irq[181]       )
	  
	  ,.i_open_req_key       ( ~di_regoin_msg[1][33]    )
	  ,.i_close_confirm_key  ( ~di_regoin_msg[3][55]    )
	//   ,.i_door_monitor       ( 1'b1                     )
	  ,.i_lock_monitor       ( ~di_regoin_msg[1][32]    )
	  ,.o_lock_open          ( o_lock_open_107  )
	//   ,.o_key_light          (                          )

    );
	assign do_regoin_r_msg[ 1][30] = o_lock_open_107;

	
	
	wire   o_lock_open_108;
	// --- flow_comp_108 -----B区1#安全门锁
    ec_sf_door
    #(
         .REG_SPACE_BIAS     (20'd95232)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_sf_door_108
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[182]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[182]    ),
	  .o_intr_irq            ( map_irq[182]       )
	  
	  ,.i_open_req_key       ( ~di_regoin_msg[3][5]     )
	  ,.i_close_confirm_key  ( ~di_regoin_msg[3][55]    )
	//   ,.i_door_monitor       ( 1'b1                     )
	  ,.i_lock_monitor       ( ~di_regoin_msg[3][4]     )
	  ,.o_lock_open          ( o_lock_open_108    )
	//   ,.o_key_light          (                          )

    );
	assign do_regoin_r_msg[ 4][1] = o_lock_open_108;
	
	
	wire   o_lock_open_109;
	// --- flow_comp_109 -----B区2#安全门锁
    ec_sf_door
    #(
         .REG_SPACE_BIAS     (20'd95744)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_sf_door_109
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[183]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[183]    ),
	  .o_intr_irq            ( map_irq[183]       )
	  
	  ,.i_open_req_key       ( ~di_regoin_msg[3][8]     )
	  ,.i_close_confirm_key  ( ~di_regoin_msg[3][55]    )
	//   ,.i_door_monitor       ( 1'b1                     )
	  ,.i_lock_monitor       ( ~di_regoin_msg[3][7]     )
	  ,.o_lock_open          ( o_lock_open_109    )
	//   ,.o_key_light          (                          )

    );
	assign do_regoin_r_msg[ 4][2] = o_lock_open_109;

	
	
	wire   o_lock_open_110;
	// --- flow_comp_110 -----B区3#安全门锁
    ec_sf_door
    #(
         .REG_SPACE_BIAS     (20'd96256)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_sf_door_110
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[184]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[184]    ),
	  .o_intr_irq            ( map_irq[184]       )
	  
	  ,.i_open_req_key       ( ~di_regoin_msg[3][11]    )
	  ,.i_close_confirm_key  ( ~di_regoin_msg[3][55]    )
	//   ,.i_door_monitor       ( 1'b1                     )
	  ,.i_lock_monitor       ( ~di_regoin_msg[3][10]    )
	  ,.o_lock_open          ( o_lock_open_110    )
	//   ,.o_key_light          (                          )

    );
	assign do_regoin_r_msg[ 4][3] = o_lock_open_110;

	
	
	wire   o_lock_open_111;
	// --- flow_comp_111 -----C区1#安全门锁
    ec_sf_door
    #(
         .REG_SPACE_BIAS     (20'd96768)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_sf_door_111
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[185]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[185]    ),
	  .o_intr_irq            ( map_irq[185]       )
	  
	  ,.i_open_req_key       ( ~di_regoin_msg[3][47]    )
	  ,.i_close_confirm_key  ( ~di_regoin_msg[3][55]    )
	//   ,.i_door_monitor       ( 1'b1                     )
	  ,.i_lock_monitor       ( ~di_regoin_msg[3][13]    )
	  ,.o_lock_open          ( o_lock_open_111    )
	//   ,.o_key_light          (                          )

    );
	assign do_regoin_r_msg[3][4] = o_lock_open_111;
	
	
	wire   o_lock_open_112;
	// --- flow_comp_112 -----C区2#安全门锁
    ec_sf_door
    #(
         .REG_SPACE_BIAS     (20'd97280)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_sf_door_112
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[186]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[186]    ),
	  .o_intr_irq            ( map_irq[186]       )
	  
	  ,.i_open_req_key       ( ~di_regoin_msg[3][50]    )
	  ,.i_close_confirm_key  ( ~di_regoin_msg[3][55]    )
	//   ,.i_door_monitor       ( 1'b1                     )
	  ,.i_lock_monitor       ( ~di_regoin_msg[3][49]    )
	  ,.o_lock_open          ( o_lock_open_112    )
	//   ,.o_key_light          (                          )

    );
	assign do_regoin_r_msg[ 3][5] = o_lock_open_112;
	
	
	wire   o_lock_open_113;
	// --- flow_comp_113 -----C区3#安全门锁
    ec_sf_door
    #(
         .REG_SPACE_BIAS     (20'd97792)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_sf_door_113
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[187]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[187]    ),
	  .o_intr_irq            ( map_irq[187]       )
	  
	  ,.i_open_req_key       ( ~di_regoin_msg[3][53]    )
	  ,.i_close_confirm_key  ( ~di_regoin_msg[3][55]    )
	//   ,.i_door_monitor       ( 1'b1                     )
	  ,.i_lock_monitor       ( ~di_regoin_msg[3][52]    )
	  ,.o_lock_open          ( o_lock_open_113    )
	//   ,.o_key_light          (                          )

    );
	assign do_regoin_r_msg[3][6] = o_lock_open_113;
	
	
	wire   o_lock_open_114;
	// --- flow_comp_114 -----地轨首端安全门锁
    ec_sf_door
    #(
         .REG_SPACE_BIAS     (20'd98304)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_sf_door_114
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[188]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[188]    ),
	  .o_intr_irq            ( map_irq[188]       )
	  
	  ,.i_open_req_key       ( ~di_regoin_msg[1][39]    )
	  ,.i_close_confirm_key  ( ~di_regoin_msg[3][55]    )
	//   ,.i_door_monitor       ( 1'b1                     )
	  ,.i_lock_monitor       ( ~di_regoin_msg[1][38]    )
	  ,.o_lock_open          ( o_lock_open_114   )
	//   ,.o_key_light          (                          )

    );
	assign do_regoin_r_msg[1][32] = o_lock_open_114;
	
	
	wire   o_lock_open_115;
	// --- flow_comp_115 -----地轨尾端安全门锁
    ec_sf_door
    #(
         .REG_SPACE_BIAS     (20'd98816)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_sf_door_115
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[189]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[189]    ),
	  .o_intr_irq            ( map_irq[189]       )
	  
	  ,.i_open_req_key       ( ~di_regoin_msg[1][36]    )
	  ,.i_close_confirm_key  ( ~di_regoin_msg[3][55]    )
	//   ,.i_door_monitor       ( 1'b1                     )
	  ,.i_lock_monitor       ( ~di_regoin_msg[1][35]    )
	  ,.o_lock_open          ( o_lock_open_115   )
	//   ,.o_key_light          (                          )

    );
	assign do_regoin_r_msg[1][31] = o_lock_open_115;

	
	
	wire   o_sig_dri_116;
	// --- flow_comp_116 -----清洗机吹气
    ec_1do
    #(
         .REG_SPACE_BIAS     (20'd57856)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_1do_116
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[109]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[109]    ),
	  .o_intr_irq            ( map_irq[109]       )
	  
	  ,.o_sig_dri            ( o_sig_dri_116 )

    );
	assign do_regoin_r_msg[ 2][7]=o_sig_dri_116;

	
	
	wire   o_bz_118;
	wire   o_led_g_118;
	wire   o_led_y_118;
	wire   o_led_r_118;
	// --- flow_comp_118 -----6号机床_三色灯蜂鸣器
    ec_3led_buzzer
    #(
         .REG_SPACE_BIAS     (20'd83456)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_3led_buzzer_118
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[159]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[159]    ),
	  .o_intr_irq            ( map_irq[159]       )
	  
	   ,.o_bz           ( o_bz_118           )
       ,.o_led_g        ( o_led_g_118           )
       ,.o_led_y        ( o_led_y_118           )
       ,.o_led_r        ( o_led_r_118           )

    );
	assign do_regoin_r_msg[ 3][3]=o_bz_118;
    assign do_regoin_r_msg[ 3][2]=o_led_g_118;
    assign do_regoin_r_msg[ 3][1]=o_led_y_118;
    assign do_regoin_r_msg[ 3][0]=o_led_r_118;

	
	
	/*
	// --- flow_comp_119 -----1序1号机床滑块
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd92160)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_119
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[176]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[176]    ),
	  .o_intr_irq            ( map_irq[176]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[4][1]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[4][2]          )
	  //驱动端口1
	  ,.o_dri1				( do_regoin_r_msg[4][20]           )
	  //驱动端口2
	  ,.o_dri2				( do_regoin_r_msg[4][21]           )

    );

	
	
	
	// --- flow_comp_120 -----1序2号机床滑块
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd92672)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_120
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[177]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[177]    ),
	  .o_intr_irq            ( map_irq[177]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[4][3]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[4][4]          )
	  //驱动端口1
	  ,.o_dri1				( do_regoin_r_msg[4][22]           )
	  //驱动端口2
	  ,.o_dri2				( do_regoin_r_msg[4][23]           )

    );

	
	
	
	// --- flow_comp_121 -----1序3号机床滑块
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd93184)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_121
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[178]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[178]    ),
	  .o_intr_irq            ( map_irq[178]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[4][5]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[4][6]          )
	  //驱动端口1
	  ,.o_dri1				( do_regoin_r_msg[4][24]           )
	  //驱动端口2
	  ,.o_dri2				( do_regoin_r_msg[4][25]           )

    );
*/
	
	
	wire   o_dri1_122;
	wire   o_dri2_122;
	// --- flow_comp_122 -----7号机床旋转机构
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd99328)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_122
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[190]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[190]    ),
	  .o_intr_irq            ( map_irq[190]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[4][66]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[4][67]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_122   )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_122   )

    );
	assign do_regoin_r_msg[4][34] = o_dri1_122;
    assign do_regoin_r_msg[4][35] = o_dri2_122;

	
	
	wire   o_dri2_123;
	wire   o_dri1_123;
	// --- flow_comp_123 -----8号机床旋转机构
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd99840)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_123
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[191]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[191]    ),
	  .o_intr_irq            ( map_irq[191]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[4][68]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[4][69]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_123           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_123           )

    );
	assign do_regoin_r_msg[ 4][37]=o_dri2_123;
    assign do_regoin_r_msg[ 4][36]=o_dri1_123;
	
	
	wire   o_dri1_124;
	wire   o_dri2_124;
	// --- flow_comp_124 -----9号机床旋转机构
    ec_2di_2do
    #(
         .REG_SPACE_BIAS     (20'd100352)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_2di_2do_124
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[192]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[192]    ),
	  .o_intr_irq            ( map_irq[192]       )
	  
	  //位置1到位端口
	  ,.i_pos1				( ~di_regoin_msg[4][70]          )
	  //位置2到位端口
	  ,.i_pos2				( ~di_regoin_msg[4][71]          )
	  //驱动端口1
	  ,.o_dri1				( o_dri1_124           )
	  //驱动端口2
	  ,.o_dri2				( o_dri2_124           )

    );
	assign do_regoin_r_msg[ 4][38] = o_dri1_124;
    assign do_regoin_r_msg[ 4][39] = o_dri2_124;
	
	
	
	// // --- flow_comp_125 -----EMCC60主控板
    // ec_emcc60_board
    // #(
    //      .REG_SPACE_BIAS     (20'd100864)
    //     ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    // )
    // ec_emcc60_board_125
    // (
    //   .clk_i                 ( clk               ),
    //   .rst                   ( reset             ),
	//   .ps_reg_clk            ( ps_reg_clk               ),
    //   .ps_reg_reset          ( ps_reg_reset             ),
	  
	//   .i_time_1ms_vld        (time_1ms_vld         ),
	//   .i_time_1s_vld         (time_1s_vld          ),

	//   .i_st_wr_en            ( ps_reg_we                ),
	//   .i_st_wr_addr          ( ps_reg_addr              ),
    //   .i_st_wr_data          ( ps_reg_wr_dat            ),
    //   .i_st_rd_en            ( ps_reg_re                ),
    //   .i_st_rd_addr          ( ps_reg_rd_addr           ),
	//   .o_st_rd_vld           ( sub_comp_rd_vld[193]    ),
    //   .o_st_rd_data          ( sub_comp_rd_dat[193]    ),
	//   .o_intr_irq            ( map_irq[193]       )

    // );
	
	
	
	// --- flow_comp_134 -----
    ec_s7_plc
    #(
         .REG_SPACE_BIAS     (20'd102912)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_s7_plc_134
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[197]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[197]    ),
	  .o_intr_irq            ( map_irq[197]       )

    );

	
	
	
	// --- flow_comp_135 -----
    ec_s7_plc
    #(
         .REG_SPACE_BIAS     (20'd103424)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_s7_plc_135
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[198]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[198]    ),
	  .o_intr_irq            ( map_irq[198]       )

    );

	
	
	
	// --- flow_comp_136 -----
    ec_s7_plc
    #(
         .REG_SPACE_BIAS     (20'd103936)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_s7_plc_136
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[199]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[199]    ),
	  .o_intr_irq            ( map_irq[199]       )

    );

	
	
	
	// --- flow_comp_137 -----
    ec_s7_plc
    #(
         .REG_SPACE_BIAS     (20'd104448)
        ,.REG_SPACE_SIZE     (`REG_SPACE_SIZE           )
    )
    ec_s7_plc_137
    (
      .clk_i                 ( clk               ),
      .rst                   ( reset             ),
	  .ps_reg_clk            ( ps_reg_clk               ),
      .ps_reg_reset          ( ps_reg_reset             ),
	  
	  .i_time_1ms_vld        (time_1ms_vld         ),
	  .i_time_1s_vld         (time_1s_vld          ),

	  .i_st_wr_en            ( ps_reg_we                ),
	  .i_st_wr_addr          ( ps_reg_addr              ),
      .i_st_wr_data          ( ps_reg_wr_dat            ),
      .i_st_rd_en            ( ps_reg_re                ),
      .i_st_rd_addr          ( ps_reg_rd_addr           ),
	  .o_st_rd_vld           ( sub_comp_rd_vld[200]    ),
      .o_st_rd_data          ( sub_comp_rd_dat[200]    ),
	  .o_intr_irq            ( map_irq[200]       )

    );

	
	
	
	`endif

	
endmodule