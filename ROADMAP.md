# Pythia — Roteiro do Projeto / Project Roadmap
**Nomidor Software, LLC**
Última atualização / Last updated: 2026-05-22

---

## Imediato / Immediate (próxima sessão / next session)

- [ ] Corrigir `sudoku.mdp` — remover `var fi2` inline dentro de bloco begin
      (limitação do parser). Substituir por declaração no topo da função.
      Auto-selecionar a primeira célula vazia ao iniciar o jogo.
      ---
      Fix `sudoku.mdp` — remove inline `var fi2` inside begin block (parser limitation).
      Replace with top-level var declaration. Auto-select first empty cell on game start.

- [ ] Verificar Sudoku totalmente jogável de ponta a ponta
      ---
      Verify Sudoku fully playable end-to-end (click cell → type digit → win detection)

- [ ] Construir `pyrun.exe` — runtime standalone do Pythia para distribuir programas .mdp
      ---
      Build `pyrun.exe` — standalone Pythia runtime for shipping .mdp programs

---

## Curto Prazo / Short Term

### Migração SQLite para o Sudoku / SQLite Migration for Sudoku
- [ ] Instalar SQLite (`sqlite3.dll` ao lado do exe) — Jim instalando em breve
      ---
      Install SQLite (`sqlite3.dll` next to exe) — Jim installing soon

- [ ] Migrar salvamentos do `sudoku.ini` para tabelas SQLite:
      - `jogos` (id, data, modo, tempo, tabuleiro, fixas, solução, concluído)
      - `melhores_tempos` (modo, segundos, data)
      - `desafios_diarios` (data, semente, tabuleiro, solução)
      ---
      Migrate `sudoku.ini` saves to SQLite tables:
      - `games` (id, date, mode, elapsed, board, given, solution, completed)
      - `best_times` (mode, seconds, date)
      - `daily_challenges` (date, seed, board, solution)

- [ ] Distribuir `pythia.db` pré-populado como asset de release no GitHub
      ---
      Ship pre-populated `pythia.db` as a GitHub release asset

### pyrun.exe — Runtime Standalone
- [ ] Projeto Delphi separado (aplicação console)
      ---
      Separate Delphi project (console app)
- [ ] Executa arquivo `.mdp` pela linha de comando: `pyrun sudoku.mdp`
      ---
      Runs `.mdp` file from command line: `pyrun sudoku.mdp`
- [ ] Compartilha UInterpreter, UGraphics, USQLite, UObjectRuntime
      ---
      Shares UInterpreter, UGraphics, USQLite, UObjectRuntime
- [ ] Sem IDE — motor de execução + janela gráfica apenas
      ---
      No IDE — just the runtime engine + graphics window

---

## Médio Prazo / Medium Term

### Python como Linguagem de Aprendizado / Python as a Learning Language

**Justificativa / Rationale**:
Python tem muito maior utilidade prática no mundo real do que Pascal hoje.
O Pythia deve ensinar AMBAS — Pascal para fundamentos (tipos, ponteiros, POO)
e Python para scripts práticos, dados e automação.
---
Python has far greater real-world utility than Pascal today.
Pythia should teach BOTH — Pascal for fundamentals (types, pointers, OOP)
and Python for practical scripting, data, and automation.

**Abordagens / Approach options**:
1. Shell para o Python do sistema (`python.exe`) capturando stdout — simples, sem embedding
   --- Shell to system Python and capture stdout — simple, no embedding
2. Embutir interpretador Python leve (MicroPython ou CPython via DLL)
   --- Embed lightweight Python interpreter (MicroPython or CPython via DLL)
3. Transpilar Pythia Pascal → Python para comparação lado a lado
   --- Transpile Pythia Pascal → Python for side-by-side comparison

**Interface / UI**:
Aba "Aprender a Programar" com alternância de linguagem (Pascal / Python)
---
"Learn to Code" tab with language toggle (Pascal / Python)

**Projetos de exemplo / Example projects**:
Todo exemplo Pascal ganha um equivalente em Python
---
Every Pascal example gets a Python equivalent

**Bibliotecas gratuitas a aproveitar / Free libraries to leverage**:
- `requests` — HTTP / APIs REST
- `pandas` — análise de dados / data analysis
- `matplotlib` — gráficos / charts
- `sqlite3` — embutido, conecta ao mesmo pythia.db / built-in, same pythia.db
- `tkinter` — GUI alternativa / alternative GUI

**Ação / Action**:
Projetar arquitetura do runner Python antes de implementar
---
Design Python runner architecture before implementing

### Suporte ao Firebird / Firebird Database Support

**Justificativa / Rationale**:
Jim tem o Firebird instalado — SGBD gratuito de nível empresarial.
Muitas aplicações reais usam Firebird; ensiná-lo é valioso.
---
Jim has Firebird installed — enterprise-grade free RDBMS.
Many real-world applications use Firebird; teaching it is valuable.

**Abordagem / Approach**:
Carregamento dinâmico de `fbclient.dll` — SEM licença FireDAC necessária.
Escrever `UFirebird.pas` modelado a partir de `USQLite.pas`.
---
Dynamic loading of `fbclient.dll` — NO FireDAC license needed.
Write `UFirebird.pas` modelled after `USQLite.pas`.

**Superfície da API / API surface**:
```pascal
DbOpen('localhost:C:\dados\meuapp.fdb');  // Firebird
DbOpen('C:\dados\meuapp.db');             // SQLite (existente / existing)
DbExec('INSERT INTO ...');
DbQuery('SELECT ...');
```

Detecção automática: caminho com host → Firebird, senão → SQLite.
Transparente para programas .mdp.
---
Auto-detection: path with host → Firebird, else → SQLite. Transparent to .mdp programs.

**Ação / Action**:
Implementar UFirebird.pas após migração SQLite estável
---
Implement UFirebird.pas after SQLite migration is stable

---

## Decisões de Arquitetura / Architecture Decisions

### Idioma dos Comentários / Comment Language
- Fonte Delphi: **inglês E português** (bilíngue) / Delphi source: **English AND Portuguese**
- Exemplos .mdp: comentários em português / .mdp examples: Portuguese comments
- Mensagens de erro: português / Error messages: Portuguese
- Rótulos da interface: inglês / UI labels: English

### Implementação de Arrays / Array Implementation
- `TArrayValue` usa `TList` + ponteiros `PValue` no heap
  --- Uses `TList` + `PValue` heap pointers
- `TValue.ArrVal` declarado como `TObject` para evitar dependência circular de tipos
  --- Declared as `TObject` to avoid circular type dependency
- Auxiliar `AsArr()` faz o cast nos pontos de uso
  --- `AsArr()` inline helper casts at call sites
- Sem `Exit` ou `break` em programas .mdp — usar flags booleanos
  --- No `Exit` or `break` in .mdp programs — use boolean flags

### Tratamento de EExitSignal / EExitSignal Handling
- `CallRoutine`: captura `EExitSignal`, usa `E.ReturnVal` para funções
  --- Catches `EExitSignal`, uses `E.ReturnVal` for functions
- `InvokeMethod`: igual / same
- `Run`: captura `EExitSignal`, `EBreakSignal`, `EContinueSignal` no nível superior
  --- Catches all control-flow signals at top level

### Limite de Passos / Step Limit
- Padrão / Default: 1.000.000 passos / steps
- Programas gráficos / Graphics programs: `FInterp.MaxSteps := 100_000_000`

### Limitações do Parser / Parser Limitations
- `var` inline dentro de blocos `while`/`begin` aninhados não é confiável
  --- Inline `var` inside nested `while`/`begin` blocks is unreliable
- Solução: declarar vars no topo da função ou em bloco `var` global
  --- Workaround: declare vars at top of function or in top-level `var` block

---

## Concluído / Completed ✓

- [x] Lexer, Parser, AST
- [x] Interpretador em modo árvore / Tree-walking interpreter
- [x] IDE VCL com 6 abas / VCL IDE with 6 tabs
- [x] Runtime orientado a objetos / Object-oriented runtime
- [x] Builtins SQLite
- [x] Janela gráfica com mouse e teclado / Graphics window with mouse and keyboard
- [x] Arrays dinâmicos / Dynamic arrays (SetLength, indexação / indexing)
- [x] Builtins INI
- [x] Builtins Shell
- [x] Builtins de data/hora / Date/time builtins
- [x] Jogo Sudoku completo / Complete Sudoku game
- [x] EExitSignal contido corretamente / EExitSignal properly contained
- [x] Correção de foco GfxWindow / GfxWindow focus fix
- [x] VK_BACK e VK_DELETE no teclado / in keyboard handler
- [x] BUILTINS do UValidator expandido para 103 entradas / expanded to 103 entries
- [x] Comentários bilíngues em todo o fonte / Bilingual comments throughout source
- [x] ROADMAP bilíngue / Bilingual ROADMAP

---

## Bug Conhecido / Known Bug

- [ ] **Sudoku**: jogo inicia sem célula vazia selecionada. Se a primeira célula
      for pré-preenchida o jogo fica inacessível. Fix pendente: auto-selecionar
      a primeira célula vazia ao iniciar qualquer jogo.
      ---
      **Sudoku**: game starts with no empty cell selected. If the first board
      cell is a prefilled clue, the game is unplayable. Fix pending: auto-select
      first empty cell on any game start.
