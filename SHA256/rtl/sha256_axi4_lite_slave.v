module sha256_axi4_lite_slave #(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 32
)(
    input wire                   ACLK,
    input wire                   ARESETn,

    // AXI4-Lite Write Address Channel
    input wire                   AWVALID,
    output wire                  AWREADY,
    input wire [ADDR_WIDTH-1:0]  AWADDR,

    // AXI4-Lite Write Data Channel
    input wire                   WVALID,
    output wire                  WREADY,
    input wire [DATA_WIDTH-1:0]  WDATA,

    // AXI4-Lite Write Response Channel
    output wire                  BVALID,
    input wire                   BREADY,
    output wire [1:0]            BRESP,

    // AXI4-Lite Read Address Channel
    input wire                   ARVALID,
    output wire                  ARREADY,
    input wire [ADDR_WIDTH-1:0]  ARADDR,

    // AXI4-Lite Read Data Channel
    output wire                  RVALID,
    input wire                   RREADY,
    output wire [DATA_WIDTH-1:0] RDATA,
    output wire [1:0]            RRESP
);

    // Internal registers
    wire [255:0] digest;
    wire [511:0] block;
    reg  [31:0]  block_regs [0:15];
    reg          start_reg;
    reg          last_block_reg;
    reg  [31:0]  rdata_reg;
    reg          write_en;
    reg          read_en;
    wire         done;
    wire         digest_update;
    // Internal FSM states for AXI protocol
    reg          awready_reg, wready_reg, bvalid_reg;
    reg          arready_reg, rvalid_reg;
    reg [ADDR_WIDTH-1:0]  awaddr_reg, araddr_reg;

    // Constants
    localparam CTRL_REG        = 5'h10;
    localparam MSG_REG_BASE    = 5'h00;
    localparam DIGEST_REG_BASE = 5'h11;

    // Output assignments
    assign AWREADY = awready_reg;
    assign WREADY  = wready_reg;
    assign BVALID  = bvalid_reg;
    assign BRESP   = 2'b00;  // OKAY response

    assign ARREADY = arready_reg;
    assign RVALID  = rvalid_reg;
    assign RDATA   = rdata_reg;
    assign RRESP   = 2'b00;  // OKAY response

    assign block = {block_regs[15], block_regs[14], block_regs[13], block_regs[12],
                    block_regs[11], block_regs[10], block_regs[9],  block_regs[8],
                    block_regs[7],  block_regs[6],  block_regs[5],  block_regs[4],
                    block_regs[3],  block_regs[2],  block_regs[1],  block_regs[0]};

    // SHA core instantiation
    sha256_core IP (
        .clk        (ACLK),
        .reset_n    (ARESETn),
        .start      (start_reg),
        .block      (block),
        .last_block (last_block_reg),
        .done       (done),
        .digest_update (digest_update),
        .digest     (digest)
    );
    // AXI Write FSM
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            awready_reg <= 0;
            wready_reg  <= 0;
            bvalid_reg  <= 0;
            start_reg   <= 0;
            last_block_reg <= 0;
            block_regs[0] <= 32'h0;
            block_regs[1] <= 32'h0;
            block_regs[2] <= 32'h0;
            block_regs[3] <= 32'h0;
            block_regs[4] <= 32'h0;
            block_regs[5] <= 32'h0;
            block_regs[6] <= 32'h0;
            block_regs[7] <= 32'h0;
            block_regs[8] <= 32'h0;
            block_regs[9] <= 32'h0;
            block_regs[10] <= 32'h0;
            block_regs[11] <= 32'h0;
            block_regs[12] <= 32'h0;
            block_regs[13] <= 32'h0;
            block_regs[14] <= 32'h0;
            block_regs[15] <= 32'h0;
        end else begin
            // Write address handshake
            if (AWVALID && !awready_reg) begin
                awready_reg <= 1;
                awaddr_reg <= AWADDR;
            end else begin
                awready_reg <= 0;
            end

            // Write data handshake
            if (WVALID && !wready_reg && awready_reg) begin
                wready_reg <= 1;
                bvalid_reg <= 1;

            // Handle write
                case (awaddr_reg)
                    CTRL_REG: begin
                        start_reg <= WDATA[1];
                        last_block_reg <= WDATA[0];
                    end
                    MSG_REG_BASE + 4'hf: block_regs[0] <= WDATA;
                    MSG_REG_BASE + 4'he: block_regs[1] <= WDATA;
                    MSG_REG_BASE + 4'hd: block_regs[2] <= WDATA;
                    MSG_REG_BASE + 4'hc: block_regs[3] <= WDATA;
                    MSG_REG_BASE + 4'hb: block_regs[4] <= WDATA;
                    MSG_REG_BASE + 4'ha: block_regs[5] <= WDATA;
                    MSG_REG_BASE + 4'h9: block_regs[6] <= WDATA;
                    MSG_REG_BASE + 4'h8: block_regs[7] <= WDATA;
                    MSG_REG_BASE + 4'h7: block_regs[8] <= WDATA;
                    MSG_REG_BASE + 4'h6: block_regs[9] <= WDATA;
                    MSG_REG_BASE + 4'h5: block_regs[10] <= WDATA;
                    MSG_REG_BASE + 4'h4: block_regs[11] <= WDATA;
                    MSG_REG_BASE + 4'h3: block_regs[12] <= WDATA;
                    MSG_REG_BASE + 4'h2: block_regs[13] <= WDATA;
                    MSG_REG_BASE + 4'h1: block_regs[14] <= WDATA;
                    MSG_REG_BASE + 4'h0: block_regs[15] <= WDATA;
                endcase
            end else begin
                wready_reg <= 0;
            end

            // Write response handshake
            if (BREADY && bvalid_reg) begin
                bvalid_reg <= 0;
            end

            // Clear start after pulse
            if (!(AWVALID && WVALID && awaddr_reg == CTRL_REG))
                start_reg <= 0;
        end
    end

    // AXI Read FSM
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            arready_reg <= 0;
            rvalid_reg  <= 0;
            rdata_reg   <= 0;
        end else begin
            // Read address handshake
            if (ARVALID && !arready_reg) begin
                arready_reg <= 1;
                araddr_reg <= ARADDR;
            end else begin
                arready_reg <= 0;
            end

            // Read data output
            if (arready_reg && RREADY && !rvalid_reg) begin
                rvalid_reg <= 1;
                case (araddr_reg)
                    CTRL_REG: rdata_reg <= {28'b0, digest_update, last_block_reg, start_reg, done};
                    DIGEST_REG_BASE + 4'h0: rdata_reg <= digest[255:224];
                    DIGEST_REG_BASE + 4'h1: rdata_reg <= digest[223:192];
                    DIGEST_REG_BASE + 4'h2: rdata_reg <= digest[191:160];
                    DIGEST_REG_BASE + 4'h3: rdata_reg <= digest[159:128];
                    DIGEST_REG_BASE + 4'h4: rdata_reg <= digest[127:96];
                    DIGEST_REG_BASE + 4'h5: rdata_reg <= digest[95:64];
                    DIGEST_REG_BASE + 4'h6: rdata_reg <= digest[63:32];
                    DIGEST_REG_BASE + 4'h7: rdata_reg <= digest[31:0];
                    default: rdata_reg <= 32'h0;
                endcase
            end

            // Read response handshake
            if (RVALID && RREADY) begin
                rvalid_reg <= 0;
            end
        end
    end

endmodule
