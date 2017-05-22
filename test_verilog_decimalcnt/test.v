module test(
	input SW_1 , // 入力A
	input SW_2 ,
	input SW_3 ,
	input clk,
	output LED_1 = 0,
	output LED_2 = 0,
	output LED_3 = 0,
	output LED_4 = 0,
	output LED_5 = 0,
	output LED_6 = 0,
	output LED_7 = 0,
	output LED_8 = 0,
	output SEG7_CTL1 = 0,
	output SEG7_CTL2 = 0,
	output SEG7_CTL3 = 0,
	output SEG7_CTL4 = 0,
	output SEG7_A = 0,
	output SEG7_B = 0,
	output SEG7_C = 0,
	output SEG7_D = 0,
	output SEG7_E = 0,
	output SEG7_F = 0,
	output SEG7_G = 0,
	output SEG7_DP = 0,
	output BUZZER = 0
);

	function [7:0] decode7segled (
		input [3:0] input_data
		);
		begin
			case ( input_data )
				4'h0: decode7segled = 8'b11000000;
				4'h1: decode7segled = 8'b11111001;
				4'h2: decode7segled = 8'b10100100;
				4'h3: decode7segled = 8'b10110000;
				4'h4: decode7segled = 8'b10011001;
				4'h5: decode7segled = 8'b10010010;
				4'h6: decode7segled = 8'b10000010;
				4'h7: decode7segled = 8'b11011000;
				4'h8: decode7segled = 8'b10000000;
				4'h9: decode7segled = 8'b10010000;
				default: decode7segled = 8'bx;
			endcase
		end
	endfunction

	reg [31:0] sys_count;
	reg [7:0] counter;
	assign {LED_8, LED_7, LED_6, LED_5, LED_4, LED_3, LED_2, LED_1 } = counter;
	
	reg [7:0] seg7_pattern;
	wire [7:0] seg7out = seg7_pattern;
	assign {SEG7_DP, SEG7_G, SEG7_F, SEG7_E, SEG7_D, SEG7_C, SEG7_B, SEG7_A} = seg7out;
	
	reg [3:0] led_drive = 4'b1110;
	assign {SEG7_CTL4, SEG7_CTL3, SEG7_CTL2, SEG7_CTL1} = led_drive;
	
	reg [3:0] dec_count1 = 4'b0;
	reg [3:0] dec_count10 = 4'b0;
	reg [3:0] dec_count100 = 4'b0;
	reg [3:0] dec_count1000 = 4'b0;
	reg [5:0] pulse_cnt = 0;
	reg pulse = 0;
	assign BUZZER = pulse;
	
	
	always @(posedge clk) // 48kHz
	begin
		sys_count <= sys_count + 32'b1;
		pulse_cnt <= pulse_cnt + 1'b1;
		
		if (pulse_cnt > 24) begin
			// 1kHz
			pulse_cnt <= 0;
			if (pulse == 1)
				pulse <= 0;
//			else
//				pulse <= 1;
		end
		
		if (sys_count > 12000) begin
			// 0.25s
			sys_count <= 0;
			
			if (SW_1 == 1'b0) begin
				counter <= counter + 8'b1;
				dec_count1 <= dec_count1 + 4'b1;
				if (dec_count1 >= 9) begin
					dec_count1 <= 0;
					dec_count10 <= dec_count10 + 4'b1;
					if (dec_count10 >= 9) begin
						dec_count10 <= 0;
						dec_count100 <= dec_count100 + 4'b1;
						if (dec_count100 >= 9) begin
							dec_count100 <= 0;
							dec_count1000 <= dec_count1000 + 4'b1;
							if (dec_count1000 >= 9) begin
								dec_count1000 <= 0;
							end
						end
					end
				end
			end else if (SW_2 == 1'b0) begin
				counter <= counter - 8'b1;
				dec_count1 <= dec_count1 - 4'b1;
				if (dec_count1 == 4'b0) begin
					dec_count1 <= 4'h9;
					dec_count10 <= dec_count10 - 4'b1;
					if (dec_count10 == 4'b0) begin
						dec_count10 <= 4'h9;
						dec_count100 <= dec_count100 - 4'b1;
						if (dec_count100 == 4'b0) begin
							dec_count100 <= 4'h9;
							dec_count1000 <= dec_count1000 - 4'b1;
							if (dec_count1000 == 4'b0) begin
								dec_count1000 <= 4'h9;
							end
						end
					end
				end
			end else if (SW_3 == 1'b0) begin
				counter <= 8'b0;
				dec_count1 <= 8'b0;
				dec_count10 <= 8'b0;
				dec_count100 <= 8'b0;
				dec_count1000 <= 8'b0;
			end
		end
		
		led_drive[0] <= led_drive[1];
		led_drive[1] <= led_drive[2];
		led_drive[2] <= led_drive[3];
		led_drive[3] <= led_drive[0];
				
		if (led_drive[0] == 1'b0)
			seg7_pattern = decode7segled(dec_count1000);
		else if (led_drive[1] == 1'b0)
			seg7_pattern = decode7segled(dec_count1);
		else if (led_drive[2] == 1'b0)
			seg7_pattern = decode7segled(dec_count10);
		else if (led_drive[3] == 1'b0)
			seg7_pattern = decode7segled(dec_count100);
		
	end
	
	
endmodule