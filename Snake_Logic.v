module Snake_Logic
#(parameter c_TOTAL_COLS=800,
    parameter c_TOTAL_ROWS=525,
    parameter c_ACTIVE_COLS=640,
    parameter c_ACTIVE_ROWS=480)
(input i_Clk,
    input i_HSync,
    input i_VSync,
    
    input Snake_Up,
    input Snake_Down,
    input Snake_Left,
    input Snake_Right,

    output reg o_HSync,
    output reg o_VSync,
    output [3:0] o_Red_Video,
    output [3:0] o_Grn_Video,
    output [3:0] o_Blu_Video);

    reg [2:0] FSM_Main = IDLE;
   


    // Game States
    parameter IDLE    = 3'b000;
    parameter RUNNING = 3'b001;
    parameter GameFinished = 3'b010;
    parameter CLEANUP = 3'b100;

endmodule