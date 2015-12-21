 module processor8bit (input rst,
		input 	     clk,
		inout wire [7 :0] dat,
		output reg [7:0] add,
		output reg 	     rd,
		output reg 	     wrt);

   //-------------Declaring Registers----------------------//

   reg [7:0]   ar,dr,gr,pr;
   reg [3:0]   fr;
   reg         en,c_in;
   reg  [4:0]  state,nxtstate;
   reg [7:0]   data;
   reg [7:0]   w,z;
   reg [7:0]   data1,data2;
   
   //------------ Declaring Intermideate signals-----------//
   
   wire [7:0]  sum;
   wire [7:0]  dataout;
   wire [7:0]  opcode;
   wire        cout;
   
   //-------------Declaring Parameters---------------------//
   
   parameter reset=4'b0000;
   parameter fetch=4'b0001;
   parameter update=4'b0010;
   parameter execute=4'b0011;
   parameter load=4'b0100;
   parameter read=4'b0101;
   parameter write=4'b0110;
   parameter nop=4'b0000;
   parameter jmp=4'b0001;
   parameter rdm=4'b0010;
   parameter wrm=4'b0011;
   parameter cpr=4'b0100;
   parameter adder=4'b0101;
   parameter sub=4'b0110;
   parameter lls=4'b0111;
   parameter lms=4'b1000;
   parameter cfr=4'b1001;
  
   //--------------Calling Alu-----------------------------//
   
   alu(.sum(sum),.cout(cout),.w(w),.z(z),.c_in(c_in),.en(en),.clk(clk));
  
   //---------------Operation with Databus ----------------//
  
   assign opcode=rd?dat:8'bz;
   assign dat=wrt?data:8'bz;
  
   //---------------Execution of Processor-----------------//
  
   always @ (posedge clk or posedge rst)
   begin 
   if(rst)
   nxtstate<=4'b0000;
   else
   begin
   state<=nxtstate;
   $monitor( " value of Ar=%h,Dr=%h,GR=%h,Pr=%h  " ,ar,dr,gr,pr);
   case(nxtstate)
 //-------------------Reset State---------------------------//
   reset:begin  pr<=8'b0;
	            ar<=8'b0;
	        	gr<=8'b0;
	        	dr<=8'b0;
	        	fr<=4'b0;
	        	data<=8'b0;
	        	nxtstate<=fetch;
         end
//---------------------Fetch State--------------------------//
   fetch:begin  add<=pr;
                rd<=1'b1;
                wrt<=1'b0;
                nxtstate<=update;
         end
 //--------------------Update and Decode  state---------------------------//
   update:begin rd<=1'b0;
                pr<=pr+1;
                data1=opcode[3:0];
                data2=opcode[7:4];
                nxtstate<=execute;
          end
//----------------------Execution State-------------------------------//
   execute:begin

                case(data2)

           nop: begin 							// No Operation Case 
	        	$display ("No operation");
	        	nxtstate<=fetch;
	        	end
     
           jmp: begin 							// Jump State
	        	pr<=ar;
	        	nxtstate<=fetch;
	        	end
	       
           rdm: begin 						    // Read From Memory
                add<=ar;
	        	rd<=1'b1;
	        	wrt<=1'b0;
	        	nxtstate<=read;
	        	end
	   
           wrm: begin							 // Write onto Memory
                add<=ar;
	        	rd<=1'b0;
	        	wrt<=1'b0;
	        	nxtstate<=write;
	        	end
	        	
           cpr: begin 							 // Copy 1 register value to other.
	        	case (data1[3:0])
	        	4'b0000:ar<=ar;
	        	4'b0100:dr<=ar; 
	      		4'b1000:gr<=ar; 
	     		4'b1100:pr<=ar; 
	    		4'b0001:ar<=dr;
	     		4'b0101:dr<=dr;
	     		4'b1001:gr<=dr;
	     		4'b1101:pr<=dr; 
	     		4'b0010:ar<=gr;
	      		4'b0110:dr<=gr;
	     		4'b1010:gr<=gr;
	     		4'b1110:pr<=gr;
	      		4'b0011:ar<=pr;
	      		4'b0111:dr<=pr;
	      		4'b1011:gr<=pr;
	      		4'b1111:pr<=pr;
	 	        endcase 
	    		nxtstate<=fetch;
	    		end
	    											
         adder: begin 								// Addition of two Registers
       		    c_in<=1'b0;
     		    en<=1'b1;
	     		case (data1[3:0])					// Source Destination case.
	    		4'b0000:begin w<=ar;
	    					  z<=ar;
	    					  nxtstate<=load;
	    				end
				4'b0100:begin w<=dr;
	    					  z<=ar;
	            			  nxtstate<=load;
	                          end
	      		4'b1000:begin w<=gr;
	    					  z<=ar;
	   						  nxtstate<=load;
	    				end
	    		4'b1100:begin w<=ar;
	   					      z<=pr;
	      					  nxtstate<=load;
	    				end
	    		4'b0001:begin w<=dr;
	    					  z<= ar;
	   						  nxtstate<=load;
	    				end
	    		4'b0101:begin w<=dr;
	    					  z<=dr;
	   						  nxtstate<=load;
	    				end
	    		4'b1001:begin w<=dr; 
	    					  z<=gr;
	   						  nxtstate<=load;
	    				end
	   		    4'b1101:begin w<=dr;
	    					  z<=pr;
	    					  nxtstate<=load;
	    				end
	    		4'b0010:begin w<=gr;
	    					  z<=ar;
	 						  nxtstate<=load;
	    				end
	      		4'b0110:begin w<=gr;
	      					  z<=dr;
	     					  nxtstate<=load;
	   				    end
	      
	    	    4'b1010:begin w<=gr;
	      					  z<=gr;
	     					  nxtstate<=load; 
	    				end
	    		4'b1110:begin w<=gr;
	      					  z<=pr;
	      					  nxtstate<=load;
	    				end
	      		4'b0011:begin w<=pr;
	      					  z<=ar;
	      					  nxtstate<=load;
	    				end
	    		4'b0111:begin w<=pr;
	  						  z<=dr;
	   						  nxtstate<=load;
	    				end
	    		4'b1011:begin w<=pr;
	    					  z<=gr;
	    					  nxtstate<=load;
	   				    end
	      		4'b1111:begin w<=pr;
	      					  z<=pr;
	      					  nxtstate<=load;
	    				end
	    		endcase
	    	    end
       
       	   sub: begin							// subtraction
      		    c_in<=1'b0;
                en<=1'b0;						// enable mode to enable Mux in Alu
	            case (data1[3:0])				//Source Destination Case 
	    		4'b0000:begin w<=ar;
	    					  z<=ar;
	    					  nxtstate<=load;
	    				end
				4'b0100:begin w<=dr;
	    					  z<=ar;
	            			  nxtstate<=load;
	                          end
	      		4'b1000:begin w<=gr;
	    					  z<=ar;
	   						  nxtstate<=load;
	    				end
	    		4'b1100:begin w<=ar;
	   					      z<=pr;
	      					  nxtstate<=load;
	    				end
	    		4'b0001:begin w<=dr;
	    					  z<= ar;
	   						  nxtstate<=load;
	    				end
	    		4'b0101:begin w<=dr;
	    					  z<=dr;
	   						  nxtstate<=load;
	    				end
	    		4'b1001:begin w<=dr; 
	    					  z<=gr;
	   						  nxtstate<=load;
	    				end
	   		    4'b1101:begin w<=dr;
	    					  z<=pr;
	    					  nxtstate<=load;
	    				end
	    		4'b0010:begin w<=gr;
	    					  z<=ar;
	 						  nxtstate<=load;
	    				end
	      		4'b0110:begin w<=gr;
	      					  z<=dr;
	     					  nxtstate<=load;
	   				    end
	      
	    	    4'b1010:begin w<=gr;
	      					  z<=gr;
	     					  nxtstate<=load; 
	    				end
	    		4'b1110:begin w<=gr;
	      					  z<=pr;
	      					  nxtstate<=load;
	    				end
	      		4'b0011:begin w<=pr;
	      					  z<=ar;
	      					  nxtstate<=load;
	    				end
	    		4'b0111:begin w<=pr;
	  						  z<=dr;
	   						  nxtstate<=load;
	    				end
	    		4'b1011:begin w<=pr;
	    					  z<=gr;
	    					  nxtstate<=load;
	   				    end
	      		4'b1111:begin w<=pr;
	      					  z<=pr;
	      					  nxtstate<=load;
	    				end
	    		endcase
    			end
       
           lls: begin 								//LLs ,,Copy to Least bits of GR
            	gr[3:0]<=data1[3:0];
       			nxtstate<=fetch;
       		    end
       								
     	   lms: begin 								// LMS : Copy to Most signficant bits
       			gr[7:4]<=data1[3:0];
       			nxtstate<=fetch;
      			end
       	
      	   cfr: begin 								// Copy value of Flag register to GR
       			gr[3:0]<= fr[3:0];
       			nxtstate<=fetch;
       			end

		   endcase
		   end

  	 load: begin 									// Load value of addition and Subtraction
     	   case (data1[3:2])	
      		2'b00:ar<=sum; 
      		2'b01:dr<=sum;
      		2'b10:gr<=sum; 
     	    2'b11:pr<=sum; 
      		endcase
      		begin
   			if(sum==8'b0) fr[3]<=1;
   			else fr[3]<=0;
   			if(sum[7]==1) fr[2]<=1; 
   			else fr[2]<=0;
   			if(cout==1) fr[1]<=1;
   			else fr[1]<=0;
   			if(sum[7]^cout==1) fr[0]<=1;
   			else fr[0]<=0;
			end
      		nxtstate<=fetch;
      		end

      read: begin										// Read frm memory
			case(data1[3:2])
	   		2'b00:ar<=dat;
	   		2'b01:dr<= dat;
	   		2'b10:gr<=dat;
	   		2'b11:pr<=dat;
	   		endcase  
	  		nxtstate<=fetch;
	  		end	
 	write : begin 										// Write in Memory
            wrt<= 1'b1;
	 	    case(data1[1:0])
	   		2'b00:data<=ar;
	   		2'b01:data<=dr;
	   		2'b10:data<=gr;
	   		2'b11:data<=pr;
	   		endcase
	   		nxtstate<=fetch;
	   		end 
   default: nxtstate<=fetch;

   endcase
   end


 end
 endmodule

//------------------Alu Module-------------------------//
 module alu(sum,cout,w,z,c_in,en,clk);

//-----------InputPorts--------------------------------//
 input [7:0] w,z;
 input c_in,en,clk;
 
//------------Output Ports------------------------// 
 output  [7:0] sum;
 output cout;

//-------------Local Variables---------------------// 
 reg [7:0] b;
 
 
 always @ (*)
 begin 
 if(en==1'b1) begin 
 b=z;
 end
 else begin
 b=-z;
 end
 end 
 add x1(sum,cout,w,b,c_in);
 endmodule

 module add(sum,cout,w,b,c_in);
 input c_in;
 output  [7:0]sum;
 output cout;
 input [7:0]w,b;
 wire c_in4;
 Add_rca_4 M1 (sum[3:0], c_in4, w[3:0], b[3:0], c_in);
 Add_rca_4 M2 (sum[7:4], c_in8, w[7:4], b[7:4], c_in4);
 endmodule

 module Add_rca_4 (sum, cout, w, b, c_in);
 output  [3: 0] sum;
 output cout;
 input [3: 0] w, b;
 input c_in;
 wire c_in2, c_in3, c_in4;
 Add_full M1 (sum[0], c_in2, w[0], b[0], c_in);
 Add_full M2 (sum[1], c_in3, w[1], b[1], c_in2);
 Add_full M3 (sum[2], c_in4, w[2], b[2], c_in3);
 Add_full M4 (sum[3], cout, w[3], b[3], c_in4);
 endmodule

 module Add_full (sum, cout, w, b, c_in);
 output   sum, cout;
 input w, b, c_in;
 wire w1, w2, w3;
 Add_half M1 (w1, w2, w, b);
 Add_half M2 (sum, w3, w1, c_in);
 or M3 (cout, w2, w3);
 endmodule

 module Add_half (sum, cout, w, b);
 output  sum, cout;
 input w, b;
 xor M1 (sum, w, b);
 and M2 (cout, w, b);
 endmodule 

