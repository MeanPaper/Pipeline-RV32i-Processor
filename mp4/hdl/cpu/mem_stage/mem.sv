module mem
import rv32i_types::*;
(   
    input clk,
    input rst,
    input logic load_mdr,

    /* input signals from Magic Memory */
    input logic [31:0] dmem_rdata, 

    /* input signals from EX/MEM buffer */
    input EX_MEM_stage_t mem_in,
    input logic dmem_resp,

    /* output to EX/MEM buffer */
    output MEM_WB_stage_t mem_out,

    /* output to Magic Memory */
    output logic [31:0] dmem_wdata,
    output logic [31:0] dmem_address,
    output logic dmem_read,
    output logic dmem_write,
    output logic [3:0] mem_byte_enable
);

//to do: wmask & mem_byte_enable
//to do: figure out when to output dmem_read and dmem_write
//not declare load_mdr in version 10.20 9:13
//done: pass control_wd store_funct3 into stage
// MEM_WB_stage_t mem_mid_reg;

logic [3:0] wmask;
logic [3:0] rmask;
load_funct3_t load_funct3;
store_funct3_t store_funct3;
assign load_funct3 = load_funct3_t'(mem_in.ctrl_wd.mem_ctrlwd.funct3);
assign store_funct3 = store_funct3_t'(mem_in.ctrl_wd.mem_ctrlwd.funct3);

/**********dmem_address***********/
assign dmem_address = {mem_in.mar[31:2], 2'b0};

/**********dmem_wdata*************/
always_comb begin: dmem_write_data

    case(store_funct3)
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
end: dmem_write_data 
 

/***************** wmask & rmask ******************************/
always_comb begin
    wmask = '0;
    rmask = '0;
    if(mem_in.ctrl_wd.opcode == op_store) begin
        case (store_funct3)
            sw: wmask = 4'b1111;
            sh: 
            begin
                case(dmem_address[1:0])
                    2'b00: wmask = 4'b0011;
                    2'b01: wmask = 4'bxxxx;
                    2'b10: wmask = 4'b1100;
                    2'b11: wmask = 4'bxxxx;
                endcase
            end
            sb:
            begin
                case(dmem_address[1:0])
                    2'b00: wmask = 4'b0001;
                    2'b01: wmask = 4'b0010;
                    2'b10: wmask = 4'b0100;
                    2'b11: wmask = 4'b1000;
                endcase
            end 
        endcase
    end
    else if(mem_in.ctrl_wd.opcode == op_load) begin
        case (load_funct3)
            lw: rmask = 4'b1111;
            lh, lhu: 
            begin
                case(dmem_address[1:0])
                    2'b00: rmask = 4'b0011;
                    2'b01: rmask = 4'bxxxx;
                    2'b10: rmask = 4'b1100;
                    2'b11: rmask = 4'bxxxx;
                endcase
            end
            lb, lbu:
            begin
                case(dmem_address[1:0])
                    2'b00: rmask = 4'b0001;
                    2'b01: rmask = 4'b0010;
                    2'b10: rmask = 4'b0100;
                    2'b11: rmask = 4'b1000;
                endcase
            end
        endcase
    end
end

/********** mem_byte_enable & dmem_read & dmem_write **************/
assign mem_byte_enable = wmask;
assign dmem_write = mem_in.ctrl_wd.mem_ctrlwd.mem_write;
assign dmem_read = mem_in.ctrl_wd.mem_ctrlwd.mem_read;

// always_ff @(posedge clk) begin
//     if(rst) begin
//         mem_mid_reg <= '0;
//     end
//     else begin
//         mem_mid_reg.ctrl_wd <= mem_in.ctrl_wd;
//         mem_mid_reg.cmp_out <= mem_in.cmp_out;
//         mem_mid_reg.u_imm <= mem_in.u_imm;
//         mem_mid_reg.rd <= mem_in.rd;
//         mem_mid_reg.alu_out <= mem_in.alu_out;
//         mem_mid_reg.mar <= mem_in.mar;
//         mem_mid_reg.mdr <= '0;   // mdr next value

//         mem_mid_reg.rvfi_d.rvfi_valid       <= mem_in.rvfi_d.rvfi_valid;
//         mem_mid_reg.rvfi_d.rvfi_order       <= mem_in.rvfi_d.rvfi_order;
//         mem_mid_reg.rvfi_d.rvfi_inst        <= mem_in.rvfi_d.rvfi_inst;
//         mem_mid_reg.rvfi_d.rvfi_rs1_addr    <= mem_in.rvfi_d.rvfi_rs1_addr;
//         mem_mid_reg.rvfi_d.rvfi_rs2_addr    <= mem_in.rvfi_d.rvfi_rs2_addr;
//         mem_mid_reg.rvfi_d.rvfi_rs1_rdata   <= mem_in.rvfi_d.rvfi_rs1_rdata;
//         mem_mid_reg.rvfi_d.rvfi_rs2_rdata   <= mem_in.rvfi_d.rvfi_rs2_rdata;
//         mem_mid_reg.rvfi_d.rvfi_rd_addr     <= mem_in.rvfi_d.rvfi_rd_addr;
//         mem_mid_reg.rvfi_d.rvfi_rd_wdata    <= mem_in.rvfi_d.rvfi_rd_wdata;
//         mem_mid_reg.rvfi_d.rvfi_pc_rdata    <= mem_in.rvfi_d.rvfi_pc_rdata;
//         mem_mid_reg.rvfi_d.rvfi_pc_wdata    <= mem_in.rvfi_d.rvfi_pc_wdata;
//         mem_mid_reg.rvfi_d.rvfi_mem_addr    <= {mem_in.mar[31:2], 2'b0};
//         mem_mid_reg.rvfi_d.rvfi_mem_rmask   <= rmask;
//         mem_mid_reg.rvfi_d.rvfi_mem_wmask   <= wmask;
//         mem_mid_reg.rvfi_d.rvfi_mem_rdata   <= '0;
//         mem_mid_reg.rvfi_d.rvfi_mem_wdata   <= '0;
    
//     end
// end 


// used by pass at this checkpoint
/*****transfer to next stage******/
// always_comb begin
//     mem_out.ctrl_wd = mem_mid_reg.ctrl_wd;
//     mem_out.cmp_out = mem_mid_reg.cmp_out;
//     mem_out.u_imm = mem_mid_reg.u_imm;
//     mem_out.rd = mem_mid_reg.rd;
//     mem_out.alu_out = mem_mid_reg.alu_out;
//     mem_out.mar = mem_mid_reg.mar;
//     mem_out.mdr = mem_mid_reg.mdr;   // mdr next value
//     if(dmem_resp) mem_out.mdr = dmem_rdata;   // mdr next value    
    
//     // rvfi section
//     mem_out.rvfi_d                  = mem_mid_reg.rvfi_d;
//     mem_out.rvfi_d.rvfi_mem_addr    = {mem_mid_reg.mar[31:2], 2'b0};
//     mem_out.rvfi_d.rvfi_mem_rmask   = mem_mid_reg.rvfi_d.rvfi_mem_rmask; 
//     mem_out.rvfi_d.rvfi_mem_wmask   = mem_mid_reg.rvfi_d.rvfi_mem_wmask;
//     mem_out.rvfi_d.rvfi_mem_rdata   = mem_mid_reg.rvfi_d.rvfi_mem_rdata;
//     mem_out.rvfi_d.rvfi_mem_wdata   = mem_mid_reg.rvfi_d.rvfi_mem_wdata;
//     if(dmem_resp) mem_out.rvfi_d.rvfi_mem_rdata   = dmem_rdata;
//     if(dmem_write) mem_out.rvfi_d.rvfi_mem_wdata   = dmem_wdata; 
// end


// use for later
always_comb begin : transfer_to_next
    mem_out.ctrl_wd = mem_in.ctrl_wd;
    mem_out.cmp_out = mem_in.cmp_out;
    mem_out.u_imm = mem_in.u_imm;
    mem_out.rd = mem_in.rd;
    mem_out.alu_out = mem_in.alu_out;
    mem_out.mar = mem_in.mar;
    mem_out.mdr = dmem_rdata;   // mdr next value TODO: need to fix in CP2 
    // if(dmem_resp) mem_out.mdr = dmem_rdata;   // mdr next value, for later part
    
    // rvfi section
    mem_out.rvfi_d                  = mem_in.rvfi_d;
    mem_out.rvfi_d.rvfi_mem_addr    = {mem_in.mar[31:2], 2'b0};
    mem_out.rvfi_d.rvfi_mem_rmask   = rmask; 
    mem_out.rvfi_d.rvfi_mem_wmask   = wmask;
    mem_out.rvfi_d.rvfi_mem_rdata = '0; // TODO: need to fix later: CP2
    mem_out.rvfi_d.rvfi_mem_wdata = '0;
    if(dmem_resp) mem_out.rvfi_d.rvfi_mem_rdata   = dmem_rdata; // for later part
    if(dmem_write) mem_out.rvfi_d.rvfi_mem_wdata   = dmem_wdata; 

end: transfer_to_next


endmodule

/*
always_comb begin : trap_check
    trap = '0;
    rmask = '0;
    wmask = '0;

    case (mem_in.ctrl_wd.opcode)
        op_lui, op_auipc, op_imm, op_reg, op_jal, op_jalr:;

        op_br: begin
            case (branch_funct3)
                beq, bne, blt, bge, bltu, bgeu:;
                default: trap = '1;
            endcase
        end

        op_load: begin
            case (load_funct3)
                lw: rmask = 4'b1111;
                lh, lhu: 
                begin
                    case(dmem_address[1:0])d
                        2'b00: rmask = 4'b0011;
                        2'b01: rmask = 4'bxxxx;
                        2'b10: rmask = 4'b1100;
                        2'b11: rmask = 4'bxxxx;
                    endcase
                end
                lb, lbu:
                begin
                    case(dmem_address[1:0])
                        2'b00: rmask = 4'b0001;
                        2'b01: rmask = 4'b0010;
                        2'b10: rmask = 4'b0100;
                        2'b11: rmask = 4'b1000;
                    endcase
                end
                default: trap = '1;
            endcase
        end

        op_store: begin
            mem_byte_enable = wmask; //not sure right or not
            case (store_funct3)
                sw: wmask = 4'b1111;
                sh: 
                begin
                    case(dmem_address[1:0])
                        2'b00: wmask = 4'b0011;
                        2'b01: wmask = 4'bxxxx;
                        2'b10: wmask = 4'b1100;
                        2'b11: wmask = 4'bxxxx;
                    endcase
                end
                sb:
                begin
                    case(dmem_address[1:0])
                        2'b00: wmask = 4'b0001;
                        2'b01: wmask = 4'b0010;
                        2'b10: wmask = 4'b0100;
                        2'b11: wmask = 4'b1000;
                    endcase
                end
                default: trap = '1;
            endcase
        end

        default: trap = '1;
    endcase
end
*/
