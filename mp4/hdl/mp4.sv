module mp4
import rv32i_types::*;
(
    input   logic           clk,
    input   logic           rst,

    // Use these for CP1 (magic memory)
    output  logic   [31:0]  imem_address,
    output  logic           imem_read,
    input   logic   [31:0]  imem_rdata,
    input   logic           imem_resp,
    output  logic   [31:0]  dmem_address,
    output  logic           dmem_read,
    output  logic           dmem_write,
    output  logic   [3:0]   dmem_wmask,
    input   logic   [31:0]  dmem_rdata,
    output  logic   [31:0]  dmem_wdata,
    input   logic           dmem_resp

    // Use these for CP2+ (with caches and burst memory)
    // output  logic   [31:0]  bmem_address,
    // output  logic           bmem_read,
    // output  logic           bmem_write,
    // input   logic   [63:0]  bmem_rdata,
    // output  logic   [63:0]  bmem_wdata,
    // input   logic           bmem_resp
);
    /* Stanley coding style */
            logic           monitor_valid;
            logic   [63:0]  monitor_order;
            logic   [31:0]  monitor_inst;
            logic   [4:0]   monitor_rs1_addr;
            logic   [4:0]   monitor_rs2_addr;
            logic   [31:0]  monitor_rs1_rdata;
            logic   [31:0]  monitor_rs2_rdata;
            logic   [4:0]   monitor_rd_addr;
            logic   [31:0]  monitor_rd_wdata;
            logic   [31:0]  monitor_pc_rdata;
            logic   [31:0]  monitor_pc_wdata;
            logic   [31:0]  monitor_mem_addr;
            logic   [3:0]   monitor_mem_rmask;
            logic   [3:0]   monitor_mem_wmask;
            logic   [31:0]  monitor_mem_rdata;
            logic   [31:0]  monitor_mem_wdata;

    /* My coding style */
    logic commit;
    logic [63:0] order;

    // rv32i_inst_t inst_ex, inst_mem, inst_wb;
    // rv32i_word pc_wdata_id, pc_wdata_ex, pc_wdata_mem, pc_wdata_wb, commit_addr;
    // rv32i_word rs1_out_mem, rs1_out_wb;
    // rv32i_word rs2_out_mem, rs2_out_wb;
    // logic [3:0] commit_rmask, commit_wmask;
    
    always_ff @(posedge clk) begin
        if(rst) begin
            order <= '0;
        end
        else begin 
            if(commit == 1'b1) order <= order + 1;
        
            // // instruction commit tracking
            // inst_ex <= cpu.if_to_id.ir;
            // inst_mem <= inst_ex;
            // inst_wb <= inst_mem;

            // // pc wdata commit tracking
            // pc_wdata_id <= cpu.i_fetch.pcmux_out;
            // pc_wdata_ex <= pc_wdata_id;
            // pc_wdata_mem <= pc_wdata_ex;
            // pc_wdata_wb <= pc_wdata_mem;

            // // r and w mask
            // commit_rmask <= cpu.mem.rmask;
            // commit_wmask <= cpu.mem.wmask;
            
            // // addr tracking
            // commit_addr <= cpu.mem.dmem_address;

            // // rs1 and rs2 value tracking
            // rs1_out_mem <= cpu.id_to_ex.rs1_out;
            // rs1_out_wb <= rs1_out_mem;
            // rs2_out_mem <= cpu.id_to_ex.rs2_out;
            // rs2_out_wb <= rs2_out_mem;
        end
    end



    assign commit = cpu.mem_to_wb.ctrl_wd.valid;

    // Fill this out
    // Only use hierarchical references here for verification
    // **DO NOT** use hierarchical references in the actual design!
    assign monitor_valid     = commit;
    assign monitor_order     = order;
    assign monitor_inst      = cpu.mem_to_wb.rvfi_d.rvfi_inst;
    assign monitor_rs1_addr  = cpu.mem_to_wb.rvfi_d.rvfi_rs1_addr;
    assign monitor_rs2_addr  = cpu.mem_to_wb.rvfi_d.rvfi_rs2_addr;
    assign monitor_rs1_rdata = cpu.mem_to_wb.rvfi_d.rvfi_rs1_rdata;
    assign monitor_rs2_rdata = cpu.mem_to_wb.rvfi_d.rvfi_rs2_rdata;
    assign monitor_rd_addr   = cpu.mem_to_wb.rvfi_d.rvfi_rd_addr;
    assign monitor_rd_wdata  = cpu.regfile_in;  
    assign monitor_pc_rdata  = cpu.mem_to_wb.rvfi_d.rvfi_pc_rdata;
    assign monitor_pc_wdata  = cpu.mem_to_wb.rvfi_d.rvfi_pc_wdata;
    assign monitor_mem_addr  = cpu.mem_to_wb.rvfi_d.rvfi_mem_addr;        
    assign monitor_mem_rmask = cpu.mem_to_wb.rvfi_d.rvfi_mem_rmask; 
    assign monitor_mem_wmask = cpu.mem_to_wb.rvfi_d.rvfi_mem_wmask;
    // assign monitor_mem_rdata = cpu.mem_to_wb.rvfi_d.rvfi_mem_rdata;
    assign monitor_mem_rdata = cpu.write_back.dmem_rdata;           // this is somewhat bad, because cp1 use direct wire
    assign monitor_mem_wdata = cpu.mem_to_wb.rvfi_d.rvfi_mem_wdata;
    
    cpu cpu(
        .clk,
        .rst,
        .imem_address,
        .imem_read, //need double check
        .imem_rdata,
        .imem_resp, //tbd
        .dmem_address,
        .dmem_read,
        .dmem_write, 
        .dmem_wmask,
        .dmem_rdata,
        .dmem_wdata,
        .dmem_resp //tbd
    );

endmodule : mp4
