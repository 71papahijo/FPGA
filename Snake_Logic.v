// X Lenght = 7, Y length = 6

module Snake_Logic
#(parameter c_TOTAL_COLS=800,
    parameter c_TOTAL_ROWS=525,
    parameter c_ACTIVE_COLS=640,
    parameter c_ACTIVE_ROWS=480)
(input Game_Clk,
    input i_Clk,
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

   
    reg [41:0] SnakeBody;
    reg [5:0] SnakeIndexs [1:20];
    reg [4:0] SnakeLength;
    reg [2:0] Head_X, Head_Y;
    reg [2:0] Food_X, Food_Y;
    reg o_Collision;

    // Game States
    reg [1:0] Game_State = IDLE;
    parameter IDLE    = 2'b00;
    parameter RUNNING = 2'b01;
    parameter GameFinished = 2'b10;
    parameter CLEANUP = 2'b11;

    wire w_HSync, w_VSync;
    wire [5:0] w_Col_Count_Div, w_Row_Count_Div;
    wire [9:0] w_Col_Count, w_Row_Count;
    Sync_To_Count #(.TOTAL_COLS(c_TOTAL_COLS),
                  .TOTAL_ROWS(c_TOTAL_ROWS)) Sync_To_Count_Inst
        (.i_Clk(i_Clk),
        .i_HSync(i_HSync),
        .i_VSync(i_VSync),
        .o_HSync(w_HSync),
        .o_VSync(w_VSync),
        .o_Col_Count(w_Col_Count),
        .o_Row_Count(w_Row_Count));

    always @(posedge i_Clk)
    begin
        o_HSync <= w_HSync;
        o_VSync <= w_VSync;
    end
    // Drop 4 LSBs, which effectively divides by 16
    // assign w_Col_Count_Div = w_Col_Count[9:4];
    // assign w_Row_Count_Div = w_Row_Count[9:4];
    assign w_Col_Count_Div = w_Col_Count / (c_ACTIVE_COLS / 7);
    assign w_Row_Count_Div = w_Row_Count / (c_ACTIVE_ROWS / 6);


    parameter DIR_UP = 2'b00;
    parameter DIR_DOWN = 2'b01;
    parameter DIR_LEFT = 2'b10;
    parameter DIR_RIGHT = 2'b11;

    reg [1:0] Snake_Dir;
    reg [1:0] Snake_Dir_Next;
    Snake_NextDir Directions(
    .i_Clk(i_Clk),
    .Snake_Up(Snake_Up),
    .Snake_Down(Snake_Down),
    .Snake_Left(Snake_Left),
    .Snake_Right(Snake_Right),
    .Snake_Dir(Snake_Dir),  
    .o_Dir(Snake_Dir_Next)       
    );
    reg i;
    reg [3:0] new_Head_X, new_Head_Y;
    reg wallCollision;
    reg[5:0] tail_index;
    reg[5:0] new_head_index;
    reg[5:0] index;


    always @(posedge Game_Clk) begin
        case (Game_State)
            IDLE: begin
                if (Snake_Right) begin
                    Game_State <= RUNNING;
                    Snake_Dir <= DIR_RIGHT;

                    // Preload snake
                    Head_X <= 3;
                    Head_Y <= 3;
                    SnakeIndexs[1] <= 22;
                    SnakeIndexs[2] <= 23;
                    SnakeIndexs[3] <= 24; // tail
                    SnakeLength <= 3;

                    Food_X <= 6;
                    Food_Y <= 3;

                    SnakeBody <= 42'b0;
                    SnakeBody[24] <= 1'b1;
                    SnakeBody[23] <= 1'b1;
                    SnakeBody[22] <= 1'b1;
                
                    o_Collision <= 0;
                end
            end

            RUNNING: begin
                wallCollision = 0;
                new_Head_X = Head_X;
                new_Head_Y = Head_Y;

                case (Snake_Dir_Next)
                    DIR_UP: if (Head_Y==0) wallCollision=1; else new_Head_Y = Head_Y-1;
                    DIR_DOWN: if (Head_Y==5) wallCollision=1; else new_Head_Y = Head_Y+1;
                    DIR_LEFT: if (Head_X==0) wallCollision=1; else new_Head_X = Head_X-1;
                    DIR_RIGHT: if (Head_X==6) wallCollision=1; else new_Head_X = Head_X+1;
                endcase

                if (wallCollision) begin
                    o_Collision <= 1;
                    Game_State <= GameFinished;
                end else begin
                    o_Collision <= 0;
                    Head_X <= new_Head_X;
                    Head_Y <= new_Head_Y;

                    // compute new head index
                    new_head_index = new_Head_Y*7 + new_Head_X;

                    // self collision
                    if (SnakeBody[new_head_index] == 1'b1) begin
                        o_Collision <= 1;
                        Game_State <= GAME_FINISHED;
                    end else begin
                        if (new_head_index == (Food_Y*7 + Food_X)) begin
                            SnakeIndexs[SnakeLength] <= new_head_index;
                            SnakeLength <= SnakeLength + 1;
                            if(SnakeLength == 20) begin
                                // max length reached
                                Game_State <= GameFinished;
                            end

                            SnakeBody[new_head_index] <= 1'b1;

                            // TODO: generate new food
                        end else begin
                            tail_index = SnakeIndexs[1];
                            SnakeBody[tail_index] <= 0;

                            // shift FIFO forward
                            // SnakeIndexs[0:89] <= SnakeIndexs[1:90]; // cant do it to the same array :(
                            for (index = 1; index < 20; index = index + 1) begin
                                SnakeIndexs[index] <= SnakeIndexs[index + 1];
                            end

                            SnakeIndexs[SnakeLength] <= new_head_index;
                            SnakeBody[new_head_index] <= 1'b1;
                        end
                    end
                end

                // update direction
                Snake_Dir <= Snake_Dir_Next;
            end
            GameFinished: begin
                if(Snake_Right)begin
                    Game_State <= IDLE;
                end
            end
        endcase
    end

// render
reg [3:0] pixel_R;
reg [3:0] pixel_G;
reg [3:0] pixel_B;

integer render_index;

// Each visible pixel belongs to one "cell" in the 10x9 grid
wire [2:0] cell_X = w_Col_Count_Div[2:0];
wire [2:0] cell_Y = w_Row_Count_Div[2:0];
wire [6:0] pixel_index = cell_Y * 7 + cell_X;

always @(*) begin
    // Default: black background
    pixel_R = 0;
    pixel_G = 0;
    pixel_B = 0;

    if (pixel_index < 42) begin
        if (SnakeBody[pixel_index]) begin
            // Snake body — green
            pixel_R = 0;
            pixel_G = 15;
            pixel_B = 0;
        end
        else if (pixel_index == (Food_Y * 7 + Food_X)) begin
            // Food — red
            pixel_R = 15;
            pixel_G = 0;
            pixel_B = 0;
        end
        else begin
            // Background
            if(Game_State == RUNNING) begin
                pixel_R = 0;
                pixel_G = 5;
                pixel_B = 0;
            end else if (Game_State == GameFinished) begin
                pixel_R = 5;
                pixel_G = 0;
                pixel_B = 0;
            end else begin
                pixel_R = 0;
                pixel_G = 0;
                pixel_B = 5;
            end
            // pixel_R = 0;
            // pixel_G = 0;
            // pixel_B = 0;
        end
    end
end

assign o_Red_Video = pixel_R;
assign o_Grn_Video = pixel_G;
assign o_Blu_Video = pixel_B;


endmodule