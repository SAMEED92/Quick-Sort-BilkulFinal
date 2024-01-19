//-------------------------------------------------------\\
// 
//-------------------------------------------------------\\

module QuickSort #(parameter AW=6, parameter DW=8)
(
	//
	input 								rst,
	input 								clk,
	//
	input 								start,
	input 			[AW-1:0] 	left,
	input 			[AW-1:0] 	right,
	output reg 						done = 1'b0,
	//
	output reg 						mem_wr_en = 1'b0,
	output reg 	[AW-1:0] 	mem_addr,
	output reg 	[DW-1:0] 	mem_wr_data,
	input				[DW-1:0] 	mem_rd_data
);

//-------------------------------------------------------\\
//Data Path Signals
reg [AW-1:0] left_loc 	= {AW{1'b0}};
reg [AW-1:0] right_loc 	= {AW{1'b0}};
reg [AW-1:0] left_ptr 	= {AW{1'b0}};
reg [AW-1:0] right_ptr 	= {AW{1'b0}};
reg [AW-1:0] pivot_loc 	= {AW{1'b0}};
//
reg [DW-1:0] left_val 	= {DW{1'b0}};
reg [DW-1:0] right_val 	= {DW{1'b0}};
reg [DW-1:0] pivot_val 	= {DW{1'b0}};
//
reg [1:0] step_cnt = 2'd0;
//
reg [AW-1:0] mux_left_loc;
reg [AW-1:0] mux_right_loc;
reg [AW-1:0] mux_left_ptr;
reg [AW-1:0] mux_right_ptr;

//Control Path Signals
//
reg leftloc_load_en = 1'b0;
reg [1:0] mux_left_loc_sel = 2'd0;
//
reg rightloc_load_en = 1'b0;
reg [1:0] mux_right_loc_sel = 2'd0;
//
reg leftptr_load_en = 1'b0;
reg [1:0] mux_left_ptr_sel = 2'd0;
//
reg rightptr_load_en = 1'b0;
reg [1:0] mux_right_ptr_sel = 2'd0;
//
reg pivotloc_load_en = 1'b0;
//
reg leftval_load_en = 1'b0;
//
reg rightval_load_en = 1'b0;
//
reg pivotval_load_en = 1'b0;

//
reg step_cnt_inc_en = 1'b0;
//
reg clear_all_reg = 1'b0;
//
reg [1:0] mux_mem_addr_sel = 2'd0; 
reg [1:0] mux_mem_wr_data_sel = 2'd0; 
//
localparam 	SM_IDLE 							= 5'd0,
						SM_CLR 								= 5'd1,
						SM_WAIT 							= 5'd2,
						SM_LOAD_LOC 					= 5'd3,
						SM_LOAD_PTR 					= 5'd4,
						SM_LOAD_PIVOT_VAL 		= 5'd5,
						SM_LOAD_LEFT_VAL 			= 5'd6,
						SM_LOAD_RIGHT_VAL 		= 5'd7,
						SM_LEFT_PTR_CHECK 		= 5'd8,
						SM_LEFT_PTR_INC 			= 5'd9,
						SM_LEFT_PTR_INC_1 		= 5'd10,
						SM_LEFT_PTR_INC_2 		= 5'd11,
						SM_RIGHT_PTR_CHECK 		= 5'd12,
						SM_RIGHT_PTR_INC 			= 5'd13,
						SM_RIGHT_PTR_INC_1 		= 5'd14,
						SM_RIGHT_PTR_INC_2 		= 5'd15,
						SM_LR_PTR_COMPARE 		= 5'd16,
						SM_LEFT_PTR_RIGHT_VAL	= 5'd17,
						SM_RIGHT_PTR_LEFT_VAL	= 5'd18,
						SM_INC_LR_PTR			= 5'd19,
						SM_LEFT_PTR_PIVOT_VAL	= 5'd20,	
						SM_PIVOT_PT_LEFT_VAL	= 5'd21,
						SM_UPD_PIVOT_LOC		= 5'd22,
						SM_ADD_LOC_SHIFT_RIGHT	= 5'd23,
						SM_ADD_LOC_SHIFT_LEFT	= 5'd24,
						SM_ADD_LOC_SHIFT_1		= 5'd25,
						SM_ADD_LOC_SHIFT_CHECK	= 5'd26,
						SM_UPD_LOC_ARR			= 5'd27,
						SM_UPD_LOC_ARR_1		= 5'd28,
						SM_CHK_LOC_LR			= 5'd29,
						SM_DONE					= 5'd30;

						
reg [4:0] fsm_quicksort = SM_IDLE;
//
reg [16383:0] shift_reg = {16384{1'b0}};
reg [1:0] set_shift_reg_opt = 2'd0;
reg shift_reg_en = 1'b0;
wire [15:0] shift_out_val;

//-------------------------------------------------------\\

//Left LOC 
always@(*)
begin
	(*parallel_case*)
	case(mux_left_loc_sel)
		2'd0: mux_left_loc = left;
		2'd1: mux_left_loc = shift_out_val[15:8] & 8'h3F;
		2'd2: mux_left_loc = shift_out_val[7:0];
		2'd3: mux_left_loc = {AW{1'b0}};	
	endcase
end

always@(posedge clk)
begin
	if(rst || clear_all_reg)
	begin
		left_loc <= {AW{1'b0}};
	end
	else if( leftloc_load_en ) begin
		left_loc <= mux_left_loc;
	end
end

//Right LOC 
always@(*)
begin
	(*parallel_case*)
	case(mux_right_loc_sel)
		2'd0: mux_right_loc = right;
		2'd1: mux_right_loc = shift_out_val[15:8] & 8'h3F;
		2'd2: mux_right_loc = shift_out_val[7:0];
		2'd3: mux_right_loc = {AW{1'b0}};	
	endcase
end

always@(posedge clk)
begin
	if(rst || clear_all_reg)
	begin
		right_loc <= {AW{1'b0}};
	end
	else if( rightloc_load_en ) begin
		right_loc <= mux_right_loc;
	end
end

//Left PTR
always@(*)
begin
	(*parallel_case*)
	case(mux_left_ptr_sel)
		2'd0: mux_left_ptr = left_loc;
		2'd1: mux_left_ptr = left_ptr + {{AW-1{1'b0}},1'b1};
		2'd2: mux_left_ptr = {AW{1'b0}};
		2'd3: mux_left_ptr = {AW{1'b0}};	
	endcase
end

always@(posedge clk)
begin
	if(rst || clear_all_reg)
	begin
		left_ptr <= {AW{1'b0}};
	end
	else if( leftptr_load_en ) begin
		left_ptr <= mux_left_ptr;
	end
end

//Right PTR
always@(*)
begin
	(*parallel_case*)
	case(mux_right_ptr_sel)
		2'd0: mux_right_ptr = right_loc - {{AW-1{1'b0}},1'b1};
		2'd1: mux_right_ptr = right_ptr - {{AW-1{1'b0}},1'b1};
		2'd2: mux_right_ptr = {AW{1'b0}};
		2'd3: mux_right_ptr = {AW{1'b0}};	
	endcase
end

always@(posedge clk)
begin
	if(rst || clear_all_reg)
	begin
		right_ptr <= {AW{1'b0}};
	end
	else if( rightptr_load_en ) begin
		right_ptr <= mux_right_ptr;
	end
end

//Pivot LOC
always@(posedge clk)
begin
	if(rst || clear_all_reg) 
	begin
		pivot_loc <= {AW{1'b0}};
	end
	else if( pivotloc_load_en ) begin
		pivot_loc <= left_ptr;
	end
end

////////////////////////////////

//Left Value
always@(posedge clk)
begin
	if(rst || clear_all_reg)
	begin
		left_val <= {DW{1'b0}};
	end
	else if( leftval_load_en ) begin
		left_val <= mem_rd_data;
	end
end

//Right Value
always@(posedge clk)
begin
	if(rst || clear_all_reg)
	begin
		right_val <= {DW{1'b0}};
	end
	else if( rightval_load_en ) begin
		right_val <= mem_rd_data;
	end
end

//Pivot Value
always@(posedge clk)
begin
	if(rst || clear_all_reg)
	begin
		pivot_val <= {DW{1'b0}};
	end
	else if( pivotval_load_en ) begin
		pivot_val <= mem_rd_data;
	end
end

////////////////////////////////

//Step Cnt Value
always@(posedge clk)
begin
	if(rst || clear_all_reg)
	begin
		step_cnt <= 2'd0; 
	end
	else if( step_cnt_inc_en ) begin
		step_cnt <= step_cnt + 2'd1; 
	end
end

////////////////////////////////

assign shift_out_val = shift_reg[16383:16368];

wire [15:0] addr_16b_add = {2'b11,(pivot_loc+{{AW-1{1'b0}},1'b1}),2'b00, right_loc};
wire [15:0] addr_16b_sub = {2'b10,(pivot_loc-{{AW-1{1'b0}},1'b1}),2'b00, left_loc};

//Step Cnt Value
always@(posedge clk)
begin
	if(rst || clear_all_reg)
	begin
		shift_reg <= {16384{1'b0}};
	end
	else if( shift_reg_en == 1'b1 && set_shift_reg_opt == 2'd1 ) begin	//Add Right value
		shift_reg <= { addr_16b_sub, shift_reg[16383:16] };
	end
	else if( shift_reg_en == 1'b1 && set_shift_reg_opt == 2'd2 ) begin	//Add Left value
		shift_reg <= { addr_16b_add, shift_reg[16383:16] };
	end
	else if( shift_reg_en == 1'b1 && set_shift_reg_opt == 2'd3 ) begin	//Shift out value 
		shift_reg <= { shift_reg[16367:0], 16'd0 };
	end
end

////////////////////////////////

//Address MUX
always@(*)
begin
	(*parallel_case*)
	case(mux_mem_addr_sel)
		2'd0: mem_addr = right_loc;
		2'd1: mem_addr = left_ptr;
		2'd2: mem_addr = right_ptr;
		2'd3: mem_addr = {AW{1'b0}};	
	endcase
end

//Data Mem WR Mux
always@(*)
begin
	(*parallel_case*)
	case(mux_mem_wr_data_sel)
		2'd0: mem_wr_data = left_val;
		2'd1: mem_wr_data = right_val;
		2'd2: mem_wr_data = pivot_val;
		2'd3: mem_wr_data = {DW{1'b0}};	
	endcase
end

//-------------------------------------------------------\\


always@(posedge clk)
begin
	if(rst)
	begin
		fsm_quicksort 			<= SM_IDLE;
		clear_all_reg 			<= 1'b0;
		step_cnt_inc_en 		<= 1'b0;
		mem_wr_en 					<= 1'b0;
		mux_mem_addr_sel 		<= 2'd0; 
		mux_mem_wr_data_sel <= 2'd0; 
		leftloc_load_en 		<= 1'b0;
		mux_left_loc_sel 		<= 2'd0;
		rightloc_load_en 		<= 1'b0;
		mux_right_loc_sel 	<= 2'd0;
		leftptr_load_en 		<= 1'b0;
		mux_left_ptr_sel 		<= 2'd0;
		rightptr_load_en 		<= 1'b0;
		mux_right_ptr_sel 		<= 2'd0;
		pivotloc_load_en 		<= 1'b0;
		leftval_load_en 		<= 1'b0;
		rightval_load_en 		<= 1'b0;
		pivotval_load_en 		<= 1'b0;
		done 					<= 1'b0;
		set_shift_reg_opt 		<= 2'd0;
		shift_reg_en 			<= 1'b0;
	end
	else 
	begin
		(*parallel_case*)
		case(fsm_quicksort)
		
			SM_IDLE: begin
				fsm_quicksort 			<= SM_CLR;
				clear_all_reg 			<= 1'b1;	//clear Reg
				mux_mem_addr_sel 		<= 2'd0; 
				mux_mem_wr_data_sel <= 2'd0; 
				mux_left_loc_sel 		<= 2'd0;	//Default Mux Locations
				mux_right_loc_sel 	<= 2'd0;
				mux_left_ptr_sel 		<= 2'd0;
				mux_right_ptr_sel 	<= 2'd0;
				set_shift_reg_opt 		<= 2'd0;
				done 				<= 1'b0;	
			end
			
			SM_CLR: begin
				fsm_quicksort 			<= SM_WAIT;
				clear_all_reg 			<= 1'b0;
			end
			
			SM_WAIT: begin
				if(start) begin
					if( left < right ) begin //In case of Mismatch Exit
						fsm_quicksort 			<= SM_LOAD_LOC;
						mux_right_loc_sel 	<= 2'd0;	//Right
						mux_left_loc_sel 		<= 2'd0;	//Left
						rightloc_load_en 		<= 1'b1;
						leftloc_load_en 		<= 1'b1;
					end
					else begin
						fsm_quicksort 			<= SM_DONE;
					end			
				end
			end
			
			SM_LOAD_LOC: begin
				fsm_quicksort 			<= SM_LOAD_PTR;
				rightloc_load_en 		<= 1'b0;
				leftloc_load_en 		<= 1'b0;
				mux_mem_addr_sel 		<= 2'd0; 	//pivot Loc
				mux_left_ptr_sel 		<= 2'd0;
				mux_right_ptr_sel 		<= 2'd0;
				leftptr_load_en 		<= 1'b1;
				rightptr_load_en 		<= 1'b1;
			end
			
			SM_LOAD_PTR: begin
				fsm_quicksort 			<= SM_LOAD_PIVOT_VAL;
				leftptr_load_en 		<= 1'b0;
				rightptr_load_en 		<= 1'b0;
				pivotval_load_en 		<= 1'b1;
				mux_mem_addr_sel 		<= 2'd1; 	//Left Ptr Loc
			end
			
			SM_LOAD_PIVOT_VAL: begin
				fsm_quicksort 			<= SM_LOAD_LEFT_VAL;
				pivotval_load_en 		<= 1'b0;
				leftval_load_en 		<= 1'b1;
				mux_mem_addr_sel 		<= 2'd2; 	//Right Ptr Loc
			end
			
			SM_LOAD_LEFT_VAL: begin
				fsm_quicksort 			<= SM_LOAD_RIGHT_VAL;
				leftval_load_en 		<= 1'b0;
				rightval_load_en 		<= 1'b1;
			end
			
			SM_LOAD_RIGHT_VAL: begin
				fsm_quicksort 			<= SM_LEFT_PTR_CHECK;
				rightval_load_en 		<= 1'b0;
			end
			
			SM_LEFT_PTR_CHECK: begin
				if( left_val < pivot_val ) begin
					fsm_quicksort 			<= SM_LEFT_PTR_INC;
					mux_left_ptr_sel 		<= 2'd1;	//ptr++
					leftptr_load_en			<= 1'b1;
				end
				else begin
					fsm_quicksort 			<= SM_RIGHT_PTR_CHECK;
				end
			end
			
			SM_LEFT_PTR_INC: begin
				fsm_quicksort 			<= SM_LEFT_PTR_INC_1;
				leftptr_load_en 		<= 1'b0;
				mux_mem_addr_sel 		<= 2'd1; 	//Left Ptr Loc
			end
			
			SM_LEFT_PTR_INC_1: begin
				fsm_quicksort 			<= SM_LEFT_PTR_INC_2;
				leftval_load_en 		<= 1'b1;
			end
			
			SM_LEFT_PTR_INC_2: begin
				fsm_quicksort 			<= SM_LEFT_PTR_CHECK;
				leftval_load_en 		<= 1'b0;
			end
			
			SM_RIGHT_PTR_CHECK: begin
				if( right_val > pivot_val && right_ptr > left_loc ) begin
					fsm_quicksort 			<= SM_RIGHT_PTR_INC;
					mux_right_ptr_sel		<= 2'd1;	//ptr--
					rightptr_load_en		<= 1'b1;
				end
				else begin
					fsm_quicksort 			<= SM_LR_PTR_COMPARE;
				end
			end
			
			SM_RIGHT_PTR_INC: begin
				fsm_quicksort 			<= SM_RIGHT_PTR_INC_1;
				rightptr_load_en		<= 1'b0;
				mux_mem_addr_sel 		<= 2'd2; 	//Right Ptr Loc
			end
			
			SM_RIGHT_PTR_INC_1: begin
				fsm_quicksort 			<= SM_RIGHT_PTR_INC_2;
				rightval_load_en 		<= 1'b1;
			end
			
			SM_RIGHT_PTR_INC_2: begin
				fsm_quicksort 			<= SM_RIGHT_PTR_CHECK;
				rightval_load_en 		<= 1'b0;
			end
			
			SM_LR_PTR_COMPARE: begin
				if( left_ptr < right_ptr ) begin	//SWAP Left Right
					fsm_quicksort 			<= SM_LEFT_PTR_RIGHT_VAL;
					mux_mem_addr_sel 		<= 2'd1;	//left ptr 
					mux_mem_wr_data_sel <= 2'd1;	//right val
					mem_wr_en 					<= 1'b1;
				end
				else begin //SWAP Left Pivot
					fsm_quicksort 			<= SM_LEFT_PTR_PIVOT_VAL;
					mux_mem_addr_sel 		<= 2'd1;	//left ptr 
					mux_mem_wr_data_sel <= 2'd2;	//Pivot val
					mem_wr_en 					<= 1'b1;
				end
			end
			
			SM_LEFT_PTR_RIGHT_VAL: begin
					fsm_quicksort 			<= SM_RIGHT_PTR_LEFT_VAL;
					mux_mem_addr_sel 		<= 2'd2;	//right ptr 
					mux_mem_wr_data_sel <= 2'd0;	//left val
			end
			
			SM_RIGHT_PTR_LEFT_VAL: begin
					fsm_quicksort 			<= SM_INC_LR_PTR;
					mem_wr_en 					<= 1'b0;
					mux_right_ptr_sel 	<= 2'd1;
					mux_left_ptr_sel 		<= 2'd1;
					leftptr_load_en 		<= 1'b1;
					rightptr_load_en 		<= 1'b1;
			end
			
			SM_INC_LR_PTR: begin
					fsm_quicksort 			<= SM_LOAD_PIVOT_VAL;
					leftptr_load_en 		<= 1'b0;
					rightptr_load_en 		<= 1'b0;
					mux_mem_addr_sel 		<= 2'd1; 	//Left Ptr Loc
			end
			
			SM_LEFT_PTR_PIVOT_VAL: begin
					fsm_quicksort 			<= SM_PIVOT_PT_LEFT_VAL;
					mux_mem_addr_sel 		<= 2'd0;	//Right (Pivot Extreme Location)
					mux_mem_wr_data_sel <= 2'd0;	//Left val
			end
			
			SM_PIVOT_PT_LEFT_VAL: begin
					fsm_quicksort 			<= SM_UPD_PIVOT_LOC;
					mem_wr_en 				<= 1'b0;
					pivotloc_load_en 		<= 1'b1;
			end
			
			SM_UPD_PIVOT_LOC: begin
				fsm_quicksort 			<= SM_ADD_LOC_SHIFT_RIGHT;
				pivotloc_load_en 		<= 1'b0;			
			end
			
			SM_ADD_LOC_SHIFT_RIGHT: begin
				fsm_quicksort 			<= SM_ADD_LOC_SHIFT_LEFT;
				if( pivot_loc < right_loc ) begin
					set_shift_reg_opt 		<= 2'd2; //right
					shift_reg_en 			<= 1'b1;
				end
				//else dont shift Upper Sub Array
			end
			
			SM_ADD_LOC_SHIFT_LEFT: begin
				fsm_quicksort 			<= SM_ADD_LOC_SHIFT_1;
				if( pivot_loc > 0 && pivot_loc > left_loc ) begin
					set_shift_reg_opt 		<= 2'd1; //left
					shift_reg_en 			<= 1'b1;
				end
				else begin
					shift_reg_en 			<= 1'b0;	//DONT SHIFT Lower Sub-Array
				end
			end
			
			SM_ADD_LOC_SHIFT_1: begin
				fsm_quicksort 			<= SM_ADD_LOC_SHIFT_CHECK;
				shift_reg_en 			<= 1'b0;
			end
			
			SM_ADD_LOC_SHIFT_CHECK: begin
				if( shift_out_val[15:14] == 2'b10 ) begin //pivot-1
					fsm_quicksort 			<= SM_UPD_LOC_ARR;
					mux_left_loc_sel 		<= 2'd2;	//Left Loc
					mux_right_loc_sel 		<= 2'd1;	//Pivot-1
					rightloc_load_en 		<= 1'b1;
					leftloc_load_en 		<= 1'b1;
				end
				else if( shift_out_val[15:14] == 2'b11 ) begin //pivot+1
					fsm_quicksort 			<= SM_UPD_LOC_ARR;
					mux_left_loc_sel 		<= 2'd1;	//Pivot+1
					mux_right_loc_sel 		<= 2'd2;	//Right Loc
					rightloc_load_en 		<= 1'b1;
					leftloc_load_en 		<= 1'b1;
				end	
				else begin	//done
					fsm_quicksort 			<= SM_DONE;
				end
			end
			
			SM_UPD_LOC_ARR: begin
				fsm_quicksort 			<= SM_UPD_LOC_ARR_1;
				rightloc_load_en 		<= 1'b0;
				leftloc_load_en 		<= 1'b0;
				shift_reg_en 			<= 1'b1;
				set_shift_reg_opt 		<= 2'd3; //Discard Entry
			end
			
			SM_UPD_LOC_ARR_1: begin
				fsm_quicksort 			<= SM_CHK_LOC_LR;
				shift_reg_en 			<= 1'b0;
			end
			
			SM_CHK_LOC_LR: begin
				if( right_loc > left_loc ) begin
					fsm_quicksort 			<= SM_LOAD_LOC;
				end
				else begin
					fsm_quicksort 			<= SM_ADD_LOC_SHIFT_CHECK;
				end
			end
			
			SM_DONE: begin
				fsm_quicksort 		<= SM_IDLE;
				done 				<= 1'b1;
			end
			
			default: begin
				fsm_quicksort 			<= SM_IDLE;
				clear_all_reg 			<= 1'b0;
				step_cnt_inc_en 		<= 1'b0;
				mem_wr_en 					<= 1'b0;
				mux_mem_addr_sel 		<= 2'd0; 
				mux_mem_wr_data_sel <= 2'd0; 
				leftloc_load_en 		<= 1'b0;
				mux_left_loc_sel 		<= 2'd0;
				rightloc_load_en 		<= 1'b0;
				mux_right_loc_sel 	<= 2'd0;
				leftptr_load_en 		<= 1'b0;
				mux_left_ptr_sel 		<= 2'd0;
				rightptr_load_en 		<= 1'b0;
				mux_right_ptr_sel 	<= 2'd0;
				pivotloc_load_en 		<= 1'b0;
				leftval_load_en 		<= 1'b0;
				rightval_load_en 		<= 1'b0;
				pivotval_load_en 		<= 1'b0;
				done 					<= 1'b0;
				set_shift_reg_opt 		<= 2'd0;
				shift_reg_en 			<= 1'b0;
			end
		
		endcase
	end
end
	
	
//-------------------------------------------------------\\

endmodule