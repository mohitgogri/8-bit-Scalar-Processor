`timescale 1ns/1ps

module tb_processor();
//----------------inputs-------------//

reg rst,clk;
wire [7:0] dat;

//----------------outputs------------//

wire wrt,rd;
wire [7:0] add,wrt_data;

//-------------memory----------------//
reg [7:0]  mem_data [0:255]; //memory.
  
//---------------Calling the Main module-----------------------//

processor8bit uut(.rst(rst),.clk(clk),.dat(dat),.add(add),.rd(rd),.wrt(wrt));
 
 //---------------Creating Dump file ----------------------//
initial begin
        $dumpfile("project.vcd");
        $dumpvars(0,tb_processor);
        end
//----------------assigning memory and data bus-----------//

assign  dat=rd? mem_data[add]:8'bz;
assign  wrt_data = wrt ? dat : 8'bz;

//------------------------Initialising Reset---------//
initial begin 
        clk=1'b0;
        rst=1;
        #2 rst=0;
        #2000 $finish ;
        end

initial
   begin
   mem_data[0] = 8'b0111_0000 ; // LLS  0 to GR[3:0]
   mem_data[1] =8'b1000_1000 ; // LMS  8 to GR[7:4]         // Now GR has 80h
   mem_data[2] = 8'b0100_0010 ; // CPR  GR[7:0] to AR[7:0]   // Now AR had 80h
   mem_data[3] = 8'b0010_0100 ; // RDM  - Reads Address 80h  // DR has data 80h   
 
   mem_data[4] = 8'b0100_1001 ; // CPR  DR[7:0] to GR[7:0]   // Now GR had 80h
 
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[5] = 8'b0111_0101 ; // LLS  5 to GR[3:0]
   mem_data[6] = 8'b1000_0100 ; // LMS  4 to GR[7:4]         // Now GR has 45h
   mem_data[7] = 8'b0100_0010 ; // COPY GR[7:0] to AR[7:0]   // Now AR had 45h
   mem_data[8] = 8'b0010_1000 ; // RDM  - Reads Address 45h  // GR has data 45h  
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[9] = 8'b0101_0110 ; // ADD contents of GR to DR
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[10] = 8'b0111_0000 ; // LLS  0 to GR[3:0]
   mem_data[11] = 8'b1000_1000 ; // LMS  8 to GR[7:4]         // Now GR has 80h
   mem_data[12] = 8'b0100_0010 ; // COPY GR[7:0] to AR[7:0]   // Now AR had 80h
   mem_data[13] = 8'b0011_0101 ; // WRM - Writes to address 80h // 80h addr has the sum 
   
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[14] = 8'b0111_0001 ; // LLS  1 to GR[3:0]
   mem_data[15] = 8'b1000_1000 ; // LMS  8 to GR[7:4]         // Now GR has 81h
   mem_data[16] = 8'b0100_0010 ; // CPR  GR[7:0] to AR[7:0]   // Now AR had 81h
   mem_data[17] = 8'b0010_0100 ; // RDM  - Reads Address 81h  // DR has data 81h                     
   mem_data[18] = 8'b0100_1001 ; // CPR  DR[7:0] to GR[7:0]   // Now GR had 81h
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[19] = 8'b0111_0001 ; // LLS  1 to GR[3:0]
   mem_data[20] = 8'b1000_1001 ; // LMS  9 to GR[7:4]         // Now GR has 91h
   mem_data[21] = 8'b0100_0010 ; // COPY GR[7:0] to AR[7:0]   // Now AR had 91h
   mem_data[22] = 8'b0010_1000 ; // RDM  - Reads Address 91h  // GR has data 91h  
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[23] = 8'b0101_0110 ; // ADD contents of GR to DR
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[24] = 8'b0111_0001 ; // LLS  1 to GR[3:0]
   mem_data[25] = 8'b1000_1000 ; // LMS  8 to GR[7:4]         // Now GR has 81h
   mem_data[26] = 8'b0100_0010 ; // COPY GR[7:0] to AR[7:0]   // Now AR had 81h
   mem_data[27] = 8'b0011_0101 ; // WRM - Writes to address 81h // 80h addr has the sum 
   // ----------------------------------------------------------------------------------------------------- 
   // Subtraction and Storing the Difference  
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[28] = 8'b0111_0010 ; // LLS  2 to GR[3:0]
   mem_data[29] = 8'b1000_1001 ; // LMS  9 to GR[7:4]         // Now GR has 92h
   mem_data[30] = 8'b0100_0010 ; // CPR  GR[7:0] to AR[7:0]   // Now AR had 92h
   mem_data[31] = 8'b0010_0100 ; // RDM  - Reads Address 92h  // DR has data 92h                     
   
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[32] = 8'b0111_0010 ; // LLS  2 to GR[3:0]
   mem_data[33] = 8'b1000_1000 ; // LMS  8 to GR[7:4]         // Now GR has 82h
   mem_data[34] = 8'b0100_0010 ; // COPY GR[7:0] to AR[7:0]   // Now AR had 82h
   mem_data[35] = 8'b0010_1000 ; // RDM  - Reads Address 82h  // GR has data 82h  
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[36] = 8'b0110_0110 ; // SUB GR fro DR and store in DR
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[37] = 8'b0111_0010 ; // LLS  2 to GR[3:0]
   mem_data[38] = 8'b1000_1000 ; // LMS  8 to GR[7:4]         // Now GR has 82h
   mem_data[39] = 8'b0100_0010 ; // COPY GR[7:0] to AR[7:0]   // Now AR had 82h
   mem_data[40] = 8'b0011_0101 ; // WRM - Writes to address 82h // 82h addr has the diff
   // ----------------------------------------------------------------------------------------------------- 
   // Store Carry  
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[41] = 8'b0111_0000 ; // LLS  0 to GR[3:0]
   mem_data[42] = 8'b1000_1111 ; // LMS  F to GR[7:4]         // Now GR has F0h
   mem_data[43] = 8'b0100_0010 ; // COPY GR[7:0] to AR[7:0]   // Now AR had F0h
   mem_data[44] = 8'b1001_1001 ; // COPY contents of FLAG to LSB of GR 
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[45] = 8'b0011_1010 ; // WRM - Writes to address F0h value of GR
   // ----------------------------------------------------------------------------------------------------- 
   mem_data[46] = 8'b0000_0000 ; // NOP  
   mem_data[47] = 8'b0000_0000 ; // NOP  
   // ----------------------------------------------------------------------------------------------------- 
   // JUMP to address location 00(dec) = 00(hex)
   mem_data[48] = 8'b0111_0000 ; // LLS 4'h0 to GR[3:0]
   mem_data[49] = 8'b1000_0000 ; // LMS 4'h0 to GR[7:4]       // Now GR has 00h
   mem_data[50] = 8'b0100_0010 ; // COPY GR[7:0] to AR[7:0]   // Now AR had 00h
   mem_data[51] = 8'b0001_0000 ; // JMP
   mem_data[52] = 8'b0000_0000 ; // NOP  
   mem_data[53] = 8'b0000_0000 ; // NOP  
   mem_data[54] = 8'b0000_0000 ; // NOP  
   mem_data[55] = 8'b0000_0000 ; // NOP  
   mem_data[56] = 8'b0000_0000 ; // NOP  
   
 //----------------------------------------------------------------------------------------------------- 
   // Jump to Zero-th Location
   mem_data[124] = 8'b0111_0000 ; // LLS
   mem_data[125] = 8'b1000_0000 ; // LMS
   mem_data[126] = 8'b0100_0010 ; // COPY contents of GR to AR
   mem_data[127] = 8'b0001_0000 ; // JMP to Address = 00h
  
   mem_data[69]=8'b0100_0101;
   mem_data[128]=8'b0100_0000;
   mem_data[129]=8'b0101_0110;
   mem_data[145]=8'b0110_0110;
   mem_data[146]=8'b0111_0101;
   mem_data[130]=8'b0011_0011;
   // ----------------------------------------------------------------------------------------------------- 
  
   end
//----------------Initialising Clocl----------------------// 
initial begin  
	forever clk=#5.1 ~clk;
	end
//---------------monitoring write  data-------------------//
always @(posedge clk)
	begin
	if(wrt==1)
	mem_data[add] <= wrt_data;
	end


endmodule
 
