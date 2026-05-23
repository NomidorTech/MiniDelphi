unit UGraphics;

// =============================================================================
// Pythia -- ambiente de aprendizado Pascal
// Copyright (C) 2026 Nomidor Software, LLC.
// GPL v3 — veja https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
//
//  UGraphics.pas  -  Janela de animação 2D para o Pythia
//
//  Como funciona:
//    O interpretador roda na thread principal (mesma que a VCL).
//    Usamos InvalidateRect + UpdateWindow para pintar de forma síncrona,
//    forçando um WM_PAINT imediato antes de retornar.
//
//  Eventos de mouse são registrados tanto no formulário quanto no painel
//  filho (TGfxPanel) para garantir que cliques na área de desenho sejam
//  capturados corretamente.
// =============================================================================

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Math,
  Vcl.Controls, Vcl.Forms, Vcl.Graphics, Vcl.ExtCtrls,
  System.UITypes;

const
  WM_GFX_SHOW = WM_USER + 100;

type
  // Painel de desenho — possui o bitmap e trata WM_PAINT via BitBlt
  TGfxPanel = class(TWinControl)
  private
    FBitmap : TBitmap;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property    Bitmap : TBitmap read FBitmap;
  end;

  // Janela gráfica principal
  TGfxWindow = class(TForm)
  private
    FPanel     : TGfxPanel;     // superfície de desenho
    FKeyQueue  : TStringList;   // fila de teclas pressionadas
    FRunning   : Boolean;       // janela ainda aberta?
    FMouseX    : Integer;       // posição X do mouse
    FMouseY    : Integer;       // posição Y do mouse
    FMouseDown : Boolean;       // botão do mouse pressionado?
    FCurColor  : TColor;        // cor atual de desenho
    FPenWidth  : Integer;       // largura da caneta
    FW, FH     : Integer;       // largura e altura em pixels

    procedure OnClose2(Sender: TObject; var Action: TCloseAction);
    procedure OnMMove (Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure OnMDown (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnMUp   (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnKDown (Sender: TObject; var Key: Word; Shift: TShiftState);

    function  NameToColor(const N: string): TColor;
    function  C: TCanvas; inline;
  public
    constructor CreateGfx(W, H: Integer; const Title: string);
    destructor  Destroy; override;

    procedure GfxClear       (const ColorName: string);
    procedure GfxColor       (const ColorName: string);
    procedure GfxPenWidth    (N: Integer);
    procedure GfxDrawLine    (X1, Y1, X2, Y2: Integer);
    procedure GfxDrawRect    (X, Y, W, H: Integer);
    procedure GfxFillRect    (X, Y, W, H: Integer);
    procedure GfxDrawCircle  (X, Y, R: Integer);
    procedure GfxFillCircle  (X, Y, R: Integer);
    procedure GfxDrawEllipse (X, Y, RX, RY: Integer);
    procedure GfxFillEllipse (X, Y, RX, RY: Integer);
    procedure GfxDrawText    (X, Y: Integer; const Text: string);
    procedure GfxSetFont     (Size: Integer; Bold: Boolean);
    procedure GfxDrawPixel   (X, Y: Integer);
    procedure GfxShow;

    function  GfxKeyPressed: Boolean;
    function  GfxReadKey: string;

    property Running   : Boolean read FRunning;
    property MouseX    : Integer read FMouseX;
    property MouseY    : Integer read FMouseY;
    property MouseDown : Boolean read FMouseDown;
  end;

var
  GfxWin : TGfxWindow = nil;

procedure GfxOpenWindow (W, H: Integer; const Title: string);
procedure GfxCloseWindow;

// =============================================================================
implementation
// =============================================================================

// ---------------------------------------------------------------------------
//  TGfxPanel — painel de desenho com bitmap duplo-buffer
// ---------------------------------------------------------------------------
constructor TGfxPanel.Create(AOwner: TComponent);
begin
  inherited;
  FBitmap := TBitmap.Create;
end;

destructor TGfxPanel.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

// Suprime o apagamento do fundo para evitar piscar
procedure TGfxPanel.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

// Pinta o painel copiando o bitmap via BitBlt
procedure TGfxPanel.WMPaint(var Msg: TWMPaint);
var
  PS : TPaintStruct;
  DC : HDC;
begin
  DC := BeginPaint(Handle, PS);
  try
    try
      if Assigned(FBitmap) and (FBitmap.Width > 0) then
        BitBlt(DC, 0, 0, FBitmap.Width, FBitmap.Height,
               FBitmap.Canvas.Handle, 0, 0, SRCCOPY);
    except
      // Ignora erros de pintura após destruição da janela
    end;
  finally
    EndPaint(Handle, PS);
  end;
end;

// ---------------------------------------------------------------------------
//  Tabela de cores nomeadas
// ---------------------------------------------------------------------------
function TGfxWindow.NameToColor(const N: string): TColor;
var
  S       : string;
  R, G, B : Integer;
begin
  S := LowerCase(Trim(N));
  if      S = 'black'     then Result := clBlack
  else if S = 'white'     then Result := clWhite
  else if S = 'red'       then Result := clRed
  else if S = 'green'     then Result := RGB(0, 170, 0)
  else if S = 'lime'      then Result := clLime
  else if S = 'blue'      then Result := clBlue
  else if S = 'yellow'    then Result := clYellow
  else if S = 'orange'    then Result := RGB(255, 128, 0)
  else if S = 'purple'    then Result := RGB(128, 0, 128)
  else if S = 'cyan'      then Result := clAqua
  else if S = 'aqua'      then Result := clAqua
  else if S = 'magenta'   then Result := clFuchsia
  else if S = 'pink'      then Result := RGB(255, 128, 255)
  else if S = 'hotpink'   then Result := RGB(255, 69, 180)
  else if S = 'brown'     then Result := RGB(139, 69, 19)
  else if S = 'grey'      then Result := clGray
  else if S = 'gray'      then Result := clGray
  else if S = 'silver'    then Result := clSilver
  else if S = 'gold'      then Result := RGB(255, 215, 0)
  else if S = 'navy'      then Result := clNavy
  else if S = 'teal'      then Result := clTeal
  else if S = 'maroon'    then Result := clMaroon
  else if S = 'olive'     then Result := clOlive
  else if S = 'darkblue'  then Result := clNavy
  else if S = 'darkgreen' then Result := RGB(0, 100, 0)
  else if S = 'darkred'   then Result := clMaroon
  else if S = 'skyblue'   then Result := RGB(135, 206, 235)
  else
  begin
    // Tenta interpretar como cor hexadecimal #RRGGBB
    if (Length(S) = 7) and (S[1] = '#') then
    try
      R := StrToInt('$' + Copy(S, 2, 2));
      G := StrToInt('$' + Copy(S, 4, 2));
      B := StrToInt('$' + Copy(S, 6, 2));
      Result := RGB(R, G, B);
      Exit;
    except end;
    Result := clWhite;  // cor padrão se não reconhecida
  end;
end;

// Atalho para o canvas do bitmap
function TGfxWindow.C: TCanvas;
begin
  Result := FPanel.Bitmap.Canvas;
end;

// ---------------------------------------------------------------------------
//  Construtor da janela gráfica
// ---------------------------------------------------------------------------
constructor TGfxWindow.CreateGfx(W, H: Integer; const Title: string);
var
  ExW, ExH : Integer;
begin
  inherited CreateNew(nil);

  FW := W;  FH := H;

  // Ajusta tamanho considerando bordas e barra de título
  ExW    := Width  - ClientWidth;
  ExH    := Height - ClientHeight;
  Width  := W + ExW;
  Height := H + ExH;

  Caption     := Title;
  BorderStyle := bsSingle;
  Position    := poScreenCenter;
  KeyPreview  := True;   // o formulário recebe teclas antes dos filhos
  Color       := clBlack;

  // Eventos do formulário
  OnClose    := OnClose2;
  OnMouseMove:= OnMMove;
  OnMouseDown:= OnMDown;
  OnMouseUp  := OnMUp;
  OnKeyDown  := OnKDown;

  // Cria o painel de desenho
  FPanel             := TGfxPanel.Create(Self);
  FPanel.Parent      := Self;
  FPanel.SetBounds(0, 0, W, H);
  FPanel.Align       := alClient;

  // Registra eventos de mouse no painel também
  // (cliques no painel não sobem automaticamente para o formulário)
  FPanel.OnMouseMove := OnMMove;
  FPanel.OnMouseDown := OnMDown;
  FPanel.OnMouseUp   := OnMUp;

  // Configura o bitmap de desenho
  FPanel.Bitmap.PixelFormat := pf32bit;
  FPanel.Bitmap.Width       := W;
  FPanel.Bitmap.Height      := H;
  FPanel.Bitmap.Canvas.Brush.Color := clBlack;
  FPanel.Bitmap.Canvas.FillRect(Rect(0, 0, W, H));

  FKeyQueue  := TStringList.Create;
  FRunning   := True;
  FPenWidth  := 1;
  FCurColor  := clWhite;

  // Configurações iniciais do canvas
  C.Pen.Color   := clWhite;
  C.Pen.Width   := 1;
  C.Brush.Style := bsClear;
  C.Font.Color  := clWhite;
  C.Font.Size   := 12;
  C.Font.Name   := 'Segoe UI';

  Show;
  SetFocus;   // captura foco do teclado imediatamente
  Application.ProcessMessages;
end;

destructor TGfxWindow.Destroy;
begin
  FKeyQueue.Free;
  inherited;
end;

// ---------------------------------------------------------------------------
//  Tratadores de eventos
// ---------------------------------------------------------------------------

procedure TGfxWindow.OnClose2(Sender: TObject; var Action: TCloseAction);
begin
  FRunning := False;
  Action   := caHide;
end;

procedure TGfxWindow.OnMMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  FMouseX := X;
  FMouseY := Y;
end;

procedure TGfxWindow.OnMDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FMouseDown := True;
  FMouseX    := X;
  FMouseY    := Y;
  // Recupera o foco ao clicar (outra janela pode ter roubado)
  if not Self.Focused then SetFocus;
end;

procedure TGfxWindow.OnMUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FMouseDown := False;
end;

procedure TGfxWindow.OnKDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  S : string;
begin
  S := '';
  case Key of
    VK_LEFT  : S := 'LEFT';    // seta esquerda
    VK_RIGHT : S := 'RIGHT';   // seta direita
    VK_UP    : S := 'UP';      // seta cima
    VK_DOWN  : S := 'DOWN';    // seta baixo
    VK_ESCAPE: S := 'ESC';     // escape
    VK_SPACE : S := 'SPACE';   // espaço
    VK_RETURN: S := 'ENTER';   // enter
    VK_BACK  : S := 'BACK';    // retrocesso (backspace)
    VK_DELETE: S := 'DEL';     // delete
  else
    if (Key >= Ord('A')) and (Key <= Ord('Z')) then S := Chr(Key)
    else if (Key >= Ord('0')) and (Key <= Ord('9')) then S := Chr(Key)
    else S := '';
  end;
  if S <> '' then FKeyQueue.Add(S);
end;

// ---------------------------------------------------------------------------
//  Primitivas de desenho
// ---------------------------------------------------------------------------

procedure TGfxWindow.GfxClear(const ColorName: string);
var Clr : TColor;
begin
  Clr := NameToColor(ColorName);
  C.Brush.Color := Clr;
  C.Brush.Style := bsSolid;
  C.Pen.Color   := Clr;
  C.FillRect(Rect(0, 0, FW, FH));
  C.Pen.Color   := FCurColor;
  C.Brush.Color := FCurColor;
end;

procedure TGfxWindow.GfxColor(const ColorName: string);
begin
  FCurColor     := NameToColor(ColorName);
  C.Pen.Color   := FCurColor;
  C.Brush.Color := FCurColor;
  C.Font.Color  := FCurColor;
end;

procedure TGfxWindow.GfxPenWidth(N: Integer);
begin
  FPenWidth   := N;
  C.Pen.Width := N;
end;

procedure TGfxWindow.GfxDrawLine(X1, Y1, X2, Y2: Integer);
begin
  C.Pen.Color := FCurColor;
  C.Pen.Width := FPenWidth;
  C.MoveTo(X1, Y1);
  C.LineTo(X2, Y2);
end;

procedure TGfxWindow.GfxDrawRect(X, Y, W, H: Integer);
begin
  C.Pen.Color   := FCurColor;
  C.Pen.Width   := FPenWidth;
  C.Brush.Style := bsClear;
  C.Rectangle(X, Y, X + W, Y + H);
end;

procedure TGfxWindow.GfxFillRect(X, Y, W, H: Integer);
begin
  C.Pen.Color   := FCurColor;
  C.Pen.Width   := 1;
  C.Brush.Color := FCurColor;
  C.Brush.Style := bsSolid;
  C.Rectangle(X, Y, X + W, Y + H);
end;

procedure TGfxWindow.GfxDrawCircle(X, Y, R: Integer);
begin
  C.Pen.Color   := FCurColor;
  C.Pen.Width   := FPenWidth;
  C.Brush.Style := bsClear;
  C.Ellipse(X - R, Y - R, X + R, Y + R);
end;

procedure TGfxWindow.GfxFillCircle(X, Y, R: Integer);
begin
  C.Pen.Color   := FCurColor;
  C.Pen.Width   := 1;
  C.Brush.Color := FCurColor;
  C.Brush.Style := bsSolid;
  C.Ellipse(X - R, Y - R, X + R, Y + R);
end;

procedure TGfxWindow.GfxDrawEllipse(X, Y, RX, RY: Integer);
begin
  C.Pen.Color   := FCurColor;
  C.Pen.Width   := FPenWidth;
  C.Brush.Style := bsClear;
  C.Ellipse(X - RX, Y - RY, X + RX, Y + RY);
end;

procedure TGfxWindow.GfxFillEllipse(X, Y, RX, RY: Integer);
begin
  C.Pen.Color   := FCurColor;
  C.Pen.Width   := 1;
  C.Brush.Color := FCurColor;
  C.Brush.Style := bsSolid;
  C.Ellipse(X - RX, Y - RY, X + RX, Y + RY);
end;

procedure TGfxWindow.GfxDrawText(X, Y: Integer; const Text: string);
begin
  C.Font.Color  := FCurColor;
  C.Brush.Style := bsClear;
  C.TextOut(X, Y, Text);
end;

procedure TGfxWindow.GfxSetFont(Size: Integer; Bold: Boolean);
begin
  C.Font.Name := 'Segoe UI';
  C.Font.Size := Size;
  if Bold then C.Font.Style := [fsBold]
  else         C.Font.Style := [];
end;

procedure TGfxWindow.GfxDrawPixel(X, Y: Integer);
begin
  FPanel.Bitmap.Canvas.Pixels[X, Y] := FCurColor;
end;

// Força repintura imediata do painel sem passar pela fila de mensagens
procedure TGfxWindow.GfxShow;
begin
  if not FRunning then Exit;
  InvalidateRect(FPanel.Handle, nil, False);
  UpdateWindow(FPanel.Handle);
  Application.ProcessMessages;
end;

// ---------------------------------------------------------------------------
//  Teclado
// ---------------------------------------------------------------------------

function TGfxWindow.GfxKeyPressed: Boolean;
begin
  Application.ProcessMessages;
  Result := FKeyQueue.Count > 0;
end;

function TGfxWindow.GfxReadKey: string;
begin
  Application.ProcessMessages;
  if FKeyQueue.Count > 0 then
  begin
    Result := FKeyQueue[0];
    FKeyQueue.Delete(0);
  end
  else
    Result := '';
end;

// ---------------------------------------------------------------------------
//  Funções globais de abertura/fechamento
// ---------------------------------------------------------------------------

procedure GfxOpenWindow(W, H: Integer; const Title: string);
begin
  GfxCloseWindow;
  GfxWin := TGfxWindow.CreateGfx(W, H, Title);
end;

procedure GfxCloseWindow;
var
  W : TGfxWindow;
begin
  if Assigned(GfxWin) then
  begin
    W          := GfxWin;
    GfxWin     := nil;
    W.FRunning := False;
    W.Hide;
    W.Free;
  end;
end;

initialization
  GfxWin := nil;

finalization
  GfxCloseWindow;

end.
