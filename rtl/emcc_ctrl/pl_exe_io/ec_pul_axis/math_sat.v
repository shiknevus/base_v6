/////////////////////////// MODULE //////////////////////////////
module math_sat(in_acc,out_acc,out_saturated);

    parameter nbit_in=32;
    parameter nbit_out=31;
    parameter signed_data=1; // retain signed behavior unless explicitly disabled

    input  [nbit_in-1:0]     in_acc;
    output [nbit_out-1:0]    out_acc;
    output                   out_saturated;

    wire                     pos_over;
    wire                     neg_over;
    wire [nbit_out-1:0]       resized;

    generate // overflow flags + neg sat + nbit guard, change by szzhang 20260913
        if(nbit_in > nbit_out) begin : sat_on
            assign pos_over = signed_data
                            ? ~in_acc[nbit_in-1]&(|in_acc[nbit_in-2:nbit_out-1])
                            : |in_acc[nbit_in-1:nbit_out];
            assign neg_over = signed_data
                            ? in_acc[nbit_in-1]&~(&in_acc[nbit_in-2:nbit_out-1])
                            : 1'b0;
            assign resized = in_acc[nbit_out-1:0];
        end else begin : sat_off
            assign pos_over = 1'b0;
            assign neg_over = 1'b0;
            assign resized = {{(nbit_out-nbit_in){signed_data && in_acc[nbit_in-1]}},in_acc};
        end
    endgenerate

    reg    [nbit_out-1:0]    out_acc;
    reg                      out_saturated;

    always@* begin
        if(pos_over) begin
            out_acc=signed_data ? {1'h0,{nbit_out-1{1'h1}}} : {nbit_out{1'b1}};
            out_saturated=1'b1;
        end else if(neg_over) begin // clamp min negative, change by szzhang 20260913
            out_acc={1'h1,{nbit_out-1{1'b0}}};
            out_saturated=1'b1;
        end else begin
            out_acc=resized;
            out_saturated=1'b0;
        end
    end

endmodule