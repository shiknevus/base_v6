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
    reg                     drop;
    reg     [10:0]          buf_lvl;
    wire                    buf_cut;
    reg                     out_valid;
    reg     [BUF_WIDTH-1:0] out_dat;
    wire    [BUF_WIDTH-1:0] buf_rd_dat;
    
    assign  s_axi_tready = drop ? 1'b1 : ~buf_full;
    assign  buf_cut      = !s_axi_tlast && (buf_lvl >= BUF_DEPTH-1);
    assign  buf_wr_en    = s_axi_tvalid & s_axi_tready & !drop;
    assign  buf_wr_dat   = {1'b0,s_axi_tlast | buf_cut,s_axi_tdata[31:0]};
    always @(posedge clk) begin
        if (reset) begin
            drop    <= 1'b0;
            buf_lvl <= 'd0;
        end else begin
            if (s_axi_tvalid && s_axi_tready && s_axi_tlast)
                drop <= 1'b0;
            else if (s_axi_tvalid && s_axi_tready && buf_cut)
                drop <= 1'b1;
            case ({buf_wr_en,buf_rd_en})
                2'b10: buf_lvl <= buf_lvl + 1'b1;
                2'b01: buf_lvl <= buf_lvl - 1'b1;
                default: buf_lvl <= buf_lvl;
            endcase
        end
    end
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
    assign  buf_rd_en       =   !buf_empty & (!out_valid | m_axi_tready);   // FWFT: dout valid in the pop cycle
    always @(posedge clk) begin
        if (reset) begin
            out_valid  <= 1'b0;
            out_dat    <= 'd0;
        end else if (buf_rd_en) begin
            out_valid  <= 1'b1;
            out_dat    <= buf_rd_dat;
        end else if (m_axi_tready)
            out_valid  <= 1'b0;
    end
    assign  m_axi_tvalid    =   out_valid;
    assign  m_axi_tlast     =   out_dat[32] & out_valid;
    assign  m_axi_tdata     =   out_dat[31:0];
    assign  m_axi_tkeep     =   4'hf;
endmodule

