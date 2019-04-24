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
	
	
	
	
	

	
	reg R1;
	reg R2=0;
	reg	R3=0;
	reg	R4=0;
	reg	R5=0;
	reg B1=0;
	reg flag=1;

	
	
	wire R;//CounterY>=(100) && CounterY<=(200) && CounterX>=(100) && CounterX<=(200);//CounterY>=(yPosition-yPath) && CounterY<=(yPosition+yPath) && CounterX>=(xPosition-xPath) && CounterX<=(xPosition+xPath);
	assign R=R1;
	reg G = 0;//CounterX>100 && CounterX<200 && CounterY[8:5]==7;
	wire B = B1;

	
	reg [9:0] P1xPos = 200;
	reg [9:0] P1yPos = 200;
	
	reg [9:0] P2xPos = 10;
	reg [9:0] P2yPos = 10;

	reg [1:0] P1direction=2'b00;
	reg [1:0] P2direction;
	
	//00 = up
	//01 = right
	//10 = down
	//11 = left
	
	
	reg P1win=0;
	reg P2win=0;
	
	reg upperlim = 500;
	reg blockSize = 20;
	reg halfBlock = 10;
	
	
		

	
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
		
		

	reg [8:0] R3pos=10; 
	reg R3flag=1;
	reg [8:0] R4pos=100; 
	reg R4flag=0;
	reg [8:0] R5pos=10; 
	reg R5flag=1;
	reg [9:0] xpos[3:0];
	reg [9:0] ypos[3:0];
	
	initial begin
		xpos[3] = 200;
		xpos[2] = 200;
		xpos[1] = 200;
		xpos[0] = 200;
		
		ypos[3] = 200;
		ypos[2] = 200;
		ypos[1] = 200;
		ypos[0] = 200;
	end
	
	integer i;
	
	//assign R = (CounterY>=(ypos[3]-10) && CounterY<=(ypos[3]+10) && CounterX>=(xpos[3]-10) && CounterX<=(xpos[3]+10)) ||
	//				(CounterY>=(ypos[2]-10) && CounterY<=(ypos[2]+10) && CounterX>=(xpos[2]-10) && CounterX<=(xpos[2]+10)) ||
	//				(CounterY>=(ypos[1]-10) && CounterY<=(ypos[1]+10) && CounterX>=(xpos[1]-10) && CounterX<=(xpos[1]+10)) ||
	//				(CounterY>=(ypos[0]-10) && CounterY<=(ypos[0]+10) && CounterX>=(xpos[0]-10) && CounterX<=(xpos[0]+10));
	
	always @(posedge DIV_CLK[21])
	begin
			xpos[3]<=P1xPos;
			xpos[2]<=xpos[3];
			xpos[1]<=xpos[2];
			xpos[0]<=xpos[1];
			
			
			ypos[3]<=P1yPos;
			ypos[2]<=ypos[3];
			ypos[1]<=ypos[2];
			ypos[0]<=ypos[1];
			
			//R2<=(CounterY>=(P1yPos-10) && CounterY<=(P1yPos+10) && CounterX>=(P1xPos-10) && CounterX<=(P1xPos+10));
			
			for(i=0;i<=3;i=i+1)
			begin
				R1 = (CounterY>=(ypos[i]-10) && CounterY<=(ypos[i]+10) && CounterX>=(xpos[i]-10) && CounterX<=(xpos[i]+10)) | R1;
			end 
			/*
			R3<=(CounterY>=(290) && CounterY<=(310) && CounterX>=(R3pos-10) && CounterX<=(R3pos+10));
			
			R4<=(CounterY>=(90) && CounterY<=(110) && CounterX>=(R4pos-10) && CounterX<=(R4pos+10));
						
			R5<=(CounterY>=(R5pos-10) && CounterY<=(R5pos+10) && CounterX>=(90) && CounterX<=(110));
			*/
			//flag=0;
			
			
			
			B1<=(CounterY>=(200-10) && CounterY<=(200+10) && CounterX>=(200-10) && CounterX<=(200+10));
		
	end
	
	
	
	always @(posedge DIV_CLK[21])
	begin
		/*
		if(reset)
		begin
			P1xPos <= 25;
			P1yPos <= 25;
		end
		*/
		if(R3flag==1)
				R3pos<=R3pos+4;
			else
				R3pos<=R3pos-4;
			if(R3pos>399)
			begin
				R3flag=0;
			end
			if(R3pos<9)
				R3flag=1;
		if(R4flag==1)
				R4pos<=R4pos+4;
			else
				R4pos<=R4pos-4;
			if(R4pos>399)
			begin
				R4flag=0;
			end
			if(R4pos<9)
				R4flag=1;
				
				
				
		if(R5flag==1)
				R5pos<=R5pos+4;
			else
				R5pos<=R5pos-4;
			if(R5pos>399)
			begin
				R5flag=0;
			end
			if(R5pos<9)
				R5flag=1;
				
				
		if(P1direction == 2'b00)
		begin
			P1yPos<=P1yPos-20;
			
			if(P1yPos>upperlim || P1yPos<1)
			begin
				P2win<=1;
			end
			
			
		end
		else if(P1direction == 2'b01)
		begin
			P1xPos <= P1xPos + 20;
			if(P1xPos>upperlim || P1xPos<1)
			begin
				P2win<=1;
			end
			
			
		end
		else if(P1direction == 2'b10)
		begin
			P1yPos<=P1yPos+20;
			if(P1yPos>upperlim || P1yPos<1)
			begin
				P2win<=1;
			end
			
		end
		else if(P1direction == 2'b11)
		begin
			P1xPos <= P1xPos - 20;
			if(P1xPos>upperlim || P1xPos<1)
			begin
				P2win<=1;
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