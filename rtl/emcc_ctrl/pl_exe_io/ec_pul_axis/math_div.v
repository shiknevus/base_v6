/////////////////////////// MODULE //////////////////////////////
module math_div
#(
     parameter  n_width = 32
    ,parameter  d_width = 22
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
);

   ///////////////// PARAMETER ////////////////
   localparam         auto_round = 1;

   ////////////////// ARCH ////////////////////
   
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
   
   always@* begin
      if(rst) begin
         clk_en_d <= 0;
      end
      else begin
         clk_en_d <= 0;
         
         if(clk_en) begin
            if(~busy_d[0])
               clk_en_d[0] <= 1'b1;
            else if(~busy_d[1])
               clk_en_d[1] <= 1'b1;
            else if(~busy_d[2])
               clk_en_d[2] <= 1'b1;
            else if(~busy_d[3])
               clk_en_d[3] <= 1'b1;
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
         else begin
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
                     den_d[s]  <= den_d[s]>>1;
                     quo_d[s]  <= {quo_d[s][n_width-2:0],1'b1};
                  end
                  else begin
                     remo_d[s] <= remo_d[s];
                     den_d[s]  <= den_d[s]>>1;
                     quo_d[s]  <= {quo_d[s][n_width-2:0],1'b0};
                  end
                  if(fsm_cnt[s] == n_width)
                     fsm_st[s] <= 2'd2;
               end
               2: begin
                  busy_d[s] <= 1'b1;
                  fsm_cnt[s] <= 0;
                  fsm_st[s] <= 0;
                  
                  ready_q[s] <= 1'b1;
                  remo_q[s] <= remo_d[s][d_width-1:0]; 
                  if(auto_round)
                     quo_q[s] <= quo_d[s] + (remo_d[s]>=den_d[s]);
                  else
                     quo_q[s] <= quo_d[s];
               end
            endcase
         end
      end
   end
   endgenerate
   
   always@(posedge clk) begin
      if(rst) begin
         quo   <= 0;
         remo  <= 0;
         ready <= 1'b0;
      end
      else begin
         quo   <= quo_q[0] | quo_q[1] | quo_q[2] | quo_q[3];
         remo  <= remo_q[0] | remo_q[1] | remo_q[2] | remo_q[3];
         ready <= ready_q[0] | ready_q[1] | ready_q[2] | ready_q[3];
      end
   end
   
endmodule