module add(
    input [18:0] a,
    input [18:0] b, 
    input isSub,	        //If is_Sub = 0: Add, else: Sub
    output exception,
    output [18:0] result    //Outputs
);

wire operation_sub_add;
wire comp_enable;
wire output_sign;
wire exp_equal;

wire [18:0] operand_a;
wire [18:0] operand_b;
wire [10:0] mantissa_a;
wire [18:0] mantissa_b;
wire [7:0] exponent_diff;


wire [10:0] mantissa_b_add_sub;
wire [7:0] exp_b_add_sub;

wire [11:0] mantissa_add;
wire [17:0] add_sum;

wire [10:0] mantissa_sub_compl;
wire [11:0] mantissa_sub;
wire [17:0] sub_diff;
wire [11:0] subtraction_diff; 
wire [7:0] exp_sub;

//for operations always a must not be less than b
assign {comp_enable,operand_a,operand_b} = (a[17:0] < b[17:0]) ? {1'b1,b,a} : {1'b0,a,b};

//Exception flag sets 1 if either one of the exponent is 255.
assign exception = (&operand_a[17:10]) | (&operand_b[17:10]);

assign output_sign = isSub ? comp_enable ? !operand_a[18] : operand_a[18] : operand_a[18] ;

assign operation_sub_add = isSub ? operand_a[18] ^ operand_b[18] : ~(operand_a[18] ^ operand_b[18]);

//If exponent is equal to zero then hidden bit will be 0 for that respective significand else it will be 1
assign mantissa_a = (|operand_a[17:10]) ? {1'b1,operand_a[9:0]} : {1'b0,operand_a[9:0]};
assign mantissa_b = (|operand_b[17:10]) ? {1'b1,operand_b[9:0]} : {1'b0,operand_b[9:0]};

//Evaluating Exponent Difference vì operand_a luôn lớn hơn operand_b
assign exponent_diff = operand_a[17:10] - operand_b[17:10];

//Shifting significand_b according to exponent_diff
assign mantissa_b_add_sub = mantissa_b >> exponent_diff;

assign exp_b_add_sub = operand_b[17:10] + exponent_diff; 

//Checking exponents are same or not
assign exp_equal = (operand_a[17:10] == exp_b_add_sub);

//ADD

assign mantissa_add = (exp_equal & operation_sub_add) ? (mantissa_a + mantissa_b_add_sub) : 12'd0; 

//Result will be equal to Most 23 bits if carry generates else it will be Least 22 bits.
assign add_sum[9:0] = mantissa_add[11] ? mantissa_add[10:1] : mantissa_add[9:0];

//If carry generates in sum value then exponent must be added with 1 else feed as it is.
assign add_sum[17:10] = mantissa_add[11] ? (1'b1 + operand_a[17:10]) : operand_a[17:10];

//SUB 

assign mantissa_sub_compl = (exp_equal & !operation_sub_add) ? ~(mantissa_b_add_sub) + 11'd1 : 11'd0 ; 

assign mantissa_sub = exp_equal ? (mantissa_a + mantissa_sub_compl) : 12'd0;

priority_encoder pe(mantissa_sub, operand_a[17:10], subtraction_diff, exp_sub);

assign sub_diff[17:10] = exp_sub;

assign sub_diff[9:0] = subtraction_diff[9:0];

//Output

assign result = exception ? 18'b0 : ((!operation_sub_add) ? {output_sign,sub_diff} : {output_sign,add_sum});

endmodule