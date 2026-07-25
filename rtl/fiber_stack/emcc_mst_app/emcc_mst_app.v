/////////////////////////////////////////////////////////////////
// Company:
// Engineer:      Huaye Zhang
// Creat Date:    
// Design Name:   
// Module Name:   
// Project Name:  
// Target Devices:
// Tool versions:
//                
// Dependencies:
//    
//
//Description:
//
/////////////////////////////////////////////////////////////////
module emcc_mst_app
#(
     parameter  PS_REG_AWIDTH   =   7 - 1
    ,parameter  PS_REG_DWIDTH   =   32
    ,parameter  RAM_DEPTH   =   4096
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
)
(
     input              clk
    ,input              reset
    
    ,input              link_success
    ,input  wire        loop_link_success
    
    //component interface
    ,output wire                        slv_cfg_msg_rden
    ,output wire    [RAM_AWIDTH-1:0]    slv_cfg_msg_addr
    ,input  wire    [RAM_DWIDTH-1:0]    slv_cfg_msg_dat
    //jtag interface
    ,input  wire    [RAM_AWIDTH-1:0]    jtag_slv_cfg_msg_addr
    ,input  wire    [RAM_DWIDTH-1:0]    jtag_slv_cfg_msg_dat
    //ps depot inteface
//  ps interface
    ,input  wire                        ps_reg_clk
    ,input  wire                        ps_reg_reset
    ,input  wire                        ps_reg_we
    ,input  wire    [PS_REG_AWIDTH-1:0] ps_reg_addr
    ,input  wire    [PS_REG_DWIDTH-1:0] ps_reg_wr_dat
    ,input  wire                        ps_reg_re
    ,input  wire    [PS_REG_AWIDTH-1:0] ps_reg_rd_addr
    ,output wire                        ps_reg_rd_vld
    ,output wire    [PS_REG_DWIDTH-1:0] ps_reg_rd_dat

    ,output wire    [RAM_AWIDTH-1:0]    ps_tx_depot_addr
    ,input  wire    [RAM_DWIDTH-1:0]    ps_tx_depot_dout

            //  ps  config  port    //
    ,output reg                         rcv_intf_tst_dg_done
    
    ,output wire    [3:0]               slv_sta_msg_vld     //slave station status message
    ,output wire    [RAM_AWIDTH-1:0]    slv_sta_msg_addr
    ,output wire    [RAM_DWIDTH-1:0]    slv_sta_msg_dat

    ,output reg     [3:0]               ps_depot_we
    ,output reg     [RAM_AWIDTH-1:0]    ps_depot_addr
    ,output reg     [RAM_DWIDTH-1:0]    ps_depot_din

    ,output wire                        tst_sig
////////////


//////////////////////////////////
    ,output wire            mst_prcs_hb_flag

    //master AXI interface to aurora IP:send port
    ,output                 m_boroa_tx_tvalid
    ,input                  m_boroa_tx_tready
    ,output         [3:0]   m_boroa_tx_tkeep
    ,output                 m_boroa_tx_tlast
    ,output         [31:0]  m_boroa_tx_tdata

    //slave AXI receive interface
    ,input  wire            s_aurora_rx_tvalid
    ,input  wire    [3:0]   s_aurora_rx_tkeep
    ,input  wire            s_aurora_rx_tlast
    ,input  wire    [31:0]  s_aurora_rx_tdata

);
    //the signals that PS config master app 
    wire            ps_tst_trsf_port;
    wire            ps_trsf_port_en;
    wire            ps_loopback_flag;
    wire            ps_rd_depot_flag;
    wire            ps_tx_req;
    wire            ps_tx_ack;
    wire            opt_intf_init_en;
    wire    [31:0]  cur_tx_trsf_pkg_id;
    wire            tx_dg_done;
    wire            rx_dg_done;
    wire            rx_dg_done_ps;
    wire            rx_dg_done_pl;
    wire    [31:0]  stat_rslt;

    wire    [3:0]               rx_ps_depot_we;
    wire    [RAM_AWIDTH-1:0]    rx_ps_depot_addr;
    wire    [RAM_DWIDTH-1:0]    rx_ps_depot_din;

    //depot buffer:send and receive
    wire                            send_buf_ena;
    wire        [4-1:0]             send_buf_wea;
    wire        [RAM_AWIDTH-1:0]    send_buf_addra;
    wire        [RAM_DWIDTH-1:0]    send_buf_dina;
    wire                            rcv_buf_ena;
    wire        [RAM_AWIDTH-1:0]    rcv_buf_addra;
    wire        [RAM_DWIDTH-1:0]    rcv_buf_douta;
    wire            app_send_req;
    wire            app_send_ack;
    wire            app_rcv_req;
    wire            app_rcv_ack;
    //the signals that depot module and protocol module
    wire            prot_send_req;
    wire            prot_send_ack;
    wire            prot_rcv_req;
    wire            prot_rcv_ack;
    wire    [3:0]   prot_wr_en;
    wire            prot_rd_en;
    wire    [15:0]  prot_rd_addr;
    wire    [31:0]  prot_rd_data;
    wire    [31:0]  prot_wr_data;

///////////////////

    // master mode systerm signal
    (* MARK_DEBUG="true" *)wire           app_trsf_en;
    wire            app_err_flag;        //the error type of slave station is valid
    wire    [15:0]  app_err_type;        //the error type of slave station
    wire    [15:0]  each_dg_len;
    wire    [7:0]   slv_sta_num;         //this signals only update during first initial datagram.It indicate the number of slave station
    wire    [15:0]  hb_err_slvsta;       //indicate the index of the error station //指示产生链接错误的从站

    wire    [3:0]   slv_id_we;
    wire    [15:0]  slv_id_addr;
    wire    [31:0]  slv_id_din;
    wire    [31:0]  slv_fpga_version;
    wire            ping_pong_flag;//0:aurora link is success;1:aurora link is fail
(* MARK_DEBUG="true" *)    wire            mst_sta_trsf_flag;
(* MARK_DEBUG="true" *)    reg [31:0]  wk_cnt  =   'd0;

    always @(posedge clk)begin
        if(reset)begin
            wk_cnt  <=  0;
        end else if (mst_sta_trsf_flag) begin
            wk_cnt  <=  wk_cnt  + 1;
        end else begin
            wk_cnt  <=  0;
        end
    end

    assign  each_dg_len         =   ps_tst_trsf_port ? (`DEPOT_ACTIVE_BYTE_NUM * 2) : (`DEPOT_ACTIVE_BYTE_NUM * 2);//unit:BYTE  datagram length contain the length of tx region and rx region,so the active value must multiply 2.
    
    always @( * )begin
        if(ps_loopback_flag)begin
            ps_depot_we             <=    send_buf_wea;
            ps_depot_addr           <=    send_buf_addra;
            ps_depot_din            <=    send_buf_dina;
            rcv_intf_tst_dg_done    <=    tx_dg_done;
        end else begin
            ps_depot_we             <=    rx_ps_depot_we;
            ps_depot_addr           <=    rx_ps_depot_addr;
            ps_depot_din            <=    rx_ps_depot_din;
//            rcv_intf_tst_dg_done    <=    rx_dg_done_ps;
            rcv_intf_tst_dg_done    <=    rx_dg_done_pl;
        end
    end

    mst_app_cfg
    #(
         .REG_SPACE_BIAS    (`MST_APP_REG_BIAS  )
        ,.REG_SPACE_SIZE    (`MST_APP_REG_SIZE  )
        ,.PS_REG_AWIDTH     (PS_REG_AWIDTH  )
        ,.PS_REG_DWIDTH     (PS_REG_DWIDTH  )
    )
    mst_app_cfg_u
    (
         .ps_reg_clk        (ps_reg_clk     )
        ,.ps_reg_reset      (ps_reg_reset   )
        ,.ps_reg_we         (ps_reg_we      )
        ,.ps_reg_addr       (ps_reg_addr    )
        ,.ps_reg_wr_dat     (ps_reg_wr_dat  )
        ,.ps_reg_re         (ps_reg_re      )
        ,.ps_reg_rd_addr    (ps_reg_rd_addr )
        ,.ps_reg_rd_vld     (ps_reg_rd_vld  )
        ,.ps_reg_rd_dat     (ps_reg_rd_dat  )

        ,.prot_clk          (clk                )
        ,.slv_id_we         (slv_id_we          )
        ,.slv_id_addr       (slv_id_addr        )
        ,.slv_id_din        (slv_id_din         )
        ,.slv_fpga_version  (slv_fpga_version   )

        ,.link_success      (link_success       )
        ,.loop_link_success (loop_link_success  )
        ,.slv_sta_num       (slv_sta_num        )   //this signals only update during first initial datagram.It indicate the number of slave station
        ,.app_err_flag      (app_err_flag       )   //optical fiber link errors type
        ,.app_err_type      (app_err_type       )   //optical fiber link errors type
        ,.hb_err_slvsta     (hb_err_slvsta      )   //indicate the index of the error station //指示产生链接错误的从站
        ,.ps_tst_trsf_port  (ps_tst_trsf_port   )
        ,.ps_trsf_port_en   (ps_trsf_port_en    )
        ,.stat_rslt         (stat_rslt          )
        ,.ps_loopback_flag  (ps_loopback_flag   )
        ,.ps_tx_req         (ps_tx_req          )
        ,.ps_rd_depot_flag  (ps_rd_depot_flag   )
        ,.opt_intf_init_en  (opt_intf_init_en   )
    );

    mst_app_send
    #(
         .RAM_DEPTH     (RAM_DEPTH      )
        ,.RAM_DWIDTH    (RAM_DWIDTH     )
    )
        mst_app_send_u
        (
             .clk               (clk            )
            ,.reset             (reset          )

            ,.link_success      (link_success   )
            ,.slv_sta_num       (slv_sta_num    )

            ,.each_dg_len       (each_dg_len    )

            ,.app_send_req      (app_send_req   )
            ,.app_send_ack      (app_send_ack   )

            //send buffer
            ,.send_buf_ena      (send_buf_ena   )
            ,.send_buf_wea      (send_buf_wea   )
            ,.send_buf_addra    (send_buf_addra )
            ,.send_buf_dina     (send_buf_dina  )

            ,.slv_cfg_msg_rden  (slv_cfg_msg_rden   )
            ,.slv_cfg_msg_addr   (slv_cfg_msg_addr)
            ,.slv_cfg_msg_dat    (slv_cfg_msg_dat )

            ,.jtag_slv_cfg_msg_addr (jtag_slv_cfg_msg_addr  )
            ,.jtag_slv_cfg_msg_dat  (jtag_slv_cfg_msg_dat   )
            //ps depot inteface
            ,.ps_tst_trsf_port  (ps_tst_trsf_port)
            ,.ps_trsf_port_en   (ps_trsf_port_en )
            ,.ps_tx_req         (ps_tx_req       )
            ,.ps_tx_ack         (ps_tx_ack       )
            ,.ps_tx_depot_addr  (ps_tx_depot_addr)
            ,.ps_tx_depot_dout  (ps_tx_depot_dout)
            ,.stat_rslt         (stat_rslt          )

            ,.app_trsf_en       (app_trsf_en    )
            ,.cur_tx_trsf_pkg_id   (cur_tx_trsf_pkg_id)
            ,.tx_dg_done        (tx_dg_done     )
            ,.rx_dg_done        (rx_dg_done_pl)
            ,.tst_sig           (        )
        );

    mst_app_rcv
    #(
         .RAM_DEPTH     (RAM_DEPTH  )
        ,.RAM_DWIDTH    (RAM_DWIDTH )
    )
        mst_app_rcv_u
        (
             .clk           (clk        )
            ,.reset         (reset      )

            ,.slv_sta_num   (slv_sta_num    )
            
            ,.each_dg_len   (each_dg_len    )
            
            ,.cur_tx_trsf_pkg_id(cur_tx_trsf_pkg_id)
            
            ,.app_rcv_req   (app_rcv_req    )
            ,.app_rcv_ack   (app_rcv_ack    )

            //receive buffer
            ,.rcv_buf_ena   (rcv_buf_ena    )
            ,.rcv_buf_addra (rcv_buf_addra  )
            ,.rcv_buf_douta (rcv_buf_douta  )
            //PS   read port
            ,.ps_rd_depot_flag      (ps_rd_depot_flag       )
            ,.rcv_intf_tst_dg_done  (rx_dg_done_ps   )//notice that one ps test package has been received
            ,.rx_dg_done            (rx_dg_done_pl)//notice that one pl normal package has been received
            ,.ps_depot_we       (rx_ps_depot_we        )
            ,.ps_depot_addr     (rx_ps_depot_addr      )
            ,.ps_depot_din      (rx_ps_depot_din       )

            ,.slv_sta_msg_vld   (slv_sta_msg_vld    ) //slave station status message
            ,.slv_sta_msg_addr  (slv_sta_msg_addr   )
            ,.slv_sta_msg_dat   (slv_sta_msg_dat    )

            ,.tst_sig       (tst_sig)
        );

    app_depot_top
    #(
         .RAM_DEPTH     (RAM_DEPTH      )
        ,.RAM_DWIDTH    (RAM_DWIDTH     )
        ,.WOKE_MODE     ("MAST"         )
    )
        app_depot_top_u
        (
             .prot_clk          (clk            )
            ,.prot_reset        (reset          )
            ,.ll_clk            (clk            )
            ,.ll_clk_rst        (reset          )
            ,.ping_pong_flag    (ping_pong_flag )

            ,.prot_send_req     (prot_send_req  )
            ,.prot_send_ack     (prot_send_ack  )
            ,.app_send_req      (app_send_req   )
            ,.app_send_ack      (app_send_ack   )

            ,.prot_rcv_req      (prot_rcv_req   )
            ,.prot_rcv_ack      (prot_rcv_ack   )
            ,.app_rcv_req       (app_rcv_req    )
            ,.app_rcv_ack       (app_rcv_ack    )

            ,.prot_wr_en        (prot_wr_en     )
            ,.prot_rd_en        (prot_rd_en     )
            ,.prot_rd_addr      (prot_rd_addr   )
            ,.prot_rd_data      (prot_rd_data   )
            ,.prot_wr_data      (prot_wr_data   )
            
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

    app_protocal_top
    #(
         .WOKE_MODE     ("MAST"         )
    )
        app_protocal_top_u
        (
             .clk               (clk      )
            ,.reset             (reset  )
            //systerm signals
            ,.app_trsf_en       (app_trsf_en  & opt_intf_init_en  )
            ,.mst_sta_restart   (app_trsf_en  & opt_intf_init_en  )
            ,.each_dg_length    (each_dg_len    )//unit:BYTE
            ,.app_err_flag      (app_err_flag   )
            ,.app_err_type      (app_err_type   )
            ,.hb_err_slvsta     (hb_err_slvsta  )
            ,.mst_prcs_hb_flag  (mst_prcs_hb_flag)
            ,.mst_sta_trsf_flag (mst_sta_trsf_flag  )
            ,.slv_sta_num       (slv_sta_num    )
            ,.loop_link_success (loop_link_success   )
            ,.ping_pong_flag    (ping_pong_flag             )

            ,.prot_send_req     (prot_send_req  )
            ,.prot_send_ack     (prot_send_ack  )
            ,.prot_rcv_req      (prot_rcv_req   )
            ,.prot_rcv_ack      (prot_rcv_ack   )

            //interface between protocal layer and application depot
            ,.app_wr_en         (prot_wr_en      )
            ,.app_rd_en         (prot_rd_en      )
            ,.app_rd_addr       (prot_rd_addr    )
            ,.app_rd_data       (prot_rd_data    )
            ,.app_wr_data       (prot_wr_data    )
            
            ,.slv_id_we         (slv_id_we          )
            ,.slv_id_addr       (slv_id_addr        )
            ,.slv_id_din        (slv_id_din         )
            ,.slv_fpga_version  (slv_fpga_version   )

            //master AXI interface to aurora IP:send port
            ,.m_boroa_tx_tvalid (m_boroa_tx_tvalid)
            ,.m_boroa_tx_tready (m_boroa_tx_tready)
            ,.m_boroa_tx_tkeep  (m_boroa_tx_tkeep)
            ,.m_boroa_tx_tlast  (m_boroa_tx_tlast)
            ,.m_boroa_tx_tdata  (m_boroa_tx_tdata)

            //slave AXI receive interface
            ,.s_aurora_rx_tvalid(s_aurora_rx_tvalid)
            ,.s_aurora_rx_tkeep (s_aurora_rx_tkeep )
            ,.s_aurora_rx_tlast (s_aurora_rx_tlast )
            ,.s_aurora_rx_tdata (s_aurora_rx_tdata )
        );


endmodule