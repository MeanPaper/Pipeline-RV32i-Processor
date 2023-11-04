module simple_data_array #(
    parameter s_index = 4,
    parameter s_offset = 5
)(
    input clk0,
    input logic rst0,
    input logic [31:0] wmask0,
    input logic [3:0] addr0,
    input logic [255:0] din0,
    output logic [255:0] dout0
);

    localparam s_mask = 2**s_offset;
    localparam num_sets = 2**s_index;

    logic [255:0] data_line [num_sets] = '{default: '0};

    /****** read *******/
    always_comb begin 
        for (int i = 0 ; i < s_mask ; i++) begin
            if (wmask0[i]) begin
                dout0[8*i +: 8] = din0[8*i +: 8];
            end else begin
                dout0[8*i +: 8] = data_line[addr0][8*i +: 8];
            end
        end
    end

    always_ff @(posedge clk0) begin
        if (rst0) begin
            for (int i = 0 ; i < s_mask ; i++ ) begin
                data_line[i] <= '0;
            end
        end else begin
            for (int i = 0 ; i < s_mask ; i++ ) begin
                if (wmask0[i]) begin
                    data_line[addr0][8*i +: 8] <= din0[8*i +: 8];
                end else begin
                    data_line[addr0][8*i +: 8] <= data_line[addr0][8*i +: 8];
                end
            end
        end
    end

    
endmodule