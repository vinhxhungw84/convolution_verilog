module Vedic_mul_16x16(
	input logic [15:0] a, b,
	output logic [31:0] out
	);
	
	wire [15:0] temp1;
	wire [15:0] temp2;
	wire [15:0] temp3;
	wire [15:0] temp4;
	wire [23:0] temp5;
	wire [15:0] temp6;
	wire [23:0] temp7;
	
	Vedic_mul_8x8 F0(a[7:0], b[7:0], temp1);
	assign out[7:0] = temp1[7:0];
	Vedic_mul_8x8 F1(a[15:8], b[7:0], temp2);
	Vedic_mul_8x8 F2(a[7:0], b[15:8], temp3);
	Vedic_mul_8x8 F3(a[15:8], b[15:8], temp6);
	
	adder_Nbit #('d16) B0({8'h00, temp1[15:8]}, temp2, temp4);
	adder_Nbit #('d24) B1({8'h00, temp3}, {temp6, 8'h00}, temp5);
	adder_Nbit #('d24) B2({8'h00, temp4}, temp5, temp7);
	assign out[31:8] = temp7;
	
endmodule
	