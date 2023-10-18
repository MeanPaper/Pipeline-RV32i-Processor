package rv32i_types;

/* Parameters */
parameter int WORD_LEN = 32;

/* Basic Types */
typedef logic [WORD_LEN-1: 0] rv32i_word; // [31:0], 32 bits
typedef logic [4:0] rv32i_reg;            // [4:0], 32 registers
typedef logic [3:0] rv32i_mem_wmask;      // [3:0], 4 bits, used to select the bytes in the word

typedef struct packed{
    
    logic aluop; // more information will come
    logic cmpop; // more information will come



}EX_control_t;

typedef struct packed{

}MEM_control_t;

typedef struct packed{

}WB_control_t;


// the struct use to store the stage control signals
typedef struct packed {
    
    // control signal blocks
    EX_control_t EX_ctrl;
    MEM_control_t MEM_ctrl;
    WB_control_t WB_ctrl;

    
}ID_EX_stage_t;

typedef struct packed {

    // control signal blocks
    EX_control_t EX_ctrl;
    MEM_control_t MEM_ctrl;
    WB_control_t WB_ctrl;


}EX_MEM_stage_t;

typedef struct packed {
    
    // control signal blocks
    EX_control_t EX_ctrl;
    MEM_control_t MEM_ctrl;
    WB_control_t WB_ctrl;

}MEM_WB_stage_t;



endpackage