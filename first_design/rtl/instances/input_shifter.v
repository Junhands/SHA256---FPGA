`default_nettype none
module input_shifter(
    input wire clk,
    input wire ready,
    input wire [511:0] message,
    output wire [31:0] M_i
);
    reg [511:0] message_tmp;
    reg [511:0] message_init;
    assign M_i = (ready) ? message_tmp[511:480] :  message[511:480];
    always @*begin
        message_init <= message;
    end
    always @ (posedge clk) begin
        if(ready) begin
            message_tmp <= message_tmp << 32;
        end
        else begin
            message_tmp <= message_init << 32;
        end
    end
endmodule