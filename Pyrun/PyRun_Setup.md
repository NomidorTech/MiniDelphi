# PyRun — Runtime Standalone do Pythia / Pythia Standalone Runtime

## Como criar o projeto / How to create the project

### No Delphi / In Delphi

1. **File → New → Other → Console Application** — NÃO / DO NOT use this
   Use **File → New → VCL Application** instead, then:
   - Delete the auto-generated form (`Unit1.pas`, `Unit1.dfm`)
   - Replace the `.dpr` content with `PyRun.dpr`

2. **Ou / Or** — criar manualmente / create manually:
   - File → New → Empty Project
   - Paste `PyRun.dpr` as the project file

3. **Adicionar ao projeto / Add to project** — as mesmas units do Pythia:
   ```
   ULexer.pas
   UParser.pas
   UAST.pas
   UInterpreter.pas
   UObjectRuntime.pas
   UGraphics.pas
   USQLite.pas
   UUnitLoader.pas
   UValidator.pas
   ```
   Estas já existem na pasta do Pythia — aponte para elas.
   These already exist in the Pythia folder — point to them.

4. **Project → Options:**
   - Application → Title: `Pythia Runtime`
   - Application → Output directory: mesma pasta do `Pythia.exe`
   - Linker → Target: `Win64`
   - Build configuration: `Release`

5. **Project → Build** (Shift+F9)

---

## Uso / Usage

```powershell
# Executar um programa / Run a program
pyrun.exe sudoku.mdp

# Executar um projeto / Run a project
pyrun.exe MeuApp\meuapp.mdproj

# Sem builtins Shell / Without Shell builtins
pyrun.exe script.mdp --no-shell

# Ajuda / Help
pyrun.exe --help
```

---

## Comportamento / Behaviour

| Tipo de programa / Program type | Saída / Output |
|---|---|
| `writeln` sem `GfxOpen` | Console alocado automaticamente |
| `GfxOpen` (gráfico) | Janela gráfica, sem console |
| Erro fatal | MessageBox + código de saída 1 |

---

## Distribuição / Distribution

Copie para a mesma pasta do `pyrun.exe` / Copy to the same folder as `pyrun.exe`:
- `sqlite3.dll` (para builtins Db* / for Db* builtins)
- `LangPacks\` (pasta opcional / optional folder)
- `pythia.ini` (configurações / settings)

Para distribuir um programa ao usuário final / To distribute a program to end users:
```
MeuApp\
  pyrun.exe
  sudoku.mdp
  sqlite3.dll      (se usar banco de dados / if using database)
  Executar.bat     (opcional / optional)
```

`Executar.bat`:
```batch
@echo off
pyrun.exe sudoku.mdp
```
