module cache_datapath 
import my_types::*;         // import my datatypes
#(
            parameter       s_offset = 5,
            parameter       s_index  = 4,
            parameter       s_tag    = 32 - s_offset - s_index,
            parameter       s_mask   = 2**s_offset,
            parameter       s_line   = 8*s_mask,
            parameter       num_sets = 2**s_index
)( 
    input logic clk,
    input logic rst,

    
    input logic [31:0] mem_address,
    input logic [31:0] mem_byte_enable256,
    input cacheline_t  mem_wdata256,
    output cacheline_t mem_rdata256,
    
    input cacheline_t pmem_rdata,
    output cacheline_t pmem_wdata,
    output logic [31:0] pmem_address,

    // to control
    output logic is_hit,
    // output logic is_valid, // valid_bit_output[#ways]
    output logic is_dirty, // dirty_bit_output[#ways]


    // from control
    input logic is_allocate,
    input logic use_replace,    // is_neg
    input logic load_data,
    input logic load_tag,
    input logic load_dirty,
    input logic load_valid,
    input logic load_plru,
    input logic valid_in,
    input logic dirty_in
);


    /*============================== Signals begin ==============================*/
    // for data array and tag array inputs
    // logic   [255:0] data_d      [4];    // data array, wait why?
    // logic   [22:0]  tag_d       [4];    // tag array, wait why?
    // cacheline_t data_d;
    // tag_word_t tag_d;

    cacheline_t data_arr_in;
    tag_word_t  tag_arr_in;  

    // data array and tag array (4 ways)
    cacheline_t  data_arr_out  [4];     // data_out from 4 ways
    tag_word_t   tag_arr_out   [4];     // tag_out from 4 ways
    
    // plru array (one array for 4 way)
    plru_word_t  plru_data_out;
    plru_word_t  new_plru_data;

    // dirty array and valid array (4 ways)
    logic   valid_out   [4];
    logic   dirty_out   [4];

    logic [3:0] hit;            // one hot hit vector
    
    tag_word_t tag_from_addr;   // mem_addr[31:9]
    logic [3:0] set_idx;        // mem_addr[8:5]      

    logic [1:0] hit_way, way_idx, replace_way;
    
    tag_word_t tag_out;         // one of the tags in 4 ways
    cacheline_t data_out;       // one of the data in 4 ways

    logic [31:0] write_mask;    // write mask for cacheline
    tag_word_t final_tag_out;


    // write enable should active low 
    logic [3:0] data_web_arr;   // data_web
    logic [3:0] tag_web_arr;    // tag_web
    logic [3:0] dirty_web_arr;   // chip select for dirty bits
    logic [3:0] valid_web_arr;   // chip select for valid bits
    /*============================== Signals end ==============================*/


    /*============================== Assignments begin ==============================*/
    assign tag_from_addr = mem_address[31:9];
    assign tag_arr_in = mem_address[31:9];
    assign set_idx = mem_address[8:5];
    assign pmem_address = {final_tag_out, mem_address[8:5], 5'b0};
    // assign is_hit = |hit;            // OR all the hit bit to see if a way is hit

    assign mem_rdata256 = data_out;
    assign pmem_wdata = data_out;
    /*============================== Assignments end ==============================*/
    

    /*============================== Modules begin ==============================*/
    // TODO: filling the signals
    // generate 4 data_array
    generate for (genvar i = 0; i < 4; i++) begin : data_arrays
        mp3_data_array data_array (
            .clk0       (clk),
            .csb0       (1'b0),
            .web0       (data_web_arr[i]),
            .wmask0     (write_mask),
            .addr0      (set_idx),
            .din0       (data_arr_in),
            .dout0      (data_arr_out[i])
        );
    end endgenerate

    // TODO: filling the signals
    // generate 4 tag array
    generate for (genvar i = 0; i < 4; i++) begin : tag_arrays
        mp3_tag_array tag_array(
            .clk0    (clk),
            .csb0    (1'b0),
            .web0    (tag_web_arr[i]),
            .addr0   (set_idx),
            .din0    (tag_arr_in),
            .dout0   (tag_arr_out[i])
        );
    end endgenerate

    // TODO: filling the signals
    // generate 4 valid arrays and 4 dirty arrays
    generate for (genvar i = 0; i < 4; i++) begin
        ff_array valid_array (
            .clk0(clk),
            .rst0(rst),
            .csb0(1'b0),
            .web0(valid_web_arr[i]),
            .addr0(set_idx),
            .din0(valid_in),        // data input for all valid array
            .dout0(valid_out[i])    // output
        );
        ff_array dirty_array (  
            .clk0(clk),
            .rst0(rst),
            .csb0(1'b0),
            .web0(dirty_web_arr[i]),
            .addr0(set_idx),
            .din0(dirty_in),        // data input for all dirty array
            .dout0(dirty_out[i])    // output
        );
    end endgenerate

    // create a plru_array with a width of 3 bits
    ff_array #(.width(3)) plru_array(
        .clk0(clk),
        .rst0(rst),
        .csb0(1'b0),                 
        .web0(~load_plru),           // load_plru will output high from the control, so need to invert it   
        .addr0(set_idx),
        .din0(new_plru_data),        // new plru bits 
        .dout0(plru_data_out)        // output
    );
    /*============================== Modules end ==============================*/


    /*======================== load data handling begin ========================*/
    always_comb begin //TODO: double check this
        data_web_arr = 4'hF;
        tag_web_arr = 4'hF;
        valid_web_arr = 4'hF;
        dirty_web_arr = 4'hF;
        
        unique case(use_replace | (~is_hit)) // determine when to use replace index or hit index
            1'b0: way_idx = hit_way;
            1'b1: way_idx = replace_way;
            default: way_idx = hit_way;
        endcase

        if(load_data == 1'b1) begin 
            data_web_arr[way_idx] = 1'b0;
        end

        if(load_tag == 1'b1) begin
            tag_web_arr[way_idx] = 1'b0;
        end

        if(load_dirty == 1'b1) begin    
            dirty_web_arr[way_idx] = 1'b0;
        end 

        if(load_valid == 1'b1) begin
            valid_web_arr[way_idx] = 1'b0;
        end
    end
    /*======================== load data handling end ========================*/

    /*======================== PLRU begin ========================*/
    always_comb begin
        // PLRU traverse and updates, this is happen in HIT_CHECK state
        // when cache miss, it use the slot here to replace the data
        unique case(plru_data_out[0]) // L0
            1'b0: begin
                unique case(plru_data_out[1])   // L1: decision tree
                    1'b0: replace_way = 2'd0;
                    1'b1: replace_way = 2'd1;
                    default: replace_way = 2'd0;
                endcase
            end
            1'b1: begin
                unique case(plru_data_out[2])   // L2: decision tree
                    1'b0: replace_way = 2'd2;
                    1'b1: replace_way = 2'd3;
                    default: replace_way = 2'd2;
                endcase
            end
            default: begin
                unique case(plru_data_out[1])   // L1: decision tree
                    1'b0: replace_way = 2'd0;
                    1'b1: replace_way = 2'd1;
                    default: replace_way = 2'd0;
                endcase
            end
        endcase

        // use by hit_state, used to update PLRUs
        unique case(hit_way[1])
            1'd0: new_plru_data = {plru_data_out[2], ~hit_way[0], 1'b1};
            1'd1: new_plru_data = {~hit_way[0], plru_data_out[1], 1'b0};
            default: new_plru_data = 3'b0;
        endcase

        // select data from replace way (determined by current PLRU)
        // is_valid = valid_out[replace_way];  // extract valid bits
        is_dirty = dirty_out[replace_way];  // extract dirty bits
    end
    /*======================== PLRU end ========================*/

    // 000 --> 1, 011
    // hit 1 x00, x11
    //    L0
    //   /  \
    // L1    L2
    // 12    34

    //TODO: 4-way parallel tag check
    always_comb begin
        is_hit = 1'b0;
        for(int idx = 0; idx < 4; idx++) begin
            hit[idx] = 1'(tag_from_addr == tag_arr_out[idx]) & valid_out[idx];
        end 
        is_hit = |hit;            // OR all the hit bit to see if a way is hit
    end

    // hit_way decoding
    always_comb begin 
        unique case(hit)
            4'b0001: hit_way = 2'd0; // way 0
            4'b0010: hit_way = 2'd1; // way 1
            4'b0100: hit_way = 2'd2; // way 2
            4'b1000: hit_way = 2'd3; // way 3
            default: hit_way = 2'd0;
        endcase
    end 
    
    //TODO: MUXES
    always_comb begin

        // cache selection ord write back data selection  
        unique case(way_idx)
            2'd0: begin
                tag_out = tag_arr_out[0];
                data_out = data_arr_out[0];
            end
            2'd1: begin
                tag_out = tag_arr_out[1];
                data_out = data_arr_out[1];
            end 
            2'd2: begin
                tag_out = tag_arr_out[2];
                data_out = data_arr_out[2];
            end
            2'd3: begin
                tag_out = tag_arr_out[3];
                data_out = data_arr_out[3];
            end
            default: begin
                tag_out = tag_arr_out[0];
                data_out = data_arr_out[0];
            end
        endcase 

        // mem_byte_enable256 base on current situation
        unique case(is_allocate)
            1'b0: begin
                write_mask = mem_byte_enable256; // write mask
                final_tag_out = tag_out;         // normal tag output from tag arrays
                data_arr_in = mem_wdata256;
            end
            1'b1: begin 
                write_mask = 32'hFFFFFFFF;      // write entire cacheline at allocate
                final_tag_out = tag_from_addr; // using the tag out from mem_addr
                data_arr_in = pmem_rdata;
            end
            default: begin
                write_mask = mem_byte_enable256; // write mask
                final_tag_out = tag_out;         // normal tag output from tag arrays
                data_arr_in = mem_wdata256;
            end
        endcase

    end

endmodule : cache_datapath