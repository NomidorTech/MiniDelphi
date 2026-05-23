# Pythia — Roteiro do Projeto
**Nomidor Software, LLC**
Última atualização: 2026-05-22

---

## Imediato (próxima sessão)

- [ ] Corrigir `sudoku.mdp` — remover `var fi2` inline dentro de bloco begin
      (limitação do parser). Substituir por declaração no topo da função.
      Auto-selecionar a primeira célula vazia ao iniciar o jogo.
- [ ] Verificar Sudoku totalmente jogável de ponta a ponta
- [ ] Construir `pyrun.exe` — runtime standalone do Pythia para distribuir programas .mdp

---

## Curto Prazo

### Migração SQLite para o Sudoku
- [ ] Instalar SQLite (`sqlite3.dll` ao lado do exe) — Jim instalando em breve
- [ ] Migrar salvamentos do `sudoku.ini` para tabelas SQLite:
      - `jogos` (id, data, modo, tempo, tabuleiro, fixas, solução, concluído)
      - `melhores_tempos` (modo, segundos, data)
      - `desafios_diarios` (data, semente, tabuleiro, solução)
- [ ] Distribuir `pythia.db` pré-populado como asset de release no GitHub

### pyrun.exe — Runtime Standalone
- [ ] Projeto Delphi separado (aplicação console)
- [ ] Executa arquivo `.mdp` pela linha de comando: `pyrun sudoku.mdp`
- [ ] Compartilha UInterpreter, UGraphics, USQLite, UObjectRuntime
- [ ] Sem IDE — motor de execução + janela gráfica apenas

---

## Médio Prazo

### Python como Linguagem de Aprendizado
**Justificativa**: Python tem muito maior utilidade prática no mundo real do que Pascal hoje.
O Pythia deve ensinar AMBAS — Pascal para fundamentos (tipos, ponteiros, POO)
e Python para scripts práticos, dados e automação.

**Abordagens**:
1. Shell para o Python do sistema (`python.exe`) capturando stdout — simples, sem embedding
2. Embutir interpretador Python leve (MicroPython ou CPython via DLL)
3. Transpilar Pythia Pascal → Python para comparação lado a lado

**Interface**: Aba "Aprender a Programar" com alternância de linguagem (Pascal / Python)

**Projetos de exemplo**: Todo exemplo Pascal ganha um equivalente em Python

**Bibliotecas gratuitas a aproveitar**:
- `requests` — HTTP / APIs REST
- `pandas` — análise de dados
- `matplotlib` — gráficos
- `sqlite3` — embutido, conecta ao mesmo pythia.db
- `tkinter` — GUI alternativa

**Ação**: Projetar arquitetura do runner Python antes de implementar

### Suporte ao Firebird
**Justificativa**: Jim tem o Firebird instalado — SGBD gratuito de nível empresarial.
Muitas aplicações reais usam Firebird; ensiná-lo é valioso.

**Abordagem**: Carregamento dinâmico de `fbclient.dll` — SEM licença FireDAC necessária.
Escrever `UFirebird.pas` modelado a partir de `USQLite.pas`.

**Superfície da API**:
```pascal
DbOpen('localhost:C:\dados\meuapp.fdb');  // Firebird
DbOpen('C:\dados\meuapp.db');             // SQLite (existente)
DbExec('INSERT INTO ...');
DbQuery('SELECT ...');
```

Detecção automática: caminho com host → Firebird, senão → SQLite. Transparente para programas .mdp.

**Ação**: Implementar UFirebird.pas após migração SQLite estável

---

## Decisões de Arquitetura

### Idioma dos Comentários
- Fonte Delphi: inglês E português (bilíngue)
- Exemplos .mdp: comentários em português
- Mensagens de erro: português
- Rótulos da interface: inglês

### Implementação de Arrays
- `TArrayValue` usa `TList` + ponteiros `PValue` no heap
- `TValue.ArrVal` declarado como `TObject` para evitar dependência circular de tipos
- Auxiliar `AsArr()` faz o cast nos pontos de uso
- Sem `Exit` ou `break` em programas .mdp — usar flags booleanos

### Tratamento de EExitSignal
- `CallRoutine`: captura `EExitSignal`, usa `E.ReturnVal` para funções
- `InvokeMethod`: igual
- `Run`: captura `EExitSignal`, `EBreakSignal`, `EContinueSignal` no nível superior

### Limite de Passos
- Padrão: 1.000.000 passos
- Programas gráficos: `FInterp.MaxSteps := 100_000_000`

### Limitações do Parser
- `var` inline dentro de blocos `while`/`begin` aninhados não é confiável
- Solução: declarar vars no topo da função ou em bloco `var` global

---

## Concluído ✓

- [x] Lexer, Parser, AST
- [x] Interpretador em modo árvore
- [x] IDE VCL com 6 abas
- [x] Runtime orientado a objetos
- [x] Builtins SQLite
- [x] Janela gráfica com mouse e teclado
- [x] Arrays dinâmicos (SetLength, indexação)
- [x] Builtins INI
- [x] Builtins Shell
- [x] Builtins de data/hora
- [x] Jogo Sudoku completo
- [x] EExitSignal contido corretamente
- [x] Correção de foco GfxWindow
- [x] VK_BACK e VK_DELETE no teclado
- [x] BUILTINS do UValidator expandido para 103 entradas
- [x] Comentários bilíngues em todo o fonte
- [x] ROADMAP bilíngue

---

## Bug Conhecido

- [ ] **Sudoku**: jogo inicia sem célula vazia selecionada. Se a primeira célula
      for pré-preenchida o jogo fica inacessível. Fix pendente: auto-selecionar
      a primeira célula vazia ao iniciar qualquer jogo.

---
---
---

# Pythia — Project Roadmap
**Nomidor Software, LLC**
Last updated: 2026-05-22

---

## Immediate (next session)

- [ ] Fix `sudoku.mdp` — remove inline `var fi2` inside begin block (parser limitation).
      Replace with top-level var declaration. Auto-select first empty cell on game start.
- [ ] Verify Sudoku fully playable end-to-end (click cell → type digit → win detection)
- [ ] Build `pyrun.exe` — standalone Pythia runtime for shipping .mdp programs

---

## Short Term

### SQLite Migration for Sudoku
- [ ] Install SQLite (`sqlite3.dll` next to exe) — Jim installing soon
- [ ] Migrate `sudoku.ini` saves to SQLite tables:
      - `games` (id, date, mode, elapsed, board, given, solution, completed)
      - `best_times` (mode, seconds, date)
      - `daily_challenges` (date, seed, board, solution)
- [ ] Ship pre-populated `pythia.db` as a GitHub release asset

### pyrun.exe — Standalone Runtime
- [ ] Separate Delphi project (console app)
- [ ] Runs `.mdp` file from command line: `pyrun sudoku.mdp`
- [ ] Shares UInterpreter, UGraphics, USQLite, UObjectRuntime
- [ ] No IDE — just the runtime engine + graphics window

---

## Medium Term

### Python as a Learning Language
**Rationale**: Python has far greater real-world utility than Pascal today.
Pythia should teach BOTH — Pascal for fundamentals (types, pointers, OOP)
and Python for practical scripting, data, and automation.

**Approach options**:
1. Shell to system Python (`python.exe`) and capture stdout — simple, no embedding
2. Embed a lightweight Python interpreter (MicroPython or CPython via DLL)
3. Transpile Pythia Pascal → Python for side-by-side comparison

**UI**: "Learn to Code" tab with language toggle (Pascal / Python)

**Example projects**: Every Pascal example gets a Python equivalent

**Free libraries to leverage**:
- `requests` — HTTP / REST APIs
- `pandas` — data analysis
- `matplotlib` — charts
- `sqlite3` — built-in, connects to same pythia.db
- `tkinter` — alternative GUI

**Action**: Design Python runner architecture before implementing

### Firebird Database Support
**Rationale**: Jim has Firebird installed — enterprise-grade free RDBMS.
Many real-world applications use Firebird; teaching it is valuable.

**Approach**: Dynamic loading of `fbclient.dll` — NO FireDAC license needed.
Write `UFirebird.pas` modelled after `USQLite.pas`.

**API surface**:
```pascal
DbOpen('localhost:C:\data\myapp.fdb');  // Firebird
DbOpen('C:\data\myapp.db');             // SQLite (existing)
DbExec('INSERT INTO ...');
DbQuery('SELECT ...');
```

Auto-detection: path with host → Firebird, else → SQLite. Transparent to .mdp programs.

**Action**: Implement UFirebird.pas after SQLite migration is stable

---

## Architecture Decisions

### Comment Language
- Delphi source: English AND Portuguese (bilingual)
- .mdp example programs: Portuguese comments
- Error messages: Portuguese
- UI labels: English

### Array Implementation
- `TArrayValue` uses `TList` + `PValue` heap pointers
- `TValue.ArrVal` declared as `TObject` to avoid circular type dependency
- `AsArr()` inline helper casts at call sites
- No `Exit` or `break` in .mdp programs — use boolean flags and while loops

### EExitSignal Handling
- `CallRoutine`: catches `EExitSignal`, uses `E.ReturnVal` for functions
- `InvokeMethod`: same
- `Run`: catches `EExitSignal`, `EBreakSignal`, `EContinueSignal` at top level

### Step Limit
- Default: 1,000,000 steps (simple programs)
- Graphics programs: `FInterp.MaxSteps := 100_000_000`

### Known Parser Limitations
- Inline `var` inside nested `while`/`begin` blocks is unreliable
- Workaround: always declare vars at top of function or in top-level `var` block

---

## Completed ✓

- [x] Lexer, Parser, AST
- [x] Tree-walking interpreter
- [x] VCL IDE with 6 tabs
- [x] Object-oriented runtime
- [x] SQLite builtins
- [x] Graphics window with mouse and keyboard
- [x] Dynamic arrays (SetLength, indexing)
- [x] INI builtins
- [x] Shell builtins
- [x] Date/time builtins
- [x] Complete Sudoku game
- [x] EExitSignal properly contained
- [x] GfxWindow focus fix
- [x] VK_BACK and VK_DELETE in keyboard handler
- [x] UValidator BUILTINS expanded to 103 entries
- [x] Bilingual comments throughout source
- [x] Bilingual ROADMAP

---

## Known Bug

- [ ] **Sudoku**: game starts with no empty cell selected. If the first board
      cell is a prefilled clue, the game is unplayable. Fix pending: auto-select
      first empty cell on any game start.
