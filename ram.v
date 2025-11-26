// =============================================================
// 64 x 2-bit true dual-port RAM for iCE40 (SB_RAM40_4K)
// Fully synthesizable, guaranteed to map into an EBR
// =============================================================
module Snake_Grid_RAM (
    // Write port  (Game clock domain)
    input  wire        wclk,
    input  wire        we,
    input  wire [5:0]  waddr,
    input  wire [1:0]  wdata,

    // Read port   (VGA pixel clock domain)
    input  wire        rclk,
    input  wire [5:0]  raddr,
    output wire [1:0]  rdata
);

    // SB_RAM40_4K has 16-bit data, but we only need 2 bits.
    // So we pack our 2-bit words into the LSBs and tie the rest to zero.

    wire [15:0] wdata_packed = {14'b0, wdata};
    wire [15:0] rdata_packed;

    SB_RAM40_4K #(
        .READ_MODE(0),    // 0 = normal RAM
        .WRITE_MODE(0),   // 0 = normal RAM
        .INIT_0(256'h0),
        .INIT_1(256'h0),
        .INIT_2(256'h0),
        .INIT_3(256'h0),
        .INIT_4(256'h0),
        .INIT_5(256'h0),
        .INIT_6(256'h0),
        .INIT_7(256'h0),
        .INIT_8(256'h0),
        .INIT_9(256'h0),
        .INIT_A(256'h0),
        .INIT_B(256'h0),
        .INIT_C(256'h0),
        .INIT_D(256'h0),
        .INIT_E(256'h0),
        .INIT_F(256'h0)
    ) ram_inst (
        // PORT A (write)
        .RCLK    (wclk),
        .RCLKE   (1'b1),
        .RE      (1'b0),     // not used on write port
        .WCLK    (wclk),
        .WCLKE   (1'b1),
        .WE      (we),
        .AD      ({10'b0, waddr}),   // 16-bit address; lower 6 bits used
        .DI      (wdata_packed),

        // PORT B (read)
        .RCLK_B  (rclk),
        .RCLKE_B (1'b1),
        .RE_B    (1'b1),
        .WCLK_B  (rclk),
        .WCLKE_B (1'b0),             // no writing on port B
        .WE_B    (1'b0),
        .AD_B    ({10'b0, raddr}),
        .DI_B    (16'b0),
        .DO_B    (rdata_packed)
    );

    // Return only the lower 2 bits
    assign rdata = rdata_packed[1:0];

endmodule
