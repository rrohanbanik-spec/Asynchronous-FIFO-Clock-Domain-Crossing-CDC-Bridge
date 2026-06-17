`timescale 1ns / 1ps
module async_fifo#(
    parameter DATA_WIDTH=32,
    parameter DEPTH=16,
    localparam ADDR_WIDTH=$clog2(DEPTH))(
    
    //write domian ports
    input logic wclk,
    input logic wrst_n,
    input logic w_en,
    input logic [DATA_WIDTH-1:0] wdata,
    output logic wfull,
    
    //read domain ports
    input logic rclk,
    input logic rrst_n,
    input logic r_en,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic rempty
    );
    
//memory indexing wires [3:0]
logic [ADDR_WIDTH-1:0] waddr;
logic [ADDR_WIDTH-1:0] raddr;

//GRAY-CODE POINTERS
logic [ADDR_WIDTH:0] wptr;
logic [ADDR_WIDTH:0] rptr;

//cross-synchronized gray-code pointer buses [4:0]
logic [ADDR_WIDTH:0] wq2_rptr;
logic [ADDR_WIDTH:0] rq2_wptr;

//instantiating the dual -port memory matrix

fifo_mem_array#(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
    )mem_core(
    .wclk(wclk),
    .w_en(w_en),
    .wfull(wfull),
    .waddr(waddr),
    .wdata(wdata),
    .raddr(raddr),
    .rdata(rdata)
    );
    
    
//instantiate the clock domain crossing  synchronizer

//synchronizing write clock domain into read clock domain
cdc_synchronizer #(
    .WIDTH(ADDR_WIDTH+1)
    ) sync_wptr_to_rclk(
    .dest_clk(rclk),
    .dest_rst_n(rrst_n),
    .src_ptr(wptr),
    .dest_ptr(wq2_rptr));
//syncgronizing read clock domain into write clock domain

cdc_synchronizer #(
    .WIDTH(ADDR_WIDTH+1)
    ) sync_rptr_to_wclk(
    .dest_clk(wclk),
    .dest_rst_n(wrst_n),
    .src_ptr(rptr),
    .dest_ptr(rq2_wptr));

// INSTANTIATE THE CONTROLLER ENGINE BLOCKS

//write domain controller
fifo_write_ctrl #(
        .DEPTH(DEPTH)
    ) write_controller (
    .wclk(wclk),
    .wrst_n(wrst_n),
    .w_en(w_en),
    .wq2_rptr(rq2_wptr),     // Feeds in the stabilized read pointer from step 3
        .wfull(wfull),
        .waddr(waddr),           // Drives the waddr wire going to the RAM core
        .wptr(wptr));
        
 //the read domain controller
 fifo_read_ctrl #(
        .DEPTH(DEPTH)
    ) read_controller (
        .rclk(rclk),
        .rrst_n(rrst_n),
        .r_en(r_en),
        .wq2_rptr(wq2_rptr),     // Feeds in the stabilized write pointer from step 3
        .rempty(rempty),
        .raddr(raddr),           // Drives the raddr wire going to the RAM core
        .rptr(rptr)              // Drives the rptr wire going to the synchronizer
    );
endmodule
