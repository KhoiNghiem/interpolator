module interpolator#(
    parameter DATA_WIDTH = 19
)(
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] Intplt,
    input [DATA_WIDTH-1:0] mu,
    output reg [DATA_WIDTH-1:0] IntpOut
);

// always @(negedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         data_in_0 <= 0;
//     end else if (ValidIn) begin
//         data_in_0 <= FilterIn;
//     end else begin
//         data_in_0 <= 0;
//     end
// end

localparam local_0_5 = 19'b0_01111110_0000000000;
localparam local_1_5 = 19'b0_01111111_1000000000;

localparam v2_add1_sign = 1'b1;
localparam v2_add2_sign = 1'b1;
localparam v2_add3_sign = 1'b0;

localparam v1_add1_sign = 1'b1;
localparam v1_add2_sign = 1'b1;
localparam v1_add3_sign = 1'b1;

localparam add1_sign = 1'b0;
localparam add2_sign = 1'b0;


// reg [18:0] data_in_m_p2;
reg [18:0] mu_data;

wire [18:0] data_in_m, data_in_m_m1, data_in_m_p1, data_in_m_p2;

// V2 wire
// Mul wire
wire [18:0] v2_mul1, v2_mul2, v2_mul3, v2_mul4;
wire        v2_mul1_exception, v2_mul1_overflow, v2_mul1_underflow;
wire        v2_mul2_exception, v2_mul2_overflow, v2_mul2_underflow;
wire        v2_mul3_exception, v2_mul3_overflow, v2_mul3_underflow;
wire        v2_mul4_exception, v2_mul4_overflow, v2_mul4_underflow;

// Add wire
wire [18:0] v2_add1, v2_add2, v2_add3;
wire        v2_add1_exception;
wire        v2_add2_exception;
wire        v2_add3_exception;

// V1 wire
// Mul wire
wire [18:0] v1_mul1, v1_mul2, v1_mul3, v1_mul4;
wire        v1_mul1_exception, v1_mul1_overflow, v1_mul1_underflow;
wire        v1_mul2_exception, v1_mul2_overflow, v1_mul2_underflow;
wire        v1_mul3_exception, v1_mul3_overflow, v1_mul3_underflow;
wire        v1_mul4_exception, v1_mul4_overflow, v1_mul4_underflow;

// Add wire
wire [18:0] v1_add1, v1_add2, v1_add3;
wire        v1_add1_exception;
wire        v1_add2_exception;
wire        v1_add3_exception;

// Global wire
wire [18:0] mul_1;
wire [18:0] mul_2;
wire        mul1_exception, mul1_overflow, mul1_underflow;
wire        mul2_exception, mul2_overflow, mul2_underflow;

wire [18:0] add_1;
wire [18:0] add_2;
wire        add1_exception;
wire        add2_exception;

always @(negedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // data_in_m_p2 <= 0;
        mu_data <= 0;
    end begin
        // data_in_m_p2 <= Intplt;
        mu_data <= mu;
    end 
end

reg [18:0] x_delay [0:3];  // Lưu 5 mẫu liên tiếp: x[n-2], x[n-1], x[n], x[n+1], x[n+2]
reg [3:0] mu_index;
reg load_new_x;

always @(negedge clk or negedge rst_n) begin
    if (!rst_n) begin
        x_delay[0] <= 0;
        x_delay[1] <= 0;
        x_delay[2] <= 0;
        x_delay[3] <= 0;
    end else if (load_new_x) begin
        x_delay[3] <= x_delay[2];
        x_delay[2] <= x_delay[1];
        x_delay[1] <= x_delay[0];
        x_delay[0] <= Intplt;  // Intplt là x[n]
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mu_index <= 0;
        load_new_x <= 1;
    end else begin
        if (mu_index == 8) begin
            mu_index <= 0;
            load_new_x <= 1;  // sau 9 lần thì đổi x mới
        end else begin
            mu_index <= mu_index + 1;
            load_new_x <= 0;
        end
    end
end

assign data_in_m_p2 = x_delay[0];
assign data_in_m_p1 = x_delay[1];
assign data_in_m    = x_delay[2];
assign data_in_m_m1 = x_delay[3];

mul V2_mul_1(data_in_m_p2,  local_0_5, v2_mul1_exception, v2_mul1_overflow, v2_mul1_underflow, v2_mul1);
mul V2_mul_2(data_in_m_p1,  local_0_5, v2_mul2_exception, v2_mul2_overflow, v2_mul2_underflow, v2_mul2);
mul V2_mul_3(data_in_m,     local_0_5, v2_mul3_exception, v2_mul3_overflow, v2_mul3_underflow, v2_mul3);
mul V2_mul_4(data_in_m_m1,  local_0_5, v2_mul4_exception, v2_mul4_overflow, v2_mul4_underflow, v2_mul4);

add V2_add_1(v2_mul1, v2_mul2, v2_add1_sign, v2_add1_exception, v2_add1);
add V2_add_2(v2_add1, v2_mul3, v2_add2_sign, v2_add2_exception, v2_add2);
add V2_add_3(v2_add2, v2_mul4, v2_add3_sign, v2_add3_exception, v2_add3);

mul V1_mul_1(data_in_m_p2,  local_0_5, v1_mul1_exception, v1_mul1_overflow, v1_mul1_underflow, v1_mul1);
mul V1_mul_2(data_in_m_p1,  local_1_5, v1_mul2_exception, v1_mul2_overflow, v1_mul2_underflow, v1_mul2);
mul V1_mul_3(data_in_m,     local_0_5, v1_mul3_exception, v1_mul3_overflow, v1_mul3_underflow, v1_mul3);
mul V1_mul_4(data_in_m_m1,  local_0_5, v1_mul4_exception, v1_mul4_overflow, v1_mul4_underflow, v1_mul4);

add V1_add_1(v1_mul2, v1_mul1, v1_add1_sign, v1_add1_exception, v1_add1);
add V1_add_2(v1_add1, v1_mul3, v1_add2_sign, v1_add2_exception, v1_add2);
add V1_add_3(v1_add2, v1_mul4, v1_add3_sign, v1_add3_exception, v1_add3);

// Global

mul MUL1(v2_add3, mu_data, mul1_exception, mul1_overflow, mul1_underflow, mul_1);
add ADD1(mul_1, v1_add3, add1_sign, add1_exception, add_1);

mul MUL2(add_1, mu_data, mul2_exception, mul2_overflow, mul2_underflow, mul_2);
add ADD2(mul_2, data_in_m, add2_sign, add2_exception, add_2);



always @(negedge clk or negedge rst_n) begin
    if (!rst_n) begin
        IntpOut <= 0;
    end else begin
        IntpOut <= add_2;
    end
end

endmodule