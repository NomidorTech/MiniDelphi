# Architecture

Pythia is a Pascal learning environment built in Delphi 13 (Athens) for Win64. This document describes how the codebase is organised and why the key design decisions were made.

---

## High-level overview

```
Source text
    │
    ▼
 ULexer          → TList<TToken>
    │
    ▼
 UParser         → TProgramNode  (AST)
    │
    ▼
 UValidator      → errors / warnings
    │
    ▼
 UUnitLoader     → merges imported .mdp routines into AST
    │
    ▼
 UInterpreter    → executes the tree
    │
    ├── UObjectRuntime   (class/object heap)
    ├── UGraphics        (Gfx* builtins → on-screen window)
    └── USQLite          (Db* builtins → sqlite3.dll)
```

The IDE wraps this pipeline in a VCL application with six tabs. All execution happens on the main thread.

---

## Unit map

| Layer | Unit | Responsibility |
|---|---|---|
| **Language engine** | `ULexer` | Source text → `TList<TToken>` |
| | `UParser` | Tokens → `TProgramNode` AST |
| | `UAST` | All AST node type definitions |
| | `UValidator` | Post-parse, pre-run static checks |
| | `UInterpreter` | Tree-walking executor |
| **Runtime extensions** | `UObjectRuntime` | Class instantiation, field access, vtable dispatch |
| | `UUnitLoader` | `uses` clause — loads and merges `.mdp` library files |
| | `UGraphics` | `Gfx*` builtins and the graphics window |
| | `USQLite` | `Db*` builtins via dynamic-loaded `sqlite3.dll` |
| **IDE shell** | `UMainForm` | Main VCL form, tab host, menu routing |
| | `UProjectTab` | Projects tab — editor, tree, Run/Stop, file ops |
| | `ULearnTab` | Learn tab — curriculum, challenge checker, progress |
| | `UFormBuilderTab` | Forms tab — visual designer (Phase 1) |
| | `UFormDef` | `.mdfrm` form definition model |
| | `UMacroTab` | Macros tab |
| | `UMacroLibrary` | Macro storage and starter templates |
| | `UExampleProjects` | 40+ built-in example programs (embedded strings) |
| **Infrastructure** | `UTheme` | VCL Styles wrapper (Dark / Light / Follow Windows) |
| | `UPreferencesDialog` | View → Preferences dialog |
| | `UAboutDialog` | About dialog + in-app programming reference |

---

## Language engine

### Lexer (`ULexer`)

Single-pass tokeniser. Reads source character by character and emits a flat `TList<TToken>`. Every token records `Kind`, `Text`, `Line`, and `Col` — position is stored on the token rather than reconstructed later, which makes error messages exact at no extra cost.

### Parser (`UParser`)

Classic recursive-descent parser. One method per grammar production (`ParseProgram`, `ParseBlock`, `ParseStatement`, `ParseExpr`, …). Returns a single `TProgramNode`; the caller owns and frees it.

Expression parsing uses a precedence chain:

```
ParseOrExpr → ParseAndExpr → ParseRelExpr → ParseAddExpr
    → ParseMulExpr → ParseUnaryExpr → ParsePrimary
```

`EParseError` carries `Line` and `Col` as separate fields so the IDE can display position without duplicating it in the message text.

OOP grammar is fully supported: `ParseClassDecl`, `ParseInterfaceDecl`, `ParseMethodDecl`, inline `var` declarations.

### AST (`UAST`)

`TASTNode` is the base; every node records `Line` and `Col`. Subclass hierarchy:

- **Expression nodes** — literals (int, float, string, bool, nil), variable references, binary/unary operators, function calls, array/field access, type casts.
- **Statement nodes** — assignment, writeln/readln, all control flow (`if`, `while`, `repeat`, `for`, `case`, `caseof`), procedure calls, `exit`/`break`/`continue`, OOP statements.
- **Declaration nodes** — `TVarDecl`, `TParamDecl`, `TRoutineDecl`, `TClassDecl`, `TInterfaceDecl`, `TMethodDecl`.
- **Top-level** — `TProgramNode` owns globals, routines, class/interface declarations, and the main block.

Ownership follows `TObjectList<T>` with `OwnsObjects = True` throughout; destructors cascade correctly.

### Validator (`UValidator`)

Runs between parsing and execution. Checks (non-exhaustive):

1. Missing `begin..end` main block
2. Empty program body
3. Undeclared variable / routine usage (builtins are whitelisted)
4. Function with no `Result` assignment (best-effort)
5. `while true do` without `break`/`exit`
6. Division by zero literals
7. Wrong argument count to known routines
8. String used in arithmetic context

Keeping validation separate from parsing means syntactic and semantic errors are reported independently and neither phase is complicated by the other's concerns.

### Interpreter (`UInterpreter`)

Tree walker. `TInterpreter.Run`:

1. Calls `TUnitLoader` to resolve the `uses` clause and merge imported routines.
2. Registers all built-in procedures/functions.
3. Declares global variables.
4. Calls `ExecBlock` on the main block.

`ExecStmt` dispatches on node type with an `if … is … then` chain — idiomatic Delphi for a visitor pattern without a visitor interface.

Control transfer (`exit`, `break`, `continue`) uses exceptions (`EExitSignal`, `EBreakSignal`, `EContinueSignal`) caught at appropriate enclosing contexts.

A step counter (`Tick`) enforces a maximum execution limit, protecting the UI against infinite loops in student code.

---

## Runtime extensions

### Object runtime (`UObjectRuntime`)

Handles class instantiation (`TMyClass.Create`), field storage, method lookup and dispatch, inheritance chains, and `Self`. The compile-time class declaration (AST) is separate from the runtime object representation here.

### Unit loader (`UUnitLoader`)

Resolves the `uses` clause of a `.mdp` program:

1. Scans quoted filenames in the `uses` clause.
2. Loads each file from disk relative to `BaseDir`.
3. Lexes, parses, and extracts `TRoutineDecl` nodes.
4. Merges them into the main program's AST before execution.

Library `.mdp` files contain declarations only — no `begin..end` block. If a main block is present it is silently ignored. Circular imports are detected and skipped.

### Graphics (`UGraphics`)

Implements the `Gfx*` builtins. Because the interpreter runs on the main VCL thread, painting is synchronous: `InvalidateRect + UpdateWindow` forces an immediate `WM_PAINT` before returning. No thread synchronisation is needed.

### SQLite (`USQLite`)

Wraps `sqlite3.dll` via dynamic loading. The DLL is optional — programs that don't use `Db*` builtins run fine without it.

---

## IDE shell

### Main form (`UMainForm`)

Hosts six `TTabSheet` pages and owns one instance of each tab module. The File menu delegates to the active tab's `Do*` methods. View menu provides token-stream and AST inspection on the Compiler tab.

Startup order matters: `Theme.Load` runs before `Application.CreateForm` so VCL Styles are applied before any window is painted.

### Project tab (`UProjectTab`)

`.mdproj` files are INI-format with three sections:

```ini
[Project]
Name=MyApp

[Files]
0=MathLib.mdp

[Source]
program MyApp;
uses 'MathLib.mdp';
begin
  writeln(Add(2, 3));
end.
```

Main program source lives in `[Source]` (like a real Delphi `.dpr`). Library paths in `[Files]` are relative to the `.mdproj` file. The Stop button sets `FInterp.FStop`, which the step counter checks on every `Tick`.

### Learn tab (`ULearnTab`)

Curriculum model: `TLearnCurriculum → TLesson → TChallenge`.

Each `TChallenge` has: instruction, hint, starter skeleton, reference solution, check strategy (`TCheckKind`), and point value. Check strategies: exact output match, contains-all substrings, numeric output, range, line count.

The checker runs student code through the same `TLexer → TParser → TInterpreter` pipeline as the Compiler tab. Progress (completed IDs, points, student name) is persisted to disk.

### Form builder (`UFormBuilderTab`)

Phase 1 visual designer for `.mdfrm` files. Palette: Pointer, Label, Button, Edit. Drag-and-drop placement, object inspector, arrow-key nudging (1px), Delete to remove. Runtime preview uses `TForm.CreateNew` with real VCL controls.

`TFormDef` (in `UFormDef`) is the data model. Properties are stored as a `TDictionary<string, string>`. The `OnClick` field stores a handler procedure name — ready for Phase 2 wiring to the interpreter, not yet invoked.

### Example projects (`UExampleProjects`)

All examples are embedded as string constants — no external files needed. Each example follows a consistent template: header block, per-line comments, `// *** NOTE:` teaching callouts. Multi-file examples demonstrate the `uses`/library system in context.

---

## Threading model

Everything runs on the main thread. There is no background interpreter thread. This simplifies the graphics model (synchronous paint), eliminates the need for thread-safe data structures in the interpreter, and avoids races between VCL and interpreter state. The tradeoff is that a slow or infinite program freezes the UI — mitigated by the step counter and Stop button.

---

## File formats

| Extension | Format | Description |
|---|---|---|
| `.mdp` | Plain text Pascal | Source file — program or library |
| `.mdproj` | INI (`[Project]` `[Files]` `[Source]`) | Project file |
| `.mdfrm` | INI | Form definition (controls + properties) |
| `Pythia.settings.ini` | INI | User preferences (theme choice) |

---

## Future work

- **Form builder Phase 2** — wire `OnClick` handler names to interpreter calls.
- **Debugger** — single-step execution with variable inspection at each step.
- **Stronger static analysis** — a simple symbol table with inferred types would catch more type mismatches before execution.
- **Bytecode VM** — a stack-based VM would improve throughput for tight loops and heavy graphics programs without fundamentally changing the architecture.
- **Interpreter test suite** — a set of small programs with known outputs, separate from the challenge checker, to protect against regressions.