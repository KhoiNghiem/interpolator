`include "priority_encoder.v"

module add(

input [18:0] a_operand,b_operand, //Inputs in the format of IEEE-754 Representation.
input AddBar_Sub,	//If Add_Sub is low then Addition else Subtraction.
output Exception,
output [18:0] result //Outputs in the format of IEEE-754 Representation.
);

wire operation_sub_addBar;
wire Comp_enable;
wire output_sign;
wire perform;

wire [18:0] operand_a,operand_b;
wire [10:0] significand_a,significand_b;
wire [7:0] exponent_diff;


wire [10:0] significand_b_add_sub;
wire [7:0] exponent_b_add_sub;

wire [11:0] significand_add;
wire [17:0] add_sum;

wire [10:0] significand_sub_complement;
wire [11:0] significand_sub;
wire [17:0] sub_diff;
wire [11:0] subtraction_diff; 
wire [7:0] exponent_sub;

//for operations always operand_a must not be less than b_operand
assign {Comp_enable,operand_a,operand_b} = (a_operand[17:0] < b_operand[17:0]) ? {1'b1,b_operand,a_operand} : {1'b0,a_operand,b_operand};

//Exception flag sets 1 if either one of the exponent is 255.
assign Exception = (&operand_a[17:10]) | (&operand_b[17:10]);

assign output_sign = AddBar_Sub ? Comp_enable ? !operand_a[18] : operand_a[18] : operand_a[18] ;

assign operation_sub_addBar = AddBar_Sub ? operand_a[18] ^ operand_b[18] : ~(operand_a[18] ^ operand_b[18]);

//Assigining significand values according to Hidden Bit.
//If exponent is equal to zero then hidden bit will be 0 for that respective significand else it will be 1
assign significand_a = (|operand_a[17:10]) ? {1'b1,operand_a[9:0]} : {1'b0,operand_a[9:0]};
assign significand_b = (|operand_b[17:10]) ? {1'b1,operand_b[9:0]} : {1'b0,operand_b[9:0]};

//Evaluating Exponent Difference vì operand_a luôn lớn hơn operand_b
assign exponent_diff = operand_a[17:10] - operand_b[17:10];

//Shifting significand_b according to exponent_diff
assign significand_b_add_sub = significand_b >> exponent_diff;

assign exponent_b_add_sub = operand_b[17:10] + exponent_diff; 

//Checking exponents are same or not
assign perform = (operand_a[17:10] == exponent_b_add_sub);

///////////////////////////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------ADD BLOCK------------------------------------------//

assign significand_add = (perform & operation_sub_addBar) ? (significand_a + significand_b_add_sub) : 12'd0; 

//Result will be equal to Most 23 bits if carry generates else it will be Least 22 bits.
assign add_sum[9:0] = significand_add[11] ? significand_add[10:1] : significand_add[9:0];

//If carry generates in sum value then exponent must be added with 1 else feed as it is.
assign add_sum[17:10] = significand_add[11] ? (1'b1 + operand_a[17:10]) : operand_a[17:10];

///////////////////////////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------SUB BLOCK------------------------------------------//

assign significand_sub_complement = (perform & !operation_sub_addBar) ? ~(significand_b_add_sub) + 11'd1 : 11'd0 ; 

assign significand_sub = perform ? (significand_a + significand_sub_complement) : 12'd0;

priority_encoder pe(significand_sub,operand_a[17:10],subtraction_diff,exponent_sub);

assign sub_diff[17:10] = exponent_sub;

assign sub_diff[9:0] = subtraction_diff[9:0];

///////////////////////////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------OUTPUT--------------------------------------------//

//If there is no exception and operation will evaluate


assign result = Exception ? 18'b0 : ((!operation_sub_addBar) ? {output_sign,sub_diff} : {output_sign,add_sum});

endmodule