`default_nettype none
module f_adder_32b(
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] sum
);
    wire [30:0] w;
    genvar i;
    generate begin
        for(i = 0; i < 32; i = i + 1) begin
            if(i == 0) begin
                CSA fa(
                    .a(a[i]),
                    .b(b[i]),
                    .cin(0),
                    .sum(sum[i]),
                    .cout(w[i])
                );
            end
            else if(i == 31) begin
                CSA fa(
                    .a  (a[i]),
                    .b  (b[i]),
                    .cin(w[i-1]),
                    .sum(sum[i]),
                    .cout()
                );
            end
            else begin
                CSA fa(
                    .a  (a[i]),
                    .b  (b[i]),
                    .cin(w[i-1]),
                    .sum(sum[i]),
                    .cout(w[i])
                );
            end
        end
    end
    endgenerate
endmodule