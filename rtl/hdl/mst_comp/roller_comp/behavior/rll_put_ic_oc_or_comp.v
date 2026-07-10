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
module rll_put_ic_oc_or_comp
#(
    parameter  IN_CHAN_NUM  =  3'd1
    ,parameter  OUT_CHAN_NUM  = 3'd2
    ,parameter  WORK_OUT0_PATH = 14'd0
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
    ,output wire                       extra_opt_done
    ,output reg [7:0]                  behavior_type

    ,input wire                        mf
    ,input wire                        dgt_error
    ,output wire                       dgt_start
    ,output wire                       dgt_start_f
    ,input wire                        yzqg_up
    ,input wire                        yzqg_down
    ,output wire                       yzqg_out
    ,output wire                       yzdj_start_z
    ,output wire                       yzdj_start_f
    ,input wire                        cdqg_put_out
    ,input wire                        cdqg_draw_back
    ,output reg                        cdqg_out
);
        localparam  NO_DRIVER     =   4'd0;
        localparam  ROLLER_CW     =   4'd1;
        localparam  ROLLER_CWW    =   4'd9;
        localparam  TRANSFER_CW   =   4'd2;
        localparam  TRANSFER_CWW  =   4'd10;
        localparam  LOCATION_CW   =   4'd3;
        localparam  LOCATION_CWW  =   4'd11;
        wire    start_in1;
        wire    start_out1;
        wire    start_out0;
        wire    instart_pose;
        wire    done_pose;
        wire    done2_pose;
        reg     instart_r;
        reg     instart_r_r;
        reg     done_r;
        reg     done_r_r;
        reg     done2_r;
        reg     done2_r_r;
        reg     extra_opt_done_buf1;
        reg     extra_opt_done_buf2;
        
        assign  extra_opt_done = 1'b1;

        always @(posedge clk)begin
            if(reset)begin
                cdqg_out <= 1'b0;
            end else if(instart_pose | done2_pose)begin
                cdqg_out <= 1'b0;
            end else if(done_pose & cur_out_path == WORK_OUT0_PATH)begin
                cdqg_out <= 1'b1;
            end else begin
                cdqg_out <= cdqg_out;
            end
        end

        always @(posedge clk)begin
            if(reset)begin
                instart_r <= 1'b0;
                instart_r_r <= 1'b0;
            end else begin
                instart_r <= comp_in_start;
                instart_r_r <= instart_r;
            end
        end
        assign  instart_pose = instart_r & ~instart_r_r;
        
        always @(posedge clk)begin
            if(reset)begin
                done_r <= 1'b0;
                done_r_r <= 1'b0;
            end else begin
                done_r <= cfg_wait_done;
                done_r_r <= done_r;
            end
        end
        assign  done_pose = done_r & ~done_r_r;
        
        always @(posedge clk)begin
            if(reset)begin
                done2_r <= 1'b0;
                done2_r_r <= 1'b0;
            end else begin
                done2_r <= cfg_comp_done2;
                done2_r_r <= done2_r;
            end
        end
        assign  done2_pose = done2_r & ~done2_r_r;

            roller_comp_behavior
            #(
                 .WORK_TYPE                 (ROLLER_CW      )
                ,.WORK_IN_PATH              (3'd1           )
                ,.WORK_OUT_PATH             (WORK_OUT1_PATH )
            )
            roller_comp_beh11_u
            (
                .clk                        (clk            )
                ,.reset                     (reset          )
                ,.instart_reg               (start_in1      )
                ,.outstart_reg              (start_out1     )

                ,.comp_in_start             (comp_in_start  )
                ,.comp_out_start            (comp_out_start )
                ,.cur_in_path               (cur_in_path    )
                ,.cur_out_path              (cur_out_path   )
                ,.cfg_comp_done             (cfg_comp_done  )
                ,.cfg_comp_done2            (cfg_comp_done2 )
                ,.comp_error                (comp_error    )
                ,.mat_in_place              (mat_in_place   )
    
                ,.mf                        (mf             )
                ,.dgt_error                 (dgt_error      )
                ,.dgt_start                 (dgt_start      )
                ,.dgt_start_f               (dgt_start_f    )
                ,.yzqg_up                   (yzqg_up        )
                ,.yzqg_down                 (yzqg_down      )
                ,.yzqg_out                  (yzqg_out       )
                ,.yzdj_start_z              ()
                ,.yzdj_start_f              ()
            );

endmodule