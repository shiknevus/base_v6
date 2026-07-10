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
module rll_scan_ic_oc_comp
#(
    parameter  IN_CHAN_NUM  =  3'd1
    ,parameter  OUT_CHAN_NUM  = 3'd1
    ,parameter  WORK_OUT1_PATH = 14'd0
    ,parameter  LOCK_SCAN_ADDR = `DEPOT_BIAS_RS232_1ST
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

    ,input wire                        mf
    ,input wire                        dgt_error
    ,output wire                       dgt_start
    ,output wire                       dgt_start_f
    ,input wire                        yzqg_up
    ,input wire                        yzqg_down
    ,output wire                       yzqg_out
    ,output wire                       yzdj_start_z
    ,output wire                       yzdj_start_f
    
    ,input wire [3:0]                  rs232_1st_vld
    ,input wire [15:0]                 rs232_1st_addr
    ,input wire [31:0]                 rs232_1st_msg
    ,output wire                       scan_token_vld
);
        localparam  NO_DRIVER     =   4'd0;
        localparam  ROLLER_CW     =   4'd1;
        localparam  ROLLER_CWW    =   4'd9;
        localparam  TRANSFER_CW   =   4'd2;
        localparam  TRANSFER_CWW  =   4'd10;
        localparam  LOCATION_CW   =   4'd3;
        localparam  LOCATION_CWW  =   4'd11;
        
        assign  extra_opt_done = 1'b1;

        scan_comp_driver
        #(
            .LOCK_SCAN_ADDR             (LOCK_SCAN_ADDR)
        )
        scan_comp_driver_u
        (
            .clk                        (clk            )
            ,.reset                     (reset          )
                
            ,.rs232_1st_vld             (rs232_1st_vld  )
            ,.rs232_1st_addr            (rs232_1st_addr )
            ,.rs232_1st_msg             (rs232_1st_msg  )
            ,.scan_token_vld            (scan_token_vld )
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
                
                ,.comp_in_start             (comp_in_start  )
                ,.comp_out_start            (comp_out_start )
                ,.cur_in_path               (cur_in_path    )
                ,.cur_out_path              (cur_out_path   )
                ,.cfg_comp_done             (cfg_comp_done  )
                ,.cfg_comp_done2            (cfg_comp_done2 )
                ,.comp_error                (comp_error     )
                ,.mat_in_place              (mat_in_place   )
    
                ,.mf                        (mf             )
                ,.dgt_error                 (dgt_error      )
                ,.dgt_start                 (dgt_start      )
                ,.dgt_start_f               (dgt_start_f    )
                ,.yzqg_up                   (1'b0        	)
                ,.yzqg_down                 (1'b0      		)
                ,.yzqg_out                  ()
                ,.yzdj_start_z              ()
                ,.yzdj_start_f              ()
            );

endmodule