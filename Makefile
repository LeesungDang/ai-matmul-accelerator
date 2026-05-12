.PHONY: dot matmul2 matmul2array matmul4 golden clean

dot:
	mkdir -p build waveforms
	iverilog -g2012 -o build/dot_product_tb tb/tb_dot_product.sv rtl/dot_product.sv
	vvp build/dot_product_tb

matmul2:
	mkdir -p build waveforms
	iverilog -g2012 -o build/matmul_2x2_tb tb/tb_matmul_2x2.sv rtl/matmul_2x2.sv
	vvp build/matmul_2x2_tb

matmul2array:
	mkdir -p build waveforms
	iverilog -g2012 -o build/matmul_2x2_array_tb tb/tb_matmul_2x2_array.sv rtl/matmul_2x2_array.sv
	vvp build/matmul_2x2_array_tb

matmul4:
	mkdir -p build waveforms
	iverilog -g2012 -o build/matmul_4x4_tb tb/tb_matmul_4x4.sv rtl/matmul_4x4.sv
	vvp build/matmul_4x4_tb

golden:
	python3 python/golden_dot_product.py
	python3 python/golden_matmul_2x2.py

clean:
	rm -rf build/*
	rm -rf waveforms/*
