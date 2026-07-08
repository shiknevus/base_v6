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
module rll_online_height_behavior
(
     input wire                        clk
    ,input wire                        reset
    ,input wire                        instart_reg
    
    ,input wire                        mf1
    ,input wire                        mf2
    ,input wire                        mf
    ,input wire [15:0]                 ldl_data
    ,input wire [15:0]                 ldr_data
    ,output reg [31:0]                 AI1_data
    ,output reg [31:0]                 AI2_data
    ,output reg [31:0]                 AI3_data
);
    reg	mf1_r;
    reg mf1_r_r;
    reg mf2_r;
    reg mf2_r_r;
    reg mf_r;
    reg mf_r_r;
    wire mf1_pose;
    wire mf2_pose;
    wire mf_pose;

    assign  mf1_pose = mf1_r & ~mf1_r_r;
    assign  mf2_pose = mf2_r & ~mf2_r_r;
    assign  mf_pose = mf_r & ~mf_r_r;
    
    always @(posedge clk)begin
        if(reset)begin
            AI1_data <= 32'd0;
        end else if(instart_reg & mf1_pose)begin
		    AI1_data <= {ldr_data, ldl_data};
        end else begin
            AI1_data <= AI1_data;		
      	end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            AI2_data <= 32'd0;
        end else if(instart_reg & mf2_pose)begin
		    AI2_data <= {ldr_data, ldl_data};
        end else begin
            AI2_data <= AI2_data;
      	end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            AI3_data <= 32'd0;
        end else if(instart_reg & mf_pose)begin
		    AI3_data <= {ldr_data, ldl_data};
        end else begin
            AI3_data <= AI3_data;
      	end
    end

    always @(posedge clk)begin
        if(reset)begin
            mf1_r <= 1'b0;
            mf1_r_r <= 1'b0;
        end else begin
            mf1_r <= mf1;
            mf1_r_r <= mf1_r;
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            mf2_r <= 1'b0;
            mf2_r_r <= 1'b0;
        end else begin
            mf2_r <= mf2;
            mf2_r_r <= mf2_r;
        end
    end

    always @(posedge clk)begin
        if(reset)begin
            mf_r <= 1'b0;
            mf_r_r <= 1'b0;
        end else begin
            mf_r <= mf;
            mf_r_r <= mf_r;
        end
    end

endmodule