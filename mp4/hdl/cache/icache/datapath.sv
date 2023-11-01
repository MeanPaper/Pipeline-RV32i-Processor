module simple_cache_datapath #(
    parameter s_offset = 5,
    parameter s_index = 4,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)(
    input clk,
    input rst,

    /****** with CPU ********/
    input logic [255:0] mem_wdata,
    input logic [31:0] mem_address,
    input logic [31:0] mem_byte_enable,
    output logic [255:0] mem_rdata,

    /****** with MEM *******/
    input logic [255:0] pmem_rdata,
    output logic [255:0] pmem_wdata,
    output logic [31:0] pmem_address,

    /******* with control ******/
    input logic [1:0] w_mask,
    input logic tag_web,
    input logic valid_web,
    input logic dirty_in,
    input logic dirty_web,
    output logic dirty_out,
    output logic hit_signal
);
    
    logic [s_tag-1:0] tag_out;
    logic valid_out;
    logic [s_mask-1:0] write_mask;
    logic [s_line-1:0] data_in;
    logic [s_line-1:0] data_out;

    /******* data array *****/
    simple_data_array data_array(
        .clk0(clk),
        .rst0(rst),
        .wmask0(write_mask),
        .addr0(mem_address[8:5]),
        .din0(data_in),
        .dout0(data_out)
    );
    
    /****** tag array *******/
    ff_array #(s_index, s_tag)
        tag_array(
            .clk0(clk),
            .rst0 (rst),
            .csb0 (1'b0),
            .web0 (tag_web),
            .addr0 (mem_address[8:5]),
            .din0 (mem_address[31:9]),
            .dout0 (tag_out)
        );


    /***** valid array ******/
    ff_array valid_array(
        .clk0(clk),
        .rst0 (rst),
        .csb0 (1'b0),
        .web0 (valid_web),
        .addr0 (mem_address[8:5]),
        .din0 (1'b1),
        .dout0 (valid_out)
    );


    /****** dirty_array *****/
    ff_array dirty_array(
            .clk0 (clk),
            .rst0 (rst),
            .csb0 (1'b0),
            .web0 (dirty_web),
            .addr0 (mem_address[8:5]),
            .din0 (dirty_in),
            .dout0 (dirty_out)
        );

    always_comb begin
        hit_signal = (tag_out == mem_address[31:9]) && valid_out;
        if (dirty_out) begin
            pmem_address = {tag_out, mem_address[8:0]};
        end else begin
            pmem_address = mem_address;
        end
        mem_rdata = data_out;
        pmem_wdata = data_out;

        if (w_mask = 2'b00) begin
            write_mask = {32{1'b1}};
            data_in = pmem_rdata;
        end else if (w_mask = 2'b01) begin
            write_mask = mem_byte_enable;
            data_in = mem_wdata;
        end else begin
            write_mask = 32'b0;
            data_in = mem_wdata;
        end
    end

endmodule