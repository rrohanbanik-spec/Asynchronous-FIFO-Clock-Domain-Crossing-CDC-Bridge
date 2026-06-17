`timescale 1ns / 1ps


module tb_async_fifo;

parameter  DATA_WIDTH=32;
parameter DEPTH=16;

logic                  wclk;
logic                  wrst_n;
logic                  w_en;
logic [DATA_WIDTH-1:0] wdata;
logic                  wfull;

logic                  rclk;
logic                  rrst_n;
logic                  r_en;
logic [DATA_WIDTH-1:0] rdata;
logic                  rempty;

async_fifo#(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH))
    DUT(
    .wclk(wclk),
    .wrst_n(wrst_n),
    .w_en(w_en),
    .wdata(wdata),
    .wfull(wfull),
    .rclk(rclk),
    .rrst_n(rrst_n),
    .r_en(r_en),
    .rdata(rdata),
    .rempty(rempty)
    );
 
 //write clock:100MHz so 10ns is one period and delay of 5ns   
 initial begin 
    wclk=0;
    forever #5  wclk = ~wclk;
    end
 //read clcok:50MHz so 20ns is one period so delay is 10ns
 initial begin 
    rclk=0;
    forever #10 rclk = ~rclk;
 
 end
 
 //stimulus generator(adding testcase)
 
 initial begin 
 r_en=0;
 w_en=0;
 wdata=0;
 wrst_n=0;
 rrst_n=0;
 #30;//20ns read and 10ns write
 wrst_n=1;
 rrst_n=1;
 #20; //for clearing and stabilizing the 2synchronizer flipflops
 $display("Starting Testbench: Fast write and slow read");
 
 //trying to write 20 items in a set depth of 16
 @(posedge wclk);
 for (int i=1;i<=20;i++)begin
    if(!wfull) begin
        w_en=1;
        wdata=i*10;
        $display("[WRITE] Time: %0t | Data In: %0d",$time,wdata);
         end
     else begin
        w_en=0;
        $display("[WRITE BLOCKED] Time: %0t | FIFO is Full cannot  write %0d",$time,i*10 );
        
         end 
         
    @(posedge wclk);
    end
 w_en=0;
 #100;
 
 //TEST CASE 2: TRYING TO READ UNTIL MEMORY IS EMPTY
@(posedge rclk);
    while (!rempty) begin 
       
        r_en = 1; 
        #0.1; 
        
       
        if (!rempty) begin
            $display("[READ]  Time: %0t | Data Out: %0d", $time, rdata);
        end
        
        // 4. Wait for the clock edge. On this rising edge, the Read Controller 
        // will officially increment rbin/rptr to prepare the NEXT data word.
        @(posedge rclk);
        
         
    end
    r_en = 0;
 $display("[READ BLOCKED] Time: %0t | FIFO is EMPTY!", $time);
 
 #200;
 $display("--- Simulation Successfully Concluded ---");
 $finish;
 end
endmodule
