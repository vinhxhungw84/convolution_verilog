`timescale 1ns / 1ps


module adder_Nbit #(parameter N = 4)(
	input logic [N-1:0] a, b,
	output logic [N-1:0] s
	//output logic c
	);
	
	logic [N:0] carry;
	
	assign carry[0] = 0;
	
	generate
	genvar i;
	for (i = 0; i < N; i = i + 1) begin: for_loop
		full_adder FA(a[i], b[i], carry[i], s[i], carry[i+1]);
	end: for_loop
	//assign c = carry[15];
	endgenerate
	
endmodule