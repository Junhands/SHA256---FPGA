`default_nettype none
module compression(
    input wire          clk,
    input wire          reset_n,
    input wire          init,
    input wire          ready,
    input wire          digest_update,
    input wire          done,
    input wire   [31:0] W_i,
    input wire   [31:0] K_i,
    output wire [255:0] digest
);
//================================================================
// Khởi tạo & cập nhật H0
//================================================================
    localparam H_0 = 32'h6a09e667;
    localparam H_1 = 32'hbb67ae85;
    localparam H_2 = 32'h3c6ef372;
    localparam H_3 = 32'ha54ff53a;
    localparam H_4 = 32'h510e527f;
    localparam H_5 = 32'h9b05688c;
    localparam H_6 = 32'h1f83d9ab;
    localparam H_7 = 32'h5be0cd19;

    reg [31:0] H0_init_reg;
    reg [31:0] H1_init_reg;
    reg [31:0] H2_init_reg;
    reg [31:0] H3_init_reg;
    reg [31:0] H4_init_reg;
    reg [31:0] H5_init_reg;
    reg [31:0] H6_init_reg;
    reg [31:0] H7_init_reg;

    always @ (posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            H0_init_reg <= 32'h0;
            H1_init_reg <= 32'h0;
            H2_init_reg <= 32'h0;
            H3_init_reg <= 32'h0;
            H4_init_reg <= 32'h0;
            H5_init_reg <= 32'h0;
            H6_init_reg <= 32'h0;
            H7_init_reg <= 32'h0;
        end
        else begin
            if(init) begin // Khởi tạo giá trị hằng số H0
                H0_init_reg <= H_0;
                H1_init_reg <= H_1;
                H2_init_reg <= H_2;
                H3_init_reg <= H_3;
                H4_init_reg <= H_4;
                H5_init_reg <= H_5;
                H6_init_reg <= H_6;
                H7_init_reg <= H_7;
            end
            if(digest_update) begin // cập nhật H0 cho trường hợp message được chia làm nhiều block
                H0_init_reg <= H0_init_reg + a_i;
                H1_init_reg <= H1_init_reg + b_i;
                H2_init_reg <= H2_init_reg + c_i;
                H3_init_reg <= H3_init_reg + d_i;
                H4_init_reg <= H4_init_reg + e_i;
                H5_init_reg <= H5_init_reg + f_i;
                H6_init_reg <= H6_init_reg + g_i;
                H7_init_reg <= H7_init_reg + h_i;
            end
        end
    end
//================================================================
// Thực hiện hàm băm SHA256
//================================================================
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

    always @* begin
        Sigma1 =    {e_i[ 5:0], e_i[31: 6]}^
                    {e_i[10:0], e_i[31:11]}^
                    {e_i[24:0], e_i[31:25]};
        Sigma0 =    {a_i[ 1:0], a_i[31: 2]}^
                    {a_i[12:0], a_i[31:13]}^
                    {a_i[21:0], a_i[31:22]};
        Maj    =    (a_i & b_i) ^ (a_i & c_i) ^ (b_i & c_i);
        CH     =    (e_i & f_i) ^ (~e_i & g_i);
        temp   =     h_i + K_i + W_i + CH + Sigma1;
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
            if(init) begin // khởi tạo lại giá trị ban đầu để thực hiện hàm băm kế tiếp (1 duty cycle)
                a_i <= H_0;
                b_i <= H_1;
                c_i <= H_2;
                d_i <= H_3;
                e_i <= H_4;
                f_i <= H_5;
                g_i <= H_6;
                h_i <= H_7;
            end
            if(digest_update) begin // thực hiện sau round cuối, cộng digest với H0 (1 duty cycle)
                a_i <= H0_init_reg + a_i;
                b_i <= H1_init_reg + b_i;
                c_i <= H2_init_reg + c_i;
                d_i <= H3_init_reg + d_i;
                e_i <= H4_init_reg + e_i;
                f_i <= H5_init_reg + f_i;
                g_i <= H6_init_reg + g_i;
                h_i <= H7_init_reg + h_i;
            end
            if(ready) begin // thực hiện hàm băm SHA256 (64 duty cycle)
                a_i <= Sigma0 + Maj + temp;
                b_i <= a_i;
                c_i <= b_i;
                d_i <= c_i;
                e_i <= d_i + temp;
                f_i <= e_i;
                g_i <= f_i;
                h_i <= g_i;
            end
        end
    end
    assign digest = (done) ? {a_i, b_i, c_i, d_i, e_i, f_i, g_i, h_i} : 256'h0;

endmodule