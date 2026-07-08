/////////////////////////////////////////////////////////////////
// Company:
// Engineer:      Luhui
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
//  master station rs232 components
/////////////////////////////////////////////////////////////////
module location_comp_driver
(
     input wire                        clk
    ,input wire                        reset
    ,output reg                        instart_reg
    ,output reg                        outstart_reg

    ,input wire                        comp_in_start
    ,input wire                        comp_out_start
    ,input wire [3:0]                  work_type
    ,input wire [2:0]                  work_in_path
    ,input wire [13:0]                 work_out_path
    ,input wire [2:0]                  cur_in_path
    ,input wire [13:0]                 cur_out_path
    ,input wire                        cfg_comp_done
    ,input wire                        cfg_comp_done2
    ,output reg                        comp_error
    ,output wire                       mat_in_place
    
    ,input wire                        mf
    ,input wire                        dgt_error
    ,output reg                        dgt_start
    ,output reg                        dgt_start_f
    ,input wire                        qdqg_up
    ,input wire                        qdqg_down
    ,output reg                        qdqg_out
    ,input wire                        cdqg_put_out
    ,input wire                        cdqg_draw_back
    ,output reg                        cdqg_out
);
    localparam  DRV_NULL                =   'd0;
    localparam  DRV_IDLE                =   'd1;
    localparam  DRV_CK                  =   'd2;   
    localparam  DRV_CK_ERR              =   'd3;
    localparam  DRV_CK_ERR2             =   'd4;
    localparam  DRV_ROLLER_IN_WORK      =   'd5;
    localparam  DRV_ROLLER_OUT_WORK     =   'd6;
    localparam  DRV_VALVE1_UP_WORK      =   'd7;
    localparam  DRV_VALVE1_DN_WORK      =   'd8;
    localparam  DRV_VALVE2_PUSH_WORK    =   'd9;
    localparam  DRV_VALVE2_BACK_WORK    =   'd10;
    localparam  DRV_DONE                =   'd11;
    localparam  WK_MODE = 1'b1;
    
    reg [5:0] wk_state = DRV_NULL;
    reg done_r;
    reg done_r_r;
    reg done2_r;
    reg done2_r_r;
    reg instart_r;
    reg instart_r_r;
    reg outstart_r;
    reg outstart_r_r;
    wire done_pose;
    wire done2_pose;
    wire instart_pose;
    wire outstart_pose;
    wire instart_err_flag;
    wire valve1_upflag;
    wire valve1_dnflag;
    wire valve2_pushflag;
    wire valve2_backflag;

    assign  instart_err_flag = ~cdqg_draw_back | cdqg_put_out | mf;
    assign  valve1_upflag = ~qdqg_down & qdqg_up;
    assign  valve1_dnflag = qdqg_down & ~qdqg_up;
    assign  valve2_pushflag = ~cdqg_draw_back & cdqg_put_out;
    assign  valve2_backflag = cdqg_draw_back & ~cdqg_put_out;
    assign  mat_in_place = mf;

    always @(posedge clk)begin
        if(reset | work_type[2:0] != 3'd3)begin
            wk_state <= DRV_NULL;
        end else if(dgt_error & (instart_reg | outstart_reg))begin  
            wk_state <= DRV_CK_ERR;
        end else begin
            case(wk_state)
                DRV_NULL:begin
                    wk_state <= DRV_IDLE;
                end
                DRV_IDLE:begin
                    if(outstart_reg) begin
                        wk_state <= DRV_VALVE2_BACK_WORK;
                    end else if(instart_reg) begin
                        if(instart_err_flag)begin
                            wk_state <= DRV_CK_ERR2;
                        end else begin
                            wk_state <= DRV_VALVE1_UP_WORK;
                        end
                    end else begin
                        wk_state <= wk_state;
                    end
                end
                DRV_CK_ERR:begin
                    if(~dgt_error)begin
                        wk_state <= DRV_IDLE;
                    end else begin
                        wk_state <= wk_state;
                    end
                end
                DRV_CK_ERR2:begin
                    if(!(instart_reg & instart_err_flag))begin
                        wk_state <= DRV_IDLE;
                    end else begin
                        wk_state <= wk_state;
                    end
                end
                DRV_VALVE1_UP_WORK:begin
                    if(valve1_upflag)begin
                        wk_state <= DRV_ROLLER_IN_WORK;
                    end else begin
                        wk_state <= wk_state;
                    end
                end
                DRV_VALVE2_BACK_WORK:begin
                    if(valve2_backflag)begin
                        wk_state <= DRV_VALVE1_DN_WORK;
                    end else begin
                        wk_state <= wk_state;
                    end
                end
                DRV_VALVE1_DN_WORK:begin
                    if(valve1_dnflag)begin
                        wk_state <= DRV_ROLLER_OUT_WORK;
                    end else begin
                        wk_state <= wk_state;
                    end
                end
                DRV_ROLLER_OUT_WORK:begin
                    if(outstart_reg & done2_pose)begin
                        wk_state <= DRV_DONE;
                    end else begin
                        wk_state <= wk_state;
                    end
                end
                DRV_ROLLER_IN_WORK:begin
                    if(instart_reg & done_pose)begin
                        wk_state <= DRV_VALVE2_PUSH_WORK;
                    end else begin
                        wk_state <= wk_state;
                    end
                end
                DRV_VALVE2_PUSH_WORK:begin
                    if(valve2_pushflag)begin
                        wk_state <= DRV_DONE;
                    end else begin
                        wk_state <= wk_state;
                    end
                end
                DRV_DONE:begin 
                    wk_state <= DRV_IDLE;
                end
                default:begin
                    wk_state <= DRV_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            dgt_start <= 1'b0;
            dgt_start_f <= work_type[3:3];
        end else begin
            case(wk_state)
                DRV_ROLLER_IN_WORK,DRV_ROLLER_OUT_WORK:begin
                    dgt_start <= 1'b1;
                    dgt_start_f <= work_type[3:3];
                end
                DRV_VALVE2_PUSH_WORK:begin
                    if(WK_MODE == 1'b1 && instart_reg)begin
                        dgt_start <= 1'b1;
                        dgt_start_f <= work_type[3:3];
                    end else begin
                        dgt_start <= 1'b0;
                        dgt_start_f <= work_type[3:3];
                    end
                end
                default:begin
                    dgt_start <= 1'b0;
                    dgt_start_f <= work_type[3:3];
                end
            endcase
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            qdqg_out <= 1'b0;
        end else begin
            case(wk_state)
                DRV_VALVE1_UP_WORK:begin
                    qdqg_out <= 1'b1;
                end
                DRV_VALVE1_DN_WORK:begin
                    qdqg_out <= 1'b0;
                end
                default:begin
                end
            endcase
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            cdqg_out <= 1'b0;
        end else begin
            case(wk_state)
                DRV_VALVE2_PUSH_WORK:begin
                    cdqg_out <= 1'b1;
                end
                DRV_VALVE2_BACK_WORK:begin
                    cdqg_out <= 1'b0;
                end
                default:begin
                end
            endcase
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            comp_error <= 1'b0;
        end else begin
            case(wk_state)
                DRV_CK_ERR,DRV_CK_ERR2:begin
                    comp_error <= 1'b1;
                end
                DRV_IDLE:begin
                    comp_error <= 1'b0;
                end
                default:begin
                end
            endcase
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            instart_r <= 1'b0;
            instart_r_r <= 1'b0;
        end else begin
            instart_r <= comp_in_start;
            instart_r_r <= instart_r;
        end
    end
    assign  instart_pose = instart_r & ~instart_r_r;

    always @(posedge clk)begin
        if(reset)begin
            outstart_r <= 1'b0;
            outstart_r_r <= 1'b0;
        end else begin
            outstart_r <= comp_out_start;
            outstart_r_r <= outstart_r;
        end
    end
    assign  outstart_pose = outstart_r & ~outstart_r_r;
    
    always @(posedge clk)begin
        if(reset)begin
            instart_reg <= 1'b0;
            outstart_reg <= 1'b0;
        end else begin
            case(wk_state)
                DRV_IDLE:begin
                    if(outstart_pose && work_out_path == cur_out_path)begin
                        instart_reg <= 1'b0;
                        outstart_reg <= 1'b1;
                    end else if(instart_pose && work_in_path == cur_in_path)begin
                        instart_reg <= 1'b1;
                        outstart_reg <= 1'b0;
                    end
                end
                DRV_DONE,DRV_CK_ERR,DRV_CK_ERR2:begin
                    instart_reg <= 1'b0;
                    outstart_reg <= 1'b0;
                end
                default:begin
                end
            endcase
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            done_r <= 1'b0;
            done_r_r <= 1'b0;
        end else begin
            done_r <= cfg_comp_done;
            done_r_r <= done_r;
        end
    end
    assign  done_pose = done_r & ~done_r_r;
    
    always @(posedge clk)begin
        if(reset)begin
            done2_r <= 1'b0;
            done2_r_r <= 1'b0;
        end else begin
            done2_r <= cfg_comp_done2;
            done2_r_r <= done2_r;
        end
    end
    assign  done2_pose = done2_r & ~done2_r_r;

endmodule