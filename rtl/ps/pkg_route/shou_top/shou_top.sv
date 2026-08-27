`timescale 1 ns / 1 ps
module shou_top
#(
     parameter  RAM_DEPTH   =   32768
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
    ,parameter  BAG_LENGTH  =   512
) 
(
     input          clk 
    ,input          rst
   
    ,input wire                    slv_sta_msg_vld     
    ,input wire [RAM_AWIDTH-1:0]    slv_sta_msg_addr
    
    ,output reg [RAM_DWIDTH-1:0]    slv_sta_msg_dat
    
    ,output reg                         slv_1_msg_vld_s [RAM_DWIDTH-1:0]     
    ,output reg   [RAM_AWIDTH-1:0]     slv_1_msg_addr_s [RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH-1:0]    slv_1_msg_dat_s [RAM_DWIDTH-1:0]
    
);
 reg[RAM_AWIDTH-1:0] LOW_ADDR[RAM_DWIDTH-1:0];

generate 
    genvar i;
    for(i =0 ; i <RAM_DWIDTH ;i=i+1)
     assign LOW_ADDR[i]=i*512;
 endgenerate
 
genvar j;
    generate 
       for(j =0 ; j <RAM_DWIDTH ;j=j+1)begin
         always @(posedge clk)begin
         
            if(rst)begin
                 slv_1_msg_vld_s[j]<=0;  
                 slv_1_msg_addr_s[j]<=0; 
            end else begin
                if(slv_sta_msg_vld)begin
                    if ((LOW_ADDR[j]<=slv_sta_msg_addr)&&(slv_sta_msg_addr< LOW_ADDR[j]+BAG_LENGTH)) begin // fix off-by-one: word 511 dropped
                        slv_1_msg_vld_s[j]<=slv_sta_msg_vld;  
                        slv_1_msg_addr_s[j]<=slv_sta_msg_addr-j*512;
                    end else begin
                        slv_1_msg_vld_s[j]<=0;  
                        slv_1_msg_addr_s[j]<=slv_1_msg_addr_s[j];
                    end
                end else begin
                    slv_1_msg_vld_s[j]<=0;  
                    slv_1_msg_addr_s[j]<=slv_1_msg_addr_s[j];
                end
            end  
         end  
       end
    endgenerate

    always @(posedge clk)begin
        slv_sta_msg_dat <= 0;
        for (int k = 0; k < RAM_DWIDTH; k++) begin
            if ((LOW_ADDR[k]<=slv_sta_msg_addr)&&(slv_sta_msg_addr< LOW_ADDR[k]+BAG_LENGTH)) begin // fix off-by-one
                slv_sta_msg_dat<=slv_1_msg_dat_s[k];
            end
        end
    end
endmodule




