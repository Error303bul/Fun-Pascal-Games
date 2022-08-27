program TikTakToe;

uses GraphABC;

type
  tile = integer;// 0-Ничего 1-X 2-O
  row = array of tile;
  grid = array of row;
  cords = array[0..1] of integer; //Специально для работы с кординатами

const
  fps = 20;
  blank = 0;
  xtile = 1;
  otile = 2;
  tileSize = 50;

var
  frame, timeSleep, sizeX, sizeY, fieldWidth, fieldHeight: integer;

var
  fieldX, fieldY, mouseX, mouseY: integer;

var
  bgcolor: Color;

var
  field: grid;

var
  xturn, mousePressed, rpressed: boolean;

procedure KeyDown(key: integer);
begin
  if(key = VK_R) then begin
    rpressed := true;
  end;
end;

procedure KeyUp(key: integer);
begin
  if(key = VK_R) then begin
    rpressed := false;
  end;
end;

function getTileId(x, y: integer): cords;
var
  tileId: cords;
begin
  if((x > fieldX - 1) and (x < fieldX + fieldWidth * tileSize)) then begin
    if((y > fieldY - 1) and (y < fieldY + fieldHeight * tileSize)) then begin
      tileId[0] := Round((x - fieldX) / tileSize);
      tileId[1] := Round((y - fieldY) / tileSize);
    end else begin
      tileId[0] := -1;
      tileId[1] := -1;
    end;
  end else begin
    tileId[0] := -1;
    tileId[1] := -1;
  end;
  getTileId := tileId;
end;

function getTile(x, y: integer): integer;
var
  tileId: cords;
begin
  tileId := getTileId(x, y);
  if(tileId[0] > -1) then begin
    if(tileId[1] > -1) then begin
      if(tileId[0] < fieldWidth) then begin
        if(tileId[1] < fieldHeight) then begin
          getTile := field[tileId[1]][tileId[0]];
        end else begin
          getTile := -1;
        end;
      end else begin
        getTile := -1;
      end;
    end else begin
      getTile := -1;
    end;
  end else begin
    getTile := -1
  end;
end;

procedure MouseDown(x, y, mousebutton: integer);
begin
  mousePressed := true;
end;

procedure MouseUp(x, y, mousebutton: integer);
begin
  mousePressed := false;
end;

procedure MouseMove(x, y, mousebutton: integer);
begin
  mouseX := x;
  mouseY := y;
end;
//Создает новое поле размерами width и height
procedure resetField(width: integer; height: integer);
var
  rowid, tileid: integer;
begin
  xturn := true;
  fieldWidth := width;
  fieldHeight := height;
  SetLength(field, fieldHeight);
  for rowid := 0 to fieldHeight - 1 do
  begin
    SetLength(field[rowid], fieldWidth);
    for tileid := 0 to fieldWidth - 1 do
    begin
      field[rowid][tileid] := blank;
    end;
  end;
end;
//Рисует незаполненный квадрат
procedure square(x1, y1, width, height: integer);
begin
  Line(x1, y1, x1 + width, y1);
  Line(x1, y1, x1, y1 + height);
  Line(x1 + width, y1, x1 + width, y1 + height);
  Line(x1, y1 + height, x1 + width, y1 + height);
end;
//Возвращает либо true либо false
function randBool(): boolean;
begin
  if(Random(2) = 1) then begin
    randBool := true;
  end else begin
    randBool := false;
  end;
end;

procedure move();
var
  tile: cords;
begin
  if(getTile(mouseX, mouseY) <> -1) then begin
    tile := getTileId(mouseX, mouseY);
    if(field[tile[1]][tile[0]] = blank) then begin
      if(xturn) then begin
        field[tile[1]][tile[0]] := xtile;
        xturn := false;
      end else begin
        field[tile[1]][tile[0]] := otile;
        xturn := true;
      end;
    end;
  end;
end;

function checkTileForWin(tile: integer): integer;
var
  temp, res, line: integer;
begin
  for line := 0 to fieldHeight - 1 do
  begin
    res := 0;
    for temp := 0 to fieldWidth - 1 do
    begin
      if(field[line][temp] = tile) then begin
        res := res + 1;
      end;
    end;
    if(res = fieldWidth) then begin
      checkTileForWin := tile;
    end;
  end;
  for line := 0 to fieldWidth - 1 do
  begin
    res := 0;
    for temp := 0 to fieldHeight - 1 do
    begin
      if(field[temp][line] = tile) then begin
        res := res + 1;
      end;
    end;
    if(res = fieldHeight) then begin
      checkTileForWin := tile;
    end;
  end;
  res := 0;
  for temp := 0 to fieldHeight - 1 do
  begin
    if(field[temp][temp] = tile) then begin
      res := res + 1;
    end;
  end;
  if(res = fieldHeight) then begin
    checkTileForWin := tile;
  end;
  res := 0;
  for temp := 0 to fieldHeight - 1 do
  begin
    if(field[fieldHeight - 1 - temp][fieldWidth - 1 - temp] = tile) then begin
      res := res + 1;
    end;
  end;
  if(res = fieldHeight) then begin
    checkTileForWin := tile;
  end;
end;

function checkWin(): integer;
begin
  if(checkTileForWin(xtile) > 0) then begin
    checkWin := checkTileForWin(xtile);
  end else begin
    if(checkTileForWin(otile) > 0) then begin
      checkWin := checkTileForWin(otile);
    end else begin
      checkWin := 0;
    end;
  end;
end;

procedure logic();
var
  tile: cords;
begin
  if(rpressed) then begin
    resetField(3, 3);
  end else begin
    {0-nobody win,1-x win,2-o win}
    if(checkWin() = 0) then begin
      if(mousePressed) then begin
        move();
      end;
    end;
  end;
end;

procedure draw();
var
  row, col: integer;
begin
  SetBrushColor(clBlack);
  
  row := 0;
  repeat
    col := 0;
    repeat
      square(fieldX + (col * tileSize), fieldY + (row * tileSize), tileSize, tileSize);
      if(field[row][col] <> blank) then begin
        if(field[row][col] = xtile) then begin
          Line(fieldX + (col * tileSize), fieldY + (row * tileSize), fieldX + ((col + 1) * tileSize), fieldY + ((row + 1) * tileSize));
          Line(fieldX + ((1 + col) * tileSize), fieldY + (row * tileSize), fieldX + (col * tileSize), fieldY + ((row + 1) * tileSize));
        end else begin
          DrawEllipse(fieldX + (col * tileSize), fieldY + (row * tileSize), fieldX + ((col + 1) * tileSize), fieldY + ((row + 1) * tileSize));
        end;
      end;
      col := col + 1;
    until col >= fieldWidth;
    row := row + 1;
  until row >= fieldHeight;
  if(checkWin() > 0) then begin
    if(checkWin() = 1) then begin
      DrawTextCentered(fieldX + (tileSize * (fieldWidth + 1)), fieldY + (tileSize * (fieldHeight + 1)), 'Победили крестики');
    end else begin
      DrawTextCentered(fieldX + (tileSize * (fieldWidth + 1)), fieldY + (tileSize * (fieldHeight + 1)), 'Победили нолики');
    end;
  end else begin
    if(xturn) then begin
      DrawTextCentered(fieldX + (tileSize * (fieldWidth + 1)), fieldY + (tileSize * (fieldHeight + 1)), 'Ходят крестики');
    end else begin
      DrawTextCentered(fieldX + (tileSize * (fieldWidth + 1)), fieldY + (tileSize * (fieldHeight + 1)), 'Ходят нолики');
    end;
  end;
  DrawTextCentered(fieldX + (tileSize * (fieldWidth + 1)), fieldY + (tileSize * (fieldHeight + 2)), 'R для рестарта');
  Redraw;
  LockDrawing;
end;

begin
  fieldX := 50;
  fieldY := 50;
  bgcolor := clWhite;
  frame := 0;
  timeSleep := Round(1000 / fps);
  resetField(3, 3);
  OnMouseDown := MouseDown;
  OnMouseUp := MouseUp;
  OnMouseMove := MouseMove;
  OnKeyDown := KeyDown;
  OnKeyUp := KeyUp;
  while true do
  begin
    sizeX := WindowWidth();
    sizeY := WindowHeight();
    setbrushcolor(bgcolor);
    fillrectangle(0, 0, sizeX, sizeY);
    draw();
    logic();
    frame := frame + 1;
    Sleep(timeSleep);
  end
end.
