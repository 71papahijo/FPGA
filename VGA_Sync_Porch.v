module VGA_Sync_Porch
  #(parameter VIDEO_WIDTH = 3,
    parameter TOTAL_COLS  = 800,
    parameter TOTAL_ROWS  = 525,
    parameter ACTIVE_COLS = 640,
    parameter ACTIVE_ROWS = 480)
  (input  wire i_Clk,
   input  wire i_HSync,
   input  wire i_VSync,
   input  wire [VIDEO_WIDTH-1:0] i_Red_Video,
   input  wire [VIDEO_WIDTH-1:0] i_Grn_Video,
   input  wire [VIDEO_WIDTH-1:0] i_Blu_Video,
   output reg  o_HSync,
   output reg  o_VSync,
   output reg [VIDEO_WIDTH-1:0] o_Red_Video,
   output reg [VIDEO_WIDTH-1:0] o_Grn_Video,
   output reg [VIDEO_WIDTH-1:0] o_Blu_Video);

  reg [9:0] r_Col_Count = 0;
  reg [9:0] r_Row_Count = 0;

  always @(posedge i_Clk)
  begin
    o_HSync <= i_HSync;
    o_VSync <= i_VSync;
    if (r_Col_Count < ACTIVE_COLS && r_Row_Count < ACTIVE_ROWS)
    begin
      o_Red_Video <= i_Red_Video;
      o_Grn_Video <= i_Grn_Video;
      o_Blu_Video <= i_Blu_Video;
    end
    else
    begin
      o_Red_Video <= 0;
      o_Grn_Video <= 0;
      o_Blu_Video <= 0;
    end

    if (r_Col_Count == TOTAL_COLS - 1)
    begin
      r_Col_Count <= 0;
      if (r_Row_Count == TOTAL_ROWS - 1)
        r_Row_Count <= 0;
      else
        r_Row_Count <= r_Row_Count + 1;
    end
    else
      r_Col_Count <= r_Col_Count + 1;
  end
endmodule
