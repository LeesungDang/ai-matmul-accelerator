# Project Summary

## AI Matrix Multiply Accelerator

This project is a SystemVerilog RTL hardware design and verification project focused on matrix multiplication, a core operation in AI accelerators, GPUs, TPUs, and digital signal processing systems.

The design starts with a dot-product compute unit and builds up to 2x2 and 4x4 matrix multiplication accelerators. It includes both combinational and sequential FSM-based implementations, Python/NumPy golden-model verification, randomized signed INT8 RTL testing, and Yosys synthesis results.

## Why This Project Matters

Matrix multiplication is the central computation behind many AI inference and machine learning workloads. This project implements a small-scale version of that compute pattern in hardware.

The project demonstrates the complete early digital design flow:

1. Write RTL hardware in SystemVerilog
2. Simulate with Icarus Verilog
3. Verify outputs against Python/NumPy golden models
4. Use randomized test vectors to catch signed arithmetic bugs
5. Build a sequential FSM-based accelerator
6. Synthesize RTL with Yosys
7. Compare combinational vs sequential hardware tradeoffs

## Implemented Modules

| Module | Description |
|---|---|
| dot_product.sv | 4-element signed dot-product unit |
| matmul_2x2.sv | Basic 2x2 matrix multiplication |
| matmul_2x2_array.sv | Array-interface 2x2 matrix multiplication |
| matmul_4x4.sv | Combinational 4x4 matrix multiplication |
| matmul_4x4_seq.sv | Sequential FSM-based 4x4 matrix multiplication |
| matmul_4x4_flat.sv | Synthesis-friendly flat combinational 4x4 design |
| matmul_4x4_seq_flat.sv | Synthesis-friendly flat sequential 4x4 design |

## Verification

The project includes:

- Fixed SystemVerilog testbenches
- Python/NumPy golden models
- Randomized signed INT8 test-vector generation
- Randomized RTL verification for both combinational and sequential 4x4 designs

A signed arithmetic bug was found when randomized negative INT8 inputs were introduced. The fix required wider signed accumulation, matching the common AI hardware pattern:

INT8 inputs  
wider signed accumulation  

## Synthesis Results

Both flattened 4x4 designs were synthesized with Yosys.

| Design | Style | Yosys Cell Count | Main Tradeoff |
|---|---|---:|---|
| matmul_4x4_flat | Combinational | 51,056 cells | High parallelism, larger gate count |
| matmul_4x4_seq_flat | Sequential FSM | 5,134 cells | Lower gate count, more cycles |

The sequential design uses about 10x fewer cells than the fully combinational design. This demonstrates the classic hardware tradeoff between area and latency.

## Skills Demonstrated

- SystemVerilog RTL design
- Digital datapath design
- Matrix multiplication hardware
- Signed INT8 arithmetic
- Wider accumulation for quantized compute
- FSM-based sequential hardware
- Testbench development
- Python golden-model verification
- Randomized RTL verification
- Yosys synthesis
- Area vs latency tradeoff analysis
- Git/GitHub project workflow

## Resume Bullets

- Designed and verified a SystemVerilog INT8 matrix multiplication accelerator, implementing dot-product, 2x2, 4x4 combinational, and FSM-based sequential datapaths.

- Built Python/NumPy golden models and randomized signed INT8 test-vector generators to validate RTL behavior, catching and fixing signed arithmetic issues through verification.

- Synthesized combinational and sequential 4x4 matrix multiplication designs using Yosys, demonstrating an approximately 10x cell-count reduction in the sequential FSM implementation compared with the fully combinational design.

## Interview Talking Points

### Why matrix multiplication?

Matrix multiplication is the core operation behind neural-network inference, AI accelerators, GPUs, TPUs, NPUs, and many signal-processing workloads.

### Why INT8?

INT8 is commonly used in quantized AI inference because it reduces memory and compute cost compared with wider floating-point formats.

### Why wider accumulation?

Even if inputs are INT8, multiply-accumulate results can exceed the INT8 range. Wider signed accumulation is necessary for correctness.

### Why randomized verification?

A fixed positive-only test passed, but randomized signed inputs exposed a bug. This showed why hardware designs need more than one hand-picked test case.

### Why have both combinational and sequential versions?

The combinational version shows high parallelism but synthesizes to a larger gate count. The sequential FSM version uses fewer cells but requires more cycles. This demonstrates area-latency tradeoffs.

## Next Steps

Possible next extensions:

1. Run OpenLane/OpenROAD ASIC physical design flow
2. Deploy the design to an FPGA board
3. Add formal verification or linting
4. Add waveform screenshots and block diagrams
5. Create a memory-mapped accelerator interface
