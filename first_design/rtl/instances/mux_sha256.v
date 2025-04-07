`default_nettype none
module mux_sha256(
    input  wire [255:0] H0_constants,
    input  wire [255:0] digest_of_block,
    input  wire         sel,
    output wire [255:0] H0_init
);
    assign H0_init = (ready) ? digest_of_block : H0_constants;
endmodule