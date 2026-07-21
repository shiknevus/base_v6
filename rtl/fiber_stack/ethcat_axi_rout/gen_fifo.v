/////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// Creat Date:
// Design Name
// Module Name
// Project Name
// Target Devices
// Tool versions:
//
// Dependencies:
//
//
// Revision:
/////////////////////////////////////////////////////////////////
`timescale 1 ps / 1 ps

module gen_fifo
#(
     parameter  BUF_DWIDTH  = 16
    ,parameter  DEPTH       = 1024
    ,parameter  TYPE        = "DISTRIBUT"//BLOCK
    ,parameter  DEPTH_WIDTH = $clog2(DEPTH + 1)
//  parameter DEPTH_WIDTH = 10
)
(
     input                     rst
    ,input                     clk
    ,input                     wr_en
    ,input   [BUF_DWIDTH-1:0]  din
    ,input                     rd_en
    ,output  [BUF_DWIDTH-1:0]  dout
    ,output                    full
    ,output                    empty
);
    generate
        if(TYPE ==  "BLOCK") begin:BLOCK
            if(DEPTH == 1024) begin:DEPTH_1024
                if(BUF_DWIDTH == 36) begin:DWIDTH_26b
                    BFIFO_1024x36b
                        BFIFO_1024x36b_u(
                             .clk            (clk           )   // input wire clk
                            ,.srst           (rst           )   // input wire srst
                            ,.din            (din           )   // input wire [35 : 0] din
                            ,.wr_en          (wr_en         )   // input wire wr_en
                            ,.rd_en          (rd_en         )   // input wire rd_en
                            ,.dout           (dout          )   // output wire [35 : 0] dout
                            ,.full           (full          )   // output wire full
                            ,.empty          (empty         )   // output wire empty
//                            ,.wr_rst_busy    (   )   // output wire wr_rst_busy
//                            ,.rd_rst_busy    (   )   // output wire rd_rst_busy
                        );
                end
            end
        end else if(TYPE ==  "DISTRIBUT") begin:DIST
            if(DEPTH == 16) begin:DEPTH_16
                if(BUF_DWIDTH == 32) begin:DWIDTH_32
                    DFIFO_16x32b DFIFO_16x32b_u (
                      .clk(clk),                  // input wire clk
                      .srst(srst),                // input wire srst
                      .din(din),                  // input wire [31 : 0] din
                      .wr_en(wr_en),              // input wire wr_en
                      .rd_en(rd_en),              // input wire rd_en
                      .dout(dout),                // output wire [31 : 0] dout
                      .full(full),                // output wire full
                      .empty(empty)              // output wire empty
//                      .wr_rst_busy(),  // output wire wr_rst_busy
//                      .rd_rst_busy()  // output wire rd_rst_busy
                    );
                end
            end
        end
    endgenerate

endmodule
