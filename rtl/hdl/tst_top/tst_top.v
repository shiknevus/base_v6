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
module tst_top(
     input              clk
    ,input              reset
    
    ,output reg         pkg_vld = 0
    ,input              pkg_rdy
    ,output [3:0]       pkg_keep
    ,output reg            pkg_last
    ,output [31:0]      pkg_dat
);
//    localparam PKG_NUM = 1251;//Ãÿ ‚µ„
    localparam PKG_NUM = 1252;
    
    reg [31:0]  work_cnt = 0;
    reg [31:0]  rd_cnt   = 0;
    reg [31:0]  rd_cnt_d1   = 0;
    reg [31:0]  rd_cnt_d2   = 0;
    reg [31:0]  backup_dat = 0;
    reg         pkg_rdy_d1  = 0;
    always @(posedge clk)begin
        pkg_rdy_d1 <= pkg_rdy;
    end
    
    localparam  STM_IDLE        = 'd0;
    localparam  STM_GEN_DAT     = 'd1;
    localparam  STM_RD_DAT      = 'd2;
    localparam  STM_END         = 'd7;
    reg [4:0] wk_state  = 'd0;
    reg [7:0] backup_cnt  = 'd0;
    wire          checksum_vld;
    wire        gen_dat_done;
    wire        rd_dat_done;
    always @(posedge clk) begin
        if(reset)begin
          wk_state  <=  STM_IDLE;
        end else begin
            case(wk_state)
                STM_IDLE: begin
                    if(1) begin
                        wk_state  <=  STM_GEN_DAT;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_GEN_DAT:begin
                    if(gen_dat_done)begin
                        wk_state  <=  STM_RD_DAT;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_RD_DAT:begin
                    if(rd_dat_done)begin
                        wk_state  <=  STM_END;
                    end else begin
                        wk_state  <=  wk_state;
                    end
                end
                STM_END:begin
                    
                end
                default: begin
                  wk_state  <=  STM_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        case(wk_state)
            STM_GEN_DAT:begin
                work_cnt <= work_cnt + 1;
            end
            default: begin
                work_cnt  <=  0;
            end
        endcase
    end
    assign  gen_dat_done = (work_cnt == PKG_NUM - 1) ? 1'b1 : 1'b0;

    always @(posedge clk) begin
        case(wk_state)
            STM_RD_DAT:begin
                if(pkg_rdy)begin
                    rd_cnt <= rd_cnt + 1;
                end else begin
                    rd_cnt <= rd_cnt;
                end
            end
            default: begin
              rd_cnt  <=  0;
            end
        endcase
    end

    wire pkg_last_tmp ;
    reg pkg_last_tmp_d1 = 'd0;
    assign  rd_dat_done = (pkg_rdy & (rd_cnt == PKG_NUM - 1)) ? 1'b1 : 1'b0;
    assign  pkg_last_tmp = (rd_cnt == PKG_NUM - 1) ? 1'b1 : 1'b0;
    
    reg pkg_vld_tmp = 'd0;
    always @(posedge clk) begin
        case(wk_state)
            STM_RD_DAT:begin
                pkg_vld_tmp  <= 1;
            end
            default: begin
              pkg_vld_tmp  <=  0;
            end
        endcase
    end
    
    localparam  RAM_DWIDTH  =   32;
    localparam  RAM_AWIDTH  =   $clog2(2048);
    wire    [RAM_AWIDTH-1:0]    wr_addr;
    wire    [RAM_DWIDTH-1:0]    wr_dat;
    wire    [RAM_AWIDTH-1:0]    rd_addr;
    wire    [RAM_DWIDTH-1:0]    rd_dat;
    wire    [3:0]               wr_ea;
    gen_ram
    #(
         .RAM_DWIDTH    (32     )
        ,.RAM_DEPTH     (2048   )
        ,.TYPE          ("TRUE" )
    )
        gen_ram_u
    (
         .clka  (clk        )
        ,.ena   (1          )
        ,.wea   (wr_ea    )
        ,.addra (wr_addr      )
        ,.dina  (wr_dat       )
        ,.clkb  (clk        )
        ,.enb   (pkg_rdy          )
        ,.addrb (rd_addr      )
        ,.doutb (rd_dat      )
    );
    assign  wr_addr = work_cnt;
    assign  wr_dat  = work_cnt + 1;
    assign  wr_ea   = (wk_state ==  STM_GEN_DAT) ? 4'b1111 : 4'b0000;
    assign  rd_addr = rd_cnt;
    assign pkg_keep = 4'b1111;
    assign pkg_dat  = rd_dat;
//    assign  pkg_last = ((rd_cnt_d2 == PKG_NUM - 1)) ? 1'b1 : 1'b0;

    always @(posedge clk)begin
        if(pkg_rdy)begin
            rd_cnt_d1 <= rd_cnt;
            rd_cnt_d2 <= rd_cnt_d1;
        end else begin
            rd_cnt_d1 <= rd_cnt_d1;
            rd_cnt_d2 <= rd_cnt_d2;
        end
    end

    always @(posedge clk)begin
        if(pkg_rdy)begin
            pkg_vld <= pkg_vld_tmp;
            pkg_last_tmp_d1 <= pkg_last_tmp;
            pkg_last<=pkg_last_tmp_d1;
        end else begin
            pkg_vld <= pkg_vld;
            pkg_last_tmp_d1 <= pkg_last_tmp_d1;
            pkg_last <= pkg_last;
        end
    end
endmodule

