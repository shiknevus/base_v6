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
module slv_depot_gen_self(
     input              clk
    ,input              reset
    
    ,output reg         buf_wr_vld = 0
    ,output reg [15:0]  buf_wr_addr
    ,output reg [31:0]  buf_wr_data
);

    localparam PKG_NUM = 512;

    reg [31:0]  work_cnt    =   0;
    reg [4:0]   frm_index   =   'd0;
    
    localparam  STM_IDLE        = 'd0;
    localparam  STM_GEN_DAT     = 'd1;
    localparam  STM_GEN_END     = 'd2;
    localparam  STM_WAIT        = 'd3;
    localparam  STM_ONCE_FINISH = 'd4;
    localparam  STM_END         = 'd7;
    reg [4:0] wk_state  = 'd0;
    reg         gen_dat_done;
    wire        rd_dat_done;
    wire        last_frame;
    always @(posedge clk) begin
        if(reset)begin
          wk_state  <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE: begin
                    if(1) begin
                        wk_state  <=  STM_GEN_DAT;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_GEN_DAT:begin
                    if(gen_dat_done)begin
                        wk_state  <=  STM_GEN_END;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_GEN_END:begin
                    wk_state  <=  STM_WAIT;
                end
                STM_WAIT:begin
                    if(gen_dat_done)begin
                        wk_state  <=  STM_ONCE_FINISH;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_ONCE_FINISH:begin
                    if(last_frame)begin
                        wk_state  <=  STM_END;
                    end else begin
                        wk_state  <=  STM_GEN_DAT;
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
            STM_GEN_DAT,STM_WAIT:begin
                work_cnt <= work_cnt + 1;
            end
            default: begin
                work_cnt  <=  0;
            end
        endcase
    end
    
    always @( * )begin
        case(wk_state)
            STM_GEN_DAT:begin
                gen_dat_done    <=  (work_cnt == PKG_NUM - 1) ? 1'b1 : 1'b0;
            end
            STM_WAIT:begin
                gen_dat_done    <=  (work_cnt == 4096 - 1) ? 1'b1 : 1'b0;
            end
            default: begin
                gen_dat_done    <=  1'b0;
            end
        endcase
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_IDLE:begin
                frm_index   <=  0;
            end
            STM_ONCE_FINISH:begin
                frm_index   <=  frm_index   +   1;
            end
            default: begin
                frm_index   <=  frm_index;
            end
        endcase
    end
    assign  last_frame  =   (frm_index == 10) ? 1'b1 : 1'b0;
    
    always @(posedge clk) begin
        case(wk_state)
            STM_GEN_DAT:begin
                buf_wr_vld  <=  'd1;
                buf_wr_addr <=  work_cnt;
                buf_wr_data <=  frm_index + work_cnt;
            end
            default: begin
                buf_wr_vld  <=  'd0;
                buf_wr_addr <=  'd0;
                buf_wr_data <=  'd0;
            end
        endcase
    end
endmodule

