/////////////////////////// MODULE //////////////////////////////
module math_div
#(
     parameter  n_width = 32
    ,parameter  d_width = 22
    ,parameter  auto_round = 1 // change by szzhang 20260913
    ,parameter  USE_PAUSE = 0 // optional synchronous pipeline hold
)
(
    input                       clk
   ,input                       rst
   
   ,input  wire                 clk_en
   ,input  wire [n_width-1:0]   nom
   ,input  wire [d_width-1:0]   den
   ,output reg  [n_width-1:0]   quo
   ,output reg  [d_width-1:0]   remo
   ,output reg                  ready
   ,output wire                 full // all busy: clk_en dropped, change by szzhang 20260913
   ,input  wire                 pause // used only when USE_PAUSE=1; hold ready/data too
);

   ////////////////// ARCH ////////////////////
   wire advance = !USE_PAUSE || !pause;
   
   ////////////////// STATE
   localparam p_state = 4;
   
   reg [1:0]                   fsm_st[0:p_state-1];
   reg [7:0]                   fsm_cnt[0:p_state-1];

   reg [n_width+d_width-1 : 0] den_d[0:p_state-1];
   reg [n_width-1 : 0]         quo_d[0:p_state-1];
   reg [n_width+d_width-1 : 0] remo_d[0:p_state-1];
   reg                         busy_d[0:p_state-1];

   reg [n_width-1 : 0]         quo_q[0:p_state-1];
   reg [d_width-1 : 0]         remo_q[0:p_state-1];
   reg                         ready_q[0:p_state-1];
   
   reg [0:p_state-1]           clk_en_d;
   integer                     p;
   
   always@* begin // blocking style, change by szzhang 20260913
      if(rst || !advance) begin
         clk_en_d = 0;
      end
      else begin
         clk_en_d = 0;
         
         if(clk_en) begin // chain tracks p_state
            if(~busy_d[0])
               clk_en_d[0] = 1'b1;
            else if(~busy_d[1])
               clk_en_d[1] = 1'b1;
            else if(~busy_d[2])
               clk_en_d[2] = 1'b1;
            else if(~busy_d[3])
               clk_en_d[3] = 1'b1;
         end
      end
   end
   
   generate
   genvar s;
   for(s=0;s<p_state;s=s+1) begin: div_state
      always@(posedge clk) begin
         if(rst) begin
            fsm_st[s]  <= 0;
            fsm_cnt[s] <= 0;
            remo_d[s]  <= {(n_width+d_width){1'b0}};
            den_d[s]   <= {(n_width+d_width){1'b0}};
            quo_d[s]   <= {n_width{1'b0}};
            busy_d[s]  <= 1'b0;
            ready_q[s] <= 1'b0;
            remo_q[s]  <= {d_width{1'b0}};
            quo_q[s]   <= {n_width{1'b0}};
         end
         else if(advance) begin//change by szzhang 20260913
            case(fsm_st[s]) 
               0: begin
                  fsm_cnt[s] <= 0;
                  remo_d[s]  <= {(n_width+d_width){1'b0}};
                  den_d[s]   <= {(n_width+d_width){1'b0}};
                  quo_d[s]   <= {n_width{1'b0}};
                  busy_d[s]  <= 1'b0;
                  ready_q[s] <= 1'b0;
                  remo_q[s]  <= {d_width{1'b0}};
                  quo_q[s]   <= {n_width{1'b0}};
                  if(clk_en_d[s]) begin
                     fsm_cnt[s] <= fsm_cnt[s] + 1'b1;
                     fsm_st[s] <= 2'd1;
                     remo_d[s] <= {{d_width{1'b0}},nom};
                     den_d[s]  <= {1'b0,den,{(n_width-1){1'b0}}};
                     quo_d[s]  <= {n_width{1'b0}};
                     busy_d[s]  <= 1'b1;
                  end
               end
               1: begin
                  busy_d[s]  <= 1'b1;
                  ready_q[s] <= 1'b0;
                  remo_q[s]  <= {d_width{1'b0}};
                  quo_q[s]   <= {n_width{1'b0}};
                  fsm_cnt[s] <= fsm_cnt[s] + 1'b1;
                  if(remo_d[s] >= den_d[s])  begin
                     remo_d[s] <= remo_d[s] - den_d[s];
                     quo_d[s]  <= {quo_d[s][n_width-2:0],1'b1};
                  end
                  else begin
                     remo_d[s] <= remo_d[s];
                     quo_d[s]  <= {quo_d[s][n_width-2:0],1'b0};
                  end
                  if(fsm_cnt[s] != n_width)
                     den_d[s]  <= den_d[s]>>1; // last iter keeps den for round
                  if(fsm_cnt[s] == n_width)
                     fsm_st[s] <= 2'd2;
               end
               2: begin
                  busy_d[s] <= 1'b1;
                  fsm_cnt[s] <= 0;
                  fsm_st[s] <= 0;
                  
                  ready_q[s] <= 1'b1;
                  if(~|den_d[s]) begin // den==0: quo=rem=0, change by szzhang 20260913
                     remo_q[s] <= {d_width{1'b0}};
                     quo_q[s]  <= {n_width{1'b0}};
                  end
                  else begin
                     remo_q[s] <= remo_d[s][d_width-1:0]; 
                     if(auto_round)
                        quo_q[s] <= quo_d[s] + ({remo_d[s][d_width-1:0],1'b0} >= {1'b0,den_d[s][d_width-1:0]}); // half-up: 2*rem>=den
                     else
                        quo_q[s] <= quo_d[s];
                  end
               end
            endcase
         end
      end
   end
   endgenerate
   
   // OR bus reduce, change by szzhang 20260913
   reg [n_width-1:0]   quo_or;
   reg [d_width-1:0]   remo_or;
   reg                 ready_or;
   reg                 busy_all;

   always@* begin
      quo_or   = {n_width{1'b0}};
      remo_or  = {d_width{1'b0}};
      ready_or = 1'b0;
      busy_all = 1'b1;
      for(p=0;p<p_state;p=p+1) begin
         quo_or   = quo_or   | quo_q[p];
         remo_or  = remo_or  | remo_q[p];
         ready_or = ready_or | ready_q[p];
         busy_all = busy_all & busy_d[p]; // full = all busy
      end
   end

   assign full = busy_all;

   // 1 start/cyc + fixed latency => ready never overlaps; hold until next ready, change by szzhang 20260913
   always@(posedge clk) begin
      if(rst) begin
         quo   <= 0;
         remo  <= 0;
         ready <= 1'b0;
      end
      else if(advance) begin//change by szzhang 20260913
         ready <= ready_or;
         if(ready_or) begin
            quo  <= quo_or;
            remo <= remo_or;
         end
      end
   end
   
endmodule