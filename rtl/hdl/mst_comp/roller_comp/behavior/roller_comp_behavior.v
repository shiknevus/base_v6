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
module roller_comp_behavior
#(
     parameter   WORK_TYPE = 4'd0
    ,parameter   WORK_IN_PATH = 3'd7
    ,parameter   WORK_OUT_PATH = 14'd7
)
(
     input wire                        clk
    ,input wire                        reset
    ,output wire                       instart_reg
    ,output wire                       outstart_reg
    
    ,input wire                        comp_in_start
    ,input wire                        comp_out_start
    ,input wire [2:0]                  cur_in_path
    ,input wire [13:0]                 cur_out_path
    ,input wire                        cfg_comp_done
    ,input wire                        cfg_comp_done2
    ,output wire                       comp_error
    ,output wire                       mat_in_place
    
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
    wire    n_dgt_start;
    wire    n_yzqg_out;
    wire    n_yzdj_start_z;
    wire    n_yzdj_start_f;
    
    assign  dgt_start = ~n_dgt_start;
    assign  yzqg_out = ~n_yzqg_out;
    assign  yzdj_start_z = ~n_yzdj_start_z;
    assign  yzdj_start_f = ~n_yzdj_start_f;

    generate
      case (WORK_TYPE[2:0])
         3'd1: begin: roller_driver
                    roller_comp_driver roller_comp_driver_u
                    (
                        .clk                        (clk            )
                        ,.reset                     (reset          )
                        ,.instart_reg               (instart_reg    )
                        ,.outstart_reg              (outstart_reg   )

                        ,.comp_in_start             (comp_in_start  )
                        ,.comp_out_start            (comp_out_start )
                        ,.work_type                 (WORK_TYPE      )
                        ,.work_in_path              (WORK_IN_PATH   )
                        ,.work_out_path             (WORK_OUT_PATH  )
                        ,.cur_in_path               (cur_in_path    )
                        ,.cur_out_path              (cur_out_path   )
                        ,.cfg_comp_done             (cfg_comp_done  )
                        ,.cfg_comp_done2            (cfg_comp_done2 )
                        ,.comp_error                (comp_error     )
                        ,.mat_in_place              (mat_in_place   )

                        ,.mf                        (~mf            )  //~mf
                        ,.dgt_error                 (~dgt_error     )  //~dgt_error
                        ,.dgt_start                 (n_dgt_start    )
                        ,.dgt_start_f               (dgt_start_f    )
                        ,.yzqg_up                   (~yzqg_up       )  //~yzqg_up
                        ,.yzqg_down                 (~yzqg_down     )  //~yzqg_down
                        ,.yzqg_out                  (n_yzqg_out     )
                    );
                  end
         3'd2: begin: transfer_driver
                    transfer_comp_driver    transfer_comp_driver_u
                    (
                        .clk                        (clk            )
                        ,.reset                     (reset          )
                        ,.instart_reg               (instart_reg    )
                        ,.outstart_reg              (outstart_reg   )
                            
                        ,.comp_in_start             (comp_in_start  )
                        ,.comp_out_start            (comp_out_start )
                        ,.work_type                 (WORK_TYPE      )
                        ,.work_in_path              (WORK_IN_PATH   )
                        ,.work_out_path             (WORK_OUT_PATH  )
                        ,.cur_in_path               (cur_in_path    )
                        ,.cur_out_path              (cur_out_path   )
                        ,.cfg_comp_done             (cfg_comp_done  )
                        ,.cfg_comp_done2            (cfg_comp_done2 )
                        ,.comp_error                (comp_error     )
                        ,.mat_in_place              (mat_in_place   )

                        ,.mf                        (~mf             )  //~mf
                        ,.yzqg_up                   (~yzqg_up        )  //~yzqg_up
                        ,.yzqg_down                 (~yzqg_down      )  //~yzqg_down
                        ,.yzqg_out                  (n_yzqg_out      )
                        ,.yzdj_start_z              (n_yzdj_start_z  )
                        ,.yzdj_start_f              (n_yzdj_start_f  )
                    );
                  end
         default: begin: no_driver
                  end
      endcase
   endgenerate

endmodule