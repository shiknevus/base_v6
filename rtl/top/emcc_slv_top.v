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
`include "global_includes.vh"
`include "depot_addr_map.vh"
module emcc_slv_top #
(
    parameter   STATION_ID = 32'habcd_dc00
)
(
    // User IO
`ifdef SIM_PLATFORM_MST
     input          INIT_CLK_P
    ,input          INIT_CLK_N
`else
     input          INIT_CLK
`endif
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
    
    //IO
    ,output [47:0]  dataout
    ,input  [95:0]  datain
    ,input  [7:0]   uart_232_rxd
    ,output [7:0]   uart_232_txd
    ,input          uart_485_rxd
    ,output         uart_485_txd
    ,output         uart_485_dir
    ,output         adc_sclk1
    ,output         adc_sdin1
    ,input          adc_dout1
    ,output         adc_cs1
    ,output         iic_rtl_0_scl_io
    ,inout          iic_rtl_0_sda_io
    ,input          read_uuid_key
    
    //MOTOR
    ,input  wire [3:0]      i_dv_alarm      
    ,output wire [3:0]      o_dv_pulse
    ,output wire [3:0]      o_dv_dir
    ,output wire [3:0]      o_dv_reset
    ,output wire [3:0]      o_dv_son
);

    localparam  RAM_DEPTH   =   512;
    localparam  RAM_DWIDTH  =   32;
    localparam  RAM_AWIDTH  =   $clog2(RAM_DEPTH);

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
    wire            clk10m; 
    wire            clk_10m;
    wire            ll_clk;
    wire            ll_clk_rst; // local logical clock domain reset

    wire                        driver_cfg_wea;
    wire    [RAM_AWIDTH-1:0]    driver_cfg_addra;
    wire    [RAM_DWIDTH-1:0]    driver_cfg_dina;
    wire                        driver_cfg_msg_wr_req;
    wire                        driver_cfg_msg_wr_ack;

    wire    [31:0]              do_regoin_msg;
    wire    [31:0]              di_regoin_msg;
    wire    [31:0]              ai_regoin_msg;
    wire    [31:0]              rs232_ch0_msg;
    wire    [31:0]              rs232_ch1_msg;
    wire    [31:0]              rs232_ch2_msg;
    wire    [31:0]              rs232_ch3_msg;
    wire    [31:0]              rs232_ch4_msg;
    wire    [31:0]              rs232_ch5_msg;
    wire    [31:0]              rs232_ch6_msg;
    wire    [31:0]              rs232_ch7_msg;
    wire    [31:0]              rs485_ch8_msg;
    wire    [31:0]              pul_motor0_msg;
    wire    [31:0]              pul_motor1_msg;
    wire    [31:0]              pul_motor2_msg;
    wire    [31:0]              pul_motor3_msg;
    wire    [1:0]		         loop_link_success;
    wire    [RAM_DWIDTH-1:0]    do_status;
    wire    [RAM_DWIDTH-1:0]    di_status;
    wire    [RAM_DWIDTH-1:0]    ai_status;
    wire                        rd_msg_addr_en;
    wire    [RAM_AWIDTH-1:0]    rd_msg_addr;
    
    //AXI INTF
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

    assign  sfp0_disable = 1;
    assign  sfp1_disable = 1;
    assign  loop_link_success = {LANE_UP_0,LANE_UP_1};

`ifdef SIM_PLATFORM_MST
    sys_signal_gen
        sys_signal_gen_u
        (
             .sys_clk_in_p          (INIT_CLK_P         )
            ,.sys_clk_in_n          (INIT_CLK_N         )
            ,.rst_fpga_n            (1                  )
            ,.clk_10m               (clk_10m            )
            ,.aurora_ref_clk        (aurora_ref_clk     )
            ,.aurora_ref_clk_rst    (aurora_ref_clk_rst )
            ,.rst_aurora_init_clk   (rst_aurora_init_clk)
            ,.aurora_init_clk       (aurora_init_clk    )
        );
`else
    sys_signal_gen
    #(
         .WOKE_MODE             ("SLAVE"           )
    )
    sys_signal_gen_u
    (
         .sys_clk_in_p          (INIT_CLK           )
        ,.sys_clk_in_n          (0                  )
        ,.rst_fpga_n            (1                  )
        ,.clk_10m               (clk_10m            )
        ,.aurora_ref_clk        (aurora_ref_clk     )
        ,.aurora_ref_clk_rst    (aurora_ref_clk_rst )
        ,.rst_aurora_init_clk   (rst_aurora_init_clk)
        ,.aurora_init_clk       (aurora_init_clk    )
    );
`endif
    assign  GT_RESET_IN = rst_aurora_init_clk;
    assign  ll_clk = aurora_ref_clk;
    assign  ll_clk_rst = aurora_ref_clk_rst;
    assign  clk10m = clk_10m;
//////////////////////////////////////////////////////
    wire [95:0]     slv_inio;
    wire [3:0]      i_servo_alarm;
    zz_io_debounce    
    #(
		 .IO_NUM                (8'd100                )
	    ,.SAMPLE_CNT            (12'd10                )
	)
    zz_io_debounce_u1
    (
         .clk                   (ll_clk                )
        ,.reset                 (ll_clk_rst            )
    
        ,.i_signal              ({i_dv_alarm,datain}   )
        ,.o_signal              ({i_servo_alarm,slv_inio} )
    );

///////////////////////////////////////////////////////    

    hardware_interface_top hardware_interface_top_u
    (
         .clk               (ll_clk             )
        ,.reset             (ll_clk_rst         )
         
	    ,.s_axi_rx_tvalid_0	(m_axi_rx_tvalid_0  )
	    ,.s_axi_rx_tvalid_1	(m_axi_rx_tvalid_1  )

        ,.driver_cfg_wea    (driver_cfg_wea     )
        ,.driver_cfg_addra  ({{16-RAM_AWIDTH{1'b0}},driver_cfg_addra})
        ,.driver_cfg_dina   (driver_cfg_dina    )
        ,.rd_msg_addr_en    (rd_msg_addr_en     )
        ,.rd_msg_addr       ({{16-RAM_AWIDTH{1'b0}},rd_msg_addr})
        ,.slvbd_inio        (slv_inio           )
        ,.slvbd_outio       (dataout            )
        ,.uart_232_rxd      (uart_232_rxd       )
        ,.uart_232_txd      (uart_232_txd       )
        ,.uart_485_rxd      (uart_485_rxd       )
        ,.uart_485_txd      (uart_485_txd       )
        ,.uart_485_dir      (uart_485_dir       )
        ,.i_dv_alarm        (i_servo_alarm      )
        ,.o_dv_pulse        (o_dv_pulse         )
        ,.o_dv_dir          (o_dv_dir           )
        ,.o_dv_reset        (o_dv_reset         )
        ,.o_dv_son          (o_dv_son           )
        ,.di_regoin_msg     (di_regoin_msg      )
        ,.do_regoin_msg     (do_regoin_msg      )
        ,.rs232_ch0_msg     (rs232_ch0_msg      )
        ,.rs232_ch1_msg     (rs232_ch1_msg      )
        ,.rs232_ch2_msg     (rs232_ch2_msg      )
        ,.rs232_ch3_msg     (rs232_ch3_msg      )
        ,.rs232_ch4_msg     (rs232_ch4_msg      )
        ,.rs232_ch5_msg     (rs232_ch5_msg      )
        ,.rs232_ch6_msg     (rs232_ch6_msg      )
        ,.rs232_ch7_msg     (rs232_ch7_msg      )
        ,.rs485_ch8_msg     (rs485_ch8_msg      )
        ,.pul_motor0_msg    (pul_motor0_msg     )
        ,.pul_motor1_msg    (pul_motor1_msg     )
        ,.pul_motor2_msg    (pul_motor2_msg     )
        ,.pul_motor3_msg    (pul_motor3_msg     )
    );

    wire            prot_clk;
    reg             prot_clk_rst = 1;
    reg             axi_clk_rst_0_d1;
    assign  prot_clk = axi_clk_0;

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

    aurora_8b10b_top aurora_8b10b_top_u
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

        // AXI INTF: from upstream
        ,.axi_clk_0         (axi_clk_0          )
        ,.axi_clk_rst_0     (axi_clk_rst_0      )
        ,.s_axi_tx_tdata_0  (s_axi_tx_tdata_0   )
        ,.s_axi_tx_tkeep_0  (s_axi_tx_tkeep_0   )
        ,.s_axi_tx_tvalid_0 (s_axi_tx_tvalid_0  )
        ,.s_axi_tx_tlast_0  (s_axi_tx_tlast_0   )
        ,.s_axi_tx_tready_0 (s_axi_tx_tready_0  )
        // AXI RX
        ,.m_axi_rx_tdata_0  (m_axi_rx_tdata_0   )
        ,.m_axi_rx_tkeep_0  (m_axi_rx_tkeep_0   )
        ,.m_axi_rx_tvalid_0 (m_axi_rx_tvalid_0  )
        ,.m_axi_rx_tlast_0  (m_axi_rx_tlast_0   )

        // AXI INTF:to downstream
        ,.HARD_ERR_1        (HARD_ERR_1  )
        ,.SOFT_ERR_1        (SOFT_ERR_1  )
        ,.FRAME_ERR_1       (FRAME_ERR_1 )
        ,.LANE_UP_1         (LANE_UP_1   )
        ,.CHANNEL_UP_1      (CHANNEL_UP_1)

        ,.RXP_1             (RXP_1      )
        ,.RXN_1             (RXN_1      )
        ,.TXP_1             (TXP_1      )
        ,.TXN_1             (TXN_1      )

        ,.s_axi_tx_tdata_1  (s_axi_tx_tdata_1   )
        ,.s_axi_tx_tkeep_1  (s_axi_tx_tkeep_1   )
        ,.s_axi_tx_tvalid_1 (s_axi_tx_tvalid_1  )
        ,.s_axi_tx_tlast_1  (s_axi_tx_tlast_1   )
        ,.s_axi_tx_tready_1 (s_axi_tx_tready_1  )
        //AXI RX
        ,.m_axi_rx_tdata_1  (m_axi_rx_tdata_1   )
        ,.m_axi_rx_tkeep_1  (m_axi_rx_tkeep_1   )
        ,.m_axi_rx_tvalid_1 (m_axi_rx_tvalid_1  )
        ,.m_axi_rx_tlast_1  (m_axi_rx_tlast_1   )
    );
    
    //these signals is used to communicate between app protocol layer and app depot
    wire [3:0]      app_wr_en;
    wire            app_rd_en;
    wire [15:0]     app_rd_addr;
    wire [31:0]     app_rd_data;
    wire [31:0]     app_wr_data;

    //protocol layer axi transfer port to aurora IP
    wire            m_app_tx_tvalid;
    wire            m_app_tx_tready;
    wire    [3:0]   m_app_tx_tkeep;
    wire            m_app_tx_tlast;
    wire    [31:0]  m_app_tx_tdata;

    //protocol layer axi receive port from aurora IP
    wire            s_app_rx_tvalid;
    wire    [3:0]   s_app_rx_tkeep;
    wire            s_app_rx_tlast;
    wire    [31:0]  s_app_rx_tdata;
    
    //slave station receive heartbeat flag[1:0]
    //[1bit]: receive hb fram;
    //[0bit]:check slave station address is match
    wire    [1:0]   slvsta_rcv_hb_flag;

    wire            prot_send_req;
    wire            prot_send_ack;

    wire            prot_rcv_req;
    wire            prot_rcv_ack;
    wire    [15:0]  cur_slv_dg_beat;     //current slave station datagram beat number

//----------------depot bus port---------------------{
    //send buffer
    wire                            app_send_req;
    wire                            app_send_ack;
    wire                            send_buf_ena;
    wire        [4-1:0]             send_buf_wea;
    wire        [RAM_AWIDTH-1:0]    send_buf_addra;
    wire        [RAM_DWIDTH-1:0]    send_buf_dina;
    //receive buffer
    wire                            app_rcv_req;
    wire                            app_rcv_ack;
    wire                            rcv_buf_ena;
    wire        [RAM_AWIDTH-1:0]    rcv_buf_addra;
    wire        [RAM_DWIDTH-1:0]    rcv_buf_douta;
//----------------depot bus port---------------------}
    wire            id_op_f;
    wire [31:0]     id_out_data; 
    //current slave station id
    wire            slvsta_id_vld;
    wire [31:0]     slvsta_id;
    wire            cfg_sta_addr_vld;
    wire [7:0]      cfg_sta_addr;        //the slave station address which is configed by master station
    wire            read_sta_addr_vld;
    wire [7:0]      read_sta_addr;
    wire            ping_pong_flag;
    wire            rest_read_finish;
    wire [12:0]     ch_1;
    wire [12:0]     ch_2;

`ifdef SIM_PLATFORM_MST
    assign  slvsta_id_vld   =   1;
    assign  slvsta_id       =   STATION_ID + cfg_sta_addr;
`else
    assign  slvsta_id_vld   =   rest_read_finish;
    assign  slvsta_id       =   id_out_data;
`endif

    app_protocal_top
    #(
        .WOKE_MODE  ("SLAVE")
    )
        app_protocal_top_u
        (
             .clk               (prot_clk           )
            ,.reset             (prot_clk_rst       )
            //systerm signal
            ,.slvsta_rcv_hb_flag(slvsta_rcv_hb_flag )
            ,.slvsta_id_vld     (slvsta_id_vld      )
            ,.slvsta_id         (slvsta_id          )
            ,.cfg_sta_addr_vld  (cfg_sta_addr_vld   )
            ,.cfg_sta_addr      (cfg_sta_addr       )
            ,.read_sta_addr_vld (read_sta_addr_vld  )
            ,.read_sta_addr     (read_sta_addr      )
            ,.ping_pong_flag    (ping_pong_flag     )
            ,.cur_slv_dg_beat   (cur_slv_dg_beat    )
	       ,.loop_link_success  (loop_link_success)
	       ,.downstream_lane_up (LANE_UP_0 & CHANNEL_UP_0)
	       ,.downstream_link    (LANE_UP_1 & CHANNEL_UP_1)
            //interface between protocal layer and application depot
            ,.app_wr_en         (app_wr_en          )
            ,.app_rd_en         (app_rd_en          )
            ,.app_rd_addr       (app_rd_addr        )
            ,.app_rd_data       (app_rd_data        )
            ,.app_wr_data       (app_wr_data        )

            ,.prot_send_req     (prot_send_req      )
            ,.prot_send_ack     (prot_send_ack      )
            ,.prot_rcv_req      (prot_rcv_req       )
            ,.prot_rcv_ack      (prot_rcv_ack       )

            //master AXI interface to aurora IP:send port
            ,.m_boroa_tx_tvalid (m_app_tx_tvalid    )
            ,.m_boroa_tx_tready (m_app_tx_tready    )
            ,.m_boroa_tx_tkeep  (m_app_tx_tkeep     )
            ,.m_boroa_tx_tlast  (m_app_tx_tlast     )
            ,.m_boroa_tx_tdata  (m_app_tx_tdata     )

            //slave AXI receive interface
            ,.s_aurora_rx_tvalid(s_app_rx_tvalid    )
            ,.s_aurora_rx_tkeep (s_app_rx_tkeep     )
            ,.s_aurora_rx_tlast (s_app_rx_tlast     )
            ,.s_aurora_rx_tdata (s_app_rx_tdata     )
        );

    //this signal is used to decidet how the downstream bus is connected
    reg downstream_lane_up = 'd0;
    always @ (posedge prot_clk)begin
        if(slvsta_rcv_hb_flag[1])begin  //update only on heartbeat result, hold between heartbeats
            if(slvsta_rcv_hb_flag[0])begin   //if address match,package is return
                downstream_lane_up  <=  'd0;
            end else begin//package continues to downstream
                downstream_lane_up  <=  'd1;
            end
        end
    end

    ethcat_axi_rout ethcat_axi_rout_u
    (
         .clk                   (prot_clk           )
        ,.rst                   (prot_clk_rst       )
        ,.downstream_lane_up    (LANE_UP_0 & CHANNEL_UP_0)
        ,.downstream_link       (LANE_UP_1 & CHANNEL_UP_1)
        //from app interface
        ,.s_app_tx_tvalid       (m_app_tx_tvalid    )
        ,.s_app_tx_tready       (m_app_tx_tready    )
        ,.s_app_tx_tkeep        (m_app_tx_tkeep     )
        ,.s_app_tx_tlast        (m_app_tx_tlast     )
        ,.s_app_tx_tdata        (m_app_tx_tdata     )

        ,.m_app_rx_tvalid       (s_app_rx_tvalid    )
        ,.m_app_rx_tkeep        (s_app_rx_tkeep     )
        ,.m_app_rx_tlast        (s_app_rx_tlast     )
        ,.m_app_rx_tdata        (s_app_rx_tdata     )

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

     wire           id_w_en;
     wire           id_r_en;
     wire [31:0]    iid_data;
     wire [15:0]    iid_addr;
     wire [31:0]    id_data;
     wire [15:0]    id_addr;
     wire           c_w_en;
     wire           c_r_en;
     wire           did;
     wire           com_id_f;
     wire [31:0]    com_id_data;
     wire           iic_r_end;
     wire           iic_w_end;   

/////////////////////////////////////////////////////////////////////////////
    /*vio_7series vio_top_u
    (
        .clk(ll_clk),         // input wire clk   prot_clk
        .probe_in0(id_op_f),    // input wire [0 : 0] probe_in0
        .probe_in1(id_out_data), // input wire [31 : 0] probe_in1
        .probe_out0(iid_data),  // output wire [31 : 0] probe_out0
        .probe_out1(iid_addr),  // output wire [15 : 0] probe_out1
        .probe_out2(id_w_en),   // output wire [0 : 0] probe_out2
        .probe_out3(id_r_en),   // output wire [0 : 0] probe_out3
        .probe_out4(did)        // output wire [0 : 0] probe_out3
    );*/

    app_depot_top
    #(
         .RAM_DEPTH      (RAM_DEPTH)
        ,.WOKE_MODE      ("SLAVE" )
    )
    app_depot_top_u
    (
         .prot_clk          (prot_clk       )
        ,.prot_reset        (prot_clk_rst   )
        ,.ll_clk            (ll_clk         )
        ,.ll_clk_rst        (ll_clk_rst     )
        ,.ping_pong_flag    (0 )//The slave no need to consider the backup situation

        ,.prot_send_req     (prot_send_req  )
        ,.prot_send_ack     (prot_send_ack  )
        ,.app_send_req      (app_send_req   )
        ,.app_send_ack      (app_send_ack   )

        ,.prot_rcv_req      (prot_rcv_req   )
        ,.prot_rcv_ack      (prot_rcv_ack   )
        ,.app_rcv_req       (app_rcv_req    )
        ,.app_rcv_ack       (app_rcv_ack    )

        ,.prot_wr_en        (app_wr_en      )
        ,.prot_rd_en        (app_rd_en      )
        ,.prot_rd_addr      (app_rd_addr    )
        ,.prot_rd_data      (app_rd_data    )
        ,.prot_wr_data      (app_wr_data    )
            
        //send buffer
        ,.send_buf_ena      (send_buf_ena   )
        ,.send_buf_wea      (send_buf_wea   )
        ,.send_buf_addra    (send_buf_addra )
        ,.send_buf_dina     (send_buf_dina  )
        //receive buffer
        ,.rcv_buf_ena       (rcv_buf_ena    )
        ,.rcv_buf_addra     (rcv_buf_addra  )
        ,.rcv_buf_douta     (rcv_buf_douta  )
    );

    emcc_slv_app
    #(
        .RAM_DEPTH           (RAM_DEPTH     )
    )
    emcc_slv_app_u
    (
          .clk               (ll_clk            )
         ,.reset             (ll_clk_rst        )
    
         ,.slv_sta_num       (1)
         ,.each_dg_len       (cur_slv_dg_beat   )
         ,.app_send_req      (app_send_req      )
         ,.app_send_ack      (app_send_ack      )
         ,.app_rcv_req       (app_rcv_req       )
         ,.app_rcv_ack       (app_rcv_ack       )

         //send buffer
         ,.send_buf_ena      (send_buf_ena      )
         ,.send_buf_wea      (send_buf_wea      )
         ,.send_buf_addra    (send_buf_addra    )
         ,.send_buf_dina     (send_buf_dina     )
         //receive buffer
         ,.rcv_buf_ena       (rcv_buf_ena       )
         ,.rcv_buf_addra     (rcv_buf_addra     )
         ,.rcv_buf_douta     (rcv_buf_douta     )

         ,.app_cfg_wea       (driver_cfg_wea    )
         ,.app_cfg_addra     (driver_cfg_addra  )
         ,.app_cfg_dina      (driver_cfg_dina   )
         ,.rd_msg_addr_en    (rd_msg_addr_en    ) 
         ,.rd_msg_addr       (rd_msg_addr       ) 
         ,.driver_cfg_msg_wr_req (driver_cfg_msg_wr_req  )
         ,.driver_cfg_msg_wr_ack (1'b1                   ) // cfg stream is fire-and-forget, ack tied high (was fake self-echo)

         ,.do_regoin_msg     (do_regoin_msg     )
         ,.di_regoin_msg     (di_regoin_msg     )
         ,.ai_regoin_msg     (ai_regoin_msg     )
         ,.rs232_ch0_msg     (rs232_ch0_msg     )
         ,.rs232_ch1_msg     (rs232_ch1_msg     )
         ,.rs232_ch2_msg     (rs232_ch2_msg     )
         ,.rs232_ch3_msg     (rs232_ch3_msg     )
         ,.rs232_ch4_msg     (rs232_ch4_msg     )
         ,.rs232_ch5_msg     (rs232_ch5_msg     )
         ,.rs232_ch6_msg     (rs232_ch6_msg     )
         ,.rs232_ch7_msg     (rs232_ch7_msg     )
         ,.rs485_ch8_msg     (rs485_ch8_msg     )
         ,.pul_motor0_msg    (pul_motor0_msg    )
         ,.pul_motor1_msg    (pul_motor1_msg    )
         ,.pul_motor2_msg    (pul_motor2_msg    )
         ,.pul_motor3_msg    (pul_motor3_msg    )
    );

    wire    out_10Hz; 
    my_freq my_freq_u
    (
         .clk         (ll_clk   )
        ,.out_10Hz    (out_10Hz )
    );    
 
    wire [7:0]      address_L;
    wire [7:0]      address_U;
    wire [0:0]      write_en;
    wire [0:0]      read_en;
    wire [7:0]      iic_datain;
    wire [7:0]      iic_dataout;

        iic_rom iic_rom_u
        (
             .clk               (out_10Hz   )
            ,.reset             (~ll_clk_rst)
            ,.scl               (iic_rtl_0_scl_io)
            ,.sda               (iic_rtl_0_sda_io)
            ,.address_L         (address_L  )
            ,.address_U         (address_U  )
            ,.write_en          (write_en   )
            ,.read_en           (read_en    )
            ,.datain            (iic_datain )
            ,.dataout           (iic_dataout)
            ,.iic_r_end         (iic_r_end  )
            ,.iic_w_end         (iic_w_end  )
        );
 
        combine combine_u
        (
            .clock(out_10Hz),
            .reset(~ll_clk_rst),
            .c_w_en(c_w_en),
            .c_r_en(c_r_en),
            .data(id_data),
            .addr(id_addr),
            .iic_rd_end(iic_r_end),
            .iic_wd_end(iic_w_end),
            .iic_com_data(iic_dataout),
            
            .w_en(write_en),
            .r_en(read_en),
            .addr_u(address_U),
            .addr_l(address_L),
            .com_iic_data(iic_datain),
            .com_id_data(com_id_data),
            .com_id_f(com_id_f)
        );

        id id_u
        (
            .ll_clk(ll_clk),
            .clock(out_10Hz),
            .reset(ll_clk_rst),
            .did(did),
            .id_w_en(id_w_en),
            .id_r_en(id_r_en),
            .data(iid_data),
            .addr(iid_addr),
            .id_op_f(id_op_f),
            .id_out_data(id_out_data),
            .rest_read_finish(rest_read_finish),
            .read_uuid_key(read_uuid_key),
            .cfg_sta_addr_vld(cfg_sta_addr_vld),
            .cfg_sta_addr(cfg_sta_addr),
            .read_sta_addr_vld(read_sta_addr_vld),
            .read_sta_addr(read_sta_addr),
            
            .com_id_f(com_id_f),
            .w_en(c_w_en),
            .r_en(c_r_en),
            .id_com_addr(id_addr),
            .id_com_data(id_data),
            .com_id_data(com_id_data)
        );

        adc_dac adc_dac_u
        ( 
             .clk10m    (clk10m     )
             ,.locked   (~ll_clk_rst)
             
             ,.sclk     (adc_sclk1  )
             ,.sdin1    (adc_sdin1  )
             ,.sdout1   (adc_dout1  )
             ,.cs1      (adc_cs1    )
             ,.ch_1     (ch_1       )
             ,.ch_2     (ch_2       )
        );

`ifdef SIM_PLATFORM_MST
    assign  ai_regoin_msg   =   {cfg_sta_addr[7:0],24'h03_cdef};
`else
    assign  ai_regoin_msg   =   {1'b0,1'b0,1'b0,ch_1,1'b0,1'b0,1'b0,ch_2};
`endif

	//status LED: solid=link idle, fast blink=data flowing, dark=link down
	wire            slv_link_up  = LANE_UP_0 & CHANNEL_UP_0;
	wire            slv_data_act = m_app_tx_tvalid | s_app_rx_tvalid
	                             | s_axi_tx_tvalid_0 | m_axi_rx_tvalid_0
	                             | s_axi_tx_tvalid_1 | m_axi_rx_tvalid_1;
	reg [26:0]      led_act_hold;
	reg [26:0]      led_free_cnt;
	always @(posedge axi_clk_0) begin
	    led_free_cnt    <= led_free_cnt + 1'b1;
	    if (slv_data_act)
	        led_act_hold <= 27'd78_125_000;         //0.5s hold @156.25MHz
	    else if (led_act_hold != 0)
	        led_act_hold <= led_act_hold - 1'b1;
	end
	assign  led = ~(slv_link_up & ((led_act_hold != 0) ? led_free_cnt[24] : 1'b1)); //~5Hz blink on activity, keep active-low drive
endmodule