// apple_gen.v
// 7-position apple generator FSM for 7x6 grid

module Apple_Gen
#(
    parameter X_WIDTH = 3,   // 0..6
    parameter Y_WIDTH = 3    // 0..5
)
(
    input  wire                 i_Clk,      // Game_Clk
    input  wire                 i_Reset,    // sync reset, active high
    input  wire                 i_Advance,  // 1-clock pulse when apple is eaten

    output reg  [X_WIDTH-1:0]   o_Apple_X,
    output reg  [Y_WIDTH-1:0]   o_Apple_Y
);

    reg [2:0] r_State;  // 0..6

    always @(posedge i_Clk) begin
        if (i_Reset) begin
            r_State <= 3'd0;
        end else if (i_Advance) begin
            if (r_State == 3'd6)
                r_State <= 3'd0;
            else
                r_State <= r_State + 3'd1;
        end
    end

    always @* begin
        case (r_State)
            3'd0: begin  // near top-right-ish
                o_Apple_X = 3'd6;
                o_Apple_Y = 3'd4;
            end
            3'd1: begin  // near top-left-ish
                o_Apple_X = 3'd0;
                o_Apple_Y = 3'd1;
            end
            3'd2: begin
                o_Apple_X = 3'd3;
                o_Apple_Y = 3'd0;
            end
            3'd3: begin
                o_Apple_X = 3'd1;
                o_Apple_Y = 3'd5;
            end
            3'd4: begin
                o_Apple_X = 3'd5;
                o_Apple_Y = 3'd2;
            end
            3'd5: begin
                o_Apple_X = 3'd2;
                o_Apple_Y = 3'd3;
            end
            3'd6: begin
                o_Apple_X = 3'd4;
                o_Apple_Y = 3'd1;
            end
            default: begin
                o_Apple_X = 3'd6;
                o_Apple_Y = 3'd4;
            end
        endcase
    end

endmodule
