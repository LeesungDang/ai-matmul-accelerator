.PHONY: dot golden clean

dot:
	mkdir -p build waveforms
	iverilog -g2012 -o build/dot_product_tb tb/tb_dot_product.sv rtl/dot_product.sv
	vvp build/dot_product_tb

golden:
	python3 python/golden_dot_product.py

clean:
	rm -rf build/*
	rm -rf waveforms/*
