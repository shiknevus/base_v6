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
module slv_app_rcv
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

    ,output reg         app_rcv_req
    ,input              app_rcv_ack
    
    //receive buffer
    ,output wire                        rcv_buf_ena
    ,output reg     [RAM_AWIDTH-1:0]    rcv_buf_addra
    ,input  wire    [RAM_DWIDTH-1:0]    rcv_buf_douta
    
    ,output reg                         app_cfg_wea
    ,output reg     [RAM_AWIDTH-1:0]    app_cfg_addra
    ,output reg     [RAM_DWIDTH-1:0]    app_cfg_dina

    ,output reg                         driver_cfg_msg_wr_req
    ,input  wire                        driver_cfg_msg_wr_ack
    
    ,output reg                         app_tx_pulse
    ,   (* MARK_DEBUG="true" *) output reg     [31:0]              pre_uuid
    ,   (* MARK_DEBUG="true" *)output reg     [31:0]              cur_uuid
    ,output reg                         ping_pong_flag          //operation buffer:0 ping buffer,1 pong buffer

    ,output reg                         intf_tst_flag
    ,output reg                         tst_sig
);

(* MARK_DEBUG="true" *)    reg [31:0]  work_cnt = 0;
    
    localparam  STM_IDLE        = 'd0;
    localparam  STM_RD_RCV_UID  = 'd1;
    localparam  STM_CK_RCV_UID  = 'd2;
    localparam  STM_GEN_TX_START= 'd3;//notice that tx module could move data to tx depot
    localparam  STM_TX_HS       = 'd4;//this state check that the portocol buffer is busying now?
    localparam  STM_RD_DAT      = 'd7;//read data from protocol buffer to application buffer
    localparam  STM_RD_ONCE_END = 'd8;
    localparam  STM_RD_FINISH   = 'd9;
    localparam  STM_CHECK_RSLT  = 'd10;//this state is no use in slave station mode
    localparam  STM_DRIVER_HS   = 'd11;//handshake with driver module
    localparam  STM_DRIVER_CFG  = 'd12;//config driver module
    localparam  STM_END         = 'd13;
   (* MARK_DEBUG="true" *)    reg [4:0] wk_state  = 'd0;
    reg [4:0] wk_state_d1 = 'd0;
    reg [4:0] wk_state_d2 = 'd0;
    reg         work_cnt_done;
    reg [RAM_DWIDTH-1:0]    rcv_buf_douta_d1;
    reg [15:0]  slv_dg_index;
    reg [7:0]   slv_sta_num_d1;
    reg [7:0]   slv_sta_num_d2;
    reg [RAM_AWIDTH-1:0]    rcv_buf_addra_d1;
    reg [RAM_AWIDTH-1:0]    rcv_buf_addra_d2;
    reg                     rcv_buf_rden = 0;
    reg                     rcv_buf_rden_d1;
    reg                     rcv_buf_rden_d2;
    reg                     cfg_msg_rd_en;
    reg                     cfg_msg_rd_en_d1;
    reg                     cfg_msg_rd_en_d2;
    reg [RAM_AWIDTH-1:0]    cfg_msg_rd_addr;
    reg [RAM_AWIDTH-1:0]    cfg_msg_rd_addr_d1;
    reg [RAM_AWIDTH-1:0]    cfg_msg_rd_addr_d2;
    wire[RAM_DWIDTH-1:0]    cfg_msg_rd_dat;

    reg     [3:0]               app_rslt_wea;
    reg     [RAM_AWIDTH-1:0]    app_rslt_addra;
    reg     [RAM_DWIDTH-1:0]    app_rslt_dina;
    reg     [31:0]              cur_uuid_d1;
   (* MARK_DEBUG="true" *)        reg                         err_flag  =   'd0;
    
    always @(posedge clk)begin
        cur_uuid_d1 <=  cur_uuid;
    end

    always @(posedge clk)begin
        if(((cur_uuid[15:8] - cur_uuid_d1[15:8]) > 1) & (cur_uuid_d1[15:8] !== 0))begin
            err_flag    <=  1;
        end else begin
            err_flag    <=  0;
        end
    end

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
                    if(work_cnt_done)begin
                        wk_state  <=  STM_CK_RCV_UID;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_CK_RCV_UID:begin
                    if(rcv_buf_douta !== rcv_buf_douta_d1)begin
                        wk_state  <=  STM_GEN_TX_START;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_GEN_TX_START:begin
                    wk_state  <=  STM_TX_HS;
                end
                STM_TX_HS:begin
                    if(app_rcv_ack)begin
                        wk_state  <=  STM_RD_DAT;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_RD_DAT:begin
                    if(work_cnt_done)begin
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
                    if(work_cnt_done)begin
                        wk_state  <=  STM_DRIVER_HS;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_DRIVER_HS:begin
                    if(driver_cfg_msg_wr_ack)begin
                        wk_state  <=  STM_DRIVER_CFG;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_DRIVER_CFG:begin
                    if(work_cnt_done)begin
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

    always @(posedge clk)begin
        if(reset)begin
            ping_pong_flag  <=  'd0;
        end else if (wk_state == STM_END) begin
            ping_pong_flag  <=  ~ping_pong_flag;
        end else begin
            ping_pong_flag  <=  ping_pong_flag;
        end
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
            STM_IDLE,STM_END:begin
                driver_cfg_msg_wr_req   <=  0;
            end
            STM_DRIVER_HS:begin
                driver_cfg_msg_wr_req   <=  1;
            end
            default: begin
                driver_cfg_msg_wr_req   <=  driver_cfg_msg_wr_req;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_CHECK_RSLT,STM_RD_RCV_UID,STM_RD_DAT,STM_DRIVER_CFG:begin
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
                work_cnt_done <= (work_cnt == 5 - 1) ? 1'b1 : 1'b0;
            end
            STM_RD_DAT,STM_DRIVER_CFG:begin
                work_cnt_done <= (work_cnt == (each_dg_len>>3) - 1) ? 1'b1 : 1'b0;
//                work_cnt_done <= (work_cnt == 511) ? 1'b1 : 1'b0;
            end
            default: begin
                work_cnt_done <= 1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE,STM_RD_RCV_UID,STM_CK_RCV_UID,STM_GEN_TX_START:begin
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
        if(reset)begin
            cur_uuid    <=  'd0;
            pre_uuid    <=  'd0;
        end else begin
            case(wk_state)
                STM_GEN_TX_START:begin
                    cur_uuid    <=  rcv_buf_douta;
                    pre_uuid    <=  cur_uuid;
                end
                default: begin
                    cur_uuid    <=  cur_uuid;
                    pre_uuid    <=  pre_uuid;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_GEN_TX_START:begin
                app_tx_pulse    <=  1;
            end
            default: begin
                app_tx_pulse    <=  0;
            end
        endcase
    end

    always @(posedge clk)begin
        rcv_buf_rden_d1 <=  rcv_buf_rden;
        rcv_buf_rden_d2 <=  rcv_buf_rden_d1;
    end
    
    always @(posedge clk)begin
        app_rslt_wea    <=  rcv_buf_rden_d2 ? 4'hf : 4'h0;
        app_rslt_addra  <=  rcv_buf_addra_d2;
        app_rslt_dina   <=  rcv_buf_douta;
    end
    
    always @(posedge clk) begin
        case(wk_state)
            STM_DRIVER_CFG:begin
                cfg_msg_rd_addr <=  work_cnt;
                cfg_msg_rd_en   <=  1;
            end
            default: begin
                cfg_msg_rd_addr <=  0;
                cfg_msg_rd_en   <=  0;
            end
        endcase
    end
    
    gen_ram
    #(
         .RAM_DWIDTH    (RAM_DWIDTH  )
        ,.RAM_DEPTH     (RAM_DEPTH   )
        ,.TYPE          ("TRUE"      )
    )
        app_depot_u
        (
             .clka  (clk                )
            ,.ena   (1                  )
            ,.wea   (app_rslt_wea       )
            ,.addra (app_rslt_addra     )
            ,.dina  (app_rslt_dina      )
            ,.douta (                   )
            ,.clkb  (clk        )
            ,.enb   (1                  )
            ,.web   (0                  )
            ,.addrb (cfg_msg_rd_addr    )
            ,.dinb  (                   )
            ,.doutb (cfg_msg_rd_dat     )
        );

    always @(posedge clk)begin
        cfg_msg_rd_addr_d1  <=  cfg_msg_rd_addr;
        cfg_msg_rd_addr_d2  <=  cfg_msg_rd_addr_d1;
        
        cfg_msg_rd_en_d1    <=  cfg_msg_rd_en;
        cfg_msg_rd_en_d2    <=  cfg_msg_rd_en_d1;
        
        
        app_cfg_wea         <=  cfg_msg_rd_en_d2;
        app_cfg_addra       <=  cfg_msg_rd_addr_d2;
        app_cfg_dina        <=  cfg_msg_rd_dat;
    end

    always @(posedge clk)begin
        tst_sig <=  1;
    end

endmodule