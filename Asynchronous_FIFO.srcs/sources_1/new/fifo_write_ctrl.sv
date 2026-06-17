// fifo_write_ctrl.sv
module fifo_write_ctrl #(
    parameter DEPTH      = 16,             
    localparam PTR_WIDTH = $clog2(DEPTH))( 

    input  logic               wclk,       
    input  logic               wrst_n,     
    input  logic               w_en,      
    input  logic [PTR_WIDTH:0] wq2_rptr,   
    output logic               wfull,      
    output logic [PTR_WIDTH-1:0] waddr,   
    output logic [PTR_WIDTH:0] wptr        
);

    // Internal pointer registers tracking our position
    logic [PTR_WIDTH:0] wbin;             
    logic [PTR_WIDTH:0] wbin_next;         
    logic [PTR_WIDTH:0] wgray_next;        

    // 1. Direct Memory Address Generation
    
    assign waddr = wbin[PTR_WIDTH-1:0];

    // 2. Incrementor Logic
    
    assign wbin_next  = wbin + (w_en & ~wfull);
    
    // 3. Binary-to-Gray Transform Math
   
    assign wgray_next = wbin_next ^ (wbin_next >> 1);

    // 4. Sequential Register Upkeep
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wbin <= '0; 
            wptr <= '0; 
        end else begin
            wbin <= wbin_next;  
            wptr <= wgray_next; 
        end
    end

    // 5. Full Flag Verification (Direct Gray Code Pattern Matching)
    assign wfull = (wptr == {~wq2_rptr[PTR_WIDTH:PTR_WIDTH-1], wq2_rptr[PTR_WIDTH-2:0]});

endmodule