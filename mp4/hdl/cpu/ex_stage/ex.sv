module execute
import rv32i_types::*;
(
    /* input signals from ID/EX buffer */
    input ID_EX_stage_t ex_in,

    /* output to EX/MEM buffer */
    output EX_MEM_stage_t ex_out,
    output pcmux::pcmux_sel_t pcmux_sel
);
    /* intermidiate variables */
    /* ALU signals */
    rv32i_word alumux1_out;
    rv32i_word alumux2_out;
    rv32i_word alu_out;
    /* CMP signals */
    logic br_en;
    rv32i_word cmpmux_out;
    logic is_jlar;
    /* MAR signals */
    rv32i_word marmux_out;
    rv32i_word rvfi_pc_wdata_ex;

    /* signals that pass down to the next stage */

    assign is_jlar = (ex_in.ctrl_wd.opcode == op_jalr);
    // assign ex_out.cmp_out = br_en;
    // assign ex_out.ctrl_wd = ex_in.ctrl_wd;
    // assign ex_out.alu_out = alu_out;
    // assign ex_out.mar = marmux_out;
    // assign ex_out.mem_data_out = ex_in.rs2_out << (8 * marmux_out[1:0]); 
    // assign ex_out.u_imm = ex_in.u_imm;
    // assign ex_out.rd = ex_in.rd;

    // /* rvfi signals */
    // assign ex_out.rvfi_d = ex_in.rvfi_d;


    alu ALU(
        .aluop(ex_in.ctrl_wd.ex_ctrlwd.aluop),
        .a(alumux1_out),
        .b(alumux2_out),
        .f(alu_out)
    );

    cmp CMP(
        .a(ex_in.rs1_out),
        .b(cmpmux_out),
        .cmpop(ex_in.ctrl_wd.ex_ctrlwd.cmpop),
        .br_en(br_en)
    );

    /*********** EX Muxes **********/
    always_comb begin : EX_MUXES

        rvfi_pc_wdata_ex = ex_in.ctrl_wd.pc + 4;

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

        unique case (ex_in.ctrl_wd.ex_ctrlwd.cmpmux_sel)
            cmpmux::rs2_out: cmpmux_out = ex_in.rs2_out;
            cmpmux::i_imm: cmpmux_out = ex_in.i_imm;
        endcase

        unique case (is_jlar)
            1'b0: 
            begin
                pcmux_sel = {1'b0, br_en & ex_in.ctrl_wd.ex_ctrlwd.is_branch}; // TODO: not sure if this is valid

                // for rvfi
                // rvfi_pc_wdata_ex = ex_in.ctrl_wd.pc;
                if(br_en & ex_in.ctrl_wd.ex_ctrlwd.is_branch) begin // if there is a branch
                    rvfi_pc_wdata_ex = alu_out;
                end
            end
            1'b1:
            begin
                pcmux_sel = pcmux::alu_mod2;
                rvfi_pc_wdata_ex = {alu_out[31:1], 1'b0};
            end
            default: begin 
                pcmux_sel = {1'b0, br_en & ex_in.ctrl_wd.ex_ctrlwd.is_branch};
                // for rvfi
                // rvfi_pc_wdata_ex = ex_in.ctrl_wd.pc; 
                if(br_en & ex_in.ctrl_wd.ex_ctrlwd.is_branch) begin
                    rvfi_pc_wdata_ex = alu_out;
                end
            end 
        endcase

        unique case (ex_in.ctrl_wd.ex_ctrlwd.marmux_sel)
            marmux::pc_out: marmux_out = ex_in.ctrl_wd.pc;
            marmux::alu_out: marmux_out = alu_out;
        endcase


    end : EX_MUXES


    always_comb begin
        ex_out.cmp_out = br_en;
        ex_out.ctrl_wd = ex_in.ctrl_wd;
        ex_out.alu_out = alu_out;
        ex_out.mar = marmux_out;
        ex_out.mem_data_out = ex_in.rs2_out << (8 * marmux_out[1:0]); 
        ex_out.u_imm = ex_in.u_imm;
        ex_out.rd = ex_in.rd;
        ex_out.rvfi_d = ex_in.rvfi_d;
        ex_out.rvfi_d.rvfi_pc_wdata = rvfi_pc_wdata_ex; // something wrong here, causing pc_wdata to be wrong
    end

endmodule
