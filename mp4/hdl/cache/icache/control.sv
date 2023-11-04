module simple_cache_control(
    input clk,
    input rst,

    /******* with CPU ********/
    input logic mem_read,
    input logic mem_write,
    output logic mem_resp,

    /******* with MEM ********/
    input logic pmem_resp,
    output logic pmem_read,
    output logic pmem_write,

    /****** with datapath *****/
    output logic tag_web,
    output logic valid_web,
    output logic dirty_web,
    output logic dirty_in,
    input logic dirty_out,

    input logic hit_signal,
    output logic [1:0] w_mask
);

/**** 1 cycle hit, two states *****/
enum int unsigned{
    COMPARE_TAG, READ_MEMORY
} state, next_state;

logic read_write;
assign read_write = mem_read || mem_write;

/***** intitialization *******/
function void initialization();
    mem_resp = 1'b0;
    pmem_write = 1'b0;
    pmem_read = 1'b0;
    tag_web = 1'b1; //active low
    valid_web = 1'b1; //active low
    dirty_web = 1'b1; //active low
    dirty_in = 1'b0;
    w_mask = 2'b11;
endfunction


always_comb begin
    initialization();
    case (state)
        COMPARE_TAG: begin
            if (read_write) begin
                mem_resp = hit_signal;
                dirty_web = !(hit_signal && mem_write);
                dirty_in = hit_signal && mem_write;
                w_mask = (hit_signal && mem_write)? 2'b01 : 2'b00;
                pmem_write  = (!hit_signal) && dirty_out;
            end else begin
                ;
            end
        end

        READ_MEMORY: begin
            pmem_read = 1'b1;
            w_mask = 2'b00;
            dirty_web = 1'b0;
            dirty_in = 1'b0;
            tag_web = !pmem_resp;
            valid_web = !pmem_resp;
        end
    endcase
end

/********* state transition ********/
always_comb begin
    next_state = state;
   case (state)
    COMPARE_TAG:begin
        if (read_write && (!hit_signal) && (dirty_out)) begin
            next_state = READ_MEMORY;
        end
        else begin
            ;
        end
    end 

    READ_MEMORY: begin
        if (pmem_resp) begin
            next_state = COMPARE_TAG;
        end
        else begin
            ;
        end
    end
   endcase 
end

always_ff @(posedge clk) begin
    if(rst) begin
        state <= COMPARE_TAG;
    end
    else begin
        state <= next_state;
    end
end
endmodule