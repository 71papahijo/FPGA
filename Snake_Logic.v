// X Lenght = 10, Y length = 9

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

   
    reg [89:0] SnakeBody;
    reg [3:0] Head_X, Head_Y;
    reg [3:0] Tail_X, Tail_Y;
    reg [3:0] Tail2_X, Tail2_Y;
    reg [3:0] Food_X, Food_Y;

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
    assign w_Col_Count_Div = w_Col_Count[9:4];
    assign w_Row_Count_Div = w_Row_Count[9:4];


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



    always @(posedge i_Clk)
    begin
        case (Game_State)
            IDLE:
            begin
                if(Snake_Right)
                begin
                    Game_State <= RUNNING;
                    Snake_Dir <= DIR_RIGHT;
                    Head_X <= 4;
                    Head_Y <= 4;
                    Tail_X <= 2;
                    Tail_Y <= 4;
                    Tail2_X <= 3;
                    Tail2_Y <= 4;
                    Food_X <= 8;
                    Food_Y <= 4;
                    SnakeBody <= 90'b0;
                    SnakeBody[(Head_Y  * 10) + Head_X;] <= 1'b1; // prelaod snake
                    SnakeBody[(Tail_Y  * 10) + Tail_X]  <= 1'b1;
                    SnakeBody[(Tail2_Y * 10) + Tail2_X] <= 1'b1;

                end
            end
            RUNNING:
            begin
                if (o_Collision) begin
                    Game_State <= GameFinished;
                end

            end
            

        endcase   
    end


endmodule