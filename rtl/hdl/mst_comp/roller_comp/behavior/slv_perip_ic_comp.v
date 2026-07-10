/////////////////////////////////////////////////////////////////
// Company:
// Engineer:      Luhui
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
module slv_perip_ic_comp
#(
      parameter  TOKEN_DWIDTH    =   1
     ,parameter  COMP_TYPE       =   "IC_MODE"
)
(
     input  wire            clk
    ,input  wire            reset

    ,output reg             ext_dev_req
    ,input  wire            ext_dev_ack

    ,input  wire            perip_req
    ,output reg             perip_ack
    
    ,output reg             mat_in_place    =   'd0
    ,input  wire            comp_done
    ,output wire            comp_error
    ,output wire            extra_opt_done
    ,output reg             virtual_reply   =   'd0

    ,output reg                     v_token_vld =   'd0
    ,output reg [TOKEN_DWIDTH-1:0]  v_token_dat =   'd0
);

    localparam  STM_IDLE                =   'd0;
    localparam  STM_WAIT_PERIP_REQ      =   'd1;
    localparam  STM_GEN_EXT_REQ         =   'd2;
    localparam  STM_WAIT_EXT_ACK        =   'd3;
    localparam  STM_GEN_PERIP_ACK       =   'd4;
    localparam  STM_WAIT_EXT_NOACK      =   'd5;
    localparam  STM_WAIT_DONE           =   'd6;
    localparam  STM_WAIT_TIME           =   'd7;
    localparam  STM_END                 =   'd10;

    `ifdef SIM_PLATFORM_MST
        localparam  WAIT_BEAT_NUM           =   100;
    `else
        localparam  WAIT_BEAT_NUM           =   1000_000_000;
    `endif

    reg         ext_dev_ack_d1  =   'd0;
    reg         ext_dev_ack_d2  =   'd0;
    reg         ext_dev_ack_d3  =   'd0;
    reg         ext_dev_ack_r   =   'd0;
 (* MARK_DEBUG="true" *)   reg [4:0]    wk_state    =   'd0;
    reg     [$clog2(WAIT_BEAT_NUM):0]   wk_cnt      =   'd0;
    reg                 wk_cnt_done;
    reg         latch_comp_done;

    always @(posedge clk)begin
        ext_dev_ack_d1  <=  ~ext_dev_ack;
        ext_dev_ack_d2  <=  ext_dev_ack_d1;
        ext_dev_ack_d3  <=  ext_dev_ack_d2;
        ext_dev_ack_r   <=  ext_dev_ack_d2 & (~ext_dev_ack_d3);
    end

    always @(posedge clk)begin
        virtual_reply   <=  ~virtual_reply;
    end

    assign  comp_error      =   0;
    assign  extra_opt_done  =   1;

    always @(posedge clk)begin
        if(reset)begin
            wk_state    <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE:begin
                    wk_state    <=  STM_WAIT_PERIP_REQ;
                end
                STM_WAIT_PERIP_REQ:begin
                    if(perip_req)begin
                        wk_state    <=  STM_GEN_EXT_REQ;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_GEN_EXT_REQ:begin
                    wk_state    <=  STM_WAIT_EXT_ACK;
                end
                STM_WAIT_EXT_ACK:begin
                    if(wk_cnt_done)begin
                        wk_state    <=  STM_WAIT_TIME;
//                    end else if(ext_dev_ack_r)begin
                    end else if(ext_dev_ack_d3)begin
                        wk_state    <=  STM_GEN_PERIP_ACK;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_GEN_PERIP_ACK:begin
                    wk_state    <=  STM_WAIT_EXT_NOACK;
                end
                STM_WAIT_EXT_NOACK:begin
                    if(~ext_dev_ack_d3)begin
                        wk_state    <=  STM_WAIT_DONE;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_WAIT_DONE:begin
                    if(latch_comp_done)begin
                        wk_state    <=  STM_WAIT_TIME;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_WAIT_TIME:begin
                    if (wk_cnt_done)begin
                        wk_state    <=  STM_END;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_END:begin
                    wk_state    <=  STM_IDLE;
                end
                default:begin
                    wk_state    <=  STM_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            latch_comp_done <=  'd0;
        end else if (wk_state == STM_END) begin
            latch_comp_done <=  'd0;
        end else if (comp_done & ((wk_state == STM_WAIT_EXT_NOACK) | (wk_state == STM_WAIT_DONE)))begin
            latch_comp_done <=  'd1;
        end else begin
            latch_comp_done <=  latch_comp_done;
        end
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_WAIT_TIME,STM_WAIT_EXT_ACK:begin
                if(wk_cnt_done)begin
                    wk_cnt  <=  'd0;
                end else begin
                    wk_cnt  <=  wk_cnt + 'd1;
                end
            end
            default:begin
                wk_cnt  <=  'd0;
            end
        endcase
    end

    always @( * )begin
        case(wk_state)
            STM_WAIT_TIME,STM_WAIT_EXT_ACK:begin
                wk_cnt_done <=  (wk_cnt == WAIT_BEAT_NUM) ? 1'b1 : 1'b0;
            end
            default:begin
                wk_cnt_done <=  1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_GEN_EXT_REQ,STM_WAIT_EXT_ACK,STM_GEN_PERIP_ACK:begin
                ext_dev_req <=  'd0;
            end
            STM_WAIT_EXT_NOACK:begin
                if(~ext_dev_ack_d3)begin
                    ext_dev_req <=  'd1;
                end else begin
                    ext_dev_req <=  'd0;
                end
            end
            default:begin
                ext_dev_req <=  'd1;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_GEN_PERIP_ACK:begin
                perip_ack   <=  1;
            end
            default:begin
                perip_ack   <=  0;
            end
        endcase
    end

    generate
        if(COMP_TYPE ==  "IC_MODE") begin:IC_MODE
            always @(posedge clk)begin
                case(wk_state)
                    STM_WAIT_EXT_NOACK:begin
                        if(~ext_dev_ack_d3)begin
                            mat_in_place<=  1;
                        end else begin
                            mat_in_place<=  0;
                        end
                    end
                    default:begin
                        mat_in_place<=  0;
                    end
                endcase
            end
            
            always @(posedge clk)begin
                v_token_vld <=  0;
                v_token_dat <=  0;
            end
        end else if(COMP_TYPE ==  "OC_MODE") begin:OC_MODE
            always @(posedge clk)begin
                mat_in_place<=  ~mat_in_place;
                v_token_vld <=  ~v_token_vld;
                v_token_dat <=  v_token_dat + 1;
            end
        end
    endgenerate
endmodule