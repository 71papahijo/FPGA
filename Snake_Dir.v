module Snake_NextDir(
    input  i_Clk,
    input  Snake_Up,
    input  Snake_Down,
    input  Snake_Left,
    input  Snake_Right,
    input  [1:0] Snake_Dir,
    output reg [1:0] o_Dir);

    parameter DIR_UP    = 2'b00;
    parameter DIR_DOWN  = 2'b01;
    parameter DIR_LEFT  = 2'b10;
    parameter DIR_RIGHT = 2'b11;

    always @(posedge i_Clk) begin
        // default: maintain current direction

        case (Snake_Dir)
            DIR_UP: begin    
                if (Snake_Left)  o_Dir <= DIR_LEFT;
                else if (Snake_Right) o_Dir <= DIR_RIGHT;
                else if (Snake_Up) o_Dir <= DIR_UP;
            end
            DIR_DOWN: begin  
                if (Snake_Left)  o_Dir <= DIR_RIGHT;
                else if (Snake_Right) o_Dir <= DIR_LEFT;
                else if (Snake_Down) o_Dir <= DIR_DOWN;
            end
            DIR_LEFT: begin  
                if (Snake_Up) o_Dir <= DIR_UP;
                else if (Snake_Down) o_Dir <= DIR_DOWN;
                else if (Snake_Left) o_Dir <= DIR_LEFT;
            end
            DIR_RIGHT: begin 
                if (Snake_Up) o_Dir <= DIR_DOWN;
                else if (Snake_Down) o_Dir <= DIR_UP;
                else if (Snake_Right) o_Dir <= DIR_RIGHT;
            end
        endcase

    end
endmodule
