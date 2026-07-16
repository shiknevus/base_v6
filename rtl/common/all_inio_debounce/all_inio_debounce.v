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
//
/////////////////////////////////////////////////////////////////
module all_inio_debounce
#(
     parameter  IO_NUM = 8'd72
)
(
     input wire                        clk		//156M
    ,input wire                        reset
    
    ,input wire [IO_NUM-1:0]           IO_in
    ,output wire [IO_NUM-1:0]          IO_in_handle
);

    localparam WHOLE_VALUE  = 15600/2;		//50us
//    localparam WHOLE_VALUE  = 15600;		//100us*20
    localparam DUTY_VALUE   = WHOLE_VALUE/2;
    localparam TIME_WIDTH   = $clog2(WHOLE_VALUE);
    reg [TIME_WIDTH-1:0] time_cnt;
    reg aclk_r;
    reg aclk_r_r;
    reg aclk_r_r_r;
    wire aclk_pose;
    
    assign aclk_pose = aclk_r_r & (~aclk_r_r_r);
    
    always @(posedge clk)begin
        if(reset)begin
            time_cnt <= 'd0;
        end else begin
            time_cnt <= (time_cnt < WHOLE_VALUE-1) ? (time_cnt + 1'b1) : 'd0;
        end
    end
    
    always @(posedge clk)begin
        if(reset)begin
            aclk_r <= 1'b0;
            aclk_r_r <= 1'b0;
            aclk_r_r_r <= 1'b0;
        end else begin
            aclk_r <= (time_cnt <= DUTY_VALUE-1) ? 1'b1 : 1'b0;
            aclk_r_r <= aclk_r;
            aclk_r_r_r <= aclk_r_r;
        end
    end
    
    //	generate	
	//		genvar i;
	//		for (i=0; i<IO_NUM; i=i+1)begin:
	//		inio_debounce inio_debounce
	//		(
	//			 .clk		   	(clk			)
	//			,.reset		 	(reset			)
	//			,.sample_en     (aclk_pose	    )
	//						
	//			,.i_data	 	(IO_in[i]	    )
	//			,.o_data   		(IO_in_handle[i])
	//		);
	//		end
    //	endgenerate
	
	generate
    genvar i;
    for (i=0; i<IO_NUM; i=i+1) begin : gen_inio_debounce // 补块名
        // 模块名 + 实例名，用i区分每一路
        inio_debounce u_inio_debounce
        (
             .clk		   	(clk			)
            ,.reset		 	(reset			)
            ,.sample_en     (aclk_pose	    )
            ,.i_data	 	(IO_in[i]	    )
            ,.o_data   		(IO_in_handle[i])
        );
    end
endgenerate

endmodule