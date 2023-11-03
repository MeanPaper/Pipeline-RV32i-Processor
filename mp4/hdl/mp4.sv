module mp4
import rv32i_types::*;
(
    input   logic           clk,
    input   logic           rst,

    // Use these for CP1 (magic memory)
    // output  logic   [31:0]  imem_address,
    // output  logic           imem_read,
    // input   logic   [31:0]  imem_rdata,
    // input   logic           imem_resp,
    // output  logic   [31:0]  dmem_address,
    // output  logic           dmem_read,
    // output  logic           dmem_write,
    // output  logic   [3:0]   dmem_wmask,
    // input   logic   [31:0]  dmem_rdata,
    // output  logic   [31:0]  dmem_wdata,
    // input   logic           dmem_resp

    // Use these for CP2+ (with caches and burst memory)
    output  logic   [31:0]  bmem_address,
    output  logic           bmem_read,
    output  logic           bmem_write,
    input   logic   [63:0]  bmem_rdata,
    output  logic   [63:0]  bmem_wdata,
    input   logic           bmem_resp
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
    
    always_ff @(posedge clk) begin
        if(rst) begin
            order <= '0;
        end
        else begin 
            if(commit == 1'b1) order <= order + 1;
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
    

    //connections between cpu and icacheline_adapter & dcacheline_adapter
    logic   [31:0]  imem_address;
    logic           imem_read;
    logic   [31:0]  imem_rdata;
    logic           imem_resp;
    logic   [31:0]  dmem_address;
    logic           dmem_read;
    logic           dmem_write;
    logic   [3:0]   dmem_wmask;
    logic   [31:0]  dmem_rdata;
    logic   [31:0]  dmem_wdata;
    logic           dmem_resp;

    /**** connections between arbiter and icache ****/
    logic           icache_read;
    logic [31:0]    icache_address;
    logic           icache_resp;
    logic [255:0]   icache_rdata;

    /**** connections between arbiter and dcache ****/
    logic           dcache_read;
    logic           dcache_write;
    logic [31:0]    dcache_address;
    logic [255:0]   dcache_wdata;
    logic           dcache_resp;
    logic [255:0]   dcache_rdata;

    //connections between cacheline_adapter and arbiter
    logic           adapter_resp;
    logic   [255:0] adapter_rdata;
    logic           adapter_read;
    logic           adapter_write;
    logic   [31:0]  adapter_address;
    logic   [255:0] adapter_wdata;

    //connections between icache and icache_bus_adapter
    logic [255:0]  imem_wdata256_bus;//it's 0
    logic [255:0]  imem_rdata256_bus;
    logic [31:0]   imem_byte_enable256_bus;//it's 0

    //connections between dcache and dcache_bus_adapter
    logic [255:0]   dmem_wdata256_bus;
    logic [255:0]   dmem_rdata256_bus;
    logic [31:0]    dmem_byte_enable256_bus;

    cpu cpu(
        .clk(clk),
        .rst(rst),
        .imem_address(imem_address),
        .imem_read(imem_read), 
        .imem_rdata(imem_rdata),
        .imem_resp(imem_resp),
        .dmem_address(dmem_address),
        .dmem_read(dmem_read),
        .dmem_write(dmem_write), 
        .dmem_wmask(dmem_wmask),
        .dmem_rdata(dmem_rdata),
        .dmem_wdata(dmem_wdata),
        .dmem_resp(dmem_resp)
    );

    bus_adapter icache_bus_adapter(
        .address(imem_address),
        .mem_wdata256(imem_wdata256_bus),//it's 0
        .mem_rdata256(imem_rdata256_bus),
        .mem_wdata(32'b0),
        .mem_rdata(imem_rdata),
        .mem_byte_enable(4'b0000),
        .mem_byte_enable256(imem_byte_enable256_bus)//it's 0
    );

    bus_adapter dcache_bus_adapter(
        .address(dmem_address),
        .mem_wdata256(dmem_wdata256_bus),
        .mem_rdata256(dmem_rdata256_bus),
        .mem_wdata(dmem_wdata),
        .mem_rdata(dmem_rdata),
        .mem_byte_enable(dmem_wmask),
        .mem_byte_enable256(dmem_byte_enable256_bus)
    );

    icache icache(
        .clk(clk),
        .rst(rst),

        /* icacheline_adapter side signals */
        .mem_address(imem_address),
        .mem_read(imem_read),
        .mem_write(1'b0),
        .mem_byte_enable(imem_byte_enable256_bus),//it's 0
        .mem_rdata(imem_rdata256_bus),
        .mem_wdata(imem_wdata256_bus),//it's 0
        .mem_resp(imem_resp),

        /* Arbiter side signals */
        .pmem_address(icache_address),
        .pmem_read(icache_read),
        //.pmem_write(),
        .pmem_rdata(icache_rdata),
        //.pmem_wdata(),
        .pmem_resp(icache_resp)
    );

    dcache dcache(
        .clk(clk),
        .rst(rst),

        /* CPU side signals */
        .mem_address(dmem_address),
        .mem_read(dmem_read),
        .mem_write(dmem_write),
        .mem_byte_enable(dmem_byte_enable256_bus),
        .mem_rdata(dmem_rdata256_bus),
        .mem_wdata(dmem_wdata256_bus),
        .mem_resp(dmem_resp),

        /* Arbiter side signals */
        .pmem_address(dcache_address),
        .pmem_read(dcache_read),
        .pmem_write(dcache_write),
        .pmem_rdata(dcache_rdata),
        .pmem_wdata(dcache_wdata),
        .pmem_resp(dcache_resp)
    );

    

    arbiter arbiter(
        .clk(clk),
        .rst(rst),

        /**** with ICACHE ****/
        .icache_read(icache_read),
        .icache_address(icache_address),
        .icache_resp(icache_resp),
        .icache_rdata(icache_rdata),

        /**** with DCACHE ****/
        .dcache_read(dcache_read),
        .dcache_write(dcache_write),
        .dcache_address(dcache_address),
        .dcache_wdata(dcache_wdata),
        .dcache_resp(dcache_resp),
        .dcache_rdata(dcache_rdata),

        /**** with cacheline_adapter ****/
        .adapter_resp(adapter_resp),
        .adapter_rdata(adapter_rdata),
        .adapter_read(adapter_read),
        .adapter_write(adapter_write),
        .adapter_address(adapter_address),
        .adapter_wdata(adapter_wdata)
    );



    cacheline_adapter cacheline_adapter(
        .clk(clk),
        .reset_n(!rst),

    // Port to arbiter
        .line_i(adapter_wdata),
        .line_o(adapter_rdata),
        .address_i(adapter_address),
        .read_i(adapter_read),
        .write_i(adapter_write),
        .resp_o(adapter_resp),

    // Port to burst memory
        .burst_i(bmem_rdata),
        .burst_o(bmem_wdata),
        .address_o(bmem_address),
        .read_o(bmem_read),
        .write_o(bmem_write),
        .resp_i(bmem_resp)
    );

    
endmodule : mp4
