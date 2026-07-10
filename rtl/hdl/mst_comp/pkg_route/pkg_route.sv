`timescale 1 ns / 1 ps
module pkg_route
#(
     parameter  RAM_DEPTH   =   32768
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
    ,parameter  BAG_LENGTH  =   512
) 
(
     input                                      clk
    ,input                                      rst
   
    ,input  wire                                slv_cfg_msg_rden
    ,input  wire    [RAM_AWIDTH-1:0]            slv_cfg_msg_addr
    ,output wire    [RAM_DWIDTH-1:0]            slv_cfg_msg_dat

    ,input          [3:0]                       slv_sta_msg_vld
    ,input          [RAM_AWIDTH-1:0]            slv_sta_msg_addr
    ,input          [RAM_DWIDTH-1:0]            slv_sta_msg_dat
    
    ,output wire    [RAM_DWIDTH*2-1:0]          do_regoin_msg[RAM_DWIDTH-1:0]    //1
    ,output wire    [RAM_DWIDTH*3-1:0]          di_regoin_msg[RAM_DWIDTH-1:0]    //1
    ,output wire    [RAM_DWIDTH*4-1:0]          ai_regoin_msg[RAM_DWIDTH-1:0]     //1
    ,output wire    [RAM_DWIDTH-1:0]            rs232_1st_msg[RAM_DWIDTH-1:0]//1
    ,output wire    [RAM_DWIDTH-1:0]            rs232_2nd_msg[RAM_DWIDTH-1:0]//1
    ,output wire    [RAM_DWIDTH-1:0]            reseve_data[RAM_DWIDTH-1:0]//1

    ,input  wire    [RAM_DWIDTH-1:0]            pre_r_uuid[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH*2-1:0]          do_regoin_r_msg[RAM_DWIDTH-1:0]    //1
    ,input  wire    [RAM_DWIDTH*3-1:0]          di_regoin_r_msg[RAM_DWIDTH-1:0]    //1
    ,input  wire    [RAM_DWIDTH*4-1:0]          ai_regoin_r_msg[RAM_DWIDTH-1:0]     //1
    ,input  wire    [RAM_DWIDTH-1:0]            rs232_1st_r_msg[RAM_DWIDTH-1:0]//1
    ,input  wire    [RAM_DWIDTH-1:0]            rs232_2nd_r_msg[RAM_DWIDTH-1:0]//1
    ,input  wire    [RAM_DWIDTH-1:0]            reseve_r_data[RAM_DWIDTH-1:0]//1   
    
    ,output wire     [RAM_AWIDTH-1:0]           sys_addra[RAM_DWIDTH-1:0]//1
    ,output wire     [3:0]                      sys_wea[RAM_DWIDTH-1:0]//1
);
    wire    [3:0]               slv_1_msg_vld_s [RAM_DWIDTH-1:0];
    wire    [RAM_AWIDTH-1:0]    slv_1_msg_addr_s[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]    slv_1_msg_dat_s [RAM_DWIDTH-1:0];

//slave to master
    fen_top
    #(
         .RAM_DEPTH (RAM_DEPTH)
        ,.RAM_DWIDTH (RAM_DWIDTH)
        ,.RAM_AWIDTH (RAM_AWIDTH)
        ,.BAG_LENGTH (BAG_LENGTH)
    )
        fen_top_u
        (
              .clk (clk)
             ,.rst (rst)
           
            ,.slv_sta_msg_vld (slv_sta_msg_vld)
            ,.slv_sta_msg_addr(slv_sta_msg_addr)
            ,.slv_sta_msg_dat(slv_sta_msg_dat)
            
            ,.slv_1_msg_vld_s(slv_1_msg_vld_s)
            ,.slv_1_msg_addr_s(slv_1_msg_addr_s)
            ,.slv_1_msg_dat_s(slv_1_msg_dat_s)
            
        );

    genvar s;
    generate
        for(s =0 ; s<RAM_DWIDTH ;s=s+1)begin:fen_1
            fen_1
            #(
               .RAM_DEPTH(RAM_DEPTH)
                ,.RAM_DWIDTH(RAM_DWIDTH)
                ,.RAM_AWIDTH (RAM_AWIDTH)
            )
            fen_1_u
            (
                 .clk(clk)
                ,.reset(rst)
                //receive buffer
                ,.accept_buf_wea(slv_1_msg_vld_s[s])//1
                ,.accept_buf_addra(slv_1_msg_addr_s[s])//1
                ,.accept_buf_dina(slv_1_msg_dat_s[s])//1
                
                ,.sys_addra(sys_addra[s])//1
                ,.sys_wea(sys_wea[s])
                ,.pre_uuid()
             
                ,.do_regoin_msg (do_regoin_msg[s])   //1
                
                ,.di_regoin_msg (di_regoin_msg[s])   //1
                
                ,.ai_regoin_msg(ai_regoin_msg[s])     //1
                
                ,.rs232_1st_msg(rs232_1st_msg[s])//1
                ,.rs232_2nd_msg(rs232_2nd_msg[s])//1
               
                ,.reseve_data(reseve_data[s])//1
            );
       end
     endgenerate

//master to slave
    wire                        slv_1_msg_r_vld_s [RAM_DWIDTH-1:0];
    wire    [RAM_AWIDTH-1:0]    slv_1_msg_r_addr_s [RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]    slv_1_msg_r_dat_s [RAM_DWIDTH-1:0];

    shou_top 
    #(
         .RAM_DEPTH (RAM_DEPTH)
        ,.RAM_DWIDTH (RAM_DWIDTH)
        ,.RAM_AWIDTH (RAM_AWIDTH)
        ,.BAG_LENGTH (BAG_LENGTH)
    )
    shou_top_u
    (
          .clk (clk)
         ,.rst (rst)
       
        ,.slv_sta_msg_vld (slv_cfg_msg_rden)    ////////////////////////////
        ,.slv_sta_msg_addr(slv_cfg_msg_addr)
        ,.slv_sta_msg_dat(slv_cfg_msg_dat)
        
        ,.slv_1_msg_vld_s(slv_1_msg_r_vld_s)
        ,.slv_1_msg_addr_s(slv_1_msg_r_addr_s)
        ,.slv_1_msg_dat_s(slv_1_msg_r_dat_s)
    );

    genvar u;
    generate 
        for(u =0 ; u<RAM_DWIDTH ;u=u+1)begin:shou_1
            shou_1
            #(
                .RAM_DEPTH(RAM_DEPTH)
                ,.RAM_DWIDTH(RAM_DWIDTH)
                ,.RAM_AWIDTH (RAM_AWIDTH)
            )

            shou_1_u
            (
                .clk(clk)
                ,.reset(rst)
                //receive buffer
                ,.accept_buf_rea(slv_1_msg_r_vld_s[u])//1
                ,.accept_buf_addra(slv_1_msg_r_addr_s[u])//1
                ,.accept_buf_dina(slv_1_msg_r_dat_s[u])//1
                ,.pre_uuid(32'heffe_effe)
             
                ,.do_regoin_msg (do_regoin_r_msg[u])   //1
             
                ,.di_regoin_msg (di_regoin_r_msg[u])   //1

             
                ,.ai_regoin_msg(ai_regoin_r_msg[u])     //1
                
                ,.rs232_1st_msg(rs232_1st_r_msg[u])//1
                ,.rs232_2nd_msg(rs232_2nd_r_msg[u])//1
                ,.reseve_data(reseve_r_data[u])//1
            );
        end
    endgenerate

endmodule




