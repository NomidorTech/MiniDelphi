unit UPythonCurriculum;

// =============================================================================
// Pythia -- Pascal learning environment / ambiente de aprendizado Pascal
// Copyright (C) 2026 Nomidor Software, LLC.
// GPL v3 -- see/veja https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
//
//  UPythonCurriculum.pas  --  Real-world Python curriculum for Pythia
//                             Currículo Python do mundo real para o Pythia
//
//  English:
//    10 lessons built around what makes Python genuinely powerful:
//    list comprehensions, file I/O, JSON, CSV, APIs, data analysis,
//    automation, and writing clean Pythonic code.
//    Assumes Python 3.8+ installed on the system.
//
//  Português:
//    10 lições construídas em torno do que torna o Python genuinamente
//    poderoso: list comprehensions, E/S de arquivos, JSON, CSV, APIs,
//    análise de dados, automação e código Pythônico limpo.
//    Requer Python 3.8+ instalado no sistema.
// =============================================================================

interface

uses ULearnTabBase;

type
  TPythonCurriculum = class(TLearnCurriculumBase)
  protected
    procedure Build; override;
  end;

// =============================================================================
implementation
// =============================================================================

procedure TPythonCurriculum.Build;

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

  // ── LESSON 1 -- Python Basics & f-strings ─────────────────────────────────
  FLessons[0].Number := 1;
  FLessons[0].Title  := 'Python Basics & f-strings';
  FLessons[0].Intro  :=
    'Python is concise. No semicolons, no type declarations, no boilerplate.' + #13#10 +
    '' + #13#10 +
    'The most important output tool is print():' + #13#10 +
    '' + #13#10 +
    '    print("Hello, World!")' + #13#10 +
    '' + #13#10 +
    'f-strings are Python''s most powerful string tool:' + #13#10 +
    '' + #13#10 +
    '    name  = "Alice"' + #13#10 +
    '    score = 98.5' + #13#10 +
    '    print(f"Player {name} scored {score:.1f} points")' + #13#10 +
    '    # Player Alice scored 98.5 points' + #13#10 +
    '' + #13#10 +
    'Format specifiers inside f-strings:' + #13#10 +
    '    {value:.2f}   two decimal places' + #13#10 +
    '    {value:,}     thousands separator   1000 -> 1,000' + #13#10 +
    '    {value:>10}   right-align in 10 chars' + #13#10 +
    '    {value:05d}   zero-pad integer to 5 digits';

  FLessons[0].Challenges := [
    Ch(1001, 'Invoice Line',
       'A product costs 49.99 and the quantity is 3.' + #13#10 +
       'Print this line using an f-string:' + #13#10 +
       '' + #13#10 +
       '    Item: Widget   Qty: 3   Unit: $49.99   Total: $149.97',
       'total = price * qty  then  f"Item: Widget   Qty: {qty}   Unit: ${price:.2f}   Total: ${total:.2f}"',
       'price = 49.99' + #13#10 +
       'qty   = 3' + #13#10 +
       '# Calculate total and print the invoice line',
       'price = 49.99' + #13#10 +
       'qty   = 3' + #13#10 +
       'total = price * qty' + #13#10 +
       'print(f"Item: Widget   Qty: {qty}   Unit: ${price:.2f}   Total: ${total:.2f}")',
       ckExactOutput,
       'Item: Widget   Qty: 3   Unit: $49.99   Total: $149.97',
       0,0,0, 0, 15),

    Ch(1002, 'Temperature Table',
       'Print a Celsius-to-Fahrenheit table for 0, 10, 20, 30, 40, 50°C.' + #13#10 +
       'Formula: F = C * 9/5 + 32' + #13#10 +
       'Each line:   0°C =  32.0°F' + #13#10 +
       'Right-align the Celsius value in 2 characters.',
       'for c in range(0, 51, 10):   f = c*9/5+32   print(f"{c:2}°C = {f:5.1f}°F")',
       'for c in range(0, 51, 10):' + #13#10 +
       '    pass  # calculate and print',
       'for c in range(0, 51, 10):' + #13#10 +
       '    f = c * 9 / 5 + 32' + #13#10 +
       '    print(f"{c:2}°C = {f:5.1f}°F")',
       ckContainsAll,
       ' 0°C =  32.0°F|50°C = 122.0°F',
       0,0,0, 0, 20),

    Ch(1003, 'Progress Bar',
       'Given done=7 and total=10, print a text progress bar:' + #13#10 +
       '' + #13#10 +
       '    Progress: [#######   ] 70%' + #13#10 +
       '' + #13#10 +
       'The bar is always 10 chars wide: # for done, space for remaining.',
       'bar = "#" * done + " " * (total - done)   then   f"Progress: [{bar}] {done*100//total}%"',
       'done  = 7' + #13#10 +
       'total = 10' + #13#10 +
       '# Build the progress bar string',
       'done  = 7' + #13#10 +
       'total = 10' + #13#10 +
       'bar = "#" * done + " " * (total - done)' + #13#10 +
       'print(f"Progress: [{bar}] {done * 100 // total}%")',
       ckExactOutput,
       'Progress: [#######   ] 70%',
       0,0,0, 0, 20)
  ];

  // ── LESSON 2 -- List Comprehensions ───────────────────────────────────────
  FLessons[1].Number := 2;
  FLessons[1].Title  := 'List Comprehensions';
  FLessons[1].Intro  :=
    'List comprehensions are Python''s most distinctive feature.' + #13#10 +
    'They replace 4-line for loops with a single readable expression.' + #13#10 +
    '' + #13#10 +
    'Basic form:' + #13#10 +
    '    squares = [x**2 for x in range(10)]' + #13#10 +
    '    # [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]' + #13#10 +
    '' + #13#10 +
    'With a filter condition:' + #13#10 +
    '    evens = [x for x in range(20) if x % 2 == 0]' + #13#10 +
    '    # [0, 2, 4, 6, 8, 10, 12, 14, 16, 18]' + #13#10 +
    '' + #13#10 +
    'Transforming strings:' + #13#10 +
    '    names = ["alice", "bob", "carol"]' + #13#10 +
    '    upper = [n.upper() for n in names]' + #13#10 +
    '    # ["ALICE", "BOB", "CAROL"]' + #13#10 +
    '' + #13#10 +
    'Nested: flatten a 2D list' + #13#10 +
    '    matrix = [[1,2],[3,4],[5,6]]' + #13#10 +
    '    flat = [n for row in matrix for n in row]' + #13#10 +
    '    # [1, 2, 3, 4, 5, 6]';

  FLessons[1].Challenges := [
    Ch(1010, 'Squares of Odds',
       'Using a list comprehension, create a list of the squares of all' + #13#10 +
       'odd numbers from 1 to 19 (inclusive).' + #13#10 +
       'Print the list.' + #13#10 +
       'Expected: [1, 9, 25, 49, 81, 121, 169, 225, 289, 361]',
       '[x**2 for x in range(1, 20) if x % 2 != 0]',
       'result = []  # replace with a list comprehension',
       'result = [x**2 for x in range(1, 20) if x % 2 != 0]' + #13#10 +
       'print(result)',
       ckExactOutput,
       '[1, 9, 25, 49, 81, 121, 169, 225, 289, 361]',
       0,0,0, 0, 15),

    Ch(1011, 'Email Validator',
       'Given a list of strings, keep only the ones that contain "@" and "."' + #13#10 +
       'Use a list comprehension with two conditions.' + #13#10 +
       'Print the valid emails, one per line.' + #13#10 +
       'Expected output:' + #13#10 +
       '    alice@example.com' + #13#10 +
       '    bob@test.org',
       '[e for e in emails if "@" in e and "." in e]   then loop and print',
       'emails = ["alice@example.com", "notanemail", "bob@test.org", "missing-at.com", "@nodomain"]' + #13#10 +
       '# Filter valid emails with a list comprehension',
       'emails = ["alice@example.com", "notanemail", "bob@test.org", "missing-at.com", "@nodomain"]' + #13#10 +
       'valid = [e for e in emails if "@" in e and "." in e]' + #13#10 +
       'for e in valid:' + #13#10 +
       '    print(e)',
       ckExactOutput,
       'alice@example.com' + #13#10 + 'bob@test.org',
       0,0,0, 0, 20),

    Ch(1012, 'Word Lengths',
       'Given the sentence below, create a list of (word, length) tuples' + #13#10 +
       'for words longer than 4 characters. Print each tuple.' + #13#10 +
       '' + #13#10 +
       'sentence = "The quick brown fox jumps over the lazy dog"' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    (''quick'', 5)' + #13#10 +
       '    (''brown'', 5)' + #13#10 +
       '    (''jumps'', 5)' + #13#10 +
       '    (''over'', 4)  <- NOT included (not > 4)' + #13#10 +
       '    (''lazy'', 4)  <- NOT included',
       '[(w, len(w)) for w in sentence.split() if len(w) > 4]',
       'sentence = "The quick brown fox jumps over the lazy dog"' + #13#10 +
       '# Create list of (word, length) tuples for words longer than 4 chars',
       'sentence = "The quick brown fox jumps over the lazy dog"' + #13#10 +
       'result = [(w, len(w)) for w in sentence.split() if len(w) > 4]' + #13#10 +
       'for item in result:' + #13#10 +
       '    print(item)',
       ckContainsAll,
       'quick|brown|jumps',
       0,0,0, 0, 20)
  ];

  // ── LESSON 3 -- Dictionaries & Data Structures ────────────────────────────
  FLessons[2].Number := 3;
  FLessons[2].Title  := 'Dictionaries & Real Data';
  FLessons[2].Intro  :=
    'Python dictionaries are the backbone of real-world data.' + #13#10 +
    'JSON, APIs, config files — they all map to dicts.' + #13#10 +
    '' + #13#10 +
    'A list of dicts models a database table:' + #13#10 +
    '' + #13#10 +
    '    employees = [' + #13#10 +
    '        {"name": "Alice", "dept": "Eng",   "salary": 95000},' + #13#10 +
    '        {"name": "Bob",   "dept": "Sales", "salary": 72000},' + #13#10 +
    '        {"name": "Carol", "dept": "Eng",   "salary": 88000},' + #13#10 +
    '    ]' + #13#10 +
    '' + #13#10 +
    'Filter, sort, aggregate with comprehensions:' + #13#10 +
    '' + #13#10 +
    '    eng = [e for e in employees if e["dept"] == "Eng"]' + #13#10 +
    '    avg = sum(e["salary"] for e in eng) / len(eng)' + #13#10 +
    '' + #13#10 +
    'Sort a list of dicts:' + #13#10 +
    '    sorted_by_salary = sorted(employees, key=lambda e: e["salary"], reverse=True)' + #13#10 +
    '' + #13#10 +
    'Group by key using defaultdict:' + #13#10 +
    '    from collections import defaultdict' + #13#10 +
    '    by_dept = defaultdict(list)' + #13#10 +
    '    for e in employees:' + #13#10 +
    '        by_dept[e["dept"]].append(e["name"])';

  FLessons[2].Challenges := [
    Ch(1020, 'Highest Salary',
       'Given the employees list below, print the name and salary of the' + #13#10 +
       'highest-paid employee.' + #13#10 +
       'Expected: Carol earns $102000',
       'max() with key=lambda e: e["salary"]   or   sorted(..., reverse=True)[0]',
       'employees = [' + #13#10 +
       '    {"name": "Alice", "dept": "Eng",     "salary": 95000},' + #13#10 +
       '    {"name": "Bob",   "dept": "Sales",   "salary": 72000},' + #13#10 +
       '    {"name": "Carol", "dept": "Eng",     "salary": 102000},' + #13#10 +
       '    {"name": "Dave",  "dept": "Support", "salary": 61000},' + #13#10 +
       ']' + #13#10 +
       '# Find the highest paid employee',
       'employees = [' + #13#10 +
       '    {"name": "Alice", "dept": "Eng",     "salary": 95000},' + #13#10 +
       '    {"name": "Bob",   "dept": "Sales",   "salary": 72000},' + #13#10 +
       '    {"name": "Carol", "dept": "Eng",     "salary": 102000},' + #13#10 +
       '    {"name": "Dave",  "dept": "Support", "salary": 61000},' + #13#10 +
       ']' + #13#10 +
       'top = max(employees, key=lambda e: e["salary"])' + #13#10 +
       'print(f"{top[''name'']} earns ${top[''salary'']}")',
       ckExactOutput, 'Carol earns $102000', 0,0,0, 0, 15),

    Ch(1021, 'Department Average',
       'Using the same employees list, calculate and print the average salary' + #13#10 +
       'for the "Eng" department only.' + #13#10 +
       'Round to the nearest dollar.' + #13#10 +
       'Expected: Eng average salary: $98500',
       'eng = [e for e in employees if e["dept"] == "Eng"]   avg = sum(...)/len(...)',
       'employees = [' + #13#10 +
       '    {"name": "Alice", "dept": "Eng",     "salary": 95000},' + #13#10 +
       '    {"name": "Bob",   "dept": "Sales",   "salary": 72000},' + #13#10 +
       '    {"name": "Carol", "dept": "Eng",     "salary": 102000},' + #13#10 +
       '    {"name": "Dave",  "dept": "Support", "salary": 61000},' + #13#10 +
       ']' + #13#10 +
       '# Filter to Eng only, then compute average',
       'employees = [' + #13#10 +
       '    {"name": "Alice", "dept": "Eng",     "salary": 95000},' + #13#10 +
       '    {"name": "Bob",   "dept": "Sales",   "salary": 72000},' + #13#10 +
       '    {"name": "Carol", "dept": "Eng",     "salary": 102000},' + #13#10 +
       '    {"name": "Dave",  "dept": "Support", "salary": 61000},' + #13#10 +
       ']' + #13#10 +
       'eng = [e for e in employees if e["dept"] == "Eng"]' + #13#10 +
       'avg = round(sum(e["salary"] for e in eng) / len(eng))' + #13#10 +
       'print(f"Eng average salary: ${avg}")',
       ckExactOutput, 'Eng average salary: $98500', 0,0,0, 0, 20),

    Ch(1022, 'Leaderboard',
       'Sort the players by score descending and print a numbered leaderboard.' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    1. Carol   9850' + #13#10 +
       '    2. Alice   8720' + #13#10 +
       '    3. Dave    7100' + #13#10 +
       '    4. Bob     6540',
       'sorted(players, key=lambda p: p["score"], reverse=True)   then enumerate(..., 1)',
       'players = [' + #13#10 +
       '    {"name": "Alice", "score": 8720},' + #13#10 +
       '    {"name": "Bob",   "score": 6540},' + #13#10 +
       '    {"name": "Carol", "score": 9850},' + #13#10 +
       '    {"name": "Dave",  "score": 7100},' + #13#10 +
       ']' + #13#10 +
       '# Sort and print numbered leaderboard',
       'players = [' + #13#10 +
       '    {"name": "Alice", "score": 8720},' + #13#10 +
       '    {"name": "Bob",   "score": 6540},' + #13#10 +
       '    {"name": "Carol", "score": 9850},' + #13#10 +
       '    {"name": "Dave",  "score": 7100},' + #13#10 +
       ']' + #13#10 +
       'ranked = sorted(players, key=lambda p: p["score"], reverse=True)' + #13#10 +
       'for i, p in enumerate(ranked, 1):' + #13#10 +
       '    print(f"{i}. {p[''name'']:<8} {p[''score'']}")',
       ckContainsAll,
       '1. Carol|2. Alice|3. Dave|4. Bob',
       0,0,0, 0, 20)
  ];

  // ── LESSON 4 -- Functions & Functional Python ──────────────────────────────
  FLessons[3].Number := 4;
  FLessons[3].Title  := 'Functions & Functional Python';
  FLessons[3].Intro  :=
    'Python functions are first-class objects — you can pass them around.' + #13#10 +
    '' + #13#10 +
    'Lambda (anonymous) functions:' + #13#10 +
    '    double = lambda x: x * 2' + #13#10 +
    '    print(double(5))   # 10' + #13#10 +
    '' + #13#10 +
    'map() applies a function to every element:' + #13#10 +
    '    prices  = [10.5, 20.0, 8.75]' + #13#10 +
    '    doubled = list(map(lambda p: p * 2, prices))' + #13#10 +
    '' + #13#10 +
    'filter() keeps elements where function returns True:' + #13#10 +
    '    big = list(filter(lambda p: p > 10, prices))' + #13#10 +
    '' + #13#10 +
    'reduce() folds a list to a single value (from functools):' + #13#10 +
    '    from functools import reduce' + #13#10 +
    '    product = reduce(lambda a, b: a * b, [1,2,3,4,5])  # 120' + #13#10 +
    '' + #13#10 +
    'zip() combines two lists in lockstep:' + #13#10 +
    '    names  = ["Alice", "Bob"]' + #13#10 +
    '    scores = [95, 82]' + #13#10 +
    '    for name, score in zip(names, scores):' + #13#10 +
    '        print(f"{name}: {score}")';

  FLessons[3].Challenges := [
    Ch(1030, 'Price with Tax',
       'Given a list of prices, use map() to apply 8.5% tax to each.' + #13#10 +
       'Print each taxed price rounded to 2 decimal places, one per line.' + #13#10 +
       'Expected:' + #13#10 +
       '    10.85' + #13#10 +
       '    21.70' + #13#10 +
       '    9.49',
       'list(map(lambda p: round(p * 1.085, 2), prices))',
       'prices = [10.0, 20.0, 8.75]' + #13#10 +
       '# Apply 8.5% tax using map()',
       'prices = [10.0, 20.0, 8.75]' + #13#10 +
       'taxed = list(map(lambda p: round(p * 1.085, 2), prices))' + #13#10 +
       'for p in taxed:' + #13#10 +
       '    print(p)',
       ckExactOutput, '10.85' + #13#10 + '21.7' + #13#10 + '9.49',
       0,0,0, 0, 15),

    Ch(1031, 'Zip to Dict',
       'Combine two lists into a dictionary using zip() and dict().' + #13#10 +
       'Then print each key: value pair.' + #13#10 +
       '' + #13#10 +
       'Expected (any order):' + #13#10 +
       '    CPU: Intel i9' + #13#10 +
       '    RAM: 64GB' + #13#10 +
       '    GPU: RTX 4090' + #13#10 +
       '    SSD: 2TB',
       'specs = dict(zip(keys, values))   then for k, v in specs.items(): print(f"{k}: {v}")',
       'keys   = ["CPU", "RAM", "GPU", "SSD"]' + #13#10 +
       'values = ["Intel i9", "64GB", "RTX 4090", "2TB"]' + #13#10 +
       '# Combine into a dict and print',
       'keys   = ["CPU", "RAM", "GPU", "SSD"]' + #13#10 +
       'values = ["Intel i9", "64GB", "RTX 4090", "2TB"]' + #13#10 +
       'specs  = dict(zip(keys, values))' + #13#10 +
       'for k, v in specs.items():' + #13#10 +
       '    print(f"{k}: {v}")',
       ckContainsAll,
       'CPU: Intel i9|RAM: 64GB|GPU: RTX 4090|SSD: 2TB',
       0,0,0, 0, 20),

    Ch(1032, 'Pipeline',
       'Process a list of raw strings through a pipeline:' + #13#10 +
       '  1. Strip whitespace from each string' + #13#10 +
       '  2. Keep only strings longer than 3 characters' + #13#10 +
       '  3. Convert to uppercase' + #13#10 +
       'Print each result, one per line.' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    PYTHON' + #13#10 +
       '    PROGRAMMING' + #13#10 +
       '    ROCKS',
       'Use map and filter, or chain list comprehensions.',
       'raw = ["  python  ", "ok", " programming", "  rocks ", "no"]' + #13#10 +
       '# Strip, filter length > 3, uppercase',
       'raw = ["  python  ", "ok", " programming", "  rocks ", "no"]' + #13#10 +
       'stripped = map(str.strip, raw)' + #13#10 +
       'filtered = filter(lambda s: len(s) > 3, stripped)' + #13#10 +
       'result   = map(str.upper, filtered)' + #13#10 +
       'for item in result:' + #13#10 +
       '    print(item)',
       ckExactOutput,
       'PYTHON' + #13#10 + 'PROGRAMMING' + #13#10 + 'ROCKS',
       0,0,0, 0, 25)
  ];

  // ── LESSON 5 -- File I/O & CSV ─────────────────────────────────────────────
  FLessons[4].Number := 5;
  FLessons[4].Title  := 'File I/O & CSV';
  FLessons[4].Intro  :=
    'Reading and writing files is one of Python''s most common tasks.' + #13#10 +
    '' + #13#10 +
    'Reading a text file:' + #13#10 +
    '    with open("data.txt") as f:' + #13#10 +
    '        content = f.read()          # entire file as string' + #13#10 +
    '        lines   = f.readlines()     # list of lines' + #13#10 +
    '    # "with" closes the file automatically' + #13#10 +
    '' + #13#10 +
    'Writing a text file:' + #13#10 +
    '    with open("output.txt", "w") as f:' + #13#10 +
    '        f.write("Hello\n")' + #13#10 +
    '        f.write("World\n")' + #13#10 +
    '' + #13#10 +
    'CSV with the csv module:' + #13#10 +
    '    import csv' + #13#10 +
    '    with open("sales.csv", "w", newline="") as f:' + #13#10 +
    '        w = csv.writer(f)' + #13#10 +
    '        w.writerow(["Date", "Product", "Revenue"])' + #13#10 +
    '        w.writerow(["2026-01", "Widget", 15000])' + #13#10 +
    '' + #13#10 +
    'Reading CSV into a list of dicts:' + #13#10 +
    '    with open("sales.csv") as f:' + #13#10 +
    '        rows = list(csv.DictReader(f))' + #13#10 +
    '    # rows[0] == {"Date": "2026-01", "Product": "Widget", "Revenue": "15000"}';

  FLessons[4].Challenges := [
    Ch(1040, 'Write & Read',
       'Write the numbers 1 to 5 to a file called "numbers.txt" (one per line).' + #13#10 +
       'Then read it back and print the sum of all numbers.' + #13#10 +
       'Expected: 15',
       'Write with open("numbers.txt","w"), read back with open(...).readlines()',
       '# Write numbers 1-5 to numbers.txt, then read and sum them',
       'with open("numbers.txt", "w") as f:' + #13#10 +
       '    for i in range(1, 6):' + #13#10 +
       '        f.write(f"{i}\n")' + #13#10 +
       '' + #13#10 +
       'with open("numbers.txt") as f:' + #13#10 +
       '    total = sum(int(line.strip()) for line in f)' + #13#10 +
       'print(total)',
       ckExactOutput, '15', 0,0,0, 0, 15),

    Ch(1041, 'CSV Writer',
       'Create a CSV file called "products.csv" with these 3 products:' + #13#10 +
       '' + #13#10 +
       '    Name,Price,Stock' + #13#10 +
       '    Keyboard,79.99,150' + #13#10 +
       '    Mouse,29.99,300' + #13#10 +
       '    Monitor,399.99,45' + #13#10 +
       '' + #13#10 +
       'Then read it back and print the total value of all stock.' + #13#10 +
       '(Total = sum of Price * Stock for each product)' + #13#10 +
       'Expected: 38024.55',
       'csv.writer to write, csv.DictReader to read back. Convert price and stock to float/int.',
       'import csv' + #13#10 +
       '' + #13#10 +
       'products = [' + #13#10 +
       '    ["Keyboard", 79.99,  150],' + #13#10 +
       '    ["Mouse",    29.99,  300],' + #13#10 +
       '    ["Monitor",  399.99, 45],' + #13#10 +
       ']' + #13#10 +
       '# Write to CSV then read back and calculate total stock value',
       'import csv' + #13#10 +
       '' + #13#10 +
       'products = [' + #13#10 +
       '    ["Keyboard", 79.99,  150],' + #13#10 +
       '    ["Mouse",    29.99,  300],' + #13#10 +
       '    ["Monitor",  399.99, 45],' + #13#10 +
       ']' + #13#10 +
       '' + #13#10 +
       'with open("products.csv", "w", newline="") as f:' + #13#10 +
       '    w = csv.writer(f)' + #13#10 +
       '    w.writerow(["Name", "Price", "Stock"])' + #13#10 +
       '    w.writerows(products)' + #13#10 +
       '' + #13#10 +
       'with open("products.csv") as f:' + #13#10 +
       '    rows  = list(csv.DictReader(f))' + #13#10 +
       '    total = sum(float(r["Price"]) * int(r["Stock"]) for r in rows)' + #13#10 +
       'print(round(total, 2))',
       ckExactOutput, '38024.55', 0,0,0, 0, 25),

    Ch(1042, 'Log Parser',
       'Parse a log file and count how many lines contain each log level.' + #13#10 +
       'Write the log first, then parse it.' + #13#10 +
       '' + #13#10 +
       'Expected output (sorted alphabetically):' + #13#10 +
       '    ERROR: 2' + #13#10 +
       '    INFO: 4' + #13#10 +
       '    WARNING: 1',
       'Write lines, then use a dict to count. Check if "INFO" in line etc.',
       'log_lines = [' + #13#10 +
       '    "2026-01-01 INFO  Server started",' + #13#10 +
       '    "2026-01-01 INFO  Connected 5 clients",' + #13#10 +
       '    "2026-01-01 WARNING  High memory usage",' + #13#10 +
       '    "2026-01-01 ERROR  Connection timeout",' + #13#10 +
       '    "2026-01-01 INFO  Backup complete",' + #13#10 +
       '    "2026-01-01 ERROR  Disk full",' + #13#10 +
       '    "2026-01-01 INFO  Server stopped",' + #13#10 +
       ']' + #13#10 +
       '# Count occurrences of each log level',
       'log_lines = [' + #13#10 +
       '    "2026-01-01 INFO  Server started",' + #13#10 +
       '    "2026-01-01 INFO  Connected 5 clients",' + #13#10 +
       '    "2026-01-01 WARNING  High memory usage",' + #13#10 +
       '    "2026-01-01 ERROR  Connection timeout",' + #13#10 +
       '    "2026-01-01 INFO  Backup complete",' + #13#10 +
       '    "2026-01-01 ERROR  Disk full",' + #13#10 +
       '    "2026-01-01 INFO  Server stopped",' + #13#10 +
       ']' + #13#10 +
       '' + #13#10 +
       'counts = {}' + #13#10 +
       'for line in log_lines:' + #13#10 +
       '    for level in ["INFO", "WARNING", "ERROR"]:' + #13#10 +
       '        if level in line:' + #13#10 +
       '            counts[level] = counts.get(level, 0) + 1' + #13#10 +
       '' + #13#10 +
       'for level in sorted(counts):' + #13#10 +
       '    print(f"{level}: {counts[level]}")',
       ckExactOutput,
       'ERROR: 2' + #13#10 + 'INFO: 4' + #13#10 + 'WARNING: 1',
       0,0,0, 0, 25)
  ];

  // ── LESSON 6 -- JSON & APIs ────────────────────────────────────────────────
  FLessons[5].Number := 6;
  FLessons[5].Title  := 'JSON & Working with APIs';
  FLessons[5].Intro  :=
    'JSON is the universal language of web APIs. Python handles it natively.' + #13#10 +
    '' + #13#10 +
    'JSON to Python (parsing):' + #13#10 +
    '    import json' + #13#10 +
    '    text = ''{"name": "Alice", "age": 30, "skills": ["Python", "SQL"]}''' + #13#10 +
    '    data = json.loads(text)     # string -> dict' + #13#10 +
    '    print(data["skills"][0])    # Python' + #13#10 +
    '' + #13#10 +
    'Python to JSON (serializing):' + #13#10 +
    '    payload = {"query": "Pythia", "limit": 10}' + #13#10 +
    '    text = json.dumps(payload, indent=2)' + #13#10 +
    '' + #13#10 +
    'Reading a JSON file:' + #13#10 +
    '    with open("config.json") as f:' + #13#10 +
    '        config = json.load(f)' + #13#10 +
    '' + #13#10 +
    'Calling a real API with requests (if installed):' + #13#10 +
    '    import requests' + #13#10 +
    '    r    = requests.get("https://api.github.com/users/python")' + #13#10 +
    '    data = r.json()' + #13#10 +
    '    print(data["public_repos"])' + #13#10 +
    '' + #13#10 +
    'The exercises below use json.loads() with sample data' + #13#10 +
    'so no internet connection is required.';

  FLessons[5].Challenges := [
    Ch(1050, 'Parse JSON',
       'Parse the JSON string below and print the total of all order amounts.' + #13#10 +
       'Expected: Total orders: $1847.50',
       'json.loads(text) gives a list of dicts. Sum the "amount" values.',
       'import json' + #13#10 +
       '' + #13#10 +
       'text = ''[''' + #13#10 +
       '    {"id": 1, "item": "Laptop",  "amount": 1299.99},' + #13#10 +
       '    {"id": 2, "item": "Mouse",   "amount":   29.99},' + #13#10 +
       '    {"id": 3, "item": "Headset", "amount":  249.99},' + #13#10 +
       '    {"id": 4, "item": "Webcam",  "amount":  267.53}' + #13#10 +
       ']''' + #13#10 +
       '# Parse and sum the amounts',
       'import json' + #13#10 +
       '' + #13#10 +
       'text = ''[{"id":1,"item":"Laptop","amount":1299.99},{"id":2,"item":"Mouse","amount":29.99},{"id":3,"item":"Headset","amount":249.99},{"id":4,"item":"Webcam","amount":267.53}]''' + #13#10 +
       'orders = json.loads(text)' + #13#10 +
       'total  = sum(o["amount"] for o in orders)' + #13#10 +
       'print(f"Total orders: ${total:.2f}")',
       ckExactOutput, 'Total orders: $1847.50', 0,0,0, 0, 15),

    Ch(1051, 'JSON Config',
       'Write a config dict to a JSON file, then read it back and' + #13#10 +
       'print the database host and port on one line.' + #13#10 +
       'Expected: Database: db.example.com:5432',
       'json.dump() to write, json.load() to read back.',
       'import json' + #13#10 +
       '' + #13#10 +
       'config = {' + #13#10 +
       '    "app": "MyService",' + #13#10 +
       '    "version": "2.1.0",' + #13#10 +
       '    "database": {' + #13#10 +
       '        "host": "db.example.com",' + #13#10 +
       '        "port": 5432,' + #13#10 +
       '        "name": "production"' + #13#10 +
       '    }' + #13#10 +
       '}' + #13#10 +
       '# Write to config.json then read back and print host:port',
       'import json' + #13#10 +
       '' + #13#10 +
       'config = {"app":"MyService","version":"2.1.0","database":{"host":"db.example.com","port":5432,"name":"production"}}' + #13#10 +
       '' + #13#10 +
       'with open("config.json", "w") as f:' + #13#10 +
       '    json.dump(config, f)' + #13#10 +
       '' + #13#10 +
       'with open("config.json") as f:' + #13#10 +
       '    c = json.load(f)' + #13#10 +
       '' + #13#10 +
       'db = c["database"]' + #13#10 +
       'print(f"Database: {db[''host'']}:{db[''port'']}")',
       ckExactOutput, 'Database: db.example.com:5432', 0,0,0, 0, 20),

    Ch(1052, 'Flatten Nested JSON',
       'Given the nested JSON structure below, extract all product names' + #13#10 +
       'from ALL categories and print them sorted alphabetically.' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    Espresso Machine' + #13#10 +
       '    Laptop Stand' + #13#10 +
       '    Mechanical Keyboard' + #13#10 +
       '    Wireless Mouse',
       'for cat in data["categories"]:   for product in cat["products"]:   names.append(...)',
       'import json' + #13#10 +
       '' + #13#10 +
       'data = json.loads(''{"categories":[{"name":"Electronics","products":[{"id":1,"name":"Wireless Mouse"},{"id":2,"name":"Mechanical Keyboard"}]},{"name":"Office","products":[{"id":3,"name":"Laptop Stand"},{"id":4,"name":"Espresso Machine"}]}]}'')' + #13#10 +
       '# Extract all product names and print sorted',
       'import json' + #13#10 +
       '' + #13#10 +
       'data = json.loads(''{"categories":[{"name":"Electronics","products":[{"id":1,"name":"Wireless Mouse"},{"id":2,"name":"Mechanical Keyboard"}]},{"name":"Office","products":[{"id":3,"name":"Laptop Stand"},{"id":4,"name":"Espresso Machine"}]}]}'')' + #13#10 +
       'names = [p["name"] for cat in data["categories"] for p in cat["products"]]' + #13#10 +
       'for name in sorted(names):' + #13#10 +
       '    print(name)',
       ckExactOutput,
       'Espresso Machine' + #13#10 + 'Laptop Stand' + #13#10 +
       'Mechanical Keyboard' + #13#10 + 'Wireless Mouse',
       0,0,0, 0, 25)
  ];

  // ── LESSON 7 -- Classes & OOP ─────────────────────────────────────────────
  FLessons[6].Number := 7;
  FLessons[6].Title  := 'Classes & OOP';
  FLessons[6].Intro  :=
    'Python classes are concise and powerful.' + #13#10 +
    '' + #13#10 +
    '    class BankAccount:' + #13#10 +
    '        def __init__(self, owner, balance=0):' + #13#10 +
    '            self.owner   = owner' + #13#10 +
    '            self.balance = balance' + #13#10 +
    '' + #13#10 +
    '        def deposit(self, amount):' + #13#10 +
    '            self.balance += amount' + #13#10 +
    '' + #13#10 +
    '        def withdraw(self, amount):' + #13#10 +
    '            if amount > self.balance:' + #13#10 +
    '                raise ValueError("Insufficient funds")' + #13#10 +
    '            self.balance -= amount' + #13#10 +
    '' + #13#10 +
    '        def __str__(self):' + #13#10 +
    '            return f"Account({self.owner}): ${self.balance:.2f}"' + #13#10 +
    '' + #13#10 +
    'Key dunder methods:' + #13#10 +
    '    __init__   constructor' + #13#10 +
    '    __str__    print() representation' + #13#10 +
    '    __len__    len() support' + #13#10 +
    '    __eq__     == operator' + #13#10 +
    '    __lt__     < operator (enables sorting)' + #13#10 +
    '' + #13#10 +
    '@dataclass (Python 3.7+) generates boilerplate automatically:' + #13#10 +
    '    from dataclasses import dataclass' + #13#10 +
    '    @dataclass' + #13#10 +
    '    class Point:' + #13#10 +
    '        x: float' + #13#10 +
    '        y: float';

  FLessons[6].Challenges := [
    Ch(1060, 'Bank Account',
       'Create a BankAccount class with deposit() and withdraw() methods.' + #13#10 +
       'Start with balance 1000. Deposit 500. Withdraw 200.' + #13#10 +
       'Print the final balance.' + #13#10 +
       'Expected: Balance: $1300.00',
       '__init__(self, balance)   deposit adds   withdraw subtracts',
       'class BankAccount:' + #13#10 +
       '    def __init__(self, balance):' + #13#10 +
       '        self.balance = balance' + #13#10 +
       '' + #13#10 +
       '    # Add deposit() and withdraw() methods' + #13#10 +
       '' + #13#10 +
       'acc = BankAccount(1000)' + #13#10 +
       '# deposit 500, withdraw 200, print balance',
       'class BankAccount:' + #13#10 +
       '    def __init__(self, balance):' + #13#10 +
       '        self.balance = balance' + #13#10 +
       '    def deposit(self, amount):' + #13#10 +
       '        self.balance += amount' + #13#10 +
       '    def withdraw(self, amount):' + #13#10 +
       '        self.balance -= amount' + #13#10 +
       '' + #13#10 +
       'acc = BankAccount(1000)' + #13#10 +
       'acc.deposit(500)' + #13#10 +
       'acc.withdraw(200)' + #13#10 +
       'print(f"Balance: ${acc.balance:.2f}")',
       ckExactOutput, 'Balance: $1300.00', 0,0,0, 0, 15),

    Ch(1061, 'Sortable Cards',
       'Create a Card class with suit and value.' + #13#10 +
       'Add __str__ and __lt__ so cards can be printed and sorted.' + #13#10 +
       'Sort and print the hand below.' + #13#10 +
       '' + #13#10 +
       'Expected order (by value then suit):' + #13#10 +
       '    2 of Clubs' + #13#10 +
       '    5 of Hearts' + #13#10 +
       '    9 of Spades' + #13#10 +
       '    Ace of Diamonds',
       '__lt__(self, other): return self.value < other.value',
       'class Card:' + #13#10 +
       '    def __init__(self, value, suit):' + #13#10 +
       '        self.value = value' + #13#10 +
       '        self.suit  = suit' + #13#10 +
       '    # Add __str__ and __lt__' + #13#10 +
       '' + #13#10 +
       'ORDER = {"2":2,"5":5,"9":9,"Ace":14}' + #13#10 +
       'hand = [Card("9","Spades"), Card("Ace","Diamonds"), Card("2","Clubs"), Card("5","Hearts")]' + #13#10 +
       '# Sort and print',
       'class Card:' + #13#10 +
       '    def __init__(self, value, suit):' + #13#10 +
       '        self.value = value' + #13#10 +
       '        self.suit  = suit' + #13#10 +
       '    def __str__(self):' + #13#10 +
       '        return f"{self.value} of {self.suit}"' + #13#10 +
       '    def __lt__(self, other):' + #13#10 +
       '        ORDER = {"2":2,"5":5,"9":9,"Ace":14}' + #13#10 +
       '        return ORDER[self.value] < ORDER[other.value]' + #13#10 +
       '' + #13#10 +
       'hand = [Card("9","Spades"), Card("Ace","Diamonds"), Card("2","Clubs"), Card("5","Hearts")]' + #13#10 +
       'for card in sorted(hand):' + #13#10 +
       '    print(card)',
       ckExactOutput,
       '2 of Clubs' + #13#10 + '5 of Hearts' + #13#10 +
       '9 of Spades' + #13#10 + 'Ace of Diamonds',
       0,0,0, 0, 25),

    Ch(1062, 'Inventory System',
       'Build a simple Inventory class that:' + #13#10 +
       '  - Stores items as a dict {name: quantity}' + #13#10 +
       '  - add(name, qty) adds stock' + #13#10 +
       '  - sell(name, qty) reduces stock (raise ValueError if not enough)' + #13#10 +
       '  - report() prints each item sorted by name: "Keyboard: 45"' + #13#10 +
       '' + #13#10 +
       'Expected output:' + #13#10 +
       '    Keyboard: 45' + #13#10 +
       '    Monitor: 8' + #13#10 +
       '    Mouse: 98',
       'self.items = {}   add does items[name] = items.get(name,0) + qty',
       'class Inventory:' + #13#10 +
       '    def __init__(self):' + #13#10 +
       '        self.items = {}' + #13#10 +
       '    # add add() sell() report() methods' + #13#10 +
       '' + #13#10 +
       'inv = Inventory()' + #13#10 +
       'inv.add("Keyboard", 50)' + #13#10 +
       'inv.add("Mouse", 100)' + #13#10 +
       'inv.add("Monitor", 10)' + #13#10 +
       'inv.sell("Keyboard", 5)' + #13#10 +
       'inv.sell("Mouse", 2)' + #13#10 +
       'inv.sell("Monitor", 2)' + #13#10 +
       'inv.report()',
       'class Inventory:' + #13#10 +
       '    def __init__(self):' + #13#10 +
       '        self.items = {}' + #13#10 +
       '    def add(self, name, qty):' + #13#10 +
       '        self.items[name] = self.items.get(name, 0) + qty' + #13#10 +
       '    def sell(self, name, qty):' + #13#10 +
       '        if self.items.get(name, 0) < qty:' + #13#10 +
       '            raise ValueError(f"Not enough {name}")' + #13#10 +
       '        self.items[name] -= qty' + #13#10 +
       '    def report(self):' + #13#10 +
       '        for k in sorted(self.items):' + #13#10 +
       '            print(f"{k}: {self.items[k]}")' + #13#10 +
       '' + #13#10 +
       'inv = Inventory()' + #13#10 +
       'inv.add("Keyboard", 50)' + #13#10 +
       'inv.add("Mouse", 100)' + #13#10 +
       'inv.add("Monitor", 10)' + #13#10 +
       'inv.sell("Keyboard", 5)' + #13#10 +
       'inv.sell("Mouse", 2)' + #13#10 +
       'inv.sell("Monitor", 2)' + #13#10 +
       'inv.report()',
       ckExactOutput,
       'Keyboard: 45' + #13#10 + 'Monitor: 8' + #13#10 + 'Mouse: 98',
       0,0,0, 0, 30)
  ];

  // ── LESSON 8 -- Error Handling & Defensive Code ───────────────────────────
  FLessons[7].Number := 8;
  FLessons[7].Title  := 'Error Handling & Defensive Code';
  FLessons[7].Intro  :=
    'Production Python handles errors gracefully.' + #13#10 +
    '' + #13#10 +
    'try / except / finally:' + #13#10 +
    '    try:' + #13#10 +
    '        result = 10 / int(user_input)' + #13#10 +
    '    except ZeroDivisionError:' + #13#10 +
    '        print("Cannot divide by zero")' + #13#10 +
    '    except ValueError as e:' + #13#10 +
    '        print(f"Bad input: {e}")' + #13#10 +
    '    finally:' + #13#10 +
    '        print("Done")   # runs always' + #13#10 +
    '' + #13#10 +
    'Raise your own exceptions:' + #13#10 +
    '    def set_age(age):' + #13#10 +
    '        if age < 0 or age > 150:' + #13#10 +
    '            raise ValueError(f"Invalid age: {age}")' + #13#10 +
    '' + #13#10 +
    'Context managers with "with" (automatic cleanup):' + #13#10 +
    '    with open("file.txt") as f:   # closes automatically even on error' + #13#10 +
    '        data = f.read()' + #13#10 +
    '' + #13#10 +
    'Catching multiple exceptions:' + #13#10 +
    '    except (TypeError, ValueError) as e:' + #13#10 +
    '        print(f"Input error: {e}")';

  FLessons[7].Challenges := [
    Ch(1070, 'Safe Division',
       'Write a function safe_divide(a, b) that:' + #13#10 +
       '  - Returns a / b if b != 0' + #13#10 +
       '  - Returns None if b == 0 (don''t let it crash)' + #13#10 +
       '' + #13#10 +
       'Test it:' + #13#10 +
       '    print(safe_divide(10, 2))    ->  5.0' + #13#10 +
       '    print(safe_divide(7, 0))     ->  None',
       'try: return a/b   except ZeroDivisionError: return None',
       'def safe_divide(a, b):' + #13#10 +
       '    pass  # handle ZeroDivisionError' + #13#10 +
       '' + #13#10 +
       'print(safe_divide(10, 2))' + #13#10 +
       'print(safe_divide(7, 0))',
       'def safe_divide(a, b):' + #13#10 +
       '    try:' + #13#10 +
       '        return a / b' + #13#10 +
       '    except ZeroDivisionError:' + #13#10 +
       '        return None' + #13#10 +
       '' + #13#10 +
       'print(safe_divide(10, 2))' + #13#10 +
       'print(safe_divide(7, 0))',
       ckExactOutput, '5.0' + #13#10 + 'None', 0,0,0, 0, 15),

    Ch(1071, 'Validated Input',
       'Write a function parse_age(s) that converts a string to an integer age.' + #13#10 +
       '  - Raise ValueError with "Not a number" if s is not numeric' + #13#10 +
       '  - Raise ValueError with "Age out of range" if age < 0 or age > 120' + #13#10 +
       '  - Return the integer age if valid' + #13#10 +
       '' + #13#10 +
       'Expected output:' + #13#10 +
       '    25' + #13#10 +
       '    Error: Not a number' + #13#10 +
       '    Error: Age out of range',
       'try: age = int(s)   except ValueError: raise ValueError("Not a number")',
       'def parse_age(s):' + #13#10 +
       '    pass' + #13#10 +
       '' + #13#10 +
       'for test in ["25", "abc", "200"]:' + #13#10 +
       '    try:' + #13#10 +
       '        print(parse_age(test))' + #13#10 +
       '    except ValueError as e:' + #13#10 +
       '        print(f"Error: {e}")',
       'def parse_age(s):' + #13#10 +
       '    try:' + #13#10 +
       '        age = int(s)' + #13#10 +
       '    except ValueError:' + #13#10 +
       '        raise ValueError("Not a number")' + #13#10 +
       '    if age < 0 or age > 120:' + #13#10 +
       '        raise ValueError("Age out of range")' + #13#10 +
       '    return age' + #13#10 +
       '' + #13#10 +
       'for test in ["25", "abc", "200"]:' + #13#10 +
       '    try:' + #13#10 +
       '        print(parse_age(test))' + #13#10 +
       '    except ValueError as e:' + #13#10 +
       '        print(f"Error: {e}")',
       ckExactOutput,
       '25' + #13#10 + 'Error: Not a number' + #13#10 + 'Error: Age out of range',
       0,0,0, 0, 20),

    Ch(1072, 'Retry Logic',
       'Write a function that retries an operation up to 3 times.' + #13#10 +
       'If it fails all 3 times, print "All retries failed."' + #13#10 +
       '' + #13#10 +
       'The function attempt(n) raises ValueError if n < 3.' + #13#10 +
       '' + #13#10 +
       'Expected output:' + #13#10 +
       '    Attempt 1 failed' + #13#10 +
       '    Attempt 2 failed' + #13#10 +
       '    Attempt 3 succeeded',
       'for i in range(1, 4):   try: attempt(i)   except ValueError: print(f"Attempt {i} failed")   else: print(...); break',
       'def attempt(n):' + #13#10 +
       '    if n < 3:' + #13#10 +
       '        raise ValueError("Not ready")' + #13#10 +
       '    # else succeeds' + #13#10 +
       '' + #13#10 +
       '# Try up to 3 times',
       'def attempt(n):' + #13#10 +
       '    if n < 3:' + #13#10 +
       '        raise ValueError("Not ready")' + #13#10 +
       '' + #13#10 +
       'for i in range(1, 4):' + #13#10 +
       '    try:' + #13#10 +
       '        attempt(i)' + #13#10 +
       '    except ValueError:' + #13#10 +
       '        print(f"Attempt {i} failed")' + #13#10 +
       '    else:' + #13#10 +
       '        print(f"Attempt {i} succeeded")' + #13#10 +
       '        break' + #13#10 +
       'else:' + #13#10 +
       '    print("All retries failed.")',
       ckExactOutput,
       'Attempt 1 failed' + #13#10 + 'Attempt 2 failed' + #13#10 + 'Attempt 3 succeeded',
       0,0,0, 0, 25)
  ];

  // ── LESSON 9 -- Generators & Itertools ────────────────────────────────────
  FLessons[8].Number := 9;
  FLessons[8].Title  := 'Generators & itertools';
  FLessons[8].Intro  :=
    'Generators produce values on demand — memory-efficient for large data.' + #13#10 +
    '' + #13#10 +
    'Generator function (uses yield):' + #13#10 +
    '    def countdown(n):' + #13#10 +
    '        while n > 0:' + #13#10 +
    '            yield n' + #13#10 +
    '            n -= 1' + #13#10 +
    '    for x in countdown(3):' + #13#10 +
    '        print(x)    # 3  2  1' + #13#10 +
    '' + #13#10 +
    'Generator expression (like list comprehension but lazy):' + #13#10 +
    '    total = sum(x**2 for x in range(1000000))  # never builds list' + #13#10 +
    '' + #13#10 +
    'itertools — the toolbox for iteration:' + #13#10 +
    '    from itertools import chain, islice, groupby, accumulate' + #13#10 +
    '' + #13#10 +
    '    chain([1,2], [3,4], [5])          # [1,2,3,4,5]' + #13#10 +
    '    islice(range(100), 5)             # first 5: [0,1,2,3,4]' + #13#10 +
    '    list(accumulate([1,2,3,4]))       # [1,3,6,10] running total' + #13#10 +
    '    groupby(sorted_data, key=...)     # group consecutive equal keys';

  FLessons[8].Challenges := [
    Ch(1080, 'Fibonacci Generator',
       'Write a generator function fibonacci() that yields Fibonacci numbers.' + #13#10 +
       'Print the first 10 Fibonacci numbers separated by spaces.' + #13#10 +
       'Expected: 0 1 1 2 3 5 8 13 21 34',
       'a, b = 0, 1   yield a   a, b = b, a+b',
       'def fibonacci():' + #13#10 +
       '    pass  # yield Fibonacci numbers' + #13#10 +
       '' + #13#10 +
       'from itertools import islice' + #13#10 +
       '# Print first 10',
       'def fibonacci():' + #13#10 +
       '    a, b = 0, 1' + #13#10 +
       '    while True:' + #13#10 +
       '        yield a' + #13#10 +
       '        a, b = b, a + b' + #13#10 +
       '' + #13#10 +
       'from itertools import islice' + #13#10 +
       'print(" ".join(str(n) for n in islice(fibonacci(), 10)))',
       ckExactOutput, '0 1 1 2 3 5 8 13 21 34', 0,0,0, 0, 20),

    Ch(1081, 'Running Total',
       'Use itertools.accumulate to compute running totals of monthly sales.' + #13#10 +
       'Print each month and its running total.' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    Jan: 12000' + #13#10 +
       '    Feb: 27500' + #13#10 +
       '    Mar: 45000' + #13#10 +
       '    Apr: 68000',
       'from itertools import accumulate   list(accumulate(sales))',
       'from itertools import accumulate' + #13#10 +
       '' + #13#10 +
       'months = ["Jan", "Feb", "Mar", "Apr"]' + #13#10 +
       'sales  = [12000, 15500, 17500, 23000]' + #13#10 +
       '# Print month: running total',
       'from itertools import accumulate' + #13#10 +
       '' + #13#10 +
       'months   = ["Jan", "Feb", "Mar", "Apr"]' + #13#10 +
       'sales    = [12000, 15500, 17500, 23000]' + #13#10 +
       'running  = list(accumulate(sales))' + #13#10 +
       'for month, total in zip(months, running):' + #13#10 +
       '    print(f"{month}: {total}")',
       ckExactOutput,
       'Jan: 12000' + #13#10 + 'Feb: 27500' + #13#10 +
       'Mar: 45000' + #13#10 + 'Apr: 68000',
       0,0,0, 0, 20),

    Ch(1082, 'Group By Department',
       'Use itertools.groupby to group employees by department.' + #13#10 +
       'Print each department and its member names.' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    Eng: Alice, Carol' + #13#10 +
       '    HR: Eve' + #13#10 +
       '    Sales: Bob, Dave',
       'Sort by dept first (groupby requires sorted input), then groupby(employees, key=lambda e: e["dept"])',
       'from itertools import groupby' + #13#10 +
       '' + #13#10 +
       'employees = [' + #13#10 +
       '    {"name": "Alice", "dept": "Eng"},' + #13#10 +
       '    {"name": "Bob",   "dept": "Sales"},' + #13#10 +
       '    {"name": "Carol", "dept": "Eng"},' + #13#10 +
       '    {"name": "Dave",  "dept": "Sales"},' + #13#10 +
       '    {"name": "Eve",   "dept": "HR"},' + #13#10 +
       ']' + #13#10 +
       '# Group by department and print',
       'from itertools import groupby' + #13#10 +
       '' + #13#10 +
       'employees = [' + #13#10 +
       '    {"name": "Alice", "dept": "Eng"},' + #13#10 +
       '    {"name": "Bob",   "dept": "Sales"},' + #13#10 +
       '    {"name": "Carol", "dept": "Eng"},' + #13#10 +
       '    {"name": "Dave",  "dept": "Sales"},' + #13#10 +
       '    {"name": "Eve",   "dept": "HR"},' + #13#10 +
       ']' + #13#10 +
       '' + #13#10 +
       'sorted_emps = sorted(employees, key=lambda e: e["dept"])' + #13#10 +
       'for dept, group in groupby(sorted_emps, key=lambda e: e["dept"]):' + #13#10 +
       '    names = ", ".join(e["name"] for e in group)' + #13#10 +
       '    print(f"{dept}: {names}")',
       ckExactOutput,
       'Eng: Alice, Carol' + #13#10 + 'HR: Eve' + #13#10 + 'Sales: Bob, Dave',
       0,0,0, 0, 25)
  ];

  // ── LESSON 10 -- Automation & os/pathlib ──────────────────────────────────
  FLessons[9].Number := 10;
  FLessons[9].Title  := 'Automation with os & pathlib';
  FLessons[9].Intro  :=
    'Python is the automation language. These modules handle files and OS.' + #13#10 +
    '' + #13#10 +
    'pathlib (modern, recommended):' + #13#10 +
    '    from pathlib import Path' + #13#10 +
    '    p = Path("C:/data/reports")' + #13#10 +
    '    p.mkdir(parents=True, exist_ok=True)  # create folders' + #13#10 +
    '    files = list(p.glob("*.csv"))         # find all CSVs' + #13#10 +
    '    text  = (p / "report.txt").read_text()' + #13#10 +
    '    (p / "output.txt").write_text("Hello")' + #13#10 +
    '' + #13#10 +
    'os module:' + #13#10 +
    '    import os' + #13#10 +
    '    os.getcwd()                  # current directory' + #13#10 +
    '    os.listdir(".")              # list directory' + #13#10 +
    '    os.rename("old.txt","new.txt")' + #13#10 +
    '    os.path.exists("file.txt")' + #13#10 +
    '' + #13#10 +
    'datetime for timestamps:' + #13#10 +
    '    from datetime import datetime, timedelta' + #13#10 +
    '    now   = datetime.now()' + #13#10 +
    '    stamp = now.strftime("%Y-%m-%d %H:%M")' + #13#10 +
    '    week  = now + timedelta(days=7)';

  FLessons[9].Challenges := [
    Ch(1090, 'File Organizer',
       'Given a list of filenames, group them by extension and print the groups.' + #13#10 +
       'Sort extensions alphabetically, files within each group alphabetically.' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    .csv: data.csv, sales.csv' + #13#10 +
       '    .jpg: photo.jpg' + #13#10 +
       '    .py: main.py, utils.py' + #13#10 +
       '    .txt: notes.txt, readme.txt',
       'Use a dict grouping by os.path.splitext(f)[1]',
       'import os' + #13#10 +
       '' + #13#10 +
       'files = ["main.py", "data.csv", "notes.txt", "photo.jpg",' + #13#10 +
       '         "utils.py", "readme.txt", "sales.csv"]' + #13#10 +
       '# Group by extension and print',
       'import os' + #13#10 +
       '' + #13#10 +
       'files = ["main.py", "data.csv", "notes.txt", "photo.jpg",' + #13#10 +
       '         "utils.py", "readme.txt", "sales.csv"]' + #13#10 +
       '' + #13#10 +
       'groups = {}' + #13#10 +
       'for f in files:' + #13#10 +
       '    ext = os.path.splitext(f)[1]' + #13#10 +
       '    groups.setdefault(ext, []).append(f)' + #13#10 +
       '' + #13#10 +
       'for ext in sorted(groups):' + #13#10 +
       '    names = ", ".join(sorted(groups[ext]))' + #13#10 +
       '    print(f"{ext}: {names}")',
       ckExactOutput,
       '.csv: data.csv, sales.csv' + #13#10 +
       '.jpg: photo.jpg' + #13#10 +
       '.py: main.py, utils.py' + #13#10 +
       '.txt: notes.txt, readme.txt',
       0,0,0, 0, 20),

    Ch(1091, 'Date Calculator',
       'Given a list of project deadlines, print each one with:' + #13#10 +
       '  - How many days until (or since) the deadline from 2026-06-01' + #13#10 +
       '  - Whether it is OVERDUE, TODAY, or UPCOMING' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    Alpha   2026-05-15  17 days ago  OVERDUE' + #13#10 +
       '    Beta    2026-06-01   0 days      TODAY' + #13#10 +
       '    Gamma   2026-06-20  19 days      UPCOMING',
       'from datetime import datetime   delta = deadline - today   delta.days',
       'from datetime import datetime' + #13#10 +
       '' + #13#10 +
       'projects = [' + #13#10 +
       '    ("Alpha", "2026-05-15"),' + #13#10 +
       '    ("Beta",  "2026-06-01"),' + #13#10 +
       '    ("Gamma", "2026-06-20"),' + #13#10 +
       ']' + #13#10 +
       'today = datetime(2026, 6, 1)' + #13#10 +
       '# Print each project with days and status',
       'from datetime import datetime' + #13#10 +
       '' + #13#10 +
       'projects = [' + #13#10 +
       '    ("Alpha", "2026-05-15"),' + #13#10 +
       '    ("Beta",  "2026-06-01"),' + #13#10 +
       '    ("Gamma", "2026-06-20"),' + #13#10 +
       ']' + #13#10 +
       'today = datetime(2026, 6, 1)' + #13#10 +
       'for name, ds in projects:' + #13#10 +
       '    d     = datetime.strptime(ds, "%Y-%m-%d")' + #13#10 +
       '    delta = (d - today).days' + #13#10 +
       '    if delta < 0:' + #13#10 +
       '        status = f"{-delta} days ago  OVERDUE"' + #13#10 +
       '    elif delta == 0:' + #13#10 +
       '        status = f" 0 days      TODAY"' + #13#10 +
       '    else:' + #13#10 +
       '        status = f"{delta} days      UPCOMING"' + #13#10 +
       '    print(f"{name:<8} {ds}  {status}")',
       ckContainsAll,
       'OVERDUE|TODAY|UPCOMING|Alpha|Beta|Gamma',
       0,0,0, 0, 25),

    Ch(1092, 'Mini Task Runner',
       'Build a task runner that processes a list of tasks.' + #13#10 +
       'Each task is a dict with name, priority (1-5), and done (bool).' + #13#10 +
       '' + #13#10 +
       'Print:' + #13#10 +
       '  1. Pending tasks sorted by priority (highest first)' + #13#10 +
       '  2. Count of done vs pending' + #13#10 +
       '' + #13#10 +
       'Expected:' + #13#10 +
       '    Pending (by priority):' + #13#10 +
       '      [5] Deploy to production' + #13#10 +
       '      [3] Write tests' + #13#10 +
       '      [1] Update docs' + #13#10 +
       '    Done: 2   Pending: 3',
       'pending = [t for t in tasks if not t["done"]]   sorted(..., key=..., reverse=True)',
       'tasks = [' + #13#10 +
       '    {"name": "Write tests",        "priority": 3, "done": False},' + #13#10 +
       '    {"name": "Fix login bug",       "priority": 5, "done": True},' + #13#10 +
       '    {"name": "Update docs",         "priority": 1, "done": False},' + #13#10 +
       '    {"name": "Deploy to production","priority": 5, "done": False},' + #13#10 +
       '    {"name": "Code review",         "priority": 4, "done": True},' + #13#10 +
       ']' + #13#10 +
       '# Print pending tasks by priority, then summary',
       'tasks = [' + #13#10 +
       '    {"name": "Write tests",        "priority": 3, "done": False},' + #13#10 +
       '    {"name": "Fix login bug",       "priority": 5, "done": True},' + #13#10 +
       '    {"name": "Update docs",         "priority": 1, "done": False},' + #13#10 +
       '    {"name": "Deploy to production","priority": 5, "done": False},' + #13#10 +
       '    {"name": "Code review",         "priority": 4, "done": True},' + #13#10 +
       ']' + #13#10 +
       '' + #13#10 +
       'pending = sorted([t for t in tasks if not t["done"]],' + #13#10 +
       '                 key=lambda t: t["priority"], reverse=True)' + #13#10 +
       'done_count = sum(1 for t in tasks if t["done"])' + #13#10 +
       '' + #13#10 +
       'print("Pending (by priority):")' + #13#10 +
       'for t in pending:' + #13#10 +
       '    print(f"  [{t[''priority'']}] {t[''name'']}")' + #13#10 +
       'print(f"Done: {done_count}   Pending: {len(pending)}")',
       ckExactOutput,
       'Pending (by priority):' + #13#10 +
       '  [5] Deploy to production' + #13#10 +
       '  [3] Write tests' + #13#10 +
       '  [1] Update docs' + #13#10 +
       'Done: 2   Pending: 3',
       0,0,0, 0, 30)
  ];
end;

end.
