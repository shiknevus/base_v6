/////////////////////////// MODULE //////////////////////////////
module Positioner_std
(
    input                   clk
   ,input                   reset
   
   ,input  wire [31:0]      i_pf_spd
   ,input  wire [31:0]      i_pf_acc
   ,input  wire [31:0]      i_pf_dec
   ,input  wire [31:0]      i_pf_mode
   ,input  wire             i_pf_start
   ,input  wire             i_pf_stop
   ,input  wire             i_pf_dir
   ,input  wire [31:0]      i_pf_pulse
   ,input  wire             i_quickstop
   ,input  wire [31:0]      i_quickstop_dec
   ,input  wire             i_pause
   ,output wire             o_pf_done
   ,output wire             o_pf_error
   ,output wire             o_pf_busy
   ,output wire             o_pulse_start
   ,output wire [31:0]      o_pulse_period
   ,output wire [31:0]      o_pulse_number
   ,output wire             o_pulse_dir
   ,input  wire             i_pulse_done
   
);

   //////////////////////// DEFINE ////////////
//   `define PF_SIM        1

   ///////////////// PARAMETER ////////////////
   localparam  P_SPD_MIN    = 22'd200;
   localparam  P_PERIOD_MIN = 32'd50_000000;
   
   ///////////////// ARCH ////////////////////
   localparam  P_DIV_WIDTH    = 46;
   localparam  P_SPD_WIDTH    = 23; // 0 ~ 8M
   localparam  P_PERIOD_WIDTH = 28; // 0 ~ 256M
   localparam  CLK_HZ         = 156_250_000;   
   localparam  P_JERK_WIDTH   = 65-P_SPD_WIDTH;

   localparam  SIM_PERIOD_DIV = 512; // simulation only // add by szzhang 20260813

   localparam  ST_POS_IDLE = 0;
   localparam  ST_POS_INIT = 1;
   localparam  ST_POS_ACC  = 2;
   localparam  ST_POS_DEC  = 3;
   
   localparam  MODE_T    	 = 32'h00;
   localparam  MODE_S 		 = 32'h10;
   localparam  UNIT_DT     = ({P_DIV_WIDTH{1'b1}}/(10**8));
   
   ////////////////// Division
   reg                        spd_div_start;
   reg   [P_DIV_WIDTH-1:0]    spd_div_nom;
   reg   [P_SPD_WIDTH-1:0]    spd_div_den;
   wire  [P_DIV_WIDTH-1:0]    spd_div_quo;
   wire                       spd_div_ready;
   
   math_div #(
      .n_width(P_DIV_WIDTH),
      .d_width(P_SPD_WIDTH)
   ) 
   spd_div (
      .clk     ( clk           ),
      .rst     ( reset         ),
      .clk_en  ( spd_div_start ),
      .nom     ( spd_div_nom   ),
      .den     ( spd_div_den   ),
      .quo     ( spd_div_quo   ),
      .remo    (               ),
      .ready   ( spd_div_ready )
   );

   reg                        period_div_start;
   reg   [P_JERK_WIDTH-1:0]   period_div_nom;
   reg   [P_SPD_WIDTH-1:0]    period_div_den;
   wire  [P_JERK_WIDTH-1:0]   period_div_quo;
   wire                       period_div_ready;

   math_div #(
      .n_width(P_JERK_WIDTH),
      .d_width(P_SPD_WIDTH)
   ) 
   period_div (
      .clk     ( clk              ),
      .rst     ( reset            ),
      .clk_en  ( period_div_start ),
      .nom     ( period_div_nom   ),
      .den     ( period_div_den   ),
      .quo     ( period_div_quo   ),
      .remo    (                  ),
      .ready   ( period_div_ready )
   );

   ////////////////// Profile
   reg  [1:0]                           fsm_st;
   
   reg                                  r_pf_dir;
   reg  [31:0]                          r_pf_mode;
   reg                                  r_pf_quickstop;
   reg                                  r_div_ready;
   reg                                  p_div_ready;
   reg                                  r_pf_pulse_first;
   reg  [P_PERIOD_WIDTH-1:0]            r_pf_pulse_count;
         
   ////////////////// Speed & Acceleration & Deceleration Profile
   
   // Speed 0 ~ 8M, 23-bit
   reg  [P_SPD_WIDTH-1:0]               r_pf_spd_target;
   reg  [P_DIV_WIDTH+P_SPD_WIDTH-1:0]   r_pf_spd_next;// @CLK r_pf_spd_next <= div_quo*m_pf_acc or div_quo*m_pf_dec
   reg  [P_DIV_WIDTH+P_SPD_WIDTH-1:0]   r_pf_spd_act; // @CLK r_pf_spd_act <= r_pf_spd_next
   wire [P_SPD_WIDTH-1:0]               r_pf_spd;
   math_reduce #(P_DIV_WIDTH+P_SPD_WIDTH,P_SPD_WIDTH)
   spd_reduce (
      .in_acc  ( r_pf_spd_act ),
      .out_acc ( r_pf_spd     )
   );
      
   // Acceleration/Deceleration
   reg  [31:0]                          r_pf_acc;
   reg  [P_DIV_WIDTH+31:0]              r_pf_acc_act;
   wire [31:0]                          r_pf_acc_next;
   math_reduce #(P_DIV_WIDTH+32,32)
   acc_reduce (
      .in_acc  ( r_pf_acc_act  ),
      .out_acc ( r_pf_acc_next )
   );
   reg  [31:0]                          r_pf_acc_target;
   
   reg  [31:0]                          r_pf_dec;
   reg  [P_DIV_WIDTH+31:0]              r_pf_dec_act;
   wire [31:0]                          r_pf_dec_next;
   math_reduce #(P_DIV_WIDTH+32,32)
   dec_reduce (
      .in_acc  ( r_pf_dec_act  ),
      .out_acc ( r_pf_dec_next )
   );
   reg  [31:0]                          r_pf_dec_target;

   reg  [P_SPD_WIDTH-1:0]               r_pf_jerk_spd_dec;
   reg                                  r_pf_jerk_state;
   reg  [P_JERK_WIDTH-1:0]              r_pf_jerk_acc; // jerk = 2 * acc^2 / spd
   reg  [P_JERK_WIDTH-1:0]              r_pf_jerk_dec; // jerk = 2 * dec^2 / spd



   `define CHANGE_SPD
   `ifdef CHANGE_SPD
   always@(posedge clk) begin
      if(reset) begin
         r_pf_spd_target  <= 0;
      end else begin
         r_pf_spd_target  <= i_pf_spd;
      end
   end
    `endif

   always@(posedge clk) begin
      if(reset) begin
        `ifndef CHANGE_SPD
         r_pf_spd_target  <= 0;
        `endif
         r_pf_acc         <= 0;
         r_pf_dec         <= 0;
         r_pf_spd_act     <= 0;
         r_pf_acc_act     <= 0;
         r_pf_dec_act     <= 0;
         r_pf_acc_target  <= 0;
         r_pf_dec_target  <= 0;
         r_pf_jerk_state  <= 1'b0;
         r_pf_quickstop   <= 1'b0;
      end else if(~i_pause) begin
         case(fsm_st)
            ST_POS_IDLE: begin
               if(i_pf_start) begin
                `ifndef CHANGE_SPD
                 r_pf_spd_target  <= i_pf_spd;
                `endif
                  r_pf_acc         <= i_pf_acc;
                  r_pf_acc_target  <= i_pf_acc;
                  r_pf_dec         <= i_pf_dec;
                  r_pf_dec_target  <= i_pf_dec;
                  r_pf_spd_act     <= {i_pf_spd,{P_DIV_WIDTH{1'b0}}};
                  r_pf_acc_act     <= 0;
                  r_pf_dec_act     <= 0;
                  r_pf_jerk_state  <= 1'b0;
                  r_pf_quickstop   <= 1'b0;
               end
            end
            ST_POS_INIT: begin
               if(period_div_ready&~p_div_ready)
                  r_pf_jerk_acc <= ({32'd0,period_div_quo}*r_pf_acc)>>(P_JERK_WIDTH-33);
               else if(period_div_ready&p_div_ready)
                  r_pf_jerk_dec <= ({32'd0,period_div_quo}*r_pf_dec)>>(P_JERK_WIDTH-33);
                  
               if(spd_div_ready&r_div_ready) begin
                  r_pf_spd_act <= r_pf_acc_target*({P_DIV_WIDTH+4{1'b1}}/(10**5));
                  r_pf_acc     <= r_pf_acc_target;
                  r_pf_dec     <= r_pf_dec_target;
                  
                  if((r_pf_mode&MODE_S) == MODE_S) begin // S Wave Mode
                     r_pf_acc     <= 0;
                     r_pf_spd_act <= 0;
                  end
               end
            end
            ST_POS_ACC: begin
               // speed
               if(r_pf_pulse_first) begin
`ifdef PF_SIM
                  if(r_pf_spd_act < {r_pf_spd_target,{P_DIV_WIDTH{1'b0}}})
                     r_pf_spd_act <= r_pf_spd_act + r_pf_acc*UNIT_DT*256;
                  else
                     r_pf_spd_act <= {r_pf_spd_target,{P_DIV_WIDTH{1'b0}}};
`else
                  r_pf_spd_act <= r_pf_spd_act + r_pf_acc*UNIT_DT;
`endif
               end else begin
`ifdef PF_SIM
                  if(r_pf_spd_act < {r_pf_spd_target,{P_DIV_WIDTH{1'b0}}})
                     r_pf_spd_act <= r_pf_spd_act + r_pf_acc*UNIT_DT*256;
                  else
                     r_pf_spd_act <= {r_pf_spd_target,{P_DIV_WIDTH{1'b0}}};
`else
                  if(spd_div_ready) begin
                     r_pf_spd_next <= spd_div_quo*r_pf_acc;

                     if((r_pf_mode&MODE_S) == MODE_S) // S Wave Mode
                        if(r_pf_acc_act[P_DIV_WIDTH+31:P_DIV_WIDTH] < r_pf_acc_target)
                           r_pf_spd_next <= (spd_div_quo*r_pf_acc)<<1;
                  end

                  if(r_div_ready) begin
                     if(r_pf_spd + r_pf_spd_next[P_DIV_WIDTH+P_SPD_WIDTH-1:P_DIV_WIDTH] < r_pf_spd_target)
                        r_pf_spd_act <= r_pf_spd_act + r_pf_spd_next;
                     else
                        r_pf_spd_act <= {r_pf_spd_target,{P_DIV_WIDTH{1'b0}}};
                  end
`endif
               end
               
               // acceleration
               r_pf_acc <= r_pf_acc_target;

               if((r_pf_mode&MODE_S) == MODE_S) begin // S Wave Mode
                  if(~r_pf_jerk_state) begin
                     if(r_pf_spd+r_pf_jerk_spd_dec > r_pf_spd_target)
                        r_pf_jerk_state <= 1'b1;
                        
                     if(r_pf_acc_next < r_pf_acc_target) begin
                        r_pf_acc_act      <= r_pf_acc_act + r_pf_jerk_acc*({P_DIV_WIDTH{1'b1}}/(10**8));
                        r_pf_jerk_spd_dec <= r_pf_spd;
                     end
                     else
                        r_pf_acc_act <= {r_pf_acc_target,{P_DIV_WIDTH{1'b0}}};
                  end else begin
                     r_pf_acc_act <= r_pf_acc_act - r_pf_jerk_acc*({P_DIV_WIDTH{1'b1}}/(10**8));
                     if(r_pf_acc_next <= r_pf_spd_target)
                        r_pf_acc_act <= {r_pf_spd_target,{P_DIV_WIDTH{1'b0}}};
                  end
                  
                  r_pf_acc <= r_pf_acc_next;
               end
               
               // quickstop
               if(i_quickstop) begin
                  r_pf_dec <= i_quickstop_dec;
                  r_pf_quickstop <= 1'b1;
               end
            end
            ST_POS_DEC: begin
               // speed
               if(spd_div_ready) begin
                  r_pf_spd_next <= spd_div_quo*r_pf_dec;
                  if((r_pf_mode&MODE_S) == MODE_S) // S Wave Mode
                     if(r_pf_dec_act[P_DIV_WIDTH+31:P_DIV_WIDTH] < r_pf_dec_target)
                        r_pf_spd_next <= (spd_div_quo*r_pf_dec)<<1;
               end

               if(r_div_ready) begin
                  if(r_pf_spd > r_pf_spd_next[P_DIV_WIDTH+P_SPD_WIDTH-1:P_DIV_WIDTH] + P_SPD_MIN)
                     r_pf_spd_act <= r_pf_spd_act - r_pf_spd_next;
                  else
                     r_pf_spd_act <= {P_SPD_MIN,{P_DIV_WIDTH{1'b0}}};
               end

               // deceleration             
               if((r_pf_mode&MODE_S) == MODE_S) begin // S Wave Mode
                  if(r_pf_jerk_state) begin
                     if(r_pf_dec_next < r_pf_dec_target) begin
                        r_pf_dec_act <= r_pf_dec_act + r_pf_jerk_dec*({P_DIV_WIDTH{1'b1}}/(10**8));
                        r_pf_jerk_spd_dec <= r_pf_spd_target - r_pf_spd;
                     end
                     else
                        r_pf_dec_act <= {r_pf_dec_target,{P_DIV_WIDTH{1'b0}}};
                     if(r_pf_jerk_spd_dec > r_pf_spd)
                        r_pf_jerk_state <= 1'b0;
                  end
                  else begin
                     if(r_pf_dec_next <= r_pf_spd_target)
                        r_pf_dec_act <= {r_pf_spd_target,{P_DIV_WIDTH{1'b0}}};
                     else
                        r_pf_dec_act <= r_pf_dec_act - r_pf_jerk_dec*({P_DIV_WIDTH{1'b1}}/(10**8));
                  end
                  
                  r_pf_dec <= r_pf_dec_next;
               end
               
               // quickstop
               if(i_quickstop) 
                  r_pf_quickstop <= 1'b1;
                  
               if(r_pf_quickstop)
                  r_pf_dec <= i_quickstop_dec;
            end
         endcase
      end
   end
   
   ////////////////// Pulse calculation
   reg  [31:0]                          r_pf_pulse;

   reg  [P_SPD_WIDTH-1:0]               r_pf_spd_red; // @CLK r_pf_spd_red <= r_pf_spd
   reg  [P_SPD_WIDTH*2-1:0]             r_pf_spd_p2;  // @CLK r_pf_spd_p2 <= r_pf_spd_red * r_pf_spd_red
   reg  [P_DIV_WIDTH-1:0]               r_pf_dec_inv; // 1/DEC
   reg  [P_DIV_WIDTH-1:0]               r_pf_acc_inv; // 1/ACC

   reg  [P_DIV_WIDTH+P_SPD_WIDTH*2-1:0] r_pf_pulse_acc_red_in; // @CLK r_pf_pulse_acc_red_in <= r_pf_spd_p2 * r_pf_acc_inv
   wire [P_SPD_WIDTH*2-11:0]            r_pf_pulse_acc_red_out;
   math_reduce #(P_DIV_WIDTH+P_SPD_WIDTH*2,P_SPD_WIDTH*2-10) 
   pulse_acc_reduce (
      .in_acc  ( r_pf_pulse_acc_red_in  ),
      .out_acc ( r_pf_pulse_acc_red_out )
   );
   wire [31:0]                          r_pf_pulse_acc_next; // spd_act^2/acc/2
   math_sat #(P_SPD_WIDTH*2-10,32)
   pulse_acc_sat (
      .in_acc  ( r_pf_pulse_acc_red_out ),
      .out_acc ( r_pf_pulse_acc_next    ),
      .out_saturated());
   reg  [31:0]                          r_pf_pulse_acc; // @CLK r_pf_pulse_acc <= r_pf_pulse_acc_next

   reg  [P_DIV_WIDTH+P_SPD_WIDTH*2-1:0] r_pf_pulse_dec_red_in; // @CLK r_pf_pulse_dec_red_in <= r_pf_spd_p2 * r_pf_dec_inv;
   wire [P_SPD_WIDTH*2-11:0]            r_pf_pulse_dec_red_out;
   math_reduce #(P_DIV_WIDTH+P_SPD_WIDTH*2,P_SPD_WIDTH*2-10) 
   pulse_dec_reduce (
      .in_acc  ( r_pf_pulse_dec_red_in  ),
      .out_acc ( r_pf_pulse_dec_red_out )
   );
   wire [31:0]                          r_pf_pulse_dec_next; // spd_act^2/dec/2
   math_sat #(P_SPD_WIDTH*2-10,32)
   pulse_dec_sat (
      .in_acc  ( r_pf_pulse_dec_red_out ),
      .out_acc ( r_pf_pulse_dec_next    ),
      .out_saturated());
   
   reg  [31:0]                          r_pf_pulse_dec; // @CLK r_pf_pulse_dec <= r_pf_pulse_dec_next

   reg  [31:0]                          r_pf_pulse_cal;
   reg  [31:0]                          r_pf_pulse_act;
   reg  [31:0]                          r_pf_pulse_dif;
   
   // Period, 0 ~ 10^8
   reg  [P_PERIOD_WIDTH-1:0]            r_pf_pulse_period;      // 27-BIT: 0 ~ 10^8
   
   wire                                 r_pf_pulse_done = r_pf_pulse_count>=r_pf_pulse_period-1'b1;   
   
   localparam  PF_JERK_NBIT=32;
   
   always@(posedge clk) begin
      if(reset) begin
         r_pf_pulse        <= 0;
         r_pf_pulse_count  <= 0;
         r_pf_pulse_period <= P_PERIOD_MIN;
         r_pf_pulse_dec    <= 0;
         r_pf_pulse_acc    <= 0;
         r_pf_pulse_act    <= 0;
         r_pf_dec_inv      <= 0;
         r_pf_acc_inv      <= 0;
         r_pf_pulse_first  <= 1'b1;
      end
      else if(~i_pause) begin
         case(fsm_st)
            ST_POS_IDLE: begin
               r_pf_pulse_count  <= 0;
               r_pf_pulse_period <= P_PERIOD_MIN;
               r_pf_pulse_cal    <= 0;
               r_pf_pulse_dec    <= 0;
               r_pf_pulse_acc    <= 0;
               r_pf_pulse_act    <= 0;
               if(i_pf_start) begin
                  r_pf_pulse       <= i_pf_pulse;
                  r_pf_pulse_act   <= 0;
                  r_pf_pulse_first <= 1'b1;
                  r_pf_pulse_dif   <= ((i_pf_mode&MODE_S) == MODE_S) ? 32'd5 : 32'd5;
               end
            end
            ST_POS_INIT: begin
               r_pf_pulse_count <= r_pf_pulse_count + 1'b1;
                  
               if(spd_div_ready&~r_div_ready)
                  r_pf_acc_inv <= spd_div_quo; // 2^DIV_WIDTH/ACC
               else if(spd_div_ready&r_div_ready) begin
                  r_pf_dec_inv <= spd_div_quo; // 2^DIV_WIDTH/DEC

                  r_pf_pulse_count <= 0;
               end
            end
            ST_POS_ACC: begin
               // period & count
               if(period_div_ready)
                  r_pf_pulse_period <= period_div_quo[P_PERIOD_WIDTH-1:0];//r_pf_pulse_period_next;
                  
               r_pf_pulse_count <= r_pf_pulse_count + 1'b1;
                              
               if(r_pf_pulse_first) begin
                  if(r_pf_pulse_done) begin
                     r_pf_pulse_count <= 0;
                     r_pf_pulse_first <= 1'b0;
                     r_pf_pulse_act <= r_pf_pulse_act + 1'b1;
                  end
               end
               else begin
                  if(r_pf_pulse_done)
                     r_pf_pulse_count <= 0;

                  // actual pulse
                  if(r_pf_pulse_done)
                     r_pf_pulse_act <= r_pf_pulse_act + 1'b1;
               end
               
               // pulse calculation: (spd^2/dec + spd^2/acc)/2
               r_pf_spd_red <= r_pf_spd;
               r_pf_spd_p2 <= r_pf_spd_red*r_pf_spd_red;
               
`ifdef PF_SIM
               r_pf_pulse_acc_red_in <= r_pf_spd_p2 * r_pf_acc_inv;
               r_pf_pulse_acc <= r_pf_pulse_acc_next; // pulse_acc = spd^2/acc/2
`endif               
               r_pf_pulse_dec_red_in <= r_pf_spd_p2 * r_pf_dec_inv;
               r_pf_pulse_dec <= r_pf_pulse_dec_next; // pulse_dec = spd^2/dec/2
               
               r_pf_pulse_cal <= r_pf_pulse_act + r_pf_pulse_dec + r_pf_pulse_dif;
            end
            ST_POS_DEC: begin
               // count & period
               if(period_div_ready)
                  r_pf_pulse_period <= period_div_quo[P_PERIOD_WIDTH-1:0];//r_pf_pulse_period_next;

               r_pf_pulse_count <= r_pf_pulse_count + 1'b1;
               if(r_pf_pulse_done)
                  r_pf_pulse_count <= 0;
               
               // actual pulse
               if(r_pf_pulse_done)
                  r_pf_pulse_act <= r_pf_pulse_act + 1'b1;
               
               // pulse calculation: (spd^2/dec + spd^2/acc)/2
               r_pf_spd_red <= r_pf_spd;
               r_pf_spd_p2 <= r_pf_spd_red*r_pf_spd_red;
               
               r_pf_pulse_dec_red_in <= r_pf_spd_p2 * r_pf_dec_inv;
               r_pf_pulse_dec <= r_pf_pulse_dec_next; // pulse_dec = spd^2/dec/2
            end
         endcase
      end
   end
   
   ////////////////// FSM
   reg          r_pf_error;
   reg          r_pf_busy;
   reg          r_pf_done;
   
   always@(posedge clk) begin
      if(reset) begin
         fsm_st     <= ST_POS_IDLE;
         r_pf_error <= 1'b0;
         r_pf_done  <= 1'b0;
         r_pf_busy  <= 1'b0;
         r_pf_dir   <= 1'b0;
         r_pf_mode  <= 0;
      end
      else begin
         r_div_ready <= spd_div_ready;
         p_div_ready <= period_div_ready;
         if(~i_pause)   //change by szzhang 20260813
         case(fsm_st)
            ST_POS_IDLE: begin
               r_pf_busy  <= 1'b0;
               r_pf_done  <= 1'b0;   //change by szzhang 20260813
               if(i_pf_start) begin
                  r_pf_error <= 1'b0;
                  r_pf_busy  <= 1'b1;
                  r_pf_done  <= i_pf_pulse!=0 ? 1'b0 : 1'b1;
                  r_pf_dir   <= i_pf_dir;
                  r_pf_mode  <= i_pf_mode; // 0Xh: T Wave mode, 1Xh: S Wave mode
                  fsm_st     <= i_pf_pulse!=0 ? ST_POS_INIT : ST_POS_IDLE;
               end
                                 
               if(i_pf_stop) begin
                  fsm_st <= ST_POS_IDLE;
               end
            end
            ST_POS_INIT: begin
               if(spd_div_ready&r_div_ready)
                  fsm_st <= ST_POS_ACC;

               if(i_pf_stop) begin
                  fsm_st <= ST_POS_IDLE;
                  r_pf_done <= 1'b1;
               end
            end
            ST_POS_ACC: begin
               r_pf_error <= 1'b0;
               r_pf_done  <= 1'b0;
               r_pf_busy  <= 1'b1;
               if(r_pf_pulse_first) begin
                  if(r_pf_pulse_count>=r_pf_pulse_period-1'b1)
                     if(r_pf_pulse==1) begin
                        fsm_st <= ST_POS_IDLE;
                        r_pf_done <= 1'b1;
                     end                     
                     else if(r_pf_pulse<=r_pf_pulse_dif)
                        fsm_st <= ST_POS_DEC;
               end
               else begin
                  if(r_pf_pulse_done) begin
                     if(r_pf_pulse_cal>=r_pf_pulse-1'b1 | r_pf_quickstop)
                        fsm_st <= ST_POS_DEC;
                  end
               end

               if(i_pf_stop) begin
                  fsm_st <= ST_POS_IDLE;
               end
            end
            ST_POS_DEC: begin
               r_pf_error <= 1'b0;
               r_pf_busy  <= 1'b1;
               r_pf_done  <= 1'b0;
               if(r_pf_pulse_done) begin
                  case(r_pf_mode[3:0])
                     0: begin // stop at mini speed
                        if(r_pf_spd<=P_SPD_MIN) begin
                           fsm_st <= ST_POS_IDLE;
                           r_pf_done <= 1'b1;
                        end
                     end
                     1: begin // stop when reaching target pulse, or quickstop at mini speed
                        if((r_pf_pulse_act==r_pf_pulse-1'b1) | (r_pf_quickstop&r_pf_spd<=P_SPD_MIN)) begin
                           fsm_st <= ST_POS_IDLE;
                           r_pf_done <= 1'b1;
                        end
                     end
                  endcase
               end

               if(i_pf_stop) begin
                  fsm_st <= ST_POS_IDLE;
                  r_pf_done <= 1'b1;
               end
            end
         endcase
      end
   end
      
   assign o_pf_done  = r_pf_done;
   assign o_pf_error = r_pf_error;
   assign o_pf_busy  = r_pf_busy;
   
   ////////////////// Pulse generator
   reg         r_pulse_start;
   reg [31:0]  r_pulse_period;
   reg [31:0]  r_pulse_number;
   reg         r_pulse_dir;
   
   always@* begin
      if(reset) begin
         r_pulse_start  <= 1'b0;
         r_pulse_period <= P_PERIOD_MIN;
         r_pulse_number <= 32'd0;
         r_pulse_dir    <= 1'b0;
         spd_div_start  <= 1'b0;
         spd_div_nom    <= 0;
         spd_div_den    <= 0;
         period_div_start <= 1'b0;
         period_div_nom <= 0;
         period_div_den <= 0;
      end
      else begin
         case(fsm_st)
            ST_POS_IDLE: begin
               r_pulse_start  <= 1'b0;
               r_pulse_period <= P_PERIOD_MIN;
               r_pulse_number <= 32'd0;
               r_pulse_dir    <= r_pf_dir;
               spd_div_start  <= 1'b0;
               spd_div_nom    <= 0;
               spd_div_den    <= 0;
               period_div_start <= 1'b0;
               period_div_nom <= 0;
               period_div_den <= 0;
            end
            ST_POS_INIT: begin
               r_pulse_start  <= 1'b0;
               r_pulse_period <= P_PERIOD_MIN;
               r_pulse_number <= 32'd0;
               r_pulse_dir    <= r_pf_dir;
               spd_div_start  <= r_pf_pulse_count==0 || r_pf_pulse_count==1;
               spd_div_nom    <= {P_DIV_WIDTH+9{1'b1}}/1000; // 2^(DIV_WIDTH+9)/1000
               spd_div_den    <= r_pf_pulse_count==0 ? r_pf_acc[P_SPD_WIDTH-1:0] : r_pf_dec[P_SPD_WIDTH-1:0]; // ACC/1000 or DEC/1000
               period_div_start <= r_pf_pulse_count==0 || r_pf_pulse_count==1;
               period_div_nom <= r_pf_pulse_count==0 ? {r_pf_acc_target,{P_JERK_WIDTH-32{1'b0}}} : {r_pf_dec_target,{P_JERK_WIDTH-32{1'b0}}};
               period_div_den <= r_pf_spd;
            end
            ST_POS_ACC: begin
               r_pulse_start  <= ~i_pause;
               r_pulse_period <= r_pf_pulse_period;
               r_pulse_number <= 32'd1;
               r_pulse_dir    <= r_pf_dir;
               spd_div_start  <= r_pf_pulse_first ? (r_div_ready&r_pf_pulse_count<=r_pf_pulse_period-1'b1) : r_pf_pulse_count==0;
               spd_div_nom    <= {P_DIV_WIDTH{1'b1}}; // 0 - period = 10^8/spd
               spd_div_den    <= r_pf_spd[P_SPD_WIDTH-1:0]; // Speed: 0 ~ 8M, 23-bit
               period_div_start  <= r_pf_pulse_first ? (r_div_ready&r_pf_pulse_count<=r_pf_pulse_period-1'b1) : r_pf_pulse_count==0;
`ifdef PF_SIM
               period_div_nom <= CLK_HZ[P_PERIOD_WIDTH-1:0] / SIM_PERIOD_DIV; //add by szzhang 20260813
`else
               period_div_nom <= CLK_HZ[P_PERIOD_WIDTH-1:0];
`endif
               period_div_den <= r_pf_spd[P_SPD_WIDTH-1:0]; // Speed: 0 ~ 8M, 23-bit;
            end
            ST_POS_DEC: begin
               r_pulse_start  <= ~i_pause;   //change by szzhang 20260813
               r_pulse_period <= r_pf_pulse_period;
               r_pulse_number <= 32'd1;
               r_pulse_dir    <= r_pf_dir;
               spd_div_start  <= r_pf_pulse_count==0;
               spd_div_nom    <= {P_DIV_WIDTH{1'b1}}; // 0 - period = 10^8/spd
               spd_div_den    <= r_pf_spd[P_SPD_WIDTH-1:0]; // Speed: 0 ~ 8M, 23-bit
               period_div_start  <= r_pf_pulse_count==0;
`ifdef PF_SIM
               period_div_nom <= CLK_HZ[P_PERIOD_WIDTH-1:0] / SIM_PERIOD_DIV;
`else
               period_div_nom <= CLK_HZ[P_PERIOD_WIDTH-1:0];
`endif
               period_div_den <= r_pf_spd[P_SPD_WIDTH-1:0]; // Speed: 0 ~ 8M, 23-bit;    
            end
            default: begin
               r_pulse_start  <= 1'b0;
               r_pulse_period <= P_PERIOD_MIN;
               r_pulse_number <= 32'd0;
               r_pulse_dir    <= 1'b0;
               spd_div_start  <= 1'b0;
               spd_div_nom    <= 0;
               spd_div_den    <= 0;
               period_div_start  <= 1'b0;
               period_div_nom <= 0;
               period_div_den <= 0;
            end
         endcase
      end
   end

   assign o_pulse_start  = r_pulse_start;
   assign o_pulse_period = r_pulse_period;
   assign o_pulse_number = r_pulse_number;
   assign o_pulse_dir    = r_pulse_dir;

endmodule