module mac #(
	parameter N = 16, // length of bits
	parameter Q = 12 // number of fraction
	)(
	input logic clk, sclr, ce,
	input logic [N-1:0] a_i, b_i, 
	input logic [N*2-1:0] c_i,
	output logic [N*2-1:0] r_o
	);
	
	always_ff @(posedge clk or posedge sclr) begin
		if (sclr) r_o <= 'd0;
		else if (ce) begin
				r_o <= (a_i * b_i + c_i); // this line will be update in the future
			end
	end
	
endmodule