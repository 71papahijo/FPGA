// apple_gen.v
// Simple 4-position apple generator FSM for 7x6 grid
// Sequence (internal coords):
//   0: (6,4)   -- your "(7,4)"
//   1: (0,1)
//   2: (5,0)
//   3: (2,5)

module Apple_Gen
#(
    parameter X_WIDTH = 3,   // enough for 0..6
    parameter Y_WIDTH = 3    // enough for 0..5
)
(
    input  wire                 i_Clk,      // Game_Clk
    input  wire                 i_Reset,    // sync reset, active high
    input  wire                 i_Advance,  // 1-clock pulse when apple is eaten

    output reg  [X_WIDTH-1:0]   o_Apple_X,
    output reg  [Y_WIDTH-1:0]   o_Apple_Y
);

    // 2-bit state = which apple position we are on (0..3)
    reg [1:0] r_State;

    // State update
    always @(posedge i_Clk) begin
        if (i_Reset) begin
            r_State <= 2'd0;           // start at first position
        end else if (i_Advance) begin
            r_State <= r_State + 2'd1; // wraps 3->0 automatically
        end
    end

    // Decode state -> (X,Y) coordinate
    always @* begin
        case (r_State)
            2'd0: begin
                // (7,4) user-facing -> internal (6,4)
                o_Apple_X = 3'd6;
                o_Apple_Y = 3'd4;
            end

            2'd1: begin
                // (0,1)
                o_Apple_X = 3'd0;
                o_Apple_Y = 3'd1;
            end

            2'd2: begin
                // some far-ish position, tweak as you like
                o_Apple_X = 3'd5;
                o_Apple_Y = 3'd0;
            end

            2'd3: begin
                // another far-ish position
                o_Apple_X = 3'd2;
                o_Apple_Y = 3'd5;
            end

            default: begin
                // safe default (should never hit)
                o_Apple_X = 3'd6;
                o_Apple_Y = 3'd4;
            end
        endcase
    end

endmodule
