`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Da Cheng
//////////////////////////////////////////////////////////////////////////////////
module vga_demo(ClkPort, vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b, Sw0, Sw1, btnU, btnD, btnL, btnR,
	St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7);
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
	
	reg [9:0] P1xPos = 25;
	reg [9:0] P1yPos = 25;
	
	reg [9:0] P2xPos = 25;
	reg [9:0] P2yPos = 25;

	reg [1:0] P1direction;
	reg [1:0] P2direction;
	
	//00 = up
	//01 = right
	//10 = down
	//11 = left
	
	reg [8:0] p1RecentX [3:0];
	reg [8:0] p1RecentY [3:0];
	reg [8:0] p2RecentX [3:0];
	reg [8:0] p2RecentY [3:0];
	
	reg [1:0] p1ArrayIndex;
	reg [1:0] p2ArrayIndex;
	reg [1:0] loopIndexI;
	reg [1:0] loopIndexJ;
	reg P1win=0;
	reg P2win=0;
	
	reg upperlim = 500;
	reg blockSize = 20;
	reg halfBlock = 10;
	
	reg [1:0] P1lastDirections [3:0];
	reg [1:0] P1lastDirectionIndex;
	reg [9:0] P1startX;
	reg [9:0] P1startY;
	reg [9:0] P1endX;
	reg [9:0] P1endY;
		
	always @(posedge DIV_CLK[21])
		begin
			if(reset)
			begin
				P1direction <= 2'b00;
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
		P1lastDirections[0] <= P1lastDirections[1];
		P1lastDirections[1] <= P1lastDirections[2];
		P1lastDirections[2] <= P1lastDirections[3];
		P1lastDirections[3] <= P1direction;
	end
	always @(posedge DIV_CLK[21])
	begin
		P1startX = P1xPos;
		P1startY = P1yPos;
		P1endX = P1xPos;
		P1endY = P1yPos;
		for(P1lastDirectionIndex = 3; P1lastDirectionIndex >= 0; P1lastDirectionIndex = P1lastDirectionIndex - 1)
		begin
			if(P1lastDirections[P1lastDirectionIndex] == 2'b00)
			begin
				P1endY <= P1endY + blockSize;
			end
			else if(P1lastDirections[P1lastDirectionIndex] == 2'b01)
			begin
				P1endX <= P1endX - blockSize;
			end
			else if(P1lastDirections[P1lastDirectionIndex] == 2'b10)
			begin
				P1endY <= P1endY - blockSize;
			end
			else if(P1lastDirections[P1lastDirectionIndex] == 2'b11)
			begin
				P1endX <= P1endX + blockSize;
			end
			//draw this 20 x 20 rectangle - todo
			/*
			
			if(P1lastDirectionIndex == 3)
				R2 <= (CounterY >= (P1endY-halfBlock) && CounterY<=(P1endY + halfBlock) && CounterX >= (P1endX-halfBlock) && CounterX <= (P1endX + halfBlock);
			else if(P1lastDirectionIndex == 2)
				R3 <= (CounterY >= (P1endY-halfBlock) && CounterY<=(P1endY + halfBlock) && CounterX >= (P1endX-halfBlock) && CounterX <= (P1endX + halfBlock);
			else if(P1lastDirectionIndex == 1)
				R4 <= (CounterY >= (P1endY-halfBlock) && CounterY<=(P1endY + halfBlock) && CounterX >= (P1endX-halfBlock) && CounterX <= (P1endX + halfBlock);
			else
				R5 <= (CounterY >= (P1endY-halfBlock) && CounterY<=(P1endY + halfBlock) && CounterX >= (P1endX-halfBlock) && CounterX <= (P1endX + halfBlock);
			*/
			//update vals
			P1startX <= P1endX;
			P1startY <= P1endY;
		end
		R1 <= R2 || R3 || R4 || R5;
	end
	always @(posedge DIV_CLK[21])
	begin
		if(reset)
		begin
			P1xPos <= 25;
			P1yPos <= 25;
		end
		
		if(P1direction == 2'b00)
		begin
			P1yPos<=P1yPos-1;
			
			if(P1yPos>upperlim || P1yPos<1)
			begin
				P2win<=1;
			end
			//else if(board[P1xPos][P1yPos]==1 || board[P1xPos][P1yPos]==2)
			//begin
			//	P2win<=1;
			//end
			else
			begin
				p1ArrayIndex <= p1ArrayIndex + 1;
				if(p1ArrayIndex == 3)
					p1ArrayIndex <= 0;
				p1RecentX[p1ArrayIndex] <= P1xPos;
				p1RecentY[p1ArrayIndex] <= P1yPos;
			end
		end
		else if(P1direction == 2'b01)
		begin
			P1xPos <= P1xPos + 1;
			if(P1xPos>upperlim || P1xPos<1)
			begin
				P2win<=1;
			end
			//else if(board[P1xPos][P1yPos]==1 || board[P1xPos][P1yPos]==2)
			//begin
			//	P2win<=1;
			//end
			else
			begin
				p1ArrayIndex <= p1ArrayIndex + 1;
				if(p1ArrayIndex == 3)
					p1ArrayIndex <= 0;
				p1RecentX[p1ArrayIndex] <= P1xPos;
				p1RecentY[p1ArrayIndex] <= P1yPos;
			end
		end
		else if(P1direction == 2'b10)
		begin
			P1yPos<=P1yPos+1;
			if(P1yPos>upperlim || P1yPos<1)
			begin
				P2win<=1;
			end
			//else if(board[P1xPos][P1yPos]==1 || board[P1xPos][P1yPos]==2)
			//begin
			//	P2win<=1;
			//end
			else
			begin
				p1ArrayIndex <= p1ArrayIndex + 1;
				if(p1ArrayIndex == 3)
					p1ArrayIndex <= 0;
				p1RecentX[p1ArrayIndex] <= P1xPos;
				p1RecentY[p1ArrayIndex] <= P1yPos;
			end
		end
		else if(P1direction == 2'b11)
		begin
			P1xPos <= P1xPos - 1;
			if(P1xPos>upperlim || P1xPos<1)
			begin
				P2win<=1;
			end
			//else if(board[P1xPos][P1yPos]==1 || board[P1xPos][P1yPos]==2)
			//begin
			//	P2win<=1;
			//end
			else
			begin
				p1ArrayIndex <= p1ArrayIndex + 1;
				if(p1ArrayIndex == 3)
					p1ArrayIndex <= 0;
				p1RecentX[p1ArrayIndex] <= P1xPos;
				p1RecentY[p1ArrayIndex] <= P1yPos;
			end
		end
	end
	always @(posedge DIV_CLK[21])
	begin
		for(loopIndexI = 0; loopIndexI < 4; loopIndexI = loopIndexI + 1)
		begin
			for(loopIndexJ = 0; loopIndexJ < 4; loopIndexJ = loopIndexJ + 1)
			begin
				if((p1RecentX[loopIndexI] >= p2RecentX[loopIndexJ] - halfBlock && p1RecentX[loopIndexI] <= p2RecentX[loopIndexJ] + halfBlock) &&
					(p1RecentY[loopIndexI] >= p2RecentY[loopIndexJ] - halfBlock && p1RecentY[loopIndexI] <= p2RecentY[loopIndexJ] + halfBlock))
				begin
					if(p1ArrayIndex == loopIndexI || p1ArrayIndex == loopIndexI-1)
					begin
						P2win <= 1;
					end
					else
					begin
						P1win <= 1;
					end
				end
			end
		end
	end
	reg R = 0;//CounterY>=(100) && CounterY<=(200) && CounterX>=(100) && CounterX<=(200);//CounterY>=(yPosition-yPath) && CounterY<=(yPosition+yPath) && CounterX>=(xPosition-xPath) && CounterX<=(xPosition+xPath);
	reg G = 0;//CounterX>100 && CounterX<200 && CounterY[8:5]==7;
	reg B = 0;
	
	integer i;
	integer j;
	
	always @(posedge clk)
	begin
		for(i=0; i<upperlim; i=i+1)
		begin
			for (j=0; j<upperlim; j=j+1)
			begin
				//if(board[i][j]==1)
				begin
					R = CounterY>=(100) && CounterY<=(200) && CounterX>=(100) && CounterX<=(200);//R=CounterY>=(P1yPos-2) && CounterY<=(P1yPos+2) && CounterX>=(P1xPos-2) && CounterX<=(P1xPos+2);//R|((CounterX>=(i*5+2) && (CounterX<=(i*5-2))) && (CounterY>=(j*5+2) && (CounterY<=(j*5-2))));
				end
			end
		end
	end
	always @(posedge clk)
	begin
		vga_r <= R & inDisplayArea;
		vga_g <= G & inDisplayArea;
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
	assign SSD0 = P1yPos[3:0];
	
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