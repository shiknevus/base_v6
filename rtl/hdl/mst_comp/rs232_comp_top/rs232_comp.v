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
//  master station rs232 components
/////////////////////////////////////////////////////////////////
module rs232_comp
#(
     parameter  RAM_DEPTH   =   4096
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
)
(
     input              clk
    ,input              reset
    
    ,output reg         ps_opt_deopt_flag
    
    ,input  wire    [RAM_AWIDTH-1:0]    comp_bias_addr
    ,input  wire                        msg_vld
    ,input  wire    [RAM_AWIDTH-1:0]    msg_addr
    ,output wire    [RAM_DWIDTH-1:0]    msg_dat
    ,output reg         tst_sig
);

(* MARK_DEBUG="true" *)    reg [31:0]  work_cnt = 0;

    localparam  STM_IDLE        = 'd0;
    localparam  STM_RD_RCV_UID  = 'd1;
    localparam  STM_TX_HS       = 'd2;
    localparam  STM_CK_RCV_UID  = 'd6;
    localparam  STM_RD_DAT      = 'd7;
    localparam  STM_RD_ONCE_END = 'd8;
    localparam  STM_RD_FINISH   = 'd9;
    localparam  STM_CHECK_RSLT  = 'd10;
    localparam  STM_END         = 'd12;
   (* MARK_DEBUG="true" *)    reg [4:0] wk_state  = 'd0;

    reg [31:0]  pre_uuid    =   'd0;
    reg [31:0]  cur_uuid    =   'd0;
    always @(posedge clk)begin
        if(reset)begin
            cur_uuid    <=  'd0;
            pre_uuid    <=  'd0;
        end else if(msg_vld & (msg_addr == comp_bias_addr))begin
            cur_uuid    <=  msg_dat;
            pre_uuid    <=  cur_uuid;
        end else begin
            cur_uuid    <=  cur_uuid;
            pre_uuid    <=  pre_uuid;
        end
    end





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
                        wk_state  <=  STM_TX_HS;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_TX_HS:begin
                    if(app_rcv_ack)begin
                        wk_state  <=  STM_RD_DAT;
                    end else begin
                        wk_state  <=  wk_state;
                    end
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
                gen_dat_done <= (work_cnt == 5 - 1) ? 1'b1 : 1'b0;
            end
            STM_RD_DAT:begin
                gen_dat_done <= (work_cnt == (each_dg_len>>3) - 1) ? 1'b1 : 1'b0;
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
        app_rslt_wea    <=  rcv_buf_rden_d2 ? 4'hf : 4'h0;
        app_rslt_addra  <=  rcv_buf_addra_d2;
        app_rslt_dina   <=  rcv_buf_douta;
    end

    always @(posedge clk)begin
        msg_wr_req  <=  'd1;
    end

//这个ram的B端口可以慢慢读，不影响协议层的数据传输
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
            ,.addrb (sta_msg_rd_addr    )
            ,.dinb  (                   )
            ,.doutb (sta_msg_rd_dat     )
        );
/* */
    
    
    
    always @(posedge clk)begin
        tst_sig <=  1;
    end

endmodule