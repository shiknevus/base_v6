/////////////////////////// MODULE //////////////////////////////
module math_reduce(in_acc,out_acc);

    parameter nbit_in=32;
    parameter nbit_out=16;

    input  [nbit_in-1:0]     in_acc;
    output [nbit_out-1:0]    out_acc;

    reg    [nbit_out-1:0]    out_acc;

    always@* begin
        out_acc = in_acc[nbit_in-1:nbit_in-nbit_out] + in_acc[nbit_in-nbit_out-1];
    end

endmodule