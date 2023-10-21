module cpu
import rv32i_types::*;
(
    // input logic clk,
    // input logic rst,
    // input log mem_resp,//todo, input to which stage? mem?
    // input rv32i_word mem_rdata,
    // output logic mem_read,//todo, how to output? from control word?
    // output logic mem_write,//todo,how to output? from control word?
    // output logic [3:0] mem_byte_enable,//todo, ensure correctness
    // output rv32i_word mem_address,
    // output rv32i_word mem_wdata
    input   logic           clk,
    input   logic           rst,

    // Use these for CP1 (magic memory)
    output  logic   [31:0]  imem_address,
    output  logic           imem_read,
    input   logic   [31:0]  imem_rdata,
    input   logic           imem_resp,
    output  logic   [31:0]  dmem_address,
    output  logic           dmem_read,
    output  logic           dmem_write,
    output  logic   [3:0]   dmem_wmask,
    input   logic   [31:0]  dmem_rdata,
    output  logic   [31:0]  dmem_wdata,
    input   logic           dmem_resp
);

//todo: add WB stage

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
    .if_output(if_to_id_next)
);

/******************************* ID stage ************************************/
i_decode i_decode(
    /* inputs */
    .clk(clk),
    .rst(rst),
    .id_in(if_to_id),
    .regfilemux_sel(mem_to_wb.ctrl_wd.wb_ctrlwd.regfilemux_sel), //todo, how to hook regfilemux_sel from control_word?

    /* outputs to ID/EX buffer*/
    .id_out(id_to_ex_next)
);

/******************************* EXE stage ***********************************/
execute execute(
    /* input signals from ID/EX buffer */
    .ex_in(id_to_ex),

    /* output to EX/MEM buffer */
    .ex_out(ex_to_mem_next),
    .pcmux_sel(pcmux_sel)
);

/******************************* MEM stage ***********************************/
mem mem(
    .clk(clk),
    .rst(rst),
    .load_mdr(load_mdr), //todo: also hardcode?
    /* input signals from Magic Memory */
    .dmem_rdata(dmem_rdata), 

    /* input signals from EX/MEM buffer */
    .mem_in(ex_to_mem),

    /* output to EX/MEM buffer */
    .mem_out(mem_to_wb_next),

    /* output to Magic Memory */
    .dmem_wdata(dmem_wdata),
    .dmem_address(dmem_address),
    .dmem_write(dmem_write),
    .dmem_read(dmem_read),
    .mem_byte_enable(dmem_wmask)
);

always_ff @(posedge clk) begin
    if(rst) begin
        if_id <= '0;
        id_ex <= '0;
        ex_mem <= '0;
        mem_wb <= '0;
    end
    else begin

        // if_id pipeline reg
        if_to_id.pc <= if_to_id_next.pc;
        if_to_id.ir <= imem_rdata;

        // id_ex pipeline reg
        
        // ex_mem pipeline reg
        ex_to_mem <= ex_to_mem_next;

        // mem_wb pipeline reg
        mem_to_wb <= mem_to_wb_next;
    end
end
endmodule

/*
// the struct use to store the stage registers
typedef struct packed {
    rv32i_word      pc;     // program counter
    rv32i_inst_t    ir;     // instruction reg
}IF_ID_stage_t;

//TODO: double check the imms
typedef struct packed {
    // control signal blocks
    ctrl_word_t ctrl_wd;
    rv32i_word  rs1_out;     // src reg 1 output
    rv32i_word  rs2_out;     // src reg 2 output
    rv32i_word  i_imm; 
    rv32i_word  s_imm;      
    rv32i_word  b_imm;
    rv32i_word  u_imm;       
    rv32i_word  j_imm;
    rv32i_reg   rd;          // dest reg
}ID_EX_stage_t;

// TODO: double check
typedef struct packed {
    // control signal blocks
    ctrl_word_t ctrl_wd;
    rv32i_word  cmp_out;        
    rv32i_word  alu_out;         
    rv32i_word  mar;         
    rv32i_word  mem_data_out;    
    rv32i_word  u_imm;   
    rv32i_reg   rd;
}EX_MEM_stage_t;

// TODO: double check
typedef struct packed {
    // control signal blocks
    ctrl_word_t ctrl_wd;
    rv32i_word  alu_out;
    rv32i_word  cmp_out;    
    rv32i_word  mdr;        
    rv32i_word  u_imm;   
    rv32i_reg   rd;
}MEM_WB_stage_t;
*/