module execute
import rv32i_types::*;
(
    /* input signals from ID/EX buffer */
    input rv32i_word pc_out,
    input rv32i_word rs1_out,
    input rv32i_word rs2_out,
    input rv32i_word i_imm,
    input rv32i_word u_imm,
    input rv32i_word b_imm,
    input rv32i_word s_imm,
    input rv32i_word j_imm,
    input alu_ops aluop,
    input branch_funct3_t cmpop,
    input alumux::alumux1_sel_t alumux1_sel,
    input alumux::alumux2_sel_t alumux2_sel,
    input cmpmux::cmpmux_sel_t cmpmux_sel,

    /* output to EX/MEM buffer */
    output rv32i_word alu_out,
    output pcmux::pcmux_sel_t pcmux_sel,
);
    /* intermidiate variables */
    /* ALU signals */
    rv32i_word alumux1_out;
    rv32i_word alumux2_out;
    /* CMP signals */
    logic br_en;
    rv32i_word cmpmux_out;


    alu ALU(
        .aluop,
        .a(alumux1_out),
        .b(alumux2_out),
        .f(alu_out)
    );

    cmp CMP(
        .a(rs1_out),
        .b(cmpmux_out),
        .cmpop,
        .br_en(br_en)
    );

    /******************************** Muxes **************************************/
always_comb begin : MUXES
    unique case (alumux1_sel)
        alumux::rs1_out: alumux1_out = rs1_out;
        alumux::pc_out: alumux1_out = pc_out;
    endcase

    unique case (alumux2_sel)
        alumux::i_imm: alumux2_out = i_imm;
        alumux::u_imm: alumux2_out = u_imm;
        alumux::b_imm: alumux2_out = b_imm;
        alumux::s_imm: alumux2_out = s_imm;
        alumux::j_imm: alumux2_out = j_imm;
        alumux::rs2_out: alumux2_out = rs2_out;
    endcase

    unique case (cmpmux_sel)
        cmpmux::rs2_out: cmpmux_out = rs2_out;
        cmpmux::i_imm: cmpmux_out = i_imm;
    endcase

end : MUXES

endmodule
