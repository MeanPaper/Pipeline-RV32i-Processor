// half adder, 1 bit
module HA(  
    input logic A,
    input logic B,
    output logic S,
    output logic c_out
);

assign S = A ^ B;
assign c_out = A & B;

endmodule

// full adder, 1 bit
module FA(
    input logic A,
    input logic B,
    input logic c_in,
    output logic S,
    output logic c_out
);

assign S = A ^ B ^ c_in;
assign c_out = (A & B) | (c_in & (A ^ B));

endmodule