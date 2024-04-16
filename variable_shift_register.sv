module variable_shift_register #(parameter WIDTH = 8, parameter SIZE = 3)(
	input logic clk, rst, ce,
	input logic [WIDTH-1:0] data_i,
	output logic [WIDTH-1:0] data_o
	);
	
	logic [WIDTH-1:0] sh_r [SIZE-1:0]; // shift register that holds the data
	generate 
	genvar i;
	for (i = 0; i < SIZE; i = i + 1) begin : for_loop
		always_ff @(posedge clk or posedge rst) begin
			if (rst) sh_r[i] <= 'd0; 
			else begin
				if (ce) begin
					if (i == 'd0) sh_r[i] <= data_i;
					else sh_r[i] <= sh_r[i - 1];
				end
			end
		end
	end : for_loop
	endgenerate
	
	assign data_o = sh_r[SIZE - 1];
endmodule
			
	
		