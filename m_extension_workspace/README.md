# M Extension

This folder contains all the necessary scripts for generating and testing the m extension unit. 

### Folders
- `lint`: lints settings, configurations, and lint Makefile
- `m_extension`: modules for the m extension
- `synth`: synthesis settings, configurations, and synthesis Makefile
- `tmp`: output files from `dadda_tree.ipynb`

### M Extension Files:
- `m_type.sv`: data types used in the m extension unit
- `adders.sv`: contains module for half adder and full adder
- `dadda_tree.sv`: an 8-stage dadda tree generated from `dadda_tree.ipynb`
- `divider.sv`: the top-level of simple shift-subtract divider
- `m_ex_alu.sv`: the top-level of m extension unit
- `multiplier.sv`: the top-level of multiplier

Note: `multiplier_control.sv` is not used in the m extension.

### M Extension Design and details
More information can be found in section 3.3.1 in our report `ECE411 MP4 Report` located in folder `docs`.

### Testing
Testbench file: `m_extension_top_tb.sv`

To run the testbench, run:
```
make run
```
To see the waveform, run:
```
./run_verdi.sh
```

### Lint
To run lint tools, run:
```
make lint
```

### Synthesis
`clock_period.txt`: specifying the clock period that drives the unit (in ps)

To switch between different compilation mode, comment and uncomment line 101 and 102 in `synthesis.tcl`: 
```
# compile_ultra -gate_clock -retime
compile
```

To run synthesis, run:
```
make synth
```

