//-------------------------------------------------------\\
// 
//-------------------------------------------------------\\

module dport_bram #(parameter AW=18, parameter DW=16)
  (//
  input clk,
  //
  input wea,
  input [AW-1:0] addra,
  input [DW-1:0] dina,
  output reg [DW-1:0] douta={DW{1'b0}},
  //
  input web,
  input [AW-1:0] addrb,
  input [DW-1:0] dinb,
  output reg [DW-1:0] doutb={DW{1'b0}}
	);

//-------------------------------------------------------\\

reg [DW-1:0] RAM[0:(2**AW)-1];
reg [AW-1:0] addrb_2 = 0;
reg [AW-1:0] addra_2 = 0;

//-------------------------------------------------------\\

always @(posedge clk) begin : READ_PORT_A
  douta <= RAM[addra];
	if(wea)
    RAM[addra] <= dina;
end

//-------------------------------------------------------\\

always @(posedge clk) begin : READ_PORT_B
  doutb <= RAM[addrb];
	if(web) begin
    RAM[addrb] <= dinb;
	end
end

//-------------------------------------------------------\\

reg [AW-1:0] i;

/*
initial begin : INIT_MEM
	//Initialize to all Zero's
	for(i=0; i<(2**AW);i=i+1) begin
		RAM[i] = i;
	end
end
*/

initial begin : INIT_MEM
	//Initialize from text file
	$readmemh("init_bram.txt", RAM);
end

//-------------------------------------------------------\\

endmodule
