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
module rll_alm_ic_comp
#(
    parameter  IN_CHAN_NUM  =  3'd1
    ,parameter  OUT_CHAN_NUM  = 3'd0
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

    ,input wire                        mf
    ,input wire                        dgt_error
    ,output wire                       dgt_start
    ,output wire                       dgt_start_f
    ,input wire                        yzqg_up
    ,input wire                        yzqg_down
    ,output wire                       yzqg_out
    ,output wire                       yzdj_start_z
    ,output wire                       yzdj_start_f
    ,output wire                       wl
);
        localparam  NO_DRIVER     =   4'd0;
        localparam  ROLLER_CW     =   4'd1;
        localparam  ROLLER_CWW    =   4'd9;
        localparam  TRANSFER_CW   =   4'd2;
        localparam  TRANSFER_CWW  =   4'd10;
        localparam  LOCATION_CW   =   4'd3;
        localparam  LOCATION_CWW  =   4'd11;
        reg [31:0]  time_cnt;
        wire    cfg_wait_done;
        wire    instart_pose;
        wire    done2_pose;
        reg     instart_r;
        reg     instart_r_r;
        reg     instart_reg;
        reg     done2_r;
        reg     done2_r_r;
        
        assign extra_opt_done = 1'b1;
        assign mat_in_place = (time_cnt > 32'h14000000) ? 1'b1 : 1'b0;
        assign wl = mf;
        
        always @(posedge clk)begin
            if(instart_reg) begin
                time_cnt <= time_cnt + 1'b1;
            end else begin
                time_cnt <= 32'h0;
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
                done2_r <= 1'b0;
                done2_r_r <= 1'b0;
            end else begin
                done2_r <= cfg_comp_done2;
                done2_r_r <= done2_r;
            end
        end
        assign  done2_pose = done2_r & ~done2_r_r;
        
        always @(posedge clk)begin
            if(reset | done2_pose) begin        
                instart_reg <= 1'b0;
            end else if(instart_pose) begin
                instart_reg <= 1'b1;   
            end else begin
                instart_reg <= instart_reg;
            end 
        end

endmodule