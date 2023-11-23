module multiplier
import rv32i_types::*;
(   
    input logic         clk,
    input logic         rst,
    input logic [31:0]  rs1_data,   // in mulsu, this is signed
    input logic [31:0]  rs2_data,   // in mulsu, this is unsigned
    input m_funct3_t    funct3,
    input logic         is_mul,
    output logic        mul_done,
    output logic [31:0] mul_out
);


logic [31:0] upper_partial_sum;
logic [32:0] lower_partial_sum;   // 33 bits, [32] is the carry bit
logic [31:0] lower_reg, upper_reg;

logic should_neg;                   // determine if one of the rs is negative
logic [63:0] dadda_top_o, dadda_bot_o;
logic [31:0] rs1_data_tmp, rs2_data_tmp;
logic [63:0] row_top, row_bot;      // the multiplication is going to be 64 bits long
logic [31:0] op1, op2;              // for opA and opB 
logic [31:0] op1_reg, op2_reg;
logic lower_partial_carry;
logic [63:0] mul_result;

// logic [63:0] 
// logic [31:0] low_half_reg, upper_half_reg;

// logic should_load, should_prop;
logic [2:0] mul_cycle, next_cycle;

// two's complement identifying
/* 4 cases
*  a x b = a x b            0
*  a x -b = -(a x b)        1
*  -a x b = -(a x b)        1
*  -a x -b = a x b          0
*/

// 4 case bit flip
always_comb begin : mult_pre_process
    op1 = rs1_data_tmp;
    op2 = rs2_data_tmp;
    should_neg = '0;
    case(funct3)
        mul, mulhu: begin // weird behavior
        end 
        mulhsu: begin
            should_neg = rs1_data_tmp[31];
            if(rs1_data_tmp[31]) begin
                op1 = (~rs1_data_tmp) + 1'b1;
            end
        end
        default: begin // mul might belong here, but we will see
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

always_ff @(posedge clk) begin : mult_flip_flops
    if(rst) begin    
        row_top <= '0;
        row_bot <= '0;

        // we can unflop rs1 and rs2 data to make the slack less negative
        rs1_data_tmp <= rs1_data;
        rs2_data_tmp <= rs2_data;
        
        op1_reg <= '0;
        op2_reg <= '0;
        
        lower_reg <= '0;
        upper_reg <= '0;
    end
    else begin
        // only allow data to float only if is_mul is trigger
        rs1_data_tmp <= rs1_data;
        rs2_data_tmp <= rs2_data;
        op1_reg <= op1;
        op2_reg <= op2;
        row_top <= dadda_top_o;
        row_bot <= dadda_bot_o;
        
        lower_reg <= lower_partial_sum[31:0];
        upper_reg <= upper_partial_sum;
    end
end

// a simple state machine start
always_comb begin : mult_cycle_counter
    // mul_done = mul_cycle[2];
    mul_done = (mul_cycle == 3'b101);
    next_cycle = mul_cycle + 1'b1;
    // if(mul_cycle[2]) begin
    if(mul_cycle == 3'b101) begin
        next_cycle = '0;
    end
end

always_ff @(posedge clk) begin
    if(rst | (~is_mul)) begin
        mul_cycle <= '0;
    end
    else begin
        mul_cycle <= next_cycle;
    end 
end

// a simple state machine end

always_comb begin : final_compute

    lower_partial_sum = {1'b0, row_top[31:0]} + {1'b0, row_bot[31:0]};          // lower half of the product
    lower_partial_carry = lower_partial_sum[32];                                // the carry from the lower part 
    upper_partial_sum = row_top[63:32] + row_bot[63:32];

    // lower_partial_carry;  // upper half of the product adds with partial
    if(should_neg) begin
        lower_partial_sum = {1'b0, ~row_top[31:0]} + {1'b0, ~row_bot[31:0]} + 1'b1 + 1'b1;      // negation, one complement + 1
        lower_partial_carry = lower_partial_sum[32];                                            // the carry from the lower part 
        upper_partial_sum = (~row_top[63:32]) + (~row_bot[63:32]);
    end 

    mul_result = {upper_reg + lower_partial_carry, lower_reg};

    case(funct3)
        mulh, mulhu, mulhsu: begin  // get 32 higher bits 
            mul_out = mul_result[63:32];
        end                 
        default: begin              // get 32 lower bits operation
            mul_out = mul_result[31:0];
        end
    endcase

end

endmodule



