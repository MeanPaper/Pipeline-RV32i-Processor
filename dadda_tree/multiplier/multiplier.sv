module multiplier
import m_extension::*;
(
    input logic [31:0]  rs1_data,
    input logic [31:0]  rs2_data,
    input m_funct3      funct3,
    // output logic [31:0] mul_out
    output logic [63:0] mul_out
);

logic should_neg;           // determine if one of the rs is negative
logic [63:0] mul_word;      // the multiplication is going to be 64 bits long
logic [63:0] result_word;
logic [31:0] op1, op2;      // for opA and opB 

// two's complement identifying
/* 4 cases
*  a x b = a x b            0
*  a x -b = -(a x b)        1
*  -a x b = -(a x b)        1
*  -a x -b = a x b          0
*/

// identify if the final result should be bit flip
// assign should_neg = rs1_data[31] ^ rs2_data[31];

// 4 case bit flip
always_comb begin
    op1 = rs1_data;
    op2 = rs2_data;
    unique case(funct3)
        mul: begin
        end 
        default: begin
            // happen only in the sign multiplication
            should_neg = rs1_data[31] ^ rs2_data[31]; 
            if(rs1_data[31] == 1'b1) begin  // find the abs of rs1 if rs1 neg
                op1 = (~rs1_data) + 1'b1;
            end 
            if(rs2_data[31] == 1'b1) begin  // find the abs of rs2 if rs2 neg
                op2 = (~rs2_data) + 1'b1;
            end
        end
    endcase
end 

// dadda_tree multiplier 
dadda_tree dadda_tree(
    .opA(op1),
    .opB(op2),
    .prodAB(mul_word)
);

// final output
always_comb begin
    result_word = mul_word;
    if(should_neg == 1'b1) begin
        result_word = (~mul_word) + 1'b1;
    end
end 

assign mul_out = result_word; // final assignment

endmodule


