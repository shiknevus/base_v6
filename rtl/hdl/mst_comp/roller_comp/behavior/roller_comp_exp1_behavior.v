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
module roller_comp_exp1_behavior
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
    ,input wire                        qdqg_up
    ,input wire                        qdqg_down
    ,output wire                       qdqg_out
    ,input wire                        cdqg_put_out
    ,input wire                        cdqg_draw_back
    ,output wire                       cdqg_out
);
    wire    n_dgt_start;
    wire    n_qdqg_out;
    wire    n_cdqg_out;
    
    assign  dgt_start = ~n_dgt_start;
    assign  qdqg_out = ~n_qdqg_out;
    assign  cdqg_out = ~n_cdqg_out;
    
    generate
      case (WORK_TYPE[2:0])
         3'd3: begin: location_driver
                    location_comp_driver location_comp_driver_u
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

                        ,.mf                        (~mf            )
                        ,.dgt_error                 (~dgt_error     )
                        ,.dgt_start                 (n_dgt_start    )
                        ,.dgt_start_f               (dgt_start_f    )
                        ,.qdqg_up                   (~qdqg_up       )
                        ,.qdqg_down                 (~qdqg_down     )
                        ,.qdqg_out                  (n_qdqg_out     )
                        ,.cdqg_put_out              (~cdqg_put_out  )
                        ,.cdqg_draw_back            (~cdqg_draw_back)
                        ,.cdqg_out                  (n_cdqg_out     )
                    );
                  end
         default: begin: no_driver
                  end
      endcase
   endgenerate

endmodule