//-------------------------------------------------------\\
// 
//-------------------------------------------------------\\
`timescale 1ps/1ps

module tb_quicksort;

localparam AW = 6;
localparam DW = 8;

reg rst = 1'b1;
reg clk = 1'b0;
//
reg start = 1'b0;
reg [AW-1:0] left = {AW{1'b0}};
reg [AW-1:0] right = {AW{1'b0}};
//
wire done;
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

always begin
	#31250 clk = ~clk;
end 

initial begin

	repeat(25) 	@(posedge clk);

	rst = 0;
	
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	start = 1'b1;
	left = 6'd0;
	right = 6'd63;
	
	@(posedge clk);
	start = 1'b0;
	
	@(posedge clk);
	
	while(done == 0)
	begin
		@(posedge clk);	
	end
	
	repeat(25) 	@(posedge clk);

	$stop;
end


endmodule