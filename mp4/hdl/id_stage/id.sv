
module i_decode 
import rv32i_types::*;
(
    /* inputs */
    input logic clk,
    input logic rst,
    input IF_ID_stage_t id_in,
    input regfilemux::regfilemux_sel_t regfilemux_sel,
    
    /* outputs to ID/EX buffer*/
    output ID_EX_stage_t id_out

);
    /* RegFile signals */
    logic [7:0] mdrreg_b;
    logic [15:0] mdrreg_h;

    

    /* regfile */
    regfile RegFile(
        .clk,
        .rst,
        .load(load_regfile),
        .in(regfilemux_out),  
        .src_a(rs1),
        .src_b(rs2),
        .dest(rd),
        .reg_a(rs1_out),
        .reg_b(rs2_out)
    );
    /* control word */

    /* possible Hazard Detection Unit in forwarding */
    /* save for cp2 */

    /* i_decode muxes */
    always_comb begin : EX_MUXES

        unique case (regfilemux_sel)
        regfilemux::alu_out: regfilemux_out = alu_out;
        regfilemux::br_en: regfilemux_out = {31'b0, br_en};
        regfilemux::u_imm: regfilemux_out = u_imm;
        regfilemux::lw: regfilemux_out = mdrreg_out;
        regfilemux::lb: regfilemux_out = {{24{mdrreg_b[7]}}, mdrreg_b}; // TODO: hopefully this works
        regfilemux::lbu: regfilemux_out = {{24{1'b0}}, mdrreg_b};
        regfilemux::lh: regfilemux_out = {{16{mdrreg_h[15]}}, mdrreg_h};
        regfilemux::lhu: regfilemux_out = {{16{1'b0}}, mdrreg_h};
        regfilemux::pc_plus4: regfilemux_out = pc_out + 4;
        endcase

    end : EX_MUXES




endmodule 
