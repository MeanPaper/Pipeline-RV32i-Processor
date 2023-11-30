module flipflop #(
            parameter               width = 32
)(
    input                           clk,
    input                           rst,
    input                           load,
    input           [width-1:0]     din,
    output  logic   [width-1:0]     dout
);

    logic [width-1:0] data;

    always_ff @(posedge clk) begin
        if (rst) begin
            data <= '0;
        end else if (load) begin
            data <= din;
        end else begin
            data <= data;
        end
    end

    always_comb
    begin
        dout = data;
    end

endmodule : flipflop


module prefetcher (
    input   logic           clk,
    input   logic           rst,

    /* l1 cache signals */
    input   logic           l1_mem_read,
    output  logic           l1_mem_resp,
    input   logic   [31:0]  l1_mem_address,

    /* l2 cache signals */
    output  logic           pmem_read,
    input   logic           pmem_resp,
    output  logic   [31:0]  pmem_address   
);

    enum int unsigned{
        IDLE,
        PREFETCH
    } state, next_state;

    logic [31:0] prefetch_mem_address;
    logic load;
    assign load = (l1_mem_read && state == IDLE);

    flipflop preftech_address (
        .clk(clk),
        .rst(rst),
        .load(load),
        .din(l1_mem_address + 32'd32),
        .dout(prefetch_mem_address)
    );

    /* state_actions */
    always_comb begin
        /* Defaults */
        pmem_read = l1_mem_read;
        pmem_address = l1_mem_address;
        l1_mem_resp = pmem_resp;

        case(state)
            IDLE: begin
                pmem_read =  l1_mem_read;
                pmem_address = l1_mem_address;
                l1_mem_resp = pmem_resp;  
            end
            PREFETCH: begin
                pmem_read = 1'b1;
                pmem_address = prefetch_mem_address;
                l1_mem_resp = 1'b0;
            end
        endcase
    end

    /* Next State Logic */
    always_comb begin

        next_state = state;

        case(state)
            IDLE: begin
                if (l1_mem_read && pmem_resp) begin
                    next_state = PREFETCH;
                end 
                // if (l1_mem_read) begin
                //     next_state = PREFETCH;
                // end 
            end
            PREFETCH: begin
                if (pmem_resp) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    /* Next State Assignment */
    always_ff @(posedge clk) begin 
        if (rst) state <= IDLE;

        else state <= next_state;
    end

endmodule: prefetcher
