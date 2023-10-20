module execute
import rv32i_types::*;
(
    /* input signals from ID/EX buffer */
    // input rv32i_word pc_out,
    // input rv32i_word rs1_out,
    // input rv32i_word rs2_out,
    // input rv32i_word i_imm,
    // input rv32i_word u_imm,
    // input rv32i_word b_imm,
    // input rv32i_word s_imm,
    // input rv32i_word j_imm,
    // input alu_ops aluop,
    // input branch_funct3_t cmpop,
    // input alumux::alumux1_sel_t alumux1_sel,
    // input alumux::alumux2_sel_t alumux2_sel,
    // input cmpmux::cmpmux_sel_t cmpmux_sel,
    // input logic is_branch,
    // input rv32i_opcode opcode,
    input ID_EX_stage_t ex_in,

    /* output to EX/MEM buffer */
    output EX_MEM_stage_t ex_out,
    output logic [1:0] pcmux_sel
);
    /* intermidiate variables */
    /* ALU signals */
    rv32i_word alumux1_out;
    rv32i_word alumux2_out;
    /* CMP signals */
    logic br_en;
    rv32i_word cmpmux_out;
    logic is_jlar;

    assign ex_out.cmp_out = br_en;
    assign is_jlar = (ex_in.ctrl_wd.opcode == op_jalr);

    alu ALU(
        .aluop(ex_in.ctrl_wd.ex_ctrlwd.aluop),
        .a(alumux1_out),
        .b(alumux2_out),
        .f(ex_out.alu_out)
    );

    cmp CMP(
        .a(ex_in.rs1_out),
        .b(cmpmux_out),
        .cmpop(ex_in.ctrl_wd.ex_ctrlwd.cmpop),
        .br_en(br_en)
    );

    /*********** EX Muxes **********/
    always_comb begin : EX_MUXES
        unique case (ex_in.ctrl_wd.ex_ctrlwd.alumux1_sel)
            alumux::rs1_out: alumux1_out = ex_in.rs1_out;
            alumux::pc_out: alumux1_out = ex_in.ctrl_wd.pc;
        endcase

        unique case (ex_in.ctrl_wd.ex_ctrlwd.alumux2_sel)
            alumux::i_imm: alumux2_out = ex_in.i_imm;
            alumux::u_imm: alumux2_out = ex_in.u_imm;
            alumux::b_imm: alumux2_out = ex_in.b_imm;
            alumux::s_imm: alumux2_out = ex_in.s_imm;
            alumux::j_imm: alumux2_out = ex_in.j_imm;
            alumux::rs2_out: alumux2_out = ex_in.rs2_out;
        endcase

        unique case (cmpmux_sel)
            cmpmux::rs2_out: cmpmux_out = ex_in.rs2_out;
            cmpmux::i_imm: cmpmux_out = ex_in.i_imm;
        endcase

        unique case (is_jlar)
            1'b0: 
            begin
                pcmux_sel = {1'b0, br_en & ex_in.ctrl_wd.ex_ctrlwd.is_branch}; // TODO: not sure if this is valid
            end
            1'b1:
            begin
                pcmux_sel = pcmux::alu_mod2;
            end
            default: pcmux_sel = {1'b0, br_en & ex_in.ctrl_wd.ex_ctrlwd.is_branch};
        endcase

    end : EX_MUXES

endmodule
