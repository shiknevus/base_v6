
`timescale 1ns/100ps

module axi_reg_slice #(

  parameter DATA_WIDTH = 32,
  parameter FORWARD_REGISTERED = 0,
  parameter BACKWARD_REGISTERED = 0,
  parameter AXI_MODE    =   "AXI_LITE"
)(

  input clk,
  input resetn,

  input s_axi_valid,
  output s_axi_ready,
  input [DATA_WIDTH-1:0] s_axi_data,

  output m_axi_valid,
  input m_axi_ready,
  output [DATA_WIDTH-1:0] m_axi_data
);

/*
 s_axi_data  -> bwd_data     -> fwd_data(1)  -> m_axi_data
 s_axi_valid -> bwd_valid    -> fwd_valid(1) -> m_axi_valid
 s_axi_ready <- bwd_ready(2) <- fwd_ready <- m_axi_ready
 (1) FORWARD_REGISTERED inserts a set of FF before m_axi_data and m_axi_valid
 (2) BACKWARD_REGISTERED insters a FF before s_axi_ready
*/

wire [DATA_WIDTH-1:0] bwd_data_s;
wire bwd_valid_s;
wire bwd_ready_s;
wire [DATA_WIDTH-1:0] fwd_data_s;
wire fwd_valid_s;
wire fwd_ready_s;

generate if (AXI_MODE == "AXI_LITE") begin
    reg                     fwd_valid   = 1'b0;
    reg [DATA_WIDTH-1:0]    fwd_data    = 'h00;
    wire                    stand_bwd_ready_s;
    always @(posedge clk) begin
        if(~resetn)begin
            fwd_valid <= 0;
        end else if (stand_bwd_ready_s)begin
            fwd_valid <= s_axi_valid & (~bwd_ready_s);
        end else begin
            fwd_valid <= fwd_valid;
        end
    end
    
    always @(posedge clk) begin
        if(~resetn)begin
            fwd_data <= 0;
        end else if (stand_bwd_ready_s & s_axi_valid)begin
            fwd_data <= s_axi_data;
        end else begin
            fwd_data <= fwd_data;
        end
    end
    
    assign  fwd_data_s  =   fwd_data;
    assign  fwd_valid_s =   fwd_valid;
    assign  stand_bwd_ready_s =   m_axi_ready | ~m_axi_valid;
    assign  bwd_ready_s =   m_axi_ready;
end else begin

end endgenerate

assign m_axi_data = fwd_data_s;
assign m_axi_valid = fwd_valid_s;
assign s_axi_ready = bwd_ready_s;

endmodule
