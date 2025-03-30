`default_nettype none
module compression(
    input wire          clk,
    input wire          reset_n,
    input wire          init,
    input wire          ready,
    input wire          last_round,
    input wire   [31:0] W_i,
    input wire   [31:0] K_i,
    input wire  [255:0] H_init,
    output wire [255:0] digest
);
//================================================================
// H0_constants
    reg [255:0] H_init_next;
    reg [255:0] H_init_reg;
    always @* begin
        if(!ready) begin
            H_init_next <= H_init;
        end
        else begin
            H_init_next <= H_init_reg;
        end
    end
    always @ (posedge clk) begin
        H_init_reg <= H_init_next;
    end
//================================================================
    wire [31:0] A_constant = H_init_next[255:224];
    wire [31:0] B_constant = H_init_next[223:192];
    wire [31:0] C_constant = H_init_next[191:160];
    wire [31:0] D_constant = H_init_next[159:128];
    wire [31:0] E_constant = H_init_next[127: 96];
    wire [31:0] F_constant = H_init_next[95 : 64];
    wire [31:0] G_constant = H_init_next[63 : 32];
    wire [31:0] H_constant = H_init_next[31 :  0];

    wire [31:0] A0_init = H_init_reg[255:224];
    wire [31:0] B0_init = H_init_reg[223:192];
    wire [31:0] C0_init = H_init_reg[191:160];
    wire [31:0] D0_init = H_init_reg[159:128];
    wire [31:0] E0_init = H_init_reg[127:96 ];
    wire [31:0] F0_init = H_init_reg[95:64  ];
    wire [31:0] G0_init = H_init_reg[63:32  ];
    wire [31:0] H0_init = H_init_reg[31:0   ];

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

    reg [31:0] a_next;
    reg [31:0] b_next;
    reg [31:0] c_next;
    reg [31:0] d_next;
    reg [31:0] e_next;
    reg [31:0] f_next;
    reg [31:0] g_next;
    reg [31:0] h_next;

    // reg [31:0] t1;
    // reg [31:0] t2;

    always @* begin
        if(init) begin
            Sigma1 <=   {E_constant[ 5:0], E_constant[31: 6]}^
                        {E_constant[10:0], E_constant[31:11]}^
                        {E_constant[24:0], E_constant[31:25]};
            Sigma0 <=   {A_constant[ 1:0], A_constant[31: 2]}^
                        {A_constant[12:0], A_constant[31:13]}^
                        {A_constant[21:0], A_constant[31:22]};
            Maj    <=   (A_constant & B_constant)^
                        (A_constant & C_constant)^
                        (B_constant & C_constant);
            CH     <=   (E_constant & F_constant)^
                        (~E_constant & G_constant);
            temp   <=   H_constant + K_i + W_i + CH + Sigma1;
            a_next <= Sigma0 + Maj + temp;
            b_next <= A_constant;
            c_next <= B_constant;
            d_next <= C_constant;
            e_next <= D_constant + temp;
            f_next <= E_constant;
            g_next <= F_constant;
            h_next <= G_constant;
        end
        else begin
            Sigma1 <=   {e_i[ 5:0], e_i[31: 6]}^
                        {e_i[10:0], e_i[31:11]}^
                        {e_i[24:0], e_i[31:25]};
            Sigma0 <=   {a_i[ 1:0], a_i[31: 2]}^
                        {a_i[12:0], a_i[31:13]}^
                        {a_i[21:0], a_i[31:22]};
            Maj    <=   (a_i & b_i) ^ (a_i & c_i) ^ (b_i & c_i);
            CH     <=   (e_i & f_i) ^ (~e_i & g_i);
            temp   <=   h_i + K_i + W_i + CH + Sigma1;
            // t1 <= Sigma0 + Maj + temp;
            // t2 <= d_i + temp;
            if(last_round) begin
                a_next <= Sigma0 + Maj + temp  + A0_init;
                b_next <= a_i + B0_init;
                c_next <= b_i + C0_init;
                d_next <= c_i + D0_init;
                e_next <= d_i + temp  + E0_init;
                f_next <= e_i + F0_init;
                g_next <= f_i + G0_init;
                h_next <= g_i + H0_init;
            end
            else begin
                a_next <= Sigma0 + Maj + temp;
                b_next <= a_i;
                c_next <= b_i;
                d_next <= c_i;
                e_next <= d_i + temp;
                f_next <= e_i;
                g_next <= f_i;
                h_next <= g_i;
            end
        end
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
            a_i = a_next;
            b_i = b_next;
            c_i = c_next;
            d_i = d_next;
            e_i = e_next;
            f_i = f_next;
            g_i = g_next;
            h_i = h_next;
        end
    end
    assign digest = {a_i, b_i, c_i, d_i, e_i, f_i, g_i, h_i};

endmodule