unit UExampleProjects;

// =============================================================================
// Pythia -- Multi-Language Learning IDE
// Copyright (C) 2026 Nomidor Software, LLC.
// GPL v3 -- see/veja https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
//
//  UExampleProjects.pas  --  Real-world Pythia example projects
//                            Projetos de exemplo do mundo real para o Pythia
//
//  English:
//    Each example is a self-contained .mdp program demonstrating a real
//    programming technique used in professional software development.
//    Categories: Data Processing, Algorithms, Object-Oriented, Systems & Tools,
//                Games & Fun
//
//  Portugues:
//    Cada exemplo e um programa .mdp completo demonstrando uma tecnica de
//    programacao real usada no desenvolvimento profissional de software.
// =============================================================================

interface

uses System.SysUtils, System.Classes, System.Generics.Collections;

type
  TExampleFile = record
    FileName : string;
    Source   : string;
    IsMain   : Boolean;
  end;

  TExampleProject = record
    Name        : string;
    Category    : string;
    Description : string;
    Source      : string;
    Files       : TArray<TExampleFile>;
    IsMultiFile : Boolean;
  end;

  TExampleLibrary = class
  private
    FList : TList<TExampleProject>;
    procedure Build;
  public
    constructor Create;
    destructor  Destroy; override;
    function Count : Integer;
    function Items(I: Integer) : TExampleProject;
    function Categories : TStringList;
  end;

// =============================================================================
implementation
// =============================================================================

constructor TExampleLibrary.Create;
begin
  inherited;
  FList := TList<TExampleProject>.Create;
  Build;
end;

destructor TExampleLibrary.Destroy;
begin
  FList.Free;
  inherited;
end;

function TExampleLibrary.Count: Integer;
begin Result := FList.Count; end;

function TExampleLibrary.Items(I: Integer): TExampleProject;
begin Result := FList[I]; end;

function TExampleLibrary.Categories: TStringList;
var I : Integer;
begin
  Result := TStringList.Create;
  Result.Duplicates := dupIgnore;
  Result.Sorted     := False;
  for I := 0 to FList.Count - 1 do
    if Result.IndexOf(FList[I].Category) < 0 then
      Result.Add(FList[I].Category);
end;

procedure TExampleLibrary.Build;

  procedure Add(const Name, Cat, Desc, Src: string);
  var E: TExampleProject;
  begin
    E.Name        := Name;
    E.Category    := Cat;
    E.Description := Desc;
    E.Source      := Src;
    E.IsMultiFile := False;
    E.Files       := nil;
    FList.Add(E);
  end;

const NL = #13#10;

begin

// =============================================================================
//  DATA PROCESSING / PROCESSAMENTO DE DADOS
// =============================================================================

Add('CSV Analyser', 'Data Processing',
  'Read a CSV, compute mean and standard deviation, find outliers',
  '// CSV ANALYSER' + NL +
  '// Reads comma-separated revenue data, computes statistics,' + NL +
  '// identifies outliers beyond 2 standard deviations.' + NL +
  '// Teaches: file I/O, dynamic arrays, statistical formulas' + NL +
  NL +
  'var' + NL +
  '  f           : TextFile;' + NL +
  '  line, field : String;' + NL +
  '  values      : array of Double;' + NL +
  '  n, i, p     : Integer;' + NL +
  '  v, sum, mean, variance, stddev : Double;' + NL +
  'begin' + NL +
  '  // Write sample CSV / Escreve CSV de exemplo' + NL +
  '  AssignFile(f, ''sales.csv''); Rewrite(f);' + NL +
  '  writeln(f, ''Month,Revenue'');' + NL +
  '  writeln(f, ''Jan,45000'');' + NL +
  '  writeln(f, ''Feb,52000'');' + NL +
  '  writeln(f, ''Mar,48000'');' + NL +
  '  writeln(f, ''Apr,51000'');' + NL +
  '  writeln(f, ''May,120000'');  // outlier' + NL +
  '  writeln(f, ''Jun,49000'');' + NL +
  '  writeln(f, ''Jul,53000'');' + NL +
  '  writeln(f, ''Aug,47000'');' + NL +
  '  CloseFile(f);' + NL +
  NL +
  '  // Parse CSV / Analisa CSV' + NL +
  '  Reset(f);' + NL +
  '  readln(f, line);  // skip header' + NL +
  '  n := 0;' + NL +
  '  while not Eof(f) do' + NL +
  '  begin' + NL +
  '    readln(f, line);' + NL +
  '    p := Pos('','', line);' + NL +
  '    if p > 0 then' + NL +
  '    begin' + NL +
  '      field := Copy(line, p + 1, Length(line));' + NL +
  '      v := StrToFloat(Trim(field));' + NL +
  '      SetLength(values, n + 1);' + NL +
  '      values[n] := v;' + NL +
  '      Inc(n);' + NL +
  '    end;' + NL +
  '  end;' + NL +
  '  CloseFile(f);' + NL +
  NL +
  '  // Statistics / Estatisticas' + NL +
  '  sum := 0;' + NL +
  '  for i := 0 to n - 1 do sum := sum + values[i];' + NL +
  '  mean := sum / n;' + NL +
  '  variance := 0;' + NL +
  '  for i := 0 to n - 1 do' + NL +
  '    variance := variance + (values[i] - mean) * (values[i] - mean);' + NL +
  '  stddev := Sqrt(variance / n);' + NL +
  NL +
  '  writeln(''=== Revenue Analysis ==='');' + NL +
  '  writeln(Format(''Mean:   $%10.0f'', [mean]));' + NL +
  '  writeln(Format(''StdDev: $%10.0f'', [stddev]));' + NL +
  '  writeln;' + NL +
  '  writeln(''Outliers (> 2 std deviations):'');' + NL +
  '  for i := 0 to n - 1 do' + NL +
  '    if Abs(values[i] - mean) > 2 * stddev then' + NL +
  '      writeln(Format(''  Month %d: $%.0f *** OUTLIER'', [i + 1, values[i]]));' + NL +
  'end.'
);

Add('INI Config Manager', 'Data Processing',
  'Load, validate and save application settings via INI file',
  '// INI CONFIG MANAGER' + NL +
  '// Professional config pattern: write defaults on first run,' + NL +
  '// validate on load, report problems.' + NL +
  NL +
  'var' + NL +
  '  cfg         : String;' + NL +
  '  host, theme : String;' + NL +
  '  port, retry : Integer;' + NL +
  'begin' + NL +
  '  cfg := GetAppPath + ''myapp.ini'';' + NL +
  NL +
  '  // Write defaults if first run / Padrao na primeira execucao' + NL +
  '  if not FileExists(cfg) then' + NL +
  '  begin' + NL +
  '    writeln(''First run -- writing defaults...'');' + NL +
  '    IniWriteStr(cfg, ''Server'', ''Host'',       ''api.example.com'');' + NL +
  '    IniWriteInt(cfg, ''Server'', ''Port'',       8443);' + NL +
  '    IniWriteInt(cfg, ''Server'', ''RetryCount'', 3);' + NL +
  '    IniWriteStr(cfg, ''UI'',     ''Theme'',      ''dark'');' + NL +
  '  end;' + NL +
  NL +
  '  // Load / Carrega' + NL +
  '  host  := IniReadStr(cfg, ''Server'', ''Host'',       ''localhost'');' + NL +
  '  port  := IniReadInt(cfg, ''Server'', ''Port'',       80);' + NL +
  '  retry := IniReadInt(cfg, ''Server'', ''RetryCount'', 1);' + NL +
  '  theme := IniReadStr(cfg, ''UI'',     ''Theme'',      ''light'');' + NL +
  NL +
  '  // Validate / Valida' + NL +
  '  if (port < 1) or (port > 65535) then' + NL +
  '  begin' + NL +
  '    writeln(''WARNING: Invalid port -- resetting to 443'');' + NL +
  '    port := 443;' + NL +
  '    IniWriteInt(cfg, ''Server'', ''Port'', port);' + NL +
  '  end;' + NL +
  NL +
  '  writeln(''=== Configuration Loaded ==='');' + NL +
  '  writeln(''Server:  '', host, '':'', port);' + NL +
  '  writeln(''Retries: '', retry);' + NL +
  '  writeln(''Theme:   '', theme);' + NL +
  'end.'
);

Add('Word Frequency Counter', 'Data Processing',
  'Tokenise text, count word frequencies, print top results',
  '// WORD FREQUENCY COUNTER' + NL +
  '// Real use: log analysis, text mining, keyword extraction.' + NL +
  '// Demonstrates: string tokenisation, parallel arrays, sort.' + NL +
  NL +
  'var' + NL +
  '  text        : String;' + NL +
  '  words, keys : array of String;' + NL +
  '  counts      : array of Integer;' + NL +
  '  word, cur   : String;' + NL +
  '  i, j, p     : Integer;' + NL +
  '  found       : Boolean;' + NL +
  '  tmpS        : String;' + NL +
  '  tmpI        : Integer;' + NL +
  'begin' + NL +
  '  text := ''to be or not to be that is the question '' +' + NL +
  '          ''whether tis nobler in the mind to suffer '' +' + NL +
  '          ''the slings and arrows of outrageous fortune'';' + NL +
  NL +
  '  // Tokenise by spaces / Tokeniza por espacos' + NL +
  '  SetLength(words, 0);' + NL +
  '  cur := LowerCase(text) + '' '';' + NL +
  '  p   := Pos('' '', cur);' + NL +
  '  while p > 0 do' + NL +
  '  begin' + NL +
  '    word := Trim(Copy(cur, 1, p - 1));' + NL +
  '    if word <> '''' then' + NL +
  '    begin' + NL +
  '      SetLength(words, Length(words) + 1);' + NL +
  '      words[High(words)] := word;' + NL +
  '    end;' + NL +
  '    cur := Copy(cur, p + 1, Length(cur));' + NL +
  '    p   := Pos('' '', cur);' + NL +
  '  end;' + NL +
  NL +
  '  // Count frequencies / Conta frequencias' + NL +
  '  SetLength(keys, 0); SetLength(counts, 0);' + NL +
  '  for i := 0 to High(words) do' + NL +
  '  begin' + NL +
  '    found := False;' + NL +
  '    for j := 0 to High(keys) do' + NL +
  '      if keys[j] = words[i] then' + NL +
  '      begin Inc(counts[j]); found := True; Break; end;' + NL +
  '    if not found then' + NL +
  '    begin' + NL +
  '      SetLength(keys, Length(keys) + 1);' + NL +
  '      SetLength(counts, Length(counts) + 1);' + NL +
  '      keys[High(keys)]     := words[i];' + NL +
  '      counts[High(counts)] := 1;' + NL +
  '    end;' + NL +
  '  end;' + NL +
  NL +
  '  // Sort by count descending / Ordena por contagem decrescente' + NL +
  '  for i := 0 to High(keys) - 1 do' + NL +
  '    for j := 0 to High(keys) - 1 - i do' + NL +
  '      if counts[j] < counts[j + 1] then' + NL +
  '      begin' + NL +
  '        tmpI := counts[j]; counts[j] := counts[j+1]; counts[j+1] := tmpI;' + NL +
  '        tmpS := keys[j];   keys[j]   := keys[j+1];   keys[j+1]   := tmpS;' + NL +
  '      end;' + NL +
  NL +
  '  writeln(''Top words:'');' + NL +
  '  for i := 0 to Min(9, High(keys)) do' + NL +
  '    writeln(Format(''  %-15s %d'', [keys[i], counts[i]]));' + NL +
  'end.'
);

// =============================================================================
//  ALGORITHMS / ALGORITMOS
// =============================================================================

Add('Binary Search', 'Algorithms',
  'O(log n) search vs O(n) linear search -- see the difference',
  '// BINARY SEARCH vs LINEAR SEARCH' + NL +
  '// Binary search finds in ~10 steps what linear takes ~500 steps.' + NL +
  '// Requirement: array must be sorted.' + NL +
  NL +
  'function LinearSearch(var Arr: array of Integer; N, Target: Integer): Integer;' + NL +
  'var i : Integer;' + NL +
  'begin' + NL +
  '  Result := -1;' + NL +
  '  for i := 0 to N - 1 do' + NL +
  '    if Arr[i] = Target then begin Result := i; Exit; end;' + NL +
  'end;' + NL +
  NL +
  'function BinarySearch(var Arr: array of Integer; N, Target: Integer): Integer;' + NL +
  'var lo, hi, mid : Integer;' + NL +
  'begin' + NL +
  '  lo := 0; hi := N - 1; Result := -1;' + NL +
  '  while lo <= hi do' + NL +
  '  begin' + NL +
  '    mid := (lo + hi) div 2;' + NL +
  '    if    Arr[mid] = Target then begin Result := mid; Exit; end' + NL +
  '    else if Arr[mid] < Target then lo := mid + 1' + NL +
  '    else                           hi := mid - 1;' + NL +
  '  end;' + NL +
  'end;' + NL +
  NL +
  'var' + NL +
  '  data   : array of Integer;' + NL +
  '  i, idx : Integer;' + NL +
  'begin' + NL +
  '  SetLength(data, 1000);' + NL +
  '  for i := 0 to 999 do data[i] := i * 2;  // even numbers 0..1998' + NL +
  NL +
  '  idx := LinearSearch(data, 1000, 842);' + NL +
  '  writeln(''Linear search for 842: index = '', idx);' + NL +
  NL +
  '  idx := BinarySearch(data, 1000, 842);' + NL +
  '  writeln(''Binary search for 842: index = '', idx);' + NL +
  NL +
  '  writeln(''Linear worst case:  1000 comparisons'');' + NL +
  '  writeln(''Binary worst case:    10 comparisons (log2 1000 = 10)'');' + NL +
  'end.'
);

Add('QuickSort', 'Algorithms',
  'In-place O(n log n) sort with Lomuto partition',
  '// QUICKSORT -- O(n log n) average, O(1) extra space' + NL +
  '// One of the fastest general-purpose sorting algorithms.' + NL +
  '// Demonstrates: recursion, in-place partitioning, var params.' + NL +
  NL +
  'procedure Swap(var A, B: Integer);' + NL +
  'var T : Integer;' + NL +
  'begin T := A; A := B; B := T; end;' + NL +
  NL +
  'function Partition(var Arr: array of Integer; Lo, Hi: Integer): Integer;' + NL +
  'var pivot, i, j : Integer;' + NL +
  'begin' + NL +
  '  pivot := Arr[Hi]; i := Lo - 1;' + NL +
  '  for j := Lo to Hi - 1 do' + NL +
  '    if Arr[j] <= pivot then' + NL +
  '    begin Inc(i); Swap(Arr[i], Arr[j]); end;' + NL +
  '  Swap(Arr[i + 1], Arr[Hi]);' + NL +
  '  Result := i + 1;' + NL +
  'end;' + NL +
  NL +
  'procedure QuickSort(var Arr: array of Integer; Lo, Hi: Integer);' + NL +
  'var p : Integer;' + NL +
  'begin' + NL +
  '  if Lo < Hi then' + NL +
  '  begin' + NL +
  '    p := Partition(Arr, Lo, Hi);' + NL +
  '    QuickSort(Arr, Lo, p - 1);' + NL +
  '    QuickSort(Arr, p + 1, Hi);' + NL +
  '  end;' + NL +
  'end;' + NL +
  NL +
  'var data : array[0..11] of Integer; i : Integer;' + NL +
  'begin' + NL +
  '  data[0]:=64; data[1]:=25; data[2]:=12; data[3]:=22; data[4]:=11;' + NL +
  '  data[5]:=90; data[6]:=45; data[7]:=33; data[8]:=7;  data[9]:=88;' + NL +
  '  data[10]:=55; data[11]:=3;' + NL +
  '  write(''Before: '');' + NL +
  '  for i := 0 to 11 do write(data[i], '' ''); writeln;' + NL +
  '  QuickSort(data, 0, 11);' + NL +
  '  write(''After:  '');' + NL +
  '  for i := 0 to 11 do write(data[i], '' ''); writeln;' + NL +
  'end.'
);

Add('Memoized Fibonacci', 'Algorithms',
  'Cache results to turn exponential time into linear',
  '// MEMOIZED FIBONACCI' + NL +
  '// Naive Fib(40) makes 300+ million recursive calls.' + NL +
  '// Memoized version makes exactly 40 calls.' + NL +
  '// Demonstrates: caching, Int64, performance engineering.' + NL +
  NL +
  'var cache : array[0..92] of Int64;' + NL +
  NL +
  'function Fib(n: Integer): Int64;' + NL +
  'begin' + NL +
  '  if n <= 1 then begin Result := n; Exit; end;' + NL +
  '  if cache[n] >= 0 then begin Result := cache[n]; Exit; end;' + NL +
  '  cache[n] := Fib(n - 1) + Fib(n - 2);' + NL +
  '  Result   := cache[n];' + NL +
  'end;' + NL +
  NL +
  'var i : Integer;' + NL +
  'begin' + NL +
  '  for i := 0 to 92 do cache[i] := -1;' + NL +
  '  for i := 0 to 15 do' + NL +
  '    writeln(''Fib('', i, '') = '', Fib(i));' + NL +
  '  writeln;' + NL +
  '  writeln(''Fib(50) = '', Fib(50));' + NL +
  '  writeln(''Fib(92) = '', Fib(92), ''  (largest in Int64)'');' + NL +
  'end.'
);

Add('Run-Length Encoding', 'Algorithms',
  'Compress and decompress text using RLE -- used in BMP, fax',
  '// RUN-LENGTH ENCODING (RLE)' + NL +
  '// Used in: BMP files, fax compression, simple data streams.' + NL +
  '// AAABBBCC -> 3A3B2C    then back to AAABBBCC.' + NL +
  NL +
  'function RLEncode(s: String): String;' + NL +
  'var i, count : Integer; cur : Char;' + NL +
  'begin' + NL +
  '  Result := ''''; if Length(s) = 0 then Exit;' + NL +
  '  cur := s[1]; count := 1;' + NL +
  '  for i := 2 to Length(s) do' + NL +
  '    if s[i] = cur then Inc(count)' + NL +
  '    else begin Result := Result + IntToStr(count) + cur; cur := s[i]; count := 1; end;' + NL +
  '  Result := Result + IntToStr(count) + cur;' + NL +
  'end;' + NL +
  NL +
  'function RLDecode(s: String): String;' + NL +
  'var i, count : Integer; numStr : String;' + NL +
  'begin' + NL +
  '  Result := ''''; i := 1;' + NL +
  '  while i <= Length(s) do' + NL +
  '  begin' + NL +
  '    numStr := '''';' + NL +
  '    while (i <= Length(s)) and (s[i] >= ''0'') and (s[i] <= ''9'') do' + NL +
  '    begin numStr := numStr + s[i]; Inc(i); end;' + NL +
  '    if i <= Length(s) then' + NL +
  '    begin' + NL +
  '      count  := StrToIntDef(numStr, 1);' + NL +
  '      Result := Result + StringOfChar(s[i], count);' + NL +
  '      Inc(i);' + NL +
  '    end;' + NL +
  '  end;' + NL +
  'end;' + NL +
  NL +
  'var original, encoded, decoded : String; ratio : Double;' + NL +
  'begin' + NL +
  '  original := ''AAAAABBBCCDDDDDDDDEEEEEEEEEEEEEEEFGGG'';' + NL +
  '  encoded  := RLEncode(original);' + NL +
  '  decoded  := RLDecode(encoded);' + NL +
  '  ratio    := Length(encoded) / Length(original) * 100;' + NL +
  '  writeln(''Original: '', original);' + NL +
  '  writeln(''Encoded:  '', encoded);' + NL +
  '  writeln(''Decoded:  '', decoded);' + NL +
  '  writeln(Format(''Ratio: %.0f%% of original'', [ratio]));' + NL +
  '  writeln(''Correct: '', decoded = original);' + NL +
  'end.'
);

// =============================================================================
//  OBJECT-ORIENTED / ORIENTADO A OBJETOS
// =============================================================================

Add('Bank Account', 'Object-Oriented',
  'Class with encapsulation, validation and transaction history',
  '// BANK ACCOUNT' + NL +
  '// OOP: private fields, exception handling, transaction log.' + NL +
  '// Pattern used in every financial application.' + NL +
  NL +
  'type' + NL +
  '  TTransaction = record Kind: String; Amount, Balance: Double; end;' + NL +
  NL +
  '  TBankAccount = class' + NL +
  '  private' + NL +
  '    FOwner   : String;' + NL +
  '    FBalance : Double;' + NL +
  '    FLog     : array of TTransaction;' + NL +
  '    procedure Log(const Kind: String; Amt, Bal: Double);' + NL +
  '  public' + NL +
  '    constructor Create(const Owner: String; Initial: Double);' + NL +
  '    procedure Deposit (Amount: Double);' + NL +
  '    procedure Withdraw(Amount: Double);' + NL +
  '    procedure PrintStatement;' + NL +
  '    property  Balance : Double read FBalance;' + NL +
  '  end;' + NL +
  NL +
  'procedure TBankAccount.Log(const Kind: String; Amt, Bal: Double);' + NL +
  'var T : TTransaction;' + NL +
  'begin' + NL +
  '  T.Kind := Kind; T.Amount := Amt; T.Balance := Bal;' + NL +
  '  SetLength(FLog, Length(FLog) + 1); FLog[High(FLog)] := T;' + NL +
  'end;' + NL +
  NL +
  'constructor TBankAccount.Create(const Owner: String; Initial: Double);' + NL +
  'begin FOwner := Owner; FBalance := 0; Deposit(Initial); end;' + NL +
  NL +
  'procedure TBankAccount.Deposit(Amount: Double);' + NL +
  'begin' + NL +
  '  if Amount <= 0 then raise Exception.Create(''Amount must be positive'');' + NL +
  '  FBalance := FBalance + Amount;' + NL +
  '  Log(''DEP'', Amount, FBalance);' + NL +
  'end;' + NL +
  NL +
  'procedure TBankAccount.Withdraw(Amount: Double);' + NL +
  'begin' + NL +
  '  if Amount <= 0 then raise Exception.Create(''Amount must be positive'');' + NL +
  '  if Amount > FBalance then raise Exception.Create(''Insufficient funds'');' + NL +
  '  FBalance := FBalance - Amount;' + NL +
  '  Log(''WDR'', Amount, FBalance);' + NL +
  'end;' + NL +
  NL +
  'procedure TBankAccount.PrintStatement;' + NL +
  'var i : Integer;' + NL +
  'begin' + NL +
  '  writeln(''=== Account: '', FOwner, '' ==='');' + NL +
  '  writeln(Format(''%-4s %12s %12s'', [''Type'', ''Amount'', ''Balance'']));' + NL +
  '  writeln(StringOfChar(''-'', 32));' + NL +
  '  for i := 0 to High(FLog) do' + NL +
  '    writeln(Format(''%-4s %12.2f %12.2f'',' + NL +
  '      [FLog[i].Kind, FLog[i].Amount, FLog[i].Balance]));' + NL +
  '  writeln(StringOfChar(''-'', 32));' + NL +
  '  writeln(Format(''Balance: %25.2f'', [FBalance]));' + NL +
  'end;' + NL +
  NL +
  'var acc : TBankAccount;' + NL +
  'begin' + NL +
  '  acc := TBankAccount.Create(''Alice'', 1000.00);' + NL +
  '  try' + NL +
  '    acc.Deposit(500.00);' + NL +
  '    acc.Withdraw(250.00);' + NL +
  '    acc.Deposit(75.50);' + NL +
  '    try acc.Withdraw(5000.00);' + NL +
  '    except on E: Exception do writeln(''Error: '', E.Message); end;' + NL +
  '    acc.PrintStatement;' + NL +
  '  finally acc.Free; end;' + NL +
  'end.'
);

Add('Polymorphic Shapes', 'Object-Oriented',
  'Virtual methods, inheritance, heterogeneous collection',
  '// POLYMORPHIC SHAPES' + NL +
  '// Iterate an array of different shapes through a base class.' + NL +
  '// Each shape.Area/Perimeter calls the correct override.' + NL +
  NL +
  'type' + NL +
  '  TShape = class' + NL +
  '    Name : String;' + NL +
  '    constructor Create(const AName: String); begin Name := AName; end;' + NL +
  '    function Area      : Double; virtual; begin Result := 0; end;' + NL +
  '    function Perimeter : Double; virtual; begin Result := 0; end;' + NL +
  '    procedure Describe;' + NL +
  '    begin writeln(Format(''%-12s Area:%8.2f  Peri:%8.2f'',' + NL +
  '      [Name, Area, Perimeter])); end;' + NL +
  '  end;' + NL +
  NL +
  '  TCircle = class(TShape)' + NL +
  '    R : Double;' + NL +
  '    constructor Create(Radius: Double);' + NL +
  '    begin inherited Create(''Circle''); R := Radius; end;' + NL +
  '    function Area      : Double; override;' + NL +
  '    begin Result := 3.14159265 * R * R; end;' + NL +
  '    function Perimeter : Double; override;' + NL +
  '    begin Result := 2 * 3.14159265 * R; end;' + NL +
  '  end;' + NL +
  NL +
  '  TRectangle = class(TShape)' + NL +
  '    W, H : Double;' + NL +
  '    constructor Create(Width, Height: Double);' + NL +
  '    begin inherited Create(''Rectangle''); W := Width; H := Height; end;' + NL +
  '    function Area      : Double; override; begin Result := W * H; end;' + NL +
  '    function Perimeter : Double; override; begin Result := 2*(W+H); end;' + NL +
  '  end;' + NL +
  NL +
  '  TTriangle = class(TShape)' + NL +
  '    A, B, C : Double;' + NL +
  '    constructor Create(SA, SB, SC: Double);' + NL +
  '    begin inherited Create(''Triangle''); A:=SA; B:=SB; C:=SC; end;' + NL +
  '    function Perimeter : Double; override; begin Result := A+B+C; end;' + NL +
  '    function Area : Double; override;' + NL +
  '    var s : Double;' + NL +
  '    begin s := Perimeter/2; Result := Sqrt(s*(s-A)*(s-B)*(s-C)); end;' + NL +
  '  end;' + NL +
  NL +
  'var shapes : array of TShape; i : Integer; total : Double;' + NL +
  'begin' + NL +
  '  SetLength(shapes, 4);' + NL +
  '  shapes[0] := TCircle.Create(5);' + NL +
  '  shapes[1] := TRectangle.Create(8, 6);' + NL +
  '  shapes[2] := TTriangle.Create(3, 4, 5);' + NL +
  '  shapes[3] := TCircle.Create(2.5);' + NL +
  '  try' + NL +
  '    writeln(''Shape        Area      Perimeter'');' + NL +
  '    writeln(StringOfChar(''-'', 40));' + NL +
  '    total := 0;' + NL +
  '    for i := 0 to High(shapes) do' + NL +
  '    begin shapes[i].Describe; total := total + shapes[i].Area; end;' + NL +
  '    writeln(StringOfChar(''-'', 40));' + NL +
  '    writeln(Format(''Total area: %8.2f'', [total]));' + NL +
  '  finally' + NL +
  '    for i := 0 to High(shapes) do shapes[i].Free;' + NL +
  '  end;' + NL +
  'end.'
);

Add('Observer Pattern', 'Object-Oriented',
  'Event bus with subscribe/publish -- used in every GUI framework',
  '// OBSERVER PATTERN -- Event Bus' + NL +
  '// Powers: GUI events, plugin systems, game engines, messaging.' + NL +
  '// Subscribe handlers to named events; publish fires all of them.' + NL +
  NL +
  'type' + NL +
  '  THandlerProc = procedure;' + NL +
  '  TEntry = record Name: String; Handler: THandlerProc; end;' + NL +
  '  TEventBus = class' + NL +
  '  private' + NL +
  '    FList : array of TEntry;' + NL +
  '  public' + NL +
  '    procedure Subscribe(const Name: String; Handler: THandlerProc);' + NL +
  '    procedure Publish  (const Name: String);' + NL +
  '  end;' + NL +
  NL +
  'procedure TEventBus.Subscribe(const Name: String; Handler: THandlerProc);' + NL +
  'begin' + NL +
  '  SetLength(FList, Length(FList) + 1);' + NL +
  '  FList[High(FList)].Name    := Name;' + NL +
  '  FList[High(FList)].Handler := Handler;' + NL +
  'end;' + NL +
  NL +
  'procedure TEventBus.Publish(const Name: String);' + NL +
  'var i : Integer;' + NL +
  'begin' + NL +
  '  for i := 0 to High(FList) do' + NL +
  '    if FList[i].Name = Name then FList[i].Handler;' + NL +
  'end;' + NL +
  NL +
  'procedure OnLogin_Logger;  begin writeln(''Logger: user logged in''); end;' + NL +
  'procedure OnLogin_Greeter; begin writeln(''Greeter: Welcome back!''); end;' + NL +
  'procedure OnLogout_Logger; begin writeln(''Logger: user logged out''); end;' + NL +
  NL +
  'var bus : TEventBus;' + NL +
  'begin' + NL +
  '  bus := TEventBus.Create;' + NL +
  '  try' + NL +
  '    bus.Subscribe(''login'',  OnLogin_Logger);' + NL +
  '    bus.Subscribe(''login'',  OnLogin_Greeter);' + NL +
  '    bus.Subscribe(''logout'', OnLogout_Logger);' + NL +
  '    writeln(''--- Login event ---'');' + NL +
  '    bus.Publish(''login'');' + NL +
  '    writeln(''--- Logout event ---'');' + NL +
  '    bus.Publish(''logout'');' + NL +
  '  finally bus.Free; end;' + NL +
  'end.'
);

// =============================================================================
//  SYSTEMS & TOOLS / SISTEMAS E FERRAMENTAS
// =============================================================================

Add('State Machine', 'Systems & Tools',
  'Traffic light FSM -- foundation of parsers, game AI, protocols',
  '// FINITE STATE MACHINE -- Traffic Light' + NL +
  '// FSMs power: parsers, game AI, protocol handlers, UI flow.' + NL +
  '// Demonstrates: enum types, case dispatch, OOP state pattern.' + NL +
  NL +
  'type' + NL +
  '  TLight = (lsRed, lsRedAmber, lsGreen, lsAmber);' + NL +
  NL +
  '  TTrafficLight = class' + NL +
  '  private' + NL +
  '    FState : TLight;' + NL +
  '    FTick  : Integer;' + NL +
  '    function StateName : String;' + NL +
  '    function Duration  : Integer;' + NL +
  '  public' + NL +
  '    constructor Create;' + NL +
  '    procedure Advance;' + NL +
  '    procedure Simulate(Ticks: Integer);' + NL +
  '  end;' + NL +
  NL +
  'function TTrafficLight.StateName: String;' + NL +
  'begin' + NL +
  '  case FState of' + NL +
  '    lsRed      : Result := ''RED      '';' + NL +
  '    lsRedAmber : Result := ''RED+AMBER'';' + NL +
  '    lsGreen    : Result := ''GREEN    '';' + NL +
  '    lsAmber    : Result := ''AMBER    '';' + NL +
  '  end;' + NL +
  'end;' + NL +
  NL +
  'function TTrafficLight.Duration: Integer;' + NL +
  'begin' + NL +
  '  case FState of' + NL +
  '    lsRed: Result:=4; lsRedAmber: Result:=1;' + NL +
  '    lsGreen: Result:=4; lsAmber: Result:=2;' + NL +
  '  end;' + NL +
  'end;' + NL +
  NL +
  'constructor TTrafficLight.Create;' + NL +
  'begin FState := lsRed; FTick := 0; end;' + NL +
  NL +
  'procedure TTrafficLight.Advance;' + NL +
  'begin' + NL +
  '  case FState of' + NL +
  '    lsRed:      FState := lsRedAmber;' + NL +
  '    lsRedAmber: FState := lsGreen;' + NL +
  '    lsGreen:    FState := lsAmber;' + NL +
  '    lsAmber:    FState := lsRed;' + NL +
  '  end;' + NL +
  '  FTick := 0;' + NL +
  'end;' + NL +
  NL +
  'procedure TTrafficLight.Simulate(Ticks: Integer);' + NL +
  'var t : Integer;' + NL +
  'begin' + NL +
  '  for t := 1 to Ticks do' + NL +
  '  begin' + NL +
  '    writeln(Format(''Tick %2d: [%s]'', [t, StateName]));' + NL +
  '    Inc(FTick);' + NL +
  '    if FTick >= Duration then Advance;' + NL +
  '  end;' + NL +
  'end;' + NL +
  NL +
  'var light : TTrafficLight;' + NL +
  'begin' + NL +
  '  light := TTrafficLight.Create;' + NL +
  '  try light.Simulate(20); finally light.Free; end;' + NL +
  'end.'
);

Add('Query Builder', 'Systems & Tools',
  'Fluent interface pattern -- chained method calls build SQL',
  '// QUERY BUILDER -- Fluent Interface Pattern' + NL +
  '// Methods return Self so calls chain together naturally.' + NL +
  '// Used in: ORMs, test frameworks, config builders, DSLs.' + NL +
  NL +
  'type' + NL +
  '  TQuery = class' + NL +
  '  private' + NL +
  '    FSelect, FFrom, FWhere, FOrder : String;' + NL +
  '  public' + NL +
  '    function SelectClause(const S: String) : TQuery;' + NL +
  '    begin FSelect := S; Result := Self; end;' + NL +
  '    function FromClause(const S: String) : TQuery;' + NL +
  '    begin FFrom := S; Result := Self; end;' + NL +
  '    function WhereClause(const S: String) : TQuery;' + NL +
  '    begin FWhere := S; Result := Self; end;' + NL +
  '    function OrderByClause(const S: String) : TQuery;' + NL +
  '    begin FOrder := S; Result := Self; end;' + NL +
  '    function Build : String;' + NL +
  '    begin' + NL +
  '      Result := ''SELECT '' + FSelect + '' FROM '' + FFrom;' + NL +
  '      if FWhere <> '''' then Result := Result + '' WHERE '' + FWhere;' + NL +
  '      if FOrder <> '''' then Result := Result + '' ORDER BY '' + FOrder;' + NL +
  '    end;' + NL +
  '  end;' + NL +
  NL +
  'var q : TQuery;' + NL +
  'begin' + NL +
  '  q := TQuery.Create;' + NL +
  '  try' + NL +
  '    // Fluent chain / Cadeia fluente' + NL +
  '    writeln(q.SelectClause(''name, salary'')' + NL +
  '             .FromClause(''employees'')' + NL +
  '             .WhereClause(''dept = ''''Eng'''''')' + NL +
  '             .OrderByClause(''salary DESC'')' + NL +
  '             .Build);' + NL +
  NL +
  '    // Different query, same builder / Outra query, mesmo builder' + NL +
  '    writeln(TQuery.Create' + NL +
  '             .SelectClause(''product, revenue'')' + NL +
  '             .FromClause(''sales'')' + NL +
  '             .WhereClause(''year = 2026'')' + NL +
  '             .Build);' + NL +
  '  finally q.Free; end;' + NL +
  'end.'
);

// =============================================================================
//  GAMES & FUN / JOGOS
// =============================================================================

Add('Sudoku', 'Games & Fun',
  'Full graphical Sudoku -- load sudoku.mdp from Recent Files',
  '// SUDOKU' + NL +
  '// The full Sudoku game is in sudoku.mdp.' + NL +
  '// Open it from Recent Files or File > Open File.' + NL +
  '// Features: iterative backtracking generator, Easy/Medium/Hard/Daily,' + NL +
  '//           hint system, SQLite save/resume (pythia.db).' + NL +
  NL +
  'begin' + NL +
  '  writeln(''Sudoku is a separate file: sudoku.mdp'');' + NL +
  '  writeln(''Open it from File > Open File...'');' + NL +
  '  writeln(''Or load from the Recent Files tree.'');' + NL +
  'end.'
);

Add('Number Guessing Game', 'Games & Fun',
  'Simple game loop with random numbers and input',
  '// NUMBER GUESSING GAME' + NL +
  '// Classic first game. Demonstrates: random, loops, comparison.' + NL +
  NL +
  'var' + NL +
  '  secret, guess, attempts : Integer;' + NL +
  '  input                   : String;' + NL +
  '  playing                 : Boolean;' + NL +
  'begin' + NL +
  '  Randomize;' + NL +
  '  secret   := Random(100) + 1;  // 1..100' + NL +
  '  attempts := 0;' + NL +
  '  playing  := True;' + NL +
  NL +
  '  writeln(''I picked a number from 1 to 100. Guess it!'');' + NL +
  '  writeln;' + NL +
  NL +
  '  while playing do' + NL +
  '  begin' + NL +
  '    input := InputBox(''Guess'', ''Enter your guess (1-100):'', '''');' + NL +
  '    if input = '''' then begin playing := False; Continue; end;' + NL +
  NL +
  '    guess := StrToIntDef(input, 0);' + NL +
  '    Inc(attempts);' + NL +
  NL +
  '    if guess < secret then writeln(''Too low! Try higher.'')' + NL +
  '    else if guess > secret then writeln(''Too high! Try lower.'')' + NL +
  '    else' + NL +
  '    begin' + NL +
  '      writeln(''CORRECT! The number was '', secret, ''.'');' + NL +
  '      writeln(''You got it in '', attempts, '' attempts!'');' + NL +
  '      playing := False;' + NL +
  '    end;' + NL +
  '  end;' + NL +
  'end.'
);

end;  // Build

end.
