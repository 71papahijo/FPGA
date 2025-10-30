
module Debounce_Filter #(parameter DEBOUNCE_LIMIT = 20) (
    input  i_Clk,
    input  i_Bouncy,
    output o_Debounced);
    reg [$clog2(DEBOUNCE_LIMIT)-1:0] r_Count = 0;
    reg r_State = 1'b0;
    always @(posedge i_Clk)
    begin
    if (i_Bouncy !== r_State && r_Count < DEBOUNCE_LIMIT-1)
     begin
       r_Count <= r_Count + 1;
     end
    else if (r_Count == DEBOUNCE_LIMIT-1)
     begin
       r_State <= i_Bouncy;
       r_Count <= 0;
     end
     else
     begin
        r_Count <= 0;
     end
    end
    assign o_Debounced = r_State;
endmodule