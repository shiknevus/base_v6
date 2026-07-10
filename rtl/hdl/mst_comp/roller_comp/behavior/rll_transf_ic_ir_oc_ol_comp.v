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
module rll_transf_ic_ir_oc_ol_comp
#(
     parameter  IN_CHAN_NUM  =  3'd2
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
        wire    cfg_wait_done;
        wire    start_in0;
        wire    start_out0;
        wire    error_comp0;
        wire    error_comp1;
        wire    yzqg_out0;
        wire    yzqg_out1;
        wire    mat_in_place0;
        wire    mat_in_place1;
        
        assign  extra_opt_done = 1'b1;
        assign  comp_error = (start_in0 | start_out0) ? error_comp0 : error_comp1;
        assign  yzqg_out = (start_in0 | start_out0) ? yzqg_out0 : yzqg_out1;
        assign  mat_in_place = (start_in0 | start_out0) ? mat_in_place0 : mat_in_place1;

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

                ,.comp_in_start             (comp_in_start  )
                ,.comp_out_start            (comp_out_start )
                ,.cur_in_path               (cur_in_path    )
                ,.cur_out_path              (cur_out_path   )
                ,.cfg_comp_done             (cfg_comp_done  )
                ,.cfg_comp_done2            (cfg_comp_done2 )
                ,.comp_error                (error_comp1    )
                ,.mat_in_place              (mat_in_place1  )
    
                ,.mf                        (mf             )
                ,.dgt_error                 (dgt_error      )
                ,.dgt_start                 (dgt_start      )
                ,.dgt_start_f               (dgt_start_f    )
                ,.yzqg_up                   (yzqg_up        )
                ,.yzqg_down                 (yzqg_down      )
                ,.yzqg_out                  (yzqg_out1      )
                ,.yzdj_start_z              ()
                ,.yzdj_start_f              ()
            );
        
            roller_comp_behavior
            #(
                 .WORK_TYPE                 (TRANSFER_CWW   )
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
                ,.comp_error                (error_comp0    )
                ,.mat_in_place              (mat_in_place0  )
    
                ,.mf                        (mf             )
                ,.dgt_error                 ()
                ,.dgt_start                 ()
                ,.dgt_start_f               ()
                ,.yzqg_up                   (yzqg_up        )
                ,.yzqg_down                 (yzqg_down      )
                ,.yzqg_out                  (yzqg_out0      )
                ,.yzdj_start_z              (yzdj_start_z   )
                ,.yzdj_start_f              (yzdj_start_f   )
            );

endmodule