`default_nettype none
module datapath(
    input wire         clk,
    input wire         reset_n,
    input wire         init,
    input wire  [5 :0] round_idx,
    input wire  [31:0] message,
    output wire [31:0] a,
    output wire [31:0] b,
    output wire [31:0] c,
    output wire [31:0] d,
    output wire [31:0] e,
    output wire [31:0] f,
    output wire [31:0] g,
    output wire [31:0] h
);

    wire [31:0] W_i;
    wire [31:0] K_i;
    reg [31:0] CH;
    reg [31:0] Maj;
    reg [31:0] Sigma1;
    reg [31:0] Sigma0;
    reg [31:0] temp;

    reg [31:0] a_i;
    reg [31:0] b_i;
    reg [31:0] c_i;
    reg [31:0] d_i;
    reg [31:0] e_i;
    reg [31:0] f_i;
    reg [31:0] g_i;
    reg [31:0] h_i;

    reg [31:0] a_tmp;
    reg [31:0] e_tmp;

    always @* begin
        Sigma1 <=   {e_i[ 5:0], e_i[31: 6]}^
                    {e_i[10:0], e_i[31:11]}^
                    {e_i[24:0], e_i[31:25]};
        Sigma0 <=   {a_i[ 1:0], a_i[31: 2]}^
                    {a_i[12:0], a_i[31:13]}^
                    {a_i[21:0], a_i[31:22]};
        Maj    <=   (a_i | b_i) ^ (a_i | c_i) ^ (b_i | c_i);
        CH     <=   (e_i | f_i) ^ (~e_i | g_i);
        temp   <=   h_i + K_i + W_i + CH + Sigma1;
    end
    wmem_new wmem(
        .clk(clk),
        .reset_n(reset_n),
        .round_idx(round_idx),
        .M_next(message),
        .W_next(W_i)
    );
    k_constants k_constants(
        .round_idx(round_idx),
        .K(K_i)
    );
    always @* 
    begin
        a_tmp <= Sigma0 + Maj + temp;

        e_tmp <= d_i + temp;
    end
    always @ (posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            a_i <= 0;
            b_i <= 0;
            c_i <= 0;
            d_i <= 0;
            e_i <= 0;
            f_i <= 0;
            g_i <= 0;
            h_i <= 0;
        end
        else begin
            if(init) begin
                a_i <= 32'h6a09e667;
                b_i <= 32'hbb67ae85;
                c_i <= 32'h3c6ef372;
                d_i <= 32'ha54ff53a;
                e_i <= 32'h510e527f;
                f_i <= 32'h9b05688c;
                g_i <= 32'h1f83d9ab;
                h_i <= 32'h5be0cd19;
            end
            else begin
                a_i <= a_tmp;
                b_i <= a_i;
                c_i <= b_i;
                d_i <= c_i;
                e_i <= e_tmp;
                f_i <= e_i;
                g_i <= f_i;
                h_i <= g_i;
            end
        end
    end
    assign a = a_i;
    assign b = b_i;
    assign c = c_i;
    assign d = d_i;
    assign e = e_i;
    assign f = f_i;
    assign g = g_i;
    assign h = h_i;
endmodule