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
    input               ll_clk,
    input               clock,
    input               reset,
    
    input               did,
    input               id_w_en,
    input               id_r_en,
    input [31:0]        data,
    input [15:0]        addr,
    output reg          id_op_f,
    output reg [31:0]   id_out_data,
    output reg          rest_read_finish,
    input wire          read_uuid_key,
    input wire          cfg_sta_addr_vld,
    input wire [7:0]    cfg_sta_addr,
    output wire         read_sta_addr_vld,
    output reg [7:0]    read_sta_addr,

    input               com_id_f,
    output reg          w_en,
    output reg          r_en,
    output reg [15:0]   id_com_addr,
    output wire[31:0]   id_com_data,
    input  wire[31:0]   com_id_data
    );
    
    parameter  STM_RESET            = 'd0;
    parameter  STM_RESET_WAIT       = 'd1;
    parameter  STM_READ_ADDR0       = 'd2;
    parameter  STM_ADDR0_WAIT       = 'd3;
    parameter  STM_RESET_END        = 'd4;
    parameter  STM_IDLE             = 'd5;
    parameter  STM_WRITE            = 'd6;
    parameter  STM_READ             = 'd7;
    parameter  STM_WAIT             = 'd8;
    parameter  STM_DATA             = 'd9;
    parameter  STM_END              = 'd10; 
    
    reg[5:0]    state;
    reg[15:0]   count;
    reg         count_done;
    reg         did_prv;
    wire        did_pose;
    reg[31:0]   cnt_time;
    reg         timeout_done;
    reg[3:0]    eeprom_work;    //1:uuid_write; 2:uuid_read; 3:id_write; 4:id_read
    reg[7:0]    uuid_key_buf = 8'hff;
    wire        uuid_key_en;
    reg         lock_cfg_sta_addr_vld;
    reg         lock_cfg_sta_addr_vld_d1;
    reg         latch_cfg_sta_addr_vld;

    assign  did_pose = ~did & did_prv;
    assign  id_com_data = (state==STM_DATA && eeprom_work==1) ? (cfg_sta_addr + 1) : data;
    assign  read_sta_addr_vld = ((state == STM_END) & (eeprom_work == 2)) ? 1'b1 : 1'b0;
    assign  uuid_key_en = (uuid_key_buf == 8'h0f) ? 1'b1 : 1'b0;
    
    always@(posedge ll_clk)begin
        if(state == STM_IDLE) begin
            if(cfg_sta_addr_vld) begin
                lock_cfg_sta_addr_vld <= 1'b1;
            end else begin
                lock_cfg_sta_addr_vld <= lock_cfg_sta_addr_vld;    
            end
        end else begin
            lock_cfg_sta_addr_vld <= 1'b0;
        end
    end
    
    always@(posedge clock)begin
        lock_cfg_sta_addr_vld_d1 <= lock_cfg_sta_addr_vld;
        latch_cfg_sta_addr_vld <= lock_cfg_sta_addr_vld_d1;
    end

    always@(posedge clock)begin
        uuid_key_buf <= {uuid_key_buf[6:0],read_uuid_key};
        if(state == STM_IDLE)begin
            if(latch_cfg_sta_addr_vld)begin
                eeprom_work <= 1;
            end else if(uuid_key_en)begin
                eeprom_work <= 2;
            end else if(id_w_en & ~id_r_en)begin
                eeprom_work <= 3;
            end else if(~id_w_en & id_r_en)begin
                eeprom_work <= 4;
            end
        end
    end

    always@(posedge clock)begin
        if(state == STM_READ_ADDR0)begin
            cnt_time <= cnt_time + 1'b1;
            if(cnt_time >= 'd100000000)begin
                timeout_done <= 1'b1;
            end
        end else begin
            cnt_time <= 'd0;
            timeout_done <= 1'b0;
        end
    end
    
    always@(posedge clock)begin
        did_prv <= did;
        if(reset)begin
            rest_read_finish <= 1'b0;
        end else if((state == STM_IDLE) | timeout_done) begin
            rest_read_finish <= 1'b1;
        end else begin
            rest_read_finish <= rest_read_finish;    
        end
        if(com_id_f & (state == STM_DATA))begin
            id_op_f <= 1'b1;
        end else if(!did) begin
            id_op_f <= 1'b0;
        end else begin
            id_op_f <= id_op_f;
        end
    end

    always@(posedge clock)begin
        if((state==STM_RESET_WAIT) | (state==STM_ADDR0_WAIT) | (state==STM_WAIT))begin
            count <= count + 1'b1;
            if(count >= 100)begin
                count_done <= 1'b1;
            end else begin
                count_done <= count_done;
            end    
        end else begin
            count <= 0;
            count_done <= 1'b0;
        end
    end

    always@(posedge clock)begin
        case(state)
            STM_READ_ADDR0:begin
                w_en <= 1'b0;
                r_en <= 1'b1;
                id_com_addr <= 16'h0;
                if(com_id_f)begin
                    id_out_data <= com_id_data;
                end
            end
            STM_DATA:begin
                if((eeprom_work==1) | (eeprom_work==3)) begin
                    w_en <= 1'b1;
                    r_en <= 1'b0;
                    if(eeprom_work == 1) begin
                        id_com_addr <= 16'h10;
                    end else begin
                        id_com_addr <= addr;
                    end
                    if(com_id_f)begin
                        id_out_data <= id_com_data;
                    end
                end else if((eeprom_work==2) | (eeprom_work==4)) begin
                    w_en <= 1'b0;
                    r_en <= 1'b1;
                    if(eeprom_work == 2) begin
                        id_com_addr <= 16'h10;
                    end else begin
                        id_com_addr <= addr;
                    end
                    if(com_id_f)begin
                        id_out_data <= com_id_data;
                    end
                end
            end
            default: begin
                w_en <= 1'b0;
                r_en <= 1'b0;
            end
        endcase        
    end
    
    always@(posedge clock)begin
        if((state == STM_DATA) & (eeprom_work == 2) & com_id_f)begin
            if(com_id_data == 0)begin
                read_sta_addr <= 8'hff;
            end else begin
                read_sta_addr <= (com_id_data - 1);
            end
        end
    end

    //×´Ì¬×ª»»
    always@(posedge clock)begin
        if(reset)begin
            state <= STM_RESET;
        end else if(did_pose)begin
            state <= STM_IDLE;
        end else begin
            case(state)
                STM_RESET:begin
                    state <= STM_RESET_WAIT;
                end
                STM_RESET_WAIT:begin
                    if(count_done)begin
                        state <= STM_READ_ADDR0;
                    end
                end
                STM_READ_ADDR0:begin
                    if(com_id_f)begin
                        state <= STM_ADDR0_WAIT;
                    end
                end
                STM_ADDR0_WAIT:begin
                    if(count_done)begin
                        state <= STM_RESET_END;
                    end
                end
                STM_RESET_END:begin
                    state <= STM_IDLE;
                end
                STM_IDLE:begin
                    if(latch_cfg_sta_addr_vld | uuid_key_en)begin
                        state <= STM_WAIT;
                    end else if(did & ((id_w_en & ~id_r_en) | (~id_w_en & id_r_en)))begin
                        state <= STM_WAIT;    
                    end else begin
                        state <= state;
                    end
                end
                STM_WAIT:begin
                    if(count_done)begin
                        state <= STM_DATA;
                    end
                end
                STM_DATA:begin
                    if(com_id_f)begin
                        state <= STM_END;
                    end else begin
                        state <= state;
                    end
                end
                STM_END:begin
                    state<=STM_IDLE;
                end
            endcase
        end
    end

endmodule
