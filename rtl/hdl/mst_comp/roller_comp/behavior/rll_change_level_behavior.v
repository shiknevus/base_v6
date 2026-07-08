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
module rll_change_level_behavior
#(
     parameter   UIC_DROC = 1'b1
)
(
     input wire                        clk
    ,input wire                        reset
    
    ,input wire                        comp_in_start
    ,input wire                        comp_out_start
    ,output reg                        wait_in_start
    ,output reg                        wait_out_start
    ,input wire                        cfg_comp_done
    ,input wire                        cfg_comp_done2

    ,input wire                        hcqg_up
    ,input wire                        hcqg_down
    ,output reg                        hcqg_out_up
    ,output reg                        hcqg_out_down
);
    
    reg instart_r;
    reg instart_r_r;
    reg outstart_r;
    reg outstart_r_r;
    reg instart_reg;
    reg outstart_reg;
    reg done_reg;
    reg done_r;
    reg done_r_r;
    reg done2_reg;
    reg done2_r;
    reg done2_r_r;
    wire instart_pose;
    wire outstart_pose;
    wire done_pose;
    wire done2_pose;
    wire valve_upflag;
    wire valve_dnflag;
    
    assign  valve_upflag = ~hcqg_down & hcqg_up;
    assign  valve_dnflag = hcqg_down & ~hcqg_up;

    always @(posedge clk)begin
        if(reset) begin
            wait_in_start <= 1'b0;
        end else if(instart_reg && ((valve_upflag & UIC_DROC == 1'b1) | (valve_dnflag & UIC_DROC == 1'b0))) begin
            wait_in_start <= 1'b1;
        end else if(~instart_reg) begin
            wait_in_start <= 1'b0;
        end else begin
            wait_in_start <= wait_in_start;    
        end
    end
    
    always @(posedge clk)begin
        if(reset) begin
            wait_out_start <= 1'b0;
        end else if(outstart_reg && ((valve_dnflag & UIC_DROC == 1'b1) | (valve_upflag & UIC_DROC == 1'b0))) begin
            wait_out_start <= 1'b1;
        end else if(~outstart_reg) begin
            wait_out_start <= 1'b0;
        end else begin
            wait_out_start <= wait_out_start;    
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            hcqg_out_up <= 1'b0;
            hcqg_out_down <= 1'b1;
        end else if(((instart_reg | done2_reg) & UIC_DROC == 1'b1) || ((outstart_reg | done_reg) & UIC_DROC == 1'b0))begin
            hcqg_out_up <= 1'b1;
            hcqg_out_down <= 1'b0;
        end else if(((instart_reg | done2_reg) & UIC_DROC == 1'b0) || ((outstart_reg | done_reg) & UIC_DROC == 1'b1))begin
            hcqg_out_up <= 1'b0;
            hcqg_out_down <= 1'b1;
        end else begin
            hcqg_out_up <= hcqg_out_up;
            hcqg_out_down <= hcqg_out_down;    
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            instart_reg <= 1'b0;
        end else if(instart_pose) begin
            instart_reg <= 1'b1;
        end else if(wait_in_start) begin
            instart_reg <= 1'b0;    
        end else begin
            instart_reg <= instart_reg;    
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            outstart_reg <= 1'b0;
        end else if(outstart_pose) begin
            outstart_reg <= 1'b1;
        end else if(wait_out_start) begin
            outstart_reg <= 1'b0;    
        end else begin
            outstart_reg <= outstart_reg;    
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            done_reg <= 1'b0;
        end else if(done_pose) begin
            done_reg <= 1'b1;
        end else if((valve_dnflag & UIC_DROC == 1'b1) || (valve_upflag & UIC_DROC == 1'b0)) begin
            done_reg <= 1'b0;
        end else begin
            done_reg <= done_reg;    
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            done2_reg <= 1'b0;
        end else if(done2_pose) begin
            done2_reg <= 1'b1;
        end else if((valve_upflag & UIC_DROC == 1'b1) || (valve_dnflag & UIC_DROC == 1'b0)) begin
            done2_reg <= 1'b0;
        end else begin
            done2_reg <= done2_reg;    
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