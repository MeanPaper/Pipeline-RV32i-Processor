# A Pipelined Implementation of the RV32I Processor

By the collaboration of [Dongming Liu](https://github.com/MeanPaper), [Elijah Ye](https://github.com/Elijah-Ye), [Tracy Miao](https://github.com/tracymiao111)<br>
UIUC ECE411 FA23 | October 2023 ~ December 2023

## Running the Processor

### To customize processor cache
1. Go to `src/sram/config/` and change the values of `word_size` and `num_words` following files: `L2_data_array.py`, `L2_tag_array.py`, `mp3_data_array.py`, and `mp3_tag_array.py`. Note: Due to the limitataion of OpenRAM, the minimum value of `num_words` needs to be 16
2. Run the following commands to generate SRAM
   ```
   $ cd sram
   $ make
   ```
3. Change the `localparam` in `mp4.sv` under `src/hdl`. If you change the number of ways, you need to run to generate update logics. You can do this by running `plru_update_generate.py` under `src/` with the correct number of ways. 

### To run program without M-Extension
Run the following commands under `src/`
```
$ make run_top_tb PROG=testcode/competition/coremark_rv32i.elf
$ make spike ELF=testcode/competition/coremark_rv32i.elf
$ diff -s sim/spike.log sim/golden_spike.log > sim/diff.log
$ cd synth
$ make synth
```

### To run program with M-Extension
Run the following commands under `src/`
```
$ make run_top_tb PROG=testcode/competition/coremark_rv32im.elf
$ make spike ELF=testcode/competition/coremark_rv32im.elf
$ diff -s sim/spike.log sim/golden_spike.log > sim/diff.log
$ cd synth
$ make synth
```
## Documentation
| | Design | Report |
| - | :-: | :-: |
| **CP0** - Design Checkpoint | [Design](docs/pics/ECE411MP4CP0Design.png) ||
| **CP1** - RV32I ISA, Basic Pipelining | [Design](docs/pics/ECE411MP4CP1Design.png) ||
| **CP2** - Hazard Control, L1 Cache, <br> Forwarding, Static Branch Prediction | [Design](docs/pics/ECE411MP4CP2Design.png) ||
| **CP3** - Advanced Design Options ||
| **CP4** - Design Competition | | [Demo](docs/ECE411_Final_Presentation.pptx) <br> [Report](docs/ECE411%20MP4%20Report.pdf) |


## Academic Integrity
Please review the University of Illinois Student Code, particularly all subsections of [Article 1, Part 4 - Academic Integrity Policy and Procedure](https://studentcode.illinois.edu/article1/part4/1-401/).

## Legal Notice
This work is protected under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html).<br>
**Copyright (c) 2023 Elijah Gaohan Ye, Dongming Liu, Tracy Miao, Jian Huang**

The software programs described in the documents are confidential and proprietary products of Synopsys Corp. or its licensors. The terms and conditions governing the sale and licensing of Synopsys products are set forth in written agreements between Synopsys Corp. and its customers. No representation or other affirmation of fact contained in this publication shall be deemed to be a warranty or give rise to any liability of Synopsys Corp. whatsoever. Images of software programs in use are assumed to be copyright and may not be reproduced.

The documents are for informational and instructional purposes only. The ECE 411 teaching staff reserves the right to make changes in specifications and other information contained in this publication without prior notice, and the reader should, in all cases, consult the teaching staff to determine whether any changes have been made.
