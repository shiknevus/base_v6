`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/02 13:13:11
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module combine(
    input clock,
    input reset,
    input c_w_en,
    input c_r_en,
    input [31:0] data,
    input [15:0] addr,
    input iic_rd_end,
    input iic_wd_end,
    input [7:0] iic_com_data,
    
    output reg  w_en,
    output reg  r_en,
    output reg [7:0] addr_u,
    output reg [7:0] addr_l,
    output reg [7:0] com_iic_data,
    output reg [31:0] com_id_data,
    output reg com_id_f
    );
   (* MARK_DEBUG="true" *) reg[5:0]state;
  
    reg iic_rd_end_d1;
    reg iic_wd_end_d1;
   (* MARK_DEBUG="true" *) reg iic_rd_end_r;
   (* MARK_DEBUG="true" *) reg iic_wd_end_r;

   reg[31:0]data_D=0;
   reg[7:0]jishu=0;
   reg[15:0]addr_D=0;
  //(* MARK_DEBUG="true" *)  reg[7:0]iic_com_data_1=0;
  //(* MARK_DEBUG="true" *)  reg[7:0]iic_com_data_2=0;
  //(* MARK_DEBUG="true" *)  reg[7:0]iic_com_data_3=0;
  //(* MARK_DEBUG="true" *)  reg[7:0]iic_com_data_4=0;
   
    //reg[15:0]addr_1=0;
    //reg[15:0]addr_2=0;
    //reg[15:0]addr_3=0;
    //reg[15:0]addr_4=0;
    
    parameter  STM_D_D          = 'd0;    // state_data/addr_distribution
    parameter  STM_D_W_0_7      = 'd1;    //data_w 0_7bit
    parameter  STM_D_W_8_15     = 'd2;    //data_w 8_15bit
    parameter  STM_D_W_16_23    = 'd3;    //data_w 16_23bit
    parameter  STM_D_W_24_31    = 'd4;    //data_w 24_31bit 
    parameter  STM_D_C          = 'd5;    //state_data/connect
    
    parameter  STM_D_R_0_7      = 'd6;    //data_r 0_7bit
    parameter  STM_D_R_8_15     = 'd7;    //data_r 8_15bit
    parameter  STM_D_R_16_23    = 'd8;    //data_r 16_23bit
    parameter  STM_D_R_24_31    = 'd9;    //data_r 24_31bit 
    
//iic_rd_end_r
  always@(posedge clock)begin
        iic_rd_end_d1<=iic_rd_end;
        iic_rd_end_r<=iic_rd_end&(~iic_rd_end_d1);
  end
//iic_wd_end_r
  always@(posedge clock)begin
        iic_wd_end_d1<=iic_wd_end;
        iic_wd_end_r<=iic_wd_end&(~iic_wd_end_d1);
  end
//com_iic_data--iic_com_data--
  always@(posedge clock)begin
          case(state)
            STM_D_D:begin
                data_D[31:0]<=data[31:0];
            end
            STM_D_W_0_7:begin
                if(iic_wd_end_r==0)begin
                    com_iic_data<=data_D[7:0];
                end else begin
                    com_iic_data<=com_iic_data;
                    //iic_com_data_1<=iic_com_data;
                end
            end
            STM_D_W_8_15:begin
                if(iic_wd_end_r==0)begin                    
                    com_iic_data<=data_D[15:8];
                end else begin
                    com_iic_data<=com_iic_data;
                    //iic_com_data_2<=iic_com_data;
                end
            end
            STM_D_W_16_23:begin
                if(iic_wd_end_r==0)begin
                    com_iic_data<=data_D[23:16];
                end else begin
                    com_iic_data<=com_iic_data;
                    //iic_com_data_3<=iic_com_data;
                end
            end
            STM_D_W_24_31:begin
                if(iic_wd_end_r==0)begin
                    com_iic_data<=data_D[31:24];
                end else begin
                    com_iic_data<=com_iic_data;
                    //iic_com_data_4<=iic_com_data;
                end    
            end
            STM_D_C:begin
                    com_id_data<=com_id_data;
            end
            STM_D_R_0_7:begin
                if(iic_rd_end_r==0)begin
                    com_iic_data<=data_D[7:0];
                end else begin
                    com_iic_data<=com_iic_data;
                    com_id_data[7:0]<=iic_com_data;
                end
            end
            STM_D_R_8_15:begin
                if(iic_rd_end_r==0)begin                    
                    com_iic_data<=data_D[15:8];
                end else begin
                    com_iic_data<=com_iic_data;
                    com_id_data[15:8]<=iic_com_data;
                end
            end
            STM_D_R_16_23:begin
                if(iic_rd_end_r==0)begin
                    com_iic_data<=data_D[23:16];
                end else begin
                    com_iic_data<=com_iic_data;
                    com_id_data[23:16]<=iic_com_data;
                end
            end
            STM_D_R_24_31:begin
                if(iic_rd_end_r==0)begin
                    com_iic_data<=data_D[31:24];
                end else begin
                    com_iic_data<=com_iic_data;
                    com_id_data[31:24]<=iic_com_data;
                end    
            end
          endcase
  end
//addr_u--addr_l
  always@(posedge clock)begin
          case(state)
            STM_D_W_0_7,STM_D_W_8_15,STM_D_W_16_23,STM_D_W_24_31:begin
                if(iic_wd_end_r==0)begin
                    addr_u<=addr_D[15:8];
                    addr_l<=addr_D[7:0];
                end else begin
                    addr_u<=addr_u;
                    addr_l<=addr_l;
                end
            end
            STM_D_C:begin
                    addr_u<=addr_u;
                    addr_l<=addr_l;
            end
            STM_D_R_0_7,STM_D_R_8_15,STM_D_R_16_23,STM_D_R_24_31:begin
                if(iic_rd_end_r==0)begin
                    addr_u<=addr_D[15:8];
                    addr_l<=addr_D[7:0];
                end else begin
                    addr_u<=addr_u;
                    addr_l<=addr_l;
                end
            end
          endcase
  end  
//addr_D  
  always@(posedge clock)begin
          case(state)
            STM_D_D:begin
                addr_D<=addr;
            end
            STM_D_W_0_7,STM_D_W_8_15,STM_D_W_16_23,STM_D_W_24_31:begin
                if(iic_wd_end_r==0)begin
                    addr_D<=addr_D;
                end else begin
                    addr_D<=addr_D+1;
                end
            end
            
            STM_D_C:begin
                    addr_D<=addr_D;
            end
            STM_D_R_0_7,STM_D_R_8_15,STM_D_R_16_23,STM_D_R_24_31:begin
                if(iic_rd_end_r==0)begin
                    addr_D<=addr_D;
                end else begin
                    addr_D<=addr_D+1;
                end
            end
          endcase
  end      
//state
  always@(posedge clock)begin
        if(!reset||(c_w_en==0&&c_r_en==0))begin
            state<=STM_D_D;
        end else begin
          case(state) 
              STM_D_D:begin
                   if(c_w_en==1&&c_r_en==0)begin
                      state<=STM_D_W_0_7;
                   end else if(c_w_en==0&&c_r_en==1)begin
                      state<=STM_D_R_0_7;
                   end else begin
                      state<=STM_D_D;
                   end
              end
              STM_D_W_0_7:begin
                    if(iic_wd_end_r==1)begin
                        state<=STM_D_W_8_15;
                    end else begin
                        state<=STM_D_W_0_7;
                    end    
              end
              STM_D_W_8_15:begin
                    if(iic_wd_end_r==1)begin
                        state<=STM_D_W_16_23;
                    end else begin
                        state<=STM_D_W_8_15;
                    end    
              end
              STM_D_W_16_23:begin
                    if(iic_wd_end_r==1)begin
                        state<=STM_D_W_24_31;
                    end else begin
                        state<=STM_D_W_16_23;
                    end    
              end
              STM_D_W_24_31:begin
                    if(iic_wd_end_r==1)begin
                        state<=STM_D_D;
                    end else begin
                        state<=STM_D_W_24_31;
                    end    
              end
              STM_D_C:begin
                        state<=STM_D_D;
              end
              
              STM_D_R_0_7:begin
                    if(iic_rd_end_r==1)begin
                        state<=STM_D_R_8_15;
                    end else begin
                        state<=STM_D_R_0_7;
                    end    
              end
              STM_D_R_8_15:begin
                    if(iic_rd_end_r==1)begin
                        state<=STM_D_R_16_23;
                    end else begin
                        state<=STM_D_R_8_15;
                    end    
              end
              STM_D_R_16_23:begin
                    if(iic_rd_end_r==1)begin
                        state<=STM_D_R_24_31;
                    end else begin
                        state<=STM_D_R_16_23;
                    end    
              end
              STM_D_R_24_31:begin
                    if(iic_rd_end_r==1)begin
                        state<=STM_D_C;
                    end else begin
                        state<=STM_D_R_24_31;
                    end    
              end
          endcase
        end
  end
  //com_id_f
  always@(posedge clock)begin
        if(!reset||(c_w_en==0&&c_r_en==0))begin
            com_id_f<=0;
        end else begin
          case(state) 
              STM_D_D,STM_D_W_0_7,STM_D_W_8_15,STM_D_W_16_23,STM_D_C,
              STM_D_R_0_7,STM_D_R_8_15,STM_D_R_16_23:begin
                      com_id_f<=0;
              end
              STM_D_W_24_31:begin
                    if(iic_wd_end_r==1)begin
                        com_id_f<=1;
                    end else begin
                        com_id_f<=0;
                    end    
              end
              STM_D_R_24_31:begin
                    if(iic_rd_end_r==1)begin
                        com_id_f<=1;
                    end else begin
                        com_id_f<=0;
                    end    
              end
          endcase
        end
  end
  //w_en----r_en
  always@(posedge clock)begin
   if(c_w_en==1&&c_r_en==0)begin  
        if(jishu==0)begin
            w_en<=0;
            r_en<=0;
            jishu<=jishu+1;
        end else if(jishu==1)begin
            w_en<=1;
            r_en<=0;
            jishu<=jishu+1;
        end else if(jishu==2)begin
            w_en<=0;
            r_en<=0;
            jishu<=jishu+1;
        end else if(jishu==3)begin
            w_en<=1;
            r_en<=0;
            jishu<=jishu+1;
        end else if(jishu==4)begin
            w_en<=0;
            r_en<=0;
            jishu<=jishu+1;
        end else if(jishu==5)begin
            w_en<=1;
            r_en<=0;
            jishu<=jishu+1;
        end else if(jishu==6)begin
            w_en<=0;
            r_en<=0;
            jishu<=jishu+1;
        end else if(jishu==7)begin
            w_en<=1;
            r_en<=0;
            jishu<=0;
        end   
   end else if(c_w_en==0&&c_r_en==1)begin  
        if(jishu==0)begin
            w_en<=0;
            r_en<=0;
            jishu<=jishu+1;
        end else if(jishu==1)begin
            w_en<=0;
            r_en<=1;
            jishu<=jishu+1;
        end else if(jishu==2)begin
            w_en<=0;
            r_en<=0;
            jishu<=jishu+1;
        end else if(jishu==3)begin
            w_en<=0;
            r_en<=1;
            jishu<=jishu+1;
        end else if(jishu==4)begin
            w_en<=0;
            r_en<=0;
            jishu<=jishu+1;
        end else if(jishu==5)begin
            w_en<=0;
            r_en<=1;
            jishu<=jishu+1;
        end else if(jishu==6)begin
            w_en<=0;
            r_en<=0;
            jishu<=jishu+1;
        end else if(jishu==7)begin
            w_en<=0;
            r_en<=1;
            jishu<=0;
        end   
   end else begin
            w_en<=0;
            r_en<=0;
            jishu<=0;      
   end
  end

endmodule
