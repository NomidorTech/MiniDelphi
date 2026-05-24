# Sudoku — Projeto Pythia / Pythia Project

## Arquivos / Files

| Arquivo / File | Descrição / Description |
|---|---|
| `sudoku.mdp` | Código fonte do jogo / Game source code |
| `Sudoku.dpr` | Projeto standalone dedicado / Dedicated standalone project |
| `PyRun.dpr` | Runtime genérico reutilizável / Reusable generic runtime |
| `Sudoku.bat` | Inicia com pyrun.exe / Launches with pyrun.exe |
| `Sudoku_Standalone.bat` | Inicia com Sudoku.exe / Launches with Sudoku.exe |
| `PyRun_Help.bat` | Mostra ajuda do runtime / Shows runtime help |

---

## Como compilar / How to compile

### Opção 1 — Runtime genérico / Generic runtime (recomendado / recommended)

Compile `PyRun.dpr` uma vez. Serve para todos os programas .mdp.
Compile `PyRun.dpr` once. Works for all .mdp programs.

```
File → Open Project → PyRun.dpr
Project → Options → Output directory: .\Win64\Release
Project → Build
```

Para executar / To run:
```
Sudoku.bat        (ou duplo clique / or double-click)
pyrun.exe sudoku.mdp
```

### Opção 2 — Executável dedicado / Dedicated executable

Compile `Sudoku.dpr` para um `Sudoku.exe` que só roda o Sudoku.
Compile `Sudoku.dpr` for a `Sudoku.exe` that only runs Sudoku.

```
File → Open Project → Sudoku.dpr
Project → Options → Output directory: .\Win64\Release
Project → Build
```

Para executar / To run:
```
Sudoku_Standalone.bat    (ou duplo clique em Sudoku.exe)
```

---

## Estrutura de distribuição / Distribution structure

### Com runtime genérico / With generic runtime
```
MeuJogo\
  pyrun.exe          ← compilado de PyRun.dpr
  sudoku.mdp         ← código fonte
  sqlite3.dll        ← para salvar partidas
  Sudoku.bat         ← atalho para o usuário
```

### Standalone dedicado / Dedicated standalone
```
MeuJogo\
  Sudoku.exe         ← compilado de Sudoku.dpr
  sudoku.mdp         ← código fonte
  sqlite3.dll        ← para salvar partidas
```

---

## Unidades compartilhadas / Shared units

Ambos os projetos usam as mesmas unidades do Pythia.
Both projects use the same Pythia units.
Aponte o Search Path para a pasta do Pythia.
Set the Search Path to point to the Pythia folder.

```
Project → Options → Building → Delphi Compiler → Search path:
  ..\          (pasta do Pythia / Pythia folder)
```

Unidades necessárias / Required units:
- `ULexer.pas`
- `UParser.pas`
- `UAST.pas`
- `UInterpreter.pas`
- `UObjectRuntime.pas`
- `UGraphics.pas`
- `USQLite.pas`
- `UUnitLoader.pas`
- `UValidator.pas`
