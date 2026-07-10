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
module mst_intf
#(
      parameter  TOKEN_DWIDTH    =   16
)
(
     input  wire            clk
    ,input  wire            reset
    ,input  wire            comp_wk_en
    
    ,output reg             ext_dev_req
    ,input  wire            ext_dev_ack

    ,emcc_token_if.sp       s1_token_if
);

    localparam  WAIT_BEAT_NUM           =   100_000_000;

    localparam  STM_IDLE                =   'd0;
    localparam  STM_JUDGE_UPS_TOKEN     =   'd1;
    localparam  STM_GEN_EXT_REQ         =   'd2;
    localparam  STM_WAIT_EXT_ACK        =   'd3;
    localparam  STM_WAIT_PERIP_REQ      =   'd4;
    localparam  STM_DEBOUNCE            =   'd5;
    localparam  STM_GEN_RDY_TO_UPS      =   'd6;
    localparam  STM_WAIT_MAT_IN_PLACE   =   'd7;
    localparam  STM_IN_TRSF_SUCCESS     =   'd8;
    localparam  STM_END                 =   'd10;

    reg         ext_dev_ack_d1  =   'd0;
    reg         ext_dev_ack_d2  =   'd0;
 (* MARK_DEBUG="true" *)   reg [4:0]    wk_state    =   'd0;
    reg     [$clog2(WAIT_BEAT_NUM):0]   wk_cnt      =   'd0;
    reg                 wk_cnt_done;

    always @(posedge clk)begin
        ext_dev_ack_d1  <=  ext_dev_ack;
        ext_dev_ack_d2  <=  ext_dev_ack_d1;
    end

    always @(posedge clk)begin
        if(reset)begin
            wk_state    <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE:begin
                    if(comp_wk_en)begin
                        wk_state    <=  STM_JUDGE_UPS_TOKEN;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_JUDGE_UPS_TOKEN:begin
                    if (s1_token_if.wvalid)begin
                        wk_state    <=  STM_GEN_EXT_REQ;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_GEN_EXT_REQ:begin
                    wk_state    <=  STM_WAIT_EXT_ACK;
                end
                STM_WAIT_EXT_ACK:begin
                    if(ext_dev_ack_d2)begin
                        wk_state    <=  STM_DEBOUNCE;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_DEBOUNCE:begin
                    if(~ext_dev_ack_d2)begin
                        wk_state    <=  STM_WAIT_EXT_ACK;
                    end else if (wk_cnt_done & ext_dev_ack_d2) begin
                        wk_state    <=  STM_GEN_RDY_TO_UPS;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_GEN_RDY_TO_UPS:begin
                    wk_state    <=  STM_WAIT_MAT_IN_PLACE;
                end
                STM_WAIT_MAT_IN_PLACE:begin
                    if(~ext_dev_ack_d2)begin
                        wk_state    <=  STM_IN_TRSF_SUCCESS;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_IN_TRSF_SUCCESS:begin
                    if(s1_token_if.bready)begin
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
        case(wk_state)
            STM_DEBOUNCE:begin
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
            STM_DEBOUNCE:begin
                wk_cnt_done <=  (wk_cnt == WAIT_BEAT_NUM) ? 1'b1 : 1'b0;
            end
            default:begin
                wk_cnt_done <=  1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_GEN_RDY_TO_UPS:begin//in behavior interrupt to ps
                s1_token_if.wready   <=  1'b1;
            end
            default:begin
                s1_token_if.wready   <=  1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IN_TRSF_SUCCESS:begin
                if(s1_token_if.bready)begin
                    s1_token_if.bvalid  <=  1'b0;
                    s1_token_if.bresp   <=  'd0;
                end else begin
                    s1_token_if.bvalid  <=  1'b1;
                    s1_token_if.bresp   <=  'd1;
                end
            end
            default:begin
                s1_token_if.bvalid  <=  1'b0;
                s1_token_if.bresp   <=  'd0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_GEN_EXT_REQ,STM_WAIT_EXT_ACK,STM_DEBOUNCE,STM_GEN_RDY_TO_UPS,STM_WAIT_MAT_IN_PLACE:begin
                ext_dev_req <=  'd1;
            end
            default:begin
                ext_dev_req <=  'd0;
            end
        endcase
    end
endmodule