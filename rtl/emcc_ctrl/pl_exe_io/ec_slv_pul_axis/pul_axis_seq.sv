`timescale 1ns / 1ps
// Pulse-axis behaviors as ABI v2 segment sequences (doc/pul_axis_seg_abi_v2.md §7)
module pul_axis_seq (
    input             clk_i,
    input             rst_i,
    input             i_start,          // pulse
    input             i_abort,          // level: stop/estop/alert
    input             i_cancel,         // behavior FSM finished: drop any wait
    input      [7:0]  i_bhv,            // 1 home, 2/20 jog, 3/21 move
    input             i_dir,            // jog dir, 1 = positive
    input      [31:0] i_step,
    input      [31:0] i_target,
    input      [31:0] i_spd,
    input      [31:0] i_acc,
    input      [31:0] i_dec,
    input      [31:0] i_touch_spd,
    input      [31:0] i_touch_dec,
    input      [31:0] i_dec_max,

    output reg        cmd_req,
    output reg [3:0]  cmd_op,
    output reg [31:0] cmd_arg,
    output reg [31:0] cmd_spd,
    output reg [31:0] cmd_acc,
    output reg [31:0] cmd_dec,
    output reg [31:0] cmd_evt,
    output reg [31:0] cmd_evt_dec,
    output reg [31:0] cmd_lim_dec,
    input             cmd_rdy,
    input             cmd_ack,
    input      [3:0]  cmd_result,
    input             cmd_timeout,
    input             rx_commit,
    input      [31:0] st_s1,
    input      [31:0] st_fault,
    input      [31:0] st_io,

    output            o_busy,
    output reg        o_done,           // latched until next start
    output reg        o_error,
    output reg        o_accepted,       // first segment acked OK
    output reg [7:0]  o_alm
);
    localparam [3:0] OP_REL = 4'd1, OP_ABS = 4'd2, OP_SETPOS = 4'd5;
    localparam [3:0] RS_OK = 4'd0, RS_BLOCK = 4'd1, RS_FAULT = 4'd2, RS_SOFT = 4'd5,
                     RS_BUSY = 4'd6, RS_NOPOS = 4'd7;
    localparam [31:0] CONT_P = 32'h7FFF_FFFF;
    localparam [31:0] CONT_N = 32'h8000_0001;
    localparam [31:0] EVT_H1 = 32'h49;  // org_on(EVT_DEC) | lim_evt_b | cap
    localparam [31:0] EVT_H2 = 32'h41;  // org_on(EVT_DEC) | cap; limf here = hard abort (as v1)
    localparam [31:0] EVT_H4 = 32'h52;  // org_off(DEC) | cap

    localparam [2:0] S_IDLE = 3'd0, S_ISSUE = 3'd1, S_ACK = 3'd2, S_RUN = 3'd3, S_NEXT = 3'd4;
    localparam [2:0] H_SEG = 3'd0, H1 = 3'd1, H2 = 3'd2, H4 = 3'd4, H5 = 3'd5;

    reg [2:0] st;
    reg [2:0] step;       // H_SEG for jog/move
    reg       is_home;
    reg [7:0] fail_alm;
    reg [3:0] last_cause;
    reg       last_org;

    assign o_busy = (st != S_IDLE);

    function [7:0] fault_alm(input [31:0] f);
        fault_alm = f[0]  ? 8'd108 :
                    f[3]  ? 8'd109 :
                    f[1]  ? 8'd109 :
                    f[2]  ? 8'd110 :
                    f[8]  ? 8'd113 :
                    f[6]  ? 8'd111 :
                    f[7]  ? 8'd112 :
                    f[4]  ? 8'd117 :
                    f[10] ? 8'd123 :
                    f[5]  ? 8'd119 : 8'd0;
    endfunction

    function [7:0] reject_alm(input [3:0] rs, input [31:0] f);
        case (rs)
            RS_BLOCK: reject_alm = 8'd106;
            RS_FAULT: reject_alm = (fault_alm(f) != 0) ? fault_alm(f) : 8'd115;
            RS_SOFT:  reject_alm = (fault_alm(f) != 0) ? fault_alm(f) : 8'd111;
            RS_BUSY:  reject_alm = 8'd118;
            RS_NOPOS: reject_alm = 8'd114;
            default:  reject_alm = 8'd105;
        endcase
    endfunction

    task load_seg(input [2:0] s);
        begin
            cmd_spd     <= i_spd;
            cmd_acc     <= i_acc;
            cmd_dec     <= i_dec;
            cmd_evt_dec <= i_touch_dec;
            cmd_lim_dec <= i_dec_max;
            case (s)
                H1:      begin cmd_op <= OP_REL; cmd_arg <= CONT_N; cmd_evt <= EVT_H1; end
                H2:      begin cmd_op <= OP_REL; cmd_arg <= CONT_P; cmd_evt <= EVT_H2; end
                H4:      begin cmd_op <= OP_REL; cmd_arg <= CONT_P; cmd_evt <= EVT_H4; cmd_spd <= i_touch_spd; end
                H5:      begin cmd_op <= OP_SETPOS; cmd_arg <= 32'd0; cmd_evt <= 32'd0; end
                default: begin
                    cmd_evt <= 32'd0;
                    if (i_bhv == 8'd3 || i_bhv == 8'd21) begin
                        cmd_op  <= OP_ABS;
                        cmd_arg <= i_target;
                    end else begin
                        cmd_op  <= OP_REL;
                        cmd_arg <= i_dir ? ((i_step >= CONT_P) ? CONT_P - 1 : i_step)
                                         : ((i_step >= CONT_P) ? CONT_N + 1 : (~i_step + 1'b1));
                    end
                end
            endcase
        end
    endtask

    always @(posedge clk_i) begin
        if (rst_i) begin
            st <= S_IDLE; step <= H_SEG; is_home <= 1'b0;
            cmd_req <= 1'b0; cmd_op <= 4'd0; cmd_arg <= 0; cmd_spd <= 0; cmd_acc <= 0; cmd_dec <= 0;
            cmd_evt <= 0; cmd_evt_dec <= 0; cmd_lim_dec <= 0;
            o_done <= 1'b0; o_error <= 1'b0; o_accepted <= 1'b0; o_alm <= 8'd0;
            fail_alm <= 8'd0; last_cause <= 4'd0; last_org <= 1'b0;
        end else begin
            cmd_req <= 1'b0;
            case (st)
                S_IDLE: if (i_start) begin
                    o_done <= 1'b0; o_error <= 1'b0; o_accepted <= 1'b0; o_alm <= 8'd0;
                    is_home  <= (i_bhv == 8'd1);
                    fail_alm <= (i_bhv == 8'd1) ? 8'd120 : (i_bhv == 8'd3 || i_bhv == 8'd21) ? 8'd122 : 8'd121;
                    if (i_bhv == 8'd1) begin
                        // start on search limit, off org: reverse first
                        step <= (st_io[1] && !st_io[2]) ? H2 : H1;
                        load_seg((st_io[1] && !st_io[2]) ? H2 : H1);
                    end else begin
                        step <= H_SEG;
                        load_seg(H_SEG);
                    end
                    st <= S_ISSUE;
                end
                S_ISSUE: begin
                    if (i_abort) begin
                        o_error <= 1'b1; st <= S_IDLE;
                    end else if (cmd_rdy) begin
                        cmd_req <= 1'b1;
                        st <= S_ACK;
                    end
                end
                S_ACK: begin
                    if (cmd_timeout) begin
                        o_error <= 1'b1; o_alm <= 8'd119; st <= S_IDLE;
                    end else if (cmd_ack) begin
                        if (cmd_result != RS_OK) begin
                            o_error <= 1'b1; o_alm <= reject_alm(cmd_result, st_fault); st <= S_IDLE;
                        end else begin
                            o_accepted <= 1'b1;
                            if (step == H5) begin
                                o_done <= 1'b1; st <= S_IDLE;
                            end else
                                st <= S_RUN;
                        end
                    end
                end
                S_RUN: if (rx_commit) begin
                    if (st_s1[13]) begin
                        o_error <= 1'b1;
                        o_alm   <= (st_s1[3:0] == 4'd5 && fault_alm(st_fault) != 0) ? fault_alm(st_fault) :
                                   (st_s1[3:0] == 4'd3 || st_s1[3:0] == 4'd4 || st_s1[3:0] == 4'd6) ? 8'd106 :
                                   fail_alm;
                        st <= S_IDLE;
                    end else if (st_s1[14]) begin
                        last_cause <= st_s1[11:8];
                        last_org   <= st_io[2];
                        if (!is_home) begin
                            o_done <= 1'b1; st <= S_IDLE;
                        end else
                            st <= S_NEXT;
                    end
                end
                S_NEXT: begin
                    // home step decision after a stopped search/creep segment
                    if (i_abort) begin
                        o_error <= 1'b1; st <= S_IDLE;
                    end else begin
                        case (step)
                            H1: begin
                                if (last_cause[0] && last_org) begin step <= H4; load_seg(H4); st <= S_ISSUE; end
                                else if (last_cause[3])        begin step <= H2; load_seg(H2); st <= S_ISSUE; end
                                else begin o_error <= 1'b1; o_alm <= 8'd120; st <= S_IDLE; end
                            end
                            H2: begin
                                if (last_cause[0] && last_org) begin step <= H4; load_seg(H4); st <= S_ISSUE; end
                                else begin o_error <= 1'b1; o_alm <= 8'd120; st <= S_IDLE; end
                            end
                            H4: begin step <= H5; load_seg(H5); st <= S_ISSUE; end
                            default: begin o_error <= 1'b1; o_alm <= 8'd120; st <= S_IDLE; end
                        endcase
                    end
                end
                default: st <= S_IDLE;
            endcase
            if (i_cancel && st != S_IDLE) begin
                st <= S_IDLE;
                if (!o_done) o_error <= 1'b1;
            end
        end
    end

endmodule
