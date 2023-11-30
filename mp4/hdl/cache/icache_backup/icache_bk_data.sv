module icache_bk_data_array
(
    input   logic           clk,
    input   logic           rst,
    input   logic           web,
    input   logic [2:0]     index,
    input   logic [255:0]   datain,
    output  logic [255:0]   dataout
);

logic [255:0] data[8]; 
// = '{8{'0}}; 

always_comb begin
    dataout = data[index];
end 

always_ff @(posedge clk) begin
    if(rst) begin
        for(int i = 0; i < 8; ++i) begin
            data[i] <= '0;
        end 
    end
    else begin
        if(web) begin
            data[index] <= datain;
        end
    end
end


endmodule