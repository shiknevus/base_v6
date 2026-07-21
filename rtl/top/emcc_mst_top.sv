///////////////////////////////////////////////////////////////////////////////
//
//
///////////////////////////////////////////////////////////////////////////////
//
//  AURORA_EXAMPLE
//
//  Aurora Generator
//
//
//  Description: Sample Instantiation of a 1 4-byte lane module.
//               Only tests initialization in hardware.
//
//        
`timescale 1 ns / 1 ps
(* core_generation_info = "aurora_8b10b_0,aurora_8b10b_v11_1_6,{user_interface=AXI_4_Streaming,backchannel_mode=Sidebands,c_aurora_lanes=1,c_column_used=left,c_gt_clock_1=GTHQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=31250,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=125000,c_simplex=false,c_simplex_mode=TX,c_stream=false,c_ufc=false,flow_mode=None,interface_mode=Framing,dataflow_config=Duplex}" *)
(* DowngradeIPIdentifiedWarnings="yes" *)

`include "base_addr.vh"
`include "para_reg_addr.vh"
module emcc_mst_top #
(
    parameter   STATION_ID = 0
)
(
    // User IO
     input          INIT_CLK_P
    ,input          INIT_CLK_N
    // Clocks
    ,input          GT_REFCLK_P
    ,input          GT_REFCLK_N
    // GT I/O
    ,input          RXP_0
    ,input          RXN_0
    ,output         TXP_0
    ,output         TXN_0
    
    // 2nd
    ,input          RXP_1
    ,input          RXN_1
    ,output         TXP_1
    ,output         TXN_1
    
    ,output         led     //systerm status
    ,output         sfp0_disable
    ,output         sfp1_disable
    
    ,inout         MAX31820_DQ    
    
    ,input  wire    rs485_1_rx 
    ,output wire    rs485_1_tx 
    ,output wire    rs485_1_de 
    
    ,input  wire    rs485_2_rx 
    ,output wire    rs485_2_tx 
    ,output wire    rs485_2_de 
    
    ,input  wire [63:0]     main_board_inio
    ,output wire [31:0]     main_board_outio
    ,input  wire [7:0]      i_dv_alarm      //MOTOR
    ,output wire [7:0]      o_dv_pulse
    ,output wire [7:0]      o_dv_dir
    ,output wire [7:0]      o_dv_reset
    ,output wire [7:0]      o_dv_son
    ,output wire            adc_cs          //ADC
    ,input  wire            adc_dout
    ,output wire            adc_sclk
    ,output wire            adc_sdin
    ,input  wire            main_232_rxd
    ,output wire            main_232_txd
);
    wire            HARD_ERR_0;
    wire            SOFT_ERR_0;
    wire            FRAME_ERR_0;
    wire            LANE_UP_0;
    wire            CHANNEL_UP_0;
    wire            GT_RESET_IN;

    wire            HARD_ERR_1;
    wire            SOFT_ERR_1;
    wire            FRAME_ERR_1;
    wire            LANE_UP_1;
    wire            CHANNEL_UP_1;
    wire            aurora_ref_clk;
    wire            aurora_ref_clk_rst;
    wire            rst_aurora_init_clk;
    wire            aurora_init_clk;
    wire            prot_clk;
    reg             prot_clk_rst = 1;
    

    //ps config interface
    localparam  PS_REG_AWIDTH       =   20;
    localparam  PS_REG_DWIDTH       =   32;
    localparam  C_S_AXI_DATA_WIDTH  =   32;
    localparam  C_S_AXI_ADDR_WIDTH  =   PS_REG_AWIDTH;
    localparam  RAM_DEPTH           =   16384; //TX OR RX depot depth 
    localparam  RAM_DWIDTH          =   32;
    localparam  RAM_AWIDTH          =   $clog2(RAM_DEPTH);
    localparam  CHANNEL_NUM         =   3;
    //ps config module AXI4 interface
    wire                                s_axi_aclk;
    wire                                s_axi_aresetn;
    wire    [C_S_AXI_ADDR_WIDTH-1 : 0]  s_axi_awaddr;
    wire    [2 : 0]                     s_axi_awprot;
    wire                                s_axi_awvalid;
    wire                                s_axi_awready;
    wire    [C_S_AXI_DATA_WIDTH-1 : 0]  s_axi_wdata;
    wire    [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb;
    wire                                s_axi_wvalid;
    wire                                s_axi_wready;
    wire    [1 : 0]                     s_axi_bresp;
    wire                                s_axi_bvalid;
    wire                                s_axi_bready;
    wire    [C_S_AXI_ADDR_WIDTH-1 : 0]  s_axi_araddr;
    wire    [2 : 0]                     s_axi_arprot;
    wire                                s_axi_arvalid;
    wire                                s_axi_arready;
    wire    [C_S_AXI_DATA_WIDTH-1 : 0]  s_axi_rdata;
    wire    [1 : 0]                     s_axi_rresp;
    wire                                s_axi_rvalid;
    wire                                s_axi_rready;

    //the AXI INTF of aurora ip 
    wire            axi_clk_0;
    wire            axi_clk_rst_0;
    wire    [0:31]  s_axi_tx_tdata_0;
    wire    [0:3]   s_axi_tx_tkeep_0;
    wire            s_axi_tx_tvalid_0;
    wire            s_axi_tx_tlast_0;
    wire            s_axi_tx_tready_0;
    wire    [0:31]  m_axi_rx_tdata_0;
    wire    [0:3]   m_axi_rx_tkeep_0;
    wire            m_axi_rx_tvalid_0;
    wire            m_axi_rx_tlast_0;

    wire    [0:31]  s_axi_tx_tdata_1;
    wire    [0:3]   s_axi_tx_tkeep_1;
    wire            s_axi_tx_tvalid_1;
    wire            s_axi_tx_tlast_1;
    wire            s_axi_tx_tready_1;
    wire    [0:31]  m_axi_rx_tdata_1;
    wire    [0:3]   m_axi_rx_tkeep_1;
    wire            m_axi_rx_tvalid_1;
    wire            m_axi_rx_tlast_1;

    //the axi interface between master_app AXI_route module
    wire            m_app_tx_tvalid;
    wire            m_app_tx_tready;
    wire    [3:0]   m_app_tx_tkeep;
    wire            m_app_tx_tlast;
    wire    [31:0]  m_app_tx_tdata;
    wire            s_app_rx_tvalid;
    wire    [3:0]   s_app_rx_tkeep;
    wire            s_app_rx_tlast;
    wire    [31:0]  s_app_rx_tdata;

    //protocol layer work flag which is used by PS.
    wire            mst_prcs_hb_flag;//this signal indicate that master station is processing heartbeat.
    //master app to components top
    wire                        slv_cfg_msg_rden;
    wire    [RAM_AWIDTH-1:0]    slv_cfg_msg_addr;
    wire    [RAM_DWIDTH-1:0]    slv_cfg_msg_dat;
    wire    [3:0]               slv_sta_msg_vld;     //slave station status message
    wire    [RAM_AWIDTH-1:0]    slv_sta_msg_addr;
    wire    [RAM_DWIDTH-1:0]    slv_sta_msg_dat;

//  JTAG INTERFACE signals
    reg     [RAM_AWIDTH-1:0]    sta_msg_rd_addr;
    reg     [RAM_DWIDTH-1:0]    sta_msg_rd_dat;
    reg     [RAM_AWIDTH-1:0]    jtag_slv_cfg_msg_addr;
    reg     [RAM_DWIDTH-1:0]    jtag_slv_cfg_msg_dat;

//  PS interface
    //config
    wire                        ps_reg_clk;
    wire                        ps_reg_reset;
    wire                        ps_reg_we;
    wire    [PS_REG_AWIDTH-1:0] ps_reg_addr;
    wire    [PS_REG_DWIDTH-1:0] ps_reg_wr_dat;
    wire                        ps_reg_re;
    wire    [PS_REG_AWIDTH-1:0] ps_reg_rd_addr;
    wire                        ps_reg_rd_vld;
    wire    [PS_REG_DWIDTH-1:0] ps_reg_rd_dat;
    wire                        ds_rd_vld[CHANNEL_NUM-1:0];
    wire    [PS_REG_DWIDTH-1:0] ds_rd_dat[CHANNEL_NUM-1:0];
    wire                        ps_rd_slv_msg;
    wire                        jtag_irq_select;
    wire    [255:0]             jtag_misc_ctrl;
    wire    [511:0]             jtag_irq;
    reg     [511:0]             jtag_irq_d1;
    reg     [511:0]             comp_irq;
    wire    [511:0]             emcc_irq;
    wire    [511:0]             flow_irq;
//    wire    [255:0]             emcc_comp_irq;
    
    //other
    wire    [3:0]               ps_depot_we;
    wire    [RAM_AWIDTH-1:0]    ps_depot_addr;
    wire    [RAM_DWIDTH-1:0]    ps_depot_din;

    wire    [RAM_AWIDTH-1:0]    ps_tx_depot_addr;
    wire    [RAM_DWIDTH-1:0]    ps_tx_depot_dout;
    wire                        rcv_intf_tst_dg_done;//interrupt
    reg                         axi_clk_rst_0_d1;
    reg                         aurora_ip_rst_release;
    wire    [2:0]               stu;
    wire                        clk_10m;

     ///////////////////////////////////////////////////////////////////////
    sys_signal_gen
        sys_signal_gen_u
        (
             .sys_clk_in_p          (INIT_CLK_P         )
            ,.sys_clk_in_n          (INIT_CLK_N         )
            ,.rst_fpga_n            (1'b1                  )
            ,.clk_10m               (clk_10m            )
            ,.aurora_ref_clk        (aurora_ref_clk     )
            ,.aurora_ref_clk_rst    (aurora_ref_clk_rst )
            ,.rst_aurora_init_clk   (rst_aurora_init_clk)
            ,.aurora_init_clk       (aurora_init_clk    )
        );
    assign  GT_RESET_IN = rst_aurora_init_clk;
    assign  prot_clk = axi_clk_0;
    assign led = LANE_UP_1&CHANNEL_UP_1;

    always @(posedge axi_clk_0)begin
        axi_clk_rst_0_d1    <=  axi_clk_rst_0;
    end

    always @(posedge axi_clk_0)begin
        if((~axi_clk_rst_0) & axi_clk_rst_0_d1)begin
            prot_clk_rst    <=  0;
        end else begin
            prot_clk_rst    <=  prot_clk_rst;
        end
    end
    
    wire [31:0] debug_data;
    wire [31:0] uart_debug;
    assign uart_debug = debug_data;

    wire [3:0] dbg_enable;
//    wire main_232_user_rxd;
//    wire main_232_user_txd;
    
//    wire main_232_rxd_n;
//    wire main_232_txd_n;
//    wire main_232_txd_p;
//    assign main_232_user_rxd = dbg_enable ? main_232_rxd :1'b1 ;
//    assign main_232_rxd_n    = dbg_enable ? 1'b1 :main_232_rxd ;
//    assign main_232_txd      = dbg_enable ? main_232_user_txd : main_232_txd_n;
    
//    assign main_232_txd_n = (uart_debug == 1) ? rs485_1_rx : (uart_debug == 2) ? rs485_2_rx : main_232_txd_p;

    reg                mst_io_flag;
    wire [31:0]        mst_io;
    wire [7:0]         i_servo_alarm;
//    wire [63:0]        emcc_main_inio;  
//    wire [31:0]        emcc_main_outio;
    wire [31:0]        emcc_main_inai;
    wire [15:0]        main_board_inai[1:0];
    wire [31:0]      	test_outio_data;
    wire 				test_mode;
    
    wire [15:0] board_temp_82130;
    
    assign  emcc_main_inai = {main_board_inai[1],main_board_inai[0]};
//    assign  main_board_outio = test_mode ? test_outio_data : emcc_main_outio;  //main_board_outio = mst_io_flag ? mst_io : (test_mode ? test_outio_data : emcc_main_outio);
    `ifdef ENB_SIM_MODULE
    
    `else
//    uart_interface uart_interface_u
//    (
//	   .i_clk				(ps_reg_clk          ),
//	   .i_rstn				(~ps_reg_reset       ),
	   
//	   .i_uart_rx           (main_232_rxd_n        ),
//	   .o_uart_tx			(main_232_txd_p        ),
//	   .test_mode_d1		(test_mode           ),
//	   .i_odd_even_check	(2'b00               ),//2'b0x:no check;2'b11:odd check;2'b10:even check;
//	   .i_bps_sel			(2'b00               ),//2'b00:115200bps;
//	   .ai_1                (main_board_inai[0]  ),
//       .ai_2                (main_board_inai[1]  ),
//       .i_data				(main_board_inio     ),
//	   .o_data				(test_outio_data     ),
//	   .io_code_dout		(emcc_main_outio     )
//    );

//    adc_dac adc_dac_u                       
//    (                          
//        .clk10m             (clk_10m            )
//        ,.locked            (1'b1               )
                                  
//        ,.sclk              (adc_sclk           )    
//        ,.sdin1             (adc_sdin           )   
//        ,.sdout1            (adc_dout           )  
//        ,.cs1               (adc_cs             )
//        ,.ch_1              (main_board_inai[0] )         
//        ,.ch_2              (main_board_inai[1] )
//    );
    wire   o_spi_cs_n;
    wire   o_spi_clk ;
    wire   o_spi_mosi;
    wire   i_spi_miso;
    assign adc_cs     = o_spi_cs_n ;
    assign adc_sclk   = o_spi_clk  ;
    assign adc_sdin   = o_spi_mosi ;
    assign i_spi_miso = adc_dout   ;
    

    
//    max31820_driver #(
//    .CLK_FREQUENCE(100)
//    )
//    U_temperature(
//    .clk             (ps_reg_clk        ),
//    .rst_n           (~ps_reg_reset   ),
//    .io_max31820_dq  (MAX31820_DQ    ),
    
//    .ov_t_data          (board_temp_82130         )
//    );
    
    `endif
    wire    [7:0]   slv_sta_num;
    // -------------------------------------------------------------------------------------------------------------------------------------
    wire time_1ms_vld;
    wire time_10ms_vld;
    wire time_100ms_vld;
    wire time_1s_vld;
    counter_xms #(
         .TIME_1MS_TIMER ('d100000)
    )U_counter_xms(
        .clk              ( ps_reg_clk      ),   //Source clock 100MHz
        .rst_n            ( ~ps_reg_reset   ),
        
        .o_time_1ms_vld   ( time_1ms_vld   ),
        .o_time_10ms_vld  ( time_10ms_vld  ),
        .o_time_100ms_vld ( time_100ms_vld ),
        .o_time_1s_vld    ( time_1s_vld    )
    );
    // -------------------------------------------------------------------------------------------------------------------------------------
    
        
localparam DI_BIT_WIDTH = 64;
localparam DO_BIT_WIDTH = 32;
    wire [DI_BIT_WIDTH-1:0]     emcc_main_inio;  
    wire [DO_BIT_WIDTH-1:0]     emcc_main_outio;
    wire [DI_BIT_WIDTH-1:0]     emcc_main_inio_debounce;
    `ifdef IO_DEBUG
    wire DEBUG_UART_RX ;
    wire DEBUG_UART_TX ;
    wire DEBUG_UART_DE ;
    
    wire USER_UART1_RX ;
    wire USER_UART1_TX ;
    wire USER_UART1_DE ;
    wire USER_UART2_RX ;
    wire USER_UART2_TX ;
    wire USER_UART2_DE ;
    wire USER_UART3_RX ;
    wire USER_UART3_TX ;
    wire USER_UART3_DE ;
    
    wire debug_mode;
//    debug_uart_arbitor U_debug_uart_arbitor(
//         .ps_reg_clk        (ps_reg_clk              )
//        ,.ps_reg_reset      (ps_reg_reset            )
//        ,.i_time_1ms_vld    (time_1ms_vld          )
        
////        ,.i_uart1_rx          (rs485_1_rx      )
////        ,.o_uart1_tx          (rs485_1_tx      )
////        ,.o_uart1_de          (rs485_1_de      )
        
////        ,.i_uart2_rx          (rs485_2_rx      )
////        ,.o_uart2_tx          (rs485_2_tx      )
////        ,.o_uart2_de          (rs485_2_de      )
        
//        ,.i_uart3_rx          (main_232_rxd      )
//        ,.o_uart3_tx          (main_232_txd      )
//        ,.o_uart3_de          (      )
        
//        ,.o_debug_uart_rx     ( DEBUG_UART_RX  )
//        ,.i_debug_uart_tx     ( DEBUG_UART_TX  )
//        ,.i_debug_uart_de     ( DEBUG_UART_DE  )
        
        
//        ,.o_user_uart1_rx     ( USER_UART1_RX  )
//        ,.i_user_uart1_tx     ( USER_UART1_TX  )
//        ,.i_user_uart1_de     ( USER_UART1_DE  )
        
//        ,.o_user_uart2_rx     ( USER_UART2_RX  )
//        ,.i_user_uart2_tx     ( USER_UART2_TX  )
//        ,.i_user_uart2_de     ( USER_UART2_DE  )
        
//        ,.o_user_uart3_rx     ( USER_UART3_RX  )
//        ,.i_user_uart3_tx     ( USER_UART3_TX  )
//        ,.i_user_uart3_de     ( USER_UART3_DE  )
        
//        ,.o_debug_mode        (  debug_mode  )
        
//    );
    // ---------------------------------- I/O debug -----------------------------
    wire di_debug;
    wire do_debug;
    wire [DI_BIT_WIDTH-1:0] dbg_main_board_in_io;
    wire [DO_BIT_WIDTH-1:0] dbg_main_board_out_io;
    
    
    
    wire  [RAM_DWIDTH*3-1:0] dbg_iv_di_slv_msg[RAM_DWIDTH-1:0];
    wire  [RAM_DWIDTH*3-1:0] dbg_iv_do_slv_msg[RAM_DWIDTH-1:0];
    wire  [RAM_DWIDTH*3-1:0] dbg_ov_di_slv_msg[RAM_DWIDTH-1:0];
    wire  [RAM_DWIDTH*3-1:0] dbg_ov_do_slv_msg[RAM_DWIDTH-1:0];
    wire  [RAM_DWIDTH-1:0]   dbg_ov_di_debug                  ; 
    wire  [RAM_DWIDTH-1:0]   dbg_ov_do_debug                  ;  
    
    //ebug_send_top U_debug_send_top(
    //    .ps_reg_clk      (ps_reg_clk              )
    //   ,.ps_reg_reset    (ps_reg_reset            )
    //   ,.i_time_1ms_vld    (time_1ms_vld            )
    //   
    //   ,.o_user_req      (     )
    //   ,.i_user_grant    (1'b1   )
    //   ,.i_uart_rx       (DEBUG_UART_RX      )
    //   ,.o_uart_tx       (DEBUG_UART_TX      )
    //   ,.o_uart_de       (DEBUG_UART_DE      )
    //   
    //  ,.o_di_debug        ( di_debug          )
    //  ,.o_do_debug        ( do_debug           )
    //   
    //  ,.iv_do_mst_msg        ( emcc_main_outio          )
    //  ,.iv_di_mst_msg        ( main_board_inio          )
    //  
    //  ,.ov_do_mst_msg        ( dbg_main_board_out_io          )
    //  ,.ov_di_mst_msg        ( dbg_main_board_in_io           )
    //  ,.iv_slv_sta_num       ( slv_sta_num           )
    //  
    //  ,.i_debug_mode         (  debug_mode  )
    //  
    //  ,.iv_di_slv_msg        ( dbg_iv_di_slv_msg  )
    //  ,.iv_do_slv_msg        ( dbg_iv_do_slv_msg  )
    //  ,.ov_di_slv_msg        ( dbg_ov_di_slv_msg  )
    //  ,.ov_do_slv_msg        ( dbg_ov_do_slv_msg  )
    //  ,.ov_di_debug          ( dbg_ov_di_debug    )
    //  ,.ov_do_debug          ( dbg_ov_do_debug    )
    //;
    assign  main_board_outio = do_debug ? dbg_main_board_out_io : emcc_main_outio; 
    assign emcc_main_inio = di_debug ? dbg_main_board_in_io : emcc_main_inio_debounce; 
`else

    assign main_board_outio  =  emcc_main_outio; 
    assign emcc_main_inio    =  emcc_main_inio_debounce; 

`endif
    
    
    
    all_inio_debounce 
    #(
		.IO_NUM                 (8'd72              )
	)
    all_inio_debounce_u1
    (
         .clk                   (prot_clk           )
        ,.reset                 (prot_clk_rst       )
    
        ,.IO_in                 ({i_dv_alarm,main_board_inio}   )
        ,.IO_in_handle          ({i_servo_alarm,emcc_main_inio_debounce} )
    );

    aurora_8b10b_top
        aurora_8b10b_top_u
        (
            // User IO
             .RESET             (rst_aurora_init_clk)
            ,.HARD_ERR_0        (HARD_ERR_0 )
            ,.SOFT_ERR_0        (SOFT_ERR_0 )
            ,.FRAME_ERR_0       (FRAME_ERR_0)

            ,.LANE_UP_0         (LANE_UP_0   )
            ,.CHANNEL_UP_0      (CHANNEL_UP_0)
            ,.INIT_CLK_IN       (aurora_init_clk)
            ,.GT_RESET_IN       (GT_RESET_IN )
            // Clocks
            ,.GT_REFCLK_P       (GT_REFCLK_P)
            ,.GT_REFCLK_N       (GT_REFCLK_N)
            // GT I/O
            ,.RXP_0             (RXP_0      )
            ,.RXN_0             (RXN_0      )
            ,.TXP_0             (TXP_0      )
            ,.TXN_0             (TXN_0      )

            //AXI   INTF
            ,.axi_clk_0         (axi_clk_0          )
            ,.axi_clk_rst_0     (axi_clk_rst_0      )
            ,.s_axi_tx_tdata_0  (s_axi_tx_tdata_0   )
            ,.s_axi_tx_tkeep_0  (s_axi_tx_tkeep_0   )
            ,.s_axi_tx_tvalid_0 (s_axi_tx_tvalid_0  )
            ,.s_axi_tx_tlast_0  (s_axi_tx_tlast_0   )
            ,.s_axi_tx_tready_0 (s_axi_tx_tready_0  )
            //AXI RX
            ,.m_axi_rx_tdata_0  (m_axi_rx_tdata_0   )
            ,.m_axi_rx_tkeep_0  (m_axi_rx_tkeep_0   )
            ,.m_axi_rx_tvalid_0 (m_axi_rx_tvalid_0  )
            ,.m_axi_rx_tlast_0  (m_axi_rx_tlast_0   )

            //AXI TX 2nd  current version is no use
            ,.HARD_ERR_1        (HARD_ERR_1  )
            ,.SOFT_ERR_1        (SOFT_ERR_1  )
            ,.FRAME_ERR_1       (FRAME_ERR_1 )
            ,.LANE_UP_1         (LANE_UP_1   )
            ,.CHANNEL_UP_1      (CHANNEL_UP_1)

            ,.RXP_1             (RXP_1      )
            ,.RXN_1             (RXN_1      )
            ,.TXP_1             (TXP_1      )
            ,.TXN_1             (TXN_1      )

            ,.s_axi_tx_tdata_1  (s_axi_tx_tdata_1 )
            ,.s_axi_tx_tkeep_1  (s_axi_tx_tkeep_1 )
            ,.s_axi_tx_tvalid_1 (s_axi_tx_tvalid_1)
            ,.s_axi_tx_tlast_1  (s_axi_tx_tlast_1 )
            ,.s_axi_tx_tready_1 (s_axi_tx_tready_1)
            ,.m_axi_rx_tdata_1  (m_axi_rx_tdata_1 )
            ,.m_axi_rx_tkeep_1  (m_axi_rx_tkeep_1 )
            ,.m_axi_rx_tvalid_1 (m_axi_rx_tvalid_1)
            ,.m_axi_rx_tlast_1  (m_axi_rx_tlast_1 )
        );
    assign  sfp0_disable = 1;
    assign  sfp1_disable = 1;
		
	ethcat_axi_rout ethcat_axi_rout_u
    (
         .clk                   (prot_clk       )
        ,.rst                   (prot_clk_rst   )
        ,.downstream_lane_up    (LANE_UP_0 &  CHANNEL_UP_0)//assert level base on heartbeat result downstream_lane_up-->LANE_UP_1 &  CHANNEL_UP_1
        ,.downstream_link       (LANE_UP_1 &  CHANNEL_UP_1)
        ,.stu			        (stu	        )
        //from app interface
        ,.s_app_tx_tvalid       (m_app_tx_tvalid)
        ,.s_app_tx_tready       (m_app_tx_tready)
        ,.s_app_tx_tkeep        (m_app_tx_tkeep )
        ,.s_app_tx_tlast        (m_app_tx_tlast )
        ,.s_app_tx_tdata        (m_app_tx_tdata )

        ,.m_app_rx_tvalid       (s_app_rx_tvalid)
        ,.m_app_rx_tkeep        (s_app_rx_tkeep )
        ,.m_app_rx_tlast        (s_app_rx_tlast )
        ,.m_app_rx_tdata        (s_app_rx_tdata )
        //AXI INTF  upstream
        ,.m_axi_tx_tdata_0      (s_axi_tx_tdata_0   )
        ,.m_axi_tx_tkeep_0      (s_axi_tx_tkeep_0   )
        ,.m_axi_tx_tvalid_0     (s_axi_tx_tvalid_0  )
        ,.m_axi_tx_tlast_0      (s_axi_tx_tlast_0   )
        ,.m_axi_tx_tready_0     (s_axi_tx_tready_0  )
        ,.s_axi_rx_tdata_0      (m_axi_rx_tdata_0   )
        ,.s_axi_rx_tkeep_0      (m_axi_rx_tkeep_0   )
        ,.s_axi_rx_tvalid_0     (m_axi_rx_tvalid_0  )
        ,.s_axi_rx_tlast_0      (m_axi_rx_tlast_0   )

        //AXI INTF downstream
        ,.m_axi_tx_tdata_1      (s_axi_tx_tdata_1   )
        ,.m_axi_tx_tkeep_1      (s_axi_tx_tkeep_1   )
        ,.m_axi_tx_tvalid_1     (s_axi_tx_tvalid_1  )
        ,.m_axi_tx_tlast_1      (s_axi_tx_tlast_1   )
        ,.m_axi_tx_tready_1     (s_axi_tx_tready_1  )
        ,.s_axi_rx_tdata_1      (m_axi_rx_tdata_1   )
        ,.s_axi_rx_tkeep_1      (m_axi_rx_tkeep_1   )
        ,.s_axi_rx_tvalid_1     (m_axi_rx_tvalid_1  )
        ,.s_axi_rx_tlast_1      (m_axi_rx_tlast_1   )
    );	

    `ifdef SIM_PLATFORM_MST
        always @(posedge prot_clk)begin
            if(prot_clk_rst)begin
                sta_msg_rd_addr <=  'd0;
            end else if(sta_msg_rd_addr ==  'd2047)begin
                sta_msg_rd_addr <=  'd0;
            end else begin
                sta_msg_rd_addr <=  sta_msg_rd_addr + 'd1;
            end
        end

        always @(posedge prot_clk)begin
            jtag_slv_cfg_msg_addr <=  32'h0000_0201;
            jtag_slv_cfg_msg_dat  <=  32'hffff_ffff;
        end
        
    `else
        wire    [31:0]  vio_ram_rd_addr;
        reg     [31:0]  vio_ram_rd_addr_d1;

        reg     [31:0]  vio_ram_rd_data;
        reg     [31:0]  vio_ram_rd_data_d1;
        
//        wire [31:0] uart_debug;
        wire    [31:0]  vio_ram_wr_addr;
        wire    [31:0]  vio_ram_wr_data;
        reg     [31:0]  vio_ram_wr_addr_d1;
        reg     [31:0]  vio_ram_wr_data_d1;

        assign  jtag_irq_select = jtag_misc_ctrl[0];
        
        always @(posedge prot_clk)begin
            jtag_irq_d1 <=  jtag_irq;
        end

        always @(posedge prot_clk)begin
            vio_ram_rd_addr_d1  <=  vio_ram_rd_addr;
            sta_msg_rd_addr     <=  vio_ram_rd_addr_d1;
        end
        
        always @(posedge prot_clk)begin
            if((sta_msg_rd_addr == slv_sta_msg_addr) &  slv_sta_msg_vld)begin
                sta_msg_rd_dat  <=  slv_sta_msg_dat;
            end else begin
                sta_msg_rd_dat  <=  sta_msg_rd_dat;
            end
        end
        
        always @(posedge prot_clk)begin
            vio_ram_rd_data     <=  sta_msg_rd_dat;
            vio_ram_rd_data_d1  <=  vio_ram_rd_data;
        end
        
        always @(posedge prot_clk)begin
            vio_ram_wr_addr_d1  <=  vio_ram_wr_addr;
            jtag_slv_cfg_msg_addr     <=  vio_ram_wr_addr_d1;

            vio_ram_wr_data_d1  <=  vio_ram_wr_data;
            jtag_slv_cfg_msg_dat      <=  vio_ram_wr_data_d1;
        end
    `endif

    localparam RS485_1_USER_NUMBER = 16;
    wire [RS485_1_USER_NUMBER-1:0] rs485_1_user_req;
    wire [RS485_1_USER_NUMBER-1:0] rs485_1_user_grant;
    wire [RS485_1_USER_NUMBER-1:0] rs485_1_user_tx;
    wire [RS485_1_USER_NUMBER-1:0] rs485_1_user_rx;
    wire [RS485_1_USER_NUMBER-1:0] rs485_1_user_de;
    RS485_Arbiter #(
             .USER_NUMBER     (RS485_1_USER_NUMBER      )
        )U_RS485_Arbiter_1(
          .clk                   ( ps_reg_clk        ),
          .reset                 ( ps_reg_reset      ),
          
          .o_uart_tx             (rs485_1_tx        ),
          .i_uart_rx             (rs485_1_rx        ),
          .o_uart_de             (rs485_1_de        ),
          
          .i_user_req            (rs485_1_user_req       ),
          .o_user_grant          (rs485_1_user_grant     ),
          .i_user_tx             (rs485_1_user_tx        ),
          .o_user_rx             (rs485_1_user_rx        ),
          .i_user_de             (rs485_1_user_de        )
    );



    localparam RS485_2_USER_NUMBER =16;
    wire [RS485_2_USER_NUMBER-1:0] rs485_2_user_req;
    wire [RS485_2_USER_NUMBER-1:0] rs485_2_user_grant;
    wire [RS485_2_USER_NUMBER-1:0] rs485_2_user_tx;
    wire [RS485_2_USER_NUMBER-1:0] rs485_2_user_rx;
    wire [RS485_2_USER_NUMBER-1:0] rs485_2_user_de;
    RS485_Arbiter #(
             .USER_NUMBER     (RS485_2_USER_NUMBER      )
        )U_RS485_Arbiter_2(
          .clk                   ( ps_reg_clk        ),
          .reset                 ( ps_reg_reset      ),
          
          .o_uart_tx             (rs485_2_tx        ),
          .i_uart_rx             (rs485_2_rx        ),
          .o_uart_de             (rs485_2_de        ),
          
          .i_user_req            (rs485_2_user_req       ),
          .o_user_grant          (rs485_2_user_grant     ),
          .i_user_tx             (rs485_2_user_tx        ),
          .o_user_rx             (rs485_2_user_rx        ),
          .i_user_de             (rs485_2_user_de        )
    );

    wire        wr_cfg_data_done;
    wire        read_dbg_data_done;
    wire        do_dbg_data_vld;
    wire [31:0] io_mode_cfg  ;
    wire [31:0] inout_io_data;
    wire [31:0] do_dbg_data  ;


    wire                        comp_reg_rd_vld;
    wire    [PS_REG_DWIDTH-1:0] comp_reg_rd_dat;
    wire                        flow_reg_rd_vld;
    wire    [PS_REG_DWIDTH-1:0] flow_reg_rd_dat;
    
    
//ila_0 ila (
//	.clk(ps_reg_clk), // input wire clk
//	.probe0({rs485_1_rx,rs485_1_tx,rs485_1_de,rs485_2_rx,rs485_2_tx,rs485_2_de})
//);          

    `ifdef SIM_PLATFORM_MST
    emcc_mix_top
    #(
         .PS_REG_AWIDTH     (PS_REG_AWIDTH  )
        ,.PS_REG_DWIDTH     (PS_REG_DWIDTH  )
        ,.RAM_DEPTH         (RAM_DEPTH      )
        ,.RAM_DWIDTH        (RAM_DWIDTH     )
    )
        emcc_mix_top_u
        (
             .clk                       (prot_clk        )
            ,.reset                     (prot_clk_rst    )

            ,.di_mst_msg                (main_board_inio )
            ,.do_relay_mst_msg          (main_board_outio)

       //component interface
            ,.slv_cfg_msg_rden  (slv_cfg_msg_rden   )
            ,.slv_cfg_msg_addr   (slv_cfg_msg_addr    )
            ,.slv_cfg_msg_dat    (slv_cfg_msg_dat     )

            //read back to master component
            ,.slv_sta_msg_vld   (slv_sta_msg_vld    )  //slave station status message
            ,.slv_sta_msg_addr  (slv_sta_msg_addr   )
            ,.slv_sta_msg_dat   (slv_sta_msg_dat    )
        //  ps interface
            //reg cfg interface
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_comp_rd_vld            (comp_reg_rd_vld )
            ,.ps_comp_rd_dat            (comp_reg_rd_dat )
            ,.ps_flow_rd_vld            (flow_reg_rd_vld )
            ,.ps_flow_rd_dat            (flow_reg_rd_dat )
            ,.emcc_irq                  (emcc_irq        )
            ,.flow_irq                  (flow_irq        )
        );
    `else
        emcc_mix_top
        #(
             .PS_REG_AWIDTH     (PS_REG_AWIDTH  )
            ,.PS_REG_DWIDTH     (PS_REG_DWIDTH  )
            ,.RAM_DEPTH         (RAM_DEPTH      )
            ,.RAM_DWIDTH        (RAM_DWIDTH     )
            ,.RS485_1_USER_NUMBER (RS485_1_USER_NUMBER     )
            ,.RS485_2_USER_NUMBER (RS485_2_USER_NUMBER     )
        )
        emcc_mix_top_u
        (
             .clk                   (prot_clk           )
            ,.reset                 (prot_clk_rst       )
            ,.clk_10m               (clk_10m            )
            //main_IO interface
            ,.di_mst_msg            (emcc_main_inio     )
            ,.do_relay_mst_msg      (emcc_main_outio    )
            ,.ai_mst_msg            (emcc_main_inai     )
//            ,.di_board_io           (main_board_inio     )

            //component interface
            ,.slv_cfg_msg_rden      (slv_cfg_msg_rden   )
            ,.slv_cfg_msg_addr      (slv_cfg_msg_addr   )
            ,.slv_cfg_msg_dat       (slv_cfg_msg_dat    )

            //read back to master component
            ,.slv_sta_msg_vld       (slv_sta_msg_vld    )  //slave station status message
            ,.slv_sta_msg_addr      (slv_sta_msg_addr   )
            ,.slv_sta_msg_dat       (slv_sta_msg_dat    )
            // ps interface
            //reg cfg interface
            ,.ps_reg_clk            (ps_reg_clk         )
            ,.ps_reg_reset          (ps_reg_reset       )
            ,.ps_reg_we             (ps_reg_we          )
            ,.ps_reg_addr           (ps_reg_addr        )
            ,.ps_reg_wr_dat         (ps_reg_wr_dat      )
            ,.ps_reg_re             (ps_reg_re          )
            ,.ps_reg_rd_addr        (ps_reg_rd_addr     )
            ,.ps_flow_rd_vld        (flow_reg_rd_vld    )
            ,.ps_flow_rd_dat        (flow_reg_rd_dat    )
            ,.ps_comp_rd_vld        (comp_reg_rd_vld    )
            ,.ps_comp_rd_dat        (comp_reg_rd_dat    )

            //reg cfg interrupt
            ,.emcc_irq         (emcc_irq      )
            ,.flow_irq         (flow_irq      )
//            ,.emcc_comp_irq         (emcc_comp_irq      )
            
            ,.ov_dbg_enable     (dbg_enable      )
            ,.i_do_dbg_data_vld     (do_dbg_data_vld      )
            ,.iv_io_mode_cfg        (io_mode_cfg          )
            ,.ov_rd_io_data         (inout_io_data        )
            ,.iv_do_dbg_data        (do_dbg_data          )
            ,.i_wr_cfg_data_done    (wr_cfg_data_done     )
            
           ,.rs485_1_user_req       (rs485_1_user_req    )                  //rs485_1_user_req   
           ,.rs485_1_user_grant     (rs485_1_user_grant  )                  //rs485_1_user_grant 
           ,.rs485_1_user_tx        (rs485_1_user_tx     )
           ,.rs485_1_user_rx        (rs485_1_user_rx     )
           ,.rs485_1_user_de        (rs485_1_user_de     )
           
           
           
           ,.rs485_2_user_req       (rs485_2_user_req    )
           ,.rs485_2_user_grant     (rs485_2_user_grant  )
           ,.rs485_2_user_tx        (rs485_2_user_tx     )
           ,.rs485_2_user_rx        (rs485_2_user_rx     )
           ,.rs485_2_user_de        (rs485_2_user_de     )

           
           ,.main_232_rxd           (USER_UART3_RX      )
           ,.main_232_txd           (USER_UART3_TX      )
           
           ,.i_time_1ms_vld        (time_1ms_vld     )
           ,.i_time_10ms_vld       (time_10ms_vld    )
           ,.i_time_100ms_vld      (time_100ms_vld   )
           ,.i_time_1s_vld         (time_1s_vld      )
           
            ,.i_dv_alarm            (i_servo_alarm      )
            ,.o_dv_pulse            (o_dv_pulse         )
            ,.o_dv_dir              (o_dv_dir           )
            ,.o_dv_reset            (o_dv_reset         )
            ,.o_dv_son              (o_dv_son           )
            
            // spi interface
            ,.o_spi_cs_n  ( o_spi_cs_n )
            ,.o_spi_clk   ( o_spi_clk  )
            ,.o_spi_mosi  ( o_spi_mosi )
            ,.i_spi_miso  ( i_spi_miso )
            
            //	,.ov_di_slv_msg        ( dbg_iv_di_slv_msg  )
            //	,.ov_do_slv_msg        ( dbg_iv_do_slv_msg  )
            //	,.iv_di_slv_msg        ( dbg_ov_di_slv_msg  )
            //	,.iv_do_slv_msg        ( dbg_ov_do_slv_msg  )
            //	,.iv_di_debug          ( dbg_ov_di_debug    )
            //	,.iv_do_debug          ( dbg_ov_do_debug    )
			
			,.ov_di_slv_msg        (   )
            ,.ov_do_slv_msg        (   )
            ,.iv_di_slv_msg        (   )
            ,.iv_do_slv_msg        (   )
            ,.iv_di_debug          (   )
            ,.iv_do_debug          (   )
       
        );
    `endif

    /*always @(posedge prot_clk)begin
        if(jtag_irq_select)begin
            comp_irq    <=  jtag_irq_d1;
        end else begin
            comp_irq[255:0]   <=  emcc_flow_irq;
            comp_irq[511:256] <=  emcc_comp_irq;
        end
    end*/
    
    always @(posedge ps_reg_clk)begin
        comp_irq[511:0] <= {flow_irq[511],emcc_irq[510:0]};
//        comp_irq[511:256] <= emcc_comp_irq;
    end

    wire                        app_reg_rd_vld;
    wire    [PS_REG_DWIDTH-1:0] app_reg_rd_dat;
    emcc_mst_app
    #(
         .PS_REG_AWIDTH (PS_REG_AWIDTH  )
        ,. PS_REG_DWIDTH(PS_REG_DWIDTH  )
        ,.RAM_DEPTH     (RAM_DEPTH      )
        ,.RAM_DWIDTH    (RAM_DWIDTH     )
    )
        emcc_mst_app_u
        (
             .clk               (prot_clk     )
            ,.reset             (prot_clk_rst )
    
            ,.link_success      ((LANE_UP_0 &  CHANNEL_UP_0)|(CHANNEL_UP_1 & LANE_UP_1))
            ,.loop_link_success (1            )
			,.downstream_lane_up(LANE_UP_0 &  CHANNEL_UP_0)
			,.downstream_link   (LANE_UP_1 &  CHANNEL_UP_1)
            ,.mst_prcs_hb_flag  (mst_prcs_hb_flag)
            ,.stu				(stu	       )

       //component interface
            ,.slv_cfg_msg_rden  (slv_cfg_msg_rden   )
            ,.slv_cfg_msg_addr  (slv_cfg_msg_addr   )
            ,.slv_cfg_msg_dat   (slv_cfg_msg_dat    )

            //read back to master component
            ,.slv_sta_msg_vld   (slv_sta_msg_vld    )  //slave station status message
            ,.slv_sta_msg_addr  (slv_sta_msg_addr   )
            ,.slv_sta_msg_dat   (slv_sta_msg_dat    )
//------PS signals--------//
            //ps rx depot
            ,.rcv_intf_tst_dg_done  (rcv_intf_tst_dg_done   )
            ,.ps_depot_we       (ps_depot_we        )
            ,.ps_depot_addr     (ps_depot_addr      )
            ,.ps_depot_din      (ps_depot_din       )
            //ps tx depot
            ,.ps_tx_depot_addr  (ps_tx_depot_addr   )
            ,.ps_tx_depot_dout  (ps_tx_depot_dout   )
			,.debug_data (debug_data   )
        //  ps  config  port    //
            ,.ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (app_reg_rd_vld )
            ,.ps_reg_rd_dat             (app_reg_rd_dat )

            //master AXI interface to aurora IP:send port
            ,.m_boroa_tx_tvalid (m_app_tx_tvalid)
            ,.m_boroa_tx_tready (m_app_tx_tready)
            ,.m_boroa_tx_tkeep  (m_app_tx_tkeep)
            ,.m_boroa_tx_tlast  (m_app_tx_tlast)
            ,.m_boroa_tx_tdata  (m_app_tx_tdata)

            //slave AXI receive interface
            ,.s_aurora_rx_tvalid(s_app_rx_tvalid)
            ,.s_aurora_rx_tkeep (s_app_rx_tkeep )
            ,.s_aurora_rx_tlast (s_app_rx_tlast )
            ,.s_aurora_rx_tdata (s_app_rx_tdata )
            
            ,.board_temp_82130  (board_temp_82130   )
            
            ,.o_do_dbg_data_vld  (do_dbg_data_vld      )
            ,.ov_io_mode_cfg     (io_mode_cfg          )
            ,.iv_rd_io_data      (inout_io_data        )
            ,.ov_do_dbg_data     (do_dbg_data          )
            ,.o_read_dbg_data_done(read_dbg_data_done          )
            ,.o_wr_cfg_data_done(wr_cfg_data_done          )

//---JTAG interface---//
            ,.jtag_slv_cfg_msg_addr (jtag_slv_cfg_msg_addr  )
            ,.jtag_slv_cfg_msg_dat  (jtag_slv_cfg_msg_dat   )
//            ,.slv_sta_num  (slv_sta_num   )
        );

    ps_rd_dat_route
    #(
         .CHANNEL_NUM       (CHANNEL_NUM    )
        ,.PS_REG_DWIDTH     (PS_REG_DWIDTH  )
    )
        ps_rd_dat_route_u
        (
             .ps_reg_clk        (ps_reg_clk     )
            ,.ps_reg_reset      (ps_reg_reset   )
            ,.ps_reg_rd_vld     (ps_reg_rd_vld  )
            ,.ps_reg_rd_dat     (ps_reg_rd_dat  )

            ,.ds_rd_vld         (ds_rd_vld      )
            ,.ds_rd_dat         (ds_rd_dat      )
        );
    assign  ds_rd_vld[0] = comp_reg_rd_vld;
    assign  ds_rd_dat[0] = comp_reg_rd_dat;
    assign  ds_rd_vld[1] = app_reg_rd_vld;
    assign  ds_rd_dat[1] = app_reg_rd_dat;
    assign  ds_rd_vld[2] = flow_reg_rd_vld;
    assign  ds_rd_dat[2] = flow_reg_rd_dat;

    ps_cfg_top
    #(
         .OPT_MEM_ADDR_BITS     (PS_REG_AWIDTH      )
        ,.C_S_AXI_DATA_WIDTH    (C_S_AXI_DATA_WIDTH )
        ,.C_S_AXI_ADDR_WIDTH    (C_S_AXI_ADDR_WIDTH )
    )
        ps_cfg_top_u
        (
            // Users to add ports here
             .ps_reg_clk                (ps_reg_clk     )
            ,.ps_reg_reset              (ps_reg_reset   )
            ,.ps_reg_we                 (ps_reg_we     )
            ,.ps_reg_addr               (ps_reg_addr   )
            ,.ps_reg_wr_dat             (ps_reg_wr_dat )
            ,.ps_reg_re                 (ps_reg_re     )
            ,.ps_reg_rd_addr            (ps_reg_rd_addr)
            ,.ps_reg_rd_vld             (ps_reg_rd_vld )
            ,.ps_reg_rd_dat             (ps_reg_rd_dat )

            // User ports ends
            // Ports of Axi Slave Bus Interface S_AXI
            ,.s_axi_aclk    (s_axi_aclk     )
            ,.s_axi_aresetn (s_axi_aresetn  )
            ,.s_axi_awaddr  (s_axi_awaddr   )
            ,.s_axi_awprot  (s_axi_awprot   )
            ,.s_axi_awvalid (s_axi_awvalid  )
            ,.s_axi_awready (s_axi_awready  )
            ,.s_axi_wdata   (s_axi_wdata    )
            ,.s_axi_wstrb   (s_axi_wstrb    )
            ,.s_axi_wvalid  (s_axi_wvalid   )
            ,.s_axi_wready  (s_axi_wready   )
            ,.s_axi_bresp   (s_axi_bresp    )
            ,.s_axi_bvalid  (s_axi_bvalid   )
            ,.s_axi_bready  (s_axi_bready   )
            ,.s_axi_araddr  (s_axi_araddr   )
            ,.s_axi_arprot  (s_axi_arprot   )
            ,.s_axi_arvalid (s_axi_arvalid  )
            ,.s_axi_arready (s_axi_arready  )
            ,.s_axi_rdata   (s_axi_rdata    )
            ,.s_axi_rresp   (s_axi_rresp    )
            ,.s_axi_rvalid  (s_axi_rvalid   )
            ,.s_axi_rready  (s_axi_rready   )
        );
////////////////////////////////////////PS  MODULE//////////////////////////////
  wire [7:0]GPIO_tri_i;
  wire [7:0]GPIO_tri_o;
  wire [7:0]GPIO_tri_t;
  wire [127:0]I_INTR_IRQ_0;
  wire [127:0]I_INTR_IRQ_1;
  wire [127:0]I_INTR_IRQ_2;
  wire [127:0]I_INTR_IRQ_3;

  wire [31:0]PLCFG_M_AXI_araddr;
  wire [2:0]PLCFG_M_AXI_arprot;
  wire PLCFG_M_AXI_arready;
  wire PLCFG_M_AXI_arvalid;
  wire [31:0]PLCFG_M_AXI_awaddr;
  wire [2:0]PLCFG_M_AXI_awprot;
  wire PLCFG_M_AXI_awready;
  wire PLCFG_M_AXI_awvalid;
  wire PLCFG_M_AXI_bready;
  wire [1:0]PLCFG_M_AXI_bresp;
  wire PLCFG_M_AXI_bvalid;
  wire [31:0]PLCFG_M_AXI_rdata;
  wire PLCFG_M_AXI_rready;
  wire [1:0]PLCFG_M_AXI_rresp;
  wire PLCFG_M_AXI_rvalid;
  wire [31:0]PLCFG_M_AXI_wdata;
  wire PLCFG_M_AXI_wready;
  wire [3:0]PLCFG_M_AXI_wstrb;
  wire PLCFG_M_AXI_wvalid;
  wire PLCLK;
  wire PLRESETN;
  wire [31:0]RX_BRAM_PORTB_addr;
  wire RX_BRAM_PORTB_clk;
  wire [31:0]RX_BRAM_PORTB_din;
  wire [31:0]RX_BRAM_PORTB_dout;
  wire RX_BRAM_PORTB_en;
  wire RX_BRAM_PORTB_rst;
  wire [3:0]RX_BRAM_PORTB_we;
  wire [31:0]TX_BRAM_PORTB_addr;
  wire TX_BRAM_PORTB_clk;
  wire [31:0]TX_BRAM_PORTB_din;
  wire [31:0]TX_BRAM_PORTB_dout;
  wire TX_BRAM_PORTB_en;
  wire TX_BRAM_PORTB_rst;
  wire [3:0]TX_BRAM_PORTB_we;
  wire [0:0]AXI_GPIO_tri_i_0;
  wire [0:0]AXI_GPIO_tri_o_0;
  wire [0:0]AXI_GPIO_tri_t_0;

  mststa_mpsoc_v2 mststa_mpsoc_u
       (
        .GPIO_tri_i(GPIO_tri_i),
        .GPIO_tri_o(GPIO_tri_o),
        .GPIO_tri_t(GPIO_tri_t),
        .I_INTR_IRQ_0(I_INTR_IRQ_0),
        .I_INTR_IRQ_1(I_INTR_IRQ_1),
        .I_INTR_IRQ_2(I_INTR_IRQ_2),
        .I_INTR_IRQ_3(I_INTR_IRQ_3),
        .I_INTR_IRQ_4(I_INTR_IRQ_4),
        .PLCFG_M_AXI_araddr(PLCFG_M_AXI_araddr),
        .PLCFG_M_AXI_arprot(PLCFG_M_AXI_arprot),
        .PLCFG_M_AXI_arready(PLCFG_M_AXI_arready),
        .PLCFG_M_AXI_arvalid(PLCFG_M_AXI_arvalid),
        .PLCFG_M_AXI_awaddr(PLCFG_M_AXI_awaddr),
        .PLCFG_M_AXI_awprot(PLCFG_M_AXI_awprot),
        .PLCFG_M_AXI_awready(PLCFG_M_AXI_awready),
        .PLCFG_M_AXI_awvalid(PLCFG_M_AXI_awvalid),
        .PLCFG_M_AXI_bready(PLCFG_M_AXI_bready),
        .PLCFG_M_AXI_bresp(PLCFG_M_AXI_bresp),
        .PLCFG_M_AXI_bvalid(PLCFG_M_AXI_bvalid),
        .PLCFG_M_AXI_rdata(PLCFG_M_AXI_rdata),
        .PLCFG_M_AXI_rready(PLCFG_M_AXI_rready),
        .PLCFG_M_AXI_rresp(PLCFG_M_AXI_rresp),
        .PLCFG_M_AXI_rvalid(PLCFG_M_AXI_rvalid),
        .PLCFG_M_AXI_wdata(PLCFG_M_AXI_wdata),
        .PLCFG_M_AXI_wready(PLCFG_M_AXI_wready),
        .PLCFG_M_AXI_wstrb(PLCFG_M_AXI_wstrb),
        .PLCFG_M_AXI_wvalid(PLCFG_M_AXI_wvalid),
        .PLCLK(PLCLK),
        .PLRESETN(PLRESETN),
        .prot_clk           (prot_clk       ),
        .prot_clk_rstn      (~prot_clk_rst  ),
        .RX_BRAM_PORTB_addr(RX_BRAM_PORTB_addr),
        .RX_BRAM_PORTB_clk(RX_BRAM_PORTB_clk),
        .RX_BRAM_PORTB_din(RX_BRAM_PORTB_din),
        .RX_BRAM_PORTB_dout(RX_BRAM_PORTB_dout),
        .RX_BRAM_PORTB_en(RX_BRAM_PORTB_en),
        .RX_BRAM_PORTB_rst(RX_BRAM_PORTB_rst),
        .RX_BRAM_PORTB_we(RX_BRAM_PORTB_we),
        .TX_BRAM_PORTB_addr(TX_BRAM_PORTB_addr),
        .TX_BRAM_PORTB_clk(TX_BRAM_PORTB_clk),
        .TX_BRAM_PORTB_din(TX_BRAM_PORTB_din),
        .TX_BRAM_PORTB_dout(TX_BRAM_PORTB_dout),
        .TX_BRAM_PORTB_en(TX_BRAM_PORTB_en),
        .TX_BRAM_PORTB_rst(TX_BRAM_PORTB_rst),
        .TX_BRAM_PORTB_we(TX_BRAM_PORTB_we));

    assign  s_axi_araddr        =   PLCFG_M_AXI_araddr;
    assign  s_axi_arprot        =   PLCFG_M_AXI_arprot;
    assign  PLCFG_M_AXI_arready =   s_axi_arready;
    assign  s_axi_arvalid       =   PLCFG_M_AXI_arvalid;
    assign  s_axi_awaddr        =   PLCFG_M_AXI_awaddr;
    assign  s_axi_awprot        =   PLCFG_M_AXI_awprot;
    assign  PLCFG_M_AXI_awready =   s_axi_awready;
    assign  s_axi_awvalid       =   PLCFG_M_AXI_awvalid;
    assign  s_axi_bready        =   PLCFG_M_AXI_bready;
    assign  PLCFG_M_AXI_bresp   =   s_axi_bresp;
    assign  PLCFG_M_AXI_bvalid  =   s_axi_bvalid;
    assign  PLCFG_M_AXI_rdata   =   s_axi_rdata;
    assign  s_axi_rready        =   PLCFG_M_AXI_rready;
    assign  PLCFG_M_AXI_rresp   =   s_axi_rresp;
    assign  PLCFG_M_AXI_rvalid  =   s_axi_rvalid;
    assign  s_axi_wdata         =   PLCFG_M_AXI_wdata;
    assign  PLCFG_M_AXI_wready  =   s_axi_wready;
    assign  s_axi_wstrb         =   PLCFG_M_AXI_wstrb;
    assign  s_axi_wvalid        =   PLCFG_M_AXI_wvalid;

    assign  RX_BRAM_PORTB_clk   =   prot_clk;
    assign  RX_BRAM_PORTB_rst   =   prot_clk_rst;
    assign  RX_BRAM_PORTB_en    =   1;
    assign  RX_BRAM_PORTB_we    =   ps_depot_we;
    assign  RX_BRAM_PORTB_addr  =   {ps_depot_addr,2'd0};
    assign  RX_BRAM_PORTB_din   =   ps_depot_din;
//    assign  RX_BRAM_PORTB_dout  =   (RX_BRAM_PORTB_dout),

    assign  TX_BRAM_PORTB_clk   =   prot_clk;
    assign  TX_BRAM_PORTB_rst   =   prot_clk_rst;
    assign  TX_BRAM_PORTB_en    =   1;
    assign  TX_BRAM_PORTB_we    =   0;
    assign  TX_BRAM_PORTB_addr  =   {ps_tx_depot_addr,2'd0};
    assign  TX_BRAM_PORTB_din   =   0;
    assign  ps_tx_depot_dout    =   TX_BRAM_PORTB_dout;

    assign  GPIO_tri_i          =   0;
    assign  I_INTR_IRQ_0        =   comp_irq[(128*1-1):128*(1-1)];
    assign  I_INTR_IRQ_1        =   comp_irq[(128*2-1):128*(2-1)];
    assign  I_INTR_IRQ_2        =   comp_irq[(128*3-1):128*(3-1)];
    assign  I_INTR_IRQ_3        =   comp_irq[(128*4-1):128*(4-1)];
    
    assign  s_axi_aclk          =   PLCLK;
    assign  s_axi_aresetn       =   PLRESETN;
/*       */
  IOBUF AXI_GPIO_tri_iobuf_0
       (.I(AXI_GPIO_tri_o_0),
        .IO(),
        .O(AXI_GPIO_tri_i_0),
        .T(AXI_GPIO_tri_t_0));

endmodule