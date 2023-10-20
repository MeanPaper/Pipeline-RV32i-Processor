module mem
import rv32i_types::*;
(   
    input clk,
    input rst,
    input logic [31:0] mem_rdata, //for CP1
    /* input signals from EX/MEM buffer */
    input EX_MEM_stage_t mem_in,

    /* output to EX/MEM buffer */
    output MEM_WB_stage_t mem_out
);

/*****transfer to next stage******/
always_ff @(posedge clk ) begin : transfer_to_next
    mem_out.cmp_out <= mem_in.cmp_out;
    mem_out.u_imm <= mem_in.u_imm;
    mem_out.rd <= mem_in.rd;
    mem_out.alu_out <= mem_in.alu_out;
end: transfer_to_next


/**************mdr_out************/
always_ff @(posedge clk) begin : mdr
    if (rst) begin
        mem_out.mdr <= '0;
    end else if (load_mdr) begin
        mem_out.mdr <= mem_rdata;
    end
end: mdr




endmodule