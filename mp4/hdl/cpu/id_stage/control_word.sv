module control_word;
import rv32i_types::*;
(   
    input rv32i_word    pc_i;
    input rv32i_inst_t  instr_i;
    output ctrl_word_t  control_words_o;
);

// declarations
ctrl_word_t     crtl_word;
EX_ctrl_t       ex_ctrls;
MEM_ctrl_t      mem_ctrls;
WB_ctrl_t       wb_ctrls;
rv32i_opcode    opcode;
funct3_t        funct3;
funct7_t        funct7;

// different func3 bits
instr_field::branch_funct3_t branch_funct3;
instr_field::store_funct3_t store_funct3;
instr_field::load_funct3_t load_funct3;
instr_field::arith_funct3_t arith_funct3;

// assignments
assign control_words_o = crtl_word;

// extracting function bits
assign funct3 = instr_i.r_inst.funct3;              // instruction funct3 
assign funct4 = instr_i.r_inst.funct7;              // instruction funct7

// type casting
assign opcode = `rv32i_opcode(instr_i.word[6:0]);   // opcode lower 7 bits 
assign branch_funct3 = `branch_funct3_t(funct3);
assign store_funct3 = `store_funct3_t(funct3); 
assign load_funct3 = `load_funct3_t(funct3);
assign arith_funct3 = `arith_funct3_t(funct3);

function automatic void set_op_lui_ctrl();
    wb_ctrls.load_regfile = 1'b1;
    wb_ctrls.regfilemux_sel = regfilemux::u_imm;
endfunction

function automatic void set_op_auipc_ctrl();
    ex_ctrls.alumux1_sel = alumux::pc_out;
    ex_ctrls.alumux2_sel = alumux::u_imm;
    ex_ctrls.aluop = alu_add;
    wb_ctrls.load_regfile = 1'b1;
    wb_ctrls.regfilemux_sel = alu_out;
endfunction

function automatic void set_op_jal_ctrl();
    ex_ctrls.alumux1_sel = alumux::pc_out; // use pc 
    ex_ctrls.alumux2_sel = alumux::j_imm; 
    ex_ctrls.aluop = alu_add;
    wb_ctrls.load_regfile = 1'b1;
    wb_ctrls.regfilemux_sel = regfilemux::pc_plus4;
endfunction

// jalr follows i-type format
function automatic void set_op_jalr_ctrl();
    ex_ctrls.alumux1_sel = alumux::rs1_out; // use reg
    ex_ctrls.alumux2_sel = alumux::i_imm;   // i-imm
    ex_ctrls.aluop = alu_add;
    wb_ctrls.load_regfile = 1'b1;
    wb_ctrls.regfilemux_sel = regfilemux::pc_plus4;
endfunction

function automatic void set_op_br_ctrl();
    ex_ctrls.alumux1_sel = alumux::pc_out;
    ex_ctrls.alumux2_sel = alumux::b_imm;
    ex_ctrls.aluop = alu_add;
    ex_ctrls.cmpmux_sel = rs2_out;
    ex_ctrls.cmpop = branch_funct3;
    ex_ctrls.is_branch = 1'b1; // raise is_branch flag
endfunction

function automatic void set_op_store_ctrl();
    ex_ctrls.alumux1_sel = alumux::rs1_out;
    ex_ctrls.alumux2_sel = alumux::s_imm;
    ex_ctrls.aluop = alu_add;
    mem_ctrls.mem_write = 1'b1;

    // belong to mem stage
    // case (store_funct3)
    //     sw: mem_ctrls.wmask = 4'b1111;
    //     sh: mem_ctrls.wmask = 4'b0011 << {mem_offset[1], 1'b0};
    //     sb: mem_ctrls.wmask = 4'b0001 << mem_offset;
    //     default: wmask = 4'b1111;
    // endcase
    
endfunction

function automatic void set_op_load_ctrl();

endfunction

// i_type instruction, or op_imm will write to register
// and does nothing in mem stage
function automatic void set_op_imm_ctrl();
    wb_ctrls.load_regfile = 1'b1;
    case(arith_funct3) // arithmetic operation are encoded in funct3
        slt: begin
            // setCMP(cmpmux::i_imm, blt);
            ex_ctrls.cmpmux_sel = cmpmux::i_imm;
            ex_ctrls.cmpop = blt;
            wb_ctrls.regfilemux_sel = regfilemux::br_en;
        end
        sltu: begin
            // setCMP(cmpmux::i_imm, bltu);
            ex_ctrls.cmpmux_sel = cmpmux::i_imm;
            ex_ctrls.cmpop = bltu;
            wb_ctrls.regfilemux_sel = regfilemux::br_en; 
        end
        sr: begin
            ex_ctrls.alumux1_sel = alumux::rs1_out;
            ex_ctrls.alumux2_sel = alumux::i_imm;
            ex_ctrls.aluop = alu_srl;               // funct7[5] == 0
            if(funct7[5] == 1'b1) begin             // funct7[5] == 1
                ex_ctrls.aluop = alu_sra;
            end
            wb_ctrls.regfilemux_sel = regfilemux::alu_out;
            // setRegfileMux(regfilemux::alu_out);
        end
        default: begin  // add, and, or, xor, sll
            ex_ctrls.alumux1_sel = alumux::rs1_out;
            ex_ctrls.alumux2_sel = alumux::i_imm;
            ex_ctrls.aluop = `alu_ops(arith_funct3);
            wb_ctrls.regfilemux_sel = regfilemux::alu_out;
            // setALU(alumux::rs1_out, alumux::i_imm, `alu_ops(arith_funct3)); // EX
            // setRegfileMux(regfilemux::alu_out); // WB 
        end
    endcase

    // TODO: is pc_plus4 control by the control word
endfunction

// setting reg_reg instructions control signals
// reg_reg only will only use EX and WB control words
function automatic void set_op_reg_ctrl();
    wb_ctrls.load_regfile = 1'b1; // op_reg always load regfile
    case (arith_funct3)
        add: begin
            ex_ctrls.alumux1_sel = alumux::rs1_out;
            ex_ctrls.alumux2_sel = alumux::rs2_out;
            ex_ctrls.aluop = alu_add;   // default to add
            if(funct7[5] == 1'b1) begin // subtract operation check
                ex_ctrls.aluop = alu_sub;
            end
            wb_ctrls.regfilemux_sel = regfilemux::alu_out;
        end
        sr: begin
            ex_ctrls.alumux1_sel = alumux::rs1_out;
            ex_ctrls.alumux2_sel = alumux::rs2_out;
            ex_ctrls.aluop = alu_srl;   // default to logical right shift
            if(funct7[5] == 1'b1) begin // arithmetic right shift check
                ex_ctrls.aluop = alu_sra;
            end
        end 
        slt: begin
            ex_ctrls.cmpmux_sel = rs2_out;
            ex_ctrls.cmpop = blt;
            wb_ctrls.regfilemux_sel = regfilemux::br_en; 
        end
        sltu: begin
            ex_ctrls.cmpmux_sel = rs2_out;
            ex_ctrls.cmpop = bltu;
            wb_ctrls.regfilemux_sel = regfilemux::br_en;
        end
        default: begin // and, or, xor, sll
            ex_ctrls.alumux1_sel = alumux::rs1_out;
            ex_ctrls.alumux2_sel = alumux::rs2_out;
            ex_ctrls.aluop = `alu_ops(arith_funct3);
            wb_ctrls.regfilemux_sel = regfilemux::alu_out;
        end
    endcase
endfunction


always_comb begin
    ctrl_word = '0; // clear ctrl word
    ex_ctrls = '0;
    mem_ctrls = '0;
    wb_ctrls = '0;
    ctrl_word.valid = 1'b1; 
    ctrl_word.pc = pc_i;
    ctrl_word.opcode = opcode;
    ctrl_word.ex_ctrlwd = ex_ctrls;
    ctrl_word.mem_ctrlwd = mem_ctrls;
    ctrl_word.wb_ctrlwd = wb_ctrls;
    
    unique case(opcode) 
        op_lui: begin
            set_op_lui_ctrl();
        end
        op_auipc: begin
            set_op_auipc_ctrl();
        end
        op_jal: begin
            set_op_jal_ctrl();
        end
        op_jalr: begin
            set_op_jalr_ctrl();
        end
        op_br: begin
            set_op_br_ctrl();
        end
        op_store: begin
            set_op_store_ctrl();
        end
        op_load: begin
            set_op_load_ctrl();
        end
        op_imm: begin
            set_op_imm_ctrl();
        end
        op_reg: begin
            set_op_reg_ctrl();
        end
        default:;
    endcase
end
endmodule 

// op_lui   = 7'b0110111, //load upper immediate (U type)
// op_auipc = 7'b0010111, //add upper immediate PC (U type)
// op_jal   = 7'b1101111, //jump and link (J type)
// op_jalr  = 7'b1100111, //jump and link register (I type)
// op_br    = 7'b1100011, //branch (B type)
// op_load  = 7'b0000011, //load (I type)
// op_store = 7'b0100011, //store (S type)
// op_imm   = 7'b0010011, //arith ops with register/immediate operands (I type)
// op_reg   = 7'b0110011, //arith ops with register operands (R type)
// op_csr   = 7'b1110011  //control and status register (I type)

// typedef struct packed{
//     logic           is_branch;  
//     alu_ops         aluop;
//     branch_funct3_t cmpop;
//     cmpmux_sel_t    cmpmux_sel;
//     alumux1_sel_t   alumux1_sel;
//     alumux2_sel_t   alumux2_sel;
//     // TODO: double check this, seems like it is part of both IF and EXE, do we still need this?
//     // not really in my opinion
//     marmux_sel_t    marmux_sel;
// }EX_ctrl_t;

// typedef struct packed{
//     logic               mem_read;
//     logic               mem_write;
//     rv32i_mem_wmask     wmask;
// }MEM_ctrl_t;

// typedef struct packed{
//     logic               load_regfile;   
//     regfilemux_sel_t    regfilemux_sel;
// }WB_ctrl_t;

// typedef struct packed{
//     logic           valid;
//     rv32i_word      pc;
//     rv32i_opcode    opcode;
//     EX_ctrl_t       ex_ctrlwd;
//     MEM_ctrl_t      mem_ctrlwd;
//     WB_ctrl_t       wb_ctrlwd;  
// }ctrl_word_t;

// function void setALU(alumux::alumux1_sel_t sel1, alumux::alumux2_sel_t sel2, alu_ops op); 
//     ex_ctrls.alumux1_sel = sel1;
//     ex_ctrls.alumux2_sel = sel2;
//     ex_ctrls.aluop = op;
// endfunction
// function void setCMP(cmpmux::cmpmux_sel_t sel, branch_funct3_t op);
//     ex_ctrls.cmpmux_sel = sel;
//     ex_ctrls.cmpop = op;
// endfunction
// function void setRegfileMux(regfilemux::regfilemux_sel_t sel);
//     wb_ctrls.regfilemux_sel = sel;
// endfunction
