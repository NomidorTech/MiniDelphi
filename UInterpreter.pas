unit UInterpreter;

// =============================================================================
// Pythia -- ambiente de aprendizado Pascal
// Copyright (C) 2026 Nomidor Software, LLC.
// GPL v3 — veja https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
//
//  UInterpreter.pas  -  Interpretador em modo árvore para o Pythia
//
//  Percorre a AST produzida pelo TParser e executa cada nó diretamente.
//  Nenhum código de máquina é gerado — este módulo É o "runtime".
//
//  Notas importantes:
//  - EExitSignal é capturada em CallRoutine e em Run para que Exit
//    funcione corretamente em funções e no bloco principal.
//  - Arrays dinâmicos usam TArrayValue com ponteiros PValue para evitar
//    dependência circular (TValue precisa ser declarado antes de TArrayValue).
//  - TValue.ArrVal é declarado como TObject e convertido para TArrayValue
//    via a função auxiliar AsArr() na implementação.
// =============================================================================

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.UITypes,
  System.Math, System.IOUtils, System.Win.Registry,
  UUnitLoader,
  USQLite,
  UObjectRuntime,
  UGraphics,
  Winapi.Windows, Winapi.ShellAPI,
  Vcl.Dialogs, Vcl.Forms, Vcl.FileCtrl,
  UAST;

type

  // -----------------------------------------------------------------------
  //  Enum dos tipos de valor em tempo de execução
  // -----------------------------------------------------------------------
  TValueKind = (
    vkInt,     // número inteiro (Int64)
    vkFloat,   // número real (Double)
    vkString,  // cadeia de caracteres
    vkBool,    // booleano
    vkNil,     // valor nulo / não inicializado
    vkObject,  // instância de objeto (TObjectInstance)
    vkArray    // array dinâmico (TArrayValue via TObject)
  );

  // -----------------------------------------------------------------------
  //  TValue — valor em tempo de execução
  //  ArrVal é TObject aqui; convertido para TArrayValue em runtime
  //  para evitar referência circular na seção interface.
  // -----------------------------------------------------------------------
  TValue = record
    // *** Todos os campos DEVEM vir antes dos métodos num record Delphi ***
    Kind   : TValueKind;
    IVal   : Int64;           // para vkInt e vkBool
    FVal   : Double;          // para vkFloat
    SVal   : string;          // para vkString
    BVal   : Boolean;         // para vkBool
    ObjVal : TObjectInstance; // para vkObject
    ArrVal : TObject;         // para vkArray (na prática é TArrayValue)

    class function MakeInt   (V: Int64)           : TValue; static;
    class function MakeFloat (V: Double)          : TValue; static;
    class function MakeStr   (V: string)          : TValue; static;
    class function MakeBool  (V: Boolean)         : TValue; static;
    class function MakeNil                        : TValue; static;
    class function MakeArray (V: TObject)         : TValue; static;
    class function MakeObject(V: TObjectInstance) : TValue; static;

    function ToStr  : string;
    function ToFloat: Double;
    function ToInt  : Int64;
    function ToBool : Boolean;
  end;

  // -----------------------------------------------------------------------
  //  Ponteiro para TValue — usado por TArrayValue
  // -----------------------------------------------------------------------
  PValue = ^TValue;

  // -----------------------------------------------------------------------
  //  Array dinâmico de TValue armazenado como ponteiros no heap
  //  Evita generics circulares (TList<TValue> não funciona antes de TValue)
  // -----------------------------------------------------------------------
  TArrayValue = class
  public
    Items : TList;   // cada elemento é um PValue alocado no heap
    constructor Create;
    destructor  Destroy; override;
    function  GetItem(Idx: Integer): TValue;
    procedure SetItem(Idx: Integer; const V: TValue);
    procedure AddItem(const V: TValue);
    function  Count: Integer;
  end;

  // -----------------------------------------------------------------------
  //  Exceções usadas para controle de fluxo
  // -----------------------------------------------------------------------
  EBreakSignal    = class(Exception);   // break dentro de loop
  EContinueSignal = class(Exception);   // continue dentro de loop
  EExitSignal     = class(Exception)    // exit dentro de função/procedimento
  public
    ReturnVal : TValue;
    constructor Create(const V: TValue);
  end;

  // -----------------------------------------------------------------------
  //  Ambiente de variáveis — dicionário nome→valor com escopo encadeado
  // -----------------------------------------------------------------------
  TEnvironment = class
  private
    FVars   : TDictionary<string, TValue>;
    FParent : TEnvironment;  // escopo pai (nil para o escopo global)
  public
    constructor Create(AParent: TEnvironment = nil);
    destructor  Destroy; override;
    procedure SetVar    (const Name: string; const Val: TValue);
    function  GetVar    (const Name: string; out Val: TValue): Boolean;
    function  HasVar    (const Name: string): Boolean;
    procedure DeclareVar(const Name: string; const Val: TValue);
  end;

  TRoutineEntry   = record Decl: TRoutineDecl; end;
  TVarDeclList    = TObjectList<TVarDecl>;
  TRoutineDeclMap = TDictionary<string, TRoutineDecl>;

  // Callback de confirmação para builtins Shell*
  TShellConfirmFunc = function(const Cmd: string): Boolean of object;

  // -----------------------------------------------------------------------
  //  O Interpretador
  // -----------------------------------------------------------------------
  TInterpreter = class
  private
    FProgram      : TProgramNode;
    FGlobal       : TEnvironment;
    FRoutines     : TRoutineDeclMap;
    FOutput       : TStrings;
    FInputLine    : string;
    FMaxSteps     : Int64;
    FSteps        : Int64;
    FSourcePath   : string;
    FSourceText   : string;
    FStop         : Boolean;
    FAllowShell   : Boolean;
    FShellConfirm : TShellConfirmFunc;

    procedure Tick;
    procedure RegisterRoutines;
    procedure DeclareVars(Env: TEnvironment; Decls: TVarDeclList);

    // Execução de comandos
    procedure ExecBlock      (Node: TBlockStmt;   Env: TEnvironment);
    procedure ExecStmt       (Node: TStmtNode;    Env: TEnvironment);
    procedure ExecAssign     (Node: TAssignStmt;  Env: TEnvironment);
    procedure ExecWriteln    (Node: TWritelnStmt; Env: TEnvironment);
    procedure ExecReadln     (Node: TReadlnStmt;  Env: TEnvironment);
    procedure ExecIf         (Node: TIfStmt;      Env: TEnvironment);
    procedure ExecWhile      (Node: TWhileStmt;   Env: TEnvironment);
    procedure ExecRepeat     (Node: TRepeatStmt;  Env: TEnvironment);
    procedure ExecFor        (Node: TForStmt;     Env: TEnvironment);
    procedure ExecCall       (Node: TCallStmt;    Env: TEnvironment);
    procedure ExecExit       (Node: TExitStmt;    Env: TEnvironment);
    procedure ExecCase       (Node: TCaseStmt;           Env: TEnvironment);
    procedure ExecCaseOf     (Node: TCaseOfStmt;         Env: TEnvironment);
    procedure ExecFieldAssign(Node: TFieldAssignStmt;    Env: TEnvironment);
    procedure ExecMethodCall (Node: TMethodCallStmt;     Env: TEnvironment);
    procedure ExecInherited  (Node: TInheritedCallStmt;  Env: TEnvironment);
    procedure ExecArrayIndexAssign(Node: TArrayIndexAssignStmt; Env: TEnvironment);

    // Avaliação de expressões
    function EvalExpr          (Node: TExprNode;         Env: TEnvironment): TValue;
    function EvalBinOp         (Node: TBinOpExpr;        Env: TEnvironment): TValue;
    function EvalUnary         (Node: TUnaryExpr;        Env: TEnvironment): TValue;
    function EvalCallExpr      (Node: TCallExpr;         Env: TEnvironment): TValue;
    function EvalFieldExpr     (Node: TFieldExpr;        Env: TEnvironment): TValue;
    function EvalMethodCallExpr(Node: TMethodCallExpr;   Env: TEnvironment): TValue;
    function EvalCreateExpr    (Node: TCreateExpr;       Env: TEnvironment): TValue;
    function EvalArrayIndex    (Node: TArrayIndexExpr;   Env: TEnvironment): TValue;
    function EvalIsExpr        (Obj: TValue; const TypeName: string): TValue;
    function InvokeMethod      (Obj: TObjectInstance; M: TMethodDecl;
                                Args: TExprList; CallerEnv: TEnvironment): TValue;
    procedure InitObjectFields (Obj: TObjectInstance);

    function CallRoutine(const Name: string; Args: TExprList;
                         CallerEnv: TEnvironment): TValue;
    function CallBuiltin(const Name: string; Args: TExprList;
                         CallerEnv: TEnvironment; out Val: TValue): Boolean;
    procedure Output(const S: string);

  public
    constructor Create(AProgram: TProgramNode; AOutput: TStrings);
    destructor  Destroy; override;
    procedure Run;
    procedure RequestStop;

    property InputLine   : string            read FInputLine   write FInputLine;
    property MaxSteps    : Int64             read FMaxSteps    write FMaxSteps;
    property SourcePath  : string            read FSourcePath  write FSourcePath;
    property SourceText  : string            read FSourceText  write FSourceText;
    property AllowShell  : Boolean           read FAllowShell  write FAllowShell;
    property ShellConfirm: TShellConfirmFunc read FShellConfirm write FShellConfirm;
  end;

// =============================================================================
implementation
uses IniFiles, ULanguage;
// =============================================================================

function IfThenInt(B: Boolean; T, F: Integer): Integer; forward;

// ---------------------------------------------------------------------------
//  Auxiliar: converte TObject para TArrayValue com segurança
// ---------------------------------------------------------------------------
function AsArr(V: TObject): TArrayValue; inline;
begin
  Result := TArrayValue(V);
end;

// ===========================================================================
//  TValue — construtores estáticos
// ===========================================================================

class function TValue.MakeInt(V: Int64): TValue;
begin
  Result.Kind := vkInt; Result.IVal := V; Result.FVal := V;
  Result.SVal := ''; Result.BVal := False; Result.ArrVal := nil;
end;

class function TValue.MakeFloat(V: Double): TValue;
begin
  Result.Kind := vkFloat; Result.IVal := Round(V); Result.FVal := V;
  Result.SVal := ''; Result.BVal := False; Result.ArrVal := nil;
end;

class function TValue.MakeStr(V: string): TValue;
begin
  Result.Kind := vkString; Result.IVal := 0; Result.FVal := 0;
  Result.SVal := V; Result.BVal := False; Result.ArrVal := nil;
end;

class function TValue.MakeBool(V: Boolean): TValue;
begin
  Result.Kind := vkBool; Result.IVal := Ord(V); Result.FVal := 0;
  Result.SVal := ''; Result.BVal := V; Result.ArrVal := nil;
end;

class function TValue.MakeObject(V: TObjectInstance): TValue;
begin
  Result.Kind := vkObject; Result.IVal := 0; Result.FVal := 0;
  Result.SVal := ''; Result.BVal := False; Result.ObjVal := V; Result.ArrVal := nil;
end;

class function TValue.MakeNil: TValue;
begin
  Result.Kind := vkNil; Result.IVal := 0; Result.FVal := 0;
  Result.SVal := ''; Result.BVal := False; Result.ArrVal := nil;
end;

class function TValue.MakeArray(V: TObject): TValue;
begin
  Result.Kind := vkArray; Result.IVal := 0; Result.FVal := 0;
  Result.SVal := ''; Result.BVal := False; Result.ObjVal := nil; Result.ArrVal := V;
end;

// ---------------------------------------------------------------------------
//  Conversões de TValue para tipos primitivos
// ---------------------------------------------------------------------------

function TValue.ToStr: string;
begin
  case Kind of
    vkInt    : Result := IntToStr(IVal);
    vkFloat  : Result := FloatToStr(FVal);
    vkString : Result := SVal;
    vkBool   : if BVal then Result := 'True' else Result := 'False';
    vkNil    : Result := 'nil';
    vkObject : if Assigned(ObjVal) then Result := '[' + ObjVal.ObjClass + ' objeto]'
               else Result := 'nil';
  else Result := '';
  end;
end;

function TValue.ToFloat: Double;
begin
  case Kind of
    vkInt    : Result := IVal;
    vkFloat  : Result := FVal;
    vkString : Result := StrToFloatDef(SVal, 0);
    vkBool   : Result := Ord(BVal);
  else         Result := 0;
  end;
end;

function TValue.ToInt: Int64;
begin
  case Kind of
    vkInt    : Result := IVal;
    vkFloat  : Result := Round(FVal);
    vkString : Result := StrToInt64Def(SVal, 0);
    vkBool   : Result := Ord(BVal);
  else         Result := 0;
  end;
end;

function TValue.ToBool: Boolean;
begin
  case Kind of
    vkBool   : Result := BVal;
    vkInt    : Result := IVal <> 0;
    vkFloat  : Result := FVal <> 0;
    vkString : Result := SVal <> '';
  else         Result := False;
  end;
end;

// ===========================================================================
//  TArrayValue — array dinâmico via ponteiros no heap
// ===========================================================================

constructor TArrayValue.Create;
begin
  inherited;
  Items := TList.Create;
end;

destructor TArrayValue.Destroy;
var I: Integer;
begin
  // Libera cada PValue alocado no heap
  for I := 0 to Items.Count - 1 do Dispose(PValue(Items[I]));
  Items.Free;
  inherited;
end;

function TArrayValue.GetItem(Idx: Integer): TValue;
begin
  Result := PValue(Items[Idx])^;
end;

procedure TArrayValue.SetItem(Idx: Integer; const V: TValue);
begin
  PValue(Items[Idx])^ := V;
end;

procedure TArrayValue.AddItem(const V: TValue);
var P: PValue;
begin
  New(P); P^ := V; Items.Add(P);
end;

function TArrayValue.Count: Integer;
begin
  Result := Items.Count;
end;

// ===========================================================================
//  EExitSignal
// ===========================================================================

constructor EExitSignal.Create(const V: TValue);
begin
  inherited Create('exit');
  ReturnVal := V;
end;

// ===========================================================================
//  TEnvironment — armazém de variáveis com escopo encadeado
// ===========================================================================

constructor TEnvironment.Create(AParent: TEnvironment);
begin
  inherited Create;
  FVars   := TDictionary<string, TValue>.Create;
  FParent := AParent;
end;

destructor TEnvironment.Destroy;
begin
  FVars.Free;
  inherited;
end;

// Declara variável neste escopo (força criação local mesmo se existe no pai)
procedure TEnvironment.DeclareVar(const Name: string; const Val: TValue);
begin
  FVars.AddOrSetValue(LowerCase(Name), Val);
end;

// Atribui valor — sobe a cadeia de escopos até encontrar a variável
procedure TEnvironment.SetVar(const Name: string; const Val: TValue);
var Key: string;
begin
  Key := LowerCase(Name);
  if FVars.ContainsKey(Key) then FVars[Key] := Val
  else if Assigned(FParent) then FParent.SetVar(Name, Val)
  else FVars.AddOrSetValue(Key, Val);  // declara automaticamente no escopo global
end;

// Lê valor — sobe a cadeia de escopos até encontrar
function TEnvironment.GetVar(const Name: string; out Val: TValue): Boolean;
var Key: string;
begin
  Key    := LowerCase(Name);
  Result := FVars.TryGetValue(Key, Val);
  if (not Result) and Assigned(FParent) then Result := FParent.GetVar(Name, Val);
end;

function TEnvironment.HasVar(const Name: string): Boolean;
var Dummy: TValue;
begin
  Result := GetVar(Name, Dummy);
end;

// ===========================================================================
//  TInterpreter
// ===========================================================================

procedure TInterpreter.Tick;
begin
  if FStop then
    raise Exception.Create(Lang.S(lsErrStopped));
  Inc(FSteps);
  if FSteps > FMaxSteps then
    raise Exception.Create(Lang.S(lsErrStepLimit));
end;

constructor TInterpreter.Create(AProgram: TProgramNode; AOutput: TStrings);
begin
  inherited Create;
  FProgram  := AProgram; FOutput := AOutput;
  FGlobal   := TEnvironment.Create;
  FRoutines := TRoutineDeclMap.Create;
  FMaxSteps := 1000000; FSteps := 0; FStop := False;
  FAllowShell := False; FShellConfirm := nil;
end;

procedure TInterpreter.RequestStop;
begin FStop := True; end;

destructor TInterpreter.Destroy;
begin FGlobal.Free; FRoutines.Free; inherited; end;

procedure TInterpreter.Output(const S: string);
begin
  if Assigned(FOutput) then FOutput.Add(S);
end;

// Registra rotinas de usuário — conecta corpos de métodos às classes
procedure TInterpreter.RegisterRoutines;
var
  R: TRoutineDecl; RRI, MI, DotPos: Integer;
  CName, MName: string; CD: TClassDecl;
begin
  for RRI := 0 to FProgram.Routines.Count - 1 do
  begin
    R := FProgram.Routines[RRI];
    DotPos := Pos('.', R.Name);
    if DotPos > 0 then
    begin
      // "TClasse.Metodo" — conecta o corpo ao método da classe
      CName := Copy(R.Name, 1, DotPos - 1);
      MName := Copy(R.Name, DotPos + 1, Length(R.Name));
      CD    := ClassRegistry.FindClass(CName);
      if Assigned(CD) then
        for MI := 0 to CD.Methods.Count - 1 do
          if LowerCase(CD.Methods[MI].Name) = LowerCase(MName) then
          begin
            CD.Methods[MI].Body.Free;   CD.Methods[MI].Body   := R.Body;
            CD.Methods[MI].Params.Free; CD.Methods[MI].Params := R.Params;
            CD.Methods[MI].Locals.Free; CD.Methods[MI].Locals := R.Locals;
            R.Body := nil; R.Params := nil; R.Locals := nil;
            Break;
          end;
      FRoutines.AddOrSetValue(LowerCase(CName + '.' + MName), R);
    end
    else
      FRoutines.AddOrSetValue(LowerCase(R.Name), R);
  end;
end;

// Declara variáveis com valores iniciais ou padrão por tipo
procedure TInterpreter.DeclareVars(Env: TEnvironment; Decls: TVarDeclList);
var D: TVarDecl; Val: TValue; TN: string; DVI: Integer;
begin
  if not Assigned(Decls) then Exit;
  for DVI := 0 to Decls.Count - 1 do
  begin
    D := Decls[DVI];
    if Assigned(D.InitExpr) then Val := EvalExpr(D.InitExpr, Env)
    else
    begin
      TN := LowerCase(D.TypeName);
      if      TN = 'integer' then Val := TValue.MakeInt(0)
      else if TN = 'real'    then Val := TValue.MakeFloat(0)
      else if TN = 'string'  then Val := TValue.MakeStr('')
      else if TN = 'boolean' then Val := TValue.MakeBool(False)
      else                        Val := TValue.MakeNil;
    end;
    Env.DeclareVar(D.Name, Val);
  end;
end;

// Ponto de entrada principal — executa o programa completo
procedure TInterpreter.Run;
var Loader: TUnitLoader; I: Integer;
begin
  FSteps := 0;
  InitClassRegistry;
  ClassRegistry.RegisterProgram(FProgram);

  // Carrega unidades importadas (cláusula uses)
  if FSourcePath <> '' then
  begin
    Loader := TUnitLoader.Create(FSourcePath);
    try
      Loader.LoadUnits(FSourceText);
      if Loader.HasUnits then Loader.MergeInto(FProgram);
      if Loader.Errors.Count > 0 then
        for I := 0 to Loader.Errors.Count - 1 do
          Output('*** Aviso de carregamento de unidade: ' + Loader.Errors[I]);
    finally Loader.Free; end;
  end;

  RegisterRoutines;
  DeclareVars(FGlobal, FProgram.Globals);

  // Executa o bloco principal — captura todas as exceções de controle de fluxo
  if Assigned(FProgram.MainBlock) then
  try
    ExecBlock(FProgram.MainBlock, FGlobal);
  except
    on EExitSignal     do ;   // Exit no bloco principal — encerramento normal
    on EBreakSignal    do ;   // Break escapou de algum loop — ignora
    on EContinueSignal do ;   // Continue escapou — ignora
  end;
end;

// ===========================================================================
//  Execução de comandos
// ===========================================================================

procedure TInterpreter.ExecBlock(Node: TBlockStmt; Env: TEnvironment);
var S: TStmtNode; BI: Integer;
begin
  for BI := 0 to Node.Stmts.Count - 1 do
  begin S := Node.Stmts[BI]; Tick; ExecStmt(S, Env); end;
end;

procedure TInterpreter.ExecStmt(Node: TStmtNode; Env: TEnvironment);
begin
  if Node is TBlockStmt            then ExecBlock          (TBlockStmt(Node),            Env) else
  if Node is TAssignStmt           then ExecAssign         (TAssignStmt(Node),           Env) else
  if Node is TWritelnStmt          then ExecWriteln        (TWritelnStmt(Node),          Env) else
  if Node is TReadlnStmt           then ExecReadln         (TReadlnStmt(Node),           Env) else
  if Node is TIfStmt               then ExecIf             (TIfStmt(Node),               Env) else
  if Node is TWhileStmt            then ExecWhile          (TWhileStmt(Node),            Env) else
  if Node is TRepeatStmt           then ExecRepeat         (TRepeatStmt(Node),           Env) else
  if Node is TForStmt              then ExecFor            (TForStmt(Node),              Env) else
  if Node is TCallStmt             then ExecCall           (TCallStmt(Node),             Env) else
  if Node is TExitStmt             then ExecExit           (TExitStmt(Node),             Env) else
  if Node is TBreakStmt            then raise EBreakSignal.Create('')                         else
  if Node is TContinueStmt         then raise EContinueSignal.Create('')                      else
  if Node is TCaseStmt             then ExecCase           (TCaseStmt(Node),             Env) else
  if Node is TCaseOfStmt           then ExecCaseOf         (TCaseOfStmt(Node),           Env) else
  if Node is TArrayIndexAssignStmt then ExecArrayIndexAssign(TArrayIndexAssignStmt(Node),Env) else
  if Node is TFieldAssignStmt      then ExecFieldAssign    (TFieldAssignStmt(Node),      Env) else
  if Node is TMethodCallStmt       then ExecMethodCall     (TMethodCallStmt(Node),       Env) else
  if Node is TInheritedCallStmt    then ExecInherited      (TInheritedCallStmt(Node),    Env);
end;

procedure TInterpreter.ExecAssign(Node: TAssignStmt; Env: TEnvironment);
begin Env.SetVar(Node.VarName, EvalExpr(Node.Expr, Env)); end;

procedure TInterpreter.ExecWriteln(Node: TWritelnStmt; Env: TEnvironment);
var S: string; Val: TValue; WI: Integer;
begin
  S := '';
  for WI := 0 to Node.Args.Count - 1 do
  begin Val := EvalExpr(Node.Args[WI], Env); S := S + Val.ToStr; end;
  if Node.NewLine then Output(S)
  else if FOutput.Count > 0 then
    FOutput[FOutput.Count - 1] := FOutput[FOutput.Count - 1] + S
  else Output(S);
end;

procedure TInterpreter.ExecReadln(Node: TReadlnStmt; Env: TEnvironment);
begin
  if Node.VarName <> '' then Env.SetVar(Node.VarName, TValue.MakeStr(FInputLine));
end;

procedure TInterpreter.ExecIf(Node: TIfStmt; Env: TEnvironment);
begin
  if EvalExpr(Node.Condition, Env).ToBool then ExecStmt(Node.ThenBranch, Env)
  else if Assigned(Node.ElseBranch) then ExecStmt(Node.ElseBranch, Env);
end;

procedure TInterpreter.ExecWhile(Node: TWhileStmt; Env: TEnvironment);
begin
  try
    while EvalExpr(Node.Condition, Env).ToBool do
    begin
      Tick;
      try ExecStmt(Node.Body, Env);
      except on EContinueSignal do ; end;
    end;
  except on EBreakSignal do ; end;
end;

procedure TInterpreter.ExecRepeat(Node: TRepeatStmt; Env: TEnvironment);
var S: TStmtNode; RI: Integer;
begin
  try
    repeat
      Tick;
      try
        for RI := 0 to Node.Body.Count - 1 do
        begin S := Node.Body[RI]; Tick; ExecStmt(S, Env); end;
      except on EContinueSignal do ; end;
    until EvalExpr(Node.Condition, Env).ToBool;
  except on EBreakSignal do ; end;
end;

procedure TInterpreter.ExecFor(Node: TForStmt; Env: TEnvironment);
var Start, Finish, I: Int64;
begin
  Start := EvalExpr(Node.StartVal, Env).ToInt;
  Finish := EvalExpr(Node.EndVal, Env).ToInt;
  Env.SetVar(Node.VarName, TValue.MakeInt(Start));
  I := Start;
  try
    if not Node.IsDownTo then
    begin
      while I <= Finish do
      begin
        Tick; Env.SetVar(Node.VarName, TValue.MakeInt(I));
        try ExecStmt(Node.Body, Env); except on EContinueSignal do ; end;
        Inc(I);
      end;
    end else
    begin
      while I >= Finish do
      begin
        Tick; Env.SetVar(Node.VarName, TValue.MakeInt(I));
        try ExecStmt(Node.Body, Env); except on EContinueSignal do ; end;
        Dec(I);
      end;
    end;
  except on EBreakSignal do ; end;
end;

procedure TInterpreter.ExecCall(Node: TCallStmt; Env: TEnvironment);
var Dummy: TValue;
begin
  if not CallBuiltin(Node.Name, Node.Args, Env, Dummy) then
    CallRoutine(Node.Name, Node.Args, Env);
end;

procedure TInterpreter.ExecExit(Node: TExitStmt; Env: TEnvironment);
var Val: TValue;
begin
  if Assigned(Node.Expr) then Val := EvalExpr(Node.Expr, Env)
  else Val := TValue.MakeNil;
  raise EExitSignal.Create(Val);
end;

// ===========================================================================
//  Avaliação de expressões
// ===========================================================================

function TInterpreter.EvalExpr(Node: TExprNode; Env: TEnvironment): TValue;
var EmptyArgs: TExprList;
begin
  Tick;
  if Node is TIntLitExpr   then Result := TValue.MakeInt  (TIntLitExpr(Node).Value)   else
  if Node is TFloatLitExpr then Result := TValue.MakeFloat(TFloatLitExpr(Node).Value) else
  if Node is TStrLitExpr   then Result := TValue.MakeStr  (TStrLitExpr(Node).Value)   else
  if Node is TBoolLitExpr  then Result := TValue.MakeBool (TBoolLitExpr(Node).Value)  else
  if Node is TNilLitExpr   then Result := TValue.MakeNil                               else
  if Node is TVarExpr then
  begin
    if not Env.GetVar(TVarExpr(Node).Name, Result) then
    begin
      // Tenta como builtin de zero argumentos (ex: GfxRunning, Pi)
      EmptyArgs := TExprList.Create(False);
      try
        if not CallBuiltin(TVarExpr(Node).Name, EmptyArgs, Env, Result) then
          Result := TValue.MakeNil;
      finally EmptyArgs.Free; end;
    end;
  end else
  if Node is TBinOpExpr        then Result := EvalBinOp          (TBinOpExpr(Node),        Env) else
  if Node is TUnaryExpr        then Result := EvalUnary          (TUnaryExpr(Node),        Env) else
  if Node is TCallExpr         then Result := EvalCallExpr       (TCallExpr(Node),         Env) else
  if Node is TFieldExpr        then Result := EvalFieldExpr      (TFieldExpr(Node),        Env) else
  if Node is TMethodCallExpr   then Result := EvalMethodCallExpr (TMethodCallExpr(Node),   Env) else
  if Node is TCreateExpr       then Result := EvalCreateExpr     (TCreateExpr(Node),       Env) else
  if Node is TArrayIndexExpr   then Result := EvalArrayIndex     (TArrayIndexExpr(Node),   Env)
  else Result := TValue.MakeNil;
end;

function TInterpreter.EvalBinOp(Node: TBinOpExpr; Env: TEnvironment): TValue;
var L, R: TValue; BothNumeric, EitherFloat: Boolean;
begin
  L := EvalExpr(Node.Left, Env);
  // Avaliação em curto-circuito para and/or
  if Node.Op = 'and' then
  begin
    if not L.ToBool then Exit(TValue.MakeBool(False));
    Exit(TValue.MakeBool(EvalExpr(Node.Right, Env).ToBool));
  end;
  if Node.Op = 'or' then
  begin
    if L.ToBool then Exit(TValue.MakeBool(True));
    Exit(TValue.MakeBool(EvalExpr(Node.Right, Env).ToBool));
  end;
  R := EvalExpr(Node.Right, Env);
  BothNumeric := (L.Kind in [vkInt, vkFloat]) and (R.Kind in [vkInt, vkFloat]);
  EitherFloat := (L.Kind = vkFloat) or (R.Kind = vkFloat);
  // Concatenação de strings com +
  if (Node.Op = '+') and ((L.Kind = vkString) or (R.Kind = vkString)) then
    Exit(TValue.MakeStr(L.ToStr + R.ToStr));
  case Node.Op[1] of
    '+': if BothNumeric then if EitherFloat then Result := TValue.MakeFloat(L.ToFloat + R.ToFloat) else Result := TValue.MakeInt(L.ToInt + R.ToInt);
    '-': if BothNumeric then if EitherFloat then Result := TValue.MakeFloat(L.ToFloat - R.ToFloat) else Result := TValue.MakeInt(L.ToInt - R.ToInt);
    '*': if BothNumeric then if EitherFloat then Result := TValue.MakeFloat(L.ToFloat * R.ToFloat) else Result := TValue.MakeInt(L.ToInt * R.ToInt);
    '/': if R.ToFloat <> 0 then Result := TValue.MakeFloat(L.ToFloat / R.ToFloat)
         else raise Exception.Create('Divisão por zero com "/".');
    '=': if L.Kind = vkString then Result := TValue.MakeBool(L.SVal = R.SVal)
         else Result := TValue.MakeBool(L.ToFloat = R.ToFloat);
    '<': if Node.Op = '<>' then
         begin
           if L.Kind = vkString then Result := TValue.MakeBool(L.SVal <> R.SVal)
           else Result := TValue.MakeBool(L.ToFloat <> R.ToFloat);
         end
         else if Node.Op = '<=' then Result := TValue.MakeBool(L.ToFloat <= R.ToFloat)
         else Result := TValue.MakeBool(L.ToFloat < R.ToFloat);
    '>': if Node.Op = '>=' then Result := TValue.MakeBool(L.ToFloat >= R.ToFloat)
         else Result := TValue.MakeBool(L.ToFloat > R.ToFloat);
    'd': if R.ToInt <> 0 then Result := TValue.MakeInt(L.ToInt div R.ToInt)
         else raise Exception.Create('Divisão por zero com "div".');
    'm': if R.ToInt <> 0 then Result := TValue.MakeInt(L.ToInt mod R.ToInt)
         else raise Exception.Create('Módulo por zero com "mod".');
  else Result := TValue.MakeNil;
  end;
end;

function TInterpreter.EvalUnary(Node: TUnaryExpr; Env: TEnvironment): TValue;
var V: TValue;
begin
  V := EvalExpr(Node.Operand, Env);
  if Node.Op = '-' then
  begin
    if V.Kind = vkFloat then Result := TValue.MakeFloat(-V.FVal)
    else Result := TValue.MakeInt(-V.IVal);
  end
  else if Node.Op = 'not' then Result := TValue.MakeBool(not V.ToBool)
  else Result := V;
end;

function TInterpreter.EvalCallExpr(Node: TCallExpr; Env: TEnvironment): TValue;
begin
  if not CallBuiltin(Node.Name, Node.Args, Env, Result) then
    Result := CallRoutine(Node.Name, Node.Args, Env);
end;

// Leitura de elemento de array: a[i]
function TInterpreter.EvalArrayIndex(Node: TArrayIndexExpr; Env: TEnvironment): TValue;
var AV: TValue; Idx: Integer;
begin
  AV := EvalExpr(Node.Target, Env);
  if AV.Kind <> vkArray then
    raise Exception.Create(
      'Tentativa de indexar algo que não é um array.' + sLineBreak +
      'Use SetLength(arr, n) para inicializar o array antes.');
  Idx := EvalExpr(Node.Index, Env).ToInt;
  if (Idx < 0) or (Idx >= AsArr(AV.ArrVal).Count) then
    raise Exception.CreateFmt(
      'Índice %d fora dos limites (tamanho %d, válido 0..%d).',
      [Idx, AsArr(AV.ArrVal).Count, AsArr(AV.ArrVal).Count - 1]);
  Result := AsArr(AV.ArrVal).GetItem(Idx);
end;

// Atribuição de elemento de array: a[i] := valor
procedure TInterpreter.ExecArrayIndexAssign(Node: TArrayIndexAssignStmt; Env: TEnvironment);
var AV: TValue; Idx: Integer; NV: TValue; VName: string;
begin
  NV := EvalExpr(Node.Value, Env);
  if not (Node.Target is TVarExpr) then
    raise Exception.Create('O alvo da atribuição de array deve ser uma variável simples.');
  VName := TVarExpr(Node.Target).Name;
  if not Env.GetVar(VName, AV) or (AV.Kind <> vkArray) then
    raise Exception.CreateFmt(
      '"%s" não é um array. Use SetLength(%s, n) primeiro.', [VName, VName]);
  Idx := EvalExpr(Node.Index, Env).ToInt;
  if (Idx < 0) or (Idx >= AsArr(AV.ArrVal).Count) then
    raise Exception.CreateFmt(
      'Índice %d fora dos limites (tamanho %d, válido 0..%d).',
      [Idx, AsArr(AV.ArrVal).Count, AsArr(AV.ArrVal).Count - 1]);
  // SetItem modifica o objeto compartilhado diretamente — sem necessidade de writeback
  AsArr(AV.ArrVal).SetItem(Idx, NV);
end;

// ===========================================================================
//  Chamada de rotinas de usuário
// ===========================================================================
function TInterpreter.CallRoutine(const Name: string; Args: TExprList;
  CallerEnv: TEnvironment): TValue;
var Decl: TRoutineDecl; Env: TEnvironment; I: Integer;
    Param: TParamDecl; ArgVal: TValue;
begin
  Result := TValue.MakeNil;
  if not FRoutines.TryGetValue(LowerCase(Name), Decl) then
    raise Exception.CreateFmt(
      'Não existe procedimento ou função chamado "%s".' + sLineBreak +
      'Verifique a ortografia ou adicione uma cláusula "uses".', [Name]);

  Env := TEnvironment.Create(FGlobal);
  try
    // Vincula parâmetros
    if Assigned(Decl.Params) then
      for I := 0 to Decl.Params.Count - 1 do
      begin
        Param := Decl.Params[I];
        if I < Args.Count then ArgVal := EvalExpr(Args[I], CallerEnv)
        else ArgVal := TValue.MakeNil;
        Env.DeclareVar(Param.Name, ArgVal);
      end;

    if Assigned(Decl.Locals) then DeclareVars(Env, Decl.Locals);
    if Decl.ReturnType <> '' then Env.DeclareVar('result', TValue.MakeNil);

    // Executa o corpo — captura EExitSignal para suportar Exit em funções
    try
      ExecBlock(Decl.Body, Env);
    except
      on E: EExitSignal do
      begin
        // Se é uma função, usa o valor retornado pelo Exit
        if Decl.ReturnType <> '' then Result := E.ReturnVal;
      end;
    end;

    // Lê o valor de retorno da função
    if Decl.ReturnType <> '' then Env.GetVar('result', Result);
  finally
    Env.Free;
  end;
end;

// ===========================================================================
//  Builtins — funções e procedimentos embutidos
// ===========================================================================
function TInterpreter.CallBuiltin(const Name: string; Args: TExprList;
  CallerEnv: TEnvironment; out Val: TValue): Boolean;

  // Avalia o i-ésimo argumento (retorna nil se não existir)
  function A(I: Integer): TValue;
  begin
    if I < Args.Count then Result := EvalExpr(Args[I], CallerEnv)
    else Result := TValue.MakeNil;
  end;

var
  N: string; IB_Title, IB_Def, SelDir: string;
  ODlg: TOpenDialog; SDlg3: TSaveDialog;
  IncCur, DecCur: TValue; IncStep, DecStep: Int64;
begin
  Result := True;
  N := LowerCase(Name);

  // ── Matemática ──────────────────────────────────────────────────────────
  if      N = 'abs'         then Val := TValue.MakeFloat(Abs(A(0).ToFloat))
  else if N = 'sqr'         then Val := TValue.MakeFloat(Sqr(A(0).ToFloat))
  else if N = 'sqrt'        then Val := TValue.MakeFloat(Sqrt(A(0).ToFloat))
  else if N = 'round'       then Val := TValue.MakeInt  (Round(A(0).ToFloat))
  else if N = 'trunc'       then Val := TValue.MakeInt  (Trunc(A(0).ToFloat))
  else if N = 'int'         then Val := TValue.MakeFloat(Int(A(0).ToFloat))
  else if N = 'frac'        then Val := TValue.MakeFloat(Frac(A(0).ToFloat))
  else if N = 'sin'         then Val := TValue.MakeFloat(Sin(A(0).ToFloat))
  else if N = 'cos'         then Val := TValue.MakeFloat(Cos(A(0).ToFloat))
  else if N = 'ln'          then Val := TValue.MakeFloat(Ln(A(0).ToFloat))
  else if N = 'exp'         then Val := TValue.MakeFloat(Exp(A(0).ToFloat))
  else if N = 'pi'          then Val := TValue.MakeFloat(Pi)
  else if N = 'power'       then Val := TValue.MakeFloat(Power(A(0).ToFloat, A(1).ToFloat))
  else if N = 'max'         then Val := TValue.MakeFloat(Max(A(0).ToFloat, A(1).ToFloat))
  else if N = 'min'         then Val := TValue.MakeFloat(Min(A(0).ToFloat, A(1).ToFloat))
  else if N = 'odd'         then Val := TValue.MakeBool((A(0).ToInt mod 2) <> 0)
  else if N = 'succ'        then Val := TValue.MakeInt(A(0).ToInt + 1)
  else if N = 'pred'        then Val := TValue.MakeInt(A(0).ToInt - 1)
  else if N = 'ord'         then Val := TValue.MakeInt(Ord(A(0).SVal[1]))
  else if N = 'chr'         then Val := TValue.MakeStr(Chr(A(0).ToInt))

  // ── Strings ─────────────────────────────────────────────────────────────
  else if N = 'length' then
  begin
    var LA: TValue; LA := A(0);
    // Funciona tanto para strings quanto para arrays
    if LA.Kind = vkArray then Val := TValue.MakeInt(AsArr(LA.ArrVal).Count)
    else                       Val := TValue.MakeInt(Length(LA.ToStr));
  end
  else if N = 'pos'         then Val := TValue.MakeInt  (Pos(A(0).SVal, A(1).SVal))
  else if N = 'copy'        then Val := TValue.MakeStr  (Copy(A(0).SVal, A(1).ToInt, A(2).ToInt))
  else if N = 'uppercase'   then Val := TValue.MakeStr  (UpperCase(A(0).SVal))
  else if N = 'lowercase'   then Val := TValue.MakeStr  (LowerCase(A(0).SVal))
  else if N = 'trim'        then Val := TValue.MakeStr  (Trim(A(0).SVal))
  else if N = 'inttostr'    then Val := TValue.MakeStr  (IntToStr(A(0).ToInt))
  else if N = 'strtoint'    then Val := TValue.MakeInt  (StrToIntDef(A(0).SVal, 0))
  else if N = 'strtointdef' then Val := TValue.MakeInt  (StrToIntDef(A(0).SVal, A(1).ToInt))
  else if N = 'strtofloat'  then Val := TValue.MakeFloat(StrToFloatDef(A(0).SVal, 0))
  else if N = 'floattostr'  then Val := TValue.MakeStr  (FloatToStr(A(0).ToFloat))
  else if N = 'str'         then Val := TValue.MakeStr  (A(0).ToStr)
  else if N = 'val'         then Val := TValue.MakeFloat(StrToFloatDef(A(0).SVal, 0))

  // ── Arrays dinâmicos ────────────────────────────────────────────────────
  else if N = 'setlength' then
  begin
    // SetLength(arr, novoTamanho) — redimensiona o array
    var SLName: string; var SLLen: Integer; var SLVal: TValue; var SLArr: TArrayValue;
    SLLen := A(1).ToInt; if SLLen < 0 then SLLen := 0;
    if (Args.Count > 0) and (Args[0] is TVarExpr) then SLName := TVarExpr(Args[0]).Name
    else SLName := '';
    if (SLName = '') or not CallerEnv.GetVar(SLName, SLVal) or (SLVal.Kind <> vkArray) then
    begin
      SLArr := TArrayValue.Create; SLVal := TValue.MakeArray(SLArr);
    end
    else SLArr := AsArr(SLVal.ArrVal);
    // Expande com zeros ou trunca
    while SLArr.Count < SLLen do SLArr.AddItem(TValue.MakeInt(0));
    while SLArr.Count > SLLen do
    begin
      Dispose(PValue(SLArr.Items[SLArr.Count - 1]));
      SLArr.Items.Delete(SLArr.Count - 1);
    end;
    if SLName <> '' then CallerEnv.SetVar(SLName, SLVal);
    Val := TValue.MakeNil;
  end

  // ── Aleatório ───────────────────────────────────────────────────────────
  else if N = 'random' then
  begin
    if Args.Count > 0 then Val := TValue.MakeInt(Random(A(0).ToInt))
    else Val := TValue.MakeFloat(Random);
  end
  else if N = 'randomize' then begin Randomize; Val := TValue.MakeNil; end

  // ── Inc / Dec ────────────────────────────────────────────────────────────
  else if N = 'inc' then
  begin
    if (Args.Count > 0) and (Args[0] is TVarExpr) then
    begin
      IncStep := 1;
      if not CallerEnv.GetVar(TVarExpr(Args[0]).Name, IncCur) then IncCur := TValue.MakeInt(0);
      if Args.Count > 1 then IncStep := A(1).ToInt;
      CallerEnv.SetVar(TVarExpr(Args[0]).Name, TValue.MakeInt(IncCur.ToInt + IncStep));
    end;
    Val := TValue.MakeNil;
  end
  else if N = 'dec' then
  begin
    if (Args.Count > 0) and (Args[0] is TVarExpr) then
    begin
      DecStep := 1;
      if not CallerEnv.GetVar(TVarExpr(Args[0]).Name, DecCur) then DecCur := TValue.MakeInt(0);
      if Args.Count > 1 then DecStep := A(1).ToInt;
      CallerEnv.SetVar(TVarExpr(Args[0]).Name, TValue.MakeInt(DecCur.ToInt - DecStep));
    end;
    Val := TValue.MakeNil;
  end

  // ── Diálogos de interface ────────────────────────────────────────────────
  else if N = 'showmessage'    then begin Vcl.Dialogs.ShowMessage(A(0).ToStr); Val := TValue.MakeNil; end
  else if N = 'confirm'        then Val := TValue.MakeBool(MessageDlg(A(0).ToStr, mtConfirmation, [mbYes, mbNo], 0) = mrYes)
  else if N = 'inputbox' then
  begin
    if Args.Count > 1 then IB_Title := A(1).ToStr else IB_Title := 'Entrada';
    if Args.Count > 2 then IB_Def   := A(2).ToStr else IB_Def   := '';
    Val := TValue.MakeStr(InputBox(IB_Title, A(0).ToStr, IB_Def));
  end
  else if N = 'showinfobox'    then begin MessageDlg(A(0).ToStr, mtInformation, [mbOK], 0); Val := TValue.MakeNil; end
  else if N = 'showwarningbox' then begin MessageDlg(A(0).ToStr, mtWarning,     [mbOK], 0); Val := TValue.MakeNil; end
  else if N = 'showerrorbox'   then begin MessageDlg(A(0).ToStr, mtError,       [mbOK], 0); Val := TValue.MakeNil; end

  // ── Diálogos de arquivo ──────────────────────────────────────────────────
  else if N = 'openfiledialog' then
  begin
    ODlg := TOpenDialog.Create(nil);
    try
      if Args.Count > 0 then ODlg.Filter := A(0).ToStr else ODlg.Filter := 'Todos os arquivos|*.*';
      ODlg.Options := [ofFileMustExist];
      if ODlg.Execute then Val := TValue.MakeStr(ODlg.FileName) else Val := TValue.MakeStr('');
    finally ODlg.Free; end;
  end
  else if N = 'savefiledialog' then
  begin
    SDlg3 := TSaveDialog.Create(nil);
    try
      if Args.Count > 0 then SDlg3.Filter := A(0).ToStr else SDlg3.Filter := 'Todos os arquivos|*.*';
      if Args.Count > 1 then SDlg3.DefaultExt := A(1).ToStr;
      if SDlg3.Execute then Val := TValue.MakeStr(SDlg3.FileName) else Val := TValue.MakeStr('');
    finally SDlg3.Free; end;
  end
  else if N = 'selectdirectorydialog' then
  begin
    SelDir := '';
    if SelectDirectory('Selecione uma pasta', '', SelDir) then Val := TValue.MakeStr(SelDir)
    else Val := TValue.MakeStr('');
  end

  // ── E/S de arquivo ──────────────────────────────────────────────────────
  else if N = 'writefile'      then begin TFile.WriteAllText(A(0).ToStr, A(1).ToStr); Val := TValue.MakeNil; end
  else if N = 'appendfile'     then begin TFile.AppendAllText(A(0).ToStr, A(1).ToStr + sLineBreak); Val := TValue.MakeNil; end
  else if N = 'readfile'       then begin if TFile.Exists(A(0).ToStr) then Val := TValue.MakeStr(TFile.ReadAllText(A(0).ToStr)) else Val := TValue.MakeStr(''); end
  else if N = 'fileexists'     then Val := TValue.MakeBool(TFile.Exists(A(0).ToStr))
  else if N = 'deletefile'     then begin if TFile.Exists(A(0).ToStr) then TFile.Delete(A(0).ToStr); Val := TValue.MakeNil; end
  else if N = 'getapppath'     then Val := TValue.MakeStr(ExtractFilePath(ParamStr(0)))
  else if N = 'getdesktoppath' then Val := TValue.MakeStr(GetEnvironmentVariable('USERPROFILE') + '\Desktop')

  // ── Sleep / pausa ────────────────────────────────────────────────────────
  else if N = 'sleep' then
  begin
    var SleepMs: Integer; SleepMs := A(0).ToInt;
    if SleepMs > 0 then Winapi.Windows.Sleep(SleepMs);
    Application.ProcessMessages; Val := TValue.MakeNil;
  end

  // ── Shell — executa programas externos ──────────────────────────────────
  else if N = 'shell' then
  begin
    var ShCmd: string; var ShOK: Boolean;
    ShCmd := A(0).ToStr; ShOK := FAllowShell;
    if (not ShOK) and Assigned(FShellConfirm) then ShOK := FShellConfirm(ShCmd);
    if ShOK then begin ShellExecute(0, 'open', PChar(ShCmd), nil, nil, SW_SHOWNORMAL); Val := TValue.MakeBool(True); end
    else begin Output('Chamada Shell negada: ' + ShCmd); Val := TValue.MakeBool(False); end;
  end
  else if N = 'shellwait' then
  begin
    var SwCmd, SwLine: string; var SwOK: Boolean;
    var SwSI: TStartupInfo; var SwPI: TProcessInformation; var SwExit: DWORD;
    SwCmd := A(0).ToStr; SwOK := FAllowShell;
    if (not SwOK) and Assigned(FShellConfirm) then SwOK := FShellConfirm(SwCmd);
    if not SwOK then begin Output('Chamada Shell negada: ' + SwCmd); Val := TValue.MakeInt(-1); Exit; end;
    SwLine := 'cmd.exe /c ' + SwCmd;
    FillChar(SwSI, SizeOf(SwSI), 0); SwSI.cb := SizeOf(SwSI);
    SwSI.dwFlags := STARTF_USESHOWWINDOW; SwSI.wShowWindow := SW_HIDE;
    if CreateProcess(nil, PChar(SwLine), nil, nil, False, CREATE_NO_WINDOW, nil, nil, SwSI, SwPI) then
    begin
      WaitForSingleObject(SwPI.hProcess, INFINITE);
      GetExitCodeProcess(SwPI.hProcess, SwExit);
      CloseHandle(SwPI.hThread); CloseHandle(SwPI.hProcess);
      Val := TValue.MakeInt(Integer(SwExit));
    end else Val := TValue.MakeInt(-1);
  end
  else if N = 'shellhidden' then
  begin
    var ShhCmd: string; var ShhOK: Boolean;
    ShhCmd := A(0).ToStr; ShhOK := FAllowShell;
    if (not ShhOK) and Assigned(FShellConfirm) then ShhOK := FShellConfirm(ShhCmd);
    if ShhOK then begin ShellExecute(0, 'open', PChar(ShhCmd), nil, nil, SW_HIDE); Val := TValue.MakeBool(True); end
    else begin Output('Chamada Shell negada: ' + ShhCmd); Val := TValue.MakeBool(False); end;
  end

  // ── Data / hora / ambiente ───────────────────────────────────────────────
  else if N = 'getenvvar' then Val := TValue.MakeStr(GetEnvironmentVariable(A(0).ToStr))
  else if N = 'datestr'   then Val := TValue.MakeStr(FormatDateTime('yyyy-mm-dd', Now))
  else if N = 'timestr'   then Val := TValue.MakeStr(FormatDateTime('hh:nn:ss', Now))

  // ── Arquivos INI ─────────────────────────────────────────────────────────
  else if N = 'iniwritestr' then
  begin
    var IW: TIniFile; IW := TIniFile.Create(A(0).ToStr);
    try IW.WriteString(A(1).ToStr, A(2).ToStr, A(3).ToStr); finally IW.Free; end;
    Val := TValue.MakeNil;
  end
  else if N = 'inireadstr' then
  begin
    var IR: TIniFile; IR := TIniFile.Create(A(0).ToStr);
    try Val := TValue.MakeStr(IR.ReadString(A(1).ToStr, A(2).ToStr, A(3).ToStr)); finally IR.Free; end;
  end
  else if N = 'iniwriteint' then
  begin
    var IWI: TIniFile; IWI := TIniFile.Create(A(0).ToStr);
    try IWI.WriteInteger(A(1).ToStr, A(2).ToStr, A(3).ToInt); finally IWI.Free; end;
    Val := TValue.MakeNil;
  end
  else if N = 'inireadint' then
  begin
    var IRI: TIniFile; IRI := TIniFile.Create(A(0).ToStr);
    try Val := TValue.MakeInt(IRI.ReadInteger(A(1).ToStr, A(2).ToStr, A(3).ToInt)); finally IRI.Free; end;
  end

  // ── Codificação URL ─────────────────────────────────────────────────────
  else if N = 'urlencode' then
  begin
    var UeS, UeR: string; var UeI: Integer; var UeC: Char;
    UeS := A(0).ToStr; UeR := '';
    for UeI := 1 to Length(UeS) do
    begin
      UeC := UeS[UeI];
      case UeC of
        ' ': UeR := UeR + '%20'; #10: UeR := UeR + '%0A'; #13: ;
        '&': UeR := UeR + '%26'; '#': UeR := UeR + '%23';
        '?': UeR := UeR + '%3F'; '"': UeR := UeR + '%22';
        '<': UeR := UeR + '%3C'; '>': UeR := UeR + '%3E';
      else UeR := UeR + UeC;
      end;
    end;
    Val := TValue.MakeStr(UeR);
  end
  else if N = 'extractfilename' then Val := TValue.MakeStr(ExtractFileName(A(0).ToStr))
  else if N = 'extractfilepath' then Val := TValue.MakeStr(ExtractFilePath(A(0).ToStr))

  // ── Gráficos (GfxXxx) ───────────────────────────────────────────────────
  else if N = 'gfxopen' then
  begin
    var GW, GH: Integer; var GT: string;
    GW := A(0).ToInt; GH := A(1).ToInt;
    if Args.Count > 2 then GT := A(2).ToStr else GT := 'Pythia Gráficos';
    GfxOpenWindow(GW, GH, GT); Val := TValue.MakeNil;
  end
  else if N = 'gfxclose'       then begin GfxCloseWindow; Val := TValue.MakeNil; end
  else if N = 'gfxclear'       then begin if Assigned(GfxWin) then GfxWin.GfxClear(A(0).ToStr); Val := TValue.MakeNil; end
  else if N = 'gfxshow'        then begin if Assigned(GfxWin) then GfxWin.GfxShow; Val := TValue.MakeNil; end
  else if N = 'gfxdelay' then
  begin
    var GMS: Integer; GMS := A(0).ToInt;
    if GMS > 0 then Winapi.Windows.Sleep(GMS);
    Application.ProcessMessages; Val := TValue.MakeNil;
  end
  else if N = 'gfxrunning'     then Val := TValue.MakeBool(Assigned(GfxWin) and GfxWin.Running)
  else if N = 'gfxcolor'       then begin if Assigned(GfxWin) then GfxWin.GfxColor(A(0).ToStr); Val := TValue.MakeNil; end
  else if N = 'gfxpenwidth'    then begin if Assigned(GfxWin) then GfxWin.GfxPenWidth(A(0).ToInt); Val := TValue.MakeNil; end
  else if N = 'gfxdrawline'    then begin if Assigned(GfxWin) then GfxWin.GfxDrawLine(A(0).ToInt, A(1).ToInt, A(2).ToInt, A(3).ToInt); Val := TValue.MakeNil; end
  else if N = 'gfxdrawrect'    then begin if Assigned(GfxWin) then GfxWin.GfxDrawRect(A(0).ToInt, A(1).ToInt, A(2).ToInt, A(3).ToInt); Val := TValue.MakeNil; end
  else if N = 'gfxfillrect'    then begin if Assigned(GfxWin) then GfxWin.GfxFillRect(A(0).ToInt, A(1).ToInt, A(2).ToInt, A(3).ToInt); Val := TValue.MakeNil; end
  else if N = 'gfxdrawcircle'  then begin if Assigned(GfxWin) then GfxWin.GfxDrawCircle(A(0).ToInt, A(1).ToInt, A(2).ToInt); Val := TValue.MakeNil; end
  else if N = 'gfxfillcircle'  then begin if Assigned(GfxWin) then GfxWin.GfxFillCircle(A(0).ToInt, A(1).ToInt, A(2).ToInt); Val := TValue.MakeNil; end
  else if N = 'gfxdrawellipse' then begin if Assigned(GfxWin) then GfxWin.GfxDrawEllipse(A(0).ToInt, A(1).ToInt, A(2).ToInt, A(3).ToInt); Val := TValue.MakeNil; end
  else if N = 'gfxfillellipse' then begin if Assigned(GfxWin) then GfxWin.GfxFillEllipse(A(0).ToInt, A(1).ToInt, A(2).ToInt, A(3).ToInt); Val := TValue.MakeNil; end
  else if N = 'gfxdrawtext'    then begin if Assigned(GfxWin) then GfxWin.GfxDrawText(A(0).ToInt, A(1).ToInt, A(2).ToStr); Val := TValue.MakeNil; end
  else if N = 'gfxsetfont'     then begin if Assigned(GfxWin) then GfxWin.GfxSetFont(A(0).ToInt, A(1).ToBool); Val := TValue.MakeNil; end
  else if N = 'gfxdrawpixel'   then begin if Assigned(GfxWin) then GfxWin.GfxDrawPixel(A(0).ToInt, A(1).ToInt); Val := TValue.MakeNil; end
  else if N = 'gfxkeypressed'  then Val := TValue.MakeBool(Assigned(GfxWin) and GfxWin.GfxKeyPressed)
  else if N = 'gfxreadkey' then
  begin
    if Assigned(GfxWin) then Val := TValue.MakeStr(GfxWin.GfxReadKey)
    else Val := TValue.MakeStr('');
  end
  else if N = 'gfxmousex'    then Val := TValue.MakeInt (IfThenInt(Assigned(GfxWin), GfxWin.MouseX, 0))
  else if N = 'gfxmousey'    then Val := TValue.MakeInt (IfThenInt(Assigned(GfxWin), GfxWin.MouseY, 0))
  else if N = 'gfxmousedown' then Val := TValue.MakeBool(Assigned(GfxWin) and GfxWin.MouseDown)

  // ── Banco de dados SQLite ────────────────────────────────────────────────
  else if N = 'dbopen' then
  begin
    InitMiniDB;
    if MiniDB.Open(A(0).ToStr) then begin Val := TValue.MakeBool(True); Output('Banco aberto: ' + A(0).ToStr); end
    else begin Val := TValue.MakeBool(False); Output('Erro BD: ' + MiniDB.LastError); end;
  end
  else if N = 'dbclose'      then begin if Assigned(MiniDB) then MiniDB.Close; Val := TValue.MakeNil; Output('Banco fechado.'); end
  else if N = 'dbexec' then
  begin
    InitMiniDB;
    if MiniDB.Exec(A(0).ToStr) then Val := TValue.MakeBool(True)
    else begin Val := TValue.MakeBool(False); Output('Erro BD: ' + MiniDB.LastError); end;
  end
  else if N = 'dbquery' then
  begin
    InitMiniDB; Val := TValue.MakeStr(MiniDB.Query(A(0).ToStr));
    if MiniDB.LastError <> '' then Output('Erro BD: ' + MiniDB.LastError);
  end
  else if N = 'dbqueryvalue' then
  begin
    InitMiniDB; Val := TValue.MakeStr(MiniDB.QueryValue(A(0).ToStr));
    if MiniDB.LastError <> '' then Output('Erro BD: ' + MiniDB.LastError);
  end
  else if N = 'dblasterror'  then begin if Assigned(MiniDB) then Val := TValue.MakeStr(MiniDB.LastError) else Val := TValue.MakeStr('Nenhum banco inicializado'); end
  else if N = 'dbisopen'     then Val := TValue.MakeBool(Assigned(MiniDB) and MiniDB.IsOpen)
  else if N = 'dbfilename'   then begin if Assigned(MiniDB) then Val := TValue.MakeStr(MiniDB.Filename) else Val := TValue.MakeStr(''); end

  else
    Result := False;  // não é um builtin
end;

// ===========================================================================
//  case / caseof
// ===========================================================================

procedure TInterpreter.ExecCase(Node: TCaseStmt; Env: TEnvironment);
var Val: TValue; IVal: Int64; Arm: TCaseArm; Hit: Boolean; CAI, CAJ: Integer;
begin
  Val := EvalExpr(Node.Expr, Env); IVal := Val.ToInt; Hit := False;
  for CAI := 0 to Node.Arms.Count - 1 do
  begin
    Arm := Node.Arms[CAI];
    for CAJ := 0 to Arm.Values.Count - 1 do
      if Arm.Values[CAJ] = IVal then begin ExecStmt(Arm.Body, Env); Hit := True; Break; end;
    if Hit then Break;
  end;
  if (not Hit) and Assigned(Node.ElseBody) then ExecStmt(Node.ElseBody, Env);
end;

procedure TInterpreter.ExecCaseOf(Node: TCaseOfStmt; Env: TEnvironment);
var Val: TValue; SVal: string; Arm: TCaseOfArm; Hit: Boolean; COI, COJ: Integer;
begin
  Val := EvalExpr(Node.Expr, Env); SVal := Val.ToStr; Hit := False;
  for COI := 0 to Node.Arms.Count - 1 do
  begin
    Arm := Node.Arms[COI];
    for COJ := 0 to Arm.Values.Count - 1 do
      if Arm.Values[COJ] = SVal then begin ExecStmt(Arm.Body, Env); Hit := True; Break; end;
    if Hit then Break;
  end;
  if (not Hit) and Assigned(Node.ElseBody) then ExecStmt(Node.ElseBody, Env);
end;

// ===========================================================================
//  POO — Programação Orientada a Objetos
// ===========================================================================

function TInterpreter.EvalCreateExpr(Node: TCreateExpr; Env: TEnvironment): TValue;
var Obj: TObjectInstance; ML: TMethodLookup;
begin
  Result := TValue.MakeNil;
  if not ClassRegistry.ClassExists(Node.ClassRef) then
    raise Exception.CreateFmt('Não existe classe chamada "%s".', [Node.ClassRef]);
  Obj := TObjectInstance.Create(Node.ClassRef);
  InitObjectFields(Obj);
  Result := TValue.MakeObject(Obj);
  ML := ClassRegistry.ResolveMethod(Node.ClassRef, 'Create');
  if ML.Found and ML.Method.IsConstructor then InvokeMethod(Obj, ML.Method, Node.Args, Env);
end;

procedure TInterpreter.InitObjectFields(Obj: TObjectInstance);
var Fields: TObjectList<TFieldDecl>; F: TFieldDecl; DefVal: TValue;
    PVal: ^TValue; FTN: string; OFI: Integer;
begin
  Fields := TObjectList<TFieldDecl>.Create(False);
  try
    ClassRegistry.CollectFields(Obj.ObjClass, Fields);
    for OFI := 0 to Fields.Count - 1 do
    begin
      F := Fields[OFI]; FTN := LowerCase(F.TypeName);
      if      FTN = 'integer' then DefVal := TValue.MakeInt(0)
      else if FTN = 'real'    then DefVal := TValue.MakeFloat(0)
      else if FTN = 'boolean' then DefVal := TValue.MakeBool(False)
      else if FTN = 'string'  then DefVal := TValue.MakeStr('')
      else                         DefVal := TValue.MakeNil;
      New(PVal); PVal^ := DefVal;
      Obj.Fields.AddOrSetValue(LowerCase(F.Name), PVal);
    end;
  finally Fields.Free; end;
end;

function TInterpreter.InvokeMethod(Obj: TObjectInstance; M: TMethodDecl;
  Args: TExprList; CallerEnv: TEnvironment): TValue;
var
  Env: TEnvironment; I: Integer; Param: TParamDecl; ArgVal, UpdVal: TValue;
  FKey: string; PVal: ^TValue; FPtr: Pointer; KeyList: TList<string>; KI: Integer;
begin
  Result := TValue.MakeNil;
  if M.IsAbstract then
    raise Exception.CreateFmt('O método "%s" é abstrato e não possui implementação.', [M.Name]);
  Env := TEnvironment.Create(FGlobal);
  try
    Env.DeclareVar('self', TValue.MakeObject(Obj));
    // Copia campos do objeto para o ambiente local
    if Assigned(Obj) and Assigned(Obj.Fields) then
    begin
      KeyList := TList<string>.Create;
      try
        try for FKey in Obj.Fields.Keys do KeyList.Add(FKey); except end;
        for KI := 0 to KeyList.Count - 1 do
        begin
          FKey := KeyList[KI]; FPtr := Obj.Fields[FKey];
          if Assigned(FPtr) then Env.DeclareVar(FKey, TValue(FPtr^));
        end;
      finally KeyList.Free; end;
    end;
    if Assigned(M.Params) then
      for I := 0 to M.Params.Count - 1 do
      begin
        Param := M.Params[I];
        if I < Args.Count then ArgVal := EvalExpr(Args[I], CallerEnv)
        else ArgVal := TValue.MakeNil;
        Env.DeclareVar(Param.Name, ArgVal);
      end;
    if Assigned(M.Locals) then DeclareVars(Env, M.Locals);
    if M.ReturnType <> '' then Env.DeclareVar('result', TValue.MakeNil);
    if Assigned(M.Body) then
    try ExecBlock(M.Body, Env);
    except
      on E: EExitSignal do
        if M.ReturnType <> '' then Result := E.ReturnVal;
    end;
    if M.ReturnType <> '' then Env.GetVar('result', Result);
    // Sincroniza campos modificados de volta ao objeto
    if Assigned(Obj) and Assigned(Obj.Fields) then
    begin
      KeyList := TList<string>.Create;
      try
        for FKey in Obj.Fields.Keys do KeyList.Add(FKey);
        for KI := 0 to KeyList.Count - 1 do
        begin
          FKey := KeyList[KI];
          if Env.GetVar(FKey, UpdVal) then
          begin
            FPtr := Obj.Fields[FKey];
            if Assigned(FPtr) then TValue(FPtr^) := UpdVal
            else begin New(PVal); PVal^ := UpdVal; Obj.Fields[FKey] := PVal; end;
          end;
        end;
      finally KeyList.Free; end;
    end;
  finally Env.Free; end;
end;

function TInterpreter.EvalFieldExpr(Node: TFieldExpr; Env: TEnvironment): TValue;
var OV: TValue; Obj: TObjectInstance; FPtr: Pointer; FName: string; CE: TCreateExpr;
begin
  Result := TValue.MakeNil;
  if (Node.Obj is TVarExpr) and ClassRegistry.ClassExists(TVarExpr(Node.Obj).Name)
     and (LowerCase(Node.FieldName) = 'create') then
  begin
    CE := TCreateExpr.Create; CE.ClassRef := TVarExpr(Node.Obj).Name;
    Result := EvalCreateExpr(CE, Env); CE.Free;
  end
  else
  begin
    OV := EvalExpr(Node.Obj, Env);
    if OV.Kind <> vkObject then
      raise Exception.CreateFmt('Tentativa de ler o campo "%s" em algo que não é um objeto.', [Node.FieldName]);
    if LowerCase(Node.FieldName) = 'classname' then begin Result := TValue.MakeStr(OV.ObjVal.ObjClass); end
    else
    begin
      Obj := OV.ObjVal; FName := LowerCase(Node.FieldName);
      if Obj.Fields.TryGetValue(FName, FPtr) and Assigned(FPtr) then Result := TValue(FPtr^)
      else raise Exception.CreateFmt('A classe "%s" não possui campo "%s".', [Obj.ObjClass, Node.FieldName]);
    end;
  end;
end;

function TInterpreter.EvalMethodCallExpr(Node: TMethodCallExpr; Env: TEnvironment): TValue;
var OV: TValue; Obj: TObjectInstance; ML: TMethodLookup; CE: TCreateExpr; AI: Integer;
begin
  Result := TValue.MakeNil;
  if (Node.Obj is TVarExpr) and ClassRegistry.ClassExists(TVarExpr(Node.Obj).Name)
     and (LowerCase(Node.MethodName) = 'create') then
  begin
    CE := TCreateExpr.Create; CE.ClassRef := TVarExpr(Node.Obj).Name;
    for AI := 0 to Node.Args.Count - 1 do CE.Args.Add(Node.Args[AI]);
    Result := EvalCreateExpr(CE, Env); CE.Args.Clear; CE.Free;
  end
  else
  begin
    OV := EvalExpr(Node.Obj, Env);
    if LowerCase(Node.MethodName) = 'free' then Exit;
    if OV.Kind <> vkObject then
      raise Exception.CreateFmt('Tentativa de chamar método "%s" em algo que não é um objeto.', [Node.MethodName]);
    Obj := OV.ObjVal; if not Assigned(Obj) then Exit;
    ML := ClassRegistry.ResolveMethod(Obj.ObjClass, Node.MethodName);
    if ML.Found then Result := InvokeMethod(Obj, ML.Method, Node.Args, Env);
  end;
end;

procedure TInterpreter.ExecFieldAssign(Node: TFieldAssignStmt; Env: TEnvironment);
var OV: TValue; Obj: TObjectInstance; FName: string; Val: TValue; FPtr: ^TValue; P: Pointer;
begin
  OV := EvalExpr(Node.Obj, Env);
  if (OV.Kind = vkNil) and (Node.Obj is TVarExpr)
     and ClassRegistry.ClassExists(TVarExpr(Node.Obj).Name) then Exit;
  if OV.Kind <> vkObject then
    raise Exception.CreateFmt('Tentativa de atribuir ao campo "%s" em algo que não é um objeto.', [Node.FieldName]);
  Obj := OV.ObjVal; FName := LowerCase(Node.FieldName); Val := EvalExpr(Node.Value, Env);
  if Obj.Fields.TryGetValue(FName, P) and Assigned(P) then TValue(P^) := Val
  else begin New(FPtr); FPtr^ := Val; Obj.Fields.AddOrSetValue(FName, FPtr); end;
  if Env.HasVar(FName) then Env.SetVar(FName, Val);
end;

procedure TInterpreter.ExecMethodCall(Node: TMethodCallStmt; Env: TEnvironment);
var OV: TValue; Obj: TObjectInstance; ML: TMethodLookup;
begin
  OV := EvalExpr(Node.Obj, Env);
  if LowerCase(Node.MethodName) = 'free' then Exit;
  if OV.Kind <> vkObject then
    raise Exception.CreateFmt('Tentativa de chamar método "%s" em algo que não é um objeto.', [Node.MethodName]);
  Obj := OV.ObjVal; if not Assigned(Obj) then Exit;
  ML := ClassRegistry.ResolveMethod(Obj.ObjClass, Node.MethodName);
  if ML.Found then InvokeMethod(Obj, ML.Method, Node.Args, Env);
end;

procedure TInterpreter.ExecInherited(Node: TInheritedCallStmt; Env: TEnvironment);
var SelfVal, MNVal: TValue; Obj: TObjectInstance;
    CurrentClass, ParentName, MethodName: string;
    ML: TMethodLookup; ParentDecl: TClassDecl;
begin
  if not Env.GetVar('self', SelfVal) or (SelfVal.Kind <> vkObject) then
    raise Exception.Create('"inherited" só pode ser usado dentro de um método.');
  Obj := SelfVal.ObjVal;
  if not Env.GetVar('__class__', SelfVal) then CurrentClass := Obj.ObjClass
  else CurrentClass := SelfVal.SVal;
  ParentDecl := ClassRegistry.FindClass(CurrentClass);
  if not Assigned(ParentDecl) then Exit;
  ParentName := ParentDecl.ParentName; if ParentName = '' then Exit;
  MethodName := Node.MethodName;
  if MethodName = '' then if Env.GetVar('__method__', MNVal) then MethodName := MNVal.SVal;
  if MethodName = '' then Exit;
  ML := ClassRegistry.ResolveMethod(ParentName, MethodName);
  if ML.Found then InvokeMethod(Obj, ML.Method, Node.Args, Env);
end;

function TInterpreter.EvalIsExpr(Obj: TValue; const TypeName: string): TValue;
begin
  if Obj.Kind <> vkObject then begin Result := TValue.MakeBool(False); Exit; end;
  if ClassRegistry.ClassExists(TypeName) then
    Result := TValue.MakeBool(ClassRegistry.IsDescendant(Obj.ObjVal.ObjClass, TypeName))
  else if ClassRegistry.InterfaceExists(TypeName) then
    Result := TValue.MakeBool(ClassRegistry.Implements(Obj.ObjVal.ObjClass, TypeName))
  else
    Result := TValue.MakeBool(False);
end;

// Auxiliar para GfxMouseX/Y — retorna T se B, senão F
function IfThenInt(B: Boolean; T, F: Integer): Integer;
begin
  if B then Result := T else Result := F;
end;

end.
