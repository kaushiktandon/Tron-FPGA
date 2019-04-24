`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// TRON
// Author:  Kaushik Tandon, Grant Garcia
//////////////////////////////////////////////////////////////////////////////////
module vga_demo(ClkPort, vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b, Sw0, Sw1, btnU, btnD, btnL, btnR,
	St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7, JA);
	inout [7:0] JA;
	input ClkPort, Sw0, btnU, btnD, btnL, btnR, Sw0, Sw1;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	reg vga_r, vga_g, vga_b;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*  LOCAL SIGNALS */
	wire	reset, start, ClkPort, board_clk, clk, button_clk;
	
	BUF BUF1 (board_clk, ClkPort); 	
	BUF BUF2 (reset, Sw0);
	BUF BUF3 (start, Sw1);
	
	reg [27:0]	DIV_CLK;
	always @ (posedge board_clk, posedge reset)  
	begin : CLOCK_DIVIDER
      if (reset)
			DIV_CLK <= 0;
      else
			DIV_CLK <= DIV_CLK + 1'b1;
	end	

	assign	button_clk = DIV_CLK[18];
	assign	clk = DIV_CLK[1];
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b11111};
	
	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [9:0] CounterY;

	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
	reg R1 =0;
	reg G1 =0;
	reg R2 = 0;
	reg G2 = 0;
	reg R3 = 1;
	reg G3 = 1;
	
	reg B1=0;

	wire R;
	wire G;
	wire B;

	
	reg [9:0] P1p1xpos = 200;
	reg [9:0] P1p1ypos = 200;
	
	reg [9:0] P2p2xpos = 400;
	reg [9:0] P2p2ypos = 400;

	reg [1:0] P1direction=2'b01;
	reg [1:0] P2direction=2'b11;
	
	//00 = up
	//01 = right
	//10 = down
	//11 = left
	
	reg P1win=0;
	reg P2win=0;
	
	reg upperlim = 480;
	
	always @(posedge DIV_CLK[21])
		begin
			if(reset)
			begin
				P1direction <= 2'b01;
			end
			else if(btnD && ~btnU && ~btnL && ~btnR)
			begin
				P1direction <= 2'b10;
			end
			else if(btnU && ~btnD && ~btnL && ~btnR)
			begin
				P1direction <= 2'b00;
			end
			else if(btnL && ~btnU && ~btnD && ~btnR)
			begin
				P1direction <= 2'b11;
			end
			else if(btnR && ~btnU && ~btnD && ~btnL)
			begin
				P1direction <= 2'b01;
			end
		end
	always @(posedge DIV_CLK[21])
		begin
			if(reset)
			begin
				P2direction <= 2'b11;
			end
			//JA[0] down, JA[1] left, JA[2] right, JA[3] up
			else if(JA[0] && ~JA[3] && ~JA[1] && ~JA[2])
			begin
				P2direction <= 2'b10;
			end
			else if(JA[3] && ~JA[0] && ~JA[1] && ~JA[2])
			begin
				P2direction <= 2'b00;
			end
			else if(JA[1] && ~JA[3] && ~JA[0] && ~JA[2])
			begin
				P2direction <= 2'b11;
			end
			else if(JA[2] && ~JA[3] && ~JA[0] && ~JA[1])
			begin
				P2direction <= 2'b01;
			end
		end
			
	reg [9:0] p1xpos[15:0];
	reg [9:0] p1ypos[15:0];

	reg [9:0] p2xpos[15:0];
	reg [9:0] p2ypos[15:0];
	
	integer i;
	integer j;
	
	
	initial begin
		p1xpos[15] = 200;
		p1xpos[14] = 200;
		p1xpos[13] = 200;
		p1xpos[12] = 200;
		p1xpos[11] = 200;
		p1xpos[10] = 200;
		p1xpos[9] = 200;
		p1xpos[8] = 200;
		p1xpos[7] = 200;
		p1xpos[6] = 200;
		p1xpos[5] = 200;
		p1xpos[4] = 200;
		p1xpos[3] = 200;
		p1xpos[2] = 200;
		p1xpos[1] = 200;
		p1xpos[0] = 200;
		
		p1ypos[15] = 200;
		p1ypos[14] = 200;
		p1ypos[13] = 200;
		p1ypos[12] = 200;
		p1ypos[11] = 200;
		p1ypos[10] = 200;
		p1ypos[9] = 200;
		p1ypos[8] = 200;		
		p1ypos[7] = 200;
		p1ypos[6] = 200;
		p1ypos[5] = 200;
		p1ypos[4] = 200;
		p1ypos[3] = 200;
		p1ypos[2] = 200;
		p1ypos[1] = 200;
		p1ypos[0] = 200;
		
		p2xpos[15] = 400;
		p2xpos[14] = 400;
		p2xpos[13] = 400;
		p2xpos[12] = 400;
		p2xpos[11] = 400;
		p2xpos[10] = 400;
		p2xpos[9] = 400;
		p2xpos[8] = 400;
		p2xpos[7] = 400;
		p2xpos[6] = 400;
		p2xpos[5] = 400;
		p2xpos[4] = 400;
		p2xpos[3] = 400;
		p2xpos[2] = 400;
		p2xpos[1] = 400;
		p2xpos[0] = 400;
		
		p2ypos[15] = 400;
		p2ypos[14] = 400;
		p2ypos[13] = 400;
		p2ypos[12] = 400;
		p2ypos[11] = 400;
		p2ypos[10] = 400;
		p2ypos[9] = 400;
		p2ypos[8] = 400;		
		p2ypos[7] = 400;
		p2ypos[6] = 400;
		p2ypos[5] = 400;
		p2ypos[4] = 400;
		p2ypos[3] = 400;
		p2ypos[2] = 400;
		p2ypos[1] = 400;
		p2ypos[0] = 400;
	end
	
	assign R = 		
		(CounterY>=(p1ypos[15]-8) && CounterY<=(p1ypos[15]+8) && CounterX>=(p1xpos[15]-8) && CounterX<=(p1xpos[15]+8)) ||
		(CounterY>=(p1ypos[14]-8) && CounterY<=(p1ypos[14]+8) && CounterX>=(p1xpos[14]-8) && CounterX<=(p1xpos[14]+8)) ||
		(CounterY>=(p1ypos[13]-8) && CounterY<=(p1ypos[13]+8) && CounterX>=(p1xpos[13]-8) && CounterX<=(p1xpos[13]+8)) ||
		(CounterY>=(p1ypos[12]-8) && CounterY<=(p1ypos[12]+8) && CounterX>=(p1xpos[12]-8) && CounterX<=(p1xpos[12]+8)) ||
		(CounterY>=(p1ypos[11]-8) && CounterY<=(p1ypos[11]+8) && CounterX>=(p1xpos[11]-8) && CounterX<=(p1xpos[11]+8)) ||
		(CounterY>=(p1ypos[10]-8) && CounterY<=(p1ypos[10]+8) && CounterX>=(p1xpos[10]-8) && CounterX<=(p1xpos[10]+8)) ||
		(CounterY>=(p1ypos[9]-8) && CounterY<=(p1ypos[9]+8) && CounterX>=(p1xpos[9]-8) && CounterX<=(p1xpos[9]+8)) ||
		(CounterY>=(p1ypos[8]-8) && CounterY<=(p1ypos[8]+8) && CounterX>=(p1xpos[8]-8) && CounterX<=(p1xpos[8]+8)) ||
		(CounterY>=(p1ypos[7]-8) && CounterY<=(p1ypos[7]+8) && CounterX>=(p1xpos[7]-8) && CounterX<=(p1xpos[7]+8)) ||
		(CounterY>=(p1ypos[6]-8) && CounterY<=(p1ypos[6]+8) && CounterX>=(p1xpos[6]-8) && CounterX<=(p1xpos[6]+8)) ||
		(CounterY>=(p1ypos[5]-8) && CounterY<=(p1ypos[5]+8) && CounterX>=(p1xpos[5]-8) && CounterX<=(p1xpos[5]+8)) ||
		(CounterY>=(p1ypos[4]-8) && CounterY<=(p1ypos[4]+8) && CounterX>=(p1xpos[4]-8) && CounterX<=(p1xpos[4]+8)) ||
		(CounterY>=(p1ypos[3]-8) && CounterY<=(p1ypos[3]+8) && CounterX>=(p1xpos[3]-8) && CounterX<=(p1xpos[3]+8)) ||
		(CounterY>=(p1ypos[2]-8) && CounterY<=(p1ypos[2]+8) && CounterX>=(p1xpos[2]-8) && CounterX<=(p1xpos[2]+8)) ||
		(CounterY>=(p1ypos[1]-8) && CounterY<=(p1ypos[1]+8) && CounterX>=(p1xpos[1]-8) && CounterX<=(p1xpos[1]+8)) ||
		(CounterY>=(p1ypos[0]-8) && CounterY<=(p1ypos[0]+8) && CounterX>=(p1xpos[0]-8) && CounterX<=(p1xpos[0]+8)) || R1 || R2;
					
	assign G = 			
		(CounterY>=(p2ypos[15]-8) && CounterY<=(p2ypos[15]+8) && CounterX>=(p2xpos[15]-8) && CounterX<=(p2xpos[15]+8)) ||
		(CounterY>=(p2ypos[14]-8) && CounterY<=(p2ypos[14]+8) && CounterX>=(p2xpos[14]-8) && CounterX<=(p2xpos[14]+8)) ||
		(CounterY>=(p2ypos[13]-8) && CounterY<=(p2ypos[13]+8) && CounterX>=(p2xpos[13]-8) && CounterX<=(p2xpos[13]+8)) ||
		(CounterY>=(p2ypos[12]-8) && CounterY<=(p2ypos[12]+8) && CounterX>=(p2xpos[12]-8) && CounterX<=(p2xpos[12]+8)) ||
		(CounterY>=(p2ypos[11]-8) && CounterY<=(p2ypos[11]+8) && CounterX>=(p2xpos[11]-8) && CounterX<=(p2xpos[11]+8)) ||
		(CounterY>=(p2ypos[10]-8) && CounterY<=(p2ypos[10]+8) && CounterX>=(p2xpos[10]-8) && CounterX<=(p2xpos[10]+8)) ||
		(CounterY>=(p2ypos[9]-8) && CounterY<=(p2ypos[9]+8) && CounterX>=(p2xpos[9]-8) && CounterX<=(p2xpos[9]+8)) ||
		(CounterY>=(p2ypos[8]-8) && CounterY<=(p2ypos[8]+8) && CounterX>=(p2xpos[8]-8) && CounterX<=(p2xpos[8]+8)) ||
		(CounterY>=(p2ypos[7]-8) && CounterY<=(p2ypos[7]+8) && CounterX>=(p2xpos[7]-8) && CounterX<=(p2xpos[7]+8)) ||
		(CounterY>=(p2ypos[6]-8) && CounterY<=(p2ypos[6]+8) && CounterX>=(p2xpos[6]-8) && CounterX<=(p2xpos[6]+8)) ||
		(CounterY>=(p2ypos[5]-8) && CounterY<=(p2ypos[5]+8) && CounterX>=(p2xpos[5]-8) && CounterX<=(p2xpos[5]+8)) ||
		(CounterY>=(p2ypos[4]-8) && CounterY<=(p2ypos[4]+8) && CounterX>=(p2xpos[4]-8) && CounterX<=(p2xpos[4]+8)) ||
		(CounterY>=(p2ypos[3]-8) && CounterY<=(p2ypos[3]+8) && CounterX>=(p2xpos[3]-8) && CounterX<=(p2xpos[3]+8)) ||
		(CounterY>=(p2ypos[2]-8) && CounterY<=(p2ypos[2]+8) && CounterX>=(p2xpos[2]-8) && CounterX<=(p2xpos[2]+8)) ||
		(CounterY>=(p2ypos[1]-8) && CounterY<=(p2ypos[1]+8) && CounterX>=(p2xpos[1]-8) && CounterX<=(p2xpos[1]+8)) ||
		(CounterY>=(p2ypos[0]-8) && CounterY<=(p2ypos[0]+8) && CounterX>=(p2xpos[0]-8) && CounterX<=(p2xpos[0]+8)) || G1 || G2;	

	always @(posedge DIV_CLK[21])
	begin
		p1xpos[15]<=P1p1xpos;
		p1xpos[14]<=p1xpos[15];
		p1xpos[13]<=p1xpos[14];
		p1xpos[12]<=p1xpos[13];
		p1xpos[11]<=p1xpos[12];
		p1xpos[10]<=p1xpos[11];
		p1xpos[9]<=p1xpos[10];
		p1xpos[8]<=p1xpos[9];
		p1xpos[7]<=p1xpos[8];
		p1xpos[6]<=p1xpos[7];
		p1xpos[5]<=p1xpos[6];
		p1xpos[4]<=p1xpos[5];
		p1xpos[3]<=p1xpos[4];
		p1xpos[2]<=p1xpos[3];
		p1xpos[1]<=p1xpos[2];
		p1xpos[0]<=p1xpos[1];			
		
		p1ypos[15]<=P1p1ypos;
		p1ypos[14]<=p1ypos[15];
		p1ypos[13]<=p1ypos[14];
		p1ypos[12]<=p1ypos[13];
		p1ypos[11]<=p1ypos[12];
		p1ypos[10]<=p1ypos[11];
		p1ypos[9]<=p1ypos[10];
		p1ypos[8]<=p1ypos[9];
		p1ypos[7]<=p1ypos[8];
		p1ypos[6]<=p1ypos[7];
		p1ypos[5]<=p1ypos[6];
		p1ypos[4]<=p1ypos[5];
		p1ypos[3]<=p1ypos[4];
		p1ypos[2]<=p1ypos[3];
		p1ypos[1]<=p1ypos[2];
		p1ypos[0]<=p1ypos[1];
		
	end
	always @(posedge DIV_CLK[21])
	begin
		p2xpos[15]<=P2p2xpos;
		p2xpos[14]<=p2xpos[15];
		p2xpos[13]<=p2xpos[14];
		p2xpos[12]<=p2xpos[13];
		p2xpos[11]<=p2xpos[12];
		p2xpos[10]<=p2xpos[11];
		p2xpos[9]<=p2xpos[10];
		p2xpos[8]<=p2xpos[9];
		p2xpos[7]<=p2xpos[8];
		p2xpos[6]<=p2xpos[7];
		p2xpos[5]<=p2xpos[6];
		p2xpos[4]<=p2xpos[5];
		p2xpos[3]<=p2xpos[4];
		p2xpos[2]<=p2xpos[3];
		p2xpos[1]<=p2xpos[2];
		p2xpos[0]<=p2xpos[1];			
		
		p2ypos[15]<=P2p2ypos;
		p2ypos[14]<=p2ypos[15];
		p2ypos[13]<=p2ypos[14];
		p2ypos[12]<=p2ypos[13];
		p2ypos[11]<=p2ypos[12];
		p2ypos[10]<=p2ypos[11];
		p2ypos[9]<=p2ypos[10];
		p2ypos[8]<=p2ypos[9];
		p2ypos[7]<=p2ypos[8];
		p2ypos[6]<=p2ypos[7];
		p2ypos[5]<=p2ypos[6];
		p2ypos[4]<=p2ypos[5];
		p2ypos[3]<=p2ypos[4];
		p2ypos[2]<=p2ypos[3];
		p2ypos[1]<=p2ypos[2];
		p2ypos[0]<=p2ypos[1];
	end
	
	
	always @(posedge DIV_CLK[21])
	begin
		if(reset)
		begin
			P1p1xpos <= 200;
			P1p1ypos <= 200;
		end
				
		if(P1direction == 2'b00)
		begin
			P1p1ypos<=P1p1ypos-5;
			if(P1p1ypos>upperlim || P1p1ypos<1)
			begin
				//G2<=1;
			end
			
			
		end
		else if(P1direction == 2'b01)
		begin
			P1p1xpos <= P1p1xpos + 5;
			if(P1p1xpos>upperlim || P1p1xpos<1)
			begin
				//G2<=1;
			end
			
			
		end
		else if(P1direction == 2'b10)
		begin
			P1p1ypos<=P1p1ypos+5;
			if(P1p1ypos>upperlim || P1p1ypos<1)
			begin
				//G2<=1;
			end
			
		end
		else if(P1direction == 2'b11)
		begin
			P1p1xpos <= P1p1xpos - 5;
			if(P1p1xpos>upperlim || P1p1xpos<1)
			begin
				//G2<=1;
			end
			
		end
	end

	always @(posedge DIV_CLK[21])
	begin
		if(reset)
		begin
			P2p2xpos <= 400;
			P2p2ypos <= 400;
		end
				
		if(P2direction == 2'b00)
		begin
			P2p2ypos<=P2p2ypos-5;
			
			if(P2p2ypos>upperlim || P2p2ypos<1)
			begin
				//R2<=1;
			end
			
			
		end
		else if(P2direction == 2'b01)
		begin
			P2p2xpos <= P2p2xpos + 5;
			if(P2p2xpos>upperlim || P2p2xpos<1)
			begin
				//R2<=1;
			end
			
			
		end
		else if(P2direction == 2'b10)
		begin
			P2p2ypos<=P2p2ypos+5;
			if(P2p2ypos>upperlim || P2p2ypos<1)
			begin
				//R2<=1;
			end
			
		end
		else if(P2direction == 2'b11)
		begin
			P2p2xpos <= P2p2xpos - 5;
			if(P2p2xpos>upperlim || P2p2xpos<1)
			begin
				//R2<=1;
			end
			
		end
	end
	

	always @(posedge DIV_CLK[21])
	begin
		for(i = 0; i <= 15; i = i + 1)
		begin
			if((p1xpos[i] >= P2p2xpos - 10) && (p1xpos[i] <= P2p2xpos + 10) && (p1ypos[i] >= P2p2ypos - 10) && (p1ypos[i] <= P2p2ypos + 10))
			begin
				R1 = 1;
				G3 = 0;
			end
		end
	end
	
	always @(posedge DIV_CLK[21])
	begin
		for(j = 0; j <= 15; j = j + 1)
		begin
			if((p2xpos[j] >= P1p1xpos - 10) && (p2xpos[j] <= P1p1xpos + 10) && (p2ypos[j] >= P1p1ypos - 10) && (p2ypos[j] <= P1p1ypos + 10))
			begin
				G1 = 1;
				R3 = 0;
			end
		end
	end
	
	
	
	always @(posedge clk)
	begin
		vga_r <= R & R3 & inDisplayArea;
		vga_g <= G & G3 & inDisplayArea;
		vga_b <= B & inDisplayArea;
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  VGA control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	`define QI 			2'b00
	`define QGAME_1 	2'b01
	`define QGAME_2 	2'b10
	`define QDONE 		2'b11
	
	reg [3:0] p2_score;
	reg [3:0] p1_score;
	reg [1:0] state;
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	assign LD0 = (p1_score == 4'b1010);
	assign LD1 = (p2_score == 4'b1010);
	
	assign LD2 = start;
	assign LD4 = reset;
	
	assign LD3 = (state == `QI);
	assign LD5 = (state == `QGAME_1);	
	assign LD6 = (state == `QGAME_2);
	assign LD7 = (state == `QDONE);
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	reg 	[3:0]	SSD;
	wire 	[3:0]	SSD0, SSD1, SSD2, SSD3;
	wire 	[1:0] ssdscan_clk;
	
	assign SSD3 = 4'b1111;
	assign SSD2 = 4'b1111;
	assign SSD1 = 4'b1111;
	assign SSD0 = P1p1ypos[3:0];
	
	// need a scan clk for the seven segment display 
	// 191Hz (50MHz / 2^18) works well
	assign ssdscan_clk = DIV_CLK[19:18];	
	assign An0	= !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	assign An1	= !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
	assign An2	= !( (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
	assign An3	= !( (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
			2'b00:
					SSD = SSD0;
			2'b01:
					SSD = SSD1;
			2'b10:
					SSD = SSD2;
			2'b11:
					SSD = SSD3;
		endcase 
	end	

	// and finally convert SSD_num to ssd
	reg [6:0]  SSD_CATHODES;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES, 1'b1};
	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD)		
			4'b1111: SSD_CATHODES = 7'b1111111 ; //Nothing 
			4'b0000: SSD_CATHODES = 7'b0000001 ; //0
			4'b0001: SSD_CATHODES = 7'b1001111 ; //1
			4'b0010: SSD_CATHODES = 7'b0010010 ; //2
			4'b0011: SSD_CATHODES = 7'b0000110 ; //3
			4'b0100: SSD_CATHODES = 7'b1001100 ; //4
			4'b0101: SSD_CATHODES = 7'b0100100 ; //5
			4'b0110: SSD_CATHODES = 7'b0100000 ; //6
			4'b0111: SSD_CATHODES = 7'b0001111 ; //7
			4'b1000: SSD_CATHODES = 7'b0000000 ; //8
			4'b1001: SSD_CATHODES = 7'b0000100 ; //9
			4'b1010: SSD_CATHODES = 7'b0001000 ; //10 or A
			default: SSD_CATHODES = 7'bXXXXXXX ; // default is not needed as we covered all cases
		endcase
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
endmodule