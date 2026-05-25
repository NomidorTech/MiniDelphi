# Pythia — Multi-Language Learning IDE
**Nomidor Software, LLC**

> **"Py" in Pythia stands for Python.**
> Pythia started as a Pascal learning tool and grew into a multi-language
> programming environment. The name now reflects its Python heart as much
> as its Delphi roots.

---

## What is Pythia?

Pythia is a lightweight, self-contained programming IDE designed for learning
and rapid scripting. It ships with a built-in Pascal interpreter and connects
to any external language via a snap-in runner pack system.

**No installation of external tools required to get started** — Pascal runs
natively inside the exe. Python, Lua, Node.js and others activate by dropping
a `.runner.ini` file into the `Runners\` folder.

---

## Supported Languages / Linguagens Suportadas

| Language | Mode | Requires |
|---|---|---|
| **Pascal** | Built-in interpreter | Nothing — works out of the box |
| **Python** | Shell to `python.exe` | Python 3.x on PATH |
| **Lua** | Shell to `lua.exe` | Lua 5.x on PATH |
| **JavaScript** | Shell to `node.exe` | Node.js on PATH |
| *Any language* | Shell to any exe | Drop a `.runner.ini` in `Runners\` |

---

## Tabs / Abas

| Tab | Purpose |
|---|---|
| **Compiler** | Quick Pascal scratchpad — write, run, see output instantly |
| **Calculator** | Expression evaluator for any numeric expression |
| **Learn Pascal** | 10 real-world Pascal lessons, 30 challenges — OOP, algorithms, patterns |
| **Learn Python** | 10 real-world Python lessons, 30 challenges — comprehensions, JSON, APIs |
| **Projects** | Full project IDE with file tree, runner dropdown, recent files |
| **Forms** | Visual form designer for `.mdfrm` files |

Learn tabs appear **dynamically** — install a runner pack and the matching
Learn tab appears on next startup. Remove it and the tab disappears.

---

## Runner Pack System

Pythia's language support is fully pluggable. A runner pack is a single
`.ini` file in the `Runners\` folder:

```ini
[Meta]
Name=Python
Code=py
Extension=.py

[Runtime]
Mode=shell
Command=python
Args={file}

[Detect]
TestCommand=python --version
```

Drop it in, restart Pythia, done. The new language appears in:
- The runner dropdown in the Projects toolbar
- The Learn tab (if a curriculum exists for that language)

See `Runners\README.md` for the full format reference.

---

## Language Pack System

The UI is fully translated into 13 languages. Select your language in
**View → Preferences → Language**.

| Built-in languages |
|---|
| English · Português · العربية · Deutsch · Español · Español Latinoamérica |
| Français · हिन्दी · Italiano · 日本語 · 한국어 · Українська · 简体中文 |

External language packs: drop a `.ini` file in `LangPacks\` and restart.
Use the **Language Pack Editor** in the Projects tab → Tools to create your own.

---

## File Types

| Extension | Description |
|---|---|
| `.mdp` | Pythia Pascal source file |
| `.mdproj` | Pythia project file (contains source + file list) |
| `.mdfrm` | Pythia form definition |
| `.runner.ini` | Runner pack (language plugin) |
| `.ini` in `LangPacks\` | Language pack (UI translation) |

---

## Architecture

```
Pythia.exe
├── UMainForm         — VCL shell, dynamic tab creation
├── UInterpreter      — Tree-walking Pascal interpreter
├── ULexer / UParser / UAST — Pascal front-end
├── URunnerManager    — Pluggable language runner system
├── ULanguage         — i18n system (13 languages + external packs)
├── ULearnTabBase     — Runner-aware learn tab engine
├── UPascalCurriculum — 10 Pascal lessons, 30 real-world challenges
├── UPythonCurriculum — 10 Python lessons, 30 real-world challenges
├── UProjectTab       — Project IDE with runner dropdown
├── UGraphics         — GfxOpen window (Pascal graphics programs)
├── USQLite           — SQLite builtins (DbOpen, DbExec, DbQuery)
└── UTheme            — VCL Styles dark/light/system theme
```

---

## Português / Portuguese

Pythia é um IDE leve para aprender e criar scripts em múltiplas linguagens.
O interpretador Pascal está embutido no executável. Python, Lua e outras
linguagens se conectam via o sistema de runner packs — basta colocar um
arquivo `.runner.ini` na pasta `Runners\` e reiniciar.

**"Py" em Pythia representa Python** — o nome reflete tanto as raízes em
Delphi/Pascal quanto o suporte crescente ao Python.

---

## License / Licença

GPL v3 — see [LICENSE](LICENSE) or https://www.gnu.org/licenses/gpl-3.0.html

Copyright © 2026 Nomidor Software, LLC
