/////////////////////////////////////////////////////////////////
// Company:
// Engineer:      lh
// Creat Date:    
// Design Name:   
// Module Name:   
// Project Name:  
// Target Devices:
// Tool versions:            
// Dependencies:
// Description:
/////////////////////////////////////////////////////////////////
module zz_io_debounce
#(
     parameter  IO_NUM = 8'd32
    ,parameter  SAMPLE_CNT = 12'd1000
)
(
     input wire                     clk		//100M
    ,input wire                     reset
    
    ,input wire [IO_NUM-1:0]        i_signal
    ,output wire [IO_NUM-1:0]       o_signal
    ,output wire [IO_NUM-1:0]       o_posedge
    ,output wire [IO_NUM-1:0]       o_negedge
);

    localparam WHOLE_VALUE  = 5000;		//50us*SAMPLE_CNT
    localparam DUTY_VALUE   = WHOLE_VALUE/2;
    localparam TIME_WIDTH   = $clog2(WHOLE_VALUE);
    wire        aclk_pose;
    reg [2:0]   aclk_r_d;
    reg [TIME_WIDTH-1:0] time_cnt;
    reg [11:0]  sample_cnt[IO_NUM-1:0];
    reg [1:0]   i_signal_d[IO_NUM-1:0];	
	reg         o_signal_buf[IO_NUM-1:0];
	reg [1:0]   i_edge_d[IO_NUM-1:0];
	reg         o_posedge_buf[IO_NUM-1:0];
	reg         o_negedge_buf[IO_NUM-1:0];

    assign aclk_pose = aclk_r_d[1] & (~aclk_r_d[2]);
    
    always @(posedge clk)begin
        if(reset)begin
            time_cnt <= 0;
            aclk_r_d <= 0;
        end else begin
    	    time_cnt <= (time_cnt < WHOLE_VALUE-1) ? (time_cnt + 1'b1) : 0;
	        aclk_r_d[0]   <= (time_cnt <= DUTY_VALUE-1) ? 1'b1 : 1'b0;
	        aclk_r_d[2:1] <= aclk_r_d[1:0];
	    end
    end

  	generate
		genvar i;
		for (i=0; i<IO_NUM; i=i+1)begin:sample_function
		    assign o_signal[i] = o_signal_buf[i];
		    assign o_posedge[i] = o_posedge_buf[i];
		    assign o_negedge[i] = o_negedge_buf[i];
		    
		    always @(posedge clk)begin
                if(reset) begin
                    sample_cnt[i] <= 0;
                end else if(aclk_pose) begin
                    if(sample_cnt[i] >= SAMPLE_CNT) begin
                        sample_cnt[i] <= 0;
                    end else if(i_signal_d[i] == {2{~o_signal_buf[i]}}) begin
                        sample_cnt[i] <= sample_cnt[i] + 1'b1;
                    end else if(i_signal_d[i] == {2{o_signal_buf[i]}}) begin
                        sample_cnt[i] <= 0;
                    end    
                end
            end
            
		    always @(posedge clk)begin
		        if(reset) begin
		            i_signal_d[i] <= 2'b11;
		            o_signal_buf[i] <= 1'b1;
		        end else if(aclk_pose) begin
		            i_signal_d[i] <= {i_signal_d[i][0],i_signal[i]};
		            o_signal_buf[i] <= (sample_cnt[i] == SAMPLE_CNT) ? ~o_signal_buf[i] : o_signal_buf[i];
		        end
		    end

            always @(posedge clk)begin
                if(reset)begin
                    i_edge_d[i] <= 2'b00;
                    o_posedge_buf[i] <= 1'b0;
                    o_negedge_buf[i] <= 1'b0;
                end else begin
                    i_edge_d[i] <= {i_edge_d[i][0],o_signal_buf[i]};
                    o_posedge_buf[i] <= (i_edge_d[i]==2'b01);
                    o_negedge_buf[i] <= (i_edge_d[i]==2'b10);
                end
            end
        end
    endgenerate

endmodule

