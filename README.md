# mips-32 CPU

🔌 A 32-bit MIPS CPU supporting 57 instructions implemented by Verilog HDL. 

Author : @[Mr Dk.](https://github.com/mrdrivingduck), @[zonghuaxiansheng](https://github.com/zonghuaxiansheng)

Developed at: _Nanjing University of Aeronautics and Astronautics (NUAA)_, 2017/06 - 2017/08, for _[NSCSCC 2017](http://www.nscscc.org)_

---

### Directory

* `/soc` : Contains the _soc_ project runs on IDE -- _Xilinx&copy; Vivado 2017.1_.

* `/src` : Contains the HDL source code of CPU implemented by _Verilog_ HDL.
  * `/src/controller` - The controller part of CPU
  * `/src/Datapath` - The data path of CPU

* `/test` : Contains the testing files of _Instruction RAM_ & _Data RAM_
  * `/test/func_test` - Function test of 240,000 instructions.
  * `/test/pref_test` - Performance test of 10 benchmark programs.
  * `/test/memory_game` - A program to test the whole soc system.

### Hardware Environment

Experiment box offered by _Loongson&copy;_, contains an FPGA of _Xilinx&copy; Artex7_.

### About the CPU

* Five-stage Pipeline
* Single issue
* Little-endian
* Always in _kernel_ mode
* Support 57 _MIPS_ instructions
  * Finished function test of 240,000 instructions
  * Finished 10 performance test
* Implemented with several _Xilinx&copy; IP_

### Supporting Instructions

| Instruction | Format                  |
| ----------- | ----------------------- |
| `ADD`       | ADD rd, rs, rt          |
| `ADDI`      | ADDI rt, rs, immediate  |
| `ADDU`      | ADDU rd, rs, rt         |
| `ADDIU`     | ADDIU rt, rs, immeidate |
| `SUB`       | SUB rd. rs, rt          |
| `SUBU`      | SUBU rd, rs, rt         |
| `SLT`       | SLT rd, rs, rt          |
| `SLTI`      | SLTI rt, rs, immediate  |
| `SLTU`      | SLTU rd, rs, rt         |
| `SLTIU`     | SLTIU rt, rs, immediate |
| `DIV`       | DIV rs, rt              |
| `DIVU`      | DIVU rs,rt              |
| `MULT`      | MULT rs, rt             |
| `MULTU`     | MULTU rs, rt            |
| `AND`       | AND rd, rs, rt          |
| `ANDI`      | ANDI rt, rs, immediate  |
| `LUI`       | LUI rt,immediate        |
| `NOR`       | NOR rd, rs, rt          |
| `OR`        | OR rd, rs, rt           |
| `ORI`       | ORI rt, rs, immediate   |
| `XOR`       | XOR rd, rs, rt          |
| `XORI`      | XORI rt, rs, immediate  |
| `SLL`       | SLL rd, rt, sa          |
| `SLLV`      | SLLV rd, rs, rt         |
| `SRA`       | SRA rd, rt, sa          |
| `SRAV`      | SRAV rd, rs, rt         |
| `SRL`       | SRL rd, rt, sa          |
| `SRLV`      | SRLV rd, rs, rt         |
| `BEQ`       | BEQ rs, rt, offset      |
| `BNE`       | BNE rs, rt, offset      |
| `BGEZ`      | BGEZ rs, offset         |
| `BGTZ`      | BGTZ rs, offset         |
| `BLEZ`      | BLEZ rs, offset         |
| `BLTZ`      | BLTZ rs, offset         |
| `BLTZAL`    | BLTZAL rs, offset       |
| `BGEZAL`    | BGEZAL rs, offset       |
| `J`         | J target                |
| `JAL`       | JAL target              |
| `JR`        | JR rs                   |
| `JALR`      | JALR rd, rs             |
| `MFHI`      | MFHI rd                 |
| `MFLO`      | MFLO rd                 |
| `MTHI`      | MTHI rs                 |
| `MTLO`      | MTLO rs                 |
| `BREAK`     | BREAK                   |
| `SYSCALL`   | SYSCALL                 |
| `LB`        | LB rt, offset(base)     |
| `LBU`       | LBU rt, offset(base)    |
| `LH`        | LH rt, offset(base)     |
| `LHU`       | LHU rt, offset(base)    |
| `LW`        | LW rt, offset(base)     |
| `SB`        | SB rt, offset(base)     |
| `SH`        | SH rt, offset(base)     |
| `SW`        | SW rt, offset(base)     |
| `ERET`      | ERET                    |
| `MFC0`      | MFC0                    |
| `MTC0`      | MTC0                    |

### Division of work

- @[Mr Dk.](https://github.com/mrdrivingduck) : Main part of _Datapath_
- @[zonghuaxiansheng](https://github.com/zonghuaxiansheng) : _Controller_ & Instruction Fetch module of _Datapath_

---

