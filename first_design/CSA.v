`default_nettype none
module CSA(
    input wire a,
    input wire b,
    input wire cin,
    output wire sum,
    output wire cout
);
    wire w1;
    assign w1 = a ^ b;
    assign sum = w1 ^ cin;
    assign cout = (cin & w1) | (a & b);
endmodule