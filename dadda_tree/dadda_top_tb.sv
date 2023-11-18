import m_extension::*;
module dadda_tree_dut_tb;

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
    
    // input and output for solution
    logic [63:0] correct_A;
    logic [63:0] correct_B;
    logic [63:0] correct_ans;

    // // dut initialization
    // dadda_tree dut(
    //     .opA(operandA),
    //     .opB(operandB),
    //     .prodAB(productAB) 
    // );
    multiplier dut(
        .rs1_data(operandA),
        .rs2_data(operandB),
        .funct3(m_extension::mul),
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
            correct_A = {32'b0, rand_A.data};
            correct_B = {32'b0, rand_B.data};
            correct_ans = correct_A * correct_B;

            operandA = rand_A.data;
            operandB = rand_B.data;
            @(posedge clk);
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

    initial begin
        $display("%c[0;36m", 27);
        $display("Dadda Tree Test Begin");
        
        // reset the inputs of the dadda tree
        testing_threshold = 2 ** 14;
        error_count = 0;
        operandA = '0;
        operandB = '0;
        @(posedge clk);


        // ********** code start here **********
        // rand_A.randomize();
        // rand_B.randomize();
        // correct_A = {32'b0, rand_A.data};
        // correct_B = {32'b0, rand_B.data};
        // correct_ans = correct_A * correct_B;
        // @(posedge clk);
        
        // inject data to the dut
        // operandA = rand_A.data;
        // operandB = rand_B.data;
        // repeat(2) @(posedge clk);

        unsigned_dadda_tree();

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
