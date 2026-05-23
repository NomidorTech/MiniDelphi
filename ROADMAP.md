# Pythia — Roadmap & Project Directives
**Nomidor Software, LLC**
Last updated: 2026-05-22

---

## Immediate (next session)

- [ ] Fix `sudoku.mdp` — remove inline `var fi2` inside begin block (parser limitation)
      Replace with top-level var declaration. Auto-select first empty cell on game start.
- [ ] Verify Sudoku fully playable end-to-end (click cell → type digit → win detection)
- [ ] Build `pyrun.exe` — the standalone Pythia runtime for shipping .mdp programs

---

## Short Term

### SQLite Migration for Sudoku
- [ ] Install SQLite (`sqlite3.dll` next to exe) — Jim installing tomorrow
- [ ] Migrate `sudoku.ini` saves to SQLite tables:
      - `games` (id, date, mode, elapsed, board, given, solution, completed)
      - `best_times` (mode, seconds, date)
      - `daily_challenges` (date, seed, board, solution)
- [ ] Ship a pre-populated `pythia.db` as a GitHub release asset
      Link from README so users can download puzzle database

### pyrun.exe — Standalone Runtime
- [ ] Separate Delphi project (console app)
- [ ] Loads and runs a `.mdp` file from command line: `pyrun sudoku.mdp`
- [ ] Shares UInterpreter, UGraphics, USQLite, UObjectRuntime
- [ ] No IDE — just the runtime engine + graphics window
- [ ] Used for shipping finished Pythia programs to end users

---

## Medium Term

### Python as a Learning Language
- **Rationale**: Python has far greater real-world utility than Pascal today.
  Pythia should teach BOTH — Pascal for learning fundamentals (types, pointers,
  OOP) and Python for practical scripting, data, and automation.
- **Approach options**:
  1. Shell to system Python (`python.exe`) and capture stdout — simple, no embedding
  2. Embed a lightweight Python interpreter (e.g. MicroPython or CPython via DLL)
  3. Transpile Pythia Pascal → Python for side-by-side comparison
- **UI**: "Learn to Code" tab with language toggle (Pascal / Python)
- **Example projects**: Every Pascal example gets a Python equivalent
- **Free libraries to leverage**:
  - `requests` — HTTP / REST APIs
  - `pandas` — data analysis
  - `matplotlib` — charts (could render via GfxWindow)
  - `sqlite3` — built-in, connects to same pythia.db
  - `tkinter` — GUI (alternative to GfxWindow for Python programs)
- **Action**: Design the Python runner architecture before implementing

### Firebird Database Support
- **Rationale**: Jim has Firebird installed — enterprise-grade free RDBMS.
  Many real-world applications use Firebird; teaching it is valuable.
- **Approach**: Dynamic loading of `fbclient.dll` — NO FireDAC license needed.
  Write `UFirebird.pas` modelled after `USQLite.pas`.
- **API surface** (same builtins, different connection string):
  ```pascal
  DbOpen('localhost:C:\data\myapp.fdb');   // Firebird connection
  DbOpen('C:\data\myapp.db');              // SQLite (existing)
  DbExec('INSERT INTO ...');
  DbQuery('SELECT ...');
  ```
- **Connection string detection**: if path contains `:` and host → Firebird,
  else → SQLite. Transparent to .mdp programs.
- **Action**: Implement UFirebird.pas after SQLite migration is stable

---

## Architecture Decisions

### Comment Language
- All Delphi source comments: **English AND Portuguese** (bilingual)
- All .mdp example programs: Portuguese comments
- Error messages in interpreter: Portuguese
- UI labels: English (international standard for IDE)

### Array Implementation
- `TArrayValue` uses `TList` + `PValue` heap pointers
- `TValue.ArrVal` declared as `TObject` to avoid circular type dependency
- `AsArr()` inline helper casts at call sites
- No `Exit` or `break` in .mdp programs — use boolean flags and while loops
  (interpreter raises EExitSignal / EBreakSignal which can escape if not caught)

### EExitSignal Handling
- `CallRoutine`: catches `EExitSignal`, uses `E.ReturnVal` for functions
- `InvokeMethod`: same
- `Run`: catches `EExitSignal`, `EBreakSignal`, `EContinueSignal` at top level
- .mdp programs: avoid `Exit` and `break` — use structured boolean logic

### Step Limit
- Default: 1,000,000 steps (simple programs)
- Graphics programs: set `FInterp.MaxSteps := 100_000_000` in UProjectTab and UMacroTab
- Graphics programs with backtracking algorithms need high limits

### Parser Limitations (known)
- Inline `var` declarations inside `begin..end` blocks are supported BUT
  they cannot appear inside nested `while`/`begin` blocks reliably
- Workaround: always declare vars at the top of the nearest function/procedure
  or in a top-level `var` block before `begin`
- `break` and `Exit` raise exceptions (EBreakSignal, EExitSignal) which can
  escape nested loops if not carefully structured — prefer boolean flags

---

## Completed ✓

- [x] Lexer, Parser, AST
- [x] Tree-walking interpreter
- [x] VCL IDE with 6 tabs (Compiler, Calculator, Learn, Projects, Forms, Macros)
- [x] Object-oriented runtime (classes, inheritance, interfaces)
- [x] SQLite builtins (DbOpen, DbExec, DbQuery, etc.)
- [x] Graphics window (GfxOpen, drawing primitives, mouse, keyboard)
- [x] Dynamic arrays (SetLength, array indexing, Length for arrays)
- [x] INI file builtins (IniReadStr, IniWriteStr, IniReadInt, IniWriteInt)
- [x] Shell builtins (Shell, ShellWait, ShellHidden)
- [x] Date/time builtins (DateStr, TimeStr)
- [x] Sudoku game (.mdp) — iterative generator, Easy/Medium/Hard/Daily
- [x] EExitSignal properly contained in CallRoutine and Run
- [x] GfxWindow focus fix — panel mouse events + SetFocus on show and click
- [x] VK_BACK and VK_DELETE in keyboard handler
- [x] UValidator BUILTINS expanded to include all new builtins
- [x] All source comments bilingual (English + Portuguese)
