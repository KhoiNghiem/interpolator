module mul(
    input [18:0] a,
    input [18:0] b,
    output exception,
    output overflow,
    output underflow,
    output [18:0] res
);

wire sign, round, normalised, zero;
wire [8:0] exponent, sum_exponent;
wire [9:0] product_mantissa;
wire [10:0] op_a, op_b;
wire [21:0] product, product_normalised; 

assign sign = a[18] ^ b[18];
assign exception = (&a[17:10]) | (&b[17:10]);

assign op_a = (|a[17:10]) ? {1'b1,a[9:0]} : {1'b0,a[9:0]};
assign op_b = (|b[17:10]) ? {1'b1,b[9:0]} : {1'b0,b[9:0]};

assign product = op_a * op_b;

assign normalised = product[21] ? 1'b1 : 1'b0;  

assign product_normalised = normalised ? product : product << 1; 

assign round = |product_normalised[9:0];

assign product_mantissa = product_normalised[20:11] + (product_normalised[10] & round);

assign zero = exception ? 1'b0 : (product_mantissa == 10'd0) & (sum_exponent == 127) ? 1'b1 : 1'b0;

assign sum_exponent = a[17:10] + b[17:10];

assign exponent = sum_exponent - 8'd127 + normalised + (sum_exponent == 127);

// assign exponent = sum_exponent - 8'd127 + normalised;   // Cộng dồn normalized vào exponent

assign overflow = ((exponent[8] & !exponent[7]) & !zero);

assign underflow = ((exponent[8] & exponent[7]) & !zero) ? 1'b1 : 1'b0;

assign res = exception ? 19'd0 : zero ? {sign,18'd0} : overflow ? {sign,18'd0} : underflow ? {sign,18'd0} : {sign,exponent[7:0],product_mantissa};

endmodule