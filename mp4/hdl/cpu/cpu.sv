module cpu
import rv32i_types::*;
(
    input   logic           clk,
    input   logic           rst,

    // Use these for CP1 (magic memory)
    output  logic   [31:0]  imem_address,
    output  logic           imem_read, //need double check
    input   logic   [31:0]  imem_rdata,
    input   logic           imem_resp, //tbd
    output  logic   [31:0]  dmem_address,
    output  logic           dmem_read,
    output  logic           dmem_write, 
    output  logic   [3:0]   dmem_wmask,
    input   logic   [31:0]  dmem_rdata,
    output  logic   [31:0]  dmem_wdata,
    input   logic           dmem_resp //tbd
);

/**************************** Control Signals ********************************/
pcmux::pcmux_sel_t pcmux_sel;
alumux::alumux1_sel_t alumux1_sel;
alumux::alumux2_sel_t alumux2_sel;
regfilemux::regfilemux_sel_t regfilemux_sel;
marmux::marmux_sel_t marmux_sel;
cmpmux::cmpmux_sel_t cmpmux_sel;
/***************************** Pipeline register next input ******************************/
IF_ID_stage_t if_to_id_next;
ID_EX_stage_t id_to_ex_next;
EX_MEM_stage_t ex_to_mem_next;
MEM_WB_stage_t mem_to_wb_next;
/***************************** Pipeline register ******************************/
IF_ID_stage_t if_to_id;
ID_EX_stage_t id_to_ex;
EX_MEM_stage_t ex_to_mem;
MEM_WB_stage_t mem_to_wb;
/****************************** Load Signals  ********************************/
logic load_pc;
logic load_mdr; 
logic load_regfile;
rv32i_word regfile_in;

logic ex_to_mem_load_regfile;
logic mem_to_wb_load_regfile;

assign ex_to_mem_load_regfile = ex_to_mem.ctrl_wd.wb_ctrlwd.load_regfile;
assign mem_to_wb_load_regfile = mem_to_wb.ctrl_wd.wb_ctrlwd.load_regfile;

// intermediate register, use to sync with dmem, use in mem stage
// MEM_WB_stage_t mem_mid_reg;

// assign load_pc = 1'b1; //For CP1
assign load_mdr = 1'b1; // For CP1
/******************************* IF stage ************************************/
i_fetch i_fetch(
    /* inputs */
    .clk(clk),
    .rst(rst),
    .alu_out(mem_to_wb.alu_out),
    .pcmux_sel(pcmux_sel),
    .load_pc(load_pc),//hardcode to 1 for CP1

    /* outputs to IF/ID buffer */
    .if_output(if_to_id_next),

    /* outputs to Magic Memory */
    .imem_resp(imem_resp),
    .imem_address(imem_address),
    .imem_read(imem_read) //hardcode to 1 for CP1
    // .imem_resp(imem_resp)//tbd, from control_wd
);

/******************************* ID stage ************************************/
i_decode i_decode(
    /* inputs */
    .clk(clk),
    .rst(rst),
    .id_in(if_to_id),
    .regfile_in(regfile_in),
    .rd(mem_to_wb.rd),
    .load_regfile(load_regfile),
    //.regfilemux_sel(mem_to_wb.ctrl_wd.wb_ctrlwd.regfilemux_sel), 

    /* outputs to ID/EX buffer*/
    .id_out(id_to_ex_next)
);

/******************************* EXE stage ***********************************/
execute execute(
    /* input signals from ID/EX buffer */
    .ex_in(id_to_ex),
    
    .ex_to_mem_rd(ex_to_mem.rd),
    .mem_to_wb_rd(mem_to_wb.rd),
    .ex_to_mem_load_regfile(ex_to_mem_load_regfile),
    .mem_to_wb_load_regfile(mem_to_wb_load_regfile),
    .mem_to_wb_rd_data(regfile_in),
    .ex_to_mem_rd_data(),

    /* output to EX/MEM buffer */
    .ex_out(ex_to_mem_next),
    .pcmux_sel(pcmux_sel)
);

/******************************* MEM stage ***********************************/
mem mem(
    .clk(clk),
    .rst(rst),
    .load_mdr(load_mdr),        //todo: also hardcode?
    /* input signals from Magic Memory */
    .dmem_rdata(dmem_rdata), 

    /* input signals from EX/MEM buffer */
    .mem_in(ex_to_mem),
    .mem_in_next(ex_to_mem_next),

    /* output to EX/MEM buffer */
    .mem_out(mem_to_wb_next),
    .dmem_resp(dmem_resp),

    /* output to Magic Memory */
    .dmem_wdata(dmem_wdata),
    .dmem_address(dmem_address),
    .dmem_write(dmem_write), 
    .dmem_read(dmem_read),
    .mem_byte_enable(dmem_wmask)
    // .dmem_resp(dmem_resp)//tbd, pass from control_wd
);

/******************************* WB stage ***********************************/
write_back write_back(
    .wb_in(mem_to_wb),
    .dmem_rdata(dmem_rdata),    //TODO: directly passing to wb, need to change for cp2

    /* output to regfile */
    .regfile_in(regfile_in),
    .load_regfile(load_regfile)
);


always_comb begin
    load_pc = 1'b1;
    if(rst) begin
        load_pc = 1'b0;
    end
    // if(dmem_resp == 1'b1) begin // use for later part 
    //     load_pc = 1'b0;
    // end
end
//it seems that we do not have if_id anymore?
always_ff @(posedge clk) begin
    if(rst) begin
        if_to_id <= '0;
        id_to_ex <= '0;
        ex_to_mem <= '0;
        mem_to_wb <= '0;
    end
    else begin
        // if(dmem_resp == 1'b0) begin // stalling, for latter part
        // end 
        if(imem_resp) begin
            // if_id pipeline reg
            if_to_id.pc <= if_to_id_next.pc;
            if_to_id.rvfi_d <= if_to_id_next.rvfi_d;
            if_to_id.ir <= imem_rdata;
        end
        // id_ex pipeline reg
        id_to_ex <= id_to_ex_next;

        // ex_mem pipeline reg
        ex_to_mem <= ex_to_mem_next;

        // mem_wb pipline reg
        mem_to_wb <= mem_to_wb_next;

    end
end
endmodule 
