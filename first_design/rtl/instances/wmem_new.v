 `default_nettype none
 module wmem_new(
    input  wire        clk,
    input  wire        reset_n,
    input  wire        ready,
    input  wire [5:0]  round_idx,
    input  wire [31:0] M_next,
    output wire [31:0] W_next
 );
    reg [31:0] W0;
    reg [31:0] W1;
    reg [31:0] W2;
    reg [31:0] W3;
    reg [31:0] W4;
    reg [31:0] W5;
    reg [31:0] W6;
    reg [31:0] W7;
    reg [31:0] W8;
    reg [31:0] W9;
    reg [31:0] W10;
    reg [31:0] W11;
    reg [31:0] W12;
    reg [31:0] W13;
    reg [31:0] W14;
    reg [31:0] W15;

    reg [31:0] W0_next;
    reg [31:0] W1_next;
    reg [31:0] W2_next;
    reg [31:0] W3_next;
    reg [31:0] W4_next;
    reg [31:0] W5_next;
    reg [31:0] W6_next;
    reg [31:0] W7_next;
    reg [31:0] W8_next;
    reg [31:0] W9_next;
    reg [31:0] W10_next;
    reg [31:0] W11_next;
    reg [31:0] W12_next;
    reg [31:0] W13_next;
    reg [31:0] W14_next;
    reg [31:0] W15_next;

    assign W_next = W_selected;

    reg [31:0] W_selected;
    reg [31:0] small_sigma_0;
    reg [31:0] small_sigma_1;


    reg [31:0] W_tmp;
    always @* begin
        small_sigma_0 <= {W14[ 6:0], W14[31: 7]}^
                    {W14[17:0], W14[31:18]}^
                    {     3'b0, W14[31: 3]};
        small_sigma_1 <= {W1[16:0], W1[31:17]}^
                            {W1[18:0], W1[31:19]}^
                            {   10'b0, W1[31:10]};
        W_tmp = small_sigma_0 + small_sigma_1 + W6+ W15;
    end

    always @* 
    begin
        if(round_idx < 16)begin
            W_selected = M_reg;
        end
        else begin
            W_selected = W_tmp;
        end
        W0_next <= W_selected;
        W1_next <= W0;
        W2_next <= W1;
        W3_next <= W2;
        W4_next <= W3;
        W5_next <= W4;
        W6_next <= W5;
        W7_next <= W6;
        W8_next <= W7;
        W9_next <= W8;
        W10_next <= W9;
        W11_next <= W10;
        W12_next <= W11;
        W13_next <= W12;
        W14_next <= W13;
        W15_next <= W14;
    end

    reg [31:0] M_reg;
    always @* begin
        if(!reset_n) begin
            M_reg <= 32'b0;
        end
        else begin
            M_reg <= M_next;
        end
    end
    always @ (posedge clk, negedge reset_n)
    begin
        if(!reset_n) begin
            W0 <= 32'b0;
            W1 <= 32'b0;
            W2 <= 32'b0;
            W3 <= 32'b0;
            W4 <= 32'b0;
            W5 <= 32'b0;
            W6 <= 32'b0;
            W7 <= 32'b0;
            W8 <= 32'b0;
            W9 <= 32'b0;
            W10 <= 32'b0;
            W11 <= 32'b0;
            W12 <= 32'b0;
            W13 <= 32'b0;
            W14 <= 32'b0;
            W15 <= 32'b0;
        end
        else if (ready) begin
            W0 <= W0_next;
            W1 <= W1_next;
            W2 <= W2_next;
            W3 <= W3_next;
            W4 <= W4_next;
            W5 <= W5_next;
            W6 <= W6_next;
            W7 <= W7_next;
            W8 <= W8_next;
            W9 <= W9_next;
            W10 <= W10_next;
            W11 <= W11_next;
            W12 <= W12_next;
            W13 <= W13_next;
            W14 <= W14_next;
            W15 <= W15_next;
        end
        else begin
            W0  <= 32'b0;
            W1  <= 32'b0;
            W2  <= 32'b0;
            W3  <= 32'b0;
            W4  <= 32'b0;
            W5  <= 32'b0;
            W6  <= 32'b0;
            W7  <= 32'b0;
            W8  <= 32'b0;
            W9  <= 32'b0;
            W10 <= 32'b0;
            W11 <= 32'b0;
            W12 <= 32'b0;
            W13 <= 32'b0;
            W14 <= 32'b0;
            W15 <= 32'b0;
        end
    end
 endmodule