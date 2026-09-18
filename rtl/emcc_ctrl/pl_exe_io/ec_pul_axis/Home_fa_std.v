/////////////////////////// MODULE //////////////////////////////
module Home_fa_std
(
    input                   clk
   ,input                   reset
   
   ,input  wire             i_drv_son
   ,input  wire [31:0]      i_pf_spd
   ,input  wire [31:0]      i_pf_acc
   ,input  wire [31:0]      i_pf_dec
   ,input  wire             i_pf_dir
   ,input  wire             i_lim_f
   ,input  wire             i_lim_b
   ,input  wire             i_org
   ,input  wire             i_start
   ,input  wire             i_stop
   ,output reg              o_busy
   ,output reg              o_done
   ,output reg              o_error
   
   ,output reg [31:0]       o_pf_spd
   ,output reg [31:0]       o_pf_acc
   ,output reg [31:0]       o_pf_dec
   ,output reg [31:0]       o_pf_pulse
   ,output reg              o_pf_dir
   ,output reg              o_pf_start
   ,output reg              o_pf_stop
   ,output reg              o_pf_quickstop
   ,output wire             o_pf_touchstop //add by szzhang 20260916
   ,input  wire             i_pf_busy
   ,input  wire             i_pf_done
   ,input  wire [31:0]      i_spd_min
);




   //////////////////////// DEFINE ////////////
   localparam P_SPD_MIN        = 32'd5000;
   localparam DIR_POS  	       = 1'b1;
   localparam DIR_NEG          = 1'b0;
   localparam ST_HOME_IDLE     = 0;
   localparam ST_HOME_FACC     = 1;
   localparam ST_HOME_FDEC     = 2;
   localparam ST_HOME_BACC     = 3;
   localparam ST_HOME_BDEC     = 4;
   localparam ST_HOME_FMIN     = 5;
   localparam ST_HOME_BMIN     = 6;
   localparam ST_HOME_STOP     = 7;
   localparam ST_HOME_END      = 8;
   localparam ST_HOME_FINISH   = 9;
   ///////////////// PARAMETER ////////////////
   reg [4:0]   fsm_st;
   reg         r_pf_status_lim_f;
   reg         r_pf_status_lim_b;
   reg         r_pf_status_org;
   reg         r_st_error;
   reg         r_lim_f;
   reg         r_lim_b;
   reg         r_org;
   wire        posedge_lim_f = i_lim_f&~r_lim_f;
   wire        negedge_lim_f =~i_lim_f& r_lim_f;
   wire        posedge_lim_b = i_lim_b&~r_lim_b;
   wire        negedge_lim_b =~i_lim_b& r_lim_b;
   wire        posedge_org   = i_org & ~r_org;
   wire        negedge_org   = ~i_org & r_org;

   assign o_pf_touchstop = o_pf_quickstop & r_pf_status_org; //add by szzhang 20260916

   always@(posedge clk) begin
       if(reset) begin
           r_lim_f <= 1'b0;
           r_lim_b <= 1'b0;
           r_org   <= 1'b0;
       end else begin
           r_lim_f <= i_lim_f;
           r_lim_b <= i_lim_b;
           r_org   <= i_org;
       end
   end

   always@(posedge clk) begin
       if(fsm_st==ST_HOME_IDLE) begin
    	   o_busy <= 1'b0;
    	   o_done <= 1'b0;
       end else if(fsm_st==ST_HOME_END) begin
           o_busy <= 1'b0;
           o_done <= 1'b1;
       end else begin
           o_busy <= 1'b1;
           o_done <= 1'b0;
       end
   end
   
   always@(posedge clk) begin
        if(reset | fsm_st==ST_HOME_IDLE) begin
            o_error <= 1'b0;
        end else if(fsm_st==ST_HOME_STOP) begin
            o_error <= 1'b1;
        end
    end

   // add by szzhang 20260917
   reg        r_done_lock;
   reg        r_had_busy;
   always@(posedge clk) begin
       if(reset | ((fsm_st!=ST_HOME_FDEC) && (fsm_st!=ST_HOME_BDEC))) begin
           r_done_lock <= 1'b0;
           r_had_busy  <= 1'b0;
       end else begin
           r_done_lock <= r_done_lock | (i_pf_done & i_pf_busy);
           r_had_busy  <= r_had_busy  | i_pf_busy; // pos really ran this segment
       end
   end

   always@(posedge clk) begin
       if(reset) begin
           fsm_st            <= ST_HOME_IDLE;
           o_pf_start        <= 1'b0;
           o_pf_stop         <= 1'b0;
           o_pf_quickstop    <= 1'b0;
           r_st_error        <= 1'b0;
           r_pf_status_lim_f <= 1'b0;
           r_pf_status_lim_b <= 1'b0;
           r_pf_status_org   <= 1'b0;
       end else begin
           case(fsm_st)
               ST_HOME_IDLE: begin
                   r_pf_status_lim_f <= 1'b0;
                   r_pf_status_lim_b <= 1'b0;
                   r_pf_status_org <= 1'b0;
                   o_pf_start <= 1'b0;
                   o_pf_stop  <= 1'b0;
                   o_pf_quickstop <= 1'b0;
                   r_st_error  <= 1'b0;
                   if(i_start) begin
                       fsm_st <= i_pf_dir==DIR_POS ? ST_HOME_FACC : ST_HOME_BACC;
                   end
               end
               ST_HOME_FACC: begin
                   o_pf_start <= ~i_pf_busy;
                   o_pf_stop  <= 1'b0;
                   o_pf_quickstop <= 1'b0;
                   if(i_stop | ~i_drv_son) begin
                       o_pf_stop  <= 1'b1;
                       r_st_error <= 1'b0;
                       fsm_st <= ST_HOME_STOP;
                   end else if(i_org) begin
                       fsm_st <= ST_HOME_FDEC;
                       r_pf_status_org <= 1'b1;
                   end else if(i_lim_f) begin
                       fsm_st <= ST_HOME_FDEC;
                       r_pf_status_lim_f <= 1'b1;
                       r_st_error <= r_st_error | r_pf_status_lim_b; // accumulate, by szzhang 20260917
                   end
                   
               end
               ST_HOME_FDEC: begin
                   o_pf_start <= 1'b0;
                   o_pf_stop  <= 1'b0;
                   o_pf_quickstop <= 1'b1;
                   if(r_pf_status_org&negedge_org) begin
                       r_st_error <= 1'b1;
                   end 
                   if(i_stop | ~i_drv_son) begin
                       o_pf_stop  <= 1'b1;
                       r_st_error <= 1'b0;
                       fsm_st <= ST_HOME_STOP;
                   end else if(r_done_lock | (~i_pf_busy & r_had_busy)) begin // r_had_busy: never trust idle pos before it ran. by szzhang 20260917
                       if(r_pf_status_org)
                           fsm_st <= (r_st_error | (r_pf_status_org & ~i_org)) ? ST_HOME_STOP : ST_HOME_FMIN; //change by szzhang 20260916
                       else 
                           fsm_st <= r_st_error ? ST_HOME_STOP : ST_HOME_BACC;
                   end
               end
               ST_HOME_BACC: begin
                   o_pf_start <= ~i_pf_busy;
                   o_pf_stop  <= 1'b0;
                   o_pf_quickstop <= 1'b0;
                   if(i_stop | ~i_drv_son) begin
                       o_pf_stop  <= 1'b1;
                       r_st_error <= 1'b0;
                       fsm_st <= ST_HOME_STOP;
                   end else if(i_org)begin
                       fsm_st <= ST_HOME_BDEC;
                       r_pf_status_org <= 1'b1;
                   end else if(i_lim_b) begin
                       fsm_st <= ST_HOME_BDEC;
                       r_pf_status_lim_b <= 1'b1;
                       r_st_error <= r_st_error | r_pf_status_lim_f; // accumulate, by szzhang 20260917
                   end
               end
               ST_HOME_BDEC: begin
                   o_pf_start <= 1'b0;
                   o_pf_stop  <= 1'b0;
                   o_pf_quickstop <= 1'b1;
                   if(r_pf_status_org & negedge_org) begin
                       r_st_error <= 1'b1;
                   end
                   if(i_stop | ~i_drv_son) begin
                       o_pf_stop  <= 1'b1;
                       r_st_error <= 1'b0;
                       fsm_st <= ST_HOME_STOP;   
                   end else if(r_done_lock | (~i_pf_busy & r_had_busy)) begin // r_had_busy: never trust idle pos before it ran. by szzhang 20260917
                       if(r_pf_status_org)
                           fsm_st <= (r_st_error | (r_pf_status_org & ~i_org)) ? ST_HOME_STOP : ST_HOME_FMIN;
                       else
                           fsm_st <= r_st_error ? ST_HOME_STOP : ST_HOME_FACC;
                   end
               end
               ST_HOME_FMIN: begin
                   o_pf_start <= ~i_pf_busy;
                   o_pf_stop <= 1'b0;
                   o_pf_quickstop <= 1'b0;
                   if(i_stop | ~i_drv_son | i_lim_f) begin // add lim guard by szzhang 20260917
                       o_pf_stop  <= 1'b1;
                       r_st_error <= 1'b0;
                       fsm_st <= ST_HOME_STOP;
                   end else if(~i_org & i_pf_busy) begin
                       fsm_st <= ST_HOME_FINISH;
                       o_pf_stop <= 1'b1;
                   end
               end
               ST_HOME_BMIN: begin
                   o_pf_start <= ~i_pf_busy;
                   o_pf_stop  <= 1'b0;
                   o_pf_quickstop <= 1'b0;
                   if(i_stop | ~i_drv_son | i_lim_b) begin // add lim guard by szzhang 20260917
                       o_pf_stop  <= 1'b1;
                       r_st_error <= 1'b0;
                       fsm_st <= ST_HOME_STOP;
                   end else if(~i_org & i_pf_busy) begin
                       fsm_st <= ST_HOME_FINISH;
                       o_pf_stop <= 1'b1;
                   end
               end
               ST_HOME_STOP: begin
                   r_st_error <= 1'b1;
                   o_pf_start <= 1'b0;
                   o_pf_stop  <= 1'b1; // hold until positioner idle, change by szzhang 20260913
                   o_pf_quickstop <= 1'b0;
                   if(~i_pf_busy) begin
                      o_pf_stop <= 1'b0;
                      fsm_st <= ST_HOME_END;
                   end
               end
               ST_HOME_FINISH: begin
                   // Successful homing also waits for physical pulse completion.
                   o_pf_start <= 1'b0;
                   o_pf_stop <= 1'b1;
                   o_pf_quickstop <= 1'b0;
                   if(~i_pf_busy) begin
                       o_pf_stop <= 1'b0;
                       fsm_st <= ST_HOME_END;
                   end
               end
               ST_HOME_END: begin
                   fsm_st <= ST_HOME_IDLE;
               end
           endcase
       end
   end
   
   ////////////////// Pulse generator
   always@* begin
       if(reset) begin
           o_pf_spd   <= 0;
           o_pf_acc   <= 0;
           o_pf_dec   <= 0;
           o_pf_pulse <= 0;
           o_pf_dir   <= 1'b0;
       end else begin
           case(fsm_st)
               ST_HOME_IDLE: begin
                   o_pf_spd   <= 0;
                   o_pf_acc   <= 0;
                   o_pf_dec   <= 0;
                   o_pf_pulse <= 0;
                   o_pf_dir   <= 1'b0;
               end
               ST_HOME_FACC: begin
                   o_pf_spd   <= i_pf_spd;
                   o_pf_acc   <= i_pf_acc;
                   o_pf_dec   <= i_pf_dec;
                   o_pf_pulse <= 32'h7FFFFFFF;
                   o_pf_dir   <= DIR_POS;
               end
               ST_HOME_FDEC: begin
                   o_pf_spd   <= i_pf_spd;
                   o_pf_acc   <= i_pf_acc;
                   o_pf_dec   <= i_pf_dec;
                   o_pf_pulse <= 32'h7FFFFFFF;
                   o_pf_dir   <= DIR_POS;
               end
               ST_HOME_BACC: begin
                   o_pf_spd   <= i_pf_spd;
                   o_pf_acc   <= i_pf_acc;
                   o_pf_dec   <= i_pf_dec;
                   o_pf_pulse <= 32'h7FFFFFFF;
                   o_pf_dir   <= DIR_NEG;
               end
               ST_HOME_BDEC: begin
                   o_pf_spd   <= i_pf_spd;
                   o_pf_acc   <= i_pf_acc;
                   o_pf_dec   <= i_pf_dec;
                   o_pf_pulse <= 32'h7FFFFFFF;
                   o_pf_dir   <= DIR_NEG;
               end
               ST_HOME_FMIN: begin
                   o_pf_spd   <= i_spd_min;
                   o_pf_acc   <= i_pf_acc;
                   o_pf_dec   <= i_pf_dec;
                   o_pf_pulse <= 32'h7FFFFFFF;
                   o_pf_dir   <= DIR_POS;
               end
               ST_HOME_BMIN: begin
                   o_pf_spd   <= i_spd_min;
                   o_pf_acc   <= i_pf_acc;
                   o_pf_dec   <= i_pf_dec;
                   o_pf_pulse <= 32'h7FFFFFFF;
                   o_pf_dir   <= DIR_NEG;
               end
               ST_HOME_STOP: begin
                   o_pf_spd   <= 0;
                   o_pf_acc   <= 0;
                   o_pf_dec   <= 0;
                   o_pf_pulse <= 0;
                   o_pf_dir   <= 1'b0;
               end
               default: begin
                   o_pf_spd   <= 0;
                   o_pf_acc   <= 0;
                   o_pf_dec   <= 0;
                   o_pf_pulse <= 0;
                   o_pf_dir   <= 1'b0;
               end
           endcase
       end
   end
      
endmodule