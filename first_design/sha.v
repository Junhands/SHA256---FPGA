`default_nettype none
module sha(
    input wire clk,
    input wire reset_n,
    input wire start,
    input wire [511:0] message,
    input wire last_block,
    output wire done,
    output wire [255:0] digest
);
//================================================================
// parameter settings
    localparam INIT_STATE  = 2'd0;
    localparam READY_STATE = 2'd1;
    localparam LAST_ROUND_STATE  = 2'd2;

    localparam H_0 = 32'h6a09e667;
    localparam H_1 = 32'hbb67ae85;
    localparam H_2 = 32'h3c6ef372;
    localparam H_3 = 32'ha54ff53a;
    localparam H_4 = 32'h510e527f;
    localparam H_5 = 32'h9b05688c;
    localparam H_6 = 32'h1f83d9ab;
    localparam H_7 = 32'h5be0cd19;

    wire [255:0] H_constant = {H_0, H_1, H_2, H_3, H_4, H_5, H_6, H_7};
//================================================================

    assign init    = init_reg;
    assign ready   = ready_reg;
    assign last_round = last_round_reg;
    assign done       = done_reg;

    wire init;
    wire ready;
    wire last_round;
    wire [5:0] round_idx;

    wire [255:0] digest_of_block;
    wire [255:0] H_init;
    wire [31:0] M_i;
    wire [31:0] W_i;
    wire [31:0] K_i;

    input_shifter unit0(
        .clk(clk),
        .ready(ready),
        .message(message),
        .M_i(M_i)
    );
//================================================================
// ==================================
    counter unit1(
        .clk        (clk       ),
        .reset_n    (reset_n   ),
        .ready      (ready     ),
        .round_idx  (round_idx )
    );
//================================================================
    wmem_new unit2(
        .clk       (clk       ),
        .reset_n   (reset_n   ),
        .ready (ready |start),
        .round_idx (round_idx ),
        .M_next    (M_i       ),
        .W_next    (W_i       )
    );
    k_constants unit3(
        .round_idx (round_idx),
		  .ready(ready),
        .K         (K_i      )
    );
    mux_sha256 unit4(
        .c0  (digest_of_block),
        .c1  (H_constant),
        .sel (init|done),
        .out (H_init        )
    );
    compression unit5(
        .clk        (clk            ),
        .reset_n    (reset_n        ),
        .init       (init           ),
        .ready      (ready          ),
        .last_round (last_round     ),
        .W_i        (W_i            ),
        .K_i        (K_i            ),
        .H_init     (H_init         ),
        .digest     (digest_of_block)
    );
    // assign digest = (done) ? digest_of_block : 255'hz;
    reg [255:0] digest_next;
    reg [255:0] digest_reg;
    always @* begin
        if(done) begin
            digest_next <= digest_of_block;
        end
        else begin
            digest_next <= digest_reg;
        end
    end
    always @ (posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            digest_reg <= 255'h0;
        end
        else begin
            digest_reg <= digest_next;
        end
    end
    assign digest = digest_reg;
//================================================================
//  FSM
//================================================================
    reg [1:0] next_state;
    reg [1:0] state;

    reg init_reg;
    reg ready_reg;
    reg last_round_reg;
    reg done_reg;

    always @ * begin
        next_state <= 2'b0;
        init_reg <= 1'b0;
        ready_reg <= 1'b0;
        last_round_reg <= 1'b0;
        done_reg <= 1'b0;

        case(state)
            INIT_STATE: begin
                init_reg <= 1'b1;
                if(start) begin
                    next_state <= READY_STATE;
                end
                else begin
                    next_state <= INIT_STATE;
                end
            end
            READY_STATE: begin
                ready_reg <= 1'b1;
                if (round_idx == 63) begin
                    last_round_reg <= 1'b1;
                    next_state <= LAST_ROUND_STATE;
                end
                else begin
                    next_state <= READY_STATE;
                end
            end
            LAST_ROUND_STATE: begin
                if(last_block) begin
                    done_reg <= 1'b1;
                    init_reg <= 1'b1;
                    if(start) begin
                        next_state <= READY_STATE;
                    end
                    else begin
                        next_state <= INIT_STATE;
                        
                    end
                end
                else begin
                    next_state <= READY_STATE;

                end
            end
        endcase
    end
    always @ (posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            state <= INIT_STATE;
        end
        else begin
            state <= next_state;
        end
    end
endmodule