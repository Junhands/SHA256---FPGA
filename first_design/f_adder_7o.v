`default_nettype none
module f_adder_7o(
    input  wire [31:0] a1,
    input  wire [31:0] a2,
    input  wire [31:0] a3,
    input  wire [31:0] a4,
    input  wire [31:0] a5,
    input  wire [31:0] a6,
    input  wire [31:0] a7,

    output wire        ovfl,
    output wire        carry,
    output wire [31:0] sum
);

    wire [31:0] sum1;
    wire [31:0] sum2;

    compressor_32b(
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .a4(a4),
        .a5(a5),
        .a6(a6),
        .a7(a7),
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