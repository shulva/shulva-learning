#!/bin/bash
echo "开始编译"
iverilog -o wave wallace_tree_24x24.v dependency.v booth_24x24.v test_bench_tb.v
echo "编译完成"
echo "生成波形文件"
vvp -n wave -vcd
echo "查看波形"
gtkwave.exe wave.vcd
