`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/12 08:36:22
// Design Name: 
// Module Name: CRC16_modbus
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// Width:8
// Poly:0x8005
// Init:0xFFFF;
// Xorout:0x0000;
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module CRC16_modbus#(
     parameter  RAM_DWIDTH  = 32
    ,parameter  xor_a       = 16'd0
) (
    input                              sys_clk,
    input                              rst_n,
    
    input [RAM_DWIDTH*RAM_DWIDTH-1:0]  iv_crc_data,
    input                              i_crc_cal_start,
    input [7:0]                        iv_data_length,
    output reg                         o_crc_cal_done,
    output reg                         o_crc_vld,
    output reg [15:0]                  ov_crc_reg
);
reg        vld;
reg [7:0]  data_l;
reg        crc_vld;
reg [15:0] crc_reg;
reg crc_cal_start_n;
reg [7:0] cal_cnt;
reg [7:0] data_cal_buf[RAM_DWIDTH*4-1:0];
integer for_i;
always @(posedge sys_clk or negedge rst_n) begin
	if(~rst_n) begin
		 cal_cnt  <= 0;
		 crc_cal_start_n  <= 0;
         o_crc_cal_done <= 1'b0;
         vld          <= 1'b0;
         data_l       <= 8'b0;
	end else begin
	     crc_cal_start_n <= i_crc_cal_start;
		 if((crc_cal_start_n!=i_crc_cal_start)&&(crc_cal_start_n==1'b0))begin  // rising edge
		     cal_cnt <= 0;
             o_crc_cal_done <= 1'b0;
             vld          <= 1'b1;
             data_l       <= iv_crc_data[(iv_data_length*8-1) -: 8];
             for(for_i=0;for_i<iv_data_length;for_i=for_i+1)begin
                 data_cal_buf[for_i] <= iv_crc_data[((iv_data_length-for_i)*8-1) -: 8];
             end
		 end else begin
		     if(crc_vld)begin
		         if(cal_cnt == iv_data_length-1)begin
		            cal_cnt <= 0;
		            o_crc_cal_done <= 1'b1;
                    vld          <= 1'b0;
		         end else begin
                    cal_cnt <= cal_cnt + 1;
                    o_crc_cal_done <= 1'b0;
                    vld          <= 1'b1;
                    data_l       <= data_cal_buf[cal_cnt + 1];
                 end
             end else begin
                 cal_cnt <= cal_cnt;
                 o_crc_cal_done <= 1'b0;
                 vld          <= 1'b0;
             end
		 end
	end
end

always @(posedge sys_clk or negedge rst_n) begin
	if(~rst_n) begin
		 o_crc_vld  <= 0;
		 ov_crc_reg <= 0;
	end else begin
		 o_crc_vld  <= crc_vld;
		 ov_crc_reg <= crc_vld ? crc_reg : ov_crc_reg;
	end
end



wire[7:0] data_n;
reg[7:0] d;
always @(posedge sys_clk or negedge rst_n) begin
	if(~rst_n) begin
		 d<= 0;
	end else if(vld) begin
		 d<=data_n ;
	end
end
reg[15:0] crc;
reg[15:0] newcrc;
reg[15:0] nextCRC16_D8;
wire[15:0] c;

reg[7:0] count;
always @(posedge sys_clk or negedge rst_n) begin
	if(~rst_n) begin
		 count<= 0;
	end else if(vld) begin
		 count<=1 ;
    end else if (count==8'd8) begin
    	 count<=0;	 
	end else if (count!==0) begin
		 count<=count+1;
	end
end

assign c=newcrc;
always @(posedge sys_clk or negedge rst_n) begin
	if(~rst_n) begin
		newcrc <= 16'hFFFF;
    end else if((crc_cal_start_n!=i_crc_cal_start)&&(crc_cal_start_n==1'b0)) begin
        newcrc <= 16'hFFFF;
	end else if(count==8'd5) begin
        newcrc[0]    = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[8] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
        newcrc[1]    = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
        newcrc[2]    = d[1] ^ d[0] ^ c[8] ^ c[9];
        newcrc[3]    = d[2] ^ d[1] ^ c[9] ^ c[10];
        newcrc[4]    = d[3] ^ d[2] ^ c[10] ^ c[11];
        newcrc[5]    = d[4] ^ d[3] ^ c[11] ^ c[12];
        newcrc[6]    = d[5] ^ d[4] ^ c[12] ^ c[13];
        newcrc[7]    = d[6] ^ d[5] ^ c[13] ^ c[14];
        newcrc[8]    = d[7] ^ d[6] ^ c[0] ^ c[14] ^ c[15];
        newcrc[9]    = d[7] ^ c[1] ^ c[15];
        newcrc[10]   = c[2];
        newcrc[11]   = c[3];
        newcrc[12]   = c[4];
        newcrc[13]   = c[5];
        newcrc[14]   = c[6];
        newcrc[15]   = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[2] ^ d[1] ^ d[0] ^ c[7] ^ c[8] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15];
        nextCRC16_D8 = newcrc;
	end
end


wire[15:0] crc_n;
always @(posedge sys_clk or negedge rst_n) begin
	if(~rst_n) begin
		 crc_reg <= 0;
		 crc_vld <= 0;
	end else if(count==8'd8) begin
		 crc_reg <=crc_n^xor_a ;
		 crc_vld <=1;
	end else begin 
		 crc_vld <=0;
	end
end


assign data_n[7]=data_l[0];
assign data_n[6]=data_l[1];
assign data_n[5]=data_l[2];
assign data_n[4]=data_l[3];
assign data_n[3]=data_l[4];
assign data_n[2]=data_l[5];
assign data_n[1]=data_l[6];
assign data_n[0]=data_l[7];


assign crc_n[15]=nextCRC16_D8[0];
assign crc_n[14]=nextCRC16_D8[1];
assign crc_n[13]=nextCRC16_D8[2];
assign crc_n[12]=nextCRC16_D8[3];
assign crc_n[11]=nextCRC16_D8[4];
assign crc_n[10]=nextCRC16_D8[5];
assign crc_n[9]=nextCRC16_D8[6];
assign crc_n[8]=nextCRC16_D8[7];
assign crc_n[7]=nextCRC16_D8[8];
assign crc_n[6]=nextCRC16_D8[9];
assign crc_n[5]=nextCRC16_D8[10];
assign crc_n[4]=nextCRC16_D8[11];
assign crc_n[3]=nextCRC16_D8[12];
assign crc_n[2]=nextCRC16_D8[13];
assign crc_n[1]=nextCRC16_D8[14];
assign crc_n[0]=nextCRC16_D8[15];

endmodule


