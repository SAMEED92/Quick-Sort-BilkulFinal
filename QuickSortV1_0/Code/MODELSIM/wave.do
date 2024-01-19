onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/rst
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/clk
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/start
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/left
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/right
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/done
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mem_wr_en
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mem_addr
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mem_wr_data
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mem_rd_data
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/left_loc
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/right_loc
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/left_ptr
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/right_ptr
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/pivot_loc
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/left_val
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/right_val
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/pivot_val
add wave -noupdate -radix unsigned /tb_quicksort/qsort/fsm_quicksort
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/shift_out_val
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mux_left_loc
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mux_right_loc
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mux_left_ptr
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mux_right_ptr
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/leftloc_load_en
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mux_left_loc_sel
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/rightloc_load_en
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mux_right_loc_sel
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/leftptr_load_en
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mux_left_ptr_sel
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/rightptr_load_en
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mux_right_ptr_sel
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/pivotloc_load_en
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/leftval_load_en
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/rightval_load_en
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/pivotval_load_en
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/step_cnt_inc_en
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/clear_all_reg
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mux_mem_addr_sel
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/mux_mem_wr_data_sel
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/shift_reg
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/set_shift_reg_opt
add wave -noupdate -radix hexadecimal /tb_quicksort/qsort/shift_reg_en
add wave -noupdate /tb_quicksort/qsort/addr_16b_add
add wave -noupdate /tb_quicksort/qsort/addr_16b_sub
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6907471 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {6621281 ps} {7507225 ps}
