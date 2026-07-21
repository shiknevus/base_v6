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
module app_depot_top
#(
     parameter  RAM_DEPTH   =   4096
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
    ,parameter  PKG_NUM     =   RAM_DEPTH
    ,parameter  WOKE_MODE   =   "MAST"
)
(
     input              prot_clk
    ,input              prot_reset
    ,input              ll_clk
    ,input              ll_clk_rst
    ,input              prot_send_req
    ,output             prot_send_ack
    ,input              app_send_req
    ,output             app_send_ack

    ,input              prot_rcv_req
    ,output             prot_rcv_ack
    ,input              app_rcv_req
    ,output             app_rcv_ack

    ,input              ping_pong_flag//0:aurora link is success;1:aurora link is fail
    ,input      [3:0]   prot_wr_en
    ,input              prot_rd_en
    ,input      [15:0]  prot_rd_addr
    ,output     [31:0]  prot_rd_data
    ,input      [31:0]  prot_wr_data
    
    //send buffer
    ,input                              send_buf_ena
    ,input          [4-1:0]             send_buf_wea
    ,input          [RAM_AWIDTH-1:0]    send_buf_addra
    ,input          [RAM_DWIDTH-1:0]    send_buf_dina
    //receive buffer
    ,input  wire                        rcv_buf_ena
    ,input  wire    [RAM_AWIDTH-1:0]    rcv_buf_addra
    ,output wire    [RAM_DWIDTH-1:0]    rcv_buf_douta

);

    localparam  RAM_TYPE    =   (WOKE_MODE  == "MAST") ? "ULTRA" : "TRUE";

(* MARK_DEBUG="true" *)    wire    [RAM_AWIDTH-1:0]    wr_addr;
    wire    [RAM_DWIDTH-1:0]    wr_dat;
    wire                        rd_enb;
    wire    [RAM_AWIDTH-1:0]    rd_addr;
    wire    [RAM_DWIDTH-1:0]    rd_dat;
    wire    [RAM_DWIDTH-1:0]    dinb;
    wire    [3:0]               wr_ea;
    wire    [3:0]               web;

    wire                        pong_ena;
    wire    [4-1:0]             pong_wea;
    wire    [RAM_AWIDTH-1:0]    pong_addra;
    wire    [RAM_DWIDTH-1:0]    pong_dina;
    wire    [RAM_DWIDTH-1:0]    pong_douta;
    wire                        pong_enb;
    wire    [4-1:0]      pong_web;
    wire    [RAM_AWIDTH-1:0]    pong_addrb;
    wire    [RAM_DWIDTH-1:0]    pong_dinb;
    wire    [RAM_DWIDTH-1:0]    pong_doutb;

    wire                        rcv_ena;
    wire    [4-1:0]             rcv_wea;
    wire    [RAM_AWIDTH-1:0]    rcv_addra;
    wire    [RAM_DWIDTH-1:0]    rcv_dina;
    wire    [RAM_DWIDTH-1:0]    rcv_douta;
    wire                        rcv_enb;
    wire    [4-1:0]             rcv_web;
    wire    [RAM_AWIDTH-1:0]    rcv_addrb;
    wire    [RAM_DWIDTH-1:0]    rcv_dinb;
    wire    [RAM_DWIDTH-1:0]    rcv_doutb;

    reg     [15:0]  prot_rd_addr_d1;
    reg     [15:0]  prot_rd_addr_d2;
    reg             prot_rd_en_d1;
    reg             prot_rd_en_d2;
    always @(posedge prot_clk)
    begin
        prot_rd_addr_d1  <=  prot_rd_addr;
        prot_rd_addr_d2  <=  prot_rd_addr_d1;
        prot_rd_en_d1    <=  prot_rd_en;
        prot_rd_en_d2    <=  prot_rd_en_d1;
    end
    
    depot_arbit
        depot_arbit_u
        (
             .prot_clk          (prot_clk       )
            ,.prot_reset        (prot_reset     )
            ,.app_clk           (ll_clk         )
            ,.app_reset         (ll_clk_rst     )
            ,.prot_send_req     (prot_send_req  )
            ,.prot_send_ack     (prot_send_ack  )
            ,.app_depot_req     (app_send_req   )
            ,.app_depot_ack     (app_send_ack   )
        );

    depot_arbit
        rcv_depot_arbit_u
        (
             .prot_clk          (ll_clk         )
            ,.prot_reset        (ll_clk_rst     )
            ,.app_clk           (prot_clk       )
            ,.app_reset         (prot_reset     )
            ,.prot_send_req     (app_rcv_req    )
            ,.prot_send_ack     (app_rcv_ack    )
            ,.app_depot_req     (prot_rcv_req   )
            ,.app_depot_ack     (prot_rcv_ack   )
        );
/////////////////////////////////////////////
//send ram :ping      //
/////////////////////////////////////////////

    gen_ram
    #(
         .RAM_DWIDTH    (RAM_DWIDTH  )
        ,.RAM_DEPTH     (RAM_DEPTH   )
        ,.TYPE          (RAM_TYPE    )
    )
        send_ping_ram_u
    (
         .clka  (ll_clk     )
        ,.ena   (1          )
        ,.wea   (wr_ea      )//this port is used by Application,only write mode
        ,.addra (wr_addr    )
        ,.dina  (wr_dat     )
        ,.douta (           )
        
        ,.clkb  (prot_clk    )//this port is used by protocol layer,only read mode;
        ,.enb   (rd_enb     )//the read data is sent to protocol read port and backup ram write mode
        ,.web   (web        )
        ,.addrb (rd_addr    )
        ,.dinb  (dinb       )
        ,.doutb (rd_dat     )
    );

    assign  wr_ea   = send_buf_wea;
    assign  wr_addr = send_buf_addra;
    assign  wr_dat  = send_buf_dina;
    
    assign  rd_enb      =   1;
    assign  web         =   0;
    assign  rd_addr     =   (prot_wr_en == 0) ? prot_rd_addr : 0;//read mode,so the rd_addr bus is active while read mode
    assign  dinb        =   0;

//bakcup ram
    gen_ram
    #(
         .RAM_DWIDTH    (RAM_DWIDTH  )
        ,.RAM_DEPTH     (RAM_DEPTH   )
        ,.TYPE          (RAM_TYPE    )
    )
        send_backup_ram_u
    (
         .clka  (prot_clk        )
        ,.ena   (pong_ena       )
        ,.wea   (pong_wea       )//this port is used by the output port of send buffer ram,only write mode
        ,.addra (pong_addra     )
        ,.dina  (pong_dina      )
        ,.douta (pong_douta     )
        ,.clkb  (prot_clk        )//this port is used by protocol layer,only read mode;
        ,.enb   (pong_enb       )
        ,.web   (pong_web       )
        ,.addrb (pong_addrb     )
        ,.dinb  (pong_dinb      )
        ,.doutb (pong_doutb     )
    );
    
    assign  pong_ena    =   1;
    //aurora link is success,backup ram must be used to cache the datagram which is sent to slave station.
    //ping_pong_flag: 1 link error, 0 link success
    assign  pong_wea    =   (~ping_pong_flag & prot_rd_en_d2) ? 4'b1111 : 4'b0000;
    assign  pong_addra  =   (~ping_pong_flag) ? prot_rd_addr_d2 : 0;
    assign  pong_dina   =   rd_dat;

    assign  pong_enb    =   1;
    assign  pong_web    =   0;
    //aurora link is error,the data cached in backup ram must been send to slave station
    assign  pong_addrb  =   (ping_pong_flag & (prot_wr_en == 0)) ? prot_rd_addr : 0;
    assign  pong_dinb   =   0;
    
    assign  prot_rd_data =   ping_pong_flag ? pong_doutb : rd_dat;

/////////////////////////////////////////////
//receive ram       //
/////////////////////////////////////////////
    gen_ram
    #(
         .RAM_DWIDTH    (RAM_DWIDTH  )
        ,.RAM_DEPTH     (RAM_DEPTH   )
        ,.TYPE          (RAM_TYPE    )
    )
        rcv_ram_u
    (
         .clka  (ll_clk        )
        ,.ena   (rcv_ena       )
        ,.wea   (rcv_wea       )//this port is used by application.only read mode
        ,.addra (rcv_addra     )
        ,.dina  (rcv_dina      )
        ,.douta (rcv_douta     )
        ,.clkb  (prot_clk       )
        ,.enb   (rcv_enb       )//this port is used by protocol layer.only write mode
        ,.web   (rcv_web       )
        ,.addrb (rcv_addrb     )
        ,.dinb  (rcv_dinb      )
        ,.doutb (rcv_doutb     )
    );
    //app:only read
    assign  rcv_ena    =   1;
    assign  rcv_wea    =   0;
    assign  rcv_addra  =   rcv_buf_addra;
    assign  rcv_dina   =   0;
    assign  rcv_buf_douta   =   rcv_douta;
    //protocol layer:only write
    `ifdef SIM_SLVSTA_ONLY
        wire            buf_wr_vld;
        wire    [15:0]  buf_wr_addr;
        wire    [31:0]  buf_wr_data;
        slv_depot_gen_self
            slv_depot_gen_self_u
            (
                 .clk           (prot_clk   )
                ,.reset         (prot_reset )
                
                ,.buf_wr_vld    (buf_wr_vld )
                ,.buf_wr_addr   (buf_wr_addr)
                ,.buf_wr_data   (buf_wr_data)
            );
        assign  rcv_enb    =   1;
        assign  rcv_web    =   buf_wr_vld ? 4'hf : 4'h0;
        assign  rcv_addrb  =   buf_wr_addr;
        assign  rcv_dinb   =   buf_wr_data;
    `else
        assign  rcv_enb    =   1;
        assign  rcv_web    =   prot_wr_en;
        assign  rcv_addrb  =   (prot_wr_en !== 0) ? prot_rd_addr : 0;
        assign  rcv_dinb   =   prot_wr_data;
    `endif

//----------------------compare logic----------------------//
    generate
//        if(WOKE_MODE ==  "MAST") begin:MAST
        if(0) begin:MAST
            wire    [4-1:0]             backup_wea;
            wire    [RAM_AWIDTH-1:0]    backup_addra;
            wire    [RAM_DWIDTH-1:0]    backup_dina;

            wire                        compare_src_vld;
            wire    [RAM_AWIDTH-1:0]    compare_src_addrb;
            wire    [RAM_DWIDTH-1:0]    compare_src_dat;
(* MARK_DEBUG="true" *)wire compare_rslt;
            compare_dat
            #(
                 .RAM_DEPTH     (RAM_DEPTH  )
                ,.RAM_DWIDTH    (RAM_DWIDTH )
            )
            compare_dat_u
            (
                 .clk               (prot_clk        )
                ,.reset             (prot_reset      )

                ,.backup_wea        (backup_wea     )
                ,.backup_addra      (backup_addra   )
                ,.backup_dina       (backup_dina    )

                ,.compare_src_vld   (compare_src_vld)
                ,.compare_src_addrb (compare_src_addrb   )
                ,.compare_src_dat   (compare_src_dat)
                ,.compare_rslt      (compare_rslt   )
            );
            //协议层读出数据的同时同时将数据写入到校验buffer中
            //ping_pong_flag: 1 link error, 0 link success
            assign  backup_wea  =   (prot_rd_en_d2 & (~ping_pong_flag)) ? 4'b1111 : 4'b0000;
            assign  backup_addra=   (prot_rd_en_d2 & (~ping_pong_flag)) ? prot_rd_addr_d2 : 'd0;
            assign  backup_dina =   rd_dat;
            //协议层将数据写入到接收buffer中时同时将备份buffer中的数据读出做比对
            assign  compare_src_vld     =   (prot_wr_en !== 0) ? 1   :   0;//wr operation
            assign  compare_src_addrb   =   (prot_wr_en !== 0) ? prot_rd_addr : 0;//wr operation
            assign  compare_src_dat     =   prot_wr_data;
        end else begin:SLAVE
            
        end
    endgenerate

endmodule

