/////////////////////////// MODULE //////////////////////////////
module math_sat(in_acc,out_acc,out_saturated);

    parameter nbit_in=32;
    parameter nbit_out=31;

    input  [nbit_in-1:0]     in_acc;
    output [nbit_out-1:0]    out_acc;
    output                   out_saturated;

    reg    [nbit_out-1:0]    out_acc;
    reg                      out_saturated;

    always@* begin
        if(~in_acc[nbit_in-1]&(|in_acc[nbit_in-2:nbit_out-1])) begin
            out_acc={1'h0,{nbit_out-1{1'h1}}};
            out_saturated=1'b1;
        end else begin
            out_acc=in_acc[nbit_out-1:0];
            out_saturated=1'b0;
        end
    end

endmodule