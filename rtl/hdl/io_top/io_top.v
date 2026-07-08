///////////////////////////////////////////////////////////////////////////////
//
//
///////////////////////////////////////////////////////////////////////////////
//
//  AURORA_EXAMPLE
//
//  Aurora Generator
//
//
//  Description: Sample Instantiation of a 1 4-byte lane module.
//               Only tests initialization in hardware.
//
//        
module io_top
#(

)
(
     input              clk
    ,input              rstn

    ,input  [15:0]      op_bias_addr
    
    ,input              driver_cfg_wea
    ,input  [15:0]      driver_cfg_addra
    ,input  [31:0]      driver_cfg_dina
    
    ,input              rd_msg_addr_en
    ,input  [15:0]      rd_msg_addr
    ,output [31:0]      di_regoin_msg
    ,output [31:0]      do_regoin_msg

    ,output [31:0]      dataout
    ,input  [63:0]      datain
);
//`ifdef SIM_PLATFORM_MST
//    assign  di_regoin_msg   =   32'hccddeeaa;
//    assign  do_regoin_msg   =   32'hddccff00;
//`else
    io_code
        io_code
        (
             .clk               (clk)
            ,.rstn              (rstn)
            ,.data_start        (op_bias_addr)
            //DO  region
            ,.data_reg          (driver_cfg_wea     )
            ,.data_address      (driver_cfg_addra   )
            ,.data_in           (driver_cfg_dina    )

            // read the message of Do region and DI region
            ,.data_reg1         (rd_msg_addr_en     )
            ,.data_address1     (rd_msg_addr        )
            ,.data_out_vd       ()
            ,.data_out_in       (di_regoin_msg          )
            ,.data_out_out      (do_regoin_msg          )

            ,.data_out_drive    (dataout                )//io port
            ,.data_in_drive     (datain                 )//io port
        );
//`endif

endmodule