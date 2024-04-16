`timescale 1ns / 1ps

module convolver #(
	parameter n = 8'h0a,	// size of activation map
	parameter k = 8'h03, // size of kernel 
	parameter s = 1, // value of stride (horizontal and vertical stride are equal
	parameter BL = 16, // bit width
	parameter Q = 12 // number of fractional bits in case of fixed point representation
	)(
	input logic clk,
	input logic rst,
	input logic ce,
	input logic [BL-1:0] activation,
	input logic [(k*k)*BL-1:0] weight1,
	output logic [31:0] conv_op,
	output logic valid_conv,
	output logic end_conv
	);
	
	logic [31:0] count1; // count the clock cycles
	logic [31:0] count2; // count the valid convolution outputs
	logic [31:0] count3; // count the invalid convolutions when the kernel wraps around the next row of inputs
	logic [31:0] row_count; // count number of rows of output 
	logic en1, en2, en3; // signals to control pipeline
	
	logic [BL-1:0] weight [0:k*k-1];
	
	generate
		genvar j;
		for (j = 0; j < k*k; j = j + 1) begin : for_loop
			assign weight[j][BL-1:0] = weight1[BL*j +: BL];
		end : for_loop
	endgenerate
	
	logic [BL*2-1:0] tmp [k*k+1:0];
	assign tmp[0] = 32'h00000000;
	
	generate
	genvar i;
	for (i = 0; i < k*k; i = i + 1) begin : for_loop1
		if ((i+1) % k == 0) begin 					// end of row
			if (i == k*k - 1) begin 				// end of convolution
				mac #(.N(BL), .Q(Q)) MAC0(
					.clk(clk),
					.sclr(rst),
					.ce(ce),
					.a_i(activation),
					.b_i(weight[i]),
					.c_i(tmp[i]),
					.r_o(conv_op)
				);
			end
			else begin
				logic [BL*2-1:0] tmp2;
				mac #(.N(BL), .Q(Q)) MAC1(
					.clk(clk),
					.sclr(rst),
					.ce(ce),
					.a_i(activation),
					.b_i(weight[i]),
					.c_i(tmp[i]),
					.r_o(tmp2)
				);
				variable_shift_register #(.WIDTH(BL*2), .SIZE(n-k)) SR(
					.clk(clk),
					.rst(rst),
					.ce(ce),
					.data_i(tmp2),
					.data_o(tmp[i+1])
					);
			end
		end
		else begin
			mac #(.N(BL), .Q(Q)) MAC2(
					.clk(clk),
					.sclr(rst),
					.ce(ce),
					.a_i(activation),
					.b_i(weight[i]),
					.c_i(tmp[i]),
					.r_o(tmp[i+1])
				);
		end
	end : for_loop1
	endgenerate
	
	always_ff @(posedge clk) begin
		if (rst) begin
			count1 <= 0;
			count2 <= 0;
			count3 <= 0;
			row_count <= 0;
			en1 <= 0;
			en2 <= 1;
			en3 <= 0;
		end
		if (ce) begin
			if (count1 == (k-1)*n + k - 1) begin // time taken for pipeline to fill up is (k-1)*n+k-1
				count1 <= count1 + 1'b1;
				en1 <= 1'b1;
			end
			else count1 <= count1 + 1'b1;
		end
		
		if (en1 && en2) begin
			if (count2 == n - k) begin
				count2 <= 0;
				en2 <= 0;
				row_count <= row_count + 1'b1;
			end
			else count2 <= count2 + 1'b1;
		end
		if(~en2) begin
			if(count3 == k-2) begin
				count3<=0;
				en2 <= 1'b1;
			end
		else
			count3 <= count3 + 1'b1;
		end
		
  //one in every 's' convolutions becomes valid, also some exceptional cases handled for high when count2 = 0
		if((((count2 + 1) % s == 0) && (row_count % s == 0))
			||(count3 == k-2)&&(row_count % s == 0)
			||(count1 == (k-1)*n+k-1))
		begin                                                                                                                        
			en3 <= 1;                                                                                                                             
		end
		else 
			en3 <= 0;
	end
	
	assign end_conv = (count1>= n*n+2) ? 1'b1 : 1'b0;
	assign valid_conv = (en1&&en2&&en3);
	
endmodule
	
	
	
	
	
	
	
	