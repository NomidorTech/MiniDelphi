unit UPascalCurriculum;

// =============================================================================
// Pythia -- Pascal learning environment / ambiente de aprendizado Pascal
// Copyright (C) 2026 Nomidor Software, LLC.
// GPL v3 -- see/veja https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
//
//  UPascalCurriculum.pas  --  Real-world Pascal/Delphi curriculum for Pythia
//                             Currículo Pascal/Delphi do mundo real para o Pythia
//
//  English:
//    10 lessons built around what makes Pascal and Delphi genuinely powerful:
//    strong typing, records, pointers, file I/O, object-oriented programming,
//    exception handling, generics, and systems programming patterns.
//    Exercises use Pythia's Pascal dialect (no VCL -- console/logic focus).
//
//  Português:
//    10 lições construídas em torno do que torna Pascal e Delphi genuinamente
//    poderosos: tipagem forte, records, ponteiros, E/S de arquivos, POO,
//    tratamento de exceções, genéricos e padrões de programação de sistemas.
//    Os exercícios usam o dialeto Pascal do Pythia (sem VCL -- foco em lógica).
// =============================================================================

interface

uses ULearnTabBase;

type
  TPascalCurriculum = class(TLearnCurriculumBase)
  protected
    procedure Build; override;
  end;

// =============================================================================
implementation
// =============================================================================

procedure TPascalCurriculum.Build;

  function Ch(ID: Integer;
              const Title, Instr, Hint, Starter, Solution: string;
              Kind: TCheckKind; const Exp: string;
              ExpNum, Lo, Hi: Double; Lines, Pts: Integer): TLearnChallenge;
  begin
    Result.ID          := ID;
    Result.Title       := Title;
    Result.Instruction := Instr;
    Result.Hint        := Hint;
    Result.Starter     := Starter;
    Result.Solution    := Solution;
    Result.CheckKind   := Kind;
    Result.Expected    := Exp;
    Result.ExpectedNum := ExpNum;
    Result.RangeLo     := Lo;
    Result.RangeHi     := Hi;
    Result.LineCount   := Lines;
    Result.Points      := Pts;
  end;

begin
  SetLength(FLessons, 10);

  // ── LESSON 1 -- Strong Typing & Type Safety ────────────────────────────────
  FLessons[0].Number := 1;
  FLessons[0].Title  := 'Strong Typing & Type Safety';
  FLessons[0].Intro  :=
    'Pascal''s greatest strength is its type system. The compiler catches' + #13#10 +
    'mistakes that take hours to find in dynamic languages.' + #13#10 +
    '' + #13#10 +
    'Every variable must be declared with a type:' + #13#10 +
    '    var' + #13#10 +
    '      count   : Integer;    // 32-bit signed integer' + #13#10 +
    '      price   : Double;     // 64-bit floating point' + #13#10 +
    '      name    : String;     // dynamic Unicode string' + #13#10 +
    '      active  : Boolean;    // True or False' + #13#10 +
    '      initial : Char;       // single character' + #13#10 +
    '' + #13#10 +
    'Integer types (choose the right one):' + #13#10 +
    '    Byte        0..255          (1 byte)' + #13#10 +
    '    Word        0..65535        (2 bytes)' + #13#10 +
    '    Integer     -2^31..2^31-1   (4 bytes)' + #13#10 +
    '    Int64       -2^63..2^63-1   (8 bytes)' + #13#10 +
    '    Cardinal    0..2^32-1       (4 bytes, unsigned)' + #13#10 +
    '' + #13#10 +
    'Type conversion is always explicit -- never implicit:' + #13#10 +
    '    var i : Integer; d : Double;' + #13#10 +
    '    i := 7;' + #13#10 +
    '    d := i;            // OK: Integer widens to Double' + #13#10 +
    '    i := Round(d);     // must explicitly convert back' + #13#10 +
    '' + #13#10 +
    'Useful conversion functions:' + #13#10 +
    '    IntToStr(42)        ->  "42"' + #13#10 +
    '    StrToInt("42")      ->  42' + #13#10 +
    '    FloatToStr(3.14)    ->  "3.14"' + #13#10 +
    '    StrToFloat("3.14")  ->  3.14' + #13#10 +
    '    Trunc(3.9)          ->  3  (truncate, not round)' + #13#10 +
    '    Round(3.5)          ->  4';

  FLessons[0].Challenges := [
    Ch(2001, 'Invoice Calculator',
       'A product costs 149.99 per unit. Quantity is 7. VAT rate is 20%.' + #13#10 +
       'Calculate and print:' + #13#10 +
       '    Subtotal: 1049.93' + #13#10 +
       '    VAT:       210.00' + #13#10 +
       '    Total:    1259.93' + #13#10 +
       '' + #13#10 +
       'Use Round() to get exact cent values before display.',
       'subtotal := price * qty;   vat := Round(subtotal * vatRate * 100) / 100;   total := subtotal + vat',
       'var' + #13#10 +
       '  price, subtotal, vat, total : Double;' + #13#10 +
       '  qty                          : Integer;' + #13#10 +
       '  vatRate                      : Double;' + #13#10 +
       'begin' + #13#10 +
       '  price   := 149.99;' + #13#10 +
       '  qty     := 7;' + #13#10 +
       '  vatRate := 0.20;' + #13#10 +
       '  // Calculate and print subtotal, VAT, total' + #13#10 +
       'end.',
       'var' + #13#10 +
       '  price, subtotal, vat, total : Double;' + #13#10 +
       '  qty                          : Integer;' + #13#10 +
       '  vatRate                      : Double;' + #13#10 +
       'begin' + #13#10 +
       '  price    := 149.99;' + #13#10 +
       '  qty      := 7;' + #13#10 +
       '  vatRate  := 0.20;' + #13#10 +
       '  subtotal := price * qty;' + #13#10 +
       '  vat      := Round(subtotal * vatRate * 100) / 100;' + #13#10 +
       '  total    := subtotal + vat;' + #13#10 +
       '  writeln(''Subtotal: '', subtotal:8:2);' + #13#10 +
       '  writeln(''VAT:      '', vat:8:2);' + #13#10 +
       '  writeln(''Total:    '', total:8:2);' + #13#10 +
       'end.',
       ckContainsAll, '1049.93|210.00|1259.93', 0,0,0, 0, 15),

    Ch(2002, 'Integer Division & Mod',
       'Convert 9999 seconds into hours, minutes, and seconds.' + #13#10 +
       'Use div and mod operators (integer division).' + #13#10 +
       'Expected: 2 hours, 46 minutes, 39 seconds',
       'hours := secs div 3600;   remaining := secs mod 3600;   mins := remaining div 60;',
       'var' + #13#10 +
       '  secs, hours, mins, remaining : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  secs := 9999;' + #13#10 +
       '  // Convert to hours, minutes, seconds using div and mod' + #13#10 +
       'end.',
       'var' + #13#10 +
       '  secs, hours, mins, remaining, s : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  secs      := 9999;' + #13#10 +
       '  hours     := secs div 3600;' + #13#10 +
       '  remaining := secs mod 3600;' + #13#10 +
       '  mins      := remaining div 60;' + #13#10 +
       '  s         := remaining mod 60;' + #13#10 +
       '  writeln(hours, '' hours, '', mins, '' minutes, '', s, '' seconds'');' + #13#10 +
       'end.',
       ckExactOutput, '2 hours, 46 minutes, 39 seconds', 0,0,0, 0, 15),

    Ch(2003, 'Type Guards',
       'Write a program that classifies an integer score (85) as:' + #13#10 +
       '  90-100: Distinction' + #13#10 +
       '  75-89:  Merit' + #13#10 +
       '  60-74:  Pass' + #13#10 +
       '  0-59:   Fail' + #13#10 +
       'Use a case statement. Expected: Grade: Merit',
       'case score of   90..100: ...   75..89: ...   end;',
       'var' + #13#10 +
       '  score : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  score := 85;' + #13#10 +
       '  // Use case..of to classify' + #13#10 +
       'end.',
       'var' + #13#10 +
       '  score : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  score := 85;' + #13#10 +
       '  case score of' + #13#10 +
       '    90..100 : writeln(''Grade: Distinction'');' + #13#10 +
       '    75..89  : writeln(''Grade: Merit'');' + #13#10 +
       '    60..74  : writeln(''Grade: Pass'');' + #13#10 +
       '  else' + #13#10 +
       '    writeln(''Grade: Fail'');' + #13#10 +
       '  end;' + #13#10 +
       'end.',
       ckExactOutput, 'Grade: Merit', 0,0,0, 0, 10)
  ];

  // ── LESSON 2 -- Records & Structured Data ─────────────────────────────────
  FLessons[1].Number := 2;
  FLessons[1].Title  := 'Records & Structured Data';
  FLessons[1].Intro  :=
    'Records are Pascal''s value-type structs -- perfect for data modelling.' + #13#10 +
    'They have zero overhead and are stack-allocated by default.' + #13#10 +
    '' + #13#10 +
    '    type' + #13#10 +
    '      TPoint = record' + #13#10 +
    '        X, Y : Double;' + #13#10 +
    '      end;' + #13#10 +
    '' + #13#10 +
    '      TEmployee = record' + #13#10 +
    '        ID       : Integer;' + #13#10 +
    '        Name     : String;' + #13#10 +
    '        Dept     : String;' + #13#10 +
    '        Salary   : Double;' + #13#10 +
    '      end;' + #13#10 +
    '' + #13#10 +
    'Using records:' + #13#10 +
    '    var emp : TEmployee;' + #13#10 +
    '    emp.ID     := 1001;' + #13#10 +
    '    emp.Name   := ''Alice'';' + #13#10 +
    '    emp.Salary := 95000;' + #13#10 +
    '' + #13#10 +
    'Arrays of records (the database pattern):' + #13#10 +
    '    var team : array[0..4] of TEmployee;' + #13#10 +
    '' + #13#10 +
    'Dynamic arrays of records:' + #13#10 +
    '    var staff : array of TEmployee;' + #13#10 +
    '    SetLength(staff, 10);' + #13#10 +
    '' + #13#10 +
    'With statement (field shorthand):' + #13#10 +
    '    with emp do' + #13#10 +
    '    begin' + #13#10 +
    '      Name   := ''Bob'';' + #13#10 +
    '      Salary := 72000;' + #13#10 +
    '    end;';

  FLessons[1].Challenges := [
    Ch(2010, 'Point Distance',
       'Define a TPoint record with X and Y fields (Double).' + #13#10 +
       'Write a function Distance(A, B: TPoint): Double.' + #13#10 +
       'Calculate the distance between (0,0) and (3,4).' + #13#10 +
       'Expected: Distance: 5.00',
       'uses System.Math or Sqrt. Distance := Sqrt((B.X-A.X)^2 + (B.Y-A.Y)^2)',
       'type' + #13#10 +
       '  TPoint = record' + #13#10 +
       '    X, Y : Double;' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       'function Distance(A, B: TPoint): Double;' + #13#10 +
       'begin' + #13#10 +
       '  // Calculate Euclidean distance' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'var P1, P2 : TPoint;' + #13#10 +
       'begin' + #13#10 +
       '  P1.X := 0;  P1.Y := 0;' + #13#10 +
       '  P2.X := 3;  P2.Y := 4;' + #13#10 +
       '  writeln(''Distance: '', Distance(P1, P2):4:2);' + #13#10 +
       'end.',
       'type' + #13#10 +
       '  TPoint = record' + #13#10 +
       '    X, Y : Double;' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       'function Distance(A, B: TPoint): Double;' + #13#10 +
       'begin' + #13#10 +
       '  Result := Sqrt((B.X - A.X) * (B.X - A.X) + (B.Y - A.Y) * (B.Y - A.Y));' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'var P1, P2 : TPoint;' + #13#10 +
       'begin' + #13#10 +
       '  P1.X := 0;  P1.Y := 0;' + #13#10 +
       '  P2.X := 3;  P2.Y := 4;' + #13#10 +
       '  writeln(''Distance: '', Distance(P1, P2):4:2);' + #13#10 +
       'end.',
       ckExactOutput, 'Distance: 5.00', 0,0,0, 0, 15),

    Ch(2011, 'Employee Report',
       'Define a TEmployee record (ID, Name, Dept, Salary).' + #13#10 +
       'Create an array of 4 employees, find the highest paid,' + #13#10 +
       'and print their details.' + #13#10 +
       'Expected:' + #13#10 +
       '    Top earner: Carol  Dept: Engineering  Salary: 102000.00',
       'Loop the array, track max salary index, print that employee''s fields.',
       'type' + #13#10 +
       '  TEmployee = record' + #13#10 +
       '    ID     : Integer;' + #13#10 +
       '    Name   : String;' + #13#10 +
       '    Dept   : String;' + #13#10 +
       '    Salary : Double;' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       'var' + #13#10 +
       '  staff : array[0..3] of TEmployee;' + #13#10 +
       'begin' + #13#10 +
       '  staff[0].ID := 1; staff[0].Name := ''Alice''; staff[0].Dept := ''Sales'';       staff[0].Salary := 75000;' + #13#10 +
       '  staff[1].ID := 2; staff[1].Name := ''Bob'';   staff[1].Dept := ''Support'';     staff[1].Salary := 62000;' + #13#10 +
       '  staff[2].ID := 3; staff[2].Name := ''Carol''; staff[2].Dept := ''Engineering''; staff[2].Salary := 102000;' + #13#10 +
       '  staff[3].ID := 4; staff[3].Name := ''Dave'';  staff[3].Dept := ''Sales'';       staff[3].Salary := 88000;' + #13#10 +
       '  // Find and print top earner' + #13#10 +
       'end.',
       'type' + #13#10 +
       '  TEmployee = record' + #13#10 +
       '    ID : Integer; Name, Dept : String; Salary : Double;' + #13#10 +
       '  end;' + #13#10 +
       'var' + #13#10 +
       '  staff   : array[0..3] of TEmployee;' + #13#10 +
       '  top, i  : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  staff[0].ID := 1; staff[0].Name := ''Alice''; staff[0].Dept := ''Sales'';       staff[0].Salary := 75000;' + #13#10 +
       '  staff[1].ID := 2; staff[1].Name := ''Bob'';   staff[1].Dept := ''Support'';     staff[1].Salary := 62000;' + #13#10 +
       '  staff[2].ID := 3; staff[2].Name := ''Carol''; staff[2].Dept := ''Engineering''; staff[2].Salary := 102000;' + #13#10 +
       '  staff[3].ID := 4; staff[3].Name := ''Dave'';  staff[3].Dept := ''Sales'';       staff[3].Salary := 88000;' + #13#10 +
       '  top := 0;' + #13#10 +
       '  for i := 1 to 3 do' + #13#10 +
       '    if staff[i].Salary > staff[top].Salary then top := i;' + #13#10 +
       '  writeln(''Top earner: '', staff[top].Name, ''  Dept: '', staff[top].Dept,' + #13#10 +
       '          ''  Salary: '', staff[top].Salary:10:2);' + #13#10 +
       'end.',
       ckContainsAll, 'Carol|Engineering|102000', 0,0,0, 0, 20),

    Ch(2012, 'Statistics on Array',
       'Given an array of 8 integer scores, calculate and print:' + #13#10 +
       '  Min, Max, Sum, Average (2 decimal places)' + #13#10 +
       '' + #13#10 +
       'scores = [72, 88, 91, 65, 79, 84, 93, 77]' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    Min: 65   Max: 93   Sum: 649   Avg: 81.13',
       'Loop once, track min and max, accumulate sum, divide at end.',
       'var' + #13#10 +
       '  scores : array[0..7] of Integer;' + #13#10 +
       '  i, mn, mx, total : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  scores[0] := 72; scores[1] := 88; scores[2] := 91; scores[3] := 65;' + #13#10 +
       '  scores[4] := 79; scores[5] := 84; scores[6] := 93; scores[7] := 77;' + #13#10 +
       '  // Calculate min, max, sum, average' + #13#10 +
       'end.',
       'var' + #13#10 +
       '  scores : array[0..7] of Integer;' + #13#10 +
       '  i, mn, mx, total : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  scores[0] := 72; scores[1] := 88; scores[2] := 91; scores[3] := 65;' + #13#10 +
       '  scores[4] := 79; scores[5] := 84; scores[6] := 93; scores[7] := 77;' + #13#10 +
       '  mn := scores[0]; mx := scores[0]; total := 0;' + #13#10 +
       '  for i := 0 to 7 do' + #13#10 +
       '  begin' + #13#10 +
       '    if scores[i] < mn then mn := scores[i];' + #13#10 +
       '    if scores[i] > mx then mx := scores[i];' + #13#10 +
       '    total := total + scores[i];' + #13#10 +
       '  end;' + #13#10 +
       '  writeln(''Min: '', mn, ''   Max: '', mx, ''   Sum: '', total,' + #13#10 +
       '          ''   Avg: '', total / 8:5:2);' + #13#10 +
       'end.',
       ckExactOutput, 'Min: 65   Max: 93   Sum: 649   Avg: 81.13',
       0,0,0, 0, 20)
  ];

  // ── LESSON 3 -- Procedures, Functions & Scope ─────────────────────────────
  FLessons[2].Number := 3;
  FLessons[2].Title  := 'Procedures, Functions & Scope';
  FLessons[2].Intro  :=
    'Pascal strictly separates procedures (no return) from functions (returns a value).' + #13#10 +
    'This clarity is one reason Delphi code is easier to read than C.' + #13#10 +
    '' + #13#10 +
    'Function with Result (preferred style):' + #13#10 +
    '    function Max(A, B: Integer): Integer;' + #13#10 +
    '    begin' + #13#10 +
    '      if A > B then Result := A' + #13#10 +
    '      else          Result := B;' + #13#10 +
    '    end;' + #13#10 +
    '' + #13#10 +
    'var parameters (pass by reference -- caller sees changes):' + #13#10 +
    '    procedure Swap(var A, B: Integer);' + #13#10 +
    '    var Tmp : Integer;' + #13#10 +
    '    begin' + #13#10 +
    '      Tmp := A;  A := B;  B := Tmp;' + #13#10 +
    '    end;' + #13#10 +
    '' + #13#10 +
    'const parameters (pass by reference, read-only -- efficient for large records):' + #13#10 +
    '    function FullName(const E: TEmployee): String;' + #13#10 +
    '    begin' + #13#10 +
    '      Result := E.Name + '' ('' + E.Dept + '')'';' + #13#10 +
    '    end;' + #13#10 +
    '' + #13#10 +
    'Overloading (same name, different parameters):' + #13#10 +
    '    function Add(A, B: Integer): Integer; overload;' + #13#10 +
    '    function Add(A, B: Double): Double;   overload;' + #13#10 +
    '' + #13#10 +
    'Nested functions (local helpers):' + #13#10 +
    '    function ProcessData(Data: array of Integer): Double;' + #13#10 +
    '      function IsValid(N: Integer): Boolean;' + #13#10 +
    '      begin Result := (N > 0) and (N < 1000); end;' + #13#10 +
    '    begin' + #13#10 +
    '      // IsValid only visible inside ProcessData' + #13#10 +
    '    end;';

  FLessons[2].Challenges := [
    Ch(2020, 'Recursive Power',
       'Write a recursive function Power(Base: Double; Exp: Integer): Double.' + #13#10 +
       'Handle negative exponents too (Power(2,-3) = 0.125).' + #13#10 +
       'Test: Print Power(2,10) and Power(2,-3).' + #13#10 +
       'Expected:' + #13#10 +
       '    1024.00' + #13#10 +
       '    0.13',
       'if Exp = 0: Result := 1   elif Exp < 0: Result := 1/Power(Base,-Exp)   else: Result := Base * Power(Base, Exp-1)',
       'function Power(Base: Double; Exp: Integer): Double;' + #13#10 +
       'begin' + #13#10 +
       '  // Handle Exp=0, negative Exp, and positive Exp' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'begin' + #13#10 +
       '  writeln(Power(2, 10):8:2);' + #13#10 +
       '  writeln(Power(2, -3):8:2);' + #13#10 +
       'end.',
       'function Power(Base: Double; Exp: Integer): Double;' + #13#10 +
       'begin' + #13#10 +
       '  if Exp = 0 then Result := 1' + #13#10 +
       '  else if Exp < 0 then Result := 1 / Power(Base, -Exp)' + #13#10 +
       '  else Result := Base * Power(Base, Exp - 1);' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'begin' + #13#10 +
       '  writeln(Power(2, 10):8:2);' + #13#10 +
       '  writeln(Power(2, -3):8:2);' + #13#10 +
       'end.',
       ckContainsAll, '1024.00|0.13', 0,0,0, 0, 20),

    Ch(2021, 'var Parameters',
       'Write a procedure BubbleSort(var Arr: array of Integer; N: Integer)' + #13#10 +
       'that sorts an array in place (ascending).' + #13#10 +
       'Sort [64, 34, 25, 12, 22, 11, 90] and print each element.' + #13#10 +
       'Expected: 11 12 22 25 34 64 90',
       'Outer loop 0..N-2, inner loop 0..N-2-i, swap adjacent if out of order.',
       'procedure BubbleSort(var Arr: array of Integer; N: Integer);' + #13#10 +
       'var i, j, tmp : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  // Implement bubble sort' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'var data : array[0..6] of Integer;' + #13#10 +
       '    i    : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  data[0] := 64; data[1] := 34; data[2] := 25; data[3] := 12;' + #13#10 +
       '  data[4] := 22; data[5] := 11; data[6] := 90;' + #13#10 +
       '  BubbleSort(data, 7);' + #13#10 +
       '  for i := 0 to 6 do write(data[i], '' '');' + #13#10 +
       '  writeln;' + #13#10 +
       'end.',
       'procedure BubbleSort(var Arr: array of Integer; N: Integer);' + #13#10 +
       'var i, j, tmp : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  for i := 0 to N - 2 do' + #13#10 +
       '    for j := 0 to N - 2 - i do' + #13#10 +
       '      if Arr[j] > Arr[j+1] then' + #13#10 +
       '      begin' + #13#10 +
       '        tmp := Arr[j]; Arr[j] := Arr[j+1]; Arr[j+1] := tmp;' + #13#10 +
       '      end;' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'var data : array[0..6] of Integer;' + #13#10 +
       '    i    : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  data[0] := 64; data[1] := 34; data[2] := 25; data[3] := 12;' + #13#10 +
       '  data[4] := 22; data[5] := 11; data[6] := 90;' + #13#10 +
       '  BubbleSort(data, 7);' + #13#10 +
       '  for i := 0 to 6 do write(data[i], '' '');' + #13#10 +
       '  writeln;' + #13#10 +
       'end.',
       ckExactOutput, '11 12 22 25 34 64 90 ', 0,0,0, 0, 25),

    Ch(2022, 'Function Pipeline',
       'Write three functions and chain them:' + #13#10 +
       '  Celsius(F): converts Fahrenheit to Celsius' + #13#10 +
       '  Classify(C): returns "Cold" (<10), "Mild" (10-25), "Hot" (>25)' + #13#10 +
       '  Report(F): prints "98.6°F = 37.0°C (Hot)"' + #13#10 +
       '' + #13#10 +
       'Test with 98.6, 32.0, 59.0.' + #13#10 +
       'Expected:' + #13#10 +
       '    98.6°F = 37.0°C (Hot)' + #13#10 +
       '    32.0°F = 0.0°C (Cold)' + #13#10 +
       '    59.0°F = 15.0°C (Mild)',
       'C := (F - 32) * 5 / 9',
       'function Celsius(F: Double): Double;' + #13#10 +
       'begin' + #13#10 +
       '  // Convert F to C' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'function Classify(C: Double): String;' + #13#10 +
       'begin' + #13#10 +
       '  // Return Cold / Mild / Hot' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'procedure Report(F: Double);' + #13#10 +
       'begin' + #13#10 +
       '  // Print the formatted line' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'begin' + #13#10 +
       '  Report(98.6);' + #13#10 +
       '  Report(32.0);' + #13#10 +
       '  Report(59.0);' + #13#10 +
       'end.',
       'function Celsius(F: Double): Double;' + #13#10 +
       'begin Result := (F - 32) * 5 / 9; end;' + #13#10 +
       '' + #13#10 +
       'function Classify(C: Double): String;' + #13#10 +
       'begin' + #13#10 +
       '  if C < 10 then Result := ''Cold''' + #13#10 +
       '  else if C <= 25 then Result := ''Mild''' + #13#10 +
       '  else Result := ''Hot'';' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'procedure Report(F: Double);' + #13#10 +
       'var C : Double;' + #13#10 +
       'begin' + #13#10 +
       '  C := Celsius(F);' + #13#10 +
       '  writeln(F:4:1, ''°F = '', C:4:1, ''°C ('', Classify(C), '')'');' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'begin' + #13#10 +
       '  Report(98.6);' + #13#10 +
       '  Report(32.0);' + #13#10 +
       '  Report(59.0);' + #13#10 +
       'end.',
       ckContainsAll, 'Hot|Cold|Mild|37.0', 0,0,0, 0, 20)
  ];

  // ── LESSON 4 -- String Handling ────────────────────────────────────────────
  FLessons[3].Number := 4;
  FLessons[3].Title  := 'String Handling';
  FLessons[3].Intro  :=
    'Delphi strings are Unicode by default and have a rich built-in library.' + #13#10 +
    '' + #13#10 +
    'Key string functions:' + #13#10 +
    '    Length(s)                   number of characters' + #13#10 +
    '    Copy(s, start, count)       substring (1-based index!)' + #13#10 +
    '    Pos(sub, s)                 position of sub in s (0 = not found)' + #13#10 +
    '    UpperCase(s)                ALL CAPS' + #13#10 +
    '    LowerCase(s)                all lower' + #13#10 +
    '    Trim(s)                     remove leading/trailing spaces' + #13#10 +
    '    StringReplace(s,old,new,[])' + #13#10 +
    '    IntToStr(n)   StrToInt(s)' + #13#10 +
    '    FloatToStr(d) StrToFloat(s)' + #13#10 +
    '' + #13#10 +
    'String concatenation with +:' + #13#10 +
    '    result := ''Hello, '' + name + ''!'';' + #13#10 +
    '' + #13#10 +
    'Format() for templated output:' + #13#10 +
    '    writeln(Format(''%-15s %8.2f'', [name, salary]));' + #13#10 +
    '' + #13#10 +
    'Char access (1-based!):' + #13#10 +
    '    s[1]  // first character' + #13#10 +
    '    s[Length(s)]  // last character' + #13#10 +
    '' + #13#10 +
    'Split a string manually (no built-in split in older Delphi):' + #13#10 +
    '    p := Pos('','', s);' + #13#10 +
    '    left  := Copy(s, 1, p - 1);' + #13#10 +
    '    right := Copy(s, p + 1, Length(s));';

  FLessons[3].Challenges := [
    Ch(2030, 'Title Case',
       'Write a function TitleCase(s: String): String that converts a string' + #13#10 +
       'to Title Case (first letter of each word uppercase, rest lowercase).' + #13#10 +
       '' + #13#10 +
       'Test: TitleCase(''the quick brown fox'')' + #13#10 +
       'Expected: The Quick Brown Fox',
       'Walk each character. After a space (or at start), uppercase the next letter.',
       'function TitleCase(s: String): String;' + #13#10 +
       'var i : Integer; newWord : Boolean;' + #13#10 +
       'begin' + #13#10 +
       '  // Convert to title case' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'begin' + #13#10 +
       '  writeln(TitleCase(''the quick brown fox''));' + #13#10 +
       'end.',
       'function TitleCase(s: String): String;' + #13#10 +
       'var i : Integer; newWord : Boolean;' + #13#10 +
       'begin' + #13#10 +
       '  s := LowerCase(s);' + #13#10 +
       '  newWord := True;' + #13#10 +
       '  for i := 1 to Length(s) do' + #13#10 +
       '  begin' + #13#10 +
       '    if s[i] = '' '' then newWord := True' + #13#10 +
       '    else if newWord then' + #13#10 +
       '    begin' + #13#10 +
       '      s[i] := UpCase(s[i]);' + #13#10 +
       '      newWord := False;' + #13#10 +
       '    end;' + #13#10 +
       '  end;' + #13#10 +
       '  Result := s;' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'begin' + #13#10 +
       '  writeln(TitleCase(''the quick brown fox''));' + #13#10 +
       'end.',
       ckExactOutput, 'The Quick Brown Fox', 0,0,0, 0, 20),

    Ch(2031, 'CSV Line Parser',
       'Write a function that parses a CSV line into fields.' + #13#10 +
       'Parse this line and print each field on its own line:' + #13#10 +
       '' + #13#10 +
       'line = "Alice,Engineering,102000,London"' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    Alice' + #13#10 +
       '    Engineering' + #13#10 +
       '    102000' + #13#10 +
       '    London',
       'Use Pos('','', remaining) in a loop, copy each field, advance past the comma.',
       'var' + #13#10 +
       '  line, field, rest : String;' + #13#10 +
       '  p                 : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  line := ''Alice,Engineering,102000,London'';' + #13#10 +
       '  rest := line;' + #13#10 +
       '  // Parse and print each comma-separated field' + #13#10 +
       'end.',
       'var' + #13#10 +
       '  line, field, rest : String;' + #13#10 +
       '  p                 : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  line := ''Alice,Engineering,102000,London'';' + #13#10 +
       '  rest := line;' + #13#10 +
       '  p := Pos('','', rest);' + #13#10 +
       '  while p > 0 do' + #13#10 +
       '  begin' + #13#10 +
       '    field := Copy(rest, 1, p - 1);' + #13#10 +
       '    writeln(field);' + #13#10 +
       '    rest := Copy(rest, p + 1, Length(rest));' + #13#10 +
       '    p := Pos('','', rest);' + #13#10 +
       '  end;' + #13#10 +
       '  writeln(rest);' + #13#10 +
       'end.',
       ckExactOutput,
       'Alice' + #13#10 + 'Engineering' + #13#10 + '102000' + #13#10 + 'London',
       0,0,0, 0, 20),

    Ch(2032, 'Palindrome Checker',
       'Write a function IsPalindrome(s: String): Boolean.' + #13#10 +
       'It should be case-insensitive and ignore spaces.' + #13#10 +
       '' + #13#10 +
       'Test and print results for:' + #13#10 +
       '    "racecar"          -> true' + #13#10 +
       '    "A man a plan a canal Panama" -> true' + #13#10 +
       '    "hello"            -> false' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    true' + #13#10 +
       '    true' + #13#10 +
       '    false',
       'Strip spaces, lowercase, compare s with its reverse.',
       'function IsPalindrome(s: String): Boolean;' + #13#10 +
       'begin' + #13#10 +
       '  // Strip spaces, lowercase, compare with reverse' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'begin' + #13#10 +
       '  writeln(IsPalindrome(''racecar''));' + #13#10 +
       '  writeln(IsPalindrome(''A man a plan a canal Panama''));' + #13#10 +
       '  writeln(IsPalindrome(''hello''));' + #13#10 +
       'end.',
       'function IsPalindrome(s: String): Boolean;' + #13#10 +
       'var clean, rev : String; i : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  clean := '''';' + #13#10 +
       '  for i := 1 to Length(s) do' + #13#10 +
       '    if s[i] <> '' '' then clean := clean + LowerCase(s[i]);' + #13#10 +
       '  rev := '''';' + #13#10 +
       '  for i := Length(clean) downto 1 do' + #13#10 +
       '    rev := rev + clean[i];' + #13#10 +
       '  Result := clean = rev;' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'begin' + #13#10 +
       '  writeln(IsPalindrome(''racecar''));' + #13#10 +
       '  writeln(IsPalindrome(''A man a plan a canal Panama''));' + #13#10 +
       '  writeln(IsPalindrome(''hello''));' + #13#10 +
       'end.',
       ckExactOutput, 'True' + #13#10 + 'True' + #13#10 + 'False',
       0,0,0, 0, 20)
  ];

  // ── LESSON 5 -- Object-Oriented Programming ────────────────────────────────
  FLessons[4].Number := 5;
  FLessons[4].Title  := 'Object-Oriented Programming';
  FLessons[4].Intro  :=
    'Delphi has one of the most complete OOP systems of any language.' + #13#10 +
    '' + #13#10 +
    '    type' + #13#10 +
    '      TAnimal = class' + #13#10 +
    '      private' + #13#10 +
    '        FName : String;' + #13#10 +
    '      public' + #13#10 +
    '        constructor Create(const AName: String);' + #13#10 +
    '        function    Speak: String; virtual;' + #13#10 +
    '        property    Name : String read FName;' + #13#10 +
    '      end;' + #13#10 +
    '' + #13#10 +
    '      TDog = class(TAnimal)' + #13#10 +
    '      public' + #13#10 +
    '        function Speak: String; override;' + #13#10 +
    '      end;' + #13#10 +
    '' + #13#10 +
    'Key OOP concepts in Delphi:' + #13#10 +
    '    private    only this class' + #13#10 +
    '    protected  this class + descendants' + #13#10 +
    '    public     everyone' + #13#10 +
    '    published  public + RTTI (used by IDE)' + #13#10 +
    '' + #13#10 +
    'Always free what you create:' + #13#10 +
    '    dog := TDog.Create(''Rex'');' + #13#10 +
    '    try' + #13#10 +
    '      writeln(dog.Speak);' + #13#10 +
    '    finally' + #13#10 +
    '      dog.Free;' + #13#10 +
    '    end;' + #13#10 +
    '' + #13#10 +
    'virtual + override enables polymorphism:' + #13#10 +
    '    var animals : array of TAnimal;' + #13#10 +
    '    // each animal.Speak calls the right version';

  FLessons[4].Challenges := [
    Ch(2040, 'Shape Hierarchy',
       'Create a class hierarchy:' + #13#10 +
       '    TShape (base) with virtual function Area: Double' + #13#10 +
       '    TCircle (radius) overrides Area (pi * r^2)' + #13#10 +
       '    TRectangle (width, height) overrides Area (w * h)' + #13#10 +
       '' + #13#10 +
       'Create one of each and print their areas.' + #13#10 +
       'Expected:' + #13#10 +
       '    Circle area:    78.54' + #13#10 +
       '    Rectangle area: 24.00',
       'TCircle.Create(5.0)   TRectangle.Create(6.0, 4.0)   pi = 3.14159265',
       'type' + #13#10 +
       '  TShape = class' + #13#10 +
       '    function Area: Double; virtual;' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       '  TCircle = class(TShape)' + #13#10 +
       '    FRadius : Double;' + #13#10 +
       '    constructor Create(R: Double);' + #13#10 +
       '    function Area: Double; override;' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       '  TRectangle = class(TShape)' + #13#10 +
       '    FW, FH : Double;' + #13#10 +
       '    constructor Create(W, H: Double);' + #13#10 +
       '    function Area: Double; override;' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       '// Implement constructors and Area functions' + #13#10 +
       '' + #13#10 +
       'var c : TCircle; r : TRectangle;' + #13#10 +
       'begin' + #13#10 +
       '  c := TCircle.Create(5.0);' + #13#10 +
       '  r := TRectangle.Create(6.0, 4.0);' + #13#10 +
       '  try' + #13#10 +
       '    writeln(''Circle area:    '', c.Area:6:2);' + #13#10 +
       '    writeln(''Rectangle area: '', r.Area:6:2);' + #13#10 +
       '  finally' + #13#10 +
       '    c.Free; r.Free;' + #13#10 +
       '  end;' + #13#10 +
       'end.',
       'type' + #13#10 +
       '  TShape     = class' + #13#10 +
       '    function Area: Double; virtual; begin Result := 0; end;' + #13#10 +
       '  end;' + #13#10 +
       '  TCircle    = class(TShape)' + #13#10 +
       '    FRadius : Double;' + #13#10 +
       '    constructor Create(R: Double); begin FRadius := R; end;' + #13#10 +
       '    function Area: Double; override; begin Result := 3.14159265 * FRadius * FRadius; end;' + #13#10 +
       '  end;' + #13#10 +
       '  TRectangle = class(TShape)' + #13#10 +
       '    FW, FH : Double;' + #13#10 +
       '    constructor Create(W, H: Double); begin FW := W; FH := H; end;' + #13#10 +
       '    function Area: Double; override; begin Result := FW * FH; end;' + #13#10 +
       '  end;' + #13#10 +
       'var c : TCircle; r : TRectangle;' + #13#10 +
       'begin' + #13#10 +
       '  c := TCircle.Create(5.0);' + #13#10 +
       '  r := TRectangle.Create(6.0, 4.0);' + #13#10 +
       '  try' + #13#10 +
       '    writeln(''Circle area:    '', c.Area:6:2);' + #13#10 +
       '    writeln(''Rectangle area: '', r.Area:6:2);' + #13#10 +
       '  finally' + #13#10 +
       '    c.Free; r.Free;' + #13#10 +
       '  end;' + #13#10 +
       'end.',
       ckContainsAll, '78.54|24.00', 0,0,0, 0, 25),

    Ch(2041, 'Stack Class',
       'Implement a generic integer stack class TIntStack with:' + #13#10 +
       '  Push(Value: Integer)' + #13#10 +
       '  Pop: Integer (raise exception if empty)' + #13#10 +
       '  Peek: Integer (top without removing)' + #13#10 +
       '  IsEmpty: Boolean' + #13#10 +
       '  Count: Integer' + #13#10 +
       '' + #13#10 +
       'Push 10, 20, 30. Pop one. Print Peek and Count.' + #13#10 +
       'Expected:' + #13#10 +
       '    Top: 20   Count: 2',
       'Use a dynamic array as backing store. FTop tracks current top index.',
       'type' + #13#10 +
       '  TIntStack = class' + #13#10 +
       '  private' + #13#10 +
       '    FData : array of Integer;' + #13#10 +
       '    FTop  : Integer;' + #13#10 +
       '  public' + #13#10 +
       '    constructor Create;' + #13#10 +
       '    procedure Push(Value: Integer);' + #13#10 +
       '    function  Pop: Integer;' + #13#10 +
       '    function  Peek: Integer;' + #13#10 +
       '    function  IsEmpty: Boolean;' + #13#10 +
       '    function  Count: Integer;' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       '// Implement the methods' + #13#10 +
       '' + #13#10 +
       'var s : TIntStack;' + #13#10 +
       'begin' + #13#10 +
       '  s := TIntStack.Create;' + #13#10 +
       '  try' + #13#10 +
       '    s.Push(10); s.Push(20); s.Push(30);' + #13#10 +
       '    s.Pop;' + #13#10 +
       '    writeln(''Top: '', s.Peek, ''   Count: '', s.Count);' + #13#10 +
       '  finally' + #13#10 +
       '    s.Free;' + #13#10 +
       '  end;' + #13#10 +
       'end.',
       'type' + #13#10 +
       '  TIntStack = class' + #13#10 +
       '  private' + #13#10 +
       '    FData : array of Integer;' + #13#10 +
       '    FTop  : Integer;' + #13#10 +
       '  public' + #13#10 +
       '    constructor Create; begin FTop := -1; SetLength(FData, 16); end;' + #13#10 +
       '    procedure Push(Value: Integer);' + #13#10 +
       '    begin' + #13#10 +
       '      Inc(FTop);' + #13#10 +
       '      if FTop >= Length(FData) then SetLength(FData, Length(FData) * 2);' + #13#10 +
       '      FData[FTop] := Value;' + #13#10 +
       '    end;' + #13#10 +
       '    function Pop: Integer;' + #13#10 +
       '    begin' + #13#10 +
       '      if FTop < 0 then raise Exception.Create(''Stack underflow'');' + #13#10 +
       '      Result := FData[FTop]; Dec(FTop);' + #13#10 +
       '    end;' + #13#10 +
       '    function Peek: Integer;' + #13#10 +
       '    begin' + #13#10 +
       '      if FTop < 0 then raise Exception.Create(''Stack empty'');' + #13#10 +
       '      Result := FData[FTop];' + #13#10 +
       '    end;' + #13#10 +
       '    function IsEmpty: Boolean; begin Result := FTop < 0; end;' + #13#10 +
       '    function Count: Integer;   begin Result := FTop + 1; end;' + #13#10 +
       '  end;' + #13#10 +
       'var s : TIntStack;' + #13#10 +
       'begin' + #13#10 +
       '  s := TIntStack.Create;' + #13#10 +
       '  try' + #13#10 +
       '    s.Push(10); s.Push(20); s.Push(30);' + #13#10 +
       '    s.Pop;' + #13#10 +
       '    writeln(''Top: '', s.Peek, ''   Count: '', s.Count);' + #13#10 +
       '  finally' + #13#10 +
       '    s.Free;' + #13#10 +
       '  end;' + #13#10 +
       'end.',
       ckExactOutput, 'Top: 20   Count: 2', 0,0,0, 0, 30),

    Ch(2042, 'Observer Pattern',
       'Implement a simple event system (Observer pattern):' + #13#10 +
       '  TEventBus with Subscribe(Name, Handler) and Publish(Name)' + #13#10 +
       '  Handlers are procedure references' + #13#10 +
       '' + #13#10 +
       'Subscribe two handlers to "login" event, publish it.' + #13#10 +
       'Expected:' + #13#10 +
       '    Logger: user logged in' + #13#10 +
       '    Greeter: Welcome back!',
       'Store handlers as array of procedure. Publish loops and calls each.',
       'type' + #13#10 +
       '  THandlerProc = procedure;' + #13#10 +
       '  TEventEntry  = record Name: String; Handler: THandlerProc; end;' + #13#10 +
       '  TEventBus    = class' + #13#10 +
       '  private' + #13#10 +
       '    FEntries : array of TEventEntry;' + #13#10 +
       '  public' + #13#10 +
       '    procedure Subscribe(const Name: String; Handler: THandlerProc);' + #13#10 +
       '    procedure Publish(const Name: String);' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       'procedure OnLogin_Logger;  begin writeln(''Logger: user logged in''); end;' + #13#10 +
       'procedure OnLogin_Greeter; begin writeln(''Greeter: Welcome back!''); end;' + #13#10 +
       '' + #13#10 +
       '// Implement Subscribe and Publish' + #13#10 +
       '' + #13#10 +
       'var bus : TEventBus;' + #13#10 +
       'begin' + #13#10 +
       '  bus := TEventBus.Create;' + #13#10 +
       '  try' + #13#10 +
       '    bus.Subscribe(''login'', OnLogin_Logger);' + #13#10 +
       '    bus.Subscribe(''login'', OnLogin_Greeter);' + #13#10 +
       '    bus.Publish(''login'');' + #13#10 +
       '  finally bus.Free; end;' + #13#10 +
       'end.',
       'type' + #13#10 +
       '  THandlerProc = procedure;' + #13#10 +
       '  TEventEntry  = record Name: String; Handler: THandlerProc; end;' + #13#10 +
       '  TEventBus    = class' + #13#10 +
       '  private' + #13#10 +
       '    FEntries : array of TEventEntry;' + #13#10 +
       '  public' + #13#10 +
       '    procedure Subscribe(const Name: String; Handler: THandlerProc);' + #13#10 +
       '    begin' + #13#10 +
       '      SetLength(FEntries, Length(FEntries) + 1);' + #13#10 +
       '      FEntries[High(FEntries)].Name    := Name;' + #13#10 +
       '      FEntries[High(FEntries)].Handler := Handler;' + #13#10 +
       '    end;' + #13#10 +
       '    procedure Publish(const Name: String);' + #13#10 +
       '    var i : Integer;' + #13#10 +
       '    begin' + #13#10 +
       '      for i := 0 to High(FEntries) do' + #13#10 +
       '        if FEntries[i].Name = Name then FEntries[i].Handler;' + #13#10 +
       '    end;' + #13#10 +
       '  end;' + #13#10 +
       'procedure OnLogin_Logger;  begin writeln(''Logger: user logged in''); end;' + #13#10 +
       'procedure OnLogin_Greeter; begin writeln(''Greeter: Welcome back!''); end;' + #13#10 +
       'var bus : TEventBus;' + #13#10 +
       'begin' + #13#10 +
       '  bus := TEventBus.Create;' + #13#10 +
       '  try' + #13#10 +
       '    bus.Subscribe(''login'', OnLogin_Logger);' + #13#10 +
       '    bus.Subscribe(''login'', OnLogin_Greeter);' + #13#10 +
       '    bus.Publish(''login'');' + #13#10 +
       '  finally bus.Free; end;' + #13#10 +
       'end.',
       ckExactOutput,
       'Logger: user logged in' + #13#10 + 'Greeter: Welcome back!',
       0,0,0, 0, 30)
  ];

  // ── LESSON 6 -- Exception Handling & Resource Safety ──────────────────────
  FLessons[5].Number := 6;
  FLessons[5].Title  := 'Exception Handling & Resource Safety';
  FLessons[5].Intro  :=
    'Delphi''s exception model is the gold standard for resource safety.' + #13#10 +
    '' + #13#10 +
    'try..except catches exceptions:' + #13#10 +
    '    try' + #13#10 +
    '      result := 100 div n;' + #13#10 +
    '    except' + #13#10 +
    '      on E: EDivByZero do' + #13#10 +
    '        writeln(''Cannot divide by zero: '', E.Message);' + #13#10 +
    '      on E: Exception do' + #13#10 +
    '        writeln(''Unexpected: '', E.Message);' + #13#10 +
    '    end;' + #13#10 +
    '' + #13#10 +
    'try..finally ALWAYS runs (even on exception):' + #13#10 +
    '    obj := TMyClass.Create;' + #13#10 +
    '    try' + #13#10 +
    '      obj.DoWork;   // may raise' + #13#10 +
    '    finally' + #13#10 +
    '      obj.Free;     // always runs' + #13#10 +
    '    end;' + #13#10 +
    '' + #13#10 +
    'Raise your own exceptions:' + #13#10 +
    '    raise Exception.CreateFmt(''Invalid value: %d'', [n]);' + #13#10 +
    '    raise EArgumentException.Create(''Age must be positive'');' + #13#10 +
    '' + #13#10 +
    'Custom exception classes:' + #13#10 +
    '    type EBalanceError = class(Exception);' + #13#10 +
    '    raise EBalanceError.Create(''Insufficient funds'');' + #13#10 +
    '' + #13#10 +
    'Re-raise to let the caller handle it:' + #13#10 +
    '    except' + #13#10 +
    '      on E: Exception do' + #13#10 +
    '      begin' + #13#10 +
    '        Log(E.Message);' + #13#10 +
    '        raise;   // re-raise same exception' + #13#10 +
    '      end;' + #13#10 +
    '    end;';

  FLessons[5].Challenges := [
    Ch(2050, 'Safe Calculator',
       'Write SafeDivide(A, B: Integer): Integer that raises' + #13#10 +
       'EArgumentException with "Divisor cannot be zero" if B = 0.' + #13#10 +
       '' + #13#10 +
       'Test with 10 div 2 (OK) and 10 div 0 (caught).' + #13#10 +
       'Expected:' + #13#10 +
       '    Result: 5' + #13#10 +
       '    Error: Divisor cannot be zero',
       'raise EArgumentException.Create(...) in the B=0 branch.',
       'function SafeDivide(A, B: Integer): Integer;' + #13#10 +
       'begin' + #13#10 +
       '  // Raise EArgumentException if B = 0' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'begin' + #13#10 +
       '  try' + #13#10 +
       '    writeln(''Result: '', SafeDivide(10, 2));' + #13#10 +
       '    writeln(''Result: '', SafeDivide(10, 0));' + #13#10 +
       '  except' + #13#10 +
       '    on E: Exception do writeln(''Error: '', E.Message);' + #13#10 +
       '  end;' + #13#10 +
       'end.',
       'function SafeDivide(A, B: Integer): Integer;' + #13#10 +
       'begin' + #13#10 +
       '  if B = 0 then' + #13#10 +
       '    raise EArgumentException.Create(''Divisor cannot be zero'');' + #13#10 +
       '  Result := A div B;' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'begin' + #13#10 +
       '  try' + #13#10 +
       '    writeln(''Result: '', SafeDivide(10, 2));' + #13#10 +
       '    writeln(''Result: '', SafeDivide(10, 0));' + #13#10 +
       '  except' + #13#10 +
       '    on E: Exception do writeln(''Error: '', E.Message);' + #13#10 +
       '  end;' + #13#10 +
       'end.',
       ckExactOutput,
       'Result: 5' + #13#10 + 'Error: Divisor cannot be zero',
       0,0,0, 0, 15),

    Ch(2051, 'Resource Guard',
       'Simulate a database connection class TFakeDB with:' + #13#10 +
       '  constructor Create (prints "DB connected")' + #13#10 +
       '  destructor Destroy (prints "DB disconnected")' + #13#10 +
       '  procedure Query (raises if query is empty)' + #13#10 +
       '' + #13#10 +
       'Use try..finally to guarantee disconnection even when Query raises.' + #13#10 +
       'Expected:' + #13#10 +
       '    DB connected' + #13#10 +
       '    Query error: Empty query' + #13#10 +
       '    DB disconnected',
       'db := TFakeDB.Create;   try  db.Query('''');  except ... end;  finally  db.Free;  end;',
       'type' + #13#10 +
       '  TFakeDB = class' + #13#10 +
       '    constructor Create;' + #13#10 +
       '    destructor  Destroy; override;' + #13#10 +
       '    procedure   Query(const SQL: String);' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       '// Implement Create, Destroy, Query' + #13#10 +
       '' + #13#10 +
       'var db : TFakeDB;' + #13#10 +
       'begin' + #13#10 +
       '  db := TFakeDB.Create;' + #13#10 +
       '  try' + #13#10 +
       '    try' + #13#10 +
       '      db.Query('''');' + #13#10 +
       '    except' + #13#10 +
       '      on E: Exception do writeln(''Query error: '', E.Message);' + #13#10 +
       '    end;' + #13#10 +
       '  finally' + #13#10 +
       '    db.Free;' + #13#10 +
       '  end;' + #13#10 +
       'end.',
       'type' + #13#10 +
       '  TFakeDB = class' + #13#10 +
       '    constructor Create; begin writeln(''DB connected''); end;' + #13#10 +
       '    destructor  Destroy; override; begin writeln(''DB disconnected''); inherited; end;' + #13#10 +
       '    procedure   Query(const SQL: String);' + #13#10 +
       '    begin if Trim(SQL) = '''' then raise Exception.Create(''Empty query''); end;' + #13#10 +
       '  end;' + #13#10 +
       'var db : TFakeDB;' + #13#10 +
       'begin' + #13#10 +
       '  db := TFakeDB.Create;' + #13#10 +
       '  try' + #13#10 +
       '    try' + #13#10 +
       '      db.Query('''');' + #13#10 +
       '    except' + #13#10 +
       '      on E: Exception do writeln(''Query error: '', E.Message);' + #13#10 +
       '    end;' + #13#10 +
       '  finally' + #13#10 +
       '    db.Free;' + #13#10 +
       '  end;' + #13#10 +
       'end.',
       ckExactOutput,
       'DB connected' + #13#10 + 'Query error: Empty query' + #13#10 + 'DB disconnected',
       0,0,0, 0, 25),

    Ch(2052, 'Validation Chain',
       'Write three validation functions that raise EArgumentException:' + #13#10 +
       '  ValidateName(s)  : must not be empty' + #13#10 +
       '  ValidateAge(n)   : must be 18..100' + #13#10 +
       '  ValidateEmail(s) : must contain @ and .' + #13#10 +
       '' + #13#10 +
       'Run a valid record, then an invalid one (age = 15).' + #13#10 +
       'Expected:' + #13#10 +
       '    Record valid: Alice, 25, alice@example.com' + #13#10 +
       '    Validation failed: Age must be 18 to 100',
       'Each function raises if invalid, does nothing if valid.',
       'procedure ValidateName(const s: String);' + #13#10 +
       'procedure ValidateAge(n: Integer);' + #13#10 +
       'procedure ValidateEmail(const s: String);' + #13#10 +
       '' + #13#10 +
       '// Implement each' + #13#10 +
       '' + #13#10 +
       'begin' + #13#10 +
       '  try' + #13#10 +
       '    ValidateName(''Alice''); ValidateAge(25); ValidateEmail(''alice@example.com'');' + #13#10 +
       '    writeln(''Record valid: Alice, 25, alice@example.com'');' + #13#10 +
       '  except on E: Exception do writeln(''Validation failed: '', E.Message); end;' + #13#10 +
       '' + #13#10 +
       '  try' + #13#10 +
       '    ValidateName(''Bob''); ValidateAge(15); ValidateEmail(''bob@b.com'');' + #13#10 +
       '    writeln(''Record valid: Bob, 15, bob@b.com'');' + #13#10 +
       '  except on E: Exception do writeln(''Validation failed: '', E.Message); end;' + #13#10 +
       'end.',
       'procedure ValidateName(const s: String);' + #13#10 +
       'begin if Trim(s) = '''' then raise EArgumentException.Create(''Name cannot be empty''); end;' + #13#10 +
       'procedure ValidateAge(n: Integer);' + #13#10 +
       'begin if (n < 18) or (n > 100) then raise EArgumentException.Create(''Age must be 18 to 100''); end;' + #13#10 +
       'procedure ValidateEmail(const s: String);' + #13#10 +
       'begin if (Pos(''@'',s)=0) or (Pos(''.'',s)=0) then raise EArgumentException.Create(''Invalid email''); end;' + #13#10 +
       'begin' + #13#10 +
       '  try' + #13#10 +
       '    ValidateName(''Alice''); ValidateAge(25); ValidateEmail(''alice@example.com'');' + #13#10 +
       '    writeln(''Record valid: Alice, 25, alice@example.com'');' + #13#10 +
       '  except on E: Exception do writeln(''Validation failed: '', E.Message); end;' + #13#10 +
       '  try' + #13#10 +
       '    ValidateName(''Bob''); ValidateAge(15); ValidateEmail(''bob@b.com'');' + #13#10 +
       '    writeln(''Record valid: Bob, 15, bob@b.com'');' + #13#10 +
       '  except on E: Exception do writeln(''Validation failed: '', E.Message); end;' + #13#10 +
       'end.',
       ckExactOutput,
       'Record valid: Alice, 25, alice@example.com' + #13#10 +
       'Validation failed: Age must be 18 to 100',
       0,0,0, 0, 25)
  ];

  // ── LESSON 7 -- Dynamic Data Structures ───────────────────────────────────
  FLessons[6].Number := 7;
  FLessons[6].Title  := 'Dynamic Data Structures';
  FLessons[6].Intro  :=
    'Building data structures from scratch teaches you how memory works.' + #13#10 +
    'Delphi''s explicit memory management makes this clear and predictable.' + #13#10 +
    '' + #13#10 +
    'Dynamic arrays -- the everyday collection:' + #13#10 +
    '    var nums : array of Integer;' + #13#10 +
    '    SetLength(nums, 10);' + #13#10 +
    '    nums[0] := 42;' + #13#10 +
    '    writeln(Length(nums));   // 10' + #13#10 +
    '' + #13#10 +
    'Linked list node (classic pointer pattern):' + #13#10 +
    '    type' + #13#10 +
    '      PNode = ^TNode;' + #13#10 +
    '      TNode = record' + #13#10 +
    '        Value : Integer;' + #13#10 +
    '        Next  : PNode;' + #13#10 +
    '      end;' + #13#10 +
    '' + #13#10 +
    'Allocate / free nodes:' + #13#10 +
    '    New(node);       // allocate' + #13#10 +
    '    node^.Value := 42;' + #13#10 +
    '    Dispose(node);   // free' + #13#10 +
    '' + #13#10 +
    'Resizing a dynamic array:' + #13#10 +
    '    SetLength(nums, Length(nums) * 2);  // double capacity' + #13#10 +
    '    SetLength(nums, Length(nums) - 1);  // shrink by one';

  FLessons[6].Challenges := [
    Ch(2060, 'Dynamic Append',
       'Build a dynamic array of integers starting empty.' + #13#10 +
       'Append the squares of 1..8 one at a time using SetLength.' + #13#10 +
       'Print the array contents and its length.' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    1 4 9 16 25 36 49 64' + #13#10 +
       '    Length: 8',
       'SetLength(arr, Length(arr) + 1);   arr[High(arr)] := i*i;',
       'var arr : array of Integer;' + #13#10 +
       '    i   : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  // Append squares of 1..8 using SetLength' + #13#10 +
       'end.',
       'var arr : array of Integer;' + #13#10 +
       '    i   : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  SetLength(arr, 0);' + #13#10 +
       '  for i := 1 to 8 do' + #13#10 +
       '  begin' + #13#10 +
       '    SetLength(arr, Length(arr) + 1);' + #13#10 +
       '    arr[High(arr)] := i * i;' + #13#10 +
       '  end;' + #13#10 +
       '  for i := 0 to High(arr) do write(arr[i], '' '');' + #13#10 +
       '  writeln;' + #13#10 +
       '  writeln(''Length: '', Length(arr));' + #13#10 +
       'end.',
       ckContainsAll, '1 4 9 16 25 36 49 64|Length: 8', 0,0,0, 0, 15),

    Ch(2061, 'Linked List',
       'Implement a simple singly-linked list of integers.' + #13#10 +
       'Operations: Prepend(Value), PrintAll, FreeAll.' + #13#10 +
       '' + #13#10 +
       'Prepend 10, 20, 30 (prepend reverses order).' + #13#10 +
       'Expected: 30 -> 20 -> 10 -> nil',
       'PNode = ^TNode. New(n); n^.Value := V; n^.Next := FHead; FHead := n;',
       'type' + #13#10 +
       '  PNode = ^TNode;' + #13#10 +
       '  TNode = record Value : Integer; Next : PNode; end;' + #13#10 +
       '  TList = class' + #13#10 +
       '  private' + #13#10 +
       '    FHead : PNode;' + #13#10 +
       '  public' + #13#10 +
       '    procedure Prepend(Value: Integer);' + #13#10 +
       '    procedure PrintAll;' + #13#10 +
       '    procedure FreeAll;' + #13#10 +
       '    destructor Destroy; override;' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       '// Implement the methods' + #13#10 +
       '' + #13#10 +
       'var lst : TList;' + #13#10 +
       'begin' + #13#10 +
       '  lst := TList.Create;' + #13#10 +
       '  try' + #13#10 +
       '    lst.Prepend(10); lst.Prepend(20); lst.Prepend(30);' + #13#10 +
       '    lst.PrintAll;' + #13#10 +
       '  finally lst.Free; end;' + #13#10 +
       'end.',
       'type' + #13#10 +
       '  PNode = ^TNode;' + #13#10 +
       '  TNode = record Value : Integer; Next : PNode; end;' + #13#10 +
       '  TList = class' + #13#10 +
       '  private FHead : PNode;' + #13#10 +
       '  public' + #13#10 +
       '    procedure Prepend(Value: Integer);' + #13#10 +
       '    var n : PNode;' + #13#10 +
       '    begin New(n); n^.Value := Value; n^.Next := FHead; FHead := n; end;' + #13#10 +
       '    procedure PrintAll;' + #13#10 +
       '    var cur : PNode;' + #13#10 +
       '    begin' + #13#10 +
       '      cur := FHead;' + #13#10 +
       '      while cur <> nil do' + #13#10 +
       '      begin write(cur^.Value, '' -> ''); cur := cur^.Next; end;' + #13#10 +
       '      writeln(''nil'');' + #13#10 +
       '    end;' + #13#10 +
       '    procedure FreeAll;' + #13#10 +
       '    var cur, nxt : PNode;' + #13#10 +
       '    begin' + #13#10 +
       '      cur := FHead;' + #13#10 +
       '      while cur <> nil do' + #13#10 +
       '      begin nxt := cur^.Next; Dispose(cur); cur := nxt; end;' + #13#10 +
       '      FHead := nil;' + #13#10 +
       '    end;' + #13#10 +
       '    destructor Destroy; override; begin FreeAll; inherited; end;' + #13#10 +
       '  end;' + #13#10 +
       'var lst : TList;' + #13#10 +
       'begin' + #13#10 +
       '  lst := TList.Create;' + #13#10 +
       '  try' + #13#10 +
       '    lst.Prepend(10); lst.Prepend(20); lst.Prepend(30);' + #13#10 +
       '    lst.PrintAll;' + #13#10 +
       '  finally lst.Free; end;' + #13#10 +
       'end.',
       ckExactOutput, '30 -> 20 -> 10 -> nil', 0,0,0, 0, 30),

    Ch(2062, 'Hash Map',
       'Implement a simple string-keyed integer hash map using an array of buckets.' + #13#10 +
       'Operations: Put(Key, Value), Get(Key): Integer, ContainsKey(Key): Boolean.' + #13#10 +
       '' + #13#10 +
       'Store word frequencies and print the top word.' + #13#10 +
       'Expected: the: 4',
       'Use 16 buckets. Hash = sum of ord(ch) mod 16. Handle collisions with a linked list.',
       '// Implement a simple hash map and use it to count word frequencies.' + #13#10 +
       '// Words: "the cat sat on the mat the cat sat on the"' + #13#10 +
       '// Find and print the most frequent word.',
       'type' + #13#10 +
       '  PBucket = ^TBucket;' + #13#10 +
       '  TBucket = record Key: String; Value: Integer; Next: PBucket; end;' + #13#10 +
       '  THashMap = class' + #13#10 +
       '  private' + #13#10 +
       '    FBuckets : array[0..15] of PBucket;' + #13#10 +
       '    function HashOf(const Key: String): Integer;' + #13#10 +
       '    var i, h : Integer;' + #13#10 +
       '    begin h := 0; for i := 1 to Length(Key) do Inc(h, Ord(Key[i])); Result := h mod 16; end;' + #13#10 +
       '  public' + #13#10 +
       '    destructor Destroy; override;' + #13#10 +
       '    procedure Put(const Key: String; Value: Integer);' + #13#10 +
       '    var b : PBucket; h : Integer;' + #13#10 +
       '    begin' + #13#10 +
       '      h := HashOf(Key); b := FBuckets[h];' + #13#10 +
       '      while b <> nil do begin if b^.Key = Key then begin b^.Value := Value; Exit; end; b := b^.Next; end;' + #13#10 +
       '      New(b); b^.Key := Key; b^.Value := Value; b^.Next := FBuckets[h]; FBuckets[h] := b;' + #13#10 +
       '    end;' + #13#10 +
       '    function Get(const Key: String): Integer;' + #13#10 +
       '    var b : PBucket;' + #13#10 +
       '    begin Result := 0; b := FBuckets[HashOf(Key)]; while b <> nil do begin if b^.Key=Key then begin Result:=b^.Value; Exit; end; b:=b^.Next; end; end;' + #13#10 +
       '    destructor THashMap.Destroy;' + #13#10 +
       '    var i : Integer; b, n : PBucket;' + #13#10 +
       '    begin' + #13#10 +
       '      for i := 0 to 15 do begin b := FBuckets[i]; while b<>nil do begin n:=b^.Next; Dispose(b); b:=n; end; end;' + #13#10 +
       '      inherited;' + #13#10 +
       '    end;' + #13#10 +
       '  end;' + #13#10 +
       'var' + #13#10 +
       '  map : THashMap; words : array of String;' + #13#10 +
       '  i, best : Integer; bestWord : String;' + #13#10 +
       '  sentence : String;' + #13#10 +
       'begin' + #13#10 +
       '  sentence := ''the cat sat on the mat the cat sat on the'';' + #13#10 +
       '  // Split into words (simple space split)' + #13#10 +
       '  SetLength(words, 0);' + #13#10 +
       '  var p, last : Integer; s : String;' + #13#10 +
       '  last := 1;' + #13#10 +
       '  for p := 1 to Length(sentence) do' + #13#10 +
       '    if sentence[p] = '' '' then' + #13#10 +
       '    begin' + #13#10 +
       '      s := Copy(sentence, last, p-last);' + #13#10 +
       '      SetLength(words, Length(words)+1); words[High(words)] := s;' + #13#10 +
       '      last := p + 1;' + #13#10 +
       '    end;' + #13#10 +
       '  SetLength(words, Length(words)+1); words[High(words)] := Copy(sentence, last, Length(sentence));' + #13#10 +
       '  map := THashMap.Create;' + #13#10 +
       '  try' + #13#10 +
       '    for i := 0 to High(words) do map.Put(words[i], map.Get(words[i]) + 1);' + #13#10 +
       '    best := 0; bestWord := '''';' + #13#10 +
       '    for i := 0 to High(words) do' + #13#10 +
       '      if map.Get(words[i]) > best then begin best := map.Get(words[i]); bestWord := words[i]; end;' + #13#10 +
       '    writeln(bestWord, '': '', best);' + #13#10 +
       '  finally map.Free; end;' + #13#10 +
       'end.',
       ckExactOutput, 'the: 4', 0,0,0, 0, 35)
  ];

  // ── LESSON 8 -- File I/O & INI Files ──────────────────────────────────────
  FLessons[7].Number := 8;
  FLessons[7].Title  := 'File I/O & INI Files';
  FLessons[7].Intro  :=
    'Pascal file I/O is explicit, fast, and gives you full control.' + #13#10 +
    '' + #13#10 +
    'Text file I/O (the classic way):' + #13#10 +
    '    var f : TextFile;' + #13#10 +
    '    AssignFile(f, ''data.txt'');' + #13#10 +
    '    Rewrite(f);           // open for writing (creates/truncates)' + #13#10 +
    '    writeln(f, ''Hello'');' + #13#10 +
    '    CloseFile(f);' + #13#10 +
    '' + #13#10 +
    'Reading:' + #13#10 +
    '    Reset(f);             // open for reading' + #13#10 +
    '    while not Eof(f) do' + #13#10 +
    '    begin' + #13#10 +
    '      readln(f, line);' + #13#10 +
    '      // process line' + #13#10 +
    '    end;' + #13#10 +
    '    CloseFile(f);' + #13#10 +
    '' + #13#10 +
    'INI files (pythia.ini, app.ini):' + #13#10 +
    '    // Write a setting' + #13#10 +
    '    IniWriteStr(''app.ini'', ''Database'', ''Host'', ''localhost'');' + #13#10 +
    '    IniWriteInt(''app.ini'', ''Database'', ''Port'', 5432);' + #13#10 +
    '' + #13#10 +
    '    // Read it back' + #13#10 +
    '    host := IniReadStr(''app.ini'', ''Database'', ''Host'', ''default'');' + #13#10 +
    '    port := IniReadInt(''app.ini'', ''Database'', ''Port'', 5432);';

  FLessons[7].Challenges := [
    Ch(2070, 'Write & Read Log',
       'Write a 5-line log file, then read it back and print the line count' + #13#10 +
       'and the third line.' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    Lines: 5' + #13#10 +
       '    Line 3: 2026-01-01 INFO  Service started',
       'Rewrite(f) to write, Reset(f) + readln loop to read.',
       'var' + #13#10 +
       '  f    : TextFile;' + #13#10 +
       '  line : String;' + #13#10 +
       '  count, n : Integer;' + #13#10 +
       '  third    : String;' + #13#10 +
       'begin' + #13#10 +
       '  AssignFile(f, ''app.log'');' + #13#10 +
       '  Rewrite(f);' + #13#10 +
       '  writeln(f, ''2026-01-01 INFO  Server booting'');' + #13#10 +
       '  writeln(f, ''2026-01-01 INFO  Loading config'');' + #13#10 +
       '  writeln(f, ''2026-01-01 INFO  Service started'');' + #13#10 +
       '  writeln(f, ''2026-01-01 INFO  Listening on port 8080'');' + #13#10 +
       '  writeln(f, ''2026-01-01 INFO  Ready'');' + #13#10 +
       '  CloseFile(f);' + #13#10 +
       '  // Read back and print line count and line 3' + #13#10 +
       'end.',
       'var' + #13#10 +
       '  f     : TextFile;' + #13#10 +
       '  line  : String;' + #13#10 +
       '  count : Integer;' + #13#10 +
       '  third : String;' + #13#10 +
       'begin' + #13#10 +
       '  AssignFile(f, ''app.log'');' + #13#10 +
       '  Rewrite(f);' + #13#10 +
       '  writeln(f, ''2026-01-01 INFO  Server booting'');' + #13#10 +
       '  writeln(f, ''2026-01-01 INFO  Loading config'');' + #13#10 +
       '  writeln(f, ''2026-01-01 INFO  Service started'');' + #13#10 +
       '  writeln(f, ''2026-01-01 INFO  Listening on port 8080'');' + #13#10 +
       '  writeln(f, ''2026-01-01 INFO  Ready'');' + #13#10 +
       '  CloseFile(f);' + #13#10 +
       '  Reset(f);' + #13#10 +
       '  count := 0; third := '''';' + #13#10 +
       '  while not Eof(f) do' + #13#10 +
       '  begin' + #13#10 +
       '    readln(f, line);' + #13#10 +
       '    Inc(count);' + #13#10 +
       '    if count = 3 then third := line;' + #13#10 +
       '  end;' + #13#10 +
       '  CloseFile(f);' + #13#10 +
       '  writeln(''Lines: '', count);' + #13#10 +
       '  writeln(''Line 3: '', third);' + #13#10 +
       'end.',
       ckExactOutput,
       'Lines: 5' + #13#10 + 'Line 3: 2026-01-01 INFO  Service started',
       0,0,0, 0, 20),

    Ch(2071, 'INI Config',
       'Use INI builtins to save and load application settings.' + #13#10 +
       'Write these settings to "myapp.ini":' + #13#10 +
       '    [Server] Host=api.example.com  Port=8443' + #13#10 +
       '    [Auth]   Token=abc123          Timeout=30' + #13#10 +
       '' + #13#10 +
       'Read them back and print:' + #13#10 +
       '    Server: api.example.com:8443' + #13#10 +
       '    Token: abc123 (timeout: 30s)',
       'IniWriteStr(file, section, key, value)   IniReadStr(file, section, key, default)',
       'var host, token : String; port, timeout : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  // Write settings' + #13#10 +
       '  IniWriteStr(''myapp.ini'', ''Server'', ''Host'',    ''api.example.com'');' + #13#10 +
       '  IniWriteInt(''myapp.ini'', ''Server'', ''Port'',    8443);' + #13#10 +
       '  IniWriteStr(''myapp.ini'', ''Auth'',   ''Token'',   ''abc123'');' + #13#10 +
       '  IniWriteInt(''myapp.ini'', ''Auth'',   ''Timeout'', 30);' + #13#10 +
       '  // Read back and print' + #13#10 +
       'end.',
       'var host, token : String; port, timeout : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  IniWriteStr(''myapp.ini'', ''Server'', ''Host'',    ''api.example.com'');' + #13#10 +
       '  IniWriteInt(''myapp.ini'', ''Server'', ''Port'',    8443);' + #13#10 +
       '  IniWriteStr(''myapp.ini'', ''Auth'',   ''Token'',   ''abc123'');' + #13#10 +
       '  IniWriteInt(''myapp.ini'', ''Auth'',   ''Timeout'', 30);' + #13#10 +
       '  host    := IniReadStr(''myapp.ini'', ''Server'', ''Host'',    '''');' + #13#10 +
       '  port    := IniReadInt(''myapp.ini'', ''Server'', ''Port'',    0);' + #13#10 +
       '  token   := IniReadStr(''myapp.ini'', ''Auth'',   ''Token'',   '''');' + #13#10 +
       '  timeout := IniReadInt(''myapp.ini'', ''Auth'',   ''Timeout'', 0);' + #13#10 +
       '  writeln(''Server: '', host, '':'', port);' + #13#10 +
       '  writeln(''Token: '', token, '' (timeout: '', timeout, ''s)'');' + #13#10 +
       'end.',
       ckExactOutput,
       'Server: api.example.com:8443' + #13#10 + 'Token: abc123 (timeout: 30s)',
       0,0,0, 0, 20),

    Ch(2072, 'CSV Report Writer',
       'Write a CSV report to "sales.csv", then read it back and print:' + #13#10 +
       '  - The highest revenue row' + #13#10 +
       '  - The total revenue' + #13#10 +
       '' + #13#10 +
       'Data:  Q1 Widget 45000  Q2 Widget 52000  Q3 Gadget 38000  Q4 Gadget 61000' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    Best: Q4 Gadget 61000' + #13#10 +
       '    Total: 196000',
       'Write header + rows with writeln(f,...), read with readln and parse commas.',
       'var f : TextFile; line, qtr, prod : String; rev, best, total : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  // Write CSV, read back, find best and total' + #13#10 +
       'end.',
       'var' + #13#10 +
       '  f           : TextFile;' + #13#10 +
       '  line, qtr, prod, bestQ, bestP : String;' + #13#10 +
       '  rev, best, total, p : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  AssignFile(f, ''sales.csv''); Rewrite(f);' + #13#10 +
       '  writeln(f, ''Quarter,Product,Revenue'');' + #13#10 +
       '  writeln(f, ''Q1,Widget,45000'');' + #13#10 +
       '  writeln(f, ''Q2,Widget,52000'');' + #13#10 +
       '  writeln(f, ''Q3,Gadget,38000'');' + #13#10 +
       '  writeln(f, ''Q4,Gadget,61000'');' + #13#10 +
       '  CloseFile(f);' + #13#10 +
       '  Reset(f); readln(f, line);  // skip header' + #13#10 +
       '  best := 0; total := 0; bestQ := ''''; bestP := '''';' + #13#10 +
       '  while not Eof(f) do' + #13#10 +
       '  begin' + #13#10 +
       '    readln(f, line);' + #13#10 +
       '    p := Pos('','', line); qtr := Copy(line,1,p-1); line := Copy(line,p+1,Length(line));' + #13#10 +
       '    p := Pos('','', line); prod := Copy(line,1,p-1); rev := StrToInt(Copy(line,p+1,Length(line)));' + #13#10 +
       '    total := total + rev;' + #13#10 +
       '    if rev > best then begin best := rev; bestQ := qtr; bestP := prod; end;' + #13#10 +
       '  end;' + #13#10 +
       '  CloseFile(f);' + #13#10 +
       '  writeln(''Best: '', bestQ, '' '', bestP, '' '', best);' + #13#10 +
       '  writeln(''Total: '', total);' + #13#10 +
       'end.',
       ckExactOutput,
       'Best: Q4 Gadget 61000' + #13#10 + 'Total: 196000',
       0,0,0, 0, 30)
  ];

  // ── LESSON 9 -- Algorithms & Problem Solving ───────────────────────────────
  FLessons[8].Number := 9;
  FLessons[8].Title  := 'Algorithms & Problem Solving';
  FLessons[8].Intro  :=
    'Pascal''s clarity makes it ideal for implementing algorithms.' + #13#10 +
    'The compiler enforces correctness -- no silent type coercions.' + #13#10 +
    '' + #13#10 +
    'Binary search (O(log n)):' + #13#10 +
    '    function BinarySearch(Arr: array of Integer; N, Target: Integer): Integer;' + #13#10 +
    '    var lo, hi, mid : Integer;' + #13#10 +
    '    begin' + #13#10 +
    '      lo := 0;  hi := N - 1;  Result := -1;' + #13#10 +
    '      while lo <= hi do' + #13#10 +
    '      begin' + #13#10 +
    '        mid := (lo + hi) div 2;' + #13#10 +
    '        if Arr[mid] = Target then begin Result := mid; Exit; end' + #13#10 +
    '        else if Arr[mid] < Target then lo := mid + 1' + #13#10 +
    '        else hi := mid - 1;' + #13#10 +
    '      end;' + #13#10 +
    '    end;' + #13#10 +
    '' + #13#10 +
    'Big-O complexity thinking:' + #13#10 +
    '    O(1)      constant  -- array index' + #13#10 +
    '    O(log n)  logarithmic -- binary search' + #13#10 +
    '    O(n)      linear -- single loop' + #13#10 +
    '    O(n^2)    quadratic -- nested loops' + #13#10 +
    '' + #13#10 +
    'Memoization pattern (cache expensive results):' + #13#10 +
    '    var cache : array[0..50] of Int64;' + #13#10 +
    '    FillChar(cache, SizeOf(cache), -1);   // -1 = uncalculated' + #13#10 +
    '    if cache[n] >= 0 then Exit(cache[n]);  // cache hit';

  FLessons[8].Challenges := [
    Ch(2080, 'Binary Search',
       'Implement binary search on a sorted array of integers.' + #13#10 +
       'Return the index (0-based) or -1 if not found.' + #13#10 +
       '' + #13#10 +
       'Search for 42 and 99 in [2,7,14,23,42,58,71,89,95,100].' + #13#10 +
       'Expected:' + #13#10 +
       '    Found 42 at index 4' + #13#10 +
       '    99 not found',
       'lo:=0; hi:=N-1; mid := (lo+hi) div 2; compare and halve.',
       'function BinarySearch(var Arr: array of Integer; N, Target: Integer): Integer;' + #13#10 +
       'var lo, hi, mid : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  // Implement binary search' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'var data : array[0..9] of Integer;' + #13#10 +
       '    idx  : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  data[0]:=2;  data[1]:=7;  data[2]:=14; data[3]:=23; data[4]:=42;' + #13#10 +
       '  data[5]:=58; data[6]:=71; data[7]:=89; data[8]:=95; data[9]:=100;' + #13#10 +
       '  idx := BinarySearch(data, 10, 42);' + #13#10 +
       '  if idx >= 0 then writeln(''Found 42 at index '', idx)' + #13#10 +
       '  else writeln(''42 not found'');' + #13#10 +
       '  idx := BinarySearch(data, 10, 99);' + #13#10 +
       '  if idx >= 0 then writeln(''Found 99 at index '', idx)' + #13#10 +
       '  else writeln(''99 not found'');' + #13#10 +
       'end.',
       'function BinarySearch(var Arr: array of Integer; N, Target: Integer): Integer;' + #13#10 +
       'var lo, hi, mid : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  lo := 0; hi := N - 1; Result := -1;' + #13#10 +
       '  while lo <= hi do' + #13#10 +
       '  begin' + #13#10 +
       '    mid := (lo + hi) div 2;' + #13#10 +
       '    if Arr[mid] = Target then begin Result := mid; Exit; end' + #13#10 +
       '    else if Arr[mid] < Target then lo := mid + 1' + #13#10 +
       '    else hi := mid - 1;' + #13#10 +
       '  end;' + #13#10 +
       'end;' + #13#10 +
       'var data : array[0..9] of Integer; idx : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  data[0]:=2;  data[1]:=7;  data[2]:=14; data[3]:=23; data[4]:=42;' + #13#10 +
       '  data[5]:=58; data[6]:=71; data[7]:=89; data[8]:=95; data[9]:=100;' + #13#10 +
       '  idx := BinarySearch(data, 10, 42);' + #13#10 +
       '  if idx >= 0 then writeln(''Found 42 at index '', idx) else writeln(''42 not found'');' + #13#10 +
       '  idx := BinarySearch(data, 10, 99);' + #13#10 +
       '  if idx >= 0 then writeln(''Found 99 at index '', idx) else writeln(''99 not found'');' + #13#10 +
       'end.',
       ckExactOutput,
       'Found 42 at index 4' + #13#10 + '99 not found',
       0,0,0, 0, 20),

    Ch(2081, 'Memoized Fibonacci',
       'Calculate Fibonacci(40) efficiently using memoization.' + #13#10 +
       'A naive recursive version would take billions of calls.' + #13#10 +
       'Memoization brings it to O(n).' + #13#10 +
       '' + #13#10 +
       'Expected: Fib(40) = 102334155',
       'var cache : array[0..50] of Int64 initialized to -1. Check cache before recursing.',
       'var cache : array[0..50] of Int64;' + #13#10 +
       '' + #13#10 +
       'function Fib(n: Integer): Int64;' + #13#10 +
       'begin' + #13#10 +
       '  // Use cache to avoid recalculation' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'var i : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  for i := 0 to 50 do cache[i] := -1;' + #13#10 +
       '  writeln(''Fib(40) = '', Fib(40));' + #13#10 +
       'end.',
       'var cache : array[0..50] of Int64;' + #13#10 +
       'function Fib(n: Integer): Int64;' + #13#10 +
       'begin' + #13#10 +
       '  if n <= 1 then begin Result := n; Exit; end;' + #13#10 +
       '  if cache[n] >= 0 then begin Result := cache[n]; Exit; end;' + #13#10 +
       '  cache[n] := Fib(n-1) + Fib(n-2);' + #13#10 +
       '  Result := cache[n];' + #13#10 +
       'end;' + #13#10 +
       'var i : Integer;' + #13#10 +
       'begin' + #13#10 +
       '  for i := 0 to 50 do cache[i] := -1;' + #13#10 +
       '  writeln(''Fib(40) = '', Fib(40));' + #13#10 +
       'end.',
       ckExactOutput, 'Fib(40) = 102334155', 0,0,0, 0, 25),

    Ch(2082, 'Run-Length Encoding',
       'Implement run-length encoding (RLE) compression.' + #13#10 +
       '"AAABBBCCDDDDEA"  ->  "3A3B2C4D1E1A"' + #13#10 +
       '' + #13#10 +
       'Also implement decoding: "3A3B2C4D1E1A" -> "AAABBBCCDDDDEA"' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    Encoded: 3A3B2C4D1E1A' + #13#10 +
       '    Decoded: AAABBBCCDDDDEA',
       'Count consecutive identical chars. Decode by reading digit(s) then char.',
       'function RLEncode(s: String): String;' + #13#10 +
       'begin' + #13#10 +
       '  // Encode: count runs of same character' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'function RLDecode(s: String): String;' + #13#10 +
       'begin' + #13#10 +
       '  // Decode: read count then character' + #13#10 +
       'end;' + #13#10 +
       '' + #13#10 +
       'begin' + #13#10 +
       '  writeln(''Encoded: '', RLEncode(''AAABBBCCDDDDEA''));' + #13#10 +
       '  writeln(''Decoded: '', RLDecode(''3A3B2C4D1E1A''));' + #13#10 +
       'end.',
       'function RLEncode(s: String): String;' + #13#10 +
       'var i, count : Integer; cur : Char;' + #13#10 +
       'begin' + #13#10 +
       '  Result := ''''; if Length(s) = 0 then Exit;' + #13#10 +
       '  cur := s[1]; count := 1;' + #13#10 +
       '  for i := 2 to Length(s) do' + #13#10 +
       '    if s[i] = cur then Inc(count)' + #13#10 +
       '    else begin Result := Result + IntToStr(count) + cur; cur := s[i]; count := 1; end;' + #13#10 +
       '  Result := Result + IntToStr(count) + cur;' + #13#10 +
       'end;' + #13#10 +
       'function RLDecode(s: String): String;' + #13#10 +
       'var i, count : Integer; numStr : String;' + #13#10 +
       'begin' + #13#10 +
       '  Result := ''''; i := 1;' + #13#10 +
       '  while i <= Length(s) do' + #13#10 +
       '  begin' + #13#10 +
       '    numStr := '''';' + #13#10 +
       '    while (i <= Length(s)) and (s[i] >= ''0'') and (s[i] <= ''9'') do' + #13#10 +
       '    begin numStr := numStr + s[i]; Inc(i); end;' + #13#10 +
       '    count := StrToIntDef(numStr, 1);' + #13#10 +
       '    if i <= Length(s) then begin Result := Result + StringOfChar(s[i], count); Inc(i); end;' + #13#10 +
       '  end;' + #13#10 +
       'end;' + #13#10 +
       'begin' + #13#10 +
       '  writeln(''Encoded: '', RLEncode(''AAABBBCCDDDDEA''));' + #13#10 +
       '  writeln(''Decoded: '', RLDecode(''3A3B2C4D1E1A''));' + #13#10 +
       'end.',
       ckExactOutput,
       'Encoded: 3A3B2C4D1E1A' + #13#10 + 'Decoded: AAABBBCCDDDDEA',
       0,0,0, 0, 30)
  ];

  // ── LESSON 10 -- Real-World Patterns ──────────────────────────────────────
  FLessons[9].Number := 10;
  FLessons[9].Title  := 'Real-World Delphi Patterns';
  FLessons[9].Intro  :=
    'These patterns appear in virtually every professional Delphi application.' + #13#10 +
    '' + #13#10 +
    'Singleton (one instance, globally accessible):' + #13#10 +
    '    var FInstance : TConfig = nil;' + #13#10 +
    '    class function TConfig.Instance: TConfig;' + #13#10 +
    '    begin' + #13#10 +
    '      if FInstance = nil then FInstance := TConfig.Create;' + #13#10 +
    '      Result := FInstance;' + #13#10 +
    '    end;' + #13#10 +
    '' + #13#10 +
    'Builder pattern (fluent interface):' + #13#10 +
    '    TQueryBuilder' + #13#10 +
    '      .Select(''name, salary'')' + #13#10 +
    '      .From(''employees'')' + #13#10 +
    '      .Where(''dept = ''''Eng'''''')' + #13#10 +
    '      .OrderBy(''salary DESC'')' + #13#10 +
    '      .Build;' + #13#10 +
    '' + #13#10 +
    'Strategy pattern (swap algorithms at runtime):' + #13#10 +
    '    type TSortStrategy = (ssBubble, ssQuick, ssMerge);' + #13#10 +
    '    procedure Sort(var Arr: array of Integer; Strategy: TSortStrategy);' + #13#10 +
    '' + #13#10 +
    'Template method (skeleton in base, details in subclass):' + #13#10 +
    '    TReport.Generate calls:' + #13#10 +
    '      BuildHeader  (abstract -- subclass implements)' + #13#10 +
    '      BuildBody    (abstract)' + #13#10 +
    '      BuildFooter  (abstract)';

  FLessons[9].Challenges := [
    Ch(2090, 'Query Builder',
       'Implement a fluent SQL query builder.' + #13#10 +
       'Methods SelectClause, FromClause, WhereClause, BuildQuery each' + #13#10 +
       'return Self so calls can be chained.' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    SELECT name, salary FROM employees WHERE dept = ''Eng'' ORDER BY salary DESC',
       'Each method sets a field and returns Self. Build concatenates them.',
       'type' + #13#10 +
       '  TQueryBuilder = class' + #13#10 +
       '  private' + #13#10 +
       '    FSelect, FFrom, FWhere, FOrder : String;' + #13#10 +
       '  public' + #13#10 +
       '    function SelectClause(const S: String): TQueryBuilder;' + #13#10 +
       '    function FromClause  (const S: String): TQueryBuilder;' + #13#10 +
       '    function WhereClause (const S: String): TQueryBuilder;' + #13#10 +
       '    function OrderByClause(const S: String): TQueryBuilder;' + #13#10 +
       '    function BuildQuery : String;' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       '// Implement all methods' + #13#10 +
       '' + #13#10 +
       'var qb : TQueryBuilder;' + #13#10 +
       'begin' + #13#10 +
       '  qb := TQueryBuilder.Create;' + #13#10 +
       '  try' + #13#10 +
       '    writeln(' + #13#10 +
       '      qb.SelectClause(''name, salary'')' + #13#10 +
       '        .FromClause(''employees'')' + #13#10 +
       '        .WhereClause(''dept = ''''Eng'''''')' + #13#10 +
       '        .OrderByClause(''salary DESC'')' + #13#10 +
       '        .BuildQuery' + #13#10 +
       '    );' + #13#10 +
       '  finally qb.Free; end;' + #13#10 +
       'end.',
       'type' + #13#10 +
       '  TQueryBuilder = class' + #13#10 +
       '  private FSelect, FFrom, FWhere, FOrder : String;' + #13#10 +
       '  public' + #13#10 +
       '    function SelectClause(const S: String): TQueryBuilder; begin FSelect := S; Result := Self; end;' + #13#10 +
       '    function FromClause  (const S: String): TQueryBuilder; begin FFrom   := S; Result := Self; end;' + #13#10 +
       '    function WhereClause (const S: String): TQueryBuilder; begin FWhere  := S; Result := Self; end;' + #13#10 +
       '    function OrderByClause(const S: String): TQueryBuilder; begin FOrder := S; Result := Self; end;' + #13#10 +
       '    function BuildQuery: String;' + #13#10 +
       '    begin' + #13#10 +
       '      Result := ''SELECT '' + FSelect + '' FROM '' + FFrom;' + #13#10 +
       '      if FWhere <> '''' then Result := Result + '' WHERE '' + FWhere;' + #13#10 +
       '      if FOrder <> '''' then Result := Result + '' ORDER BY '' + FOrder;' + #13#10 +
       '    end;' + #13#10 +
       '  end;' + #13#10 +
       'var qb : TQueryBuilder;' + #13#10 +
       'begin' + #13#10 +
       '  qb := TQueryBuilder.Create;' + #13#10 +
       '  try' + #13#10 +
       '    writeln(qb.SelectClause(''name, salary'').FromClause(''employees'').WhereClause(''dept = ''''Eng'''''').OrderByClause(''salary DESC'').BuildQuery);' + #13#10 +
       '  finally qb.Free; end;' + #13#10 +
       'end.',
       ckExactOutput,
       'SELECT name, salary FROM employees WHERE dept = ''Eng'' ORDER BY salary DESC',
       0,0,0, 0, 25),

    Ch(2091, 'Template Method',
       'Implement a report generator using the Template Method pattern.' + #13#10 +
       '  TReport (base): Generate calls Header, Body, Footer' + #13#10 +
       '  TSalesReport: overrides all three' + #13#10 +
       '  TInventoryReport: overrides all three' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    === SALES REPORT ===' + #13#10 +
       '    Q4 Revenue: $61,000' + #13#10 +
       '    === END ===' + #13#10 +
       '    === INVENTORY ===' + #13#10 +
       '    Items in stock: 450' + #13#10 +
       '    === END ===',
       'TReport has Generate that calls Header, Body, Footer as abstract virtual methods.',
       'type' + #13#10 +
       '  TReport = class' + #13#10 +
       '  protected' + #13#10 +
       '    procedure Header; virtual; abstract;' + #13#10 +
       '    procedure Body;   virtual; abstract;' + #13#10 +
       '    procedure Footer; virtual; abstract;' + #13#10 +
       '  public' + #13#10 +
       '    procedure Generate;' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       '  TSalesReport = class(TReport)' + #13#10 +
       '  protected' + #13#10 +
       '    procedure Header; override;' + #13#10 +
       '    procedure Body;   override;' + #13#10 +
       '    procedure Footer; override;' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       '  TInventoryReport = class(TReport)' + #13#10 +
       '  protected' + #13#10 +
       '    procedure Header; override;' + #13#10 +
       '    procedure Body;   override;' + #13#10 +
       '    procedure Footer; override;' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       '// Implement Generate and all overrides' + #13#10 +
       '' + #13#10 +
       'var r : TReport;' + #13#10 +
       'begin' + #13#10 +
       '  r := TSalesReport.Create;' + #13#10 +
       '  try r.Generate; finally r.Free; end;' + #13#10 +
       '  r := TInventoryReport.Create;' + #13#10 +
       '  try r.Generate; finally r.Free; end;' + #13#10 +
       'end.',
       'type' + #13#10 +
       '  TReport = class' + #13#10 +
       '  protected' + #13#10 +
       '    procedure Header; virtual; abstract;' + #13#10 +
       '    procedure Body;   virtual; abstract;' + #13#10 +
       '    procedure Footer; virtual; abstract;' + #13#10 +
       '  public' + #13#10 +
       '    procedure Generate; begin Header; Body; Footer; end;' + #13#10 +
       '  end;' + #13#10 +
       '  TSalesReport = class(TReport)' + #13#10 +
       '  protected' + #13#10 +
       '    procedure Header; override; begin writeln(''=== SALES REPORT ===''); end;' + #13#10 +
       '    procedure Body;   override; begin writeln(''Q4 Revenue: $61,000''); end;' + #13#10 +
       '    procedure Footer; override; begin writeln(''=== END ===''); end;' + #13#10 +
       '  end;' + #13#10 +
       '  TInventoryReport = class(TReport)' + #13#10 +
       '  protected' + #13#10 +
       '    procedure Header; override; begin writeln(''=== INVENTORY ===''); end;' + #13#10 +
       '    procedure Body;   override; begin writeln(''Items in stock: 450''); end;' + #13#10 +
       '    procedure Footer; override; begin writeln(''=== END ===''); end;' + #13#10 +
       '  end;' + #13#10 +
       'var r : TReport;' + #13#10 +
       'begin' + #13#10 +
       '  r := TSalesReport.Create;' + #13#10 +
       '  try r.Generate; finally r.Free; end;' + #13#10 +
       '  r := TInventoryReport.Create;' + #13#10 +
       '  try r.Generate; finally r.Free; end;' + #13#10 +
       'end.',
       ckExactOutput,
       '=== SALES REPORT ===' + #13#10 + 'Q4 Revenue: $61,000' + #13#10 + '=== END ===' + #13#10 +
       '=== INVENTORY ===' + #13#10 + 'Items in stock: 450' + #13#10 + '=== END ===',
       0,0,0, 0, 25),

    Ch(2092, 'Mini State Machine',
       'Implement a finite state machine for a vending machine.' + #13#10 +
       'States: Idle -> HasMoney -> Dispensing -> Idle' + #13#10 +
       '' + #13#10 +
       'Events: InsertCoin, SelectItem, Dispense' + #13#10 +
       '' + #13#10 +
       'Simulate: Insert coin, select item, dispense.' + #13#10 +
       'Expected:' + #13#10 +
       '    State: Idle' + #13#10 +
       '    Coin inserted -> HasMoney' + #13#10 +
       '    Item selected -> Dispensing' + #13#10 +
       '    Item dispensed -> Idle',
       'type TState = (stIdle, stHasMoney, stDispensing). Use case..of on current state.',
       'type' + #13#10 +
       '  TState = (stIdle, stHasMoney, stDispensing);' + #13#10 +
       '  TVendingMachine = class' + #13#10 +
       '  private' + #13#10 +
       '    FState : TState;' + #13#10 +
       '    function StateName: String;' + #13#10 +
       '  public' + #13#10 +
       '    constructor Create;' + #13#10 +
       '    procedure InsertCoin;' + #13#10 +
       '    procedure SelectItem;' + #13#10 +
       '    procedure Dispense;' + #13#10 +
       '  end;' + #13#10 +
       '' + #13#10 +
       '// Implement the state machine' + #13#10 +
       '' + #13#10 +
       'var vm : TVendingMachine;' + #13#10 +
       'begin' + #13#10 +
       '  vm := TVendingMachine.Create;' + #13#10 +
       '  try' + #13#10 +
       '    vm.InsertCoin;' + #13#10 +
       '    vm.SelectItem;' + #13#10 +
       '    vm.Dispense;' + #13#10 +
       '  finally vm.Free; end;' + #13#10 +
       'end.',
       'type' + #13#10 +
       '  TState = (stIdle, stHasMoney, stDispensing);' + #13#10 +
       '  TVendingMachine = class' + #13#10 +
       '  private' + #13#10 +
       '    FState : TState;' + #13#10 +
       '    function StateName: String;' + #13#10 +
       '    begin case FState of stIdle: Result:=''Idle''; stHasMoney: Result:=''HasMoney''; else Result:=''Dispensing''; end; end;' + #13#10 +
       '  public' + #13#10 +
       '    constructor Create; begin FState := stIdle; writeln(''State: '', StateName); end;' + #13#10 +
       '    procedure InsertCoin;' + #13#10 +
       '    begin if FState=stIdle then begin FState:=stHasMoney; writeln(''Coin inserted -> '', StateName); end; end;' + #13#10 +
       '    procedure SelectItem;' + #13#10 +
       '    begin if FState=stHasMoney then begin FState:=stDispensing; writeln(''Item selected -> '', StateName); end; end;' + #13#10 +
       '    procedure Dispense;' + #13#10 +
       '    begin if FState=stDispensing then begin FState:=stIdle; writeln(''Item dispensed -> '', StateName); end; end;' + #13#10 +
       '  end;' + #13#10 +
       'var vm : TVendingMachine;' + #13#10 +
       'begin' + #13#10 +
       '  vm := TVendingMachine.Create;' + #13#10 +
       '  try vm.InsertCoin; vm.SelectItem; vm.Dispense; finally vm.Free; end;' + #13#10 +
       'end.',
       ckExactOutput,
       'State: Idle' + #13#10 + 'Coin inserted -> HasMoney' + #13#10 +
       'Item selected -> Dispensing' + #13#10 + 'Item dispensed -> Idle',
       0,0,0, 0, 30)
  ];
end;

end.
