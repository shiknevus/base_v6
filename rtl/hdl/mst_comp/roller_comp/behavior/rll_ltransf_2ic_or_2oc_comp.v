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
module rll_ltransf_2ic_or_2oc_comp
#(
    parameter  IN_CHAN_NUM  =  3'd3
    ,parameter  OUT_CHAN_NUM  = 3'd2
    ,parameter  WORK_OUT0_PATH = 14'd0
    ,parameter  WORK_OUT1_PATH = 14'd0
    ,parameter  WORK_OUT2_PATH = 14'd0
)
(
     input wire                        clk
    ,input wire                        reset
    ,input wire [15:0]                 time_delay

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
    
    ,input wire                        mf0
    ,input wire                        dgt_error0
    ,output wire                       dgt_start0
    ,input wire                        mf
    ,input wire                        dgt_error
    ,output wire                       dgt_start
    ,output wire                       dgt_start_f
    ,input wire                        yzqg_up
    ,input wire                        yzqg_down
    ,output wire                       yzqg_out
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
        wire    start_in0;
        wire    start_in1;
        wire    start_in2;
        wire    start_out0;
        wire    start_out1;
        wire    comp_error0;
        wire    comp_error1;
        wire    comp_error2;
        wire    yzqg_out0;
        wire    yzqg_out1;
        wire    yzqg_out2;
        wire    yzqg_out3;
        wire    yzdj_start_z2;
        wire    yzdj_start_z3;
        wire    mat_in_place0;
        wire    mat_in_place1;
        wire    optstart_reg;
        wire    start_out2;
        assign  comp_error = start_out2 ? comp_error2 : ((start_in0 | start_out0) ? comp_error0 : comp_error1);
	    	assign  mat_in_place = (start_in0 | start_out0) ? mat_in_place0 : mat_in_place1;
	    	assign  yzqg_out = optstart_reg ? yzqg_out3 : (start_out2 ? yzqg_out2 : ((start_in0 | start_out0) ? yzqg_out0 : yzqg_out1));
	    	assign  yzdj_start_z = optstart_reg ? yzdj_start_z3 : yzdj_start_z2; 	    	

			ltransfer_behavior 
			#(
                .WORK_IN_PATH               (3'd2           )
                ,.WORK_OUT_PATH             (WORK_OUT2_PATH )
            )
			ltransfer_behavior_u
            (
                .clk                        (clk            )
                ,.reset                     (reset          )
                ,.time_delay                (time_delay     )
                ,.optstart_reg				(optstart_reg	)

                ,.extra_opt_start           (extra_opt_start)
                ,.extra_opt_done            (extra_opt_done )
                ,.cur_in_path               (cur_in_path    )
                ,.cur_out_path              (cur_out_path   )
                ,.yzqg_up                   (yzqg_up        )
                ,.yzqg_down                 (yzqg_down      )
                ,.yzqg_out                  (yzqg_out3      )
                ,.yzdj_start_z              (yzdj_start_z3  )
            );

            roller_comp_behavior
            #(
                 .WORK_TYPE                 (TRANSFER_CW    )
                ,.WORK_OUT_PATH             (WORK_OUT2_PATH )
            )
            roller_comp_beh2x_u
            (
                .clk                        (clk            )
                ,.reset                     (reset          )
                ,.outstart_reg              (start_out2     )

                ,.comp_in_start             ()
                ,.comp_out_start            (comp_out_start )
                ,.cur_in_path               (cur_in_path    )
                ,.cur_out_path              (cur_out_path   )
                ,.cfg_comp_done             (cfg_comp_done  )
                ,.cfg_comp_done2            (cfg_comp_done2 )
                ,.comp_error                (comp_error2    )
                ,.mat_in_place              ()
    
                ,.mf                        (mf							)
                ,.dgt_error                 ()
                ,.dgt_start                 ()
                ,.dgt_start_f               ()
                ,.yzqg_up                   (yzqg_up        )
                ,.yzqg_down                 (yzqg_down      )
                ,.yzqg_out                  (yzqg_out2      )
                ,.yzdj_start_z              (yzdj_start_z2  )
                ,.yzdj_start_f              (yzdj_start_f   )
            );
						
			roller_comp_behavior
            #(
                 .WORK_TYPE                 (ROLLER_CW      )
                ,.WORK_IN_PATH              (3'd0           )
                ,.WORK_OUT_PATH             (WORK_OUT0_PATH )
            )
            roller_comp_beh00_u
            (
                .clk                        (clk            )
                ,.reset                     (reset          )
                ,.instart_reg               (start_in0      )
                ,.outstart_reg              (start_out0     )
                
                ,.comp_in_start             (comp_in_start  )
                ,.comp_out_start            (comp_out_start )
                ,.cur_in_path               (cur_in_path    )
                ,.cur_out_path              (cur_out_path   )
                ,.cfg_comp_done             (cfg_comp_done  )
                ,.cfg_comp_done2            (cfg_comp_done2 )
                ,.comp_error                (comp_error0    )
                ,.mat_in_place              (mat_in_place0  )
    
                ,.mf                        (mf0            )
                ,.dgt_error                 (dgt_error0     )
                ,.dgt_start                 (dgt_start0     )
                ,.dgt_start_f               ()
                ,.yzqg_up                   (yzqg_up        )
                ,.yzqg_down                 (yzqg_down      )
                ,.yzqg_out                  (yzqg_out0      )
                ,.yzdj_start_z              ()
                ,.yzdj_start_f              ()
            );
						       
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
                ,.comp_error                (comp_error1    )
                ,.mat_in_place              (mat_in_place1  )
    
                ,.mf                        (mf             )
                ,.dgt_error                 (dgt_error      )
                ,.dgt_start                 (dgt_start      )
                ,.dgt_start_f               ()
                ,.yzqg_up                   (yzqg_up        )
                ,.yzqg_down                 (yzqg_down      )
                ,.yzqg_out                  (yzqg_out1      )
                ,.yzdj_start_z              ()
                ,.yzdj_start_f              ()
            );

endmodule