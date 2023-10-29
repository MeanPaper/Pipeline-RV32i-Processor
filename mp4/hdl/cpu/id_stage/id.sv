
module i_decode 
import rv32i_types::*;
(
    /* inputs */
    input logic             clk,
    input logic             rst,
    input IF_ID_stage_t     id_in,
    input rv32i_word        regfile_in,
    input logic             load_regfile,
    input rv32i_reg         rd,
    /* outputs to ID/EX buffer*/
    output ID_EX_stage_t    id_out
);
    /* RegFile signals */


    /* control word signals */


    /* signals to send out to next stage */
    assign id_out.i_imm = {{21{id_in.ir.word[31]}}, id_in.ir.word[30:20]};
    assign id_out.s_imm = {{21{id_in.ir.word[31]}}, id_in.ir.word[30:25], id_in.ir.word[11:7]};
    assign id_out.b_imm = {{20{id_in.ir.word[31]}}, id_in.ir.word[7], id_in.ir.word[30:25], id_in.ir.word[11:8], 1'b0};
    assign id_out.u_imm = {id_in.ir.word[31:12], 12'h000};
    assign id_out.j_imm = {{12{id_in.ir.word[31]}}, id_in.ir.word[19:12], id_in.ir.word[20], id_in.ir.word[30:21], 1'b0};
    assign id_out.rd = id_in.ir.r_inst.rd;

    /* setting up rvfi signals */
    always_comb begin
        id_out.rvfi_d = id_in.rvfi_d;

        /* some other signals that I need to turn on */
        id_out.rvfi_d.rvfi_inst = id_in.ir.word;
        id_out.rvfi_d.rvfi_rs1_addr = id_in.ir.r_inst.rs1;
        id_out.rvfi_d.rvfi_rs2_addr = id_in.ir.r_inst.rs2;
        id_out.rvfi_d.rvfi_rs1_rdata = id_out.rs1_out;
        id_out.rvfi_d.rvfi_rs2_rdata = id_out.rs2_out;
        id_out.rvfi_d.rvfi_rd_addr = id_in.ir.r_inst.rd;
    end 


    
    /* assignments */
    


    /* control word */
    control_word ControlWord (
        .pc_i(id_in.pc),
        .instr_i(id_in.ir.word),
        .control_words_o(id_out.ctrl_wd)
    );

    /* regfile */
    regfile RegFile(
        .clk(clk),
        .rst(rst),
        .load(load_regfile),
        .in(regfile_in),  
        .src_a(id_in.ir.r_inst.rs1),
        .src_b(id_in.ir.r_inst.rs2),
        .dest(rd), // this is not correct
        .reg_a(id_out.rs1_out),
        .reg_b(id_out.rs2_out)
    );
    
    /* possible Hazard Detection Unit in forwarding */
    /* save for cp2 */




endmodule 
