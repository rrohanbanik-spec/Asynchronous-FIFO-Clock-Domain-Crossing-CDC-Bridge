`timescale 1ns / 1ps
module fifo_mem_array #(
    parameter DATA_WIDTH=32,
    parameter DEPTH=16,
    localparam ADDR_WIDTH=$clog2(DEPTH)
    )(
    input logic wclk,
    input logic w_en,
    input logic wfull,
    input logic [ADDR_WIDTH-1:0] waddr,
    input logic [DATA_WIDTH-1:0] wdata,
    input logic [ADDR_WIDTH-1:0] raddr,
    output logic [DATA_WIDTH-1:0] rdata);
    
    
 logic [DATA_WIDTH-1:0] mem_matrix [DEPTH-1:0];
 
 always_ff @(posedge wclk)begin 
    if(w_en && !wfull) begin 
        mem_matrix[waddr]<=wdata;
        end
    
 end
 
 assign rdata=mem_matrix[raddr];
 
endmodule
