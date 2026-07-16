/////////////////////////////////////////////////////////////////
// Company:
// Engineer:      Huaye Zhang
// Creat Date:    
// Design Name:   sys_signal_gen.v
// Module Name:   sys_signal_gen.v
// Project Name:  
// Target Devices:
// Tool versions:
//                
// Dependencies:
//
// Revision:V1.4.1 This module is used to generate all kinds of
//                 clocks and corresponding reset signals
//
/////////////////////////////////////////////////////////////////
`timescale 1 ps / 1 ps

module sys_signal_gen
#(
    parameter   WOKE_MODE   =   "MAST"
)
(
     input                          sys_clk_in_p
    ,input                          sys_clk_in_n
    ,input                          rst_fpga_n
    ,output wire                    clk_10m
    ,output wire                    aurora_ref_clk
    ,output wire                    aurora_ref_clk_rst
    ,output wire                    aurora_init_clk
    ,output wire                    rst_aurora_init_clk
    

);
/////////////////////////////////////////////////////////     
//                  local_param                     //
/////////////////////////////////////////////////////////     
  localparam  RST_CNT_WIDTH = 20; //sys_rst delay counter width
/////////////////////////////////////////////////////////     
//                  generate aurora_clk                     //
/////////////////////////////////////////////////////////     
  wire fpga_reset = ! rst_fpga_n; //fpga reset signal,high active
  
  //pll module to generate the sys_clk
    wire  aurora_clk_gen_locked;
    generate
        if(WOKE_MODE ==  "MAST") begin:MAST
            aurora_mmcm aurora_mmcm_u
               (
                // Clock out ports
                     .clk_10m           (clk_10m         )  
                     ,.aurora_ref_clk    (aurora_ref_clk         )       // output aurora_ref_clk
                    ,.aurora_init_clk   (aurora_init_clk        )       // output aurora_init_clk
                // Status and control signals
                    ,.reset             (fpga_reset             )       // input reset
                    ,.locked            (aurora_clk_gen_locked  )       // output locked
               // Clock in ports
                    ,.clk_in1_p         (sys_clk_in_p           )       // input clk_in1_p
                    ,.clk_in1_n         (sys_clk_in_n           )       // input clk_in1_n
                );
        end else begin:SLAVE
            aurora_mmcm aurora_mmcm_u
               (
                // Clock out ports
                     .clk_10m           (clk_10m         ) 
                     ,.aurora_ref_clk    (aurora_ref_clk         )       // output aurora_ref_clk
                    ,.aurora_init_clk   (aurora_init_clk        )       // output aurora_init_clk
                // Status and control signals
                    ,.reset             (fpga_reset             )       // input reset
                    ,.locked            (aurora_clk_gen_locked  )       // output locked
               // Clock in ports
                //    ,.clk_in1           (sys_clk_in_p           )       // input clk_in1_p
                );
        end
    endgenerate

  reset_sync
    reset_aurora_init_clk
    (
      .clk        (aurora_init_clk          ),
      .rst_async_n(aurora_clk_gen_locked ),
      .rst_sync   (rst_aurora_init_clk      )
    );

  reset_sync
    reset_aurora_ref_clk
    (
      .clk        (aurora_ref_clk          ),
      .rst_async_n(aurora_clk_gen_locked ),
      .rst_sync   (aurora_ref_clk_rst      )
    );
/////////////////////////////////////////////////////////     
//                  generate system reset signal                     //
/////////////////////////////////////////////////////////     
/*
  //gengerate reset signal for system
  reg [RST_CNT_WIDTH-1:0] rst_cnt = 'd0;
  always @(posedge sys_clk)
  begin
    if(!aurora_clk_gen_locked)
    begin
      rst_cnt <= 'd0;
    end
    else if(rst_cnt[RST_CNT_WIDTH-1])
    begin
      rst_cnt <= rst_cnt;
    end
    else
    begin
      rst_cnt <= rst_cnt + 1'b1;
    end
  end

  always @(posedge sys_clk)
  begin
    if(!aurora_clk_gen_locked)
    begin
      sys_rst <= 1'b0;
    end
    else if(rst_cnt[RST_CNT_WIDTH-1])
    begin
      sys_rst <= 1'b0;
    end
    else
    begin
      sys_rst <= 1'b1;
    end
  end
*/

endmodule
