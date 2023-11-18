module dadda_tree_dut_tb
import m_extension::*;
();

    timeunit 1ns;
    timeprecision 1ns;

    bit clk;
    initial clk = 1'b1;
    always #1 clk = ~clk;

    //----------------------------------------------------------------------
    // Waveforms.
    //----------------------------------------------------------------------
    initial begin
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, "+all");
    end
    
    // random class
    class RandData;
        rand bit [31:0] data;
    endclass
    
    // input and output for dut
    logic [31:0] operandA;
    logic [31:0] operandB;
    logic [63:0] productAB;
    m_extension::m_funct3 funct3;
    
    // input and output for solution
    logic [31:0] correct_A;
    logic [31:0] correct_B;
    logic [63:0] correct_ans;

    // // dut initialization
    // dadda_tree dut(
    //     .opA(operandA),
    //     .opB(operandB),
    //     .prodAB(productAB) 
    // );
    multiplier dut(
        .clk(clk),
        .rst(1'b0),
        .rs1_data(operandA),
        .rs2_data(operandB),
        .funct3(funct3),
        .mul_out(productAB)
    );

    RandData rand_A = new;
    RandData rand_B = new;

    int testing_threshold;
    int error_count;
    
    // dadda tree unsigned multiplication
    task unsigned_dadda_tree();
      // testing loop
        for(int i = 0; i < testing_threshold; ++i) begin
            rand_A.randomize();
            rand_B.randomize();

            // correct ans
            correct_A = rand_A.data;
            correct_B = rand_B.data;
            correct_ans = correct_A * correct_B;

            operandA = rand_A.data;
            operandB = rand_B.data;
            repeat (3) @(posedge clk);
            if(productAB !== correct_ans) begin
                $display("%c[0;31m",27); 
                $display("A: 0x%0h", operandA);
                $display("B: 0x%0h", operandB);
                $display("dadda:   0x%0h", productAB);
                $display("correct: 0x%0h\n", correct_ans);
                error_count += 1;
            end
        end
        $write("%c[0m",27);
    endtask

    // logic [31:0] tempA;
    // logic [31:0] tempB;
    task signed_dadda_tree(logic A_const, logic B_const);
        $display("%c[0;31m",27); 
        for(int i = 0; i < testing_threshold; ++i) begin
            rand_A.randomize() with { data[31] == A_const; };
            rand_B.randomize() with { data[31] == B_const; };


            correct_A = rand_A.data;
            correct_B = rand_B.data;
            correct_ans = $signed(correct_A) * $signed(correct_B);

            operandA = rand_A.data;
            operandB = rand_B.data;

            repeat (3) @(posedge clk);
            // | 32'h80000000
            // $display("correct_A: 0x%0h", correct_A);
            // $display("correct_A: %0d", correct_A);

            // $display("correct_A: 0x%0h", $signed(correct_A));
            // $display("correct_A: %0d", $signed(correct_A));

            // $display("correct_B: 0x%0h", correct_B);
            // $display("correct_B: %0d", correct_B);
            
            // $display("correct_B: 0x%0h", $signed(correct_B));
            // $display("correct_B: %0d", $signed(correct_B));
            if(correct_ans !== productAB) begin
                error_count += 1;
                $display("correct_A: 0x%0h", $signed(correct_A));
                $display("correct_B: 0x%0h", $signed(correct_B));

                $display("correct_ans: %0d", correct_ans);
                $display("correct_ans: %0d", $signed(correct_ans));
                $display("dadda_tree: %0d", productAB);
                $display("dadda_tree: %0d", $signed(productAB));
            end 
        end
        $write("%c[0m",27);
    endtask
    
    initial begin
        $display("%c[0;36m", 27);
        $display("Dadda Tree Test Begin");
        
        // reset the inputs of the dadda tree
        testing_threshold = 2 ** 14;
        error_count = 0;
        operandA = '0;
        operandB = '0;
        funct3 = mul;
        @(posedge clk);

        // ********** code start here **********
        unsigned_dadda_tree();

        operandA = '0;
        operandB = '0;
        funct3 = mulh;

        signed_dadda_tree(0,0);
        signed_dadda_tree(1,0);
        signed_dadda_tree(0,1);
        signed_dadda_tree(1,1);

        // color display for pass and failed
        if(error_count === 0) begin
            $display("%c[1;32m",27);
            $display("Pass");
        end
        else begin
            $display("%c[1;31m",27); 
            $display("Error Count: %0d", error_count);
            $display("Fail");
        end 
        // ********** code end here **********
        
        $display("%c[0;36m", 27);
        $display("Dadda Tree Test End\n");
        $write("%c[0m",27);
        $finish;
    end 

endmodule
