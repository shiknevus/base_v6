`timescale 1 ns / 1 ps
`include "depot_addr_map.vh"
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
    ,input                                      sy_jerk
   
    ,input  wire                                slv_cfg_msg_rden
    ,input  wire    [RAM_AWIDTH-1:0]            slv_cfg_msg_addr
    ,output wire    [RAM_DWIDTH-1:0]            slv_cfg_msg_dat

    ,input          [3:0]                       slv_sta_msg_vld
    ,input          [RAM_AWIDTH-1:0]            slv_sta_msg_addr
    ,input          [RAM_DWIDTH-1:0]            slv_sta_msg_dat
    
    ,output wire    [RAM_DWIDTH*2-1:0]          do_regoin_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH*3-1:0]          di_regoin_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH*4-1:0]          ai_regoin_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH-1:0]            rs232_1st_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH-1:0]            rs232_2nd_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH-1:0]            rs232_3rd_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH-1:0]            rs232_4th_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH-1:0]            rs232_5th_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH-1:0]            rs232_6th_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH-1:0]            rs232_7th_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH-1:0]            rs232_8th_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH-1:0]            rs485_1st_msg[RAM_DWIDTH-1:0]
    ,output wire                                rs232_1st_flag
    ,output wire                                rs232_2nd_flag
    ,output wire                                rs232_3rd_flag
    ,output wire                                rs232_4th_flag
    ,output wire                                rs232_5th_flag
    ,output wire                                rs232_6th_flag
    ,output wire                                rs232_7th_flag
    ,output wire                                rs232_8th_flag
    ,output wire                                rs485_1st_flag
    ,output wire    [RAM_DWIDTH-1:0]            pul_motor0_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH-1:0]            pul_motor1_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH-1:0]            pul_motor2_msg[RAM_DWIDTH-1:0]
    ,output wire    [RAM_DWIDTH-1:0]            pul_motor3_msg[RAM_DWIDTH-1:0]
    ,output wire                                pul_motor0_flag
    ,output wire                                pul_motor1_flag
    ,output wire                                pul_motor2_flag
    ,output wire                                pul_motor3_flag

    ,input  wire    [RAM_DWIDTH-1:0]            pre_r_uuid[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH*2-1:0]          do_regoin_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH*3-1:0]          di_regoin_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH*4-1:0]          ai_regoin_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH-1:0]            rs232_1st_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH-1:0]            rs232_2nd_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH-1:0]            rs232_3rd_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH-1:0]            rs232_4th_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH-1:0]            rs232_5th_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH-1:0]            rs232_6th_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH-1:0]            rs232_7th_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH-1:0]            rs232_8th_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH-1:0]            rs485_1st_r_msg[RAM_DWIDTH-1:0]
    ,output wire                                rs232_1st_r_flag
    ,output wire                                rs232_2nd_r_flag
    ,output wire                                rs232_3rd_r_flag
    ,output wire                                rs232_4th_r_flag
    ,output wire                                rs232_5th_r_flag
    ,output wire                                rs232_6th_r_flag
    ,output wire                                rs232_7th_r_flag
    ,output wire                                rs232_8th_r_flag
    ,output wire                                rs485_1st_r_flag
    ,input  wire    [RAM_DWIDTH-1:0]            pul_motor0_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH-1:0]            pul_motor1_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH-1:0]            pul_motor2_r_msg[RAM_DWIDTH-1:0]
    ,input  wire    [RAM_DWIDTH-1:0]            pul_motor3_r_msg[RAM_DWIDTH-1:0]
    ,output wire                                pul_motor0_r_flag
    ,output wire                                pul_motor1_r_flag
    ,output wire                                pul_motor2_r_flag
    ,output wire                                pul_motor3_r_flag
    
    ,output wire     [RAM_AWIDTH-1:0]           sys_addra[RAM_DWIDTH-1:0]
    ,output wire     [3:0]                      sys_wea[RAM_DWIDTH-1:0]

);
    wire    [3:0]               slv_1_msg_vld_s [RAM_DWIDTH-1:0];
    wire    [RAM_AWIDTH-1:0]    slv_1_msg_addr_s[RAM_DWIDTH-1:0];
    wire    [RAM_DWIDTH-1:0]    slv_1_msg_dat_s [RAM_DWIDTH-1:0];

    assign pul_motor0_r_flag = (slv_cfg_msg_rden & (slv_cfg_msg_addr[8:0]==`DEPOT_BIAS_PUL_MOTOR0)) ? 1'b1 : 1'b0;
    assign pul_motor1_r_flag = (slv_cfg_msg_rden & (slv_cfg_msg_addr[8:0]==`DEPOT_BIAS_PUL_MOTOR1)) ? 1'b1 : 1'b0;
    assign pul_motor2_r_flag = (slv_cfg_msg_rden & (slv_cfg_msg_addr[8:0]==`DEPOT_BIAS_PUL_MOTOR2)) ? 1'b1 : 1'b0;
    assign pul_motor3_r_flag = (slv_cfg_msg_rden & (slv_cfg_msg_addr[8:0]==`DEPOT_BIAS_PUL_MOTOR3)) ? 1'b1 : 1'b0;
    assign pul_motor0_flag   = (slv_sta_msg_vld  & (slv_sta_msg_addr[8:0]==`DEPOT_BIAS_PUL_MOTOR0)) ? 1'b1 : 1'b0;
    assign pul_motor1_flag   = (slv_sta_msg_vld  & (slv_sta_msg_addr[8:0]==`DEPOT_BIAS_PUL_MOTOR1)) ? 1'b1 : 1'b0;
    assign pul_motor2_flag   = (slv_sta_msg_vld  & (slv_sta_msg_addr[8:0]==`DEPOT_BIAS_PUL_MOTOR2)) ? 1'b1 : 1'b0;
    assign pul_motor3_flag   = (slv_sta_msg_vld  & (slv_sta_msg_addr[8:0]==`DEPOT_BIAS_PUL_MOTOR3)) ? 1'b1 : 1'b0;
    assign rs232_1st_r_flag  = (slv_cfg_msg_rden & (slv_cfg_msg_addr[8:0]==`DEPOT_BIAS_RS232_1ST )) ? 1'b1 : 1'b0;
    assign rs232_2nd_r_flag  = (slv_cfg_msg_rden & (slv_cfg_msg_addr[8:0]==`DEPOT_BIAS_RS232_2ND )) ? 1'b1 : 1'b0;
    assign rs232_3rd_r_flag  = (slv_cfg_msg_rden & (slv_cfg_msg_addr[8:0]==`DEPOT_BIAS_RS232_3RD )) ? 1'b1 : 1'b0;
    assign rs232_4th_r_flag  = (slv_cfg_msg_rden & (slv_cfg_msg_addr[8:0]==`DEPOT_BIAS_RS232_4TH )) ? 1'b1 : 1'b0;
    assign rs232_5th_r_flag  = (slv_cfg_msg_rden & (slv_cfg_msg_addr[8:0]==`DEPOT_BIAS_RS232_5TH )) ? 1'b1 : 1'b0;
    assign rs232_6th_r_flag  = (slv_cfg_msg_rden & (slv_cfg_msg_addr[8:0]==`DEPOT_BIAS_RS232_6TH )) ? 1'b1 : 1'b0;
    assign rs232_7th_r_flag  = (slv_cfg_msg_rden & (slv_cfg_msg_addr[8:0]==`DEPOT_BIAS_RS232_7TH )) ? 1'b1 : 1'b0;
    assign rs232_8th_r_flag  = (slv_cfg_msg_rden & (slv_cfg_msg_addr[8:0]==`DEPOT_BIAS_RS232_8TH )) ? 1'b1 : 1'b0;
    assign rs485_1st_r_flag  = (slv_cfg_msg_rden & (slv_cfg_msg_addr[8:0]==`DEPOT_BIAS_RS485_1ST )) ? 1'b1 : 1'b0;
    assign rs232_1st_flag    = (slv_sta_msg_vld  & (slv_sta_msg_addr[8:0]==`DEPOT_BIAS_RS232_1ST )) ? 1'b1 : 1'b0;
    assign rs232_2nd_flag    = (slv_sta_msg_vld  & (slv_sta_msg_addr[8:0]==`DEPOT_BIAS_RS232_2ND )) ? 1'b1 : 1'b0;
    assign rs232_3rd_flag    = (slv_sta_msg_vld  & (slv_sta_msg_addr[8:0]==`DEPOT_BIAS_RS232_3RD )) ? 1'b1 : 1'b0;
    assign rs232_4th_flag    = (slv_sta_msg_vld  & (slv_sta_msg_addr[8:0]==`DEPOT_BIAS_RS232_4TH )) ? 1'b1 : 1'b0;
    assign rs232_5th_flag    = (slv_sta_msg_vld  & (slv_sta_msg_addr[8:0]==`DEPOT_BIAS_RS232_5TH )) ? 1'b1 : 1'b0;
    assign rs232_6th_flag    = (slv_sta_msg_vld  & (slv_sta_msg_addr[8:0]==`DEPOT_BIAS_RS232_6TH )) ? 1'b1 : 1'b0;
    assign rs232_7th_flag    = (slv_sta_msg_vld  & (slv_sta_msg_addr[8:0]==`DEPOT_BIAS_RS232_7TH )) ? 1'b1 : 1'b0;
    assign rs232_8th_flag    = (slv_sta_msg_vld  & (slv_sta_msg_addr[8:0]==`DEPOT_BIAS_RS232_8TH )) ? 1'b1 : 1'b0;
    assign rs485_1st_flag    = (slv_sta_msg_vld  & (slv_sta_msg_addr[8:0]==`DEPOT_BIAS_RS485_1ST )) ? 1'b1 : 1'b0;

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
                ,.accept_buf_wea(slv_1_msg_vld_s[s])
                ,.accept_buf_addra(slv_1_msg_addr_s[s])
                ,.accept_buf_dina(slv_1_msg_dat_s[s])
                
                ,.sys_addra(sys_addra[s])
                ,.sys_wea(sys_wea[s])
                ,.pre_uuid()
             
                ,.do_regoin_msg (do_regoin_msg[s])   
                
                ,.di_regoin_msg (di_regoin_msg[s])   
                
                ,.ai_regoin_msg(ai_regoin_msg[s])     
                
                ,.rs232_1st_msg(rs232_1st_msg[s])
                ,.rs232_2nd_msg(rs232_2nd_msg[s])
                ,.rs232_3rd_msg(rs232_3rd_msg[s])
                ,.rs232_4th_msg(rs232_4th_msg[s])
                ,.rs232_5th_msg(rs232_5th_msg[s])
                ,.rs232_6th_msg(rs232_6th_msg[s])
                ,.rs232_7th_msg(rs232_7th_msg[s])
                ,.rs232_8th_msg(rs232_8th_msg[s])
                ,.rs485_1st_msg(rs485_1st_msg[s])
               
                ,.pul_motor0_msg(pul_motor0_msg[s])
                ,.pul_motor1_msg(pul_motor1_msg[s])
                ,.pul_motor2_msg(pul_motor2_msg[s])
                ,.pul_motor3_msg(pul_motor3_msg[s])
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
                ,.reset(rst|sy_jerk)
                //receive buffer
                ,.accept_buf_rea(slv_1_msg_r_vld_s[u])
                ,.accept_buf_addra(slv_1_msg_r_addr_s[u])
                ,.accept_buf_dina(slv_1_msg_r_dat_s[u])
                ,.pre_uuid(32'heffe_effe)
             
                ,.do_regoin_msg (do_regoin_r_msg[u])
                ,.di_regoin_msg (di_regoin_r_msg[u])
                ,.ai_regoin_msg(ai_regoin_r_msg[u])
                ,.rs232_1st_msg(rs232_1st_r_msg[u])
                ,.rs232_2nd_msg(rs232_2nd_r_msg[u])
                ,.rs232_3rd_msg(rs232_3rd_r_msg[u])
                ,.rs232_4th_msg(rs232_4th_r_msg[u])
                ,.rs232_5th_msg(rs232_5th_r_msg[u])
                ,.rs232_6th_msg(rs232_6th_r_msg[u])
                ,.rs232_7th_msg(rs232_7th_r_msg[u])
                ,.rs232_8th_msg(rs232_8th_r_msg[u])
                ,.rs485_1st_msg(rs485_1st_r_msg[u])
                ,.pul_motor0_msg(pul_motor0_r_msg[u])
                ,.pul_motor1_msg(pul_motor1_r_msg[u])
                ,.pul_motor2_msg(pul_motor2_r_msg[u])
                ,.pul_motor3_msg(pul_motor3_r_msg[u])
            );
        end
    endgenerate

endmodule




