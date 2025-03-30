`default_nettype none
module compressor(
    input wire a1,
    input wire a2,
    input wire a3,
    input wire a4,
    input wire a5,
    input wire a6,
    input wire a7,
    input wire cin1,
    input wire cin2,
    input wire cin3,
    input wire cin4,

    output wire cout1,
    output wire cout2,
    output wire cout3,
    output wire cout4,
    output wire sum1,
    output wire sum2
);
    wire w1, w2, w3, w4;
    CSA fa1(
        .a(a7),
        .b(a6),
        .cin(a5),
        .cout(cout1),
        .sum(w1)
    );
    CSA fa2(
        .a(a4),
        .b(a3),
        .cin(a2),
        .cout(cout2),
        .sum(w2)
    );
    CSA fa3(
        .a(a1),
        .b(w1),
        .cin(w2),
        .cout(cout3),
        .sum(w3)
    );
    CSA fa4(
        .a(cin1),
        .b(cin2),
        .cin(w3),
        .cout(cout4),
        .sum(w4)
    );
    CSA fa5(
        .a(w4),
        .b(cin3),
        .cin(cin4),
        .cout(sum2),
        .sum(sum1)
    );
endmodule