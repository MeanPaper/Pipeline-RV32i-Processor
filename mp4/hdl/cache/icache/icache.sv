module icache(
    input clk,
    input rst,

    /* CPU side signals */
    input   logic   [31:0]  mem_address,
    input   logic           mem_read,
    input   logic           mem_write,
    input   logic   [31:0]  mem_byte_enable,
    output  logic   [255:0] mem_rdata,
    input   logic   [255:0] mem_wdata,
    output  logic           mem_resp,

    /* Memory side signals */
    output  logic   [31:0]  pmem_address,
    output  logic           pmem_read,
    output  logic           pmem_write,
    input   logic   [255:0] pmem_rdata,
    output  logic   [255:0] pmem_wdata,
    input   logic           pmem_resp
);
    /***** signals between datapath and control *****/
    logic tag_web;
    logic valid_web;
    logic dirty_web;
    logic dirty_in;
    logic dirty_out;
    logic hit_signal;
    logic [1:0] w_mask;  

    /***** signals between bus_adapter and CPU *****/
    // logic [255:0] mem_wdata_cpu_to_bus;
    // logic [255:0] mem_rdata_bus_to_cpu;
    // logic [31:0] mem_byte_enable_cpu_to_bus;

simple_cache_control control(
    .*
);

simple_cache_datapath datapath(
    .*
);

//may connect bus_adapter in the top level
// bus_adapter bus_adapter(
//     .address(mem_address),
//     .mem_wdata256(mem_wdata),
//     .mem_rdata256(mem_rdata),
//     .mem_wdata(mem_wdata_cpu_to_bus),
//     .mem_rdata(mem_rdata_bus_to_cpu),
//     .mem_byte_enable(mem_byte_enable),
//     .mem_byte_enable256(mem_byte_enable_cpu_to_bus)
// );

endmodule