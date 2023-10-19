/*
 * follow the c convention declarations for structs
 */

package rv32i_types;

import instr_field::*;
import pcmux::*;
import marmux::*;
import cmpmux::*;
import alumux::*;
import regfilemux::*;

/* Parameters */
parameter int WORD_LEN = 32;

/* Basic Types */
typedef logic [WORD_LEN-1: 0] rv32i_word; // [31:0], 32 bits
typedef logic [4:0] rv32i_reg;            // [4:0], 32 registers
typedef logic [3:0] rv32i_mem_wmask;      // [3:0], 4 bits, used to select the bytes in the word
typedef logic [6:0] funct7_t;               // [36:0], 7 bits, function bits, plz refer to rv32i instruction type
typedef logic [2:0] funct3_t;

/************** instructions formats **************/

// r type format
typedef struct packed{
    funct7_t        funct7;        
    rv32i_reg       rs2;
    rv32i_reg       rs1;
    funct3_t        funct3;
    rv32i_reg       rd;
    rv32i_opcode    opcode;
}rv32i_inst_r_t;

// i type format
typedef struct packed{
    logic[11:0]     imm;   // use i_imm
    rv32i_reg       rs1;
    funct3_t        funct3;    
    rv32i_reg       rd;
    rv32i_opcode    opcode;
}rv32i_inst_i_t;

// s type format
typedef struct packed{
    logic[6:0]      top_imm; // try not to use these imms, use s_imm
    rv32i_reg       rs2;
    rv32i_reg       rs1;
    funct3_t        funct3;
    logic[4:0]      bot_imm;
    rv32i_opcode    opcode;
}rv32i_inst_s_t;

// b type format
typedef struct packed{
    logic[6:0]      top_imm; // try not to use these imms, use b_imm
    rv32i_reg       rs2;
    rv32i_reg       rs1;
    funct3_t        funct3;    
    logic[4:0]      bot_imm;
    rv32i_opcode    opcode;
}rv32i_inst_b_t;

// u type format
typedef struct packed{ 
    logic[19:0]     imm;    // try not to use this imm, use u_imm
    rv32i_reg       rd;
    rv32i_opcode    opcode;
}rv32i_inst_u_t;

// j type format
typedef struct packed{
    logic[19:0]     imm;   // try not to use this imm, use j_imm
    rv32i_reg       rd;
    rv32i_opcode    opcode;    
}rv32i_inst_j_t;

/************** instructions union **************/
typedef union packed{

    // unless you want to overwrite everything, otherwise do not write to this variable
    logic[WORD_LEN-1:0] word;   

    rv32i_inst_r_t r_type; // r-type instruction
    rv32i_inst_i_t i_type; // i-type instruction
    rv32i_inst_s_t s_type; // s-type instruction
    rv32i_inst_b_t b_type; // b-type instruction
    rv32i_inst_u_t u_type; // u-type instruction
    rv32i_inst_j_t j_type; // j-type instruction
}rv32i_inst_t;


/************** control words **************/
// the valid bit in all the ctrl_t determines if the
// the control word is valid. may use it flush pipeline
// TODO: do we need pc and opcode
typedef struct packed{
    logic           valid;
    rv32i_word      pc;
    rv32i_opcode    opcode;
    
    // TODO: ask this
    logic           branch_enable;  // seems to be something for ex ctrl signals, 1 if inst is branch
    
    alu_ops         aluop;
    branch_funct3_t cmpop;
    cmpmux_sel_t    cmpmux_sel;
    alumux1_sel_t   alumux1_sel;
    alumux2_sel_t   alumux2_sel;

    // TODO: double check this, seems like it is part of both IF and EXE, do we still need this?
    // not really in my opinion
    // marmux_sel_t    marmux_sel;     
}EX_ctrl_t;

typedef struct packed{
    logic           valid;
    rv32i_word      pc;
    rv32i_opcode    opcode;

    logic       mem_read;
    logic       mem_write;
    // logic       branch_enable;
    rv32i_mem_wmask wmask;

}MEM_ctrl_t;

typedef struct packed{
    logic           valid;
    rv32i_word      pc;
    rv32i_opcode    opcode;

    logic   load_regfile;   // load signals
    regfilemux_sel_t regfilemux_sel;
}WB_ctrl_t;

/************** intermediate stages **************/
// the struct use to store the stage control signals
typedef struct packed {
    
    // TODO: pc reg
    rv32i_word      pc;

    // TODO: ir register data section
    rv32i_inst_t    ir; // the calculation can be done outside (eg. decode state)
}IF_ID_stage_t;

//TODO: double check the imms
typedef struct packed {
    
    // control signal blocks
    EX_ctrl_t   EX_ctrlwd;
    MEM_ctrl_t  MEM_ctrlwd;
    WB_ctrl_t   WB_ctrlwd;

    rv32i_word  rs1_out;     // src reg 1 output
    rv32i_word  rs2_out;     // src reg 2 output
    rv32i_word  i_imm; 
    rv32i_word  s_imm;      
    rv32i_word  b_imm;
    rv32i_word  u_imm;       // u_type immediate
    rv32i_word  j_imm;

    rv32i_reg   rd;          // dest reg
}ID_EX_stage_t;

// TODO: double check
typedef struct packed {

    // control signal blocks
    EX_ctrl_t   EX_ctrlwd;
    MEM_ctrl_t  MEM_ctrlwd;
    WB_ctrl_t   WB_ctrlwd;

    rv32i_word  cmp_out;         // use for branch or set compare output
    rv32i_word  alu_out;         // alu output
    rv32i_word  mar;             // memory address register
    rv32i_word  mem_data_out;    // store data that is about to write to the memory
    rv32i_word  u_imm;   
    rv32i_reg   rd;

}EX_MEM_stage_t;

// TODO: double check
typedef struct packed {
    
    // control signal blocks
    EX_ctrl_t   EX_ctrlwd;
    MEM_ctrl_t  MEM_ctrlwd;
    WB_ctrl_t   WB_ctrlwd;

    rv32i_word  alu_out;
    rv32i_word  cmp_out;    
    rv32i_word  mdr;        // memory data register
    rv32i_word  u_imm;   
    rv32i_reg   rd;
    
}MEM_WB_stage_t;

endpackage


/*********************** the followings are given in mp2 ***********************/

package instr_field; // just a name for import
    
typedef enum bit [6:0] {
    op_lui   = 7'b0110111, //load upper immediate (U type)
    op_auipc = 7'b0010111, //add upper immediate PC (U type)
    op_jal   = 7'b1101111, //jump and link (J type)
    op_jalr  = 7'b1100111, //jump and link register (I type)
    op_br    = 7'b1100011, //branch (B type)
    op_load  = 7'b0000011, //load (I type)
    op_store = 7'b0100011, //store (S type)
    op_imm   = 7'b0010011, //arith ops with register/immediate operands (I type)
    op_reg   = 7'b0110011, //arith ops with register operands (R type)
    op_csr   = 7'b1110011  //control and status register (I type)
} rv32i_opcode;

typedef enum bit [2:0] {
    beq  = 3'b000,
    bne  = 3'b001,
    blt  = 3'b100,
    bge  = 3'b101,
    bltu = 3'b110,
    bgeu = 3'b111
} branch_funct3_t;

typedef enum bit [2:0] {
    lb  = 3'b000,
    lh  = 3'b001,
    lw  = 3'b010,
    lbu = 3'b100,
    lhu = 3'b101
} load_funct3_t;

typedef enum bit [2:0] {
    sb = 3'b000,
    sh = 3'b001,
    sw = 3'b010
} store_funct3_t;

typedef enum bit [2:0] {
    add  = 3'b000, //check bit30 for sub if op_reg opcode
    sll  = 3'b001,
    slt  = 3'b010,
    sltu = 3'b011,
    axor = 3'b100,
    sr   = 3'b101, //check bit30 for logical/arithmetic
    aor  = 3'b110,
    aand = 3'b111
} arith_funct3_t;

typedef enum bit [2:0] { // why arith_functs and this are repeated, why not just use one copy
    alu_add = 3'b000,
    alu_sll = 3'b001,
    alu_sra = 3'b010,
    alu_sub = 3'b011,
    alu_xor = 3'b100,
    alu_srl = 3'b101,
    alu_or  = 3'b110,
    alu_and = 3'b111
} alu_ops;
endpackage

package pcmux;
typedef enum bit [1:0] {
    pc_plus4  = 2'b00
    ,alu_out  = 2'b01
    ,alu_mod2 = 2'b10 // this is useless in this mp
} pcmux_sel_t;
endpackage

package marmux;
typedef enum bit {
    pc_out = 1'b0
    ,alu_out = 1'b1
} marmux_sel_t;
endpackage

package cmpmux;
typedef enum bit {
    rs2_out = 1'b0
    ,i_imm = 1'b1
} cmpmux_sel_t;
endpackage

package alumux;
typedef enum bit {
    rs1_out = 1'b0
    ,pc_out = 1'b1
} alumux1_sel_t;

typedef enum bit [2:0] {
    i_imm    = 3'b000
    ,u_imm   = 3'b001
    ,b_imm   = 3'b010
    ,s_imm   = 3'b011
    ,j_imm   = 3'b100
    ,rs2_out = 3'b101
} alumux2_sel_t;
endpackage

package regfilemux;
typedef enum bit [3:0] {
    alu_out   = 4'b0000
    ,br_en    = 4'b0001
    ,u_imm    = 4'b0010
    ,lw       = 4'b0011
    ,pc_plus4 = 4'b0100
    ,lb        = 4'b0101
    ,lbu       = 4'b0110  // unsigned byte
    ,lh        = 4'b0111
    ,lhu       = 4'b1000  // unsigned halfword
} regfilemux_sel_t;
endpackage