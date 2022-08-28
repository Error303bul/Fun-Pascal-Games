program Minesweeper;

uses GraphABC;


//Важные типы
type
  tline = array of integer;
  matrix = array of tline;
  cords = array[0..1] of integer;

const
  fps = 50;
  fieldX = 50;
  fieldY = 50;

var
  bgcolor: Color;

var
  sizeX, sizeY: integer;

var
  width, height, tileSize, bombCount: integer;

var
  field, shown: matrix;

var
  mouseLeftPressed, mouseRightPressed, mouseLeftClicked, mouseRightClicked: boolean;
  mouseX, mouseY: integer;

var
  BPressed, RPressed, CPressed: boolean;

var
  genseed: integer;

procedure KeyUp(key: integer);
begin
  if(key = VK_B) then begin
    BPressed := false;
  end;
  if(key = VK_R) then begin
    RPressed := false;
  end;
  if(key = VK_C) then begin
    CPressed := false;
  end;
end;

procedure KeyDown(key: integer);
begin
  if(key = VK_B) then begin
    BPressed := true;
  end;
  if(key = VK_R) then begin
    RPressed := true;
  end;
  if(key = VK_C) then begin
    CPressed := true;
  end;
end;

procedure MouseDown(x, y, mousebutton: integer);
begin
  if(mousebutton = 1) then begin
    mouseLeftClicked := not mouseLeftPressed;
    mouseLeftPressed := true;
  end;
  if(mousebutton = 2) then begin
    mouseRightClicked := not mouseRightPressed;
    mouseRightPressed := true;
  end;
end;

procedure MouseUp(x, y, mousebutton: integer);
begin
  if(mousebutton = 1) then begin
    mouseLeftPressed := false;
    mouseLeftClicked := false;
  end;
  if(mousebutton = 2) then begin
    mouseRightPressed := false;
    mouseRightClicked := false;
  end;
end;

procedure MouseMove(x, y, mousebutton: integer);
begin
  mouseX := x;
  mouseY := y;
end;

///Возвращает число бомб рядом с клеткой кординаты x и y
function nearbyBombs(x, y: integer): integer;
var
  canFind: array[0..7] of boolean;
var
  i, res: integer;
begin
  for i := 0 to 7 do
  begin
    canFind[i] := false;
  end;
  res := 0;
  if(x > 0) then begin
    canFind[0] := true;
    if(field[x - 1][y] = 1) then begin
      res := res + 1;
    end;
  end;
  if(x < width - 1) then begin
    canFind[1] := true;
    if(field[x + 1][y] = 1) then begin
      res := res + 1;
    end;
  end;
  if(y > 0) then begin
    canFind[2] := true;
    if(field[x][y - 1] = 1) then begin
      res := res + 1;
    end;
  end;
  if(y < height - 1) then begin
    canFind[3] := true;
    if(field[x][y + 1] = 1) then begin
      res := res + 1;
    end;
  end;
  if(canFind[0] and canFind[2]) then begin
    canFind[4] := true;
    if(field[x - 1][y - 1] = 1) then begin
      res := res + 1;
    end;
  end;
  if(canFind[1] and canFind[3]) then begin
    canFind[5] := true;
    if(field[x + 1][y + 1] = 1) then begin
      res := res + 1;
    end;
  end;
  if(canFind[0] and canFind[3]) then begin
    canFind[6] := true;
    if(field[x - 1][y + 1] = 1) then begin
      res := res + 1;
    end;
  end;
  if(canFind[1] and canFind[2]) then begin
    canFind[7] := true;
    if(field[x + 1][y - 1] = 1) then begin
      res := res + 1;
    end;
  end;
  if(field[x][y] = 1) then begin
    res := 9;
  end;
  nearbyBombs := res;
end;

///Генерирует псевдо рандомное число
function prand(min, max, seed: integer): integer;
var
  res: integer;
begin
  res := (seed mod (max - min + 1)) + min + 1;
  prand := res;
end;

///Даёт случаное число между min и max включительно
function rand(min, max: integer): integer;
begin
  rand := Random(max - min + 1) + min;
end;

function randCords(tile: integer): cords;
var
  res: cords;
begin
  res[0] := rand(0, width - 1);
  res[1] := rand(0, height - 1);
  if(field[res[0]][res[1]] = tile) then begin
    randCords := res;
  end else begin
    randCords := randCords(tile);
  end;
end;

///Создаёт карту взависимости от сида
function randGeneration(seed: integer): matrix;
var
  x, y, i, id, repeation: integer;
  gen: matrix;
begin
  SetLength(gen, width);
  x := 0;
  repeat
    SetLength(gen[x], height);
    y := 0;
    repeat
      gen[x][y] := 0;
      y := y + 1;
    until y = height;
    x := x + 1;
  until x = width;
  for i := 1 to bombCount do
  begin
    id := prand(0, (width * height), seed + (i * i * i{*bombCount}));
    x := (Round(id / width) mod width);
    y := (id mod height);
    gen[x][y] := 1;
  end;
  randGeneration := gen;
end;

///Возвращает true если победа
function checkWin(): boolean;
var
  x, y, res,flags: integer;
begin
  res := 0;
  flags:=0;
  for x := 0 to width - 1 do
  begin
    for y := 0 to height - 1 do
    begin
      if(field[x][y] = 1) then begin
        if(shown[x][y] = 2) then begin
          res := res + 1;
        end;
      end;
      if(shown[x][y] = 2) then begin
          flags := flags + 1;
        end;
    end;
  end;
  if((res = bombCount) and (flags=bombCount)) then begin
    checkWin := true;
  end else begin
    checkWin := false;
  end;
end;

///Открывает все клетки возле x y
procedure openNearby(x, y: integer);
var
  canFind: array[0..7] of boolean;
var
  i: integer;
begin
  for i := 0 to 7 do
  begin
    canFind[i] := false;
  end;
  if(x > 0) then begin
    canFind[0] := true;
    shown[x - 1][y] := 1;
  end;
  if(x < width - 1) then begin
    canFind[1] := true;
    shown[x + 1][y] := 1;
  end;
  if(y > 0) then begin
    canFind[2] := true;
    shown[x][y - 1] := 1;
  end;
  if(y < height - 1) then begin
    canFind[3] := true;
    shown[x][y + 1] := 1;
  end;
  if(canFind[0] and canFind[2]) then begin
    canFind[4] := true;
    shown[x - 1][y - 1] := 1;
  end;
  if(canFind[1] and canFind[3]) then begin
    canFind[5] := true;
    shown[x + 1][y + 1] := 1;
  end;
  if(canFind[0] and canFind[3]) then begin
    canFind[6] := true;
    shown[x - 1][y + 1] := 1;
  end;
  if(canFind[1] and canFind[2]) then begin
    canFind[7] := true;
    shown[x + 1][y - 1] := 1;
  end;
end;

///Открывает все клетки рядом с которыми нет бомб
procedure openAllBlank();
var
  x, y: integer;
begin
  for x := 0 to width - 1 do
  begin
    for y := 0 to height - 1 do
    begin
      if(nearbyBombs(x, y) = 0) then begin
        shown[x][y] := 1;
        openNearby(x, y);
      end;
    end;
  end;
end;

///Перерисовывает игру задавая размеры
procedure makeField();
var
  x, y: integer;
begin
  SetLength(field, width);
  SetLength(shown, width);
  x := 0;
  repeat
    SetLength(field[x], height);
    SetLength(shown[x], height);
    y := 0;
    repeat
      field[x][y] := 0;
      shown[x][y] := 0;
      y := y + 1;
    until y = height;
    x := x + 1;
  until x = width;
  genseed := rand(100000, 999999);
  field := randGeneration(genseed);
  openAllBlank();
end;

///Возвращает кординаты клетки в матрице с кординатами в окне x и y в виде массива. Возвращает массив из -1 если клетку получить не удалось
function getTileId(x, y: integer): cords;
var
  tile: cords;
begin
  if((x > fieldX - 1) and (x < (tileSize * width) + fieldX + 1)) then begin
    if((y > fieldY - 1) and (y < (tileSize * height) + fieldY + 1)) then begin
      tile[0] := Round((x - fieldX + 1) / tileSize);
      tile[1] := Round((y - fieldY + 1) / tileSize);
    end else begin
      tile[0] := -1;
      tile[1] := -1;
    end;
  end else begin
    tile[0] := -1;
    tile[1] := -1;
  end;
  getTileId := tile;
end;

function checkOver(): boolean;
var
  x, y: integer;
begin
  for x := 0 to width - 1 do
  begin
    for y := 0 to height - 1 do
    begin
      if((shown[x][y] = 1) and (field[x][y] = 1)) then begin
        checkOver := true;
      end;
    end;
  end;
end;

///Получает клетку с кординатами x и y. Возвращает -1 если не удалось получить клетку
function getTile(x, y: integer): integer;
var
  tile: cords;
begin
  tile := getTileId(x, y);
  if((tile[0] > -1) and (tile[1] > -1) and (tile[0] < width) and (tile[1] < height)) then begin
    getTile := field[tile[0]][tile[1]];
  end else begin
    getTile := -1;
  end;
end;

///Контролирует всю игру
procedure logic();
var
  tile: cords;
begin
  if(not (checkOver() or checkWin())) then begin
    tile := getTileId(mouseX, mouseY);
    if(getTile(mouseX, mouseY) > -1) then begin
      if(mouseLeftClicked) then begin
        if(shown[tile[0]][tile[1]] = 0) then begin
          shown[tile[0]][tile[1]] := 1;
        end;
      end else begin
        if(mouseRightClicked) then begin
          if(shown[tile[0]][tile[1]] = 0) then begin
            shown[tile[0]][tile[1]] := 2;
          end;
        end else begin
          if(BPressed) then begin
            if(shown[tile[0]][tile[1]] = 2) then begin
              shown[tile[0]][tile[1]] := 0;
            end;
          end;
        end;
      end;
    end;
  end;
  if(RPressed) then begin
    makeField();
    Sleep(500);
  end;
end;

///Рисует рамку квадрата
procedure square(x1, y1, width, height: integer);
begin
  Line(x1, y1, x1 + width, y1);
  Line(x1, y1, x1, y1 + height);
  Line(x1 + width, y1, x1 + width, y1 + height);
  Line(x1, y1 + height, x1 + width, y1 + height);
end;

///Устанавливает цвет для текста взависимости от числа
procedure SetFontColorByNumber(itn: integer);
begin
  if(itn > 0) then begin
    if(itn = 1) then begin
      SetFontColor(Color.Black);
    end else begin
      if(itn = 2) then begin
        SetFontColor(Color.DarkCyan);
      end else begin
        if(itn = 3) then begin
          SetFontColor(Color.Blue);
        end else begin
          if(itn = 4) then begin
            SetFontColor(Color.DarkBlue);
          end else begin
            if(itn = 5) then begin
              SetFontColor(Color.Green);
            end else begin
              if(itn = 6) then begin
                SetFontColor(Color.Pink);
              end else begin
                if(itn = 7) then begin
                  SetFontColor(Color.Orange);
                end else begin
                  SetFontColor(Color.Red);
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

///Рисует всю игру
procedure draw();
var
  x, y: integer;
begin
  SetBrushColor(bgcolor);
  FillRect(0, 0, sizeX, sizeY);
  x := 0;
  repeat
    y := 0;
    SetBrushColor(Color.Red);
    repeat
      if(((shown[x][y] <> 1) and (not checkOver()))) then begin
        SetBrushColor(clGreen);
        FillRect(x * tileSize + fieldX, y * tileSize + fieldY, (x + 1) * tileSize + fieldX, (y + 1) * tileSize + fieldY);
        SetPenColor(Color.Black);
        SetPenWidth(3);
        square(x * tileSize + fieldX, y * tileSize + fieldY, tileSize, tileSize);
        if(shown[x][y] = 2) then begin
          SetPenColor(Color.Red);
          SetPenWidth(3);
          Line(x * tileSize + fieldX, y * tileSize + fieldY, (x + 1) * tileSize + fieldX, (y + 1) * tileSize + fieldY);
          Line((x + 1) * tileSize + fieldX, y * tileSize + fieldY, x * tileSize + fieldX, (y + 1) * tileSize + fieldY);
        end;
        if((getTileId(mouseX, mouseY)[0] = x) and (getTileId(mouseX, mouseY)[1] = y)) then begin
          SetBrushColor(Color.Black);
          DrawCircle(x * tileSize + fieldX + Round(tileSize / 2), y * tileSize + fieldY + Round(tileSize / 2), Round(tileSize / 6));
        end;
      end else begin
        SetBrushColor(clYellow);
        FillRect(x * tileSize + fieldX, y * tileSize + fieldY, (x + 1) * tileSize + fieldX, (y + 1) * tileSize + fieldY);
        if(field[x][y] = 1) then begin
          SetBrushColor(Color.Black);
          FillCircle((x * tileSize) + Round(tileSize / 2) + fieldX, (y * tileSize) + Round(tileSize / 2) + fieldY, Round(tileSize / 2));
        end else begin
          if(nearbyBombs(x, y) > 0) then begin
            SetFontColorByNumber(nearbyBombs(x, y));
            DrawTextCentered((x * tileSize) + Round(tileSize / 2) + fieldX, (y * tileSize) + Round(tileSize / 2) + fieldY, nearbyBombs(x, y));
          end;
        end;
      end;
      y := y + 1;
    until y = height;
    x := x + 1;
  until x = width;
  SetFontColor(Color.Black);
  if(checkOver()) then begin
    DrawTextCentered((width + 1) * tileSize + fieldX, tileSize + fieldY, 'Игра окончена');
  end else begin
    if(checkWin()) then begin
      DrawTextCentered((width + 1) * tileSize + fieldX, tileSize + fieldY, 'Победа!');
    end else begin
      DrawTextCentered((width + 1) * tileSize + fieldX, tileSize + fieldY, getTileId(mouseX, mouseY)[0]);
      DrawTextCentered((width + 1) * tileSize + fieldX, tileSize * 2 + fieldY, getTileId(mouseX, mouseY)[1]);
      DrawTextCentered((width + 1) * tileSize + fieldX, tileSize * 3 + fieldY, genseed);
    end;
  end;
  DrawTextCentered((width + 1) * tileSize + fieldX, tileSize * 4 + fieldY, 'R для рестарта');
  Redraw;
  LockDrawing;
end;

begin
  tileSize := 60;
  width := 10;
  height := 10;
  bombCount := 10;
  makeField();
  bgcolor := clWhite;
  OnMouseDown := MouseDown;
  OnMouseMove := MouseMove;
  OnMouseUp := MouseUp;
  OnKeyDown := KeyDown;
  OnKeyUp := KeyUp;
  while true do
  begin
    sizeX := WindowWidth();
    sizeY := WindowHeight();
    logic();
    draw();
    Sleep(Round(1000 / fps));
  end;
end.