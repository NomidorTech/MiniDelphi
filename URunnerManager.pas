unit URunnerManager;

// =============================================================================
// Pythia -- Pascal learning environment / ambiente de aprendizado Pascal
// Copyright (C) 2026 Nomidor Software, LLC.
// GPL v3 -- see/veja https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
//
//  URunnerManager.pas  --  Pluggable language runner system
//                          Sistema de runners de linguagem plugavel
//
//  English:
//  --------
//  A "runner" defines how Pythia executes source code for a given language.
//  Built-in runners ship inside the exe. External runners snap in by dropping
//  a .runner.ini file into the Runners\ folder next to Pythia.exe.
//
//  Runner pack INI format:
//
//    [Meta]
//    Name=Python           ; display name
//    Code=py               ; short code used in file extensions and APIs
//    Extension=.py         ; source file extension
//    Author=Nomidor Software
//    Version=1.0
//    IsBuiltIn=1           ; 1 = built-in, 0 = external pack
//
//    [Runtime]
//    Mode=shell            ; shell = run via CreateProcess
//                          ; internal = use Pythia interpreter (Pascal only)
//    Command=python        ; executable name (searched on PATH)
//    Args={file}           ; {file} = temp file path, {source} = inline source
//    WorkDir={filedir}     ; working directory ({filedir} = dir of source file)
//    Encoding=utf-8        ; source file encoding
//
//    [Detect]
//    TestCommand=python --version
//    MinVersion=3.0        ; optional minimum version string check
//
//    [Editor]
//    CommentPrefix=//      ; used for syntax hints
//    Starter=# New program\nprint("Hello!") ; default starter code
//    TabWidth=4
//    IndentChar=space      ; space or tab
//
//    [Display]
//    Color=#4B8BBE         ; language accent color (hex)
//    Icon=py               ; future: icon identifier
//
//  Português:
//  ----------
//  Um "runner" define como o Pythia executa código-fonte para um dado idioma.
//  Runners embutidos vêm compilados no exe. Runners externos se conectam
//  ao sistema colocando um arquivo .runner.ini na pasta Runners\ ao lado
//  do Pythia.exe. Nenhuma recompilação é necessária.
//
//  Usage / Uso:
//    Runners.SetRunner('py');
//    Caption := Runners.Active.Name;
//    Runners.Execute(Source, SourcePath, Output, OnDone);
// =============================================================================

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, System.IOUtils,
  System.Generics.Collections,
  Winapi.Windows;

type
  // -----------------------------------------------------------------------
  //  How a runner executes code
  //  Como um runner executa o codigo
  // -----------------------------------------------------------------------
  TRunnerMode = (
    rmInternal,  // Uses Pythia interpreter (Pascal only / somente Pascal)
    rmShell      // Launches external process / Lanca processo externo
  );

  // -----------------------------------------------------------------------
  //  A single language runner definition
  //  Definicao de um runner de linguagem
  // -----------------------------------------------------------------------
  TRunner = class
  public
    // Meta / Metadados
    Name        : string;   // 'Python', 'Pascal', 'Lua' ...
    Code        : string;   // 'py', 'pascal', 'lua' ...
    Extension   : string;   // '.py', '.mdp', '.lua' ...
    Author      : string;
    Version     : string;
    IsBuiltIn   : Boolean;

    // Runtime / Execucao
    Mode        : TRunnerMode;
    Command     : string;   // 'python', 'lua', 'node' ...
    Args        : string;   // '{file}' or '{source}' template
    WorkDir     : string;   // '{filedir}' or absolute path
    Encoding    : string;   // 'utf-8', 'ansi' ...

    // Detection / Deteccao
    TestCommand : string;   // 'python --version'
    MinVersion  : string;

    // Editor hints / Dicas para o editor
    CommentPrefix : string; // '//' or '#' or '--'
    Starter       : string; // default starter code (newlines as \n)
    TabWidth      : Integer;
    IndentChar    : string; // 'space' or 'tab'

    // Display / Exibicao
    Color       : string;   // '#4B8BBE'
    IconCode    : string;   // future icon identifier

    // Check if the runner's external executable is available
    // Verifica se o executavel externo esta disponivel
    function IsAvailable: Boolean;

    // Get the starter code with \n expanded to real newlines
    // Obtem o codigo inicial com \n expandido para quebras de linha reais
    function StarterCode: string;
  end;

  // -----------------------------------------------------------------------
  //  Callback when shell execution completes
  //  Callback quando execucao em shell termina
  // -----------------------------------------------------------------------
  TRunnerDoneEvent = procedure(ExitCode: Integer; const Output: string) of object;

  // -----------------------------------------------------------------------
  //  The runner manager -- mirrors TLanguageManager architecture
  //  O gerenciador de runners -- espelha a arquitetura do TLanguageManager
  // -----------------------------------------------------------------------
  TRunnerManager = class
  private
    FRunners    : TObjectList<TRunner>;  // all loaded runners / todos os runners
    FActive     : TRunner;              // currently selected / selecionado
    FRunnersDir : string;               // <exedir>\Runners\

    procedure LoadBuiltIns;
    procedure LoadExternalPacks;
    procedure LoadPackFromIni(const Path: string);
    procedure LoadPreference;
    procedure SavePreference;
    function  FindRunner(const Code: string): TRunner;

    // Shell execution helpers / Auxiliares de execucao em shell
    function  ExpandArgs(const Template, FilePath: string): string;
    function  ExpandWorkDir(const Template, FilePath: string): string;

  public
    constructor Create;
    destructor  Destroy; override;

    // Select a runner by code / Seleciona um runner pelo codigo
    procedure SetRunner(const Code: string);

    // Execute source code using the active runner
    // Executa codigo-fonte usando o runner ativo
    // Returns output as string / Retorna saida como string
    function Execute(const Source, SourcePath: string;
                     Output: TStrings): Boolean;

    // Shell execution -- runs an external process and captures output
    // Execucao em shell -- roda um processo externo e captura a saida
    function ExecuteShell(const Command, Args, WorkDir: string;
                          Output: TStrings;
                          TimeoutMs: Integer = 30000): Boolean;

    // Write source to a temp file and return its path
    // Escreve o fonte em arquivo temporario e retorna o caminho
    function WriteTempFile(const Source, Ext, Encoding: string): string;

    property Active     : TRunner                  read FActive;
    property AllRunners : TObjectList<TRunner>      read FRunners;
    property RunnersDir : string                    read FRunnersDir;
  end;

var
  Runners : TRunnerManager;

procedure InitRunners;

// =============================================================================
implementation
// =============================================================================

uses
  ULexer, UParser, UAST, UInterpreter;

// ---------------------------------------------------------------------------
//  TRunner
// ---------------------------------------------------------------------------

function TRunner.IsAvailable: Boolean;
var
  SI  : TStartupInfo;
  PI  : TProcessInformation;
  Cmd : string;
begin
  if Mode = rmInternal then
  begin
    Result := True;
    Exit;
  end;
  if TestCommand = '' then
  begin
    Result := True; // assume available / assume disponivel
    Exit;
  end;
  // Run the test command and see if it succeeds
  // Roda o comando de teste e verifica se tem sucesso
  Cmd := TestCommand;
  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_HIDE;
  Result := CreateProcess(nil, PChar(Cmd), nil, nil, False,
                          CREATE_NO_WINDOW, nil, nil, SI, PI);
  if Result then
  begin
    WaitForSingleObject(PI.hProcess, 5000);
    var ExitCode : DWORD;
    GetExitCodeProcess(PI.hProcess, ExitCode);
    CloseHandle(PI.hThread);
    CloseHandle(PI.hProcess);
    Result := (ExitCode = 0);
  end;
end;

function TRunner.StarterCode: string;
begin
  // Expand \n to real newlines / Expande \n para quebras de linha reais
  Result := StringReplace(Starter, '\n', sLineBreak, [rfReplaceAll]);
end;

// ---------------------------------------------------------------------------
//  Built-in runner definitions
//  Definicoes de runners embutidos
// ---------------------------------------------------------------------------

procedure TRunnerManager.LoadBuiltIns;

  procedure Add(const AName, ACode, AExt, AAuthor, AVersion: string;
                AMode: TRunnerMode;
                const ACmd, AArgs, AWorkDir, AEnc: string;
                const ATest, AMinVer: string;
                const AComment, AStarter, AColor: string;
                ATabWidth: Integer; const AIndent: string);
  var R : TRunner;
  begin
    R               := TRunner.Create;
    R.Name          := AName;
    R.Code          := ACode;
    R.Extension     := AExt;
    R.Author        := AAuthor;
    R.Version       := AVersion;
    R.IsBuiltIn     := True;
    R.Mode          := AMode;
    R.Command       := ACmd;
    R.Args          := AArgs;
    R.WorkDir       := AWorkDir;
    R.Encoding      := AEnc;
    R.TestCommand   := ATest;
    R.MinVersion    := AMinVer;
    R.CommentPrefix := AComment;
    R.Starter       := AStarter;
    R.Color         := AColor;
    R.TabWidth      := ATabWidth;
    R.IndentChar    := AIndent;
    FRunners.Add(R);
  end;

begin
  // Prime Directive order: Pascal first (native), then Python, then others
  // Ordem da Diretiva Principal: Pascal primeiro (nativo), depois Python, etc.

  // Pascal -- uses Pythia's internal interpreter / usa o interpretador interno
  Add('Pascal', 'pascal', '.mdp', 'Nomidor Software', '1.0',
      rmInternal,
      '', '', '', 'utf-8',
      '', '',
      '//',
      'program NewProgram;\n\nbegin\n  writeln(''Hello, World!'');\nend.',
      '#0070C0',
      2, 'space');

  // Python -- shells to python.exe on PATH / usa python.exe no PATH
  Add('Python', 'py', '.py', 'Nomidor Software', '1.0',
      rmShell,
      'python', '{file}', '{filedir}', 'utf-8',
      'python --version', '3.0',
      '#',
      '# Python program\nprint("Hello, World!")',
      '#4B8BBE',
      4, 'space');
end;

// ---------------------------------------------------------------------------
//  Load external runner packs from Runners\ folder
//  Carrega runners externos da pasta Runners\
// ---------------------------------------------------------------------------

procedure TRunnerManager.LoadExternalPacks;
var
  Files : TArray<string>;
  F     : string;
begin
  if not TDirectory.Exists(FRunnersDir) then
  begin
    TDirectory.CreateDirectory(FRunnersDir);
    Exit;
  end;
  Files := TDirectory.GetFiles(FRunnersDir, '*.runner.ini');
  for F in Files do LoadPackFromIni(F);
end;

procedure TRunnerManager.LoadPackFromIni(const Path: string);
var
  Ini  : TIniFile;
  R    : TRunner;
  Code : string;
  ModeStr : string;
begin
  Ini := TIniFile.Create(Path);
  try
    Code := Ini.ReadString('Meta', 'Code', '');
    if Code = '' then Exit;
    if Assigned(FindRunner(Code)) then Exit; // already loaded / ja carregado

    R             := TRunner.Create;
    R.Code        := Code;
    R.Name        := Ini.ReadString('Meta',    'Name',        Code);
    R.Extension   := Ini.ReadString('Meta',    'Extension',   '.' + Code);
    R.Author      := Ini.ReadString('Meta',    'Author',      'Community');
    R.Version     := Ini.ReadString('Meta',    'Version',     '1.0');
    R.IsBuiltIn   := Ini.ReadBool  ('Meta',    'IsBuiltIn',   False);

    ModeStr := LowerCase(Ini.ReadString('Runtime', 'Mode', 'shell'));
    if ModeStr = 'internal' then R.Mode := rmInternal
    else                         R.Mode := rmShell;

    R.Command     := Ini.ReadString('Runtime', 'Command',     '');
    R.Args        := Ini.ReadString('Runtime', 'Args',        '{file}');
    R.WorkDir     := Ini.ReadString('Runtime', 'WorkDir',     '{filedir}');
    R.Encoding    := Ini.ReadString('Runtime', 'Encoding',    'utf-8');

    R.TestCommand := Ini.ReadString('Detect',  'TestCommand', '');
    R.MinVersion  := Ini.ReadString('Detect',  'MinVersion',  '');

    R.CommentPrefix := Ini.ReadString('Editor', 'CommentPrefix', '//');
    R.Starter       := Ini.ReadString('Editor', 'Starter',       '');
    R.TabWidth      := Ini.ReadInteger('Editor','TabWidth',       4);
    R.IndentChar    := Ini.ReadString('Editor', 'IndentChar',     'space');

    R.Color     := Ini.ReadString('Display', 'Color', '#888888');
    R.IconCode  := Ini.ReadString('Display', 'Icon',  '');

    FRunners.Add(R);
  finally
    Ini.Free;
  end;
end;

// ---------------------------------------------------------------------------
//  Preference persistence / Persistencia da preferencia
// ---------------------------------------------------------------------------

procedure TRunnerManager.LoadPreference;
var
  Ini  : TIniFile;
  Code : string;
  R    : TRunner;
begin
  var IniPath := ExtractFilePath(ParamStr(0)) + 'pythia.ini';
  if not FileExists(IniPath) then Exit;
  Ini := TIniFile.Create(IniPath);
  try
    Code := Ini.ReadString('Runner', 'Code', 'pascal');
    R    := FindRunner(Code);
    if Assigned(R) then FActive := R;
  finally Ini.Free; end;
end;

procedure TRunnerManager.SavePreference;
var Ini : TIniFile;
begin
  var IniPath := ExtractFilePath(ParamStr(0)) + 'pythia.ini';
  Ini := TIniFile.Create(IniPath);
  try
    if Assigned(FActive) then
      Ini.WriteString('Runner', 'Code', FActive.Code)
    else
      Ini.WriteString('Runner', 'Code', 'pascal');
  finally Ini.Free; end;
end;

function TRunnerManager.FindRunner(const Code: string): TRunner;
var R : TRunner;
begin
  Result := nil;
  for R in FRunners do
    if SameText(R.Code, Code) then begin Result := R; Exit; end;
end;

// ---------------------------------------------------------------------------
//  Constructor / Destructor
// ---------------------------------------------------------------------------

constructor TRunnerManager.Create;
begin
  inherited Create;
  FRunners    := TObjectList<TRunner>.Create(True);
  FRunnersDir := ExtractFilePath(ParamStr(0)) + 'Runners\';
  LoadBuiltIns;
  LoadExternalPacks;
  FActive := FindRunner('pascal');
  LoadPreference;
end;

destructor TRunnerManager.Destroy;
begin
  FRunners.Free;
  inherited;
end;

// ---------------------------------------------------------------------------
//  SetRunner
// ---------------------------------------------------------------------------

procedure TRunnerManager.SetRunner(const Code: string);
var R : TRunner;
begin
  R := FindRunner(Code);
  if Assigned(R) then
  begin
    FActive := R;
    SavePreference;
  end;
end;

// ---------------------------------------------------------------------------
//  Execute -- dispatches to internal or shell
//  Executa -- despacha para interpretador interno ou shell
// ---------------------------------------------------------------------------

function TRunnerManager.Execute(const Source, SourcePath: string;
                                Output: TStrings): Boolean;
var
  TmpFile : string;
  Cmd, Args, WDir : string;
begin
  Result := True;

  if not Assigned(FActive) then
  begin
    Output.Add('No runner selected. / Nenhum runner selecionado.');
    Result := False;
    Exit;
  end;

  case FActive.Mode of

    rmInternal:
    begin
      // Use Pythia's own interpreter (Pascal)
      // Usa o interpretador proprio do Pythia (Pascal)
      var Lex   : TLexer   := nil;
      var Par   : TParser  := nil;
      var Prog  : TProgramNode := nil;
      var Interp: TInterpreter := nil;
      try
        try
          Lex := TLexer.Create(Source);
          Lex.Tokenise;
          Par  := TParser.Create(Lex.Tokens);
          Prog := Par.Parse;
          Interp := TInterpreter.Create(Prog, Output);
          Interp.MaxSteps   := 100000000;
          Interp.SourcePath := SourcePath;
          Interp.SourceText := Source;
          Interp.AllowShell := False;
          Interp.Run;
        except
          on E: Exception do
          begin
            Output.Add('');
            Output.Add('*** ' + E.Message);
            Result := False;
          end;
        end;
      finally
        FreeAndNil(Interp);
        FreeAndNil(Prog);
        FreeAndNil(Par);
        FreeAndNil(Lex);
      end;
    end;

    rmShell:
    begin
      // Write source to a temp file and run external process
      // Escreve o fonte em arquivo temporario e roda processo externo
      TmpFile := WriteTempFile(Source, FActive.Extension, FActive.Encoding);
      try
        Cmd  := FActive.Command;
        Args := ExpandArgs(FActive.Args, TmpFile);
        if SourcePath <> '' then
          WDir := ExpandWorkDir(FActive.WorkDir, SourcePath)
        else
          WDir := ExpandWorkDir(FActive.WorkDir, ExtractFilePath(TmpFile));
        Result := ExecuteShell(Cmd, Args, WDir, Output);
      finally
        if TFile.Exists(TmpFile) then TFile.Delete(TmpFile);
      end;
    end;

  end;
end;

// ---------------------------------------------------------------------------
//  Shell execution -- launches external process, captures stdout+stderr
//  Execucao em shell -- lanca processo externo, captura stdout+stderr
// ---------------------------------------------------------------------------

function TRunnerManager.ExecuteShell(const Command, Args, WorkDir: string;
                                     Output: TStrings;
                                     TimeoutMs: Integer): Boolean;
var
  SA          : TSecurityAttributes;
  ReadPipe    : THandle;
  WritePipe   : THandle;
  SI          : TStartupInfo;
  PI          : TProcessInformation;
  Buffer      : array[0..4095] of AnsiChar;
  BytesRead   : DWORD;
  ExitCode    : DWORD;
  FullCmd     : string;
  WorkDirPtr  : PChar;
  Buf         : string;
  Lines       : TStringList;
begin
  Result := False;

  // Set up pipe for stdout/stderr capture
  // Configura pipe para captura de stdout/stderr
  FillChar(SA, SizeOf(SA), 0);
  SA.nLength        := SizeOf(SA);
  SA.bInheritHandle := True;

  if not CreatePipe(ReadPipe, WritePipe, @SA, 0) then
  begin
    Output.Add('Failed to create pipe. / Falha ao criar pipe.');
    Exit;
  end;

  SetHandleInformation(ReadPipe, HANDLE_FLAG_INHERIT, 0);

  FillChar(SI, SizeOf(SI), 0);
  SI.cb          := SizeOf(SI);
  SI.dwFlags     := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  SI.wShowWindow := SW_HIDE;
  SI.hStdOutput  := WritePipe;
  SI.hStdError   := WritePipe;
  SI.hStdInput   := INVALID_HANDLE_VALUE;

  FullCmd := Command;
  if Args <> '' then FullCmd := FullCmd + ' ' + Args;

  if WorkDir <> '' then WorkDirPtr := PChar(WorkDir)
  else                   WorkDirPtr := nil;

  if not CreateProcess(nil, PChar(FullCmd), nil, nil, True,
                       CREATE_NO_WINDOW, nil, WorkDirPtr, SI, PI) then
  begin
    CloseHandle(ReadPipe);
    CloseHandle(WritePipe);
    Output.Add(Format(
      'Could not launch "%s". Is it installed and on PATH?' + sLineBreak +
      'Nao foi possivel iniciar "%s". Esta instalado e no PATH?',
      [Command, Command]));
    Exit;
  end;

  CloseHandle(WritePipe); // close write end so ReadFile returns when process exits

  // Read output / Le a saida
  Buf := '';
  repeat
    BytesRead := 0;
    if not ReadFile(ReadPipe, Buffer, SizeOf(Buffer) - 1, BytesRead, nil) then Break;
    if BytesRead = 0 then Break;
    Buffer[BytesRead] := #0;
    Buf := Buf + string(AnsiString(Buffer));
  until False;

  CloseHandle(ReadPipe);
  WaitForSingleObject(PI.hProcess, TimeoutMs);
  GetExitCodeProcess(PI.hProcess, ExitCode);
  CloseHandle(PI.hThread);
  CloseHandle(PI.hProcess);

  // Split output into lines / Divide saida em linhas
  Lines := TStringList.Create;
  try
    Lines.Text := Buf;
    Output.AddStrings(Lines);
  finally Lines.Free; end;

  Result := (ExitCode = 0);
end;

// ---------------------------------------------------------------------------
//  Write source to a temp file / Escreve o fonte em arquivo temporario
// ---------------------------------------------------------------------------

function TRunnerManager.WriteTempFile(const Source, Ext, Encoding: string): string;
var
  TmpDir  : string;
  TmpPath : string;
  Enc     : TEncoding;
begin
  TmpDir  := TPath.GetTempPath;
  TmpPath := TPath.Combine(TmpDir, 'pythia_run_' +
             IntToStr(GetTickCount) + Ext);
  if SameText(Encoding, 'utf-8') or SameText(Encoding, 'utf8') then
    Enc := TEncoding.UTF8
  else
    Enc := TEncoding.Default;
  TFile.WriteAllText(TmpPath, Source, Enc);
  Result := TmpPath;
end;

// ---------------------------------------------------------------------------
//  Template expansion helpers / Auxiliares de expansao de templates
// ---------------------------------------------------------------------------

function TRunnerManager.ExpandArgs(const Template, FilePath: string): string;
begin
  Result := StringReplace(Template, '{file}',    FilePath,                [rfReplaceAll]);
  Result := StringReplace(Result,   '{filedir}', ExtractFilePath(FilePath),[rfReplaceAll]);
  Result := StringReplace(Result,   '{filename}',ExtractFileName(FilePath),[rfReplaceAll]);
end;

function TRunnerManager.ExpandWorkDir(const Template, FilePath: string): string;
begin
  if Template = '{filedir}' then
    Result := ExtractFilePath(FilePath)
  else if Template = '' then
    Result := ''
  else
    Result := Template;
end;

// ---------------------------------------------------------------------------
//  Global init / Inicializacao global
// ---------------------------------------------------------------------------

procedure InitRunners;
begin
  if not Assigned(Runners) then Runners := TRunnerManager.Create;
end;

initialization
  Runners := nil;

finalization
  Runners.Free;
  Runners := nil;

end.
