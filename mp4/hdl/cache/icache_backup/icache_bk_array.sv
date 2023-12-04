module icache_bk_array
#(  
    parameter datawidth = 1
)(
  input logic clk,
  input logic rst,
  input logic load,
  input logic [2:0] index,
  input logic [datawidth-1:0] datain,
  output logic [datawidth-1:0] dataout
);

logic [datawidth-1:0] data [8] = '{8{'0}};

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
        if(load) begin
            data[index] <= datain;
        end
    end
end 




endmodule