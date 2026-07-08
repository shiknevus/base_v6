/////////////////////////////////////////////////////////////////
// Company:
// Engineer:      Luhui
// Creat Date:    
// Design Name:   
// Module Name:   
// Project Name:  
// Target Devices:
// Tool versions:
//                
// Dependencies:
//    
//
//Description:
//  master station rs232 components
/////////////////////////////////////////////////////////////////
module rll_change_level_aux_behavior
#(
     parameter   UIC_DROC = 1'b1
)
(
     input wire                        clk
    ,input wire                        reset
    
    ,input wire                        outstart_reg
    ,input wire                        hcqg_up
    ,input wire                        hcqg_down
    ,output wire                       extra_opt_done
);
    
    reg [1:0]   valve_mark;
    wire        valve_upflag;
    wire        valve_dnflag;
    
    assign  valve_upflag = ~hcqg_down & hcqg_up;
    assign  valve_dnflag = hcqg_down & ~hcqg_up;
    assign  extra_opt_done = (valve_upflag && valve_mark == 2'b00) ? 1'b1 :1'b0;
    
    always @(posedge clk)begin
        if(reset)begin
            valve_mark <= 2'b00;
        end else if(outstart_reg) begin
            valve_mark <= 2'b11;
        end else if((valve_dnflag & UIC_DROC == 1'b1) || (valve_upflag & UIC_DROC == 1'b0)) begin
            valve_mark <= 2'b01;
        end else if(valve_mark == 2'b01 && ((valve_upflag & UIC_DROC == 1'b1) || (valve_dnflag & UIC_DROC == 1'b0))) begin
            valve_mark <= 2'b00; 
        end else begin
            valve_mark <= valve_mark;
        end
    end

endmodule