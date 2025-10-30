module ClkDiv
#(parameter ResetValue = 6250000, parameter WIDTH = 23)
(
    input  wire Reset,
    input  wire i_Clk,
    output reg  o_Clk = 0
);
    reg [WIDTH-1:0] counter = 0;

    always @(posedge i_Clk or posedge Reset) begin
        if (Reset) begin
            counter <= 0;
            o_Clk   <= 0;
        end else if (counter == ResetValue - 1) begin
            counter <= 0;
            o_Clk   <= ~o_Clk;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule
