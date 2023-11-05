module line_adapter (
  // CPU side
  input logic [31:0] mem_wdata,
  input logic [3:0] mem_byte_enable,
  input logic [31:0] address,
  output logic [31:0] mem_rdata,

  // Cache side
  input logic [255:0] mem_rdata_line,
  output logic [255:0] mem_wdata_line,
  output logic [31:0] mem_byte_enable_line
);

assign mem_wdata_line = {8{mem_wdata}};
assign mem_rdata = mem_rdata_line[(32*address[4:2]) +: 32];
assign mem_byte_enable_line = {28'h0, mem_byte_enable} << (address[4:2]*4);

endmodule : line_adapter
