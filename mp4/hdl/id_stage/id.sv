
module i_decode 
import rv32i_types::*;
(
    /* inputs */
    input clk,
    input rst,

    /* outputs to ID/EX buffer*/
);

/* regfile */
regfile RegFile(
    .clk,
    .rst,
    .load(load_regfile),
    .in(regfilemux_out),  
    .src_a(rs1),
    .src_b(rs2),
    .dest(rd),
    .reg_a(rs1_out),
    .reg_b(rs2_out)
);
/* control word */

/* possible Hazard Detection Unit */

endmodule 
