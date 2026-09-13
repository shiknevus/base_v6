/////////////////////////// MODULE //////////////////////////////
module math_reduce(in_acc,out_acc);

    parameter nbit_in=32;
    parameter nbit_out=16;

    input  [nbit_in-1:0]     in_acc;
    output [nbit_out-1:0]    out_acc;

    wire [nbit_out:0]        red_sum;

    generate // carry sat + nbit guard, change by szzhang 20260913
        if(nbit_in > nbit_out) begin : red_on
            assign red_sum = {1'b0,in_acc[nbit_in-1:nbit_in-nbit_out]} + in_acc[nbit_in-nbit_out-1];
        end else begin : red_off
            assign red_sum = {1'b0,in_acc};
        end
    endgenerate

    reg    [nbit_out-1:0]    out_acc;

    always@* begin
        if(red_sum[nbit_out])
            out_acc = {nbit_out{1'b1}}; // round carry sat, change by szzhang 20260913
        else
            out_acc = red_sum[nbit_out-1:0];
    end

endmodule