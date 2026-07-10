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
module mst_perip_comp
#(

)
(
     input wire                        clk
    ,input wire                        reset

    ,input  wire                       comp_irq
    ,input  wire    [7:0]              comp_irq_type
    
    ,output reg                         mat_in_place
    ,input wire                        cfg_comp_done2
    ,output wire                       extra_opt_done
    ,output reg                         v_token_vld
    ,output reg [15:0]                  v_token_dat
    ,output reg                         v_reply = 'd0
    
    ,input  wire                        mst_perip_req
    ,output reg                         mst_perip_ack
    ,output wire                        comp_wk_en
    ,output reg                         alarm_led
);
        localparam  NO_DRIVER     =   4'd0;
        localparam  ROLLER_CW     =   4'd1;
        localparam  ROLLER_CWW    =   4'd9;
        localparam  TRANSFER_CW   =   4'd2;
        localparam  TRANSFER_CWW  =   4'd10;
        localparam  LOCATION_CW   =   4'd3;
        localparam  LOCATION_CWW  =   4'd11;
    `ifdef SIM_PLATFORM_MST
        localparam  WAIT_BEAT_NUM           =   100;
    `else
        localparam  WAIT_BEAT_NUM           =   100_000_000;
    `endif
//state
    localparam  STM_IDLE        =   0;
    localparam  STM_WAIT_REQ_IRQ=   1;
    localparam  STM_WAIT_DET    =   2;
    localparam  STM_JUDGE_SHAPE =   3;
    localparam  GEN_V_TOKEN     =   4;
    localparam  GEN_ALARM       =   5;
    localparam  WAIT_M_OUTPUT   =   6;
    localparam  STM_END         =   7;
    
(* MARK_DEBUG="true" *)    reg     [3:0]   wk_state    =   0;
    reg     [$clog2(WAIT_BEAT_NUM):0]   wk_cnt      =   'd0;
    reg         [7:0]                   dly_cnt     =   0;
    reg             wk_cnt_done;
    wire    outstart_reg;
    always @(posedge clk)begin
        if(reset)begin
            dly_cnt <=  0;
        end else if (dly_cnt == 128)begin
            dly_cnt <=  dly_cnt;
        end else begin
            dly_cnt <=  dly_cnt + 1;
        end
    end
    assign  comp_wk_en  =   (dly_cnt == 128) ? 1'b1 : 1'b0;
    
    assign  extra_opt_done = 1;
    always @(posedge clk)begin
        mat_in_place<=  ~mat_in_place;
        v_reply     <=  ~v_reply;
    end

    always @(posedge clk)begin
        if(reset)begin
            wk_state    <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE:begin
                    wk_state    <=  STM_WAIT_REQ_IRQ;
                end
                STM_WAIT_REQ_IRQ:begin
                    if(comp_irq & (comp_irq_type == `IN_BEH_SUC_EVENT))begin
                        wk_state    <=  STM_WAIT_DET;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_WAIT_DET:begin
                    if(wk_cnt_done)begin
                        wk_state    <=  STM_JUDGE_SHAPE;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_JUDGE_SHAPE:begin
                    if(~mst_perip_req)begin
                        wk_state    <=  GEN_V_TOKEN;
                    end else begin
                        wk_state    <=  GEN_ALARM;
                    end
                end
                GEN_V_TOKEN:begin
                    wk_state    <=  WAIT_M_OUTPUT;
                end
                WAIT_M_OUTPUT:begin
                    if(cfg_comp_done2)begin
                        wk_state    <=  STM_END;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                GEN_ALARM:begin
                    if(~mst_perip_req)begin
                        wk_state    <=  GEN_V_TOKEN;
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
            GEN_ALARM:begin
                alarm_led   <=  'd0;
            end
            default:begin
                alarm_led   <=  'd1;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            GEN_V_TOKEN,WAIT_M_OUTPUT:begin
                mst_perip_ack   <=  'd0;
            end
            default:begin
                mst_perip_ack   <=  'd1;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_WAIT_DET:begin
                wk_cnt  <=  wk_cnt + 'd1;
            end
            default:begin
                wk_cnt  <=  'd0;
            end
        endcase
    end

    always @( * )begin
        case(wk_state)
            STM_WAIT_DET:begin
                wk_cnt_done <=  (wk_cnt ==  WAIT_BEAT_NUM) ? 1'b1 : 1'b0;
            end
            default:begin
                wk_cnt_done <=  1'b0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            GEN_V_TOKEN:begin
                v_token_vld <=  1;
                v_token_dat <=  16'hdead_beaf;
            end
            default:begin
                v_token_vld <=  0;
                v_token_dat <=  16'h0000_0000;
            end
        endcase
    end

endmodule
