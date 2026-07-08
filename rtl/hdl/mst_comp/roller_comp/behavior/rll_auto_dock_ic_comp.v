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
module rll_auto_dock_ic_comp
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
    ,output reg                        yzqg_out
    ,output wire                       yzdj_start_z
    ,output wire                       yzdj_start_f
);
        localparam  NO_DRIVER     =   4'd0;
        localparam  ROLLER_CW     =   4'd1;
        localparam  ROLLER_CWW    =   4'd9;
        localparam  TRANSFER_CW   =   4'd2;
        localparam  TRANSFER_CWW  =   4'd10;
        localparam  LOCATION_CW   =   4'd3;
        localparam  LOCATION_CWW  =   4'd11;
        wire      instart_reg;
        reg       mf_flag;
        reg       latch_in_done;
        reg 	  done_r;
    	reg 	  done_r_r;
    	reg 	  done_r_r_r;
    	reg 	  done2_r;
    	reg 	  done2_r_r;
    	wire 	  done_pose;
    	wire 	  done2_pose;
        wire     yzqg_out1;
        
        assign  extra_opt_done = (yzqg_down & ~yzqg_up) ? 1'b1 : 1'b0;
        assign  done_pose = done_r_r & ~done_r_r_r;
        assign  done2_pose = done2_r & ~done2_r_r;
        
        always @(posedge clk)begin
            if(reset)begin
                mf_flag <=  1'b0;
            end else begin
                if(mat_in_place && ~mf_flag)begin
                    mf_flag = 1'b1;
                end else if(~mat_in_place && mf_flag)begin
                    mf_flag = 1'b0;
                end
            end        
        end

        always @(posedge clk)begin
		  if(reset)begin
		      done_r <= 1'b0;
		      done_r_r <= 1'b0;
		      done_r_r_r <= 1'b0;
		  end else begin
		      done_r <= cfg_comp_done;
		      done_r_r <= done_r;
		      done_r_r_r <= done_r_r;
		  end
        end
        
        always @(posedge clk)begin
            if(reset)begin
                done2_r <= 1'b0;
                done2_r_r <= 1'b0;
            end else begin
                done2_r <= cfg_comp_done2;
                done2_r_r <= done2_r;
            end
        end

        always @(posedge clk)begin
        	if(reset || (~mat_in_place & ~mf_flag & done2_pose))begin
                yzqg_out <= 1'b1;   
            end else if(done_pose)begin
                yzqg_out <= 1'b0;
            end else if(instart_reg)begin
                yzqg_out <= yzqg_out1;
            end else begin
                yzqg_out <= yzqg_out;    
            end
        end
        
            roller_comp_behavior
            #(
                 .WORK_TYPE                 (ROLLER_CW      )
                ,.WORK_IN_PATH              (3'd1           )
            )
            roller_comp_beh1x_u
            (
                .clk                        (clk            )
                ,.reset                     (reset          )
                ,.instart_reg              	(instart_reg   	)

                ,.comp_in_start             (comp_in_start  )
                ,.comp_out_start            ()
                ,.cur_in_path               (cur_in_path    )
                ,.cur_out_path              (cur_out_path   )
                ,.cfg_comp_done             (extra_opt_start)
                ,.cfg_comp_done2            (cfg_comp_done2 )
                ,.comp_error                (comp_error     )
                ,.mat_in_place              (mat_in_place   )
    
                ,.mf                        (mf             )
                ,.dgt_error                 (dgt_error      )
                ,.dgt_start                 (dgt_start      )
                ,.dgt_start_f               (dgt_start_f    )
                ,.yzqg_up                   (yzqg_up        )
                ,.yzqg_down                 (yzqg_down      )
                ,.yzqg_out                  (yzqg_out1   	)
                ,.yzdj_start_z              ()
                ,.yzdj_start_f              ()
            );

endmodule