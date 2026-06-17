`timescale 1ns / 1ps

module cdc_synchronizer #(
 parameter WIDTH=5
)(
    input logic dest_clk,
    input logic dest_rst_n,
    input logic [WIDTH-1:0] src_ptr,
    output logic [WIDTH-1:0] dest_ptr
        );
        
logic [WIDTH-1:0] sync_reg_stage1;
logic [WIDTH-1:0] sync_reg_stage2;

always_ff @(posedge dest_clk or negedge dest_rst_n)begin 
    if (!dest_rst_n)begin 
        sync_reg_stage1<=1'b0;
        sync_reg_stage2<=1'b0;
        end
     else begin
        sync_reg_stage1<=src_ptr; 
        sync_reg_stage2<=sync_reg_stage1; 
     
     end

end
assign dest_ptr=sync_reg_stage2;

endmodule
