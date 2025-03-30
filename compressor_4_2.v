`default_nettype none
module compressor_4_2(
    input  wire [31:0] a1,
    input  wire [31:0] a2,
    input  wire [31:0] a3,
    input  wire [31:0] a4,

    output wire        ovfl,
    output wire [31:0] sum1,
    output wire [31:0] sum2
);
    wire cout;
    wire [31:0] w_cout;


    assign ovfl = cout;
	assign sum2[0] = 0;
    genvar i;
    generate begin 
        for(i = 0; i < 32; i = i + 1) begin: comp_gen
            if(i == 0) begin
                compressor_4_2_cell comp(
                    .a1   (a1   [i]),
                    .a2   (a2   [i]),
                    .a3   (a3   [i]),
                    .a4   (a4   [i]),

                    .cin (0),

                    .cout(w_cout[i]),

                    .sum2(sum2[i+1]),
                    .sum1(sum1  [i])
                );
            end
            else if(i ==31) begin
                compressor_4_2_cell comp(
                    .a1   (a1   [i]),
                    .a2   (a2   [i]),
                    .a3   (a3   [i]),
                    .a4   (a4   [i]),

                    .cin (w_cout[i-1]),

                    .cout(cout),

                    .sum2(),
                    .sum1(sum1  [i])
                );
            end
            else begin
                compressor_4_2_cell comp(
                    .a1   (a1   [i]),
                    .a2   (a2   [i]),
                    .a3   (a3   [i]),
                    .a4   (a4   [i]),

                    .cin (w_cout[i-1]),

                    .cout(w_cout[i]),

                    .sum2(sum2[i+1]),
                    .sum1(sum1  [i])
                );
            end
        end
    end
    endgenerate
endmodule