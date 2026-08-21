/////////////////////////////////////////////////////////////////
// Company:
// Engineer:      Huaye Zhang
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
//       |<--------------------------32bit-------------------------->|
//       |  0        7 |  8       15   | 16        23 |  24      31  |
//       |     CMD     |     INDEX     |    DST ADDR_L(reg addr)     |
//       |  DST ADDR_H(slave station)  |       package length        |
//       |                           RSCV                            |
//       |-----------------------------------------------------------|
//       |                                                           |
//       |                           DATA                            |
//       |-----------------------------------------------------------|
/////////////////////////////////////////////////////////////////
module axi_cache(
     input              clk
    ,input              reset
    
    ,input              s_axi_tvalid
    ,output             s_axi_tready
    ,input  [3:0]       s_axi_tkeep
    ,input              s_axi_tlast
    ,input  [31:0]      s_axi_tdata
    
    ,output             m_axi_tvalid
    ,input              m_axi_tready
    ,output     [3:0]   m_axi_tkeep
    ,output             m_axi_tlast
    ,output     [31:0]  m_axi_tdata

);

    localparam  BUF_DEPTH   =   1024;
    localparam  BUF_WIDTH   =   36;
    wire                    buf_wr_en;
    wire    [BUF_WIDTH-1:0] buf_wr_dat;
    wire                    buf_empty;
    wire                    buf_rd_en;
    wire                    buf_full;
    wire    [BUF_WIDTH-1:0] buf_rd_dat;
    
    assign  buf_wr_en   =   s_axi_tvalid & s_axi_tready;
    assign  buf_wr_dat  =   {1'b0,s_axi_tlast,s_axi_tdata[31:0]};
    assign  s_axi_tready = ~buf_full;
    gen_fifo
    #(
         .BUF_DWIDTH    (BUF_WIDTH  )
        ,.DEPTH         (BUF_DEPTH  )
        ,.TYPE          ("BLOCK"    )//
    )
        gen_fifo_u
        (
             .rst       (reset      )
            ,.clk       (clk        )
            ,.wr_en     (buf_wr_en  )
            ,.din       (buf_wr_dat )
            ,.rd_en     (buf_rd_en  )
            ,.dout      (buf_rd_dat )
            ,.full      (buf_full   )
            ,.empty     (buf_empty  )
        );
    assign  buf_rd_en       =   !buf_empty & m_axi_tready;
    assign  m_axi_tvalid    =   !buf_empty;
    assign  m_axi_tlast     =   buf_rd_dat[32] & !buf_empty;
    assign  m_axi_tdata     =   buf_rd_dat[31:0];
    assign  m_axi_tkeep     =   4'hf;
endmodule

