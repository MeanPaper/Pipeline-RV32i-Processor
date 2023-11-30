
module plru_update(  
    input logic [1 : 0] hit_way,
    input logic [2 : 0] plru_bits,
    output logic [2 : 0] new_plru_bits
);
 
always_comb begin
    case(hit_way)
        2'd0: new_plru_bits = {plru_bits[2], ~hit_way[0], ~hit_way[1]};
        2'd1: new_plru_bits = {plru_bits[2], ~hit_way[0], ~hit_way[1]};
        2'd2: new_plru_bits = {~hit_way[0], plru_bits[1], ~hit_way[1]};
        2'd3: new_plru_bits = {~hit_way[0], plru_bits[1], ~hit_way[1]};

        default: new_plru_bits = 3'b000;
    endcase
end
endmodule
