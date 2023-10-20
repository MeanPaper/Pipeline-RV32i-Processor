module mem
import rv32i_types::*;
(   
    input clk,
    input rst,

    /* input signals from Magic Memory */
    input logic [31:0] dmem_rdata, 

    /* input signals from EX/MEM buffer */
    input EX_MEM_stage_t mem_in,

    /* output to EX/MEM buffer */
    output MEM_WB_stage_t mem_out,

    /* output to Magic Memory */
    output logic [31:0] dmem_wdata,
    output logic [31:0] dmem_address
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
        mem_out.mdr <= dmem_rdata;
    end
end: mdr

/**********dmem_address***********/
assign dmem_address = {mem_in.mar[31:2], 2'b0};

/**********dmem_wdata*************/
always_comb begin: dmem_write_data
    if (opcode == op_store) begin
        case(store_funct3_t'(funct3))
            sw: dmem_wdata = mem_in.mem_data_out;
            sh: begin 
                unique case(mem_in.mar[1])
                    1'b1: dmem_wdata = mem_in.mem_data_out << 16;
                    1'b0: dmem_wdata = mem_in.mem_data_out;
            endcase
            end
            sb: begin
                unique case(mem_in.mar[1:0])
                    2'b00: dmem_wdata = mem_in.mem_data_out;
                    2'b01: dmem_wdata = mem_in.mem_data_out << 8;
                    2'b10: dmem_wdata = mem_in.mem_data_out << 16;
                    2'b11: dmem_wdata = mem_in.mem_data_out << 24;
                endcase
            end
            default: dmem_wdata = mem_in.mem_data_out;
        endcase
    end   
    else begin
        dmem_wdata = mem_in.mem_data_out;
    end
end: dmem_write_data 




endmodule