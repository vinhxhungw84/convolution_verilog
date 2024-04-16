module full_adder(
	input logic ain, bin, cin,
	output logic sum, cout
	);
	
	//assign bin1 = bin ^ cin;
	assign sum = ain ^ bin ^ cin;
	assign cout = (ain & bin) | (ain & cin) | (bin & cin);
	
endmodule 