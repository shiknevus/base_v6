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
module rll_open_box_ic_oc_comp
#(
    parameter  IN_CHAN_NUM  =  3'd1
    ,parameter  OUT_CHAN_NUM  = 3'd1
    ,parameter  WORK_OUT1_PATH = 14'd0
)
(
     input wire                        clk
    ,input wire                        reset

    ,input wire                        comp_in_start
    ,input wire                        comp_out_start
    ,input wire [2:0]                  cur_in_path
    ,input wire [13:0]                 cur_out_path
    ,input wire                        cfg_comp_done
    ,input wire                        cfg_comp_done2
    ,output wire                       comp_error
    ,output wire                       mat_in_place
    ,input wire                        extra_opt_start
    ,output reg                        extra_opt_done

    ,input wire                        mf
    ,input wire                        dgt_error
    ,output wire                       dgt_start
    ,output wire                       dgt_start_f
    ,input wire                        qdqg_up
    ,input wire                        qdqg_down
    ,output wire                       qdqg_out
    ,input wire                        cdqg_put_out
    ,input wire                        cdqg_draw_back
    ,output wire                       cdqg_out
    ,input wire                        khg_di1
    ,input wire                        khg_di2
    ,output reg                        khg_dq1
    ,output wire                       khg_dq2
    ,input wire                        khg_error
);
        localparam  BOX_WAITE     =   'd0;
        localparam  BOX_TIME      =   'd1;
        localparam  BOX_DONE      =   'd2;

        localparam  NO_DRIVER     =   4'd0;
        localparam  ROLLER_CW     =   4'd1;
        localparam  ROLLER_CWW    =   4'd9;
        localparam  TRANSFER_CW   =   4'd2;
        localparam  TRANSFER_CWW  =   4'd10;
        localparam  LOCATION_CW   =   4'd3;
        localparam  LOCATION_CWW  =   4'd11;
        localparam  Init_time_1ms =   18'd108297;
        localparam  time_delay0   =   14'd500;
        wire    comp_error1;
        wire    khg_di2_handle;
        wire    cdqg_pose;
        wire    box_cnt_done;
        wire    extra_start_pose;
        reg     extra_start_reg;
        reg     extra_start_r;
        reg     extra_start_r_r;
        reg     cdqg_r;
        reg     cdqg_r_r;
        reg     cdqg_r_r_r;
        reg [31:0] time_cnt;
        reg [2:0] box_state;
        reg [7:0] khg_dq_cnt;

        assign  khg_dq2 = mf;
        assign  comp_error = khg_dq1 ? comp_error1 : ~khg_error;
        assign  khg_di2_handle = (khg_dq_cnt > 'd100) ? 1'b1 : 1'b0;

        always @(posedge clk)begin
            if(reset || extra_opt_done)begin
                khg_dq1 <= 1'b1;
            end else if(box_state == BOX_DONE && ~khg_di2_handle) begin
                khg_dq1 <= 1'b0; 
            end else begin
                khg_dq1 <= khg_dq1;
            end
        end
        
        always @(posedge clk)begin
            if((box_state == BOX_DONE && khg_di2_handle) || (~khg_di1 && khg_di2)) begin
                extra_opt_done <= 1'b1;
            end else begin
                extra_opt_done <= 1'b0;
            end
        end
        
        always @(posedge clk)begin
            if(reset || extra_opt_done)begin
                khg_dq_cnt <= 'd0;
            end else if(box_state == BOX_TIME && time_cnt[31:18] > (time_delay0 - 'd200) && time_cnt[17:0] == 'd0 && khg_di2) begin
                khg_dq_cnt <= khg_dq_cnt + 1'b1;
            end else begin
                khg_dq_cnt <= khg_dq_cnt;
            end
        end

        always @(posedge clk)begin
            if(box_state == BOX_TIME)begin
                if(time_cnt[17:0] == 'd0)begin
                    time_cnt[17:0] <= Init_time_1ms;
                end else begin
                    time_cnt <= time_cnt+'d1;
                end
            end else begin
                time_cnt <= Init_time_1ms;
            end
        end
        
        always @(posedge clk)begin
            case(box_state)
                BOX_WAITE:begin
                    if(cdqg_pose)begin
                        box_state <= BOX_TIME;
                    end else begin
                        box_state <= box_state;
                    end
                end
                BOX_TIME:begin
                    if(box_cnt_done)begin
                        box_state <= BOX_DONE;
                    end else begin
                        box_state <= box_state;
                    end
                end
                BOX_DONE:begin
                        box_state <= BOX_WAITE;
                end
                default:begin
                end
             endcase
        end

        assign  cdqg_pose = cdqg_r_r & ~cdqg_r_r_r;
        assign  extra_start_pose = extra_start_r & ~extra_start_r_r;
        assign  box_cnt_done = (time_cnt > {time_delay0, 18'd0}) ? 1'b1 : 1'b0;

        always @(posedge clk)begin
            cdqg_r <= cdqg_draw_back && ~cdqg_put_out && extra_start_reg;
            cdqg_r_r <= cdqg_r;
            cdqg_r_r_r <= cdqg_r_r;
        end

        always @(posedge clk)begin
            if(reset)begin
                extra_start_reg <= 1'b0;
            end else if(extra_start_pose) begin
                extra_start_reg <= 1'b1;
            end else if(extra_opt_done) begin
                extra_start_reg <= 1'b0;
            end else begin
                extra_start_reg <= extra_start_reg;
            end
        end
        
        always @(posedge clk)begin
            if(reset)begin
                extra_start_r <= 1'b0;
                extra_start_r_r <= 1'b0;
            end else begin
                extra_start_r <= extra_opt_start;
                extra_start_r_r <= extra_start_r;
            end
        end

            roller_comp_exp1_behavior
            #(
                 .WORK_TYPE                 (LOCATION_CW    )
                ,.WORK_IN_PATH              (3'd1           )
                ,.WORK_OUT_PATH             (WORK_OUT1_PATH )
            )
            roller_comp_beh11_u
            (
                .clk                        (clk            )
                ,.reset                     (reset          )
                
                ,.comp_in_start             (comp_in_start  )
                ,.comp_out_start            (comp_out_start )
                ,.cur_in_path               (cur_in_path    )
                ,.cur_out_path              (cur_out_path   )
                ,.cfg_comp_done             (cfg_comp_done  )
                ,.cfg_comp_done2            (cfg_comp_done2 )
                ,.comp_error                (comp_error1    )
                ,.mat_in_place              (mat_in_place   )
    
                ,.mf                        (mf             )
                ,.dgt_error                 (dgt_error      )
                ,.dgt_start                 (dgt_start      )
                ,.dgt_start_f               (dgt_start_f    )
                ,.qdqg_up                   (qdqg_up        )
                ,.qdqg_down                 (qdqg_down      )
                ,.qdqg_out                  (qdqg_out       )
                ,.cdqg_put_out              (cdqg_put_out   )
                ,.cdqg_draw_back            (cdqg_draw_back )
                ,.cdqg_out                  (cdqg_out       )
            );

endmodule