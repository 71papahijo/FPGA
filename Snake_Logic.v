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

    // CHANGE: apple generator wires/regs + instance
    wire [2:0] next_Food_X;
    wire [2:0] next_Food_Y;
    reg        apple_reset;
    reg        apple_advance;

    Apple_Gen AppleGenInst (
        .i_Clk     (Game_Clk),
        .i_Reset   (apple_reset),
        .i_Advance (apple_advance),
        .o_Apple_X (next_Food_X),
        .o_Apple_Y (next_Food_Y)
    );
    // END CHANGE

    // Game States
    reg [1:0] Game_State = IDLE;
    parameter IDLE    = 2'b00;
    parameter RUNNING = 2'b01;
    parameter GameFinished = 2'b10;
    parameter CLEANUP = 2'b11;

    wire w_HSync, w_VSync;
    // wire [5:0] w_Col_Count_Div, w_Row_Count_Div;
    wire [9:0] w_Col_Count, w_Row_Count;

    // CHANGE  
    localparam integer CELL_W = c_ACTIVE_COLS / 7; // 640/7 ≈ 91
    localparam integer CELL_H = c_ACTIVE_ROWS / 6; // 480/6 = 80
    //END


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
    integer i;

    reg [3:0] new_Head_X, new_Head_Y;
    reg wallCollision;
    reg[5:0] tail_index;
    reg[5:0] new_head_index;
    reg[5:0] index;
    reg eaten;


        always @(posedge Game_Clk) begin
        // CHANGE: default apple control signals each tick
        apple_reset   <= 1'b0;
        apple_advance <= 1'b0;
        // END CHANGE

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

                    // CHANGE: use apple FSM for first apple
                    apple_reset <= 1'b1;       // reset FSM to state 0
                    Food_X      <= next_Food_X;
                    Food_Y      <= next_Food_Y;
                    // END CHANGE

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
                    // DIR_UP:    if (Head_Y==0) wallCollision=1; else new_Head_Y = Head_Y-1;
                    // DIR_DOWN:  if (Head_Y==5) wallCollision=1; else new_Head_Y = Head_Y+1;
                    // DIR_LEFT:  if (Head_X==0) wallCollision=1; else new_Head_X = Head_X-1;
                    // DIR_RIGHT: if (Head_X==6) wallCollision=1; else new_Head_X = Head_X+1;
                    DIR_UP:    if (Head_Y==0) new_Head_Y = 5; else new_Head_Y = Head_Y-1;
                    DIR_DOWN:  if (Head_Y==5) new_Head_Y = 0; else new_Head_Y = Head_Y+1;
                    DIR_LEFT:  if (Head_X==0) new_Head_X = 6; else new_Head_X = Head_X-1;
                    DIR_RIGHT: if (Head_X==6) new_Head_X = 0; else new_Head_X = Head_X+1;
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
                    eaten = (new_head_index == Food_Y*7 + Food_X);

                    // self collision
                    if (SnakeBody[new_head_index] == 1'b1) begin
                        o_Collision <= 1;
                        Game_State <= GameFinished;
                    end else begin
                        if (eaten) begin
                            SnakeIndexs[SnakeLength] <= new_head_index;
                            SnakeLength <= SnakeLength + 1;
                            if(SnakeLength == 20) begin
                                // max length reached
                                Game_State <= GameFinished;
                            end

                            SnakeBody[new_head_index] <= 1'b1;

                            // CHANGE: advance apple when eaten
                            apple_advance <= 1'b1;
                            // END CHANGE

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
                if (apple_advance) begin
                    Food_X <= next_Food_X;
                    Food_Y <= next_Food_Y;
                    apple_advance <= 0;
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
// CHANGE
// Each visible pixel belongs to one "cell" in the 7x6 grid
reg [2:0] cell_X;
reg [2:0] cell_Y;

// Map pixel coordinates to grid cell using simple compares
always @* begin
    // X direction (7 columns)
    if      (w_Col_Count < CELL_W*1) cell_X = 3'd0;
    else if (w_Col_Count < CELL_W*2) cell_X = 3'd1;
    else if (w_Col_Count < CELL_W*3) cell_X = 3'd2;
    else if (w_Col_Count < CELL_W*4) cell_X = 3'd3;
    else if (w_Col_Count < CELL_W*5) cell_X = 3'd4;
    else if (w_Col_Count < CELL_W*6) cell_X = 3'd5;
    else if (w_Col_Count < CELL_W*7) cell_X = 3'd6;
    else                             cell_X = 3'd0; // outside active area

    // Y direction (6 rows)
    if      (w_Row_Count < CELL_H*1) cell_Y = 3'd0;
    else if (w_Row_Count < CELL_H*2) cell_Y = 3'd1;
    else if (w_Row_Count < CELL_H*3) cell_Y = 3'd2;
    else if (w_Row_Count < CELL_H*4) cell_Y = 3'd3;
    else if (w_Row_Count < CELL_H*5) cell_Y = 3'd4;
    else if (w_Row_Count < CELL_H*6) cell_Y = 3'd5;
    else                             cell_Y = 3'd0; // outside active area
end

wire [6:0] pixel_index = cell_Y * 7 + cell_X;

//END CHANGE

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