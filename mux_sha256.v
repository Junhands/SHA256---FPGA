`default_nettype none
module mux_sha256(
    input  wire [255:0] c0,
    input  wire [255:0] c1,
    input  wire         sel,
    output wire [255:0] out
);
    assign out = (sel) ? c1 : c0;

endmodule