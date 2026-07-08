interface emcc_token_if #(
  parameter DATA_WIDTH  = 32
);
  // token interface
  logic                           wvalid;
  logic                           wready;
  logic [DATA_WIDTH-1:0]          wdata;
  
  logic [1:0]                     bresp;
  logic                           bvalid;
  logic                           bready;

  modport mp (input wready, bresp, bvalid, output wdata, wvalid, bready);
  modport sp (output wready, bresp, bvalid, input wdata, wvalid, bready);

endinterface

interface emcc_reg_if #(
  parameter REG_AWIDTH  = 10,
  parameter REG_DWIDTH  = 32
);
  // token interface
    logic                           clk;
    logic                           reset;
    logic                           we;
    logic    [REG_AWIDTH-1:0]    addr;
    logic    [REG_DWIDTH-1:0]    wr_dat;
    logic                           re;
    logic    [REG_AWIDTH-1:0]    rd_addr;
    logic                           rd_vld;
    logic    [REG_DWIDTH-1:0]    rd_dat;

  modport mp (output clk, reset, we, addr, wr_dat, re, rd_addr, input rd_vld, rd_dat);
  modport sp (output rd_vld, rd_dat, input clk, reset, we, addr, wr_dat, re, rd_addr);

endinterface

//interface apb_if #(
//  parameter ADDR_WIDTH  = 12,
//  parameter DATA_WIDTH  = 32
//);
//  logic [ADDR_WIDTH-1:0]          paddr;
//  logic                           psel;
//  logic                           penable;
//  logic                           pwrite;
//  logic [DATA_WIDTH-1:0]          pwdata;
//  logic                           pready;
//  logic [DATA_WIDTH-1:0]          prdata;
//  logic                           pslverr;
//
//  modport mp (output paddr, psel, penable, pwrite, pwdata, input pready, prdata, pslverr);
//  modport sp (input paddr, psel, penable, pwrite, pwdata, output pready, prdata, pslverr);
//
//endinterface
