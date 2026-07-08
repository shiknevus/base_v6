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
module weight_comp_driver
#(
    parameter   LOCK_WEIGHT_ADDR = 32'd0
)
(
     input wire                        clk
    ,input wire                        reset
    
    ,input wire                        rs232_1st_vld
    ,input wire [31:0]                 rs232_1st_addr
    ,input wire [31:0]                 rs232_1st_msg
    ,output reg                        scan_token_vld
);
    reg [31:0] rs232_data_buf;

    always @(posedge clk)begin
        if(rs232_1st_vld && rs232_1st_addr == LOCK_WEIGHT_ADDR && rs232_data_buf != rs232_1st_msg)begin
            scan_token_vld <= 1'b1;
        end else begin
            scan_token_vld <= 1'b0;
        end
    end
    
     always @(posedge clk)begin
        if(reset)begin
            rs232_data_buf <= 32'd0;
        end else if(rs232_1st_vld && rs232_1st_addr == LOCK_SCAN_ADDR) begin
            rs232_data_buf <= rs232_1st_msg;
        end else begin
            rs232_data_buf <= rs232_data_buf;
        end
    end

endmodule