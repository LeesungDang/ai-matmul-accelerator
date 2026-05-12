.PHONY: dot matmul2 golden clean

dot:
	mkdir -p build waveforms
	iverilog -g2012 -o build/dot_product_tb tb/tb_dot_product.sv rtl/dot_product.sv
	vvp build/dot_product_tb

matmul2:
	mkdir -p build waveforms
	iverilog -g2012 -o build/matmul_2x2_tb tb/tb_matmul_2x2.sv rtl/matmul_2x2.sv
	vvp build/matmul_2x2_tb

golden:
	python3 python/golden_dot_product.py
	python3 python/golden_matmul_2x2.py

clean:
	rm -rf build/*
	rm -rf waveforms/*
