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
module rll_ic_ir_oc_comp
#(
    parameter  IN_CHAN_NUM  =  3'd2
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
        wire    start_in0;
        wire    comp_error0;
        wire    comp_error1;
        wire    mat_in_place0;
        wire    mat_in_place1;
        wire    dgt_start0;
        wire    dgt_start1;
        wire    dgt_start_f0;
        wire    dgt_start_f1;
				
				assign	extra_opt_done = 1'b1;
        assign  dgt_start = start_in0 ? dgt_start0 : dgt_start1;
        assign  dgt_start_f = start_in0 ? dgt_start_f0 : dgt_start_f1;
        assign  comp_error = start_in0 ? comp_error0 : comp_error1;
        assign  mat_in_place = start_in0 ? mat_in_place0 : mat_in_place1;

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
                ,.dgt_start                 (dgt_start1     )
                ,.dgt_start_f               (dgt_start_f1   )
                ,.yzqg_up                   (1'b0        		)
                ,.yzqg_down                 (1'b0      			)
                ,.yzqg_out                  ()
                ,.yzdj_start_z              ()
                ,.yzdj_start_f              ()
            );
        
            roller_comp_behavior
            #(
                 .WORK_TYPE                 (ROLLER_CW      )
                ,.WORK_IN_PATH              (3'd0           )
            )
            roller_comp_beh1x_u
            (
                .clk                        (clk            )
                ,.reset                     (reset          )
                ,.instart_reg               (start_in0      )
                
                ,.comp_in_start             (comp_in_start  )
                ,.comp_out_start            ()
                ,.cur_in_path               (cur_in_path    )
                ,.cur_out_path              (cur_out_path   )
                ,.cfg_comp_done             (cfg_comp_done  )
                ,.cfg_comp_done2            (cfg_comp_done2 )
                ,.comp_error                (comp_error0    )
                ,.mat_in_place              (mat_in_place0  )
    
                ,.mf                        (mf             )
                ,.dgt_error                 (dgt_error      )
                ,.dgt_start                 (dgt_start0     )
                ,.dgt_start_f               (dgt_start_f0   )
                ,.yzqg_up                   (1'b0						)
                ,.yzqg_down                 (1'b0						)
                ,.yzqg_out                  ()
                ,.yzdj_start_z              ()
                ,.yzdj_start_f              ()
            );

endmodule