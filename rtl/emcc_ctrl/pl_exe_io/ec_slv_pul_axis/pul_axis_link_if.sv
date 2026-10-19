`timescale 1ns / 1ps
// Master-side transport for the pulse-axis slave board, ABI v2
// (doc/pul_axis_seg_abi_v2.md).  Owns the 16-word frame both ways.
module pul_axis_link_if (
    input             clk_i,
    input             rst_i,
    input             i_time_1ms_vld,

    // command channel (one outstanding command)
    input             cmd_req,
    input      [3:0]  cmd_op,
    input      [31:0] cmd_arg,
    input      [31:0] cmd_spd,
    input      [31:0] cmd_acc,
    input      [31:0] cmd_dec,
    input      [31:0] cmd_evt,
    input      [31:0] cmd_evt_dec,
    input      [31:0] cmd_lim_dec,
    output            cmd_rdy,
    output reg        cmd_ack,          // pulse, cmd_result valid
    output reg [3:0]  cmd_result,
    output reg        cmd_timeout,      // pulse, no ack within CMD_TO_MS

    // level controls and config (sampled every frame)
    input             ctl_son,
    input             ctl_rst,
    input             ctl_pause,
    input             ctl_stop,
    input             ctl_qstop,
    input             ctl_ext_abort,
    input             io_limf,
    input             io_limb,
    input             io_org,
    input      [31:0] cfg_spd_max,
    input      [31:0] cfg_acc_max,
    input      [31:0] cfg_dec_max,
    input      [31:0] cfg_soft_max,
    input      [31:0] cfg_soft_min,
    input      [31:0] cfg_io_map,
    input      [31:0] cfg_opt,

    // slave status (committed per s2m frame)
    output            link_ready,
    output            abi_bad,
    output reg        rx_commit,        // pulse, st_* just updated
    output reg [31:0] st_s0,
    output reg [31:0] st_s1,
    output reg [31:0] st_fault,
    output reg [31:0] st_pos,
    output reg [31:0] st_io,
    output reg [31:0] st_s12,
    output reg [31:0] st_s13,

    // physical pulse-slave link
    input      [4:0]  cur_slv_board_id,
    input      [4:0]  slv_board_id,
    input             pul_motor_r_flag,
    input             pul_motor_flag,
    output reg [31:0] m2s_pulm_msg,
    input      [31:0] s2m_pulm_msg,

    // observability
    output            m2s_frame_start_o,
    output     [31:0] m2s_word0_o,
    output     [15:0] s2m_frame_count_o,
    output     [11:0] m2s_frame_count_o
);
    localparam [15:0] MAGIC     = 16'h5A7E;
    localparam [7:0]  ABI_MAJ   = 8'd2;
    localparam [7:0]  ABI_MIN   = 8'd0;
    localparam        CMD_TO_MS = 50;
    localparam        RX_TO_MS  = 20;

    ////////////////// heartbeat
    reg [31:0] beat_cnt;
    reg        beat;
    always @(posedge clk_i) begin
        if (rst_i) begin
            beat_cnt <= 32'd0; beat <= 1'b0;
        end else if (beat_cnt >= 2000000) begin
            beat_cnt <= 32'd0; beat <= ~beat;
        end else
            beat_cnt <= beat_cnt + 1'b1;
    end

    ////////////////// command registers
    reg [7:0]  seq;
    reg [3:0]  op_r;
    reg [31:0] arg_r, spd_r, acc_r, dec_r, evt_r, evt_dec_r, lim_dec_r;
    reg        pend;
    reg [7:0]  pend_ms;
    assign cmd_rdy = !pend;     // must not depend on cmd_req (requesters gate on it)

    wire [31:0] w0 = {seq, op_r, 4'd0,
                      ctl_son, ctl_rst, beat, ctl_pause, ctl_stop, ctl_qstop, ctl_ext_abort, 1'b0,
                      io_org, io_limb, io_limf, 5'd0};
    wire [511:0] live = {{MAGIC, ABI_MAJ, ABI_MIN}, cfg_opt, cfg_io_map, cfg_soft_min, cfg_soft_max,
                         cfg_dec_max, cfg_acc_max, cfg_spd_max, lim_dec_r, evt_dec_r, evt_r,
                         dec_r, acc_r, spd_r, arg_r, w0};

    ////////////////// m2s: snapshot at frame start, then words 1..15
    reg [3:0]   m2s_state;
    reg [511:0] snap;
    reg [11:0]  m2s_frm_cnt;
    wire        m2s_frame_start = (m2s_state == 4'd0) && pul_motor_r_flag;
    always @(posedge clk_i) begin
        if (rst_i) begin
            m2s_state <= 4'd0; m2s_pulm_msg <= 32'd0; snap <= 512'd0; m2s_frm_cnt <= 12'd0;
        end else begin
            if (m2s_state == 4'd0) begin
                m2s_pulm_msg <= w0;
                snap         <= live;
            end else
                m2s_pulm_msg <= snap[{m2s_state, 5'd0} +: 32];
            if (m2s_frame_start) begin
                m2s_state   <= 4'd1;
                m2s_frm_cnt <= m2s_frm_cnt + 1'b1;
            end else if (m2s_state != 4'd0)
                m2s_state <= (m2s_state == 4'd15) ? 4'd0 : m2s_state + 1'b1;
        end
    end

    ////////////////// s2m: capture 16 words of the selected board, commit at end
    reg        flag_d1, flag_d2;
    reg [3:0]  s2m_state;
    reg [511:0] rx_buf;
    reg        rx_full;
    reg [15:0] s2m_frm_cnt;
    wire       s2m_frame_start = flag_d2;
    always @(posedge clk_i) begin
        if (rst_i) begin
            flag_d1 <= 1'b0; flag_d2 <= 1'b0; s2m_state <= 4'd0; rx_buf <= 512'd0;
            rx_full <= 1'b0; s2m_frm_cnt <= 16'd0;
        end else begin
            flag_d1 <= pul_motor_flag && (cur_slv_board_id == slv_board_id);
            flag_d2 <= flag_d1;
            rx_full <= 1'b0;
            if (s2m_frame_start) begin
                rx_buf[31:0] <= s2m_pulm_msg;
                s2m_state    <= 4'd1;
            end else if (s2m_state != 4'd0) begin
                rx_buf[{s2m_state, 5'd0} +: 32] <= s2m_pulm_msg;
                if (s2m_state == 4'd15) begin
                    s2m_state   <= 4'd0;
                    rx_full     <= 1'b1;
                    s2m_frm_cnt <= s2m_frm_cnt + 1'b1;
                end else
                    s2m_state <= s2m_state + 1'b1;
            end
        end
    end

    reg [2:0] good_cnt;
    reg       magic_last;
    reg [7:0] rx_ms;
    wire      rx_magic = (rx_buf[511:496] == MAGIC) && (rx_buf[495:488] == ABI_MAJ);
    always @(posedge clk_i) begin
        if (rst_i) begin
            rx_commit <= 1'b0; good_cnt <= 3'd0; magic_last <= 1'b0; rx_ms <= RX_TO_MS;
            st_s0 <= 0; st_s1 <= 0; st_fault <= 0; st_pos <= 0; st_io <= 0;
            st_s12 <= 0; st_s13 <= 0;
        end else begin
            rx_commit <= rx_full;
            if (rx_full) begin
                rx_ms      <= 8'd0;
                magic_last <= rx_magic;
                good_cnt   <= rx_magic ? ((good_cnt == 3'd7) ? 3'd7 : good_cnt + 1'b1) : 3'd0;
                st_s0    <= rx_buf[31:0];
                st_s1    <= rx_buf[63:32];
                st_fault <= rx_buf[95:64];
                st_pos   <= rx_buf[127:96];
                st_io    <= rx_buf[191:160];
                st_s12   <= rx_buf[415:384];
                st_s13   <= rx_buf[447:416];
            end else if (i_time_1ms_vld && rx_ms < RX_TO_MS)
                rx_ms <= rx_ms + 1'b1;
        end
    end
    wire rx_stale = (rx_ms >= RX_TO_MS);
    assign link_ready = !rx_stale && (good_cnt >= 3'd4) && st_s1[4];
    assign abi_bad    = !rx_stale && !magic_last && (s2m_frm_cnt != 0);

    ////////////////// command handshake
    always @(posedge clk_i) begin
        if (rst_i) begin
            seq <= 8'd0; op_r <= 4'd0; arg_r <= 0; spd_r <= 0; acc_r <= 0; dec_r <= 0;
            evt_r <= 0; evt_dec_r <= 0; lim_dec_r <= 0;
            pend <= 1'b0; pend_ms <= 8'd0;
            cmd_ack <= 1'b0; cmd_result <= 4'd0; cmd_timeout <= 1'b0;
        end else begin
            cmd_ack     <= 1'b0;
            cmd_timeout <= 1'b0;
            if (cmd_req && !pend) begin
                seq <= seq + 1'b1;
                op_r <= cmd_op; arg_r <= cmd_arg; spd_r <= cmd_spd; acc_r <= cmd_acc; dec_r <= cmd_dec;
                evt_r <= cmd_evt; evt_dec_r <= cmd_evt_dec; lim_dec_r <= cmd_lim_dec;
                pend <= 1'b1; pend_ms <= 8'd0;
            end else if (pend) begin
                if (rx_commit && rx_magic && (rx_buf[63:56] == seq)) begin
                    pend       <= 1'b0;
                    cmd_ack    <= 1'b1;
                    cmd_result <= rx_buf[51:48];
                end else if (i_time_1ms_vld) begin
                    pend_ms <= pend_ms + 1'b1;
                    if (pend_ms >= CMD_TO_MS) begin
                        pend        <= 1'b0;
                        cmd_timeout <= 1'b1;
                    end
                end
            end
        end
    end

    assign m2s_frame_start_o = m2s_frame_start;
    assign m2s_word0_o       = w0;
    assign s2m_frame_count_o = s2m_frm_cnt;
    assign m2s_frame_count_o = m2s_frm_cnt;

endmodule
