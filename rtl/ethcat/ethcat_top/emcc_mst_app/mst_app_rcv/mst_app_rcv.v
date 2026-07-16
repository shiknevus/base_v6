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
`include  "depot_addr_map.vh"
module mst_app_rcv
#(
     parameter  RAM_DEPTH   =   4096
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
    ,parameter  PKG_NUM     =   RAM_DEPTH
)
(
     input              clk
    ,input              reset
    
    ,input  wire[7:0]   slv_sta_num     //this signals only update during first initial datagram.It indicate the number of slave station
    
    ,input      [15:0]  each_dg_len
    
//while ps test module,rx module generate rx interrupt,PS clear tx module to idle,and then this signal was reset to 0
    ,input  wire[31:0]  cur_tx_trsf_pkg_id

    ,output reg         app_rcv_req
    ,input              app_rcv_ack
    
    //receive buffer
    ,output wire                        rcv_buf_ena
    ,output reg     [RAM_AWIDTH-1:0]    rcv_buf_addra
    ,input  wire    [RAM_DWIDTH-1:0]    rcv_buf_douta
    
    ,input  wire                        ps_rd_depot_flag
    ,output reg                         rcv_intf_tst_dg_done
    ,output reg                         rx_dg_done
    ,output wire    [3:0]               slv_sta_msg_vld     //slave station status message
    ,output wire    [RAM_AWIDTH-1:0]    slv_sta_msg_addr
    ,output wire    [RAM_DWIDTH-1:0]    slv_sta_msg_dat

    ,output reg     [3:0]               ps_depot_we     //slave station status message
    ,output reg     [RAM_AWIDTH-1:0]    ps_depot_addr
    ,output reg     [RAM_DWIDTH-1:0]    ps_depot_din
);

    reg [31:0]  work_cnt = 0;

    localparam  STM_IDLE        = 'd0;
    localparam  STM_RD_RCV_UID  = 'd1;
    localparam  STM_CK_RCV_UID  = 'd2;
    localparam  STM_TX_HS       = 'd3;
    localparam  STM_CK_PS_MODE  = 'd4;
    localparam  STM_RD_DAT      = 'd7;
    localparam  STM_RD_ONCE_END = 'd8;
    localparam  STM_RD_FINISH   = 'd9;
    localparam  STM_CHECK_RSLT  = 'd10;
    localparam  STM_ID_UNMATCH  = 'd11;
    localparam  STM_END         = 'd12;
    reg [4:0] wk_state  = 'd0;
    reg [4:0] wk_state_d1 = 'd0;
    reg [4:0] wk_state_d2 = 'd0;
    reg         gen_dat_done;
	reg [RAM_DWIDTH-1:0]    rcv_buf_douta_d1;
    reg [15:0]  slv_dg_index;
    reg [7:0]   slv_sta_num_d1;
    reg [7:0]   slv_sta_num_d2;
    reg [RAM_AWIDTH-1:0]    rcv_buf_addra_d1;
    reg [RAM_AWIDTH-1:0]    rcv_buf_addra_d2;
    reg                     rcv_buf_rden = 0;
    reg                     rcv_buf_rden_d1;
    reg                     rcv_buf_rden_d2;
    reg                     latch_ps_rd_depot_flag;

    reg [3:0]               app_rslt_wea;
    reg [RAM_AWIDTH-1:0]    app_rslt_addra;
    reg [RAM_DWIDTH-1:0]    app_rslt_dina;
    reg                     intf_tst_flag;

    always @(posedge clk)begin
        slv_sta_num_d1  <=  slv_sta_num;
        slv_sta_num_d2  <=  slv_sta_num_d1;
    end

    always @(posedge clk)begin
        rcv_buf_addra_d1  <=  rcv_buf_addra;
        rcv_buf_addra_d2  <=  rcv_buf_addra_d1;
    end

    always @(posedge clk)begin
        rcv_buf_douta_d1    <=  rcv_buf_douta;
    end

    always @(posedge clk)begin
        wk_state_d1 <=  wk_state;
        wk_state_d2 <=  wk_state_d1;
    end
    
    always @(posedge clk) begin
        if(reset)begin
          wk_state  <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE: begin
                    if(1) begin
                        wk_state  <=  STM_RD_RCV_UID;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_RD_RCV_UID:begin
                    if(gen_dat_done)begin
                        wk_state  <=  STM_CK_RCV_UID;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_CK_RCV_UID:begin
                    if(rcv_buf_douta !== rcv_buf_douta_d1)begin
                        if(rcv_buf_douta == cur_tx_trsf_pkg_id)begin
                            wk_state  <=  STM_TX_HS;
                        end else begin
                            wk_state  <=  STM_ID_UNMATCH;
                        end
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_TX_HS:begin
                    if(app_rcv_ack)begin
                        wk_state  <=  STM_CK_PS_MODE;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_CK_PS_MODE:begin
                    wk_state  <=  STM_RD_DAT;
                end
                STM_RD_DAT:begin
                    if(gen_dat_done)begin
                        wk_state  <=  STM_RD_ONCE_END;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_RD_ONCE_END:begin
                    if(slv_dg_index == (slv_sta_num_d2 - 1))begin
                        wk_state  <=  STM_RD_FINISH;
                    end else begin
                        wk_state  <=  STM_RD_DAT;
                    end
                end
                STM_RD_FINISH:begin
                    wk_state  <=  STM_CHECK_RSLT;
                end
                STM_CHECK_RSLT:begin
                    if(gen_dat_done)begin
                        wk_state  <=  STM_END;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_ID_UNMATCH:begin
                    wk_state  <=  STM_IDLE;
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
            STM_IDLE:begin
                intf_tst_flag   <=  0;
            end
            STM_CK_RCV_UID:begin
                if(rcv_buf_douta !== rcv_buf_douta_d1)begin
                    intf_tst_flag       <=  (rcv_buf_douta[31:28] == 4'd1) ? 1'b1 : 1'b0;
                end else begin
                    intf_tst_flag   <=  intf_tst_flag;
                end
            end
            default: begin
                intf_tst_flag   <=  intf_tst_flag;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_CHECK_RSLT:begin
                rcv_intf_tst_dg_done    <=  intf_tst_flag;
                rx_dg_done              <=  1;
            end
            default: begin
                rcv_intf_tst_dg_done    <=  0;
                rx_dg_done              <=  0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE:begin
                latch_ps_rd_depot_flag  <=  0;
            end
            STM_CK_PS_MODE:begin
                latch_ps_rd_depot_flag  <=  ps_rd_depot_flag;
            end
            default: begin
                latch_ps_rd_depot_flag  <=  latch_ps_rd_depot_flag;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE,STM_RD_FINISH:begin
                slv_dg_index    <=  'd0;
            end
            STM_RD_ONCE_END:begin
                slv_dg_index    <=  slv_dg_index    +   1;
            end
            default: begin
                slv_dg_index    <=  slv_dg_index;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE,STM_CHECK_RSLT:begin
                app_rcv_req    <=  0;
            end
            STM_TX_HS:begin
                app_rcv_req    <=  1;
            end
            default: begin
                app_rcv_req  <=  app_rcv_req;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_CHECK_RSLT,STM_RD_RCV_UID,STM_RD_DAT:begin
                work_cnt <= work_cnt + 1;
            end
            default: begin
                work_cnt  <=  0;
            end
        endcase
    end
    
    always @ ( * )begin
        case(wk_state)
            STM_CHECK_RSLT,STM_RD_RCV_UID:begin
                gen_dat_done <= (work_cnt == 100 - 1) ? 1'b1 : 1'b0;
            end
            STM_RD_DAT:begin
                if(latch_ps_rd_depot_flag)begin//PS is reading depot,so APP only update commin IO part.
                    gen_dat_done <= (work_cnt == `DEPOT_BIAS_RS232_1ST - 1) ? 1'b1 : 1'b0;
                end else begin//PS is not reading depot,so APP need update comman IO part and ps_depot.
                    gen_dat_done <= (work_cnt == (each_dg_len>>3) - 1) ? 1'b1 : 1'b0;
                end
            end
            default: begin
                gen_dat_done <= 1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE,STM_RD_RCV_UID,STM_CK_RCV_UID:begin
                rcv_buf_addra   <=  'd0;
            end
            STM_RD_DAT:begin
                rcv_buf_addra  <=  work_cnt + {slv_dg_index,{$clog2(`EACH_CHILD_DEPOT_SIZE){1'b0}}};
            end
            default: begin
                rcv_buf_addra   <=  rcv_buf_addra;
            end
        endcase
    end
    assign  rcv_buf_ena =   1;
    
    always @(posedge clk)begin
        case(wk_state)
            STM_RD_DAT:begin
                rcv_buf_rden    <=  'd1;
            end
            default: begin
                rcv_buf_rden    <=  0;
            end
        endcase
    end
    
    always @(posedge clk)begin
        rcv_buf_rden_d1 <=  rcv_buf_rden;
        rcv_buf_rden_d2 <=  rcv_buf_rden_d1;
    end
    
    always @(posedge clk)begin
        if(intf_tst_flag)begin
            app_rslt_wea    <=  0;
            app_rslt_addra  <=  0;
            app_rslt_dina   <=  0;
        end else begin
            app_rslt_wea    <=  rcv_buf_rden_d2 ? 4'hf : 4'h0;
            app_rslt_addra  <=  rcv_buf_addra_d2;
            app_rslt_dina   <=  rcv_buf_douta;
        end
    end

    assign  slv_sta_msg_vld     =   app_rslt_wea;
    assign  slv_sta_msg_addr    =   app_rslt_addra;
    assign  slv_sta_msg_dat     =   (app_rslt_wea == 4'hf) ? app_rslt_dina : 'd0;

    always @(posedge clk)begin
            ps_depot_we     <=  (rcv_buf_rden_d2) ? 4'hf : 4'h0;
            ps_depot_addr   <=  (rcv_buf_rden_d2) ? rcv_buf_addra_d2 : 'd0;
            ps_depot_din    <=  (rcv_buf_rden_d2) ? rcv_buf_douta : 'd0;
    end

endmodule