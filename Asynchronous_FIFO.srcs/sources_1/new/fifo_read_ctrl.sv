`timescale 1ns / 1ps
module fifo_read_ctrl#(
    parameter DEPTH=16,
    localparam PTR_WIDTH= $clog2(DEPTH))(
    input logic rclk,
    input logic rrst_n,
    input logic r_en,
    input logic [PTR_WIDTH:0] wq2_rptr,
    output logic rempty,
    output logic [PTR_WIDTH-1:0] raddr,
    output logic [PTR_WIDTH:0] rptr);

logic [PTR_WIDTH:0] rbin;
logic [PTR_WIDTH:0] rbin_next;
logic [PTR_WIDTH:0] rgray_next;

//memory address generation
assign raddr=rbin[PTR_WIDTH-1:0];
//increment logic
assign rbin_next=rbin + (r_en & ~rempty);
//binary to gray converter
assign rgray_next=rbin_next^(rbin_next>>1);

always_ff @(posedge rclk or negedge rrst_n)begin 
    if (!rrst_n)begin 
    rbin<=1'b0;
    rptr<=1'b0;
    end
    else begin 
        rbin<=rbin_next;
        rptr<=rgray_next;
        
    end
 end
 
 assign rempty=(rptr==wq2_rptr);
 
    
endmodule
