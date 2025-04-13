module priority_encoder(
			input [11:0] significand,
			input [7:0] exp_a,
			output reg [11:0] Significand,
			output [7:0] exp_sub
			);

reg [4:0] shift;

always @(significand)
begin
	casex (significand)
		12'b1_1xxx_xxxx_xxx :	begin
													Significand = significand;
									 				shift = 5'd0;
								 			  	end
		12'b1_01xx_xxxx_xxx : 	begin						
										 			Significand = significand << 1;
									 				shift = 5'd1;
								 			  	end

		12'b1_001x_xxxx_xxx : 	begin						
										 			Significand = significand << 2;
									 				shift = 5'd2;
								 				end

		12'b1_0001_xxxx_xxx : 	begin 							
													Significand = significand << 3;
								 	 				shift = 5'd3;
								 				end

		12'b1_0000_1xxx_xxx : 	begin						
									 				Significand = significand << 4;
								 	 				shift = 5'd4;
								 				end

		12'b1_0000_01xx_xxx : 	begin						
									 				Significand = significand << 5;
								 	 				shift = 5'd5;
								 				end

		12'b1_0000_001x_xxx : 	begin						// 24'h020000
									 				Significand = significand << 6;
								 	 				shift = 5'd6;
								 				end

		12'b1_0000_0001_xxx : 	begin						// 24'h010000
									 				Significand = significand << 7;
								 	 				shift = 5'd7;
								 				end

		12'b1_0000_0000_1xx : 	begin						// 24'h008000
									 				Significand = significand << 8;
								 	 				shift = 5'd8;
								 				end

		12'b1_0000_0000_01x : 	begin						// 24'h004000
									 				Significand = significand << 9;
								 	 				shift = 5'd9;
								 				end

		12'b1_0000_0000_001 : 	begin						// 24'h002000
									 				Significand = significand << 10;
								 	 				shift = 5'd10;
								 				end

		12'b1_0000_0000_000 : 	begin						// 24'h001000
									 				Significand = significand << 11;
								 	 				shift = 5'd11;
								 				end

		default : 	begin
						Significand = (significand) + 1'b1;
						shift = 8'd0;
					end

	endcase
end
assign exp_sub = exp_a - shift;

endmodule
