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

    assign commit = cpu.load_pc;

    // Fill this out
    // Only use hierarchical references here for verification
    // **DO NOT** use hierarchical references in the actual design!
    assign monitor_valid     = commit;
    assign monitor_order     = order;
    assign monitor_inst      = cpu.if_to_id.ir;
    assign monitor_rs1_addr  = cpu.if_to_id.ir.r_inst.rs1;
    assign monitor_rs2_addr  = cpu.if_to_id.ir.r_inst.rs2;
    assign monitor_rs1_rdata = cpu.id_to_ex.rs1_out;
    assign monitor_rs2_rdata = cpu.id_to_ex.rs2_out;
    assign monitor_rd_addr   = cpu.id_to_ex.rd;
    assign monitor_rd_wdata  = cpu.regfile_in; 
    assign monitor_pc_rdata  = imem_address;
    assign monitor_pc_wdata  = cpu.i_fetch.pcmux_out;
    assign monitor_mem_addr  = dmem_address;
    assign monitor_mem_rmask = cpu.write_back.rmask; // ???
    assign monitor_mem_wmask = dmem_wmask;
    assign monitor_mem_rdata = dmem_rdata;
    assign monitor_mem_wdata = dmem_wdata;
    
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

    always_ff @(posedge clk) begin
        if(rst) begin
            order <= `0;
        end
        if(commit == 1'b1) order <= order + 1;
    end
endmodule : mp4
