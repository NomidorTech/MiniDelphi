program PyRun;

// =============================================================================
// Pythia Runtime — pyrun.exe
// Copyright (C) 2026 Nomidor Software, LLC.
// GPL v3 — veja/see https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
//
//  PyRun.dpr  —  Runtime genérico do Pythia / Generic Pythia runtime
//
//  Executa qualquer arquivo .mdp ou .mdproj passado como argumento.
//  Runs any .mdp or .mdproj file passed as an argument.
//
//  Uso / Usage:
//    pyrun.exe sudoku.mdp
//    pyrun.exe meu_projeto.mdproj
//    pyrun.exe sudoku.mdp --no-shell
//    pyrun.exe --help
//
//  Compilação / Compilation:
//    Delphi 13 Win64 Release
// =============================================================================

{$APPTYPE GUI}

uses
  Winapi.Windows,
  System.SysUtils, System.Classes, System.IOUtils, System.IniFiles,
  Vcl.Forms, Vcl.Dialogs,
  ULexer, UParser, UAST, UInterpreter,
  UObjectRuntime, UGraphics, USQLite, UUnitLoader, UValidator;

var
  GConsoleAllocated : Boolean = False;

procedure EnsureConsole;
begin
  if not GConsoleAllocated then
  begin
    AllocConsole;
    GConsoleAllocated := True;
    Rewrite(Output);
  end;
end;

procedure ShowHelp;
begin
  EnsureConsole;
  Writeln('Pythia Runtime  —  pyrun.exe');
  Writeln('');
  Writeln('Uso / Usage:');
  Writeln('  pyrun.exe <arquivo.mdp>           Executa um programa Pythia');
  Writeln('  pyrun.exe <projeto.mdproj>         Executa um projeto Pythia');
  Writeln('  pyrun.exe <arquivo> --no-shell     Desativa builtins Shell*');
  Writeln('  pyrun.exe --help                   Esta ajuda / This help');
  Writeln('');
  Writeln('  pyrun.exe <file.mdp>               Run a Pythia program');
  Writeln('  pyrun.exe <project.mdproj>         Run a Pythia project');
  Writeln('  pyrun.exe <file> --no-shell        Disable Shell* builtins');
end;

procedure FatalError(const Msg: string);
begin
  MessageBox(0, PChar(Msg), 'Pythia Runtime — Erro / Error', MB_OK or MB_ICONERROR);
  Halt(1);
end;

function ReadMdpFile(const Path: string): string;
begin
  if not TFile.Exists(Path) then
    FatalError('Arquivo não encontrado / File not found:' + sLineBreak + Path);
  Result := TFile.ReadAllText(Path, TEncoding.UTF8);
end;

function ReadProjectFile(const Path: string; out SrcPath: string): string;
var
  Ini   : TIniFile;
  Keys  : TStringList;
  Lines : TStringList;
  I     : Integer;
begin
  if not TFile.Exists(Path) then
    FatalError('Projeto não encontrado / Project not found:' + sLineBreak + Path);
  SrcPath := ExtractFilePath(Path);
  Ini   := TIniFile.Create(Path);
  Keys  := TStringList.Create;
  Lines := TStringList.Create;
  try
    Ini.ReadSection('Source', Keys);
    for I := 0 to Keys.Count - 1 do
      Lines.Add(Ini.ReadString('Source', Keys[I], ''));
    Result := Lines.Text;
  finally
    Lines.Free; Keys.Free; Ini.Free;
  end;
  if Trim(Result) = '' then
    FatalError('Projeto sem código fonte / Project has no source:' + sLineBreak + Path);
end;

procedure RunSource(const Source, SourcePath: string; AllowShell: Boolean);
var
  Lex    : TLexer;
  Par    : TParser;
  Prog   : TProgramNode;
  Valid  : TValidator;
  Interp : TInterpreter;
  Output : TStringList;
  I      : Integer;
  HasGfx : Boolean;
begin
  Lex := nil; Par := nil; Prog := nil; Valid := nil; Interp := nil;
  Output := TStringList.Create;
  try
    try
      Lex := TLexer.Create(Source); Lex.Tokenise;
    except
      on E: Exception do FatalError('Erro léxico / Lex error:' + sLineBreak + E.Message);
    end;
    try
      Par := TParser.Create(Lex.Tokens); Prog := Par.Parse;
    except
      on E: EParseError do
        FatalError(Format('Erro de sintaxe / Parse error (linha %d):' + sLineBreak + '%s',
          [E.Line, E.Message]));
      on E: Exception do FatalError('Erro de sintaxe:' + sLineBreak + E.Message);
    end;
    Valid := TValidator.Create(Prog, Source);
    Valid.Validate;
    if Valid.HasErrors then
    begin
      var Msg := 'Erros de validação / Validation errors:' + sLineBreak;
      for I := 0 to Valid.Issues.Count - 1 do
        if Valid.Issues[I].Severity = vsError then
          Msg := Msg + '  * ' + Valid.Issues[I].Message + sLineBreak;
      FatalError(Msg);
    end;
    FreeAndNil(Valid);
    Interp := TInterpreter.Create(Prog, Output);
    Interp.MaxSteps   := 1000000000;
    Interp.SourcePath := SourcePath;
    Interp.SourceText := Source;
    Interp.AllowShell := AllowShell;
    try
      Interp.Run;
    except
      on E: Exception do
      begin
        // Descarrega saída antes do erro / Flush output before error
        HasGfx := Assigned(GfxWin);
        if not HasGfx then
        begin
          EnsureConsole;
          for I := 0 to Output.Count - 1 do Writeln(Output[I]);
        end;
        FatalError('Erro de execução / Runtime error:' + sLineBreak + E.Message);
      end;
    end;
    HasGfx := Assigned(GfxWin);
    if not HasGfx then
    begin
      EnsureConsole;
      for I := 0 to Output.Count - 1 do Writeln(Output[I]);
    end;
  finally
    FreeAndNil(Interp); FreeAndNil(Valid);
    FreeAndNil(Prog);   FreeAndNil(Par);
    FreeAndNil(Lex);    FreeAndNil(Output);
  end;
end;

var
  FilePath   : string;
  SourcePath : string;
  Source     : string;
  AllowShell : Boolean;
  Ext        : string;
  I          : Integer;
begin
  Application.Initialize;
  Application.ShowMainForm := False;

  FilePath   := '';
  AllowShell := True;

  for I := 1 to ParamCount do
  begin
    if SameText(ParamStr(I), '--help') or SameText(ParamStr(I), '-h') then
    begin ShowHelp; Halt(0); end
    else if SameText(ParamStr(I), '--no-shell') then AllowShell := False
    else if SameText(ParamStr(I), '--allow-shell') then AllowShell := True
    else if (ParamStr(I)[1] <> '-') and (FilePath = '') then
      FilePath := ParamStr(I);
  end;

  if FilePath = '' then begin ShowHelp; Halt(0); end;

  if not TPath.IsPathRooted(FilePath) then
    FilePath := TPath.Combine(GetCurrentDir, FilePath);

  Ext := LowerCase(ExtractFileExt(FilePath));
  if Ext = '.mdproj' then
    Source := ReadProjectFile(FilePath, SourcePath)
  else if Ext = '.mdp' then
  begin
    SourcePath := ExtractFilePath(FilePath);
    Source := ReadMdpFile(FilePath);
  end
  else
    FatalError('Tipo não suportado / Unsupported type:' + sLineBreak + FilePath);

  RunSource(Source, SourcePath, AllowShell);

  if Assigned(GfxWin) and GfxWin.Running then Application.Run;

  if GConsoleAllocated then
  begin
    Writeln(''); Writeln('Pressione Enter / Press Enter...');
    Readln;
  end;

  GfxCloseWindow;
end.
