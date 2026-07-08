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
//
/////////////////////////////////////////////////////////////////
module compare_dat
#(
     parameter  RAM_DEPTH   =   4096
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
    ,parameter  PKG_NUM     =   RAM_DEPTH
)
(
     input                      clk
    ,input                      reset
    
    ,input  [4-1:0]             backup_wea
    ,input  [RAM_AWIDTH-1:0]    backup_addra
    ,input  [RAM_DWIDTH-1:0]    backup_dina

    ,input                      compare_src_vld
    ,input  [RAM_AWIDTH-1:0]    compare_src_addrb
    ,input  [RAM_DWIDTH-1:0]    compare_src_dat
    ,output reg                 compare_rslt
);

(* MARK_DEBUG="true" *)    wire    [RAM_AWIDTH-1:0]    backup_addrb;
(* MARK_DEBUG="true" *)    wire    [RAM_DWIDTH-1:0]    backup_doutb;
(* MARK_DEBUG="true" *)    wire    [RAM_DWIDTH-1:0]    backup_doutb_pong;
    reg                         compare_src_vld_d1;
(* MARK_DEBUG="true" *)    reg                         compare_src_vld_d2;
    reg     [RAM_DWIDTH-1:0]    compare_src_dat_d1;
(* MARK_DEBUG="true" *)    reg     [RAM_DWIDTH-1:0]    compare_src_dat_d2;
(* MARK_DEBUG="true" *)    reg                         ping_pang_flag;
    reg     [4-1:0]             backup_wea_d1;
    reg     [RAM_AWIDTH-1:0]    backup_addra_d1;
    reg     [RAM_DWIDTH-1:0]    backup_dina_d1;
    reg     [4-1:0]             backup_wea_d2;
    reg     [RAM_AWIDTH-1:0]    backup_addra_d2;
    reg     [RAM_DWIDTH-1:0]    backup_dina_d2;
    reg                         check_en;
    reg                         ping_pang_flag_d1;
    reg                         ping_pang_flag_f;
    always @(posedge clk)begin
        backup_wea_d1   <=  backup_wea;
        backup_addra_d1 <=  backup_addra;
        backup_dina_d1  <=  backup_dina;
        backup_wea_d2   <=  backup_wea_d1;
        backup_addra_d2 <=  backup_addra_d1;
        backup_dina_d2  <=  backup_dina_d1;
    end

    always @(posedge clk)begin
        if(reset)begin
            ping_pang_flag  <=  'd0;
        end else if((backup_addra == 1) & (backup_addra_d1 == 0))begin
            ping_pang_flag  <=  ~ping_pang_flag;
        end else begin
            ping_pang_flag  <=  ping_pang_flag;//0:ping read and pong write 1: ping write and pong read; 
        end
    end

    always @(posedge clk)begin
        ping_pang_flag_d1   <=  ping_pang_flag;
        ping_pang_flag_f    <=  (~ping_pang_flag) & ping_pang_flag_d1;
    end

    always @(posedge clk)begin
        if(reset)begin
            check_en    <=  'd0;
        end else if (ping_pang_flag_f) begin
            check_en    <=  'd1;
        end else begin
            check_en    <=  check_en;
        end
    end

    assign  backup_addrb    =   compare_src_addrb;

    gen_ram
    #(
         .RAM_DWIDTH    (RAM_DWIDTH  )
        ,.RAM_DEPTH     (RAM_DEPTH   )
        ,.TYPE          ("TRUE"      )
    )
        backup_ram_u
    (
         .clka  (clk            )
        ,.ena   (1              )
        ,.wea   (backup_wea_d2 & {4{ping_pang_flag}})//this port is used by the output port of send buffer ram,only write mode
        ,.addra (backup_addra_d2   )
        ,.dina  (backup_dina_d2    )
        ,.douta (               )
        ,.clkb  (clk            )//this port is used by protocol layer,only read mode;
        ,.enb   (1              )
        ,.web   (0              )
        ,.addrb (backup_addrb   )
        ,.dinb  (0              )
        ,.doutb (backup_doutb   )
    );

    gen_ram
    #(
         .RAM_DWIDTH    (RAM_DWIDTH  )
        ,.RAM_DEPTH     (RAM_DEPTH   )
        ,.TYPE          ("TRUE"      )
    )
        backup_ram_pong_u
    (
         .clka  (clk            )
        ,.ena   (1              )
        ,.wea   (backup_wea_d2 & {4{~ping_pang_flag}})//this port is used by the output port of send buffer ram,only write mode
        ,.addra (backup_addra_d2   )
        ,.dina  (backup_dina_d2    )
        ,.douta (               )
        ,.clkb  (clk            )//this port is used by protocol layer,only read mode;
        ,.enb   (1              )
        ,.web   (0              )
        ,.addrb (backup_addrb   )
        ,.dinb  (0              )
        ,.doutb (backup_doutb_pong   )
    );

    always @(posedge clk)begin
        compare_src_vld_d1  <=  compare_src_vld;
        compare_src_vld_d2  <=  compare_src_vld_d1;
    end
    
    always @(posedge clk)begin
        compare_src_dat_d1  <=  compare_src_dat;
        compare_src_dat_d2  <=  compare_src_dat_d1;
    end
    
    always @(posedge clk)begin
        if(reset)begin
            compare_rslt    <=  'd0;
        end else if(((compare_src_dat_d2 != backup_doutb) & compare_src_vld_d2 & (~ping_pang_flag) & check_en) | 
                    ((compare_src_dat_d2 != backup_doutb_pong) & compare_src_vld_d2 & (ping_pang_flag) & check_en))begin
            compare_rslt    <=  'd1;
        end else begin
            compare_rslt    <=  compare_rslt;
        end
    end
    
endmodule

