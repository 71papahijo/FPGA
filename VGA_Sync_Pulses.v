//==================================================
// VGA Sync Pulse Generator (640x480 default timing)
//==================================================
module VGA_Sync_Pulses
  #(parameter TOTAL_COLS  = 800,
    parameter TOTAL_ROWS  = 525,
    parameter ACTIVE_COLS = 640,
    parameter ACTIVE_ROWS = 480)
  (input  wire i_Clk,
   output wire o_HSync,
   output wire o_VSync,
   output reg [9:0] o_Col_Count = 0,
   output reg [9:0] o_Row_Count = 0);

  localparam H_SYNC_START = ACTIVE_COLS + 16;
  localparam H_SYNC_END   = H_SYNC_START + 96;
  localparam V_SYNC_START = ACTIVE_ROWS + 10;
  localparam V_SYNC_END   = V_SYNC_START + 2;

  always @(posedge i_Clk)
  begin
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

  assign o_HSync = ~((o_Col_Count >= H_SYNC_START) && (o_Col_Count < H_SYNC_END));
  assign o_VSync = ~((o_Row_Count >= V_SYNC_START) && (o_Row_Count < V_SYNC_END));
endmodule
