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
module ethcat_send_cache(
     input              clk
    ,input              reset
    //upstream axi stream intf
    ,input              s_crc_tx_tvalid
    ,output             s_crc_tx_tready
    ,input              s_crc_tx_sop
    ,input              s_crc_tx_eop
    ,input  [31:0]      s_crc_tx_tdata
    
    //downstream axi stream intf
    ,(* MARK_DEBUG="true" *)output             m_boroa_tx_tvalid
    ,(* MARK_DEBUG="true" *)input              m_boroa_tx_tready
    ,(* MARK_DEBUG="true" *)output     [3:0]   m_boroa_tx_tkeep
    ,(* MARK_DEBUG="true" *)output             m_boroa_tx_tlast
    ,(* MARK_DEBUG="true" *)output     [31:0]  m_boroa_tx_tdata

);
    localparam  BUF_DEPTH   =   1024;
    localparam  BUF_WIDTH   =   36;
    wire                    buf_wr_en;
    wire    [BUF_WIDTH-1:0] buf_wr_dat;
    wire                    buf_empty;
    wire                    buf_rd_en;
    wire    [BUF_WIDTH-1:0] buf_rd_dat;
    reg     [10:0]          buf_lvl = 'd0;  // words written - words read
    reg     [8:0]           stall   = 'd0;  // cycles data pending without read, saturates at 256
    reg                     drop    = 1'b0; // discarding rest of current frame
    wire                    frm_rej = stall[8] || (buf_lvl >= BUF_DEPTH-1);      // at sop: link stalled -> drop whole frame
    wire                    frm_cut = !s_crc_tx_eop && (buf_lvl >= BUF_DEPTH-1); // mid-frame full: close with eop
    assign  s_crc_tx_tready =   1'b1;   // no upstream backpressure, frames dropped here
    assign  buf_wr_en   =   s_crc_tx_tvalid & (s_crc_tx_sop ? !frm_rej : !drop);
    assign  buf_wr_dat  =   {s_crc_tx_sop,s_crc_tx_eop | frm_cut,s_crc_tx_tdata[31:0]};
    assign  buf_rd_en   =   !buf_empty & m_boroa_tx_tready;
    always @(posedge clk) begin
        if (reset)
            drop <= 1'b0;
        else if (s_crc_tx_tvalid & s_crc_tx_eop)
            drop <= 1'b0;
        else if (s_crc_tx_tvalid & s_crc_tx_sop)
            drop <= frm_rej;
        else if (buf_wr_en & frm_cut)
            drop <= 1'b1;
    end
    always @(posedge clk) begin
        if (reset | buf_rd_en | buf_empty)
            stall <= 'd0;
        else if (!stall[8])
            stall <= stall + 1'b1;
    end
    always @(posedge clk) begin
        if (reset)
            buf_lvl <= 'd0;
        else case ({buf_wr_en,buf_rd_en})
            2'b10:   buf_lvl <= buf_lvl + 1'b1;
            2'b01:   buf_lvl <= buf_lvl - 1'b1;
            default: buf_lvl <= buf_lvl;
        endcase
    end
    gen_fifo
    #(
         .BUF_DWIDTH    (BUF_WIDTH  )
        ,.DEPTH         (BUF_DEPTH  )
        ,.TYPE          ("BLOCK"    )
    )
        gen_fifo_u
        (
             .rst       (reset      )
            ,.clk       (clk        )
            ,.wr_en     (buf_wr_en  )
            ,.din       (buf_wr_dat )
            ,.rd_en     (buf_rd_en  )
            ,.dout      (buf_rd_dat)
            ,.full      ()
            ,.empty     (buf_empty)
        );
    assign  m_boroa_tx_tvalid   =   !buf_empty;
    assign  m_boroa_tx_sop      =   buf_rd_dat[33];
    assign  m_boroa_tx_tlast      =   buf_rd_dat[32] & !buf_empty;
    assign  m_boroa_tx_tdata    =   buf_rd_dat[31:0];
    assign  m_boroa_tx_tkeep    =   4'hf;
endmodule

