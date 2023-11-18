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
logic [63:0] mul_word;
logic [63:0] row_top, row_bot;      // the multiplication is going to be 64 bits long
logic [63:0] result_word;
logic [31:0] op1, op2;      // for opA and opB 

// two's complement identifying
/* 4 cases
*  a x b = a x b            0
*  a x -b = -(a x b)        1
*  -a x b = -(a x b)        1
*  -a x -b = a x b          0
*/

// 4 case bit flip
always_comb begin
    op1 = rs1_data;
    op2 = rs2_data;
    unique case(funct3)
        mul: begin
        end 
        default: begin
            // happen only in the sign multiplication
            should_neg = rs1_data[31] ^ rs2_data[31];   // see if negative should be used

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
    .row_top(row_top),
    .row_bot(row_bot)
);

// need to do some divide and conquer here
logic [31:0] upper_partial_sum;
logic [32:0] lower_partial_sum;   // 33 bits, [32] is the carry bit
logic lower_partial_carry;

// simple version, does not have 2's complement
always_comb begin

    // bottom partial and 
    lower_partial_sum = row_top[31:0] + row_bot[31:0];      // lower half of the product
    lower_partial_carry = lower_partial_sum[32];            // the carry from the lower part 

    upper_partial_sum = row_top[63:32] + row_bot[63:32] + lower_partial_carry;  // upper half of the product adds with partial

    mul_out = {upper_partial_sum, lower_partial_sum[31:0]}; // final result     
end





// final output, this works fine but the critical path will be long
// always_comb begin
//     result_word = row_top + row_bot;
//     mul_word = row_top + row_bot;
//     if(should_neg == 1'b1) begin
//         result_word = (~mul_word) + 1'b1;
//     end
// end 

// assign mul_out = result_word; // final assignment

endmodule


