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
module rs232_top
#(

)
(
     input              clk
    ,input              rstn
    ,input              rxd
    ,output             txd

    ,input              rd_en
    ,input  [15:0]      rd_addr
    ,input  [15:0]      rd_bias_addr
    ,output [31:0]      rd_dat
);

    wire            driver_dat_vld;
    wire    [7:0]   driver_dat_in;
`ifdef SIM_PLATFORM_MST
    reg         rd_en_d1    =   'd0;
    reg         rd_en_f     =   'd0;
    reg [7:0]   rd_opt_index=   'd0;
    reg [31:0]  gen_tst_dat;
    always @(posedge clk)begin
        rd_en_d1    <=  rd_en;
        rd_en_f     <=  (~rd_en) & rd_en_d1;
    end

    always @(posedge clk)begin
        if(~rstn)begin
            rd_opt_index    <=  'd1;
        end else if(rd_en_f) begin
            rd_opt_index    <=  rd_opt_index + 'd1;
        end else begin
            rd_opt_index    <=  rd_opt_index;
        end
    end
    
    always @(posedge clk)begin
        if(rd_en)begin
            gen_tst_dat <=  rd_opt_index + rd_addr;
        end else begin
            gen_tst_dat <=  0;
        end
    end
    assign  rd_dat  =   gen_tst_dat;

`else
    code_rx
        code_rx_u
    (
         .clk           (clk)
        ,.rstn          (rstn)

        ,.data_in       (driver_dat_in)
        ,.data_vd       (driver_dat_vld)

        ,.data_start    (rd_bias_addr)

        ,.data_reg      (rd_en)
        ,.data_address  (rd_addr)

        ,.data_out      (rd_dat)
        ,.data_out_vd   ()

     );

    myUART115200_rx
        myUART115200_rx_u
        (
             .bclk      (clk)
            ,.reset     (rstn)
            ,.rxd       (rxd)
            ,.txd       (txd)
            ,.rx_dout   (driver_dat_in)
            ,.rx_ready  (driver_dat_vld)
        );
`endif

endmodule