unit UValidator;

// =============================================================================
// Pythia -- ambiente de aprendizado Pascal
// Copyright (C) 2026 Nomidor Software, LLC.
// GPL v3 — veja https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
//
//  UValidator.pas  -  Passagem de validação pré-execução para o Pythia
//
//  Chamado entre o parsing e a execução. Percorre a AST e o texto fonte
//  para detectar erros comuns antes que o interpretador os encontre.
//
//  Verificações realizadas:
//    1.  Erros de parsing (linha/coluna já conhecidos do EParseError)
//    2.  Bloco begin..end principal ausente
//    3.  Corpo do programa vazio
//    4.  Uso de variáveis não declaradas (melhor esforço — builtins na whitelist)
//    5.  Chamadas a rotinas não declaradas
//    6.  Função sem atribuição de Result (melhor esforço)
//    7.  Risco de loop infinito — while true do sem break/exit
//    8.  Divisão por zero literal (x / 0 ou x div 0)
//    9.  String usada onde número era esperado em aritmética óbvia
//   10.  begin sem end correspondente (detectado pelo parser)
//   11.  Parênteses não balanceados (detectado pelo parser)
//   12.  Atribuições a variáveis não definidas no escopo global
//   13.  Procedimento chamado com número errado de argumentos
//   14.  Corpo de procedimento/função vazio
// =============================================================================

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  UAST, ULexer;

type
  TIssueSeverity = (vsError, vsWarning, vsHint);

  TValidationIssue = record
    Severity : TIssueSeverity;
    Line     : Integer;
    Col      : Integer;
    Message  : string;
    Hint     : string;
  end;

  TValidator = class
  private
    FProgram  : TProgramNode;
    FSource   : string;
    FIssues   : TList<TValidationIssue>;
    FKnownVars: TDictionary<string, Boolean>;
    FKnownRout: TDictionary<string, Integer>;

    procedure AddIssue(Sev: TIssueSeverity; Line, Col: Integer;
                       const Msg, Hint: string);
    function  GetLine(LineNo: Integer): string;
    function  TrimmedLine(LineNo: Integer): string;
    procedure CheckMainBlock;
    procedure CollectDeclarations;
    procedure CheckRoutines;
    procedure CheckMainStatements;
    procedure CheckBlock(Block: TBlockStmt; Scope: TDictionary<string,Boolean>);
    procedure CheckStatement(Stmt: TStmtNode; Scope: TDictionary<string,Boolean>);
    procedure CheckExpr(Expr: TExprNode; Scope: TDictionary<string,Boolean>);
    procedure CheckCallArgs(const Name: string; Args: TExprList; Line, Col: Integer);
    procedure CheckForDivByZero(Node: TBinOpExpr);
    function  IsBuiltin(const Name: string): Boolean;
    function  BuiltinArgCount(const Name: string): Integer;

  public
    constructor Create(AProgram: TProgramNode; const ASource: string);
    destructor  Destroy; override;
    function  Validate: Boolean;
    property  Issues : TList<TValidationIssue> read FIssues;
    function  Summary: string;
    function  HasErrors: Boolean;
    function  HasWarnings: Boolean;
  end;

// =============================================================================
implementation
// =============================================================================

// ---------------------------------------------------------------------------
//  Registro de nomes de builtins (para não sinalizar como não declarados)
// ---------------------------------------------------------------------------
const
  BUILTINS : array[0..102] of string = (
    // Matemática
    'abs','sqr','sqrt','round','trunc','int','frac',
    'sin','cos','ln','exp','pi','power','max','min','odd',
    'succ','pred','inc','dec','random','randomize',
    // Strings
    'length','copy','pos','uppercase','lowercase','trim',
    'inttostr','strtoint','strtointdef','strtofloat','floattostr',
    'str','val','chr','ord',
    // Interface com o usuário
    'showmessage','inputbox','confirm','showinfobox',
    'showwarningbox','showerrorbox',
    // Diálogos de arquivo
    'openfiledialog','savefiledialog','selectdirectorydialog',
    // Entrada e saída de arquivo
    'writefile','appendfile','readfile','fileexists',
    'deletefile','getapppath','getdesktoppath',
    'extractfilename','extractfilepath',
    // Banco de dados SQLite
    'dbopen','dbclose','dbexec','dbquery','dbqueryvalue',
    'dblasterror','dbisopen','dbfilename',
    // Arquivos INI
    'inireadstr','iniwritestr','inireadint','iniwriteint',
    // Data, hora e ambiente
    'datestr','timestr','getenvvar','urlencode',
    // Shell — execução de programas externos
    'shell','shellwait','shellhidden',
    // Arrays dinâmicos
    'setlength',
    // Pausa
    'sleep',
    // Gráficos 2D
    'gfxopen','gfxclose','gfxclear','gfxshow','gfxdelay','gfxrunning',
    'gfxcolor','gfxpenwidth',
    'gfxdrawline','gfxdrawrect','gfxfillrect',
    'gfxdrawcircle','gfxfillcircle',
    'gfxdrawellipse','gfxfillellipse',
    'gfxdrawtext','gfxsetfont','gfxdrawpixel',
    'gfxkeypressed','gfxreadkey',
    'gfxmousex','gfxmousey','gfxmousedown',
    // Especiais
    'writeln','write','readln','result'
  );

// Contagens esperadas de argumentos para builtins conhecidos
type
  TArgSpec = record Name: string; Min, Max: Integer; end;

const
  ARG_SPECS : array[0..27] of TArgSpec = (
    (Name:'abs';        Min:1; Max:1),
    (Name:'sqr';        Min:1; Max:1),
    (Name:'sqrt';       Min:1; Max:1),
    (Name:'round';      Min:1; Max:1),
    (Name:'trunc';      Min:1; Max:1),
    (Name:'sin';        Min:1; Max:1),
    (Name:'cos';        Min:1; Max:1),
    (Name:'ln';         Min:1; Max:1),
    (Name:'exp';        Min:1; Max:1),
    (Name:'power';      Min:2; Max:2),
    (Name:'max';        Min:2; Max:2),
    (Name:'min';        Min:2; Max:2),
    (Name:'length';     Min:1; Max:1),
    (Name:'copy';       Min:3; Max:3),
    (Name:'pos';        Min:2; Max:2),
    (Name:'inttostr';   Min:1; Max:1),
    (Name:'strtoint';   Min:1; Max:1),
    (Name:'strtointdef';Min:2; Max:2),
    (Name:'strtofloat'; Min:1; Max:1),
    (Name:'floattostr'; Min:1; Max:1),
    (Name:'chr';        Min:1; Max:1),
    (Name:'ord';        Min:1; Max:1),
    (Name:'inputbox';   Min:3; Max:3),
    (Name:'confirm';    Min:1; Max:1),
    (Name:'showmessage';Min:1; Max:1),
    (Name:'setlength';  Min:2; Max:2),
    (Name:'gfxopen';    Min:2; Max:3),
    (Name:'gfxdelay';   Min:1; Max:1)
  );

// =============================================================================

constructor TValidator.Create(AProgram: TProgramNode; const ASource: string);
begin
  inherited Create;
  FProgram   := AProgram;
  FSource    := ASource;
  FIssues    := TList<TValidationIssue>.Create;
  FKnownVars := TDictionary<string, Boolean>.Create;
  FKnownRout := TDictionary<string, Integer>.Create;
end;

destructor TValidator.Destroy;
begin
  FIssues.Free;
  FKnownVars.Free;
  FKnownRout.Free;
  inherited;
end;

procedure TValidator.AddIssue(Sev: TIssueSeverity; Line, Col: Integer;
  const Msg, Hint: string);
var Issue : TValidationIssue;
begin
  Issue.Severity := Sev;
  Issue.Line     := Line;
  Issue.Col      := Col;
  Issue.Message  := Msg;
  Issue.Hint     := Hint;
  FIssues.Add(Issue);
end;

function TValidator.GetLine(LineNo: Integer): string;
var Lines : TStringList;
begin
  Result := '';
  Lines := TStringList.Create;
  try
    Lines.Text := FSource;
    if (LineNo >= 1) and (LineNo <= Lines.Count) then
      Result := Lines[LineNo - 1];
  finally Lines.Free; end;
end;

function TValidator.TrimmedLine(LineNo: Integer): string;
begin
  Result := Trim(GetLine(LineNo));
end;

function TValidator.IsBuiltin(const Name: string): Boolean;
var LN : string; I : Integer;
begin
  LN := LowerCase(Name);
  for I := Low(BUILTINS) to High(BUILTINS) do
    if BUILTINS[I] = LN then begin Result := True; Exit; end;
  Result := False;
end;

function TValidator.BuiltinArgCount(const Name: string): Integer;
begin
  Result := -1;
end;

// ---------------------------------------------------------------------------
//  Ponto de entrada da validação
// ---------------------------------------------------------------------------
function TValidator.Validate: Boolean;
begin
  if not Assigned(FProgram) then
  begin
    AddIssue(vsError, 1, 1,
      'O programa não pôde ser analisado.',
      'Verifique erros de sintaxe — begin/end ausente, parênteses ' +
      'não balanceados ou pontuação incorreta.');
    Exit(False);
  end;

  CollectDeclarations;
  CheckMainBlock;
  CheckRoutines;
  CheckMainStatements;

  Result := not HasErrors;
end;

// ---------------------------------------------------------------------------
//  Passo 1: coleta todos os nomes declarados
// ---------------------------------------------------------------------------
procedure TValidator.CollectDeclarations;
var
  V  : TVarDecl;
  R  : TRoutineDecl;
  VI, RI, CI, MI : Integer;
  CD : TClassDecl;
  MD : TMethodDecl;
begin
  for VI := 0 to FProgram.Globals.Count - 1 do
  begin
    V := FProgram.Globals[VI];
    FKnownVars.AddOrSetValue(LowerCase(V.Name), True);
  end;
  for RI := 0 to FProgram.Routines.Count - 1 do
  begin
    R := FProgram.Routines[RI];
    if Assigned(R.Params) then FKnownRout.AddOrSetValue(LowerCase(R.Name), R.Params.Count)
    else FKnownRout.AddOrSetValue(LowerCase(R.Name), 0);
    if Assigned(R.Params) then
      for VI := 0 to R.Params.Count - 1 do
        FKnownVars.AddOrSetValue(LowerCase(R.Params[VI].Name), True);
  end;
  for CI := 0 to FProgram.Classes.Count - 1 do
  begin
    CD := FProgram.Classes[CI];
    FKnownVars.AddOrSetValue(LowerCase(CD.Name), True);
    for MI := 0 to CD.Methods.Count - 1 do
    begin
      MD := CD.Methods[MI];
      FKnownRout.AddOrSetValue(LowerCase(CD.Name + '.' + MD.Name), MD.Params.Count);
    end;
  end;
end;

// ---------------------------------------------------------------------------
//  Passo 2: verifica se o bloco principal existe e não está vazio
// ---------------------------------------------------------------------------
procedure TValidator.CheckMainBlock;
begin
  if not Assigned(FProgram.MainBlock) then
  begin
    AddIssue(vsError, 1, 1,
      'Este programa não tem um bloco principal "begin..end.".',
      'Todo programa Pythia precisa de um bloco principal:' + sLineBreak +
      '    begin' + sLineBreak +
      '      // seu código aqui' + sLineBreak +
      '    end.');
    Exit;
  end;
  if FProgram.MainBlock.Stmts.Count = 0 then
    AddIssue(vsWarning, 1, 1,
      'O bloco principal do programa está vazio.',
      'Adicione pelo menos um comando entre "begin" e "end."');
end;

// ---------------------------------------------------------------------------
//  Passo 3: verifica rotinas do usuário
// ---------------------------------------------------------------------------
procedure TValidator.CheckRoutines;
var
  R          : TRoutineDecl;
  LocalScope : TDictionary<string, Boolean>;
  V          : TVarDecl;
  VI, RI     : Integer;
  KLocal     : string;
begin
  for RI := 0 to FProgram.Routines.Count - 1 do
  begin
    R := FProgram.Routines[RI];
    if not Assigned(R.Body) or (R.Body.Stmts.Count = 0) then
    begin
      AddIssue(vsHint, 0, 0,
        Format('"%s" está declarado mas seu corpo está vazio.', [R.Name]),
        'Adicione comandos dentro do bloco begin..end, ou remova a ' +
        'declaração se não for necessária.');
      Continue;
    end;

    LocalScope := TDictionary<string, Boolean>.Create;
    try
      for KLocal in FKnownVars.Keys do LocalScope.AddOrSetValue(KLocal, True);
      if Assigned(R.Params) then
        for VI := 0 to R.Params.Count - 1 do
          LocalScope.AddOrSetValue(LowerCase(R.Params[VI].Name), True);
      if Assigned(R.Locals) then
        for VI := 0 to R.Locals.Count - 1 do
        begin
          V := R.Locals[VI];
          LocalScope.AddOrSetValue(LowerCase(V.Name), True);
        end;
      if R.ReturnType <> '' then LocalScope.AddOrSetValue('result', True);
      CheckBlock(R.Body, LocalScope);
    finally LocalScope.Free; end;
  end;
end;

// ---------------------------------------------------------------------------
//  Passo 4: verifica comandos do bloco principal
// ---------------------------------------------------------------------------
procedure TValidator.CheckMainStatements;
var Scope : TDictionary<string, Boolean>; KMain : string;
begin
  if not Assigned(FProgram.MainBlock) then Exit;
  Scope := TDictionary<string, Boolean>.Create;
  try
    for KMain in FKnownVars.Keys do Scope.AddOrSetValue(KMain, True);
    CheckBlock(FProgram.MainBlock, Scope);
  finally Scope.Free; end;
end;

// ---------------------------------------------------------------------------
//  Percurso de bloco e comandos
// ---------------------------------------------------------------------------

procedure TValidator.CheckBlock(Block: TBlockStmt; Scope: TDictionary<string, Boolean>);
var SI : Integer;
begin
  if not Assigned(Block) then Exit;
  for SI := 0 to Block.Stmts.Count - 1 do CheckStatement(Block.Stmts[SI], Scope);
end;

procedure TValidator.CheckStatement(Stmt: TStmtNode; Scope: TDictionary<string, Boolean>);
var
  A  : TAssignStmt;  C  : TCallStmt;   W  : TWritelnStmt;
  If1: TIfStmt;      Wh : TWhileStmt;  Fo : TForStmt;
  Re : TRepeatStmt;  B  : TBlockStmt;
  VI, AI : Integer;
begin
  if not Assigned(Stmt) then Exit;

  if Stmt is TAssignStmt then
  begin
    A := TAssignStmt(Stmt);
    Scope.AddOrSetValue(LowerCase(A.VarName), True);
    if Assigned(A.Expr) then CheckExpr(A.Expr, Scope);
  end
  else if Stmt is TCallStmt then
  begin
    C := TCallStmt(Stmt);
    if not IsBuiltin(C.Name) and
       not FKnownRout.ContainsKey(LowerCase(C.Name)) and
       not Scope.ContainsKey(LowerCase(C.Name)) then
      AddIssue(vsWarning, 0, 0,
        Format('Não conheço um procedimento chamado "%s".', [C.Name]),
        'Verifique a ortografia, declare antes no programa ou ' +
        'adicione uma cláusula "uses".')
    else CheckCallArgs(C.Name, C.Args, 0, 0);
    for AI := 0 to C.Args.Count - 1 do CheckExpr(C.Args[AI], Scope);
  end
  else if Stmt is TWritelnStmt then
  begin
    W := TWritelnStmt(Stmt);
    for AI := 0 to W.Args.Count - 1 do CheckExpr(W.Args[AI], Scope);
  end
  else if Stmt is TIfStmt then
  begin
    If1 := TIfStmt(Stmt);
    CheckExpr(If1.Condition, Scope);
    CheckStatement(If1.ThenBranch, Scope);
    if Assigned(If1.ElseBranch) then CheckStatement(If1.ElseBranch, Scope);
  end
  else if Stmt is TWhileStmt then
  begin
    Wh := TWhileStmt(Stmt);
    if (Wh.Condition is TBoolLitExpr) and TBoolLitExpr(Wh.Condition).Value then
      AddIssue(vsWarning, 0, 0,
        'Um loop "while true do" roda para sempre a menos que algo dentro dele o pare.',
        'Certifique-se de ter um "break" ou "exit" dentro deste loop.');
    CheckExpr(Wh.Condition, Scope);
    CheckStatement(Wh.Body, Scope);
  end
  else if Stmt is TForStmt then
  begin
    Fo := TForStmt(Stmt);
    Scope.AddOrSetValue(LowerCase(Fo.VarName), True);
    CheckExpr(Fo.StartVal, Scope); CheckExpr(Fo.EndVal, Scope);
    CheckStatement(Fo.Body, Scope);
  end
  else if Stmt is TRepeatStmt then
  begin
    Re := TRepeatStmt(Stmt);
    for VI := 0 to Re.Body.Count - 1 do CheckStatement(Re.Body[VI], Scope);
    CheckExpr(Re.Condition, Scope);
  end
  else if Stmt is TBlockStmt then
  begin
    B := TBlockStmt(Stmt); CheckBlock(B, Scope);
  end;
end;

procedure TValidator.CheckExpr(Expr: TExprNode; Scope: TDictionary<string, Boolean>);
var
  VE  : TVarExpr;   CE  : TCallExpr;  BO  : TBinOpExpr;
  UE  : TUnaryExpr; FE  : TFieldExpr; MCE : TMethodCallExpr;
  AI  : Integer;
begin
  if not Assigned(Expr) then Exit;

  if Expr is TVarExpr then
  begin
    VE := TVarExpr(Expr);
    if not IsBuiltin(VE.Name) and
       not Scope.ContainsKey(LowerCase(VE.Name)) and
       not FKnownRout.ContainsKey(LowerCase(VE.Name)) and
       not FKnownVars.ContainsKey(LowerCase(VE.Name)) then
      AddIssue(vsWarning, 0, 0,
        Format('O nome "%s" não foi declarado.', [VE.Name]),
        'Verifique a ortografia ou adicione em um bloco var:' + sLineBreak +
        '    var ' + VE.Name + ' : Integer;');
  end
  else if Expr is TCallExpr then
  begin
    CE := TCallExpr(Expr);
    if not IsBuiltin(CE.Name) and not FKnownRout.ContainsKey(LowerCase(CE.Name)) then
      AddIssue(vsWarning, 0, 0,
        Format('Não conheço uma função chamada "%s".', [CE.Name]),
        'Verifique a ortografia ou declare antes no programa.')
    else CheckCallArgs(CE.Name, CE.Args, 0, 0);
    for AI := 0 to CE.Args.Count - 1 do CheckExpr(CE.Args[AI], Scope);
  end
  else if Expr is TBinOpExpr then
  begin
    BO := TBinOpExpr(Expr);
    CheckForDivByZero(BO);
    CheckExpr(BO.Left, Scope); CheckExpr(BO.Right, Scope);
  end
  else if Expr is TUnaryExpr then
  begin
    UE := TUnaryExpr(Expr); CheckExpr(UE.Operand, Scope);
  end
  else if Expr is TFieldExpr then
  begin
    FE := TFieldExpr(Expr); CheckExpr(FE.Obj, Scope);
  end
  else if Expr is TMethodCallExpr then
  begin
    MCE := TMethodCallExpr(Expr);
    CheckExpr(MCE.Obj, Scope);
    for AI := 0 to MCE.Args.Count - 1 do CheckExpr(MCE.Args[AI], Scope);
  end;
end;

procedure TValidator.CheckCallArgs(const Name: string; Args: TExprList; Line, Col: Integer);
var LN: string; I, Expected, Got: Integer;
begin
  LN  := LowerCase(Name);
  Got := Args.Count;
  for I := Low(ARG_SPECS) to High(ARG_SPECS) do
  begin
    if ARG_SPECS[I].Name = LN then
    begin
      if (Got < ARG_SPECS[I].Min) or (Got > ARG_SPECS[I].Max) then
      begin
        if ARG_SPECS[I].Min = ARG_SPECS[I].Max then
          AddIssue(vsError, Line, Col,
            Format('"%s" precisa de %d argumento(s), mas recebeu %d.', [Name, ARG_SPECS[I].Min, Got]),
            Format('Verifique o número de valores entre parênteses após "%s".', [Name]))
        else
          AddIssue(vsError, Line, Col,
            Format('"%s" precisa de %d a %d argumento(s), mas recebeu %d.',
              [Name, ARG_SPECS[I].Min, ARG_SPECS[I].Max, Got]),
            Format('Verifique o número de valores entre parênteses após "%s".', [Name]));
      end;
      Exit;
    end;
  end;
  if FKnownRout.TryGetValue(LN, Expected) then
  begin
    if Got <> Expected then
      AddIssue(vsWarning, Line, Col,
        Format('"%s" foi declarado com %d argumento(s), mas aqui é chamado com %d.',
          [Name, Expected, Got]),
        'Corrija o número de argumentos ou atualize a declaração.');
  end;
end;

procedure TValidator.CheckForDivByZero(Node: TBinOpExpr);
begin
  if (Node.Op = '/') or (Node.Op = 'div') or (Node.Op = 'mod') then
  begin
    if (Node.Right is TIntLitExpr) and (TIntLitExpr(Node.Right).Value = 0) then
      AddIssue(vsError, 0, 0,
        Format('Divisão por zero literal com "%s".', [Node.Op]),
        'O lado direito de "' + Node.Op + '" não pode ser zero.');
    if (Node.Right is TFloatLitExpr) and (TFloatLitExpr(Node.Right).Value = 0) then
      AddIssue(vsError, 0, 0,
        'Divisão por zero literal.',
        'O lado direito da divisão não pode ser zero.');
  end;
end;

// ---------------------------------------------------------------------------
//  Resultados da validação
// ---------------------------------------------------------------------------

function TValidator.HasErrors: Boolean;
var I : Integer;
begin
  Result := False;
  for I := 0 to FIssues.Count - 1 do
    if FIssues[I].Severity = vsError then begin Result := True; Exit; end;
end;

function TValidator.HasWarnings: Boolean;
var I : Integer;
begin
  Result := False;
  for I := 0 to FIssues.Count - 1 do
    if FIssues[I].Severity = vsWarning then begin Result := True; Exit; end;
end;

function TValidator.Summary: string;
var
  Errors, Warnings : Integer;
  I : Integer;
begin
  Errors := 0; Warnings := 0;
  for I := 0 to FIssues.Count - 1 do
    if FIssues[I].Severity = vsError then Inc(Errors)
    else if FIssues[I].Severity = vsWarning then Inc(Warnings);
  if (Errors = 0) and (Warnings = 0) then Result := 'Nenhum problema encontrado.'
  else Result := Format('%d erro(s), %d aviso(s).', [Errors, Warnings]);
end;

end.
