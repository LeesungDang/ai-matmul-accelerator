# OpenLane Physical Design Flow

## Overview

This project includes an OpenLane ASIC physical-design run for the synthesis-friendly sequential 4x4 matrix multiplication accelerator:

rtl/matmul_4x4_seq_flat.sv

The design was run through the OpenLane RTL-to-GDS flow using the SKY130 PDK and the sky130_fd_sc_hd standard cell library.

## Design Used

The OpenLane run used the sequential flat accelerator because it is smaller than the fully combinational version.

Yosys synthesis comparison:

| Design | Style | Yosys Cell Count |
|---|---|---:|
| matmul_4x4_flat | Combinational | 51,056 |
| matmul_4x4_seq_flat | Sequential FSM | 5,134 |

## OpenLane Flow

The design completed the major ASIC physical-design stages:

1. Synthesis
2. Static timing analysis
3. Floorplanning
4. IO placement
5. Tap/decap insertion
6. Power distribution network generation
7. Global placement
8. Detailed placement
9. Clock tree synthesis
10. Global routing
11. Detailed routing
12. Parasitic extraction
13. Multi-corner timing analysis
14. GDSII generation
15. LVS
16. DRC
17. Antenna checking
18. Final report generation

## Run Configuration

The run used:

- DESIGN_NAME: matmul_4x4_seq_flat
- CLOCK_PORT: clk
- CLOCK_PERIOD: 25 ns
- FP_SIZING: absolute
- DIE_AREA: 0 0 2000 2000
- FP_CORE_UTIL: 20
- PL_TARGET_DENSITY: 0.30

A large die area was used because the flattened accelerator exposes many top-level pins:

- A_flat: 128 bits
- B_flat: 128 bits
- C_flat: 288 bits
- clk/rst/start/done control pins

This created IO placement pressure in earlier runs. Absolute die sizing fixed the IO placement issue.

## Final Status

The OpenLane run completed successfully.

Important final results:

- Flow complete
- No detailed routing DRC violations
- No DRC violations after GDS streaming
- No XOR differences between KLayout and Magic GDS
- No setup violations at the typical corner
- No hold violations at the typical corner

## Remaining Warnings

The flow reported:

- max slew violations
- max fanout violations
- IR drop analysis may be inaccurate because VSRC_LOC_FILES was not defined

These warnings indicate that the design is not fully timing/electrical-clean yet, but the RTL-to-GDS flow completed successfully.

## Key Lesson

A design can pass RTL simulation and synthesis but still fail physical design due to floorplanning or IO constraints.

The first OpenLane attempts failed because the design had 580 top-level IO pins and the floorplan did not provide enough IO placement sites. Increasing the die area and using absolute floorplan sizing allowed the physical-design flow to complete.

This highlights a real chip-design issue: exposing wide internal data buses as chip-level IO is inefficient. A more realistic accelerator would use a smaller memory-mapped interface, streaming interface, or internal SRAM buffers.

## Reports

Committed OpenLane reports are available in:

openlane/matmul_4x4_seq_flat/

Included files:

- config.json
- metrics.csv
- manufacturability.rpt
