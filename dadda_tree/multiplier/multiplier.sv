module multiplier
import m_extension::*;
(   
    input logic         clk,
    input logic         rst,
    input logic [31:0]  rs1_data,
    input logic [31:0]  rs2_data,
    input m_funct3      funct3,
    // output logic [31:0] mul_out
    output logic [63:0] mul_out
);

logic should_neg;                   // determine if one of the rs is negative

logic [63:0] dadda_top_o, dadda_bot_o;
logic [31:0] rs1_data_tmp, rs2_data_tmp;

logic [63:0] row_top, row_bot;      // the multiplication is going to be 64 bits long
logic [31:0] op1, op2;              // for opA and opB 
logic [31:0] op1_reg, op2_reg;

// need to do some divide and conquer here
logic [31:0] upper_partial_sum;
logic [32:0] lower_partial_sum;   // 33 bits, [32] is the carry bit
logic lower_partial_carry;

logic [31:0] lower_reg, upper_reg;
// two's complement identifying
/* 4 cases
*  a x b = a x b            0
*  a x -b = -(a x b)        1
*  -a x b = -(a x b)        1
*  -a x -b = a x b          0
*/

// 4 case bit flip
always_comb begin
    op1 = rs1_data_tmp;
    op2 = rs2_data_tmp;
    should_neg = '0;
    unique case(funct3)
        mul: begin
        end 
        default: begin
            // happen only in the sign multiplication
            should_neg = rs1_data_tmp[31] ^ rs2_data_tmp[31];   // see if negative should be used

            if(rs1_data_tmp[31] == 1'b1) begin  // find the abs of rs1 if rs1 neg
                op1 = (~rs1_data_tmp) + 1'b1;
            end 

            if(rs2_data_tmp[31] == 1'b1) begin  // find the abs of rs2 if rs2 neg
                op2 = (~rs2_data_tmp) + 1'b1;
            end
        end
    endcase
end 


// dadda_tree multiplier 
dadda_tree dadda_tree(
    .opA(op1_reg),
    .opB(op2_reg),
    .row_top(dadda_top_o),
    .row_bot(dadda_bot_o)
);

always_ff @(posedge clk) begin
    if(rst) begin    
        row_top <= '0;
        row_bot <= '0;
        rs1_data_tmp <= '0;
        rs2_data_tmp <= '0;
        op1_reg <= '0;
        op2_reg <= '0;
    end
    else begin
        
        // latch the data coming from dadda tree
        rs1_data_tmp <= rs1_data;
        rs2_data_tmp <= rs2_data;
        row_top <= dadda_top_o;
        row_bot <= dadda_bot_o;
        op1_reg <= op1;
        op2_reg <= op2;
    end
end

// simple version, does not have 2's complement
always_comb begin

    // bottom partial and 
    // lower_partial_sum = {1'b0, row_top[31:0]} + {1'b0, row_bot[31:0]};          // lower half of the product
    // lower_partial_carry = lower_partial_sum[32];                                // the carry from the lower part 
    // upper_partial_sum = row_top[63:32] + row_bot[63:32] + lower_partial_carry;  // upper half of the product adds with partial

    // if(should_neg) begin
    //     lower_partial_sum = {1'b0, ~row_top[31:0]} + {1'b0, ~row_bot[31:0]} + should_neg + 1'b1;         // negation, one complement + 1
    //     lower_partial_carry = lower_partial_sum[32];                                        // the carry from the lower part 
    //     upper_partial_sum = (~row_top[63:32]) + (~row_bot[63:32]) + lower_partial_carry;    // upper half of the product adds with partial
    // end 

   
    mul_out = row_top + row_bot;
    if(should_neg) begin
        mul_out = ~(row_top + row_bot) + 1'b1;
    end
end

endmodule

// Area: 9368.253932
