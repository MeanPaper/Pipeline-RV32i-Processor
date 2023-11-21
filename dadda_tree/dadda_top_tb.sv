module dadda_tree_dut_tb
import m_extension::*;
();

    timeunit 1ns;
    timeprecision 1ns;

    bit clk;
    initial clk = 1'b1;
    always #1 clk = ~clk;

    bit rst;
    task reset_all();
        rst = 1'b1;
        repeat (3) @(posedge clk);
        rst = 1'b0;
        @(posedge clk);
    endtask
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
    logic [31:0] productAB;
    m_extension::m_funct3 funct3;
    logic mul_done;
    logic mul_on;

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
        .is_mul(mul_on),
        .mul_done(mul_done),
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

            operandA <= rand_A.data;
            operandB <= rand_B.data;

            @(posedge clk iff mul_done == 1'b1);
            // @(posedge clk);

            if(dut.mul_result !== correct_ans) begin
                $display("A: 0x%0h", operandA);
                $display("B: 0x%0h", operandB);
                $display("dadda:   0x%0h", dut.mul_result);
                $display("correct: 0x%0h\n", correct_ans);
                error_count += 1;
            end
        end
    endtask

    // logic [31:0] tempA;
    // logic [31:0] tempB;
    task signed_dadda_tree(logic A_const, logic B_const);
        $write("%c[0;31m", 27);
        for(int i = 0; i < testing_threshold; ++i) begin
            rand_A.randomize() with { data[31] == A_const; };
            rand_B.randomize() with { data[31] == B_const; };

            correct_A = rand_A.data;
            correct_B = rand_B.data;
            correct_ans = $signed(correct_A) * $signed(correct_B);

            operandA <= rand_A.data;
            operandB <= rand_B.data;

            // repeat (4) @(posedge clk);
            @(posedge clk iff mul_done == 1'b1);
            
            if(correct_ans !== dut.mul_result) begin
                error_count += 1;
                $display("correct_A: 0x%0h", $signed(correct_A));
                $display("correct_B: 0x%0h", $signed(correct_B));
                $display("correct_ans: %0d", correct_ans);
                $display("correct_ans: %0d", $signed(correct_ans));
                $display("dadda_tree: %0d", dut.mul_result);
                $display("dadda_tree: %0d", $signed(dut.mul_result));
            end 
        end
        $write("%c[0m", 27);
    endtask
    
    logic [63:0] temp;
    task mul_opcode_test(m_extension::m_funct3 op);
        funct3 = op; // setting the funct3 signal
        for(int i = 0; i < testing_threshold; ++i) begin
            // rand_A.randomize();
            // rand_B.randomize();
            rand_A.randomize() with { data[31] == 1'b1;};
            rand_B.randomize() with { data[31] == 1'b0;};
            
            correct_A = rand_A.data;
            correct_B = rand_B.data;
            correct_ans = correct_A * correct_B;

            operandA <= rand_A.data;
            operandB <= rand_B.data;
            @(posedge clk iff mul_done == 1'b1);

            if(op == mul) begin
                if(correct_ans[31:0] !== productAB) begin
                    $display("mul not working");
                    $display("correct ans whole: %0h, %0h", correct_ans[63:32], correct_ans[31:0]);
                    $display("correct ans lower 32: %0h", (correct_ans[31:0]));
                    $display("dadda: %0h", (productAB));
                end 
            end 
            if(op == mulh) begin
                correct_ans = $signed(correct_A) * $signed(correct_B);
                if(correct_ans[63:32] !== productAB) begin
                    $display("mulh not working");
                    $display("correct ans whole: %0h, %0h", correct_ans[63:32], correct_ans[31:0]);
                    $display("correct ans upper 32: %0h", (correct_ans[63:32]));
                    $display("dadda: %0h", (productAB));
                end
            end 
            if(op == mulhsu) begin
                correct_ans = $signed(correct_A) * $unsigned(correct_B);
                // $display("A: %0h", $signed(correct_A));
                // $display("B: %0h", $unsigned(correct_B));
                if(correct_ans[63:32] !== productAB) begin
                    $display("mulhsu not working");
                    $display("correct ans whole: %0h, %0h", correct_ans[63:32], correct_ans[31:0]);
                    $display("correct ans upper 32: %0h", (correct_ans[63:32]));
                    $display("dadda: %0h", (productAB));
                    $display("dadda whole: %0h, %0h", dut.mul_result[63:32], dut.mul_result[31:0]);
                    temp = dut.row_top + dut.row_bot;
                    $display("dadda whole no negate: %0h, %0h", temp[63:32], temp[31:0]);

                end
            end
            if(op == mulhu) begin
                correct_ans = $unsigned(correct_A) * $unsigned(correct_B);
                if(correct_ans[63:32] !== productAB) begin
                    $display("mulh not working");
                    $display("correct ans whole: %0h, %0h", correct_ans[63:32], correct_ans[31:0]);
                    $display("correct ans upper 32: %0h", (correct_ans[63:32]));
                    $display("dadda: %0h", (productAB));
                end
            end
        end
    endtask 



    logic [31:0] remainder;
    initial begin
        $display("%c[0;36m", 27);
        $display("Dadda Tree Test Begin");
        reset_all();

        // reset the inputs of the dadda tree
        testing_threshold = 2 ** 10;
        error_count = 0;
        operandA = '0;
        operandB = '0;
        funct3 = mul;
        mul_on = '0;
        @(posedge clk);

        // ********** code start here **********
        $write("%c[0;31m",27);    // color red
        mul_on = 1'b1;

        $display("%c[0mSimple unsigned test begin", 27);
        $write("%c[0;31m", 27);
        unsigned_dadda_tree();
        $display("%c[0mSimple unsigned test end\n", 27);

        funct3 = mulh;
        $display("unsigned x unsigned begin");
        signed_dadda_tree(0,0);
        $display("unsigned x unsigned end\n");

        $display("signed x unsigned begin");
        signed_dadda_tree(1,0);
        $display("signed x unsigned end\n");

        $display("unsigned x signed begin");
        signed_dadda_tree(0,1);
        $display("unsigned x signed end\n");

        $display("signed x signed begin");
        signed_dadda_tree(1,1);
        $display("signed x signed end");


        mul_opcode_test(mul);
        mul_opcode_test(mulh);
        mul_opcode_test(mulhsu);
        mul_opcode_test(mulhu);

        // strange operation
        // correct_ans = $signed(-1)*$unsigned(-1);
        // $display("%0h", correct_ans);
        // $display("%0h %0h", correct_ans[63:32], correct_ans[31:0]);

        remainder = $signed(4) % $signed(-6);
        $display("remainder is: %0d, 0x%0h", remainder, remainder);

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
