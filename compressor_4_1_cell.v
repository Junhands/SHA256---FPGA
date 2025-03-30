`default_nettype none
module compressor_4_2_cell(
    input wire a1,
    input wire a2,
    input wire a3,
    input wire a4,

    input wire cin,


    output wire cout,
    output wire sum1,
    output wire sum2
);
    wire w1;
    CSA fa1(
        .a(a4),
        .b(a3),
        .cin(a2),
        .cout(cout),
        .sum(w1)
    );
    CSA fa1(
        .a(w1),
        .b(a1),
        .cin(cin),
        .cout(sum2),
        .sum(sum1)
    );
endmodule