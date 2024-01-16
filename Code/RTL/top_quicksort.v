//-------------------------------------------------------\\
// 
//-------------------------------------------------------\\
`timescale 1ps/1ps

module top_quicksort #(parameter AW=6, parameter DW=8)(
	input rst,
	input clk,
	input start,
	input [AW-1:0] left,
	input [AW-1:0] right,
	output done
);

wire mem_wr_en;
wire [AW-1:0] mem_addr;
wire [DW-1:0] mem_wr_data;
wire [DW-1:0] mem_rd_data;

QuickSort #(.AW(AW), .DW(DW)) qsort
(
	.rst(rst),
	.clk(clk),
	.start(start),
	.left(left),
	.right(right),
	.done(done),
	.mem_wr_en(mem_wr_en),
	.mem_addr(mem_addr),
	.mem_wr_data(mem_wr_data),
	.mem_rd_data(mem_rd_data)
);

dport_bram #(.AW(6), .DW(DW)) bram
(
.clk(clk),
.wea(mem_wr_en),
.addra(mem_addr),
.dina(mem_wr_data),
.douta(mem_rd_data),
.web(),
.addrb(),
.dinb(),	//unconnected
.doutb()
);

endmodule