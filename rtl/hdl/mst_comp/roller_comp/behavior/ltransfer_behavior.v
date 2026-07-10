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
module ltransfer_behavior
#(
      parameter   WORK_IN_PATH = 3'd7
     ,parameter   WORK_OUT_PATH = 14'd7
)
(
     input wire                        clk
    ,input wire                        reset
    ,input wire [15:0]                 time_delay
    ,output reg 					   optstart_reg

    ,input wire                        extra_opt_start
    ,output reg                        extra_opt_done
    ,input wire [2:0]                  cur_in_path
    ,input wire [13:0]                 cur_out_path
    ,input wire                        yzqg_up
    ,input wire                        yzqg_down
    ,output wire                       yzqg_out
    ,output reg                        yzdj_start_z
);
    localparam  Init_time_1ms   =   18'd108297;
    reg optstart_r;
    reg optstart_r_r;
    reg [31:0] wk_cnt;
    wire wk_cnt_done;
    wire optstart_pose;
    wire valve_upflag;
    wire valve_dnflag;

    assign  yzqg_out = 1'b0;
    assign  valve_upflag = yzqg_down & ~yzqg_up;
    assign  valve_dnflag = ~yzqg_down & yzqg_up;
    assign  optstart_pose = optstart_r & ~optstart_r_r;
    assign  wk_cnt_done =  (wk_cnt > {time_delay[13:0], 18'd0}) ? 1'b1 : 1'b0;
    
    always @(posedge clk)begin
        if(optstart_reg)begin
            if(wk_cnt[17:0] == 'd0)begin
                wk_cnt[17:0]  <=  Init_time_1ms;
            end else begin
                wk_cnt  <=  wk_cnt + 'd1;
            end
        end else begin
            wk_cnt  <=  Init_time_1ms;
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            optstart_r <= 1'b0;
            optstart_r_r <= 1'b0;
        end else begin
            optstart_r <= extra_opt_start;
            optstart_r_r <= optstart_r;
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            optstart_reg <= 1'b0;
        end else if(optstart_pose && cur_in_path != WORK_IN_PATH && cur_out_path == WORK_OUT_PATH) begin
        	optstart_reg <= 1'b1;
        end else if(wk_cnt_done) begin
        	optstart_reg <= 1'b0;
        end else begin
        	optstart_reg <= optstart_reg;
        end
    end
    
		always @(posedge clk)begin
        if(reset)begin
            yzdj_start_z <= 1'b1;
        end else if(optstart_reg & valve_upflag) begin
        	yzdj_start_z <= 1'b0;
        end else if(wk_cnt_done) begin
        	yzdj_start_z <= 1'b1;
        end else begin
        	yzdj_start_z <= yzdj_start_z;		
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            extra_opt_done <= 1'b0;
        end else if(wk_cnt_done) begin
        	extra_opt_done <= 1'b1;	
        end else if(optstart_pose) begin
            if(cur_in_path != WORK_IN_PATH && cur_out_path == WORK_OUT_PATH) begin
        	   extra_opt_done <= 1'b0;
        	end else begin
        	   extra_opt_done <= 1'b1;
        	end
        end else begin
        	extra_opt_done <= extra_opt_done;
        end
    end
 
endmodule