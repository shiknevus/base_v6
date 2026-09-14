/////////////////////////// MODULE //////////////////////////////
module Move_fa_std
(
    input                   clk
   ,input                   reset
   
   ,input  wire             i_drv_son
   ,input  wire [31:0]      i_pf_spd
   ,input  wire [31:0]      i_pf_acc
   ,input  wire [31:0]      i_pf_dec
   ,input  wire [31:0]      i_pf_pulse
   ,input  wire             i_lim_f
   ,input  wire             i_lim_b
   ,input  wire             i_org
   ,input  wire [31:0]      i_abspos
   ,input  wire             i_start
   ,input  wire             i_stop
   ,output reg              o_busy
   ,output reg              o_done
   ,output reg              o_error
   
   ,output wire [31:0]      o_pf_spd
   ,output wire [31:0]      o_pf_acc
   ,output wire [31:0]      o_pf_dec
   ,output wire [31:0]      o_pf_pulse
   ,output wire             o_pf_dir
   ,output wire             o_pf_start
   ,output wire             o_pf_stop
   ,output wire             o_pf_quickstop
   ,input  wire             i_pf_busy
   ,input  wire             i_pf_done
);

   //////////////////////// DEFINE ////////////
   localparam DIR_POS  	        = 1'b1;
   localparam DIR_NEG           = 1'b0;
   localparam ST_MOVE_IDLE      = 0;
   localparam ST_MOVE_START     = 1;
   localparam ST_MOVE_ERROR     = 2;
   localparam ST_MOVE_DONE      = 3;
   localparam ST_MOVE_END       = 4;
   ///////////////// PARAMETER ////////////////
   reg [4:0]   fsm_st;
   reg         r_pf_start;
   reg         r_pf_stop;
   reg         r_pf_quickstop;
   reg         r_st_error;
   reg [31:0]  r_pf_pulse;
   reg         r_pf_dir;
   
   wire motion_fault = (i_lim_f & r_pf_dir==DIR_POS) | (i_lim_b & r_pf_dir==DIR_NEG) | ~i_drv_son;

   always@(posedge clk) begin
       if(fsm_st==ST_MOVE_IDLE) begin
    	   o_busy <= 1'b0;
    	   o_done <= 1'b0;
       end else if(fsm_st==ST_MOVE_END) begin
           o_busy <= 1'b0;
           o_done <= 1'b1;
       end else begin
           o_busy <= 1'b1;
           o_done <= 1'b0;
       end
   end
   
   always@(posedge clk) begin
        if(reset | fsm_st==ST_MOVE_IDLE) begin
            o_error <= 1'b0;
        end else if(fsm_st==ST_MOVE_ERROR) begin
            o_error <= 1'b1;
        end
    end
   
   always@(posedge clk) begin
       if(reset) begin
           fsm_st         <= ST_MOVE_IDLE;
           r_st_error     <= 1'b0;
           r_pf_start     <= 1'b0;
           r_pf_stop      <= 1'b0;
           r_pf_quickstop <= 1'b0;
           r_pf_dir   <= 1'b0;
           r_pf_pulse <= 'd0;
       end else begin
           case(fsm_st)
               ST_MOVE_IDLE: begin
                    r_pf_start <= 1'b0;
                    r_pf_stop  <= 1'b0;
                    r_pf_quickstop <= 1'b0;
                    r_st_error <= 1'b0;
                    if(i_start) begin
                       r_pf_dir   <= $signed(i_pf_pulse) > $signed(i_abspos) ?  DIR_POS : DIR_NEG;
                       r_pf_pulse <= $signed(i_pf_pulse) > $signed(i_abspos) ? (i_pf_pulse-i_abspos) : (i_abspos-i_pf_pulse);
                       if((~i_lim_f& i_lim_b& i_org)|( i_lim_f&~i_lim_b& i_org)|
                           ( i_lim_f& i_lim_b&~i_org)|( i_lim_f& i_lim_b& i_org)|
                           ( i_lim_f& ($signed(i_pf_pulse) > $signed(i_abspos)))|
                           ( i_lim_b& ($signed(i_pf_pulse) < $signed(i_abspos))) ) begin
                           fsm_st <= ST_MOVE_ERROR;
                       end else begin
                           fsm_st <= (i_pf_pulse==i_abspos) ? ST_MOVE_DONE : ST_MOVE_START;
                       end
                   end
               end
               ST_MOVE_START: begin
                   // r_st_error latched until done, change by szzhang 20260913
                   r_pf_start <= ~i_pf_busy;
                   if(i_pf_busy) begin
                       if(motion_fault) begin
                           r_pf_quickstop  <= 1'b1;
                           r_st_error <= 1'b1;
                       end else if(i_stop) begin
                           r_pf_stop <= 1'b1;
                       end
                       if(i_pf_done) begin
                           fsm_st <= (r_st_error | motion_fault) ? ST_MOVE_ERROR : ST_MOVE_DONE;//change by szzhang 20260813
                       end    
                   end
               end
               ST_MOVE_ERROR: begin
                   r_st_error     <= 1'b1;
                   r_pf_start     <= 1'b0;
                   r_pf_stop      <= 1'b0;
                   r_pf_quickstop <= 1'b0;
                   fsm_st <= ST_MOVE_DONE;
               end
               ST_MOVE_DONE: begin
                   r_pf_start     <= 1'b0;
                   r_pf_stop      <= 1'b0;
                   r_pf_quickstop <= 1'b0;
                   fsm_st <= ST_MOVE_END;
               end
               ST_MOVE_END: begin
                   fsm_st <= ST_MOVE_IDLE;
               end
           endcase
       end
   end
   
   assign o_pf_start     = r_pf_start;
   assign o_pf_stop      = r_pf_stop ; 
   assign o_pf_spd       = i_pf_spd  ;
   assign o_pf_acc       = i_pf_acc  ;
   assign o_pf_dec       = i_pf_dec  ;
   assign o_pf_pulse     = r_pf_pulse;
   assign o_pf_dir       = r_pf_dir  ;
   assign o_pf_quickstop = r_pf_quickstop;
      
endmodule