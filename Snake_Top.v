module Snake_Top
    (input  i_Clk,       // Main Clock
    
    // Input Buttons
    input[3:0] Sw,

    // VGA
    output o_VGA_HSync,
    output o_VGA_VSync,

    output o_VGA_Red_0,
    output o_VGA_Red_1,
    output o_VGA_Red_2,

    output o_VGA_Grn_0,
    output o_VGA_Grn_1,
    output o_VGA_Grn_2,

    output o_VGA_Blu_0,
    output o_VGA_Blu_1,
    output o_VGA_Blu_2   
    );

    wire[3:0] D_Sw;
    Debounce Deb0 (.i_Clk(i_Clk), .i_Bouncy(Sw[0]), .o_Debounced(D_Sw[0]));
    Debounce Deb1 (.i_Clk(i_Clk), .i_Bouncy(Sw[1]), .o_Debounced(D_Sw[1]));
    Debounce Deb2 (.i_Clk(i_Clk), .i_Bouncy(Sw[2]), .o_Debounced(D_Sw[2]));
    Debounce Deb3 (.i_Clk(i_Clk), .i_Bouncy(Sw[3]), .o_Debounced(D_Sw[3]));

    // VGA Constants to set Frame Size
    parameter c_VIDEO_WIDTH = 3;
    parameter c_TOTAL_COLS  = 800;
    parameter c_TOTAL_ROWS  = 525;
    parameter c_ACTIVE_COLS = 640;
    parameter c_ACTIVE_ROWS = 480;
    // Common VGA Signals
    wire [c_VIDEO_WIDTH-1:0] Red_Rend, Red_Porch;
    wire [c_VIDEO_WIDTH-1:0] Grn_Rend, Grn_Porch;
    wire [c_VIDEO_WIDTH-1:0] Blu_Rend, Blu_Porch;
    // Sync and pixel coords
    wire w_HSync;
    wire w_VSync;
    wire [9:0] w_Col_Count;
    wire [9:0] w_Row_Count;

    // Generates Sync Pulses to run VGA
    VGA_Sync_Pulses #(.TOTAL_COLS(c_TOTAL_COLS),
        .TOTAL_ROWS(c_TOTAL_ROWS),
        .ACTIVE_COLS(c_ACTIVE_COLS),
        .ACTIVE_ROWS(c_ACTIVE_ROWS)
    ) VGA_Sync_Pulses_Inst (
        .i_Clk(i_Clk),
        .o_HSync(w_HSync),
        .o_VSync(w_VSync),
        .o_Col_Count(w_Col_Count),
        .o_Row_Count(w_Row_Count)
    );

    reg Game_Clk;
    ClkDiv #(.ResetValue(6250000), .WIDTH(23)) ClkDiv_Inst
    (.Reset(1'b0), .i_Clk(i_Clk), .o_Clk(Game_Clk));

    Snake_Logic Snake_Logic_Inst
    (.Game_Clk(Game_Clk), 
    .i_Clk(i_Clk),
    // .i_HSync(w_Col_Count), 
    // .i_VSync(w_Row_Count),
    .i_HSync(w_HSync),
    .i_VSync(w_VSync),
    .Snake_Up(D_Sw[0]),
    .Snake_Down(D_Sw[1]),
    .Snake_Left(D_Sw[2]),
    .Snake_Right(D_Sw[3]),
    .o_HSync(o_VGA_HSync),
    .o_VSync(o_VGA_VSync),
    .o_Red_Video({Red_Rend}),
    .o_Grn_Video({Grn_Rend}),
    .o_Blu_Video({Blu_Rend})
    );


    VGA_Sync_Porch  #(.VIDEO_WIDTH(c_VIDEO_WIDTH),
        .TOTAL_COLS(c_TOTAL_COLS),
        .TOTAL_ROWS(c_TOTAL_ROWS),
        .ACTIVE_COLS(c_ACTIVE_COLS),
        .ACTIVE_ROWS(c_ACTIVE_ROWS))
    VGA_Sync_Porch_Inst
    (.i_Clk(i_Clk),
    .i_HSync(w_HSync),
    .i_VSync(w_VSync),
    .i_Red_Video(Red_Rend),
    .i_Grn_Video(Grn_Rend),
    .i_Blu_Video(Blu_Rend),
    .o_HSync(o_VGA_HSync),
    .o_VSync(o_VGA_VSync),
    .o_Red_Video(Red_Porch),
    .o_Grn_Video(Grn_Porch),
    .o_Blu_Video(Blu_Porch));

    // Final VGA Output Assignments 
    assign {o_VGA_Red_2, o_VGA_Red_1, o_VGA_Red_0} = Red_Porch;
    assign {o_VGA_Grn_2, o_VGA_Grn_1, o_VGA_Grn_0} = Grn_Porch;
    assign {o_VGA_Blu_2, o_VGA_Blu_1, o_VGA_Blu_0} = Blu_Porch;

endmodule