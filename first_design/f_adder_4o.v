`default_nettype none
module f_adder_4o(
    input  wire [31:0] a1,
    input  wire [31:0] a2,
    input  wire [31:0] a3,
    input  wire [31:0] a4,

    output wire        ovfl,
    output wire        carry,
    output wire [31:0] sum
);

    wire [31:0] sum1;
    wire [31:0] sum2;

    compressor_4_2 comp(
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .a4(a4),

        .sum1(sum1),
        .sum2(sum2),
        .ovfl(ovfl)
    );
    f_adder_32b fa1(
        .a(sum1),
        .b(sum2),
        .sum(sum)
    );
endmodule