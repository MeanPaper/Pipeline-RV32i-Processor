module cpu
import rv32i_types::*;
(
    input logic clk,
    input logic rst,
    input log mem_resp,//todo, input to which stage? mem?
    input rv32i_word mem_rdata,
    output logic mem_read,//todo, how to output? from control word?
    output logic mem_write,//todo,how to output? from control word?
    output logic [3:0] mem_byte_enable,//todo, ensure correctness
    output rv32i_word mem_address,
    output rv32i_word mem_wdata
);

//todo: add WB stage

/**************************** Control Signals ********************************/
pcmux::pcmux_sel_t pcmux_sel;
alumux::alumux1_sel_t alumux1_sel;
alumux::alumux2_sel_t alumux2_sel;
regfilemux::regfilemux_sel_t regfilemux_sel;
marmux::marmux_sel_t marmux_sel;
cmpmux::cmpmux_sel_t cmpmux_sel;
/***************************** Pipeline Register ******************************/
IF_ID_stage_t if_to_id;
ID_EX_stage_t id_to_ex;
EX_MEM_stage_t ex_to_mem;
MEM_WB_stage_t mem_to_wb;
/****************************** Load Signals  ********************************/
logic load_pc;
logic load_mdr; //tbd
assign load_pc = 1'b1; //For CP1
assign load_mdr = 1'b1; // For CP1
/******************************* IF stage ************************************/
i_fetch i_fetch(
    /* inputs */
    .clk(clk),
    .rst(rst),
    .alu_out(mem_to_wb.alu_out),
    .pcmux_sel(pcmux_sel),
    .load_pc(load_pc),//hardcode to 1 for CP1

    /* outputs to IF/ID buffer*/
    if_output.(if_to_id)
);

/******************************* ID stage ************************************/
i_decode i_decode(
    /* inputs */
    .clk(clk),
    .rst(rst),
    .id_in(if_to_id),
    .regfilemux_sel(regfilemux_sel), //todo, how to hook regfilemux_sel from control_word?

    /* outputs to ID/EX buffer*/
    .id_out(id_to_ex)
);

/******************************* EXE stage ***********************************/
execute execute(
    /* input signals from ID/EX buffer */
    .ex_in(id_to_ex),

    /* output to EX/MEM buffer */
    .ex_out(ex_to_mem),
    .pcmux_sel(pcmux_sel)
);

/******************************* MEM stage ***********************************/
mem mem(
    .clk(clk),
    .rst(rst),
    .load_mdr(load_mdr), //todo: also hardcode?
    /* input signals from Magic Memory */
    .dmem_rdata(mem_rdata), 

    /* input signals from EX/MEM buffer */
    .mem_in(ex_to_mem),

    /* output to EX/MEM buffer */
    .mem_out(mem_to_wb),

    /* output to Magic Memory */
    .dmem_wdata(mem_wdata),
    .dmem_address(mem_address),
    .dmem_write(mem_write),
    .dmem_read(mem_read),
    .mem_byte_enable(mem_byte_enable)
);
endmodule