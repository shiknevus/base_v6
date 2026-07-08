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
module intc_top
#(

)
(
     input                              clk
    ,input                              reset

    ,input                              irq_vld
    ,input      [7:0]                   irq_type
    ,output wire                        irq_prcs_busy
    
    ,output reg                         ps_irq_vld
    ,output reg [7:0]                   ps_irq_type = 'd0
    ,input                              ps_iack_vld
    ,input      [7:0]                   ps_iack_type
);
    localparam  STM_IDLE            =   'd0;
    localparam  STM_SEND_IRQ_TO_PS  =   'd1;
    localparam  STM_WAIT_PRCS       =   'd2;
    localparam  STM_IRQ_PRCS_DONE   =   'd3;
    localparam  STM_END             =   'd4;
    localparam  IRQ_BEAT_NUM        =   'd5;
    reg [3:0]   wk_state    =   'd0;
    reg [7:0]   latch_irq_type  =   'd0;
    reg [$clog2(IRQ_BEAT_NUM):0]  wk_cnt  =   'd0;
    reg         wk_cnt_done =   'd0;
    always @(posedge clk)begin
        if(reset)begin
            wk_state    <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE:begin
                    if(irq_vld)begin
                        wk_state    <=  STM_SEND_IRQ_TO_PS;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_SEND_IRQ_TO_PS:begin
                    if(wk_cnt_done)begin
                        wk_state    <=  STM_WAIT_PRCS;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_WAIT_PRCS:begin
                    if(ps_iack_vld & (ps_iack_type == 'd9))begin
                        wk_state    <=  STM_IRQ_PRCS_DONE;
                    end else begin
                        wk_state    <=  wk_state;
                    end
                end
                STM_IRQ_PRCS_DONE:begin
                    wk_state    <=  STM_END;
                end
                STM_END:begin
                    wk_state    <=  STM_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_SEND_IRQ_TO_PS:begin
                wk_cnt  <=  wk_cnt  +   'd1;
            end
            default:begin
                wk_cnt  <=  'd0;
            end
        endcase
    end

    always @( * )begin
        case(wk_state)
            STM_SEND_IRQ_TO_PS:begin
                wk_cnt_done <=  (wk_cnt == IRQ_BEAT_NUM) ? 1'b1 : 1'b0;
            end
            default:begin
                wk_cnt_done <=  'd0;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
            STM_IDLE:begin
                if(irq_vld)begin
                    latch_irq_type    <=  irq_type;
                end else begin
                    latch_irq_type    <=  0;
                end
            end
            default:begin
                latch_irq_type  <=  latch_irq_type;
            end
        endcase
    end

    always @(posedge clk)begin
        case(wk_state)
//            STM_SEND_IRQ_TO_PS:begin
            STM_SEND_IRQ_TO_PS,STM_WAIT_PRCS:begin
                ps_irq_vld  <=  'd1;
//                ps_irq_vld  <=  'd0;
                ps_irq_type <=  latch_irq_type;
            end
            default:begin
                ps_irq_vld  <=  'd0;
                ps_irq_type <=  ps_irq_type;
            end
        endcase
    end

    assign  irq_prcs_busy   =   (irq_vld | (wk_state !== STM_IDLE)) ? 1'b1 : 1'b0;
endmodule