program PyRun;

// =============================================================================
// Pythia Runtime — pyrun.exe
// Copyright (C) 2026 Nomidor Software, LLC.
// GPL v3 — veja/see https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
//
//  PyRun.dpr  —  Runtime standalone do Pythia / Pythia standalone runtime
//
//  Executa arquivos .mdp e .mdproj sem o IDE.
//  Runs .mdp and .mdproj files without the IDE.
//
//  Uso / Usage:
//    pyrun.exe programa.mdp
//    pyrun.exe meu_projeto.mdproj
//    pyrun.exe programa.mdp --allow-shell
//    pyrun.exe --help
//
//  Saída de writeln / writeln output:
//    Programas sem gráficos → janela de console alocada automaticamente
//    Programas com GfxOpen  → janela gráfica (sem console)
//    Graphics programs      → graphics window (no console)
//    Non-graphics programs  → console window allocated automatically
//
//  Comportamento / Behaviour:
//    Shell* builtins: permitidos por padrão (o usuário executou o programa)
//    Shell* builtins: allowed by default (user explicitly ran the program)
//    Erros fatais: MessageBox + código de saída 1
//    Fatal errors: MessageBox + exit code 1
// =============================================================================

{$APPTYPE GUI}   // VCL necessário para GfxWindow e diálogos / needed for GfxWindow and dialogs

uses
  Winapi.Windows,
  System.SysUtils, System.Classes, System.IOUtils, System.IniFiles,
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
//  Constantes / Constants
// ---------------------------------------------------------------------------
const
  VERSION     = '1.0';
  APP_NAME    = 'Pythia Runtime';
  APP_NAME_PT = 'Runtime do Pythia';

// ---------------------------------------------------------------------------
//  Janela de console sob demanda / On-demand console window
//  Alocada apenas se o programa usar writeln sem GfxOpen.
//  Only allocated if the program uses writeln without GfxOpen.
// ---------------------------------------------------------------------------
var
  GConsoleAllocated : Boolean = False;

procedure EnsureConsole;
begin
  if not GConsoleAllocated then
  begin
    AllocConsole;
    GConsoleAllocated := True;
    // Redireciona saída padrão para o novo console
    // Redirect standard output to the new console
    var ConOut := TTextRec(Output);
    Rewrite(Output);
  end;
end;

// ---------------------------------------------------------------------------
//  Exibe ajuda / Show help
// ---------------------------------------------------------------------------
procedure ShowHelp;
begin
  EnsureConsole;
  Writeln(APP_NAME + ' v' + VERSION);
  Writeln('');
  Writeln('Uso / Usage:');
  Writeln('  pyrun.exe <arquivo.mdp>          Executa um programa Pythia');
  Writeln('  pyrun.exe <projeto.mdproj>        Executa um projeto Pythia');
  Writeln('  pyrun.exe <arquivo> --allow-shell Permite builtins Shell*');
  Writeln('  pyrun.exe --help                  Mostra esta ajuda');
  Writeln('');
  Writeln('  pyrun.exe <file.mdp>              Run a Pythia program');
  Writeln('  pyrun.exe <project.mdproj>        Run a Pythia project');
  Writeln('  pyrun.exe <file> --allow-shell    Allow Shell* builtins');
  Writeln('  pyrun.exe --help                  Show this help');
  Writeln('');
  Writeln('Exemplos / Examples:');
  Writeln('  pyrun.exe sudoku.mdp');
  Writeln('  pyrun.exe C:\Projetos\MeuApp\meuapp.mdproj');
end;

// ---------------------------------------------------------------------------
//  Mostra erro e encerra / Show error and exit
// ---------------------------------------------------------------------------
procedure FatalError(const Msg: string);
begin
  MessageBox(0,
    PChar(Msg),
    PChar(APP_NAME + ' — Erro / Error'),
    MB_OK or MB_ICONERROR);
  Halt(1);
end;

// ---------------------------------------------------------------------------
//  Lê o source de um arquivo .mdp / Read source from a .mdp file
// ---------------------------------------------------------------------------
function ReadMdpSource(const Path: string): string;
begin
  if not TFile.Exists(Path) then
    FatalError('Arquivo não encontrado / File not found:' + sLineBreak + Path);
  Result := TFile.ReadAllText(Path, TEncoding.UTF8);
end;

// ---------------------------------------------------------------------------
//  Lê o source de um projeto .mdproj / Read source from a .mdproj file
//  Formato / Format:
//    [Project]
//    Name=MyApp
//    [Files]
//    0=MathLib.mdp
//    [Source]
//    program MyApp; ...
// ---------------------------------------------------------------------------
function ReadProjectSource(const Path: string; out SourcePath: string): string;
var
  Ini      : TIniFile;
  SrcLines : TStringList;
  Keys     : TStringList;
  I        : Integer;
  Key, Val : string;
begin
  if not TFile.Exists(Path) then
    FatalError('Projeto não encontrado / Project not found:' + sLineBreak + Path);

  SourcePath := ExtractFilePath(Path);
  Ini        := TIniFile.Create(Path);
  SrcLines   := TStringList.Create;
  Keys       := TStringList.Create;
  try
    // Lê as linhas do [Source] / Read [Source] lines
    Ini.ReadSectionValues('Source', SrcLines);
    // O TIniFile lê como Key=Value, mas o source é linha por linha numerada
    // TIniFile reads as Key=Value; source lines are numbered sequentially
    Keys.Clear;
    Ini.ReadSection('Source', Keys);

    // Reconstrói o source na ordem correta / Rebuild source in correct order
    var Lines := TStringList.Create;
    try
      for I := 0 to Keys.Count - 1 do
      begin
        Key := Keys[I];
        Val := Ini.ReadString('Source', Key, '');
        Lines.Add(Val);
      end;
      Result := Lines.Text;
    finally
      Lines.Free;
    end;

    if Trim(Result) = '' then
      FatalError('Projeto sem código fonte / Project has no source code:' + sLineBreak + Path);
  finally
    Keys.Free;
    SrcLines.Free;
    Ini.Free;
  end;
end;

// ---------------------------------------------------------------------------
//  TRunOutput — coleta writeln e exibe no console ou descarta se gráfico
//  Collects writeln output and shows in console, or discards if graphics
// ---------------------------------------------------------------------------
type
  TRunOutput = class(TStringList)
  private
    FHasGraphics : Boolean;
    FConsoleOpen : Boolean;
  public
    constructor Create;
    procedure FlushToConsole;
    property HasGraphics : Boolean read FHasGraphics write FHasGraphics;
  end;

constructor TRunOutput.Create;
begin
  inherited Create;
  FHasGraphics := False;
  FConsoleOpen := False;
end;

procedure TRunOutput.FlushToConsole;
var I : Integer;
begin
  if FHasGraphics then Exit;  // Saída gráfica — sem console / Graphics output — no console
  EnsureConsole;
  for I := 0 to Count - 1 do
    Writeln(Strings[I]);
end;

// ---------------------------------------------------------------------------
//  Executa o programa / Run the program
// ---------------------------------------------------------------------------
procedure RunSource(const Source, SourcePath: string; AllowShell: Boolean);
var
  Lex    : TLexer;
  Par    : TParser;
  Prog   : TProgramNode;
  Valid  : TValidator;
  Interp : TInterpreter;
  Output : TRunOutput;
  I      : Integer;
begin
  Lex    := nil;
  Par    := nil;
  Prog   := nil;
  Valid  := nil;
  Interp := nil;
  Output := TRunOutput.Create;
  try
    // ── Lexer ──────────────────────────────────────────────────────────────
    try
      Lex := TLexer.Create(Source);
      Lex.Tokenise;
    except
      on E: Exception do
        FatalError('Erro léxico / Lex error:' + sLineBreak + E.Message);
    end;

    // ── Parser ─────────────────────────────────────────────────────────────
    try
      Par  := TParser.Create(Lex.Tokens);
      Prog := Par.Parse;
    except
      on E: EParseError do
        FatalError(Format('Erro de sintaxe / Parse error  (linha/line %d, col %d):' +
          sLineBreak + '%s', [E.Line, E.Col, E.Message]));
      on E: Exception do
        FatalError('Erro de sintaxe / Parse error:' + sLineBreak + E.Message);
    end;

    // ── Validação / Validation ─────────────────────────────────────────────
    Valid := TValidator.Create(Prog, Source);
    Valid.Validate;
    if Valid.HasErrors then
    begin
      var ErrMsg := 'Erros de validação / Validation errors:' + sLineBreak;
      for I := 0 to Valid.Issues.Count - 1 do
        if Valid.Issues[I].Severity = vsError then
          ErrMsg := ErrMsg + '  • ' + Valid.Issues[I].Message + sLineBreak;
      FatalError(ErrMsg);
    end;
    FreeAndNil(Valid);

    // ── Interpretador / Interpreter ────────────────────────────────────────
    Interp := TInterpreter.Create(Prog, Output);
    Interp.MaxSteps   := 1000000000;  // sem limite efetivo / no effective limit
    Interp.SourcePath := SourcePath;
    Interp.SourceText := Source;
    Interp.AllowShell := AllowShell;  // usuário executou explicitamente / user ran explicitly

    try
      Interp.Run;
    except
      on E: Exception do
      begin
        // Descarrega a saída antes de mostrar o erro / Flush output before showing error
        Output.FlushToConsole;
        FatalError('Erro de execução / Runtime error:' + sLineBreak + E.Message);
      end;
    end;

    // ── Descarrega saída / Flush output ────────────────────────────────────
    // Detecta se o programa abriu uma janela gráfica / Detect if graphics window was opened
    Output.HasGraphics := Assigned(GfxWin);
    Output.FlushToConsole;

  finally
    FreeAndNil(Interp);
    FreeAndNil(Valid);
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
  FilePath   : string;
  SourcePath : string;
  Source     : string;
  AllowShell : Boolean;
  Ext        : string;
  I          : Integer;
begin
  Application.Initialize;
  Application.ShowMainForm := False;  // Sem janela principal / No main window

  // ── Processa argumentos / Process arguments ─────────────────────────────
  FilePath   := '';
  AllowShell := True;  // Padrão: permitido / Default: allowed

  for I := 1 to ParamCount do
  begin
    if SameText(ParamStr(I), '--help') or SameText(ParamStr(I), '-h') then
    begin
      ShowHelp;
      Halt(0);
    end
    else if SameText(ParamStr(I), '--allow-shell') then
      AllowShell := True
    else if SameText(ParamStr(I), '--no-shell') then
      AllowShell := False
    else if (ParamStr(I)[1] <> '-') and (FilePath = '') then
      FilePath := ParamStr(I);
  end;

  if FilePath = '' then
  begin
    ShowHelp;
    Halt(0);
  end;

  // ── Resolve caminho completo / Resolve full path ────────────────────────
  if not TPath.IsPathRooted(FilePath) then
    FilePath := TPath.Combine(GetCurrentDir, FilePath);

  // ── Lê fonte conforme o tipo / Read source by type ──────────────────────
  Ext := LowerCase(ExtractFileExt(FilePath));

  if Ext = '.mdproj' then
    Source := ReadProjectSource(FilePath, SourcePath)
  else if Ext = '.mdp' then
  begin
    SourcePath := ExtractFilePath(FilePath);
    Source     := ReadMdpSource(FilePath);
  end
  else
    FatalError('Tipo de arquivo não suportado / Unsupported file type:' +
      sLineBreak + FilePath + sLineBreak +
      'Use .mdp ou .mdproj / Use .mdp or .mdproj');

  // ── Executa / Run ───────────────────────────────────────────────────────
  RunSource(Source, SourcePath, AllowShell);

  // ── Se programa gráfico ainda rodando, entra no loop VCL
  //    If graphics program still running, enter VCL loop
  if Assigned(GfxWin) and GfxWin.Running then
    Application.Run;

  // ── Pausa se console aberto / Pause if console was opened ───────────────
  if GConsoleAllocated then
  begin
    Writeln('');
    Writeln('Pressione Enter para sair / Press Enter to exit...');
    Readln;
  end;

  GfxCloseWindow;
end.
