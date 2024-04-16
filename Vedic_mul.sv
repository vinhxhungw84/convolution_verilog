module Vedic_mul(
	input logic [7:0] a, b,
	output logic [15:0] out
	);
	
	Vedic_mul_8x8 R0(a, b, out);
	
endmodule