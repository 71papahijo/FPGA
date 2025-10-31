//==================================================
// Converts H/V Sync pulses into pixel/row counters
//==================================================
module Sync_To_Count
  #(parameter TOTAL_COLS = 800,
    parameter TOTAL_ROWS = 525)
  (input  wire i_Clk,
   input  wire i_HSync,
   input  wire i_VSync,
   output reg  o_HSync,
   output reg  o_VSync,
   output reg [9:0] o_Col_Count = 0,
   output reg [9:0] o_Row_Count = 0);

  always @(posedge i_Clk)
  begin
    o_HSync <= i_HSync;
    o_VSync <= i_VSync;

    if (o_Col_Count == TOTAL_COLS - 1)
    begin
      o_Col_Count <= 0;
      if (o_Row_Count == TOTAL_ROWS - 1)
        o_Row_Count <= 0;
      else
        o_Row_Count <= o_Row_Count + 1;
    end
    else
      o_Col_Count <= o_Col_Count + 1;
  end
endmodule
