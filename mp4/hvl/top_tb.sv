import "DPI-C" function string getenv(input string env_name);

module top_tb;

    timeunit 1ps;
    timeprecision 1ps;

    int clock_period_ps = getenv("CLOCK_PERIOD_PS").atoi() / 2;

    bit clk;
    initial clk = 1'b1;
    always #(clock_period_ps) clk = ~clk;

    bit rst;

    int timeout = 10000000; // in cycles, change according to your needs

    logic [63:0] dmem_stall_count;
    logic [63:0] imem_stall_count;

    // CP1
    // mem_itf magic_itf_i(.*);
    // mem_itf magic_itf_d(.*);
    // magic_dual_port magic_dual_port(.itf_i(magic_itf_i), .itf_d(magic_itf_d));

    // CP2
    bmem_itf bmem_itf(.*);
    burst_memory burst_memory(.itf(bmem_itf));

    mon_itf mon_itf(.*);    
    monitor monitor(.itf(mon_itf));

    mp4 dut(
        .clk          (clk),
        .rst          (rst),

        // Use these for CP1
        // .imem_address  (magic_itf_i.addr),
        // .imem_read     (magic_itf_i.read),
        // .imem_rdata    (magic_itf_i.rdata),
        // .imem_resp     (magic_itf_i.resp),
        // .dmem_address  (magic_itf_d.addr),
        // .dmem_read     (magic_itf_d.read),
        // .dmem_write    (magic_itf_d.write),
        // .dmem_wmask    (magic_itf_d.wmask),
        // .dmem_rdata    (magic_itf_d.rdata),
        // .dmem_wdata    (magic_itf_d.wdata),
        // .dmem_resp     (magic_itf_d.resp)

        // Use these for CP2+
        .bmem_address (bmem_itf.addr),
        .bmem_read    (bmem_itf.read),
        .bmem_write   (bmem_itf.write),
        .bmem_rdata   (bmem_itf.rdata),
        .bmem_wdata   (bmem_itf.wdata),
        .bmem_resp    (bmem_itf.resp)
    );

    always_comb begin
        mon_itf.valid     = dut.monitor_valid;
        mon_itf.order     = dut.monitor_order;
        mon_itf.inst      = dut.monitor_inst;
        mon_itf.rs1_addr  = dut.monitor_rs1_addr;
        mon_itf.rs2_addr  = dut.monitor_rs2_addr;
        mon_itf.rs1_rdata = dut.monitor_rs1_rdata;
        mon_itf.rs2_rdata = dut.monitor_rs2_rdata;
        mon_itf.rd_addr   = dut.monitor_rd_addr;
        mon_itf.rd_wdata  = dut.monitor_rd_wdata;
        mon_itf.pc_rdata  = dut.monitor_pc_rdata;
        mon_itf.pc_wdata  = dut.monitor_pc_wdata;
        mon_itf.mem_addr  = dut.monitor_mem_addr;
        mon_itf.mem_rmask = dut.monitor_mem_rmask;
        mon_itf.mem_wmask = dut.monitor_mem_wmask;
        mon_itf.mem_rdata = dut.monitor_mem_rdata;
        mon_itf.mem_wdata = dut.monitor_mem_wdata;
    end

    initial begin
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, "+all");
        rst = 1'b1;
        repeat (2) @(posedge clk);
        rst <= 1'b0;
    end

    final begin
        // $display("%c[1;34m",27);
        $display("\n============= Memory Stalls =============");
        $display("imem stall total cycle: %0d", imem_stall_count);
        $display("dmem stall total cycle: %0d\n", dmem_stall_count);
        // $write("%c[0m",27);
    end

    always @(posedge clk) begin
        if (mon_itf.halt) begin
            $finish;
        end
        if (timeout == 0) begin
            $error("TB Error: Timed out");
            $finish;
        end
        if (mon_itf.error != 0) begin
            repeat (5) @(posedge clk);
            $finish;
        end
        // Comment this for CP2+
        // if (magic_itf_i.error != 0 || magic_itf_d.error != 0) begin
        //     repeat (5) @(posedge clk);
        //     $finish;
        // end
        // Uncomment this for CP2+
        if (bmem_itf.error != 0) begin
            repeat (5) @(posedge clk);
            $finish;
        end
        timeout <= timeout - 1;
    end

    // keep track of stalling ??
    always_ff @(posedge clk) begin
        if(rst) begin
            dmem_stall_count <= '0;
            imem_stall_count <= '0;
        end
        else begin
            if(dut.cpu.imem_stall == 1'b1) begin
                imem_stall_count <= imem_stall_count + 1'b1;
            end 
                
            if(dut.cpu.dmem_stall == 1'b1) begin
                dmem_stall_count <= dmem_stall_count + 1'b1;
            end
        end
    end

endmodule
