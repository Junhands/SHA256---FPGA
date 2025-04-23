 `default_nettype none
 module wmem_new(
    input  wire        clk,
    input  wire        reset_n,
    input  wire        init,
    input  wire        ready,
    input  wire        digest_update,
    input  wire [5:0]  round_idx,
    input  wire [511:0] block,
    output wire [31:0] W_next
 );


    reg [31:0] small_sigma_0;
    reg [31:0] small_sigma_1;

    reg [31:0]  W0, W1, W2,  W3,  W4,  W5,  W6,  W7,
                W8, W9, W10, W11, W12, W13, W14, W15;

    reg [31:0] W_tmp;
    reg [31:0] W_selected;
    assign W_next = W_selected;
    always @* begin
        small_sigma_0 = {W1[ 6:0], W1[31: 7]}^
                    {W1[17:0], W1[31:18]}^
                    {     3'b0, W1[31: 3]};
        small_sigma_1 = {W14[16:0], W14[31:17]}^
                            {W14[18:0], W14[31:19]}^
                            {   10'b0, W14[31:10]};
        W_tmp = small_sigma_0 + small_sigma_1 + W9+ W0;
    end

    always @* begin
        if(round_idx < 16) begin
            case(round_idx)
                4'd0: W_selected = W0;
                4'd1: W_selected = W1;
                4'd2: W_selected = W2;
                4'd3: W_selected = W3;
                4'd4: W_selected = W4;
                4'd5: W_selected = W5;
                4'd6: W_selected = W6;
                4'd7: W_selected = W7;
                4'd8: W_selected = W8;
                4'd9: W_selected = W9;
                4'd10: W_selected = W10;
                4'd11: W_selected = W11;
                4'd12: W_selected = W12;
                4'd13: W_selected = W13;
                4'd14: W_selected = W14;
                4'd15: W_selected = W15;
                default: W_selected = 32'b0;
            endcase
        end 
        else begin
            W_selected = W_tmp;
        end
    end

    always @ (posedge clk, negedge reset_n) begin
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
        else begin
            if(init | digest_update) begin
                W0 <= block[511:480];
                W1 <= block[479:448];
                W2 <= block[447:416];
                W3 <= block[415:384];
                W4 <= block[383:352];
                W5 <= block[351:320];
                W6 <= block[319:288];
                W7 <= block[287:256];
                W8 <= block[255:224];
                W9 <= block[223:192];
                W10 <= block[191:160];
                W11 <= block[159:128];
                W12 <= block[127:96];
                W13 <= block[95:64];
                W14 <= block[63:32];
                W15 <= block[31:0];
            end
            if(round_idx > 15) begin
                W0 <= W1;
                W1 <= W2;
                W2 <= W3;
                W3 <= W4;
                W4 <= W5;
                W5 <= W6;
                W6 <= W7;
                W7 <= W8;
                W8 <= W9;
                W9 <= W10;
                W10 <= W11;
                W11 <= W12;
                W12 <= W13;
                W13 <= W14;
                W14 <= W15;
                W15 <= W_selected;
            end
        end
    end
 endmodule