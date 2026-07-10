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
    
//    2nd
    ,input          RXP_1
    ,input          RXN_1
    ,output         TXP_1
    ,output         TXN_1
    
    ,inout          led     //systerm status
    ,output         sfp0_disable
    ,output         sfp1_disable
    ,output         tst_sig
    
    ,input wire [63:0]      main_board_inio
    ,output wire [31:0]     main_board_outio
    
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
    localparam  CHANNEL_NUM         =   2;
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
    wire    [511:0]             emcc_comp_irq;
    //other
    wire    [3:0]               ps_depot_we;
    wire    [RAM_AWIDTH-1:0]    ps_depot_addr;
    wire    [RAM_DWIDTH-1:0]    ps_depot_din;

    wire    [RAM_AWIDTH-1:0]    ps_tx_depot_addr;
    wire    [RAM_DWIDTH-1:0]    ps_tx_depot_dout;
    wire                        rcv_intf_tst_dg_done;//interrupt
    reg                         axi_clk_rst_0_d1;
    reg                         aurora_ip_rst_release;
    sys_signal_gen
        sys_signal_gen_u
        (
             .sys_clk_in_p          (INIT_CLK_P         )
            ,.sys_clk_in_n          (INIT_CLK_N         )
            ,.rst_fpga_n            (1                  )
            ,.aurora_ref_clk        (aurora_ref_clk     )
            ,.aurora_ref_clk_rst    (aurora_ref_clk_rst )
            ,.rst_aurora_init_clk   (rst_aurora_init_clk)
            ,.aurora_init_clk       (aurora_init_clk    )
        );
    assign  GT_RESET_IN = rst_aurora_init_clk;

    assign  prot_clk = axi_clk_0;
/*
    BUFG prot_clk_bufg (
        .O(prot_clk), // 1-bit output: Clock output
        .I(axi_clk_0)  // 1-bit input: Clock input
    );
*/
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
    assign  s_axi_tx_tdata_1    = 0;
    assign  s_axi_tx_tkeep_1    = 0;
    assign  s_axi_tx_tvalid_1   = 0;
    assign  s_axi_tx_tlast_1    = 0;

    ethcat_axi_rout_mststa
        axi_rout_u
        (
             .clk                   (prot_clk          )
            ,.rst                   (prot_clk_rst      )
            ,.downstream_lane_up    (mst_prcs_hb_flag   )//1:rx0 to tx;0:rx1 to tx

            ,.m_app_rx_tvalid       (s_app_rx_tvalid    )
            ,.m_app_rx_tkeep        (s_app_rx_tkeep     )
            ,.m_app_rx_tlast        (s_app_rx_tlast     )
            ,.m_app_rx_tdata        (s_app_rx_tdata     )

            ,.s_app_tx_tvalid       (m_app_tx_tvalid    )
            ,.s_app_tx_tready       (m_app_tx_tready    )
            ,.s_app_tx_tkeep        (m_app_tx_tkeep     )
            ,.s_app_tx_tlast        (m_app_tx_tlast     )
            ,.s_app_tx_tdata        (m_app_tx_tdata     )

            ,.m_axi_tx_tdata_0      (s_axi_tx_tdata_0   )
            ,.m_axi_tx_tkeep_0      (s_axi_tx_tkeep_0   )
            ,.m_axi_tx_tvalid_0     (s_axi_tx_tvalid_0  )
            ,.m_axi_tx_tlast_0      (s_axi_tx_tlast_0   )
            ,.m_axi_tx_tready_0     (s_axi_tx_tready_0  )

            ,.s_axi_rx_tdata_0      (m_axi_rx_tdata_0   )
            ,.s_axi_rx_tkeep_0      (m_axi_rx_tkeep_0   )
            ,.s_axi_rx_tvalid_0     (m_axi_rx_tvalid_0  )
            ,.s_axi_rx_tlast_0      (m_axi_rx_tlast_0   )

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
        
        wire    [31:0]  vio_ram_wr_addr;
        wire    [31:0]  vio_ram_wr_data;
        reg     [31:0]  vio_ram_wr_addr_d1;
        reg     [31:0]  vio_ram_wr_data_d1;
        vio_8series vio_top_u (
             .clk           (prot_clk          )
            ,.probe_in0     (LANE_UP_0          )
            ,.probe_in1     (CHANNEL_UP_0       )
            ,.probe_in2     (LANE_UP_1          )
            ,.probe_in3     (CHANNEL_UP_1       )
            ,.probe_in4     (vio_ram_rd_data_d1 )
            ,.probe_in5     (0)
            ,.probe_in6     (0)
            ,.probe_out0    (jtag_irq[255:0]    )
            ,.probe_out1    (jtag_irq[511:256]  )
            ,.probe_out2    (                   )
            ,.probe_out3    (jtag_misc_ctrl     )
            ,.probe_out4    (vio_ram_rd_addr    )
            ,.probe_out5    (vio_ram_wr_addr    )
            ,.probe_out6    (vio_ram_wr_data    )
        );
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

    wire                        comp_reg_rd_vld;
    wire    [PS_REG_DWIDTH-1:0] comp_reg_rd_dat;
    `ifdef SIM_PLATFORM_MST
    emcc_comp_top
    #(
         .PS_REG_AWIDTH     (PS_REG_AWIDTH  )
        ,.PS_REG_DWIDTH     (PS_REG_DWIDTH  )
        ,.RAM_DEPTH         (RAM_DEPTH      )
        ,.RAM_DWIDTH        (RAM_DWIDTH     )
    )
        emcc_comp_top_u
        (
             .clk                       (prot_clk        )
            ,.reset                     (prot_clk_rst    )

            ,.di_mst_msg                (main_board_inio)
            ,.do_mst_msg                (main_board_outio)

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
            ,.ps_reg_rd_vld             (comp_reg_rd_vld )
            ,.ps_reg_rd_dat             (comp_reg_rd_dat )
            ,.comp_irq                  (emcc_comp_irq       )
            ,.tst_sig                   (        )
        );
    `else
    emcc_comp_top
    #(
         .PS_REG_AWIDTH     (PS_REG_AWIDTH  )
        ,.PS_REG_DWIDTH     (PS_REG_DWIDTH  )
        ,.RAM_DEPTH         (RAM_DEPTH      )
        ,.RAM_DWIDTH        (RAM_DWIDTH     )
    )
        emcc_comp_top_u
        (
             .clk                       (prot_clk        )
            ,.reset                     (prot_clk_rst    )

            ,.di_mst_msg                (main_board_inio)
            ,.do_mst_msg                (main_board_outio)

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
            ,.ps_reg_rd_vld             (comp_reg_rd_vld )
            ,.ps_reg_rd_dat             (comp_reg_rd_dat )
            ,.comp_irq                  (emcc_comp_irq       )
            ,.tst_sig                   (        )
        );
    `endif

    always @(posedge prot_clk)begin
        if(jtag_irq_select)begin
            comp_irq    <=  jtag_irq_d1;
        end else begin
            comp_irq    <=  emcc_comp_irq;
        end
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
    
            ,.link_success      (LANE_UP_0 &  CHANNEL_UP_0)
            ,.loop_link_success (CHANNEL_UP_1 & LANE_UP_1   )
            ,.mst_prcs_hb_flag  (mst_prcs_hb_flag)

       //component interface
            ,.slv_cfg_msg_rden  (slv_cfg_msg_rden   )
            ,.slv_cfg_msg_addr   (slv_cfg_msg_addr    )
            ,.slv_cfg_msg_dat    (slv_cfg_msg_dat     )

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

//---JTAG interface---//
            ,.jtag_slv_cfg_msg_addr (jtag_slv_cfg_msg_addr  )
            ,.jtag_slv_cfg_msg_dat  (jtag_slv_cfg_msg_dat   )

            ,.tst_sig           (tst_sig)
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
(* MARK_DEBUG="true" *)  wire [127:0]I_INTR_IRQ_0;
  wire  [127:0]I_INTR_IRQ_1;
  wire  [127:0]I_INTR_IRQ_2;
  wire  [127:0]I_INTR_IRQ_3;

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
        .IO(led),
        .O(AXI_GPIO_tri_i_0),
        .T(AXI_GPIO_tri_t_0));
 
    localparam  TST_CNT_NUM =   50_000_000;
    reg [31:0]  tst_cnt =   'd0;
    always @(posedge s_axi_aclk)begin
        if(tst_cnt  ==   TST_CNT_NUM)begin
            tst_cnt <=  0;
        end else begin
            tst_cnt <=  tst_cnt + 1;
        end
    end

endmodule