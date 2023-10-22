module i_fetch
import rv32i_types::*;
(
    /* inputs */
    input clk,
    input rst,
    input rv32i_word alu_out,
    input pcmux::pcmux_sel_t pcmux_sel,
    input logic load_pc,

    /* outputs to IF/ID buffer */
    output IF_ID_stage_t if_output,

    /* outputs to Magic Memory */
    output logic imem_read,
    output logic [31:0] imem_address
);
/******************* Signals Needed for RVFI Monitor *************************/
rv32i_word pcmux_out;
/*****************************************************************************/

pc PC (
    .clk(clk),
    .rst(rst), //may need flsuh
    .load(load_pc), //may use for stall
    .in(pcmux_out),
    .out(if_output.pc_out)
);

always_comb begin : PC_MUX
    unique case (pcmux_sel)
        pcmux::pc_plus4: pcmux_out = if_output.pc_out + 4;
        pcmux::alu_out: pcmux_out = alu_out;
        pcmux::alu_mod2: pcmux_out = {alu_out[31:1], 1'b0};
    endcase
end

assign imem_address = if_output.pc_out;
assign imem_read = 1'b1; //for CP1

endmodule