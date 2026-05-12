.PHONY: dot matmul2 matmul2array matmul4 matmul4seq matmul4random matmul4seqrandom golden random4 vectors4 all clean

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

matmul4seq:
	mkdir -p build waveforms
	iverilog -g2012 -o build/matmul_4x4_seq_tb tb/tb_matmul_4x4_seq.sv rtl/matmul_4x4_seq.sv
	vvp build/matmul_4x4_seq_tb

matmul4seqrandom: vectors4
	mkdir -p build waveforms
	iverilog -g2012 -o build/matmul_4x4_seq_random_tb tb/tb_matmul_4x4_seq_random.sv rtl/matmul_4x4_seq.sv
	vvp build/matmul_4x4_seq_random_tb

matmul4random: vectors4
	mkdir -p build waveforms
	iverilog -g2012 -o build/matmul_4x4_random_tb tb/tb_matmul_4x4_random.sv rtl/matmul_4x4.sv
	vvp build/matmul_4x4_random_tb

golden:
	python3 python/golden_dot_product.py
	python3 python/golden_matmul_2x2.py
	python3 python/golden_matmul_4x4.py

random4:
	python3 python/generate_matmul4_tests.py

vectors4:
	python3 python/generate_matmul4_vectors.py

all: dot matmul2 matmul2array matmul4 matmul4seq golden random4 matmul4random matmul4seqrandom

clean:
	rm -rf build/*
	rm -rf waveforms/*
	rm -f python/matmul4_tests.txt
	rm -f python/matmul4_vectors.mem
