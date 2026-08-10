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
module mst_app_send
#(
     parameter  RAM_DEPTH   =   4096
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
)
(
     input              clk
    ,input              reset
    
    ,input              link_success
    ,input  wire[7:0]   slv_sta_num     //this signals only update during first initial datagram.It indicate the number of slave station
    
    ,input      [15:0]  each_dg_len

    ,output reg         app_send_req
    ,input              app_send_ack

    //send buffer
    ,output wire                        send_buf_ena
    ,output reg     [4-1:0]             send_buf_wea
    ,output reg     [RAM_AWIDTH-1:0]    send_buf_addra
    ,output reg     [RAM_DWIDTH-1:0]    send_buf_dina

    ,output reg                         slv_cfg_msg_rden
    ,output reg     [RAM_AWIDTH-1:0]    slv_cfg_msg_addr
    ,input  wire    [RAM_DWIDTH-1:0]    slv_cfg_msg_dat

    ,input  wire    [RAM_AWIDTH-1:0]    jtag_slv_cfg_msg_addr
    ,input  wire    [RAM_DWIDTH-1:0]    jtag_slv_cfg_msg_dat
    //ps depot inteface
    ,input  wire                        ps_tst_trsf_port
    ,input  wire                        ps_trsf_port_en
    ,input  wire                        ps_tx_req
    ,output reg                         ps_tx_ack

    ,output reg     [RAM_AWIDTH-1:0]    ps_tx_depot_addr
    ,input  wire    [RAM_DWIDTH-1:0]    ps_tx_depot_dout

    ,output reg            app_trsf_en
    
    ,output reg [31:0]                  cur_tx_trsf_pkg_id = 0
    ,output reg                         tx_dg_done
    ,input                              rx_dg_done
    ,output reg [31:0]                  stat_rslt
    ,output reg         tst_sig
);

    reg [31:0]  work_cnt = 0;

    localparam  STM_IDLE            = 'd0;
    localparam  STM_WAIT_PS_REQ     = 'd1;
    localparam  STM_TX_HS_TST       = 'd11;
    localparam  STM_TX_HS           = 'd2;
    localparam  STM_GEN_DAT         = 'd3;
    localparam  STM_GEN_ONCE_END    = 'd4;
    localparam  STM_GEN_FINISH      = 'd5;
    localparam  STM_RD_PS_DEPOT     = 'd6;
    localparam  STM_RD_PS_DEPOT_END = 'd7;
    localparam  STM_WAIT_PS_FINISH  = 'd8;
    localparam  STM_TX_POST_PRCS    = 'd9;
    localparam  STM_END             = 'd10;
    reg [4:0] wk_state  = 'd0;
    reg [4:0] wk_state_d1 = 'd0;
    reg [4:0] wk_state_d2 = 'd0;
    reg [4:0] wk_state_d3 = 'd0;
    reg [4:0] wk_state_d4 = 'd0;
    reg         gen_dat_done;
    reg [7:0]   slv_sta_num_d1;
    reg [7:0]   slv_sta_num_d2;
    reg [15:0]  slv_dg_index;
    reg [15:0]  frm_cnt;
    reg [7:0]   wait_cnt = 0;
    reg         wait_cnt_done;
    reg link_success_d1;
    reg link_success_d2;
    reg link_success_d3;
    reg link_success_r;
    reg ps_tx_req_d1;
    reg ps_tx_req_d2;
    reg ps_tx_req_r;
    reg ps_tx_req_latch;
    reg ps_trsf_port_en_d1;
    reg ps_trsf_port_en_d2;
    reg ps_tst_trsf_port_d1;
    reg ps_tst_trsf_port_d2;
    reg [RAM_AWIDTH-1:0]    ps_tx_depot_addr_reg;
    reg [RAM_AWIDTH-1:0]    ps_tx_depot_addr_d1;
    reg [RAM_AWIDTH-1:0]    ps_tx_depot_addr_d2;
    reg [RAM_AWIDTH-1:0]    slv_cfg_msg_addr_d1;
    reg [RAM_AWIDTH-1:0]    slv_cfg_msg_addr_d2;
    reg [RAM_AWIDTH-1:0]    slv_cfg_msg_addr_d3;
    reg                     rx_dg_done_d1;
    reg                     rx_dg_done_r;
    
    reg                     slv_cfg_msg_vld;
    reg [31:0]              stat_cnt    =   'd0;    //statistical counter
    
    always @(posedge clk)begin
        ps_tx_depot_addr_d1 <=  ps_tx_depot_addr_reg;
        ps_tx_depot_addr_d2 <=  ps_tx_depot_addr_d1;
    end
    
    always @(posedge clk)begin
        slv_cfg_msg_addr_d1 <=  slv_cfg_msg_addr;
        slv_cfg_msg_addr_d2 <=  slv_cfg_msg_addr_d1;
        slv_cfg_msg_addr_d3 <=  slv_cfg_msg_addr_d2;
    end
    
    always @(posedge clk)begin
        slv_sta_num_d1  <=  slv_sta_num;
        slv_sta_num_d2  <=  slv_sta_num_d1;
    end
    
    always @(posedge clk)begin
        wk_state_d1 <=  wk_state;
        wk_state_d2 <=  wk_state_d1;
        wk_state_d3 <=  wk_state_d2;
        wk_state_d4 <=  wk_state_d3;
    end

    always @(posedge clk)begin
        ps_tx_req_d1    <=  ps_tx_req;
        ps_tx_req_d2    <=  ps_tx_req_d1;
        ps_tx_req_r     <=  (ps_tx_req_d1) & (~ps_tx_req_d2);
    end

    always @(posedge clk)begin
        if(reset)begin
            ps_tx_req_latch <=  'd0;
        end else if(ps_tx_req_r)begin
            ps_tx_req_latch <=  'd1;
        end else if(wk_state == STM_WAIT_PS_REQ)begin
            ps_tx_req_latch <=  'd0;
        end else begin
            ps_tx_req_latch <=  ps_tx_req_latch;
        end
    end

    always @(posedge clk)begin
        ps_trsf_port_en_d1  <=  ps_trsf_port_en;
        ps_trsf_port_en_d2  <=  ps_trsf_port_en_d1;
        ps_tst_trsf_port_d1 <=  ps_tst_trsf_port;
        ps_tst_trsf_port_d2 <=  ps_tst_trsf_port_d1;
    end

    always @(posedge clk)begin
        rx_dg_done_d1   <=  rx_dg_done;
        rx_dg_done_r    <=  (rx_dg_done) & (~rx_dg_done_d1);
    end

    always @(posedge clk) begin
        if(reset | link_success_r)begin
          wk_state  <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE: begin
                    if((link_success_d3 & ps_trsf_port_en_d2) & (~ps_tst_trsf_port_d2)) begin
                        wk_state  <=  STM_TX_HS;
                    end else if((link_success_d3 & ps_trsf_port_en_d2) & (ps_tst_trsf_port_d2)) begin
                        wk_state  <=  STM_WAIT_PS_REQ;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_WAIT_PS_REQ:begin
                    if(ps_tx_req_latch)begin
                        wk_state  <=  STM_TX_HS_TST;
                    end else if (~ps_tst_trsf_port_d2) begin//while ps configure pl to exit the test mode
                        wk_state  <=  STM_TX_HS;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_TX_HS:begin
                    if(app_send_ack)begin//handshake with protocol layer's depot 
                        wk_state  <=  STM_GEN_DAT;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_TX_HS_TST:begin
                    if(app_send_ack)begin//When ps is requesting to tx operation
                        wk_state  <=  STM_RD_PS_DEPOT;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_GEN_DAT:begin
                    if(gen_dat_done)begin
                        wk_state  <=  STM_GEN_ONCE_END;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_GEN_ONCE_END:begin
                    if(((slv_sta_num_d2 ==0)) || (slv_dg_index == (slv_sta_num_d2 - 1)))begin
                        wk_state  <=  STM_GEN_FINISH;
                    end else begin
                        wk_state  <=  STM_GEN_DAT;
                    end
                end
                STM_GEN_FINISH:begin
                    if(rx_dg_done_r)begin
                        wk_state  <=  STM_TX_POST_PRCS;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_RD_PS_DEPOT:begin
                    if(gen_dat_done)begin
                        wk_state  <=  STM_RD_PS_DEPOT_END;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_RD_PS_DEPOT_END:begin
                    if(wait_cnt_done)begin
                        wk_state  <=  STM_WAIT_PS_FINISH;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_WAIT_PS_FINISH:begin
                    if(rx_dg_done_r)begin
                        wk_state  <=  STM_TX_POST_PRCS;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_TX_POST_PRCS:begin//2 to 1
                    if(gen_dat_done)begin
                        wk_state  <=  STM_END;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_END:begin
                    wk_state  <=  STM_IDLE;
                end
                default: begin
                    wk_state  <=  STM_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_RD_PS_DEPOT_END:begin
                tx_dg_done    <=  1;
            end
            default: begin
                tx_dg_done    <=  0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_RD_PS_DEPOT_END:begin
                wait_cnt    <=  wait_cnt + 1;
            end
            default: begin
                wait_cnt    <=  0;
            end
        endcase
    end

    always @( * ) begin
        case(wk_state)
            STM_RD_PS_DEPOT_END:begin
                wait_cnt_done   <=  (wait_cnt == 100) ? 1 : 0;
            end
            default: begin
                wait_cnt_done   <=  0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE,STM_TX_POST_PRCS:begin
                ps_tx_ack   <=  0;
            end
            STM_RD_PS_DEPOT_END:begin
                ps_tx_ack   <=  1;
            end
            default: begin
                ps_tx_ack   <=  ps_tx_ack;
            end
        endcase
    end

    always @(posedge clk) begin
        if(reset)begin
            frm_cnt <=  'd0;
        end else if(wk_state == STM_END)begin
            frm_cnt <=  frm_cnt + 'd1;
        end else begin
            frm_cnt <=  frm_cnt;
        end
    end
    
    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE,STM_GEN_FINISH,STM_RD_PS_DEPOT_END:begin
                app_send_req    <=  0;
            end
            STM_TX_HS,STM_TX_HS_TST:begin
                app_send_req    <=  1;
            end
            default: begin
                app_send_req  <=  app_send_req;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_GEN_DAT,STM_TX_POST_PRCS,STM_RD_PS_DEPOT:begin
                work_cnt <= work_cnt + 1;
            end
            default: begin
                work_cnt  <=  0;
            end
        endcase
    end
    
    always @ ( * )begin
        case(wk_state)
            STM_GEN_DAT:begin
                gen_dat_done <= (work_cnt == (each_dg_len>>3) - 1) ? 1'b1 : 1'b0;
            end
            STM_RD_PS_DEPOT:begin
                gen_dat_done <= (work_cnt == {slv_sta_num_d2,9'd0} - 1) ? 1'b1 : 1'b0;
            end
            STM_TX_POST_PRCS:begin
                gen_dat_done <= (work_cnt == 31'd100 - 1) ? 1'b1 : 1'b0;
            end
            default: begin
                gen_dat_done <= 1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_RD_PS_DEPOT:begin
                ps_tx_depot_addr_reg    <=  work_cnt;
            end
            default: begin
                ps_tx_depot_addr_reg    <=  'd0;
            end
        endcase
    end
    
    always @(posedge clk)begin
        ps_tx_depot_addr    <=  ps_tx_depot_addr_reg;
    end

    assign  send_buf_ena    =   1;
    
    always @(posedge clk)begin
        case(wk_state)
            STM_GEN_DAT:begin
                slv_cfg_msg_rden    <=  'd1;
                slv_cfg_msg_addr    <=  work_cnt + {slv_dg_index,{$clog2(`EACH_CHILD_DEPOT_SIZE){1'b0}}};
            end
            default: begin
                slv_cfg_msg_rden    <=  'd0;
                slv_cfg_msg_addr    <=  0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state_d4)
            STM_GEN_DAT:begin
                slv_cfg_msg_vld <=  'd1;
            end
            default: begin
                slv_cfg_msg_vld <=  'd0;
            end
        endcase
    end

    always @(posedge clk)begin
        if(wk_state_d4 == STM_GEN_DAT)begin
            send_buf_wea    <= 4'b1111;
            send_buf_addra  <=  slv_cfg_msg_addr_d3;
        end else if (wk_state_d3 == STM_RD_PS_DEPOT)begin
            send_buf_wea    <=  4'b1111;
            send_buf_addra  <=  ps_tx_depot_addr_d2;
        end else begin
            send_buf_wea    <= 4'd0;
            send_buf_addra  <=  0;
        end
    end

    always @(posedge clk)begin
        if(wk_state_d4 == STM_GEN_DAT)begin
            if(slv_cfg_msg_addr_d3[($clog2(`EACH_CHILD_DEPOT_SIZE)-1):0] == 0) begin
                send_buf_dina   <=  {4'h0,12'heef,frm_cnt[7:0],slv_dg_index[7:0]};
            end else if (slv_cfg_msg_addr_d3 == jtag_slv_cfg_msg_addr)begin
                send_buf_dina   <=  jtag_slv_cfg_msg_dat;
            end else begin
                send_buf_dina   <=  slv_cfg_msg_dat;
            end
        end else if ((wk_state_d3 == STM_RD_PS_DEPOT) | (wk_state_d3 == STM_RD_PS_DEPOT_END))begin
            if(ps_tx_depot_addr_d2[($clog2(`EACH_CHILD_DEPOT_SIZE)-1):0] == 0)begin
                send_buf_dina   <=  {4'h1,12'heef,frm_cnt[7:0],8'hcc};
            end else begin
                send_buf_dina   <=  ps_tx_depot_dout;
            end
        end else begin
            send_buf_dina   <=  0;
        end
    end

    always @(posedge clk)begin
        case(wk_state_d3)
//            STM_IDLE:begin
//                cur_tx_trsf_pkg_id <=  'd0;
//            end
            STM_GEN_DAT:begin
                if(slv_cfg_msg_addr_d2  == 0) begin
                    cur_tx_trsf_pkg_id <=  {4'h0,12'heef,frm_cnt[7:0],slv_dg_index[7:0]};
                end else begin
                    cur_tx_trsf_pkg_id <=  cur_tx_trsf_pkg_id;
                end
            end
            STM_RD_PS_DEPOT,STM_RD_PS_DEPOT_END:begin
                if(ps_tx_depot_addr_d2[($clog2(`EACH_CHILD_DEPOT_SIZE)-1):0] == 0)begin
                    cur_tx_trsf_pkg_id <=  {4'h1,12'heef,frm_cnt[7:0],8'hcc};
                end else begin
                    cur_tx_trsf_pkg_id <=  cur_tx_trsf_pkg_id;
                end
            end
            default: begin
                cur_tx_trsf_pkg_id <=  cur_tx_trsf_pkg_id;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE,STM_GEN_FINISH:begin
                slv_dg_index    <=  'd0;
            end
            STM_GEN_ONCE_END:begin
                slv_dg_index    <=  slv_dg_index    +   1;
            end
            default: begin
                slv_dg_index    <=  slv_dg_index;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_GEN_DAT,STM_GEN_ONCE_END,STM_GEN_FINISH:begin//normal
                stat_cnt    <=  stat_cnt + 1;
            end
            STM_RD_PS_DEPOT,STM_RD_PS_DEPOT_END,STM_WAIT_PS_FINISH:begin
                stat_cnt    <=  stat_cnt + 1;
            end
            STM_TX_POST_PRCS:begin
                stat_cnt    <=  stat_cnt;
            end
            default: begin
                stat_cnt    <=  0;
            end
        endcase
    end

    always @(posedge clk)begin
        if(reset)begin
            stat_rslt   <=  0;
        end else if (wk_state == STM_TX_POST_PRCS) begin
            stat_rslt   <=  stat_cnt;
        end else begin
            stat_rslt   <=  stat_rslt;
        end
    end

    always @(posedge clk)begin
        tst_sig <=  & (frm_cnt);
    end

    always @(posedge clk)begin
        link_success_d1 <=  link_success;
        link_success_d2 <=  link_success_d1;
        link_success_d3 <=  link_success_d2;
        link_success_r  <=  link_success_d2 & (~link_success_d3);
    end
    
    `ifdef SIM_PLATFORM_MST
        localparam  DLY_CYCLE_NUM   =   100;
    `else
        localparam  DLY_CYCLE_NUM   =   1_000_000;
    `endif
    reg [31:0]  trsf_dly_cnt     =   'd0;
    reg         trsf_dly_cnt_en  =   'd0;
    always @(posedge clk)begin
        if(reset)begin
            trsf_dly_cnt_en <=  'd0;
        end else if (link_success_r) begin
            trsf_dly_cnt_en <=  'd1;
        end else begin
            trsf_dly_cnt_en <=  trsf_dly_cnt_en;
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            trsf_dly_cnt    <=  'd0;
        end else if (trsf_dly_cnt_en) begin
            if (trsf_dly_cnt == DLY_CYCLE_NUM) begin
                trsf_dly_cnt    <=  trsf_dly_cnt;
            end else begin
                trsf_dly_cnt    <=  trsf_dly_cnt + 1;
            end
        end else begin
            trsf_dly_cnt    <=  trsf_dly_cnt;
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            app_trsf_en <=  1'b0;
        end else begin
            app_trsf_en <=  (trsf_dly_cnt == DLY_CYCLE_NUM) ? 1'b1 : 1'b0;
        end
    end

endmodule