module dff #(
    parameter DATA_WIDTH = 19
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] d,
    output reg [DATA_WIDTH-1:0] q
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        q <= 0;
    end else begin
        q <= d;
    end
end
endmodule