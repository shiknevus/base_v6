module ps_rd_dat_route #
(
     parameter integer  CHANNEL_BIAS    =   0
    ,parameter integer  CHANNEL_NUM     =   32
    ,parameter          PS_REG_DWIDTH   =   32
)
(
     input  wire                            ps_reg_clk
    ,input  wire                            ps_reg_reset
    ,output reg                             ps_reg_rd_vld
    ,output reg     [PS_REG_DWIDTH-1:0]     ps_reg_rd_dat

    ,input  wire                            ds_rd_vld[(CHANNEL_BIAS+CHANNEL_NUM-1):CHANNEL_BIAS]
    ,input  wire    [PS_REG_DWIDTH-1:0]     ds_rd_dat[(CHANNEL_BIAS+CHANNEL_NUM-1):CHANNEL_BIAS]
);

    always @(posedge ps_reg_clk)begin
        ps_reg_rd_vld   <=  0;
        ps_reg_rd_dat   <=  0;
        for (int k = CHANNEL_BIAS; k < (CHANNEL_BIAS+CHANNEL_NUM); k++) begin
            if (ds_rd_vld[k]) begin
                ps_reg_rd_vld   <=  ds_rd_vld[k];
                ps_reg_rd_dat   <=  ds_rd_dat[k];
            end
        end
    end
endmodule