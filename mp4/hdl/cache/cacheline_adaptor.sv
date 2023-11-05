module cacheline_adaptor
(
    input clk,
    input reset_n,

    // Port to LLC (Lowest Level Cache)
    input logic [255:0] line_i,
    output logic [255:0] line_o,
    input logic [31:0] address_i,
    input read_i,
    input write_i,
    output logic resp_o,

    // Port to memory
    input logic [63:0] burst_i,
    output logic [63:0] burst_o,
    output logic [31:0] address_o,
    output logic read_o,
    output logic write_o,
    input resp_i
);

    parameter S0 = 3'b000,
              S1 = 3'b001,
              S2 = 3'b010,
              S3 = 3'b011,
              S4 = 3'b100,
              S5 = 3'b101;

    logic [2:0] state, next_state;
    logic [1:0] counter;
    logic [255:0] line_temp;
    logic [31:0] address_temp;
      
    always_ff @(posedge clk) begin
        if (~reset_n) begin
            state <= S0;
        end else begin
                case (state)
                S0: begin
                        address_temp <= address_i;
                        counter <= '0;
                        if (read_i) begin
                                state <= S1;
                        end else if (write_i) begin
                                state <= S2;
                                line_temp <= line_i;
                        end else begin
                                ;
                        end
                end
    
                S1: begin
                    if (resp_i) begin
                        state <= S3;
                        counter <= 2'b01;
                        line_temp[63:0] <= burst_i;
                    end else begin
                        ;
                    end
                end
    
                S2: begin
                    if (resp_i) begin
                        state <= S4;
                        counter <= 2'b01;
                    end else begin
                        ;
                    end
                end
    
                S3: begin
                    if (counter == 2'b11) begin
                        state <= S5;
                    end else begin
                        ;
                    end
                    
                        case(counter)
                                2'b00: line_temp[63:0] <= burst_i;
                                2'b01: line_temp[127:64] <= burst_i;
                                2'b10: line_temp[191:128] <= burst_i;
                                2'b11: line_temp[255:192] <= burst_i;
                                default: line_temp <= '0;  
                        endcase
                    counter <= counter + 2'b1;
                end
                
                S4: begin
                    if (counter == 2'b11) begin
                            state <= S5;
                    end else begin
                        ;
                    end
                    
                    counter <= counter + 2'b1;
                end
    
                S5: begin
                        state <= S0;
                end 
                default: ; 
            endcase
        end
    end

    always_comb begin
        line_o = line_temp;
        address_o = address_temp;
        case (state)
                S1: begin
                    read_o = 1'b1;
                    write_o = 1'b0;
                    resp_o = 1'b0;
                end
                S2: begin
                    read_o = 1'b0;
                    write_o = 1'b1;
                    resp_o = 1'b0;
                end
                S4: begin
                    read_o = 1'b0;
                    write_o = 1'b1;
                    resp_o = 1'b0;
                end
                S3: begin
                    read_o = 1'b1;
                    write_o = 1'b0;
                    resp_o = 1'b0;
                end
                S5: begin
                    read_o = 1'b0;
                    write_o = 1'b0;
                    resp_o = 1'b1;
                end
                default: begin
                        read_o = 1'b0;
                        write_o = 1'b0;
                        resp_o = 1'b0;
                end
        endcase

        case(counter)
                2'b00: burst_o = line_temp[63:0];
                2'b01: burst_o = line_temp[127:64];
                2'b10: burst_o = line_temp[191:128];
                2'b11: burst_o = line_temp[255:192];
        default: burst_o = '0; 
        endcase

end
endmodule : cacheline_adaptor