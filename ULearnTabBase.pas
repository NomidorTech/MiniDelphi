unit ULearnTabBase;

// =============================================================================
// Pythia -- Pascal learning environment / ambiente de aprendizado Pascal
// Copyright (C) 2026 Nomidor Software, LLC.
// GPL v3 -- see/veja https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
//
//  ULearnTabBase.pas  --  Runner-aware Learn tab engine
//                         Motor da aba Learn ciente do runner
//
//  English:
//  --------
//  This unit provides the base Learn tab UI engine. It is decoupled from
//  any specific language. The curriculum is injected via TLearnCurriculum.
//  The runner is injected via TRunner. Checking answers uses the runner
//  to execute code, so Python, Lua, etc. all work identically.
//
//  One TLearnTabBase instance is created per installed runner that has
//  a curriculum. UMainForm loops over Runners.AllRunners at startup and
//  creates tabs dynamically.
//
//  Português:
//  ----------
//  Esta unidade fornece o motor base da aba Learn. Ela e desacoplada de
//  qualquer linguagem especifica. O curriculo e injetado via TLearnCurriculum.
//  O runner e injetado via TRunner. A verificacao de respostas usa o runner
//  para executar o codigo, entao Python, Lua, etc. funcionam identicamente.
//
//  Uma instancia de TLearnTabBase e criada por runner instalado que tenha
//  um curriculo. UMainForm percorre Runners.AllRunners na inicializacao
//  e cria abas dinamicamente.
// =============================================================================

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.IniFiles, System.IOUtils,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Graphics, Vcl.ComCtrls, Vcl.Dialogs, System.UITypes,
  URunnerManager;

type
  // -----------------------------------------------------------------------
  //  Answer checking strategy
  //  Estrategia de verificacao de resposta
  // -----------------------------------------------------------------------
  TCheckKind = (
    ckExactOutput,    // output must match exactly / saida deve corresponder exatamente
    ckContainsAll,    // output must contain all pipe-separated strings
                      // saida deve conter todas as strings separadas por pipe
    ckOutputIsNumber, // output (trimmed) must be a number within tolerance
                      // saida deve ser um numero dentro da tolerancia
    ckOutputInRange,  // output number must be in [Lo, Hi]
    ckLineCount,      // output must have exactly N lines
    ckAny             // any non-empty output passes / qualquer saida nao vazia passa
  );

  // -----------------------------------------------------------------------
  //  One programming challenge / Um desafio de programacao
  // -----------------------------------------------------------------------
  TLearnChallenge = record
    ID            : Integer;    // unique, never reuse / unico, nunca reutilizar
    Title         : string;
    Instruction   : string;
    Hint          : string;
    Starter       : string;     // pre-filled code skeleton
    Solution      : string;
    CheckKind     : TCheckKind;
    Expected      : string;     // pipe-separated for ckContainsAll
    ExpectedNum   : Double;     // for ckOutputIsNumber
    RangeLo       : Double;     // for ckOutputInRange
    RangeHi       : Double;
    LineCount     : Integer;    // for ckLineCount
    Points        : Integer;
  end;

  // -----------------------------------------------------------------------
  //  One lesson (named group of challenges) / Uma licao
  // -----------------------------------------------------------------------
  TLearnLesson = record
    Number     : Integer;
    Title      : string;
    Intro      : string;
    Challenges : TArray<TLearnChallenge>;
  end;

  // -----------------------------------------------------------------------
  //  Abstract curriculum -- subclass per language
  //  Curriculo abstrato -- subclasse por linguagem
  // -----------------------------------------------------------------------
  TLearnCurriculumBase = class
  protected
    FLessons : TArray<TLearnLesson>;
    procedure Build; virtual; abstract;
  public
    constructor Create;
    function LessonCount    : Integer;
    function GetLesson(I: Integer): TLearnLesson;
    function TotalChallenges: Integer;
    function TotalPoints    : Integer;
  end;

  // -----------------------------------------------------------------------
  //  Progress store -- persists per language
  //  Armazem de progresso -- persiste por linguagem
  // -----------------------------------------------------------------------
  TLearnProgress = class
  private
    FPath : string;
    FIni  : TIniFile;
    FName : string;
    FPts  : Integer;
  public
    constructor Create(const RunnerCode: string);
    destructor  Destroy; override;
    function  IsComplete(ChallengeID: Integer): Boolean;
    procedure MarkComplete(ChallengeID: Integer);
    procedure Reset;
    function  CompletedCount: Integer;
    function  EarnedPoints  : Integer;
    procedure AddPoints(N: Integer);
    procedure SaveName;
    procedure LoadName;
    property  StudentName : string read FName write FName;
  end;

  // -----------------------------------------------------------------------
  //  Answer checker -- runner-aware
  //  Verificador de respostas -- ciente do runner
  // -----------------------------------------------------------------------
  TLearnChecker = class
  public
    class function Check(const Ch: TLearnChallenge;
                         const Source: string;
                         const Runner: TRunner;
                         out Msg: string): Boolean;
  private
    class function NormalizeOutput(Lines: TStrings): string;
    class function TrimOutput(Lines: TStrings): string;
  end;

  // -----------------------------------------------------------------------
  //  The learn tab UI -- one instance per language
  //  A UI da aba learn -- uma instancia por linguagem
  // -----------------------------------------------------------------------
  TLearnTabBase = class
  private
    FParent     : TWinControl;
    FCurriculum : TLearnCurriculumBase;
    FProgress   : TLearnProgress;
    FRunner     : TRunner;           // which language we're teaching
    FRunnerCode : string;

    FCurLesson    : Integer;
    FCurChallenge : Integer;

    // UI controls
    FOuterPanel   : TPanel;
    FNavPanel     : TPanel;
    FNavTree      : TTreeView;
    FLabelScore   : TLabel;
    FLabelName    : TLabel;
    FEditName     : TEdit;
    FBtnSaveName  : TButton;
    FBtnReset     : TButton;
    FContentPanel : TPanel;
    FHeaderPanel  : TPanel;
    FLabelLesson  : TLabel;
    FLabelStars   : TLabel;
    FSplitIntroCode : TSplitter;   // between intro and code
    FSplitOutput    : TSplitter;   // between result and output
    FIntroMemo    : TMemo;
    FCodeLabel    : TLabel;
    FCodeMemo     : TMemo;
    FHintPanel    : TPanel;
    FBtnHint      : TButton;
    FBtnCheck     : TButton;
    FBtnSolution  : TButton;
    FBtnPrev      : TButton;
    FBtnNext      : TButton;
    FResultPanel  : TPanel;
    FResultLabel  : TLabel;
    FOutputLabel  : TLabel;
    FOutputMemo   : TMemo;

    procedure BuildUI;
    procedure BuildNavTree;
    procedure LoadChallenge;
    procedure UpdateScore;
    procedure ShowResult(const Msg: string; Pass: Boolean);

    function CurrentLesson   : TLearnLesson;
    function CurrentChallenge: TLearnChallenge;

    procedure OnNavSelect (Sender: TObject; Node: TTreeNode);
    procedure OnCheck     (Sender: TObject);
    procedure OnHint      (Sender: TObject);
    procedure OnSolution  (Sender: TObject);
    procedure OnPrev      (Sender: TObject);
    procedure OnNext      (Sender: TObject);
    procedure OnSaveName  (Sender: TObject);
    procedure OnReset     (Sender: TObject);

  public
    // ARunner must be a valid loaded runner with IsAvailable = True
    // ARunner deve ser um runner valido carregado com IsAvailable = True
    constructor Create(AParent: TWinControl;
                       ARunner: TRunner;
                       ACurriculum: TLearnCurriculumBase);
    destructor  Destroy; override;
  end;

// =============================================================================
implementation
// =============================================================================

uses
  System.Math;

// ---------------------------------------------------------------------------
//  TLearnCurriculumBase
// ---------------------------------------------------------------------------

constructor TLearnCurriculumBase.Create;
begin
  inherited Create;
  Build;
end;

function TLearnCurriculumBase.LessonCount: Integer;
begin
  Result := Length(FLessons);
end;

function TLearnCurriculumBase.GetLesson(I: Integer): TLearnLesson;
begin
  Result := FLessons[I];
end;

function TLearnCurriculumBase.TotalChallenges: Integer;
var I : Integer;
begin
  Result := 0;
  for I := 0 to High(FLessons) do
    Result := Result + Length(FLessons[I].Challenges);
end;

function TLearnCurriculumBase.TotalPoints: Integer;
var I, J : Integer;
begin
  Result := 0;
  for I := 0 to High(FLessons) do
    for J := 0 to High(FLessons[I].Challenges) do
      Result := Result + FLessons[I].Challenges[J].Points;
end;

// ---------------------------------------------------------------------------
//  TLearnProgress -- one INI per runner code
//  Um INI por codigo de runner
// ---------------------------------------------------------------------------

constructor TLearnProgress.Create(const RunnerCode: string);
begin
  inherited Create;
  FPath := ExtractFilePath(ParamStr(0)) +
           'learn_progress_' + RunnerCode + '.ini';
  FIni  := TIniFile.Create(FPath);
  FPts  := FIni.ReadInteger('Progress', 'Points', 0);
  LoadName;
end;

destructor TLearnProgress.Destroy;
begin
  FIni.Free;
  inherited;
end;

function TLearnProgress.IsComplete(ChallengeID: Integer): Boolean;
begin
  Result := FIni.ReadBool('Done', IntToStr(ChallengeID), False);
end;

procedure TLearnProgress.MarkComplete(ChallengeID: Integer);
begin
  FIni.WriteBool('Done', IntToStr(ChallengeID), True);
end;

procedure TLearnProgress.AddPoints(N: Integer);
begin
  FPts := FPts + N;
  FIni.WriteInteger('Progress', 'Points', FPts);
end;

function TLearnProgress.EarnedPoints: Integer;
begin
  Result := FPts;
end;

function TLearnProgress.CompletedCount: Integer;
var Keys : TStringList;
begin
  Keys := TStringList.Create;
  try
    FIni.ReadSection('Done', Keys);
    Result := Keys.Count;
  finally Keys.Free; end;
end;

procedure TLearnProgress.Reset;
begin
  FIni.EraseSection('Done');
  FIni.EraseSection('Progress');
  FPts := 0;
end;

procedure TLearnProgress.SaveName;
begin
  FIni.WriteString('Student', 'Name', FName);
end;

procedure TLearnProgress.LoadName;
begin
  FName := FIni.ReadString('Student', 'Name', '');
end;

// ---------------------------------------------------------------------------
//  TLearnChecker -- runs code via the runner, checks output
//  Roda o codigo via runner, verifica a saida
// ---------------------------------------------------------------------------

class function TLearnChecker.Check(const Ch: TLearnChallenge;
  const Source: string; const Runner: TRunner; out Msg: string): Boolean;
var
  Output   : TStringList;
  OutStr   : string;
  Parts    : TArray<string>;
  Num      : Double;
  AllFound : Boolean;
  Part     : string;
begin
  Result := False;
  Msg    := '';

  if Trim(Source) = '' then
  begin
    Msg := 'Your code is empty. Write something first!';
    Exit;
  end;

  Output := TStringList.Create;
  try
    // Execute using the appropriate runner
    // Executa usando o runner apropriado
    // Temporarily switch to the lesson's runner, execute, then restore
    // Troca temporariamente para o runner da lição, executa, depois restaura
    var PrevCode := Runners.Active.Code;
    Runners.SetRunner(Runner.Code);
    Runners.Execute(Source, '', Output);
    Runners.SetRunner(PrevCode);
    OutStr := NormalizeOutput(Output);

    case Ch.CheckKind of
      ckExactOutput:
      begin
        Result := Trim(OutStr) = Trim(Ch.Expected);
        if Result then Msg := 'Correct! Well done.'
        else Msg := 'Not quite. Expected: ' + Ch.Expected +
                    sLineBreak + 'Got: ' + Trim(OutStr);
      end;

      ckContainsAll:
      begin
        Parts    := Ch.Expected.Split(['|']);
        AllFound := True;
        for Part in Parts do
          if Pos(Trim(Part), OutStr) = 0 then AllFound := False;
        Result := AllFound;
        if Result then Msg := 'Correct! All required output found.'
        else Msg := 'Missing some expected output. Check your program.';
      end;

      ckOutputIsNumber:
      begin
        Result := TryStrToFloat(Trim(OutStr), Num) and
                  (Abs(Num - Ch.ExpectedNum) < 0.001);
        if Result then Msg := 'Correct! Answer: ' + Trim(OutStr)
        else Msg := 'Expected a number close to ' +
                    FloatToStr(Ch.ExpectedNum) + ', got: ' + Trim(OutStr);
      end;

      ckOutputInRange:
      begin
        Result := TryStrToFloat(Trim(OutStr), Num) and
                  (Num >= Ch.RangeLo) and (Num <= Ch.RangeHi);
        if Result then Msg := 'Correct!'
        else Msg := Format('Expected a value between %g and %g, got: %s',
                    [Ch.RangeLo, Ch.RangeHi, Trim(OutStr)]);
      end;

      ckLineCount:
      begin
        Result := Output.Count = Ch.LineCount;
        if Result then Msg := 'Correct!'
        else Msg := Format('Expected %d line(s) of output, got %d.',
                    [Ch.LineCount, Output.Count]);
      end;

      ckAny:
      begin
        Result := Trim(OutStr) <> '';
        if Result then Msg := 'Great! Your program produced output.'
        else Msg := 'Your program produced no output.';
      end;
    end;
  finally
    Output.Free;
  end;
end;

class function TLearnChecker.NormalizeOutput(Lines: TStrings): string;
var I : Integer;
begin
  Result := '';
  for I := 0 to Lines.Count - 1 do
  begin
    if I > 0 then Result := Result + sLineBreak;
    Result := Result + Lines[I];
  end;
end;

class function TLearnChecker.TrimOutput(Lines: TStrings): string;
begin
  Result := Trim(NormalizeOutput(Lines));
end;

// ---------------------------------------------------------------------------
//  TLearnTabBase UI
// ---------------------------------------------------------------------------

constructor TLearnTabBase.Create(AParent: TWinControl;
  ARunner: TRunner; ACurriculum: TLearnCurriculumBase);
begin
  inherited Create;
  FParent     := AParent;
  FRunner     := ARunner;
  FRunnerCode := ARunner.Code;
  FCurriculum := ACurriculum;
  FProgress   := TLearnProgress.Create(FRunnerCode);
  FCurLesson    := 0;
  FCurChallenge := 0;
  BuildUI;
  BuildNavTree;
  LoadChallenge;
  UpdateScore;
end;

destructor TLearnTabBase.Destroy;
begin
  FCurriculum.Free;
  FProgress.Free;
  inherited;
end;

function TLearnTabBase.CurrentLesson: TLearnLesson;
begin
  Result := FCurriculum.GetLesson(FCurLesson);
end;

function TLearnTabBase.CurrentChallenge: TLearnChallenge;
begin
  Result := CurrentLesson.Challenges[FCurChallenge];
end;

procedure TLearnTabBase.BuildUI;
const
  NAV_W  = 220;
  BTN_H  = 28;
  PAD    = 6;
  DARK   = $00252526;
  DARKER = $001E1E1E;
  ACCENT = $00C87533;
  GREEN  = $0056D364;
begin
  FOuterPanel            := TPanel.Create(FParent);
  FOuterPanel.Parent     := FParent;
  FOuterPanel.Align      := alClient;
  FOuterPanel.BevelOuter := bvNone;
  FOuterPanel.Color      := DARKER;

  // Left nav
  FNavPanel              := TPanel.Create(FOuterPanel);
  FNavPanel.Parent       := FOuterPanel;
  FNavPanel.Align        := alLeft;
  FNavPanel.Width        := NAV_W;
  FNavPanel.BevelOuter   := bvNone;
  FNavPanel.Color        := DARK;

  FLabelScore            := TLabel.Create(FNavPanel);
  FLabelScore.Parent     := FNavPanel;
  FLabelScore.Align      := alTop;
  FLabelScore.Height     := 20;
  FLabelScore.Font.Color := ACCENT;
  FLabelScore.Font.Style := [fsBold];
  FLabelScore.Caption    := 'Score: 0 pts';

  FLabelName             := TLabel.Create(FNavPanel);
  FLabelName.Parent      := FNavPanel;
  FLabelName.Align       := alTop;
  FLabelName.Height      := 18;
  FLabelName.Caption     := 'Your name:';
  FLabelName.Font.Color  := clSilver;

  FEditName              := TEdit.Create(FNavPanel);
  FEditName.Parent       := FNavPanel;
  FEditName.Align        := alTop;
  FEditName.Height       := 24;
  FEditName.Text         := FProgress.StudentName;

  FBtnSaveName           := TButton.Create(FNavPanel);
  FBtnSaveName.Parent    := FNavPanel;
  FBtnSaveName.Align     := alTop;
  FBtnSaveName.Height    := BTN_H;
  FBtnSaveName.Caption   := 'Save Name';
  FBtnSaveName.OnClick   := OnSaveName;

  FNavTree               := TTreeView.Create(FNavPanel);
  FNavTree.Parent        := FNavPanel;
  FNavTree.Align         := alClient;
  FNavTree.ReadOnly      := True;
  FNavTree.HideSelection := False;
  FNavTree.OnChange      := nil;  // wired after BuildNavTree

  FBtnReset              := TButton.Create(FNavPanel);
  FBtnReset.Parent       := FNavPanel;
  FBtnReset.Align        := alBottom;
  FBtnReset.Height       := BTN_H;
  FBtnReset.Caption      := 'Reset All Progress';
  FBtnReset.OnClick      := OnReset;

  // Right content
  FContentPanel          := TPanel.Create(FOuterPanel);
  FContentPanel.Parent   := FOuterPanel;
  FContentPanel.Align    := alClient;
  FContentPanel.BevelOuter := bvNone;
  FContentPanel.Color    := DARKER;

  // Header -- color changes per language / muda por linguagem
  FHeaderPanel           := TPanel.Create(FContentPanel);
  FHeaderPanel.Parent    := FContentPanel;
  FHeaderPanel.Align     := alTop;
  FHeaderPanel.Height    := 36;
  FHeaderPanel.BevelOuter := bvNone;
  // Use runner color for header / Usa a cor do runner para o cabecalho
  var HeaderColor : Integer;
  if FRunner.Color <> '' then
  begin
    var C := StringReplace(FRunner.Color, '#', '$', [rfReplaceAll]);
    // Convert #RRGGBB to TColor (BGR) / Converte #RRGGBB para TColor (BGR)
    try
      var R := StrToInt('$' + Copy(FRunner.Color, 2, 2));
      var G := StrToInt('$' + Copy(FRunner.Color, 4, 2));
      var B := StrToInt('$' + Copy(FRunner.Color, 6, 2));
      HeaderColor := RGB(R, G, B);
    except
      HeaderColor := $00003366;
    end;
  end
  else HeaderColor := $00003366;
  FHeaderPanel.Color := HeaderColor;

  FLabelLesson           := TLabel.Create(FHeaderPanel);
  FLabelLesson.Parent    := FHeaderPanel;
  FLabelLesson.Left      := 8;
  FLabelLesson.Top       := 8;
  FLabelLesson.Width     := 600;
  FLabelLesson.Font.Color := clWhite;
  FLabelLesson.Font.Style := [fsBold];
  FLabelLesson.Font.Size  := 11;
  FLabelLesson.Caption   := '';

  FLabelStars            := TLabel.Create(FHeaderPanel);
  FLabelStars.Parent     := FHeaderPanel;
  FLabelStars.Left       := 620;
  FLabelStars.Top        := 8;
  FLabelStars.Width      := 100;
  FLabelStars.Font.Color := ACCENT;
  FLabelStars.Font.Size  := 12;
  FLabelStars.Caption    := '';

  FIntroMemo             := TMemo.Create(FContentPanel);
  FIntroMemo.Parent      := FContentPanel;
  FIntroMemo.Align       := alTop;
  FIntroMemo.Height      := 140;
  FIntroMemo.ReadOnly    := True;
  FIntroMemo.WordWrap    := True;
  FIntroMemo.ScrollBars  := ssVertical;
  FIntroMemo.Font.Name   := 'Consolas';
  FIntroMemo.Font.Size   := 9;
  FIntroMemo.Color       := $00002040;
  FIntroMemo.Font.Color  := $00E0E0E0;

  // Splitter between intro and code / Divisor entre intro e código
  FSplitIntroCode        := TSplitter.Create(FContentPanel);
  FSplitIntroCode.Parent := FContentPanel;
  FSplitIntroCode.Align  := alTop;
  FSplitIntroCode.Height := 4;

  FCodeLabel             := TLabel.Create(FContentPanel);
  FCodeLabel.Parent      := FContentPanel;
  FCodeLabel.Align       := alTop;
  FCodeLabel.Height      := 20;
  FCodeLabel.Caption     := '  Your code:';
  FCodeLabel.Font.Color  := ACCENT;
  FCodeLabel.Font.Style  := [fsBold];

  FCodeMemo              := TMemo.Create(FContentPanel);
  FCodeMemo.Parent       := FContentPanel;
  FCodeMemo.Align        := alTop;
  FCodeMemo.Height       := 160;
  FCodeMemo.WordWrap     := False;
  FCodeMemo.ScrollBars   := ssBoth;
  FCodeMemo.Font.Name    := 'Consolas';
  FCodeMemo.Font.Size    := 10;
  FCodeMemo.Color        := $001E1E1E;
  FCodeMemo.Font.Color   := $00DCDCDC;

  // Button strip
  FHintPanel             := TPanel.Create(FContentPanel);
  FHintPanel.Parent      := FContentPanel;
  FHintPanel.Align       := alTop;
  FHintPanel.Height      := BTN_H + PAD * 2;
  FHintPanel.BevelOuter  := bvNone;
  FHintPanel.Color       := DARK;

  FBtnHint               := TButton.Create(FHintPanel);
  FBtnHint.Parent        := FHintPanel;
  FBtnHint.Caption       := '[?] Hint';
  FBtnHint.SetBounds(PAD, PAD, 90, BTN_H);
  FBtnHint.OnClick       := OnHint;

  FBtnCheck              := TButton.Create(FHintPanel);
  FBtnCheck.Parent       := FHintPanel;
  FBtnCheck.Caption      := 'Run & Check';
  FBtnCheck.SetBounds(PAD + 96, PAD, 120, BTN_H);
  FBtnCheck.Font.Style   := [fsBold];
  FBtnCheck.OnClick      := OnCheck;

  FBtnSolution           := TButton.Create(FHintPanel);
  FBtnSolution.Parent    := FHintPanel;
  FBtnSolution.Caption   := 'Solution';
  FBtnSolution.SetBounds(PAD + 222, PAD, 100, BTN_H);
  FBtnSolution.OnClick   := OnSolution;

  FBtnPrev               := TButton.Create(FHintPanel);
  FBtnPrev.Parent        := FHintPanel;
  FBtnPrev.Caption       := '< Prev';
  FBtnPrev.SetBounds(PAD + 330, PAD, 80, BTN_H);
  FBtnPrev.OnClick       := OnPrev;

  FBtnNext               := TButton.Create(FHintPanel);
  FBtnNext.Parent        := FHintPanel;
  FBtnNext.Caption       := 'Next >';
  FBtnNext.SetBounds(PAD + 416, PAD, 80, BTN_H);
  FBtnNext.OnClick       := OnNext;

  FResultPanel           := TPanel.Create(FContentPanel);
  FResultPanel.Parent    := FContentPanel;
  FResultPanel.Align     := alTop;
  FResultPanel.Height    := 40;
  FResultPanel.BevelOuter := bvNone;
  FResultPanel.Color     := DARKER;

  FResultLabel           := TLabel.Create(FResultPanel);
  FResultLabel.Parent    := FResultPanel;
  FResultLabel.SetBounds(8, 10, 700, 20);
  FResultLabel.Font.Name := 'Consolas';
  FResultLabel.Font.Size := 10;
  FResultLabel.Font.Style := [fsBold];
  FResultLabel.Caption   := '';

  // Splitter between result and output / Divisor entre resultado e saída
  FSplitOutput        := TSplitter.Create(FContentPanel);
  FSplitOutput.Parent := FContentPanel;
  FSplitOutput.Align  := alTop;
  FSplitOutput.Height := 4;

  FOutputLabel           := TLabel.Create(FContentPanel);
  FOutputLabel.Parent    := FContentPanel;
  FOutputLabel.Align     := alTop;
  FOutputLabel.Height    := 18;
  FOutputLabel.Caption   := '  Program output:';
  FOutputLabel.Font.Color := clSilver;

  FOutputMemo            := TMemo.Create(FContentPanel);
  FOutputMemo.Parent     := FContentPanel;
  FOutputMemo.Align      := alClient;
  FOutputMemo.ReadOnly   := True;
  FOutputMemo.ScrollBars := ssVertical;
  FOutputMemo.Font.Name  := 'Consolas';
  FOutputMemo.Font.Size  := 9;
  FOutputMemo.Color      := $00121212;
  FOutputMemo.Font.Color := GREEN;
end;

procedure TLearnTabBase.BuildNavTree;
var
  I, J   : Integer;
  Lesson : TLearnLesson;
  Ch     : TLearnChallenge;
  LNode  : TTreeNode;
  Mark   : string;
begin
  FNavTree.Items.Clear;
  for I := 0 to FCurriculum.LessonCount - 1 do
  begin
    Lesson := FCurriculum.GetLesson(I);
    LNode  := FNavTree.Items.Add(nil,
      Format('%d. %s', [Lesson.Number, Lesson.Title]));
    LNode.Data := Pointer(NativeInt(-1));  // lesson header sentinel — negative = not selectable
    for J := 0 to High(Lesson.Challenges) do
    begin
      Ch := Lesson.Challenges[J];
      if FProgress.IsComplete(Ch.ID) then Mark := '[x] '
      else Mark := '[ ] ';
      // Encode as I*1000+J; always >= 0 / Codifica como I*1000+J; sempre >= 0
      FNavTree.Items.AddChild(LNode, Mark + Ch.Title).Data :=
        Pointer(NativeInt(I * 1000 + J));
    end;
    LNode.Expand(False);
  end;

  // Wire OnChange AFTER tree is built to avoid spurious LoadChallenge calls
  // Liga OnChange APÓS a árvore ser construída para evitar chamadas espúrias
  FNavTree.OnChange := OnNavSelect;
end;

procedure TLearnTabBase.LoadChallenge;
var
  Lesson : TLearnLesson;
  Ch     : TLearnChallenge;
begin
  Lesson := CurrentLesson;
  Ch     := CurrentChallenge;

  FLabelLesson.Caption := Format(
    'Lesson %d  --  %s   |   Challenge %d of %d: %s',
    [Lesson.Number, Lesson.Title,
     FCurChallenge + 1, Length(Lesson.Challenges), Ch.Title]);

  FIntroMemo.Lines.Text :=
    Lesson.Intro + #13#10 + #13#10 +
    '------------------------------------------------------' + #13#10 +
    'CHALLENGE ' + IntToStr(FCurChallenge + 1) + ': ' + Ch.Title + #13#10 +
    '------------------------------------------------------' + #13#10 +
    Ch.Instruction;

  // Use language-appropriate starter / Usa codigo inicial da linguagem
  if Ch.Starter <> '' then
    FCodeMemo.Lines.Text := Ch.Starter
  else
    FCodeMemo.Lines.Text := FRunner.StarterCode;

  FResultLabel.Caption   := '';
  FResultPanel.Color     := $00252526;
  FOutputMemo.Lines.Clear;
end;

procedure TLearnTabBase.UpdateScore;
var
  Total : Integer;
begin
  Total := FCurriculum.TotalChallenges;
  FLabelScore.Caption := Format('Score: %d pts  (%d / %d done)',
    [FProgress.EarnedPoints,
     FProgress.CompletedCount,
     Total]);
end;

procedure TLearnTabBase.ShowResult(const Msg: string; Pass: Boolean);
begin
  FResultLabel.Caption := Msg;
  if Pass then FResultPanel.Color := $00003300
  else         FResultPanel.Color := $00330000;
end;

procedure TLearnTabBase.OnNavSelect(Sender: TObject; Node: TTreeNode);
var Encoded : NativeInt;
begin
  if not Assigned(Node) or (Node.Data = nil) then Exit;
  Encoded := NativeInt(Node.Data);

  // -1 = lesson header node, not a challenge — ignore click
  // -1 = nó de cabeçalho da lição, não é desafio — ignora clique
  if Encoded < 0 then Exit;

  // Challenge node: encoded as LessonIndex * 1000 + ChallengeIndex
  // Nó de desafio: codificado como LessonIndex * 1000 + ChallengeIndex
  FCurLesson    := Encoded div 1000;
  FCurChallenge := Encoded mod 1000;
  LoadChallenge;
end;

procedure TLearnTabBase.OnCheck(Sender: TObject);
var
  Ch   : TLearnChallenge;
  Msg  : string;
  Pass : Boolean;
begin
  Ch   := CurrentChallenge;
  FOutputMemo.Lines.Clear;

  // Run code via the runner and check output
  // Roda o codigo via runner e verifica a saida
  Pass := TLearnChecker.Check(Ch, FCodeMemo.Lines.Text, FRunner, Msg);
  ShowResult(Msg, Pass);

  if Pass and not FProgress.IsComplete(Ch.ID) then
  begin
    FProgress.MarkComplete(Ch.ID);
    FProgress.AddPoints(Ch.Points);
    UpdateScore;
    BuildNavTree;
    if FProgress.CompletedCount = FCurriculum.TotalChallenges then
      ShowResult('*** ALL CHALLENGES COMPLETE! Congratulations!', True);
  end;
end;

procedure TLearnTabBase.OnHint(Sender: TObject);
begin
  ShowResult('Hint: ' + CurrentChallenge.Hint, True);
end;

procedure TLearnTabBase.OnSolution(Sender: TObject);
begin
  if MessageDlg('Show the solution? This will replace your code.',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    FCodeMemo.Lines.Text := CurrentChallenge.Solution;
end;

procedure TLearnTabBase.OnPrev(Sender: TObject);
begin
  if FCurChallenge > 0 then Dec(FCurChallenge)
  else if FCurLesson > 0 then
  begin
    Dec(FCurLesson);
    FCurChallenge := High(CurrentLesson.Challenges);
  end;
  LoadChallenge;
end;

procedure TLearnTabBase.OnNext(Sender: TObject);
begin
  if FCurChallenge < High(CurrentLesson.Challenges) then
    Inc(FCurChallenge)
  else if FCurLesson < FCurriculum.LessonCount - 1 then
  begin
    Inc(FCurLesson);
    FCurChallenge := 0;
  end;
  LoadChallenge;
end;

procedure TLearnTabBase.OnSaveName(Sender: TObject);
begin
  FProgress.StudentName := Trim(FEditName.Text);
  FProgress.SaveName;
  ShowResult('Name saved: ' + FProgress.StudentName, True);
end;

procedure TLearnTabBase.OnReset(Sender: TObject);
begin
  if MessageDlg('Reset ALL progress for this language?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FProgress.Reset;
    BuildNavTree;
    UpdateScore;
    ShowResult('Progress reset.', True);
  end;
end;

end.
