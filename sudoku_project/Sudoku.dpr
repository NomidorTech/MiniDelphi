program Sudoku;

// =============================================================================
// Sudoku — Pythia Runtime / Runtime do Pythia
// Copyright (C) 2026 Nomidor Software, LLC.
// GPL v3 — veja/see https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
//
//  Sudoku.dpr  —  Executável standalone do jogo Sudoku
//                 Standalone executable for the Sudoku game
//
//  Uso / Usage:
//    Basta dar duplo clique em Sudoku.exe
//    Just double-click Sudoku.exe
//
//  Arquivos necessários na mesma pasta / Files needed in same folder:
//    Sudoku.exe
//    sudoku.mdp
//    sqlite3.dll    (opcional / optional — para salvamentos / for saves)
//
//  Compilação / Compilation:
//    Delphi 13 Win64 Release
//    Project → Options → Output directory: .\Win64\Release
// =============================================================================

{$APPTYPE GUI}

uses
  Winapi.Windows,
  System.SysUtils, System.Classes, System.IOUtils,
  Vcl.Forms, Vcl.Dialogs,
  ULexer,
  UParser,
  UAST,
  UInterpreter,
  UObjectRuntime,
  UGraphics,
  USQLite,
  UUnitLoader,
  UValidator;

// ---------------------------------------------------------------------------
//  Mostra erro fatal / Show fatal error
// ---------------------------------------------------------------------------
procedure FatalError(const Msg: string);
begin
  MessageBox(0,
    PChar(Msg),
    'Sudoku — Erro / Error',
    MB_OK or MB_ICONERROR);
  Halt(1);
end;

// ---------------------------------------------------------------------------
//  Executa o programa / Run the program
// ---------------------------------------------------------------------------
procedure RunGame(const Source, SourcePath: string);
var
  Lex    : TLexer;
  Par    : TParser;
  Prog   : TProgramNode;
  Interp : TInterpreter;
  Output : TStringList;
  I      : Integer;
begin
  Lex    := nil; Par := nil; Prog := nil; Interp := nil;
  Output := TStringList.Create;
  try
    // Lexer
    try
      Lex := TLexer.Create(Source);
      Lex.Tokenise;
    except
      on E: Exception do FatalError('Erro léxico / Lex error:' + sLineBreak + E.Message);
    end;

    // Parser
    try
      Par  := TParser.Create(Lex.Tokens);
      Prog := Par.Parse;
    except
      on E: EParseError do
        FatalError(Format('Erro de sintaxe / Parse error (linha %d):' + sLineBreak + '%s',
          [E.Line, E.Message]));
      on E: Exception do
        FatalError('Erro de sintaxe / Parse error:' + sLineBreak + E.Message);
    end;

    // Interpretador / Interpreter
    Interp := TInterpreter.Create(Prog, Output);
    Interp.MaxSteps   := 1000000000;
    Interp.SourcePath := SourcePath;
    Interp.SourceText := Source;
    Interp.AllowShell := False;   // Sudoku não precisa de shell / Sudoku doesn't need shell

    try
      Interp.Run;
    except
      on E: Exception do
        FatalError('Erro de execução / Runtime error:' + sLineBreak + E.Message);
    end;

  finally
    FreeAndNil(Interp);
    FreeAndNil(Prog);
    FreeAndNil(Par);
    FreeAndNil(Lex);
    FreeAndNil(Output);
  end;
end;

// ---------------------------------------------------------------------------
//  Ponto de entrada / Entry point
// ---------------------------------------------------------------------------
var
  ExeDir  : string;
  MdpFile : string;
  Source  : string;
begin
  Application.Initialize;
  Application.ShowMainForm := False;
  Application.Title        := 'Sudoku';

  // Procura sudoku.mdp na mesma pasta do exe
  // Looks for sudoku.mdp in the same folder as the exe
  ExeDir  := ExtractFilePath(ParamStr(0));
  MdpFile := ExeDir + 'sudoku.mdp';

  if not TFile.Exists(MdpFile) then
    FatalError(
      'Arquivo não encontrado / File not found:' + sLineBreak +
      MdpFile + sLineBreak + sLineBreak +
      'Certifique-se de que sudoku.mdp está na mesma pasta que Sudoku.exe.' + sLineBreak +
      'Make sure sudoku.mdp is in the same folder as Sudoku.exe.');

  Source := TFile.ReadAllText(MdpFile, TEncoding.UTF8);

  RunGame(Source, ExeDir);

  // Mantém a janela gráfica aberta / Keep graphics window open
  if Assigned(GfxWin) and GfxWin.Running then
    Application.Run;

  GfxCloseWindow;
end.

[Source]
// ============================================================
// NEW MINIDELPHI PROGRAM
// ============================================================

begin
  writeln('Hello, MiniDelphi!');
end.
[Project]
Name=Sudoku.dpr
[Files]
Count=0
