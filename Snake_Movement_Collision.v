module SnakeMovCol
    (input Game_Clk,
    input [1:0] i_Dir,
    input [3:0] i_Head_X,
    input [3:0] i_Head_Y,
    input [3:0] i_Tail_X,
    input [3:0] i_Tail_Y,
    input [3:0] i_Food_X,
    input [3:0] i_Food_Y,
    input [89:0] i_SnakeBody,
    output [89:0] o_SnakeBody,
    output reg [3:0] o_Head_X,
    output reg [3:0] o_Head_Y,
    output reg [3:0] o_Tail_X,
    output reg [3:0] o_Tail_Y,
    output reg [3:0] o_Food_X,
    output reg [3:0] o_Food_Y,
    output reg o_Collision
    );
    localparam DIR_UP    = 2'b00;
    localparam DIR_DOWN  = 2'b01;
    localparam DIR_LEFT  = 2'b10;
    localparam DIR_RIGHT = 2'b11;
    localparam X_MAX = 9;
    localparam Y_MAX = 10;

    reg wallCollision;
    always @(*) begin
        case (i_Dir)
            DIR_UP:
                if (i_head_Y == 0) // Wall collision detection, might trigger early but idk
                    wallCollision = 1;
                else
                    wallCollision = 0;
                    o_Head_Y = i_Head_Y - 1;
            DIR_DOWN:
                if (i_head_Y == Y_MAX-1)
                    wallCollision = 1;
                else
                    wallCollision = 0;
                    o_Head_Y = i_Head_Y + 1;
            DIR_LEFT:
                if (i_head_X == 0)
                    wallCollision = 1;
                else
                    wallCollision = 0;
                    o_Head_X = i_Head_X - 1;
            DIR_RIGHT:
                if (i_head_X == X_MAX-1)
                    wallCollision = 1;
                else
                    wallCollision = 0;
                    o_Head_X = i_Head_X + 1;

            //Wrap around logic, much easier :(
            // DIR_UP: o_Head_Y = (i_Head_Y == 0) ? Y_MAX-1 : i_Head_Y - 1;
            // DIR_DOWN:  o_Head_Y = (i_Head_Y == Y_MAX-1) ? 0 : i_Head_Y + 1;
            // DIR_LEFT:  o_Food_X = (i_Head_X == 0) ? X_MAX-1 : i_Head_X - 1;
            // DIR_RIGHT: o_Food_X = (i_Head_X == X_MAX-1) ? 0 : i_Head_X + 1;
        endcase
    end


    reg[6:0] tail_index = i_Tail_X + i_Tail_Y * 10;
    reg[6:0] food_index = i_Food_X + i_Food_Y * 10;

    @(posedge Game_Clk) begin
        if(wallCollision) begin
            o_Collision <= 1;
        end else begin
            o_Collision <= 0;
        end
        
        
    end

endmodule