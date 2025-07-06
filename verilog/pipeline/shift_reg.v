module shift_reg #(
    parameter DATA_WIDTH = 19
)(
    input                   clk,
    input                   rst_n,
    input                   load_new_x,
    input  [DATA_WIDTH-1:0] x_in,           // Intplt
    output [DATA_WIDTH-1:0] x_p2,           // x[n+2]
    output [DATA_WIDTH-1:0] x_p1,           // x[n+1]
    output [DATA_WIDTH-1:0] x_0,            // x[n]
    output [DATA_WIDTH-1:0] x_m1            // x[n-1]
);

    reg [DATA_WIDTH-1:0] x_delay [0:3];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_delay[0] <= 0;
            x_delay[1] <= 0;
            x_delay[2] <= 0;
            x_delay[3] <= 0;
        end else if (load_new_x) begin
            x_delay[3] <= x_delay[2];
            x_delay[2] <= x_delay[1];
            x_delay[1] <= x_delay[0];
            x_delay[0] <= x_in;
        end
    end

    assign x_p2 = x_delay[0];  // x[n+2]
    assign x_p1  = x_delay[1];  // x[n+1]
    assign x_0 = x_delay[2];  // x[n]
    assign x_m1 = x_delay[3];  // x[n-1]

endmodule
