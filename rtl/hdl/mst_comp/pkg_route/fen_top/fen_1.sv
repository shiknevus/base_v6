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
`include  "./../../../include_files/depot_addr_map.vh"
module fen_1
#(
     parameter  RAM_DEPTH   =   4096
    ,parameter  RAM_DWIDTH  =   32
    ,parameter  RAM_AWIDTH  =   $clog2(RAM_DEPTH)
)
(
     input              clk
    ,input              reset
   
    //receive buffer
    ,input wire     [3:0]               accept_buf_wea//1
    ,input wire     [RAM_AWIDTH-1:0]    accept_buf_addra//1
    ,input wire     [RAM_DWIDTH-1:0]    accept_buf_dina//1
    
    ,output  reg     [RAM_AWIDTH-1:0]             sys_addra//1
    ,output  reg     [3:0]                        sys_wea//1
    
    ,output  reg     [RAM_DWIDTH-1:0]             pre_uuid
   
    ,output  reg     [RAM_DWIDTH*2-1:0]             do_regoin_msg    //1
 
    
    ,output  reg    [RAM_DWIDTH*3-1:0]             di_regoin_msg    //1

  //  ,output  reg    [RAM_DWIDTH*4-1:0]             ao_regoin_msg     //
    
    ,output  reg    [RAM_DWIDTH*4-1:0]             ai_regoin_msg     //1

//    ,output  reg    [RAM_DWIDTH*8-1:0]             axis_1st_msg//1
//    ,output  reg    [RAM_DWIDTH*8-1:0]             axis_2nd_msg//1
//    ,output  reg    [RAM_DWIDTH*8-1:0]             axis_3rd_msg//1
//    ,output  reg    [RAM_DWIDTH*8-1:0]             axis_4th_msg//1
    
    ,output  reg    [RAM_DWIDTH-1:0]             rs232_1st_msg//1
    ,output  reg    [RAM_DWIDTH-1:0]             rs232_2nd_msg//1
//    ,output  reg    [RAM_DWIDTH-1:0]             rs232_3rd_msg//1
//    ,output  reg    [RAM_DWIDTH-1:0]             rs232_4th_msg//1
//    ,output  reg    [RAM_DWIDTH-1:0]             rs232_5th_msg//1
//    ,output  reg    [RAM_DWIDTH-1:0]             rs232_6th_msg//1
//    ,output  reg    [RAM_DWIDTH-1:0]             rs232_7th_msg//1
//    ,output  reg    [RAM_DWIDTH-1:0]             rs232_8th_msg//1

//    ,output  reg    [RAM_DWIDTH-1:0]             rs485_1st_msg//1
    
    ,output  reg    [RAM_DWIDTH-1:0]             reseve_data//1

);

////pre_uuid
    always @(posedge clk)begin
        if(reset)begin
             pre_uuid<=0;
        end else if (!accept_buf_wea)begin
                pre_uuid <=pre_uuid;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_ID) & (accept_buf_addra < `DEPOT_BIAS_DO))begin
                pre_uuid<=accept_buf_dina;
        end else begin
                pre_uuid<=pre_uuid;
        end          
    end
 ////do_regoin_msg    
    always @(posedge clk)begin
        if(reset)begin
           do_regoin_msg<=0;
        end else if (!accept_buf_wea)begin
           do_regoin_msg <=do_regoin_msg;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_DO) & (accept_buf_addra < `DEPOT_BIAS_DI))begin
                        if(accept_buf_addra== (`DEPOT_BIAS_DO + 0))  begin
                               do_regoin_msg[31:0]<=accept_buf_dina;
                        end if(accept_buf_addra==(`DEPOT_BIAS_DO + 1))  begin 
                               do_regoin_msg[63:32]<=accept_buf_dina;
                        end
        end 
                   
    end
  ////di_regoin_msg       
     always @(posedge clk)begin
        if(reset)begin
           di_regoin_msg<=0;
        end else if (!accept_buf_wea)begin
           di_regoin_msg <=di_regoin_msg;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_DI) & (accept_buf_addra < `DEPOT_BIAS_AI))begin
                        if(accept_buf_addra== (`DEPOT_BIAS_DI + 0))  begin
                               di_regoin_msg[31:0]<=accept_buf_dina;
                        end if(accept_buf_addra==(`DEPOT_BIAS_DI + 1))  begin 
                               di_regoin_msg[63:32]<=accept_buf_dina;
                        end if(accept_buf_addra==(`DEPOT_BIAS_DI + 2))  begin 
                               di_regoin_msg[95:64]<=accept_buf_dina;
                        end
        end        
      end
   ////ai_regoin_msg    
    always @(posedge clk)begin
        if(reset)begin
           ai_regoin_msg<=0;
        end else if (!accept_buf_wea)begin
           ai_regoin_msg <=ai_regoin_msg;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_AI) & (accept_buf_addra < `DEPOT_BIAS_RS232_1ST))begin
                        if(accept_buf_addra==(`DEPOT_BIAS_AI + 0))  begin
                               ai_regoin_msg[31:0]<=accept_buf_dina;
                        end if(accept_buf_addra==(`DEPOT_BIAS_AI + 1))  begin 
                               ai_regoin_msg[63:32]<=accept_buf_dina;
                        end if(accept_buf_addra==(`DEPOT_BIAS_AI + 2))  begin 
                               ai_regoin_msg[95:64]<=accept_buf_dina;
                        end if(accept_buf_addra==(`DEPOT_BIAS_AI + 3))  begin 
                               ai_regoin_msg[127:96]<=accept_buf_dina;
                        end
        end 
                   
      end 
  ////rs232_1st_msg
    always @(posedge clk)begin
        if(reset)begin
             rs232_1st_msg<=0;
        end else if (!accept_buf_wea)begin
                rs232_1st_msg <=rs232_1st_msg;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_RS232_1ST) & (accept_buf_addra < `DEPOT_BIAS_RS232_2ND))begin
                rs232_1st_msg<=accept_buf_dina;
        end else begin
                rs232_1st_msg<=rs232_1st_msg;
        end          
    end
 ////rs232_2nd_msg
    always @(posedge clk)begin
        if(reset)begin
             rs232_2nd_msg<=0;
        end else if (!accept_buf_wea)begin
                rs232_2nd_msg <=rs232_2nd_msg;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_RS232_2ND) & (accept_buf_addra < `DEPOT_BIAS_RESEVE_DATA_1ST))begin
                rs232_2nd_msg<=accept_buf_dina;
        end else begin
                rs232_2nd_msg<=rs232_2nd_msg;
        end          
    end
    ////reseve_data
    always @(posedge clk)begin
        if(reset)begin
             reseve_data<=0;
        end else if (!accept_buf_wea)begin
                reseve_data <=reseve_data;
        end else if ((accept_buf_addra >= `DEPOT_BIAS_RESEVE_DATA_1ST) & (accept_buf_addra < (`DEPOT_BIAS_RESEVE_DATA_1ST + `DEPOT_SIZE_RESEVE_DATA_1ST)))begin
                reseve_data<=accept_buf_dina;
        end else begin
                reseve_data<=reseve_data;
        end          
    end
    ////sys_addra
    always @(posedge clk)begin
        if(reset)begin
            sys_addra <=0;
        end else if (!accept_buf_wea)begin
            sys_addra <=0;
        end else begin
            sys_addra=accept_buf_addra;
        end               
    end
     ////sys_wea
     always @(posedge clk)begin
        if(reset)begin
            sys_wea <=0;
        end else begin
            sys_wea <=accept_buf_wea;
        end               
    end
endmodule