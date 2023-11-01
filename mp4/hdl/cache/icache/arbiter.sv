module arbiter(
    input clk,
    input rst,

    /**** with ICACHE ****/
    input logic icahce_read,
    input logic [31:0] icahce_address,
    output logic icahce_resp,
    output logic [255:0] icache_rdata,

    /**** with DCACHE ****/
    input logic dcache_read,
    input logic dcache_write,
    input logic [31:0] dcache_address,
    input logic [255:0] dcache_wdata,
    output logic dcache_resp,
    output logic dcache_rdata

    /**** with cacheline_adapter ****/
    input logic adapter_resp,
    input logic [255:0] adapter_rdata,
    output logic adapter_read,
    output logic adapter_write,
    output logic [31:0] adapter_address,
    output logic [255:0] adapter_wdata
);
    /**** three states ****/
    enum int unsigned{
        IDLE, ICACHE, DCACHE
    } state, next_state;

    function void initialization();
        icahce_resp = 1'b0;
        icache_rdata = 256'b0;

        dcache_resp = 1'b0;
        dcache_rdata = 1'b0;

        adapter_read = 1'b0;
        adapter_write = 1'b0;
        adapter_address = 32'b0;
        adapter_wdata = 256'b0;
    endfunction

    function void icache_action();
        icahce_resp = adapter_resp? 1'b1:1'b0;
        icache_rdata = adapter_rdata;
        
        adapter_read = icahce_read;
        adapter_address = icahce_address;
        adapter_write = 1'b0;
        adapter_wdata = 256'b0;
    endfunction

    function void dcache_action();
        dcache_resp = adapter_resp? 1'b1:1'b0;
        dcache_rdata = adapter_rdata;

        adapter_read = dcache_read;
        adapter_address = dcache_address;
        adapter_write = dcache_write;
        adapter_wdata = dcache_wdata;
    endfunction

    /**** state actions ****/
    always_comb begin 
        initialization();
        case (state)
            IDLE: begin
                ;
            end

            ICACHE: begin
                icache_action();
            end

            DCACHE: begin
                dcache_action();
            end
        endcase
    end

    /**** state transition logic ****/
    always_comb begin
       next_state = state;
        case (state)
            IDLE: begin
                if (icahce_read) begin
                    next_state = ICACHE;
                end else if (dcache_read || dcache_write) begin
                    next_state = DCACHE;
                end else begin
                    next_state = IDLE;
                end
            end
            
            ICACHE: begin
                if (adapter_resp) begin
                    next_state = IDLE;
                end else begin
                    next_state = ICACHE;
                end
            end

            DCACHE: begin
                if (adapter_resp) begin
                    next_state = IDLE;
                end else begin
                    next_state = DCACHE;
                end
            end
        endcase
    end

    /**** state update ****/
    always_ff @( posedge clk ) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
endmodule