/////////////////////////////////////////////////////////////////
// Company:
// Engineer:      Huaye Zhang
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
`include  "depot_addr_map.vh"
module shou_1
#(
     parameter  RAM_DEPTH   =   32768
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
)
(
     input              clk
    ,input              reset
   
    //receive buffer
    ,input  wire                            accept_buf_rea
    ,input  wire    [RAM_AWIDTH-1:0]        accept_buf_addra
    ,output reg     [RAM_DWIDTH-1:0]        accept_buf_dina
    
    ,input  wire    [RAM_DWIDTH-1:0]        pre_uuid
    ,input  wire    [RAM_DWIDTH*2-1:0]      do_regoin_msg
    ,input  wire    [RAM_DWIDTH*3-1:0]      di_regoin_msg
    ,input  wire    [RAM_DWIDTH*4-1:0]      ai_regoin_msg
    ,input  wire    [RAM_DWIDTH-1:0]        rs232_1st_msg
    ,input  wire    [RAM_DWIDTH-1:0]        rs232_2nd_msg
    ,input  wire    [RAM_DWIDTH-1:0]        rs232_3rd_msg
    ,input  wire    [RAM_DWIDTH-1:0]        rs232_4th_msg
    ,input  wire    [RAM_DWIDTH-1:0]        rs232_5th_msg
    ,input  wire    [RAM_DWIDTH-1:0]        rs232_6th_msg
    ,input  wire    [RAM_DWIDTH-1:0]        rs232_7th_msg
    ,input  wire    [RAM_DWIDTH-1:0]        rs232_8th_msg
    ,input  wire    [RAM_DWIDTH-1:0]        rs485_1st_msg
    ,input  wire    [RAM_DWIDTH-1:0]        pul_motor0_msg
    ,input  wire    [RAM_DWIDTH-1:0]        pul_motor1_msg
    ,input  wire    [RAM_DWIDTH-1:0]        pul_motor2_msg
    ,input  wire    [RAM_DWIDTH-1:0]        pul_motor3_msg
//    ,input  wire    [RAM_DWIDTH-1:0]        reseve_data
);

////accept_buf_dina
    always @(posedge clk)begin
        if(reset)begin
            accept_buf_dina<=32'd0;
        end else if (!accept_buf_rea)begin
            accept_buf_dina <=accept_buf_dina;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_ID) & (accept_buf_addra < `DEPOT_BIAS_DO))begin
            accept_buf_dina<=pre_uuid;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_DO) & (accept_buf_addra < `DEPOT_BIAS_DI))begin
            if(accept_buf_addra==(`DEPOT_BIAS_DO + 0))  begin
                accept_buf_dina<=do_regoin_msg[31:0];
            end if(accept_buf_addra==(`DEPOT_BIAS_DO + 1))  begin 
                accept_buf_dina<=do_regoin_msg[63:32];
            end
        end else if ((accept_buf_addra >= `DEPOT_BIAS_DI) & (accept_buf_addra < `DEPOT_BIAS_AI))begin
            if(accept_buf_addra== (`DEPOT_BIAS_DI + 0))  begin
                accept_buf_dina<=di_regoin_msg[31:0];
            end if(accept_buf_addra==(`DEPOT_BIAS_DI + 1))  begin 
                accept_buf_dina<=di_regoin_msg[63:32];
            end if(accept_buf_addra==(`DEPOT_BIAS_DI + 2))  begin 
                accept_buf_dina<=di_regoin_msg[95:64];
            end
        end else if ((accept_buf_addra >= `DEPOT_BIAS_AI) & (accept_buf_addra < `DEPOT_BIAS_RS232_1ST))begin
            if(accept_buf_addra==(`DEPOT_BIAS_AI + 0))  begin
                accept_buf_dina<=ai_regoin_msg[31:0];
            end if(accept_buf_addra==(`DEPOT_BIAS_AI + 1))  begin 
                accept_buf_dina<=ai_regoin_msg[63:32];
            end if(accept_buf_addra==(`DEPOT_BIAS_AI + 2))  begin 
                accept_buf_dina<=ai_regoin_msg[95:64];
            end if(accept_buf_addra==(`DEPOT_BIAS_AI + 3))  begin 
                accept_buf_dina<=ai_regoin_msg[127:96];
            end
        end else if ((accept_buf_addra >= `DEPOT_BIAS_RS232_1ST) & (accept_buf_addra < `DEPOT_BIAS_RS232_1ST+`DEPOT_SIZE_RS232_1ST))begin
            accept_buf_dina<=rs232_1st_msg;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_RS232_2ND) & (accept_buf_addra < `DEPOT_BIAS_RS232_2ND+`DEPOT_SIZE_RS232_2ND))begin
            accept_buf_dina<=rs232_2nd_msg;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_RS232_3RD) & (accept_buf_addra < `DEPOT_BIAS_RS232_3RD+`DEPOT_SIZE_RS232_3RD))begin
            accept_buf_dina<=rs232_3rd_msg;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_RS232_4TH) & (accept_buf_addra < `DEPOT_BIAS_RS232_4TH+`DEPOT_SIZE_RS232_4TH))begin
            accept_buf_dina<=rs232_4th_msg;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_RS232_5TH) & (accept_buf_addra < `DEPOT_BIAS_RS232_5TH+`DEPOT_SIZE_RS232_5TH))begin
            accept_buf_dina<=rs232_5th_msg;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_RS232_6TH) & (accept_buf_addra < `DEPOT_BIAS_RS232_6TH+`DEPOT_SIZE_RS232_6TH))begin
            accept_buf_dina<=rs232_6th_msg;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_RS232_7TH) & (accept_buf_addra < `DEPOT_BIAS_RS232_7TH+`DEPOT_SIZE_RS232_7TH))begin
            accept_buf_dina<=rs232_7th_msg;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_RS232_8TH) & (accept_buf_addra < `DEPOT_BIAS_RS232_8TH+`DEPOT_SIZE_RS232_8TH))begin
            accept_buf_dina<=rs232_8th_msg;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_RS485_1ST) & (accept_buf_addra < `DEPOT_BIAS_RS485_1ST+`DEPOT_SIZE_RS485_1ST))begin
            accept_buf_dina<=rs485_1st_msg;
        end else if((accept_buf_addra >= `DEPOT_BIAS_PUL_MOTOR0) & (accept_buf_addra < `DEPOT_BIAS_PUL_MOTOR1))begin
            accept_buf_dina<=pul_motor0_msg;    
        end else if((accept_buf_addra >= `DEPOT_BIAS_PUL_MOTOR1) & (accept_buf_addra < `DEPOT_BIAS_PUL_MOTOR2))begin
            accept_buf_dina<=pul_motor1_msg;  
        end else if((accept_buf_addra >= `DEPOT_BIAS_PUL_MOTOR2) & (accept_buf_addra < `DEPOT_BIAS_PUL_MOTOR3))begin
            accept_buf_dina<=pul_motor2_msg;
        end else if((accept_buf_addra >= `DEPOT_BIAS_PUL_MOTOR3) & (accept_buf_addra < (`DEPOT_BIAS_PUL_MOTOR3+`DEPOT_SIZE_PUL_MOTOR3)))begin
            accept_buf_dina<=pul_motor3_msg; 
        end else begin
            accept_buf_dina<=accept_buf_dina;
        end          
    end
    
endmodule