module man_handwheel
(
     input                      clk
    ,input                      reset

	,input  wire             	i_pulse_a	//Handwheel input AB phase pulses
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
	
	,output reg [3:0]       	o_axis_number
	,output	reg	[7:0]			o_speed_gear
	,output	reg	[31:0]			or_pulse_cnt
	,output	reg					or_wheel_dir
	,input						sample_vld
);
    localparam WHOLE_VALUE  = 100;       
    localparam TIME_WIDTH   = $clog2(WHOLE_VALUE);
	
    reg [TIME_WIDTH-1:0]    time_cnt;
    reg                     aclk_r;
    reg                     aclk_r_r;
    reg                     aclk_r_r_r;
    wire                    aclk_pose;
    reg  [1:0]              previ;
    reg  [3:0]              axis_number_r;
	
	wire	i_clk = clk;
	wire	i_rst = reset;

	
	//axis check 
	always @(posedge clk)begin 
       case({1'b0,i_axis_7,i_axis_6,i_axis_5,i_axis_4,i_axis_z,i_axis_y,i_axis_x})
           8'b0000_0000: begin
               o_axis_number <= 4'd0;	//off
           end
           8'b0000_0001: begin
               o_axis_number <= 4'd1;
           end
           8'b0000_0010: begin
               o_axis_number <= 4'd2;
           end
           8'b0000_0100: begin
               o_axis_number <= 4'd3;
           end
           8'b0000_1000: begin
               o_axis_number <= 4'd4;
           end
           8'b0001_0000: begin
               o_axis_number <= 4'd5;
           end
           8'b0010_0000: begin
               o_axis_number <= 4'd6;
           end
           8'b0100_0000: begin
               o_axis_number <= 4'd7;
           end
           default: begin
               o_axis_number <= 4'd0;
           end
       endcase 
   end
   
   always@(posedge i_clk)
   begin
	   if(i_rst)
		   axis_number_r <= 4'd0;
	   else
		   axis_number_r <= o_axis_number;
   end
   
   
   //speed_gear check 
   always@(posedge i_clk)
   begin
		case({i_stp_x100,i_stp_x10,i_stp_x1})
			3'b001:o_speed_gear <= 8'd1;
			3'b010:o_speed_gear <= 8'd10;	
			3'b100:o_speed_gear <= 8'd100;
			default:o_speed_gear <= 8'd1;
		endcase
   end
   
   
   //------------- 产生检测AB相的pulse ----------
   always@(posedge clk)
	begin
		if(reset)
			time_cnt <= 0;
		else if(time_cnt < WHOLE_VALUE-1)
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
    end

    assign aclk_pose = aclk_r_r & (~aclk_r_r_r);

	//----------------------------------------


    always @(posedge clk)begin
	    if(reset | (o_axis_number != axis_number_r))begin
	        previ <= {i_pulse_a,i_pulse_b};
            o_pulse_cnt <= 0;
			o_wheel_dir <= 1'b0;
		end else if(sample_vld)begin
			previ <= {i_pulse_a,i_pulse_b};
            or_pulse_cnt <= o_pulse_cnt;
			or_wheel_dir <= o_wheel_dir;
		end else if(aclk_pose)begin
		    if({i_pulse_a,i_pulse_b} != previ)begin
		        previ <= {i_pulse_a,i_pulse_b};
		        case(previ)
                    2'b00: begin
                        if({i_pulse_a,i_pulse_b} == 2'b01)begin
                            o_pulse_cnt <= o_pulse_cnt - 1;
							o_wheel_dir <= 1'b1;
                        end else if({i_pulse_a,i_pulse_b} == 2'b10)begin
                            o_pulse_cnt <= o_pulse_cnt + 1;
							o_wheel_dir <= 1'b0;
                        end
                    end
                    2'b01: begin
                        if({i_pulse_a,i_pulse_b} == 2'b00)begin
                            o_pulse_cnt <= o_pulse_cnt + 1;
							o_wheel_dir <= 1'b0;
                        end else if({i_pulse_a,i_pulse_b} == 2'b11)begin
                            o_pulse_cnt <= o_pulse_cnt - 1;
							o_wheel_dir <= 1'b1;
                        end
                    end
                    2'b10: begin
                        if({i_pulse_a,i_pulse_b} == 2'b00)begin
                            o_pulse_cnt <= o_pulse_cnt - 1;
							o_wheel_dir <= 1'b1;
                        end else if({i_pulse_a,i_pulse_b} == 2'b11)begin
                            o_pulse_cnt <= o_pulse_cnt + 1;
							o_wheel_dir <= 1'b0;
                        end
                    end
                    2'b11: begin
                        if({i_pulse_a,i_pulse_b} == 2'b01)begin
                            o_pulse_cnt <= o_pulse_cnt + 1;
							o_wheel_dir <= 1'b0;
                        end else if({i_pulse_a,i_pulse_b} == 2'b10)begin
                            o_pulse_cnt <= o_pulse_cnt - 1;
							o_wheel_dir <= 1'b1;
                        end
                    end
                    default: begin
                        o_pulse_cnt <= o_pulse_cnt;
						o_wheel_dir <= o_wheel_dir;
                    end
                endcase
		    end
        end
    end
       
endmodule