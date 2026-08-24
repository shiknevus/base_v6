module man_handwheel
(
     input                      clk
    ,input                      reset
	
	//,input  wire             	i_estop
	,input  wire             	i_pulse_a
	,input  wire             	i_pulse_b
	
	,input  wire             	i_stp_x1
	,input  wire             	i_stp_x10
	,input  wire             	i_stp_x100
	
	,input  wire             	i_axis_x
	,input  wire             	i_axis_y
	,input  wire             	i_axis_z
	,input  wire             	i_axis_4
	,input  wire             	i_axis_5
	,input  wire             	i_axis_6
	,input  wire             	i_axis_7
	
	,output reg [3:0]       	o_wheel_prog
	,output	reg	[31:0]			o_pulse_cnt
	//,output	reg					o_wheel_run
	,output	reg					o_wheel_dir
	,input						sample_vld
);
    localparam WHOLE_VALUE  = 10000;        //100us
    localparam TIME_WIDTH   = $clog2(WHOLE_VALUE);
	
    reg [TIME_WIDTH-1:0]    time_cnt;
    reg                     aclk_r;
    reg                     aclk_r_r;
    reg                     aclk_r_r_r;
    wire                    aclk_pose;
    wire [1:0]              sigport;
    wire [15:0]             step_value;
    reg  [1:0]              previ;
    reg  [3:0]              wheel_prog_d1;
    reg	 [31:0]       		pulse_cnt_d1;
    reg	 [31:0]       		pulse_cnt_d2;

	
	//Gear check 
	always @(posedge clk)begin 
       case({1'b0,i_axis_7,i_axis_6,i_axis_5,i_axis_4,i_axis_z,i_axis_y,i_axis_x})
           8'b0000_0000: begin
               o_wheel_prog <= 4'd0;	//off
           end
           8'b0000_0001: begin
               o_wheel_prog <= 4'd1;
           end
           8'b0000_0010: begin
               o_wheel_prog <= 4'd2;
           end
           8'b0000_0100: begin
               o_wheel_prog <= 4'd3;
           end
           8'b0000_1000: begin
               o_wheel_prog <= 4'd4;
           end
           8'b0001_0000: begin
               o_wheel_prog <= 4'd5;
           end
           8'b0010_0000: begin
               o_wheel_prog <= 4'd6;
           end
           8'b0100_0000: begin
               o_wheel_prog <= 4'd7;
           end
           default: begin
               o_wheel_prog <= 4'd0;
           end
       endcase 
   end
   
   always@(posedge clk)
	begin
		if(reset)
			time_cnt <= 0;
		else if(time_cnt < WHOLE_VALUE-1)//100us
			time_cnt <= time_cnt + 1'b1;
		else
			time_cnt <= 0;
	end
   
   always@(posedge clk)
	begin
		if(reset)
			aclk_r <= 0;
		else if(time_cnt <= WHOLE_VALUE/2-1) //100us
			aclk_r <= 1;
		else
			aclk_r <= 0;
	end
   
    always @(posedge clk)begin
        aclk_r_r <= aclk_r;
        aclk_r_r_r <= aclk_r_r;
        wheel_prog_d1 <= o_wheel_prog;	//gear change
    end

    assign aclk_pose = aclk_r_r & (~aclk_r_r_r);
    assign sigport = {i_pulse_a,i_pulse_b};
    assign step_value = 16'd1;
	
    always @(posedge clk)begin
        if(i_estop | (o_wheel_prog != wheel_prog_d1))begin
            pulse_cnt_d1 <= 0;
            pulse_cnt_d2 <= 0;
            //o_wheel_run <= 1'b0;
            o_wheel_dir <= o_wheel_dir;
        end else if(sample_vld)begin
            pulse_cnt_d1 <= o_pulse_cnt;
            pulse_cnt_d2 <= pulse_cnt_d1;
            if((o_pulse_cnt == pulse_cnt_d1) & (o_pulse_cnt == pulse_cnt_d2))begin
                //o_wheel_run <= 1'b0;
                o_wheel_dir <= o_wheel_dir;
            end else if((o_pulse_cnt > pulse_cnt_d1) & (o_pulse_cnt > pulse_cnt_d2)) begin
                //o_wheel_run <= 1'b1;
                o_wheel_dir <= 1'b1;     
            end else if((o_pulse_cnt < pulse_cnt_d1) & (o_pulse_cnt < pulse_cnt_d2)) begin
                //o_wheel_run <= 1'b1;
                o_wheel_dir <= 1'b0;
            end
        end
    end

    always @(posedge clk)begin
	    if(reset | i_estop | (o_wheel_prog != wheel_prog_d1))begin
	        previ <= sigport;
            o_pulse_cnt <= 0;
		end else if(aclk_pose)begin
		    if(sigport != previ)begin
		        previ <= sigport;
		        case(previ)
                    2'b00: begin
                        if(sigport == 2'b01)begin
                            o_pulse_cnt <= o_pulse_cnt - step_value;
                        end else if(sigport == 2'b10)begin
                            o_pulse_cnt <= o_pulse_cnt + step_value;
                        end
                    end
                    2'b01: begin
                        if(sigport == 2'b00)begin
                            o_pulse_cnt <= o_pulse_cnt + step_value;
                        end else if(sigport == 2'b11)begin
                            o_pulse_cnt <= o_pulse_cnt - step_value;
                        end
                    end
                    2'b10: begin
                        if(sigport == 2'b00)begin
                            o_pulse_cnt <= o_pulse_cnt - step_value;
                        end else if(sigport == 2'b11)begin
                            o_pulse_cnt <= o_pulse_cnt + step_value;
                        end
                    end
                    2'b11: begin
                        if(sigport == 2'b01)begin
                            o_pulse_cnt <= o_pulse_cnt + step_value;
                        end else if(sigport == 2'b10)begin
                            o_pulse_cnt <= o_pulse_cnt - step_value;
                        end
                    end
                    default: begin
                        o_pulse_cnt <= o_pulse_cnt;
                    end
                endcase
		    end
        end
    end
       
endmodule