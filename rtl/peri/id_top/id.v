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
module id(
    input clock,
    input reset,
    input did,
    input id_w_en,
    input id_r_en,
    input [31:0] data,
    input [15:0] addr,
    output reg id_op_f,
    output reg [31:0] id_op_data,
    
    output reg [31:0] id_out_data,
    
    input com_id_f,
    input [31:0] com_id_data,
    output reg  w_en,
    output reg  r_en,
    output reg[15:0] id_com_addr,
    output reg [31:0] id_com_data
    );
    parameter  STM_R            = 'd0;
    parameter  STM_COUNT        = 'd1;    
    parameter  STM_ID           = 'd2;    
    parameter  STM_RD_ID_END       = 'd3;    
    parameter  STM_COM          = 'd4;    
   (* MARK_DEBUG="true" *) reg[5:0]state;
   (* MARK_DEBUG="true" *)reg[15:0]count=0;
//×´Ì¬×ª»»
    always@(posedge clock)begin
        if(!reset)begin
                    state<=STM_R;
        end else begin
            case(state)
                STM_R:begin
                    if(did==1)begin
                        state<=STM_COUNT;
                    end else begin
                        state<=STM_COM;
                    end
                end
                STM_COUNT:begin
                    if(count==100)begin
                        state<=STM_ID;
                    end 
                end
                STM_ID:begin
                    if(com_id_f==1) begin
                        state<=STM_RD_ID_END;
                    end else begin
                        state<=STM_ID;
                    end
                end
                STM_RD_ID_END:begin
                    if(did==1)begin
                        state<=STM_RD_ID_END;
                    end else begin
                        state<=STM_R;
                    end
                end
                STM_COM:begin 
                    if(did==1)begin
                        state<=STM_R;
                    end else begin
                        state<=STM_COM;
                    end
                end
            endcase
        end
    end
 //COUNT  
    always@(posedge clock)begin
        case(state)
            STM_COUNT:begin
                count<=count+1;
            end
            default:begin
                count<=0;
            end
        endcase
    end
//id_op_f
 always@(posedge clock)begin
          case(state)
             STM_ID:begin
                  id_op_f<=0; 
             end
             STM_RD_ID_END:begin 
                  id_op_f<=1;
              end
              STM_COM : begin
                  id_op_f <=com_id_f;
               end
              default : begin
                  id_op_f <=id_op_f;
            end
          endcase
     end       
//id_com_addr
 always@(posedge clock)begin
          case(state)
              STM_ID:begin
                     id_com_addr<=0;
              end
              STM_COM:begin 
                     id_com_addr<=addr;
              end
              default:begin
              id_com_addr<=id_com_addr;
              end
          endcase
     end       
 //id_com_data
  always@(posedge clock)begin
          case(state)
              STM_COM:begin 
                     id_com_data<=data;
              end
              default:begin
                     id_com_data<=id_com_data;
              end
          endcase
     end       
 //w_en
  always@(posedge clock)begin
          case(state)
              STM_ID:begin
                     w_en<=0;
              end
              STM_COM:begin 
                     w_en<=id_w_en;
              end
              default:begin
                     w_en<=w_en;
              end
          endcase
     end       
 //r_en
  always@(posedge clock)begin
          case(state)
              STM_ID:begin
                     r_en<=1;
              end
              STM_COM:begin 
                     r_en<=id_r_en;
              end
              default:begin
                    r_en<=r_en;
              end
          endcase
     end       
 //id_op_data
  always@(posedge clock)begin
          case(state)
              STM_COM:begin 
                     id_op_data<=com_id_data;
              end
              default:begin
                    r_en<=r_en;
              end
          endcase
     end       
//id_out_data
always@(posedge clock)begin
          case(state)
              STM_ID:begin
                      id_out_data<=com_id_data;
              end
              default:begin
                    id_out_data<=id_out_data;
              end
          endcase
        end
endmodule
