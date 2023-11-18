// half adder, 1 bit
module HA(  
    input logic A_i,
    input logic B_i,
    output logic S_o,
    output logic c_out
);

assign S = A ^ B;
assign c_out = A & B;

endmodule

// full adder, 1 bit
module FA(
    input logic A_i,
    input logic B_i,
    input logic c_in,
    output logic S_o,
    output logic c_out
);

assign S = A ^ B ^ c_in;
assign c_out = (A & B) | (c_in & (A ^ B));

endmodule