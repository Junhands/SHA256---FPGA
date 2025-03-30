`default_nettype none
module compressor_32b(
    input  wire [31:0] a1,
    input  wire [31:0] a2,
    input  wire [31:0] a3,
    input  wire [31:0] a4,
    input  wire [31:0] a5,
    input  wire [31:0] a6,
    input  wire [31:0] a7,

    output wire        ovfl,
    output wire [31:0] sum1,
    output wire [31:0] sum2
);
    wire cout1, cout2, cout3, cout4;
    wire [31:0] w_cout1;
    wire [31:0] w_cout2;
    wire [31:0] w_cout3;
    wire [31:0] w_cout4;

    assign ovfl = cout1 | cout2 | cout3 | cout4;
	assign sum2[0] = 0;
    genvar i;
    generate begin 
        for(i = 0; i < 32; i = i + 1) begin: comp_gen
            if(i == 0) begin
                compressor comp(
                    .a1   (a1   [i]),
                    .a2   (a2   [i]),
                    .a3   (a3   [i]),
                    .a4   (a4   [i]),
                    .a5   (a5   [i]),
                    .a6   (a6   [i]),
                    .a7   (a7   [i]),
                    .cin1 (0),
                    .cin2 (0),
                    .cin3 (0),
                    .cin4 (0),
                    .cout1(w_cout1[i]),
                    .cout2(w_cout2[i]),
                    .cout3(w_cout3[i]),
                    .cout4(w_cout4[i]),
                    .sum2(sum2[i+1]),
                    .sum1(sum1  [i])
                );
            end
            else if(i ==31) begin
                compressor comp(
                    .a1   (a1   [i]),
                    .a2   (a2   [i]),
                    .a3   (a3   [i]),
                    .a4   (a4   [i]),
                    .a5   (a5   [i]),
                    .a6   (a6   [i]),
                    .a7   (a7   [i]),
                    .cin1 (w_cout1[i-1]),
                    .cin2 (w_cout2[i-1]),
                    .cin3 (w_cout3[i-1]),
                    .cin4 (w_cout4[i-1]),
                    .cout1(cout1),
                    .cout2(cout2),
                    .cout3(cout3),
                    .cout4(cout4),
                    .sum2(),
                    .sum1(sum1  [i])
                );
            end
            else begin
                compressor comp(
                    .a1   (a1   [i]),
                    .a2   (a2   [i]),
                    .a3   (a3   [i]),
                    .a4   (a4   [i]),
                    .a5   (a5   [i]),
                    .a6   (a6   [i]),
                    .a7   (a7   [i]),
                    .cin1 (w_cout1[i-1]),
                    .cin2 (w_cout2[i-1]),
                    .cin3 (w_cout3[i-1]),
                    .cin4 (w_cout4[i-1]),
                    .cout1(w_cout1[i]),
                    .cout2(w_cout2[i]),
                    .cout3(w_cout3[i]),
                    .cout4(w_cout4[i]),
                    .sum2(sum2[i+1]),
                    .sum1(sum1  [i])
                );
            end
        end
    end
    endgenerate
endmodule