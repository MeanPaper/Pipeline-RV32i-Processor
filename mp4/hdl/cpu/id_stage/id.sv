
module i_decode 
import rv32i_types::*;
(
    /* inputs */
    input logic clk,
    input logic rst,
    input IF_ID_stage_t id_in,
    input rv32i_word regfile_in,
    input logic load_regfile
    
    /* outputs to ID/EX buffer*/
    output ID_EX_stage_t id_out

);
    /* RegFile signals */


    /* signals to send out to next stage */

    
    /* assignments */
    


    /* regfile */
    regfile RegFile(
        .clk(clk),
        .rst(rst),
        .load(load_regfile),
        .in(regfile_in),  
        .src_a(id_in.ir.r_inst.rs1),
        .src_b(id_in.ir.r_inst.rs2),
        .dest(id_in.ir.r_inst.rd),
        .reg_a(id_out.rs1_out),
        .reg_b(id_out.rs2_out)
    );
    /* control word */

    /* possible Hazard Detection Unit in forwarding */
    /* save for cp2 */




endmodule 
