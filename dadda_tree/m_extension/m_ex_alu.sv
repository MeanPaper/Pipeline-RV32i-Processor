module m_extension_alu
import m_extension::*;
(
    input logic clk,
    input logic rst,
    
    // data input and opcode (operation)
    input logic [31:0]  rs1_data_i,
    input logic [31:0]  rs2_data_i,
    input m_funct3      funct3,
 
    // results
    output logic [31:0] rd_data_o
);


logic is_mul, mul_done;
logic [31:0] mul_out;

assign is_mul = (funct3[2] == '0);
multiplier multiplier
(   
    // input
    .clk(clk),
    .rst(rst),
    .rs1_data(rs1_data_i),
    .rs2_data(rs2_data_i),
    .funct3(funct3),
    .is_mul(is_mul),

    // output
    .mul_done(mul_done),
    .mul_out(mul_out)
);




endmodule;