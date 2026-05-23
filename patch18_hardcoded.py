#!/usr/bin/env python3
"""
patch18_hardcoded.py  —  Pythia Patch 18
Add Portuguese (pt-BR) translations after every English section-divider
comment block in the .pas source files.

No API key required — all translations are hardcoded.

Usage:
    py patch18_hardcoded.py <source-folder>
    py patch18_hardcoded.py C:\\holder\\MiniDelphi\\MiniDelphi

Safe to re-run: skips any block that already has [PT-BR] after it.
Writes <file>.patch18.bak backups.
"""

import sys, os, re, shutil
from datetime import datetime

# ---------------------------------------------------------------------------
#  Translation table:  English content text  ->  Portuguese content text
#
#  Key   = the text INSIDE the divider block (stripped of // and dashes)
#          Match is case-sensitive and stripped of leading/trailing spaces.
#  Value = Portuguese replacement text for the [PT-BR] line
#
#  Rules applied during translation:
#    - Pascal keywords kept as-is
#    - Class/type names kept as-is
#    - Technical acronyms (AST, VCL, INI, OOP) kept as-is
# ---------------------------------------------------------------------------
TRANSLATIONS = {

    # ── ULexer.pas ──────────────────────────────────────────────────────────
    "Low-level character access":
        "Acesso a caracteres de baixo nível",

    "Skip whitespace and both comment styles  { }  and  //":
        "Ignorar espaços em branco e ambos os estilos de comentário  { }  e  //",

    "Make a token stamped with current line/col":
        "Criar um token com a linha/coluna atual",

    "Read a quoted string  'hello world'":
        "Ler uma string entre aspas simples, ex: 'hello world'",

    "Read an integer or float literal":
        "Ler um literal inteiro ou de ponto flutuante",

    "Read an identifier, then check if it is a keyword":
        "Ler um identificador e verificar se é uma palavra-chave",

    "Main tokenise loop":
        "Loop principal de tokenização",

    # ── UParser.pas ─────────────────────────────────────────────────────────
    "Token access helpers":
        "Auxiliares de acesso a tokens",

    "Token helpers":
        "Auxiliares de token",

    "Grammar rules  (each method = one grammar production)":
        "Regras gramaticais  (cada método = uma produção gramatical)",

    "Expect a specific token kind, or raise a friendly error.\n\n"
    "  This is where most of the user-facing parse errors come from.  The goal\n"
    "  is to translate parser-internal token names (\"tkSemicolon\") into things\n"
    "  a beginner recognises (a semicolon \";\"), and to recognise common\n"
    "  beginner-mistake patterns and attach an explanatory hint.":
        "Esperar um tipo de token específico ou lançar um erro amigável.\n"
        "  [PT-BR] Aqui surgem a maioria dos erros de parse exibidos ao usuário.\n"
        "  O objetivo é traduzir nomes internos (\"tkSemicolon\") em termos que\n"
        "  um iniciante reconheça (\";\") e identificar erros comuns com dicas.",

    "var\n    x, y : Integer;\n    name  : String;":
        "Bloco var — declaração de variáveis",

    "procedure Foo(a: Integer; var b: String);\n  var ...\n  begin ... end;":
        "Análise de procedimento/função com parâmetros, var e begin..end",

    # ── UObjectRuntime.pas ──────────────────────────────────────────────────
    "A live object instance — one per  TFoo.Create  call":
        "Uma instância viva de objeto — uma por chamada  TFoo.Create",

    "Method resolution result":
        "Resultado da resolução de método",

    "The class registry — built from the parsed AST before running":
        "O registro de classes — construído a partir da AST antes da execução",

    "Walk the inheritance chain to find a method.\n"
    "  We start at ClassName and work up to parents until found or no parent.":
        "Percorrer a cadeia de herança para encontrar um método.\n"
        "  [PT-BR] Começa em ClassName e sobe até os pais até encontrar ou esgotar.",

    "Find a field's type by walking the inheritance chain":
        "Encontrar o tipo de um campo percorrendo a cadeia de herança",

    "Check interface conformance":
        "Verificar conformidade com interface",

    "IsDescendant: is AClass the same as or a subclass of BClass?":
        "IsDescendant: AClass é igual ou subclasse de BClass?",

    "Collect all fields for a class including inherited ones":
        "Coletar todos os campos de uma classe, incluindo os herdados",

    "Collect all methods visible on a class (most derived wins)":
        "Coletar todos os métodos visíveis em uma classe (o mais derivado tem prioridade)",

    # ── UValidator.pas ──────────────────────────────────────────────────────
    "Pass 1: collect all declared names so later passes can spot undeclared ones":
        "Passo 1: coletar todos os nomes declarados para que passos posteriores detectem nomes não declarados",

    "Pass 2: check the main block exists and is not empty":
        "Passo 2: verificar se o bloco principal existe e não está vazio",

    "Pass 3: check each routine":
        "Passo 3: verificar cada rotina",

    "Pass 4: check main block statements":
        "Passo 4: verificar as instruções do bloco principal",

    "Statement and expression walkers":
        "Percorrentes de instruções e expressões",

    "Main validation entry point":
        "Ponto de entrada principal da validação",

    "Results":
        "Resultados",

    "Source helpers":
        "Auxiliares de texto-fonte",

    # ── UUnitLoader.pas ─────────────────────────────────────────────────────
    "We look for the pattern:\n"
    "     uses\n"
    "       'file1.mdp',\n"
    "       'file2.mdp';\n"
    "  The filenames must be single-quoted strings.":
        "Procura pelo padrão:\n"
        "  [PT-BR]   uses\n"
        "              'arquivo1.mdp',\n"
        "              'arquivo2.mdp';\n"
        "  Os nomes de arquivo devem ser strings entre aspas simples.",

    "Load one unit file, parse it, store its routines":
        "Carregar um arquivo de unidade, fazer parse e armazenar suas rotinas",

    # ── UInterpreter.pas ────────────────────────────────────────────────────
    "is  operator  (type checking)":
        "operador  is  (verificação de tipo)",

    "Environment — a scope-aware variable store":
        "Ambiente — armazenamento de variáveis com consciência de escopo",

    "Built-in functions and procedures":
        "Funções e procedimentos embutidos",

    "Expression evaluators":
        "Avaliadores de expressão",

    "Statement executors":
        "Executores de instrução",

    "Routine invocation":
        "Invocação de rotinas",

    "OOP — object creation, method dispatch, field access":
        "OOP — criação de objetos, despacho de métodos, acesso a campos",

    # ── ULearnTab.pas ───────────────────────────────────────────────────────
    "One programming challenge":
        "Um desafio de programação",

    "One lesson (a named group of challenges)":
        "Uma lição (um grupo nomeado de desafios)",

    "The full curriculum":
        "O currículo completo",

    "Answer checker — runs code, applies strategy":
        "Verificador de respostas — executa o código e aplica a estratégia",

    "Progress store — persists completions between sessions":
        "Armazenamento de progresso — persiste conclusões entre sessões",

    "Certificate pop-up":
        "Janela pop-up de certificado",

    "The VCL Learn tab panel  (drop onto a TTabSheet)":
        "Painel VCL da aba Aprender  (coloque em um TTabSheet)",

    "Helpers":
        "Auxiliares",

    "CURRICULUM DATA\nEach challenge has a unique ID (never reuse or renumber — used as keys\nin the progress INI file).":
        "DADOS DO CURRÍCULO — cada desafio tem um ID único (nunca reutilize ou renumere — chave no INI de progresso)",

    "PROGRESS STORE":
        "ARMAZENAMENTO DE PROGRESSO",

    "CERTIFICATE FORM":
        "FORMULÁRIO DE CERTIFICADO",

    "Sync the TreeView selection to the current lesson/challenge":
        "Sincronizar a seleção da TreeView com a lição/desafio atual",

    "Update score label":
        "Atualizar rótulo de pontuação",

    "Update star display for current lesson":
        "Atualizar exibição de estrelas para a lição atual",

    # ── UProjectTab.pas ─────────────────────────────────────────────────────
    "Recent files list (persisted in INI)":
        "Lista de arquivos recentes (persistida em INI)",

    "Public API called by the main form's File menu":
        "API pública chamada pelo menu Arquivo do formulário principal",

    "THEME":
        "TEMA",

    "Project tree management":
        "Gerenciamento da árvore de projeto",

    "Run / Stop":
        "Executar / Parar",

    # ── UMacroTab.pas ───────────────────────────────────────────────────────
    "Parsed macro metadata":
        "Metadados de macro analisados",

    "Macro file scanning and loading":
        "Varredura e carregamento de arquivos de macro",

    "Trusted-macro INI store":
        "Armazenamento INI de macros confiáveis",

    "Build the tree":
        "Construir a árvore",

    "Shell execution with trust check":
        "Execução de shell com verificação de confiança",

    # ── UFormBuilderTab.pas ─────────────────────────────────────────────────
    "Design surface — drag/drop/select":
        "Superfície de design — arrastar/soltar/selecionar",

    "Object Inspector helpers":
        "Auxiliares do Inspetor de Objetos",

    "Palette tool selection":
        "Seleção de ferramenta da paleta",

    "Form file load / save":
        "Carregamento / salvamento de arquivo de formulário",

    "Runtime preview":
        "Pré-visualização em tempo de execução",

    # ── UMacroLibrary.pas ───────────────────────────────────────────────────
    "BACKUP & FILE MANAGEMENT":
        "BACKUP E GERENCIAMENTO DE ARQUIVOS",

    "TEXT & STRING UTILITIES":
        "UTILITÁRIOS DE TEXTO E STRING",

    "DATE & TIME":
        "DATA E HORA",

    "SYSTEM INFORMATION":
        "INFORMAÇÕES DO SISTEMA",

    "DEVELOPMENT TOOLS":
        "FERRAMENTAS DE DESENVOLVIMENTO",

    # ── UGraphics.pas ───────────────────────────────────────────────────────
    "Graphics window lifecycle":
        "Ciclo de vida da janela gráfica",

    "Drawing primitives":
        "Primitivas de desenho",

    "Text rendering":
        "Renderização de texto",

    "Input polling":
        "Consulta de entrada",

    "Colour parsing":
        "Análise de cores",

    "Color parsing":
        "Análise de cores",

    # ── USQLite.pas ─────────────────────────────────────────────────────────
    "SQLite DLL binding":
        "Vinculação da DLL SQLite",

    "Query result grid":
        "Grade de resultado de consulta",

    "Public API":
        "API pública",

    # ── UTheme.pas ──────────────────────────────────────────────────────────
    "VCL Styles repaints automatically.":
        "O VCL Styles repinta automaticamente.",

    "Theme application — all no-ops, VCL Styles handles it":
        "Aplicação de tema — todas são operações nulas; o VCL Styles cuida disso",

    # ── UMainForm.pas ───────────────────────────────────────────────────────
    "Compiler tab — run, tokenise, parse, show AST":
        "Aba Compilador — executar, tokenizar, analisar, exibir AST",

    "Calculator tab":
        "Aba Calculadora",

    "Snippet menu":
        "Menu de trechos de código",

    "Tab-triggered snippet expansion":
        "Expansão de trecho acionada por Tab",
}

# ---------------------------------------------------------------------------
#  Regex: matches a section divider block (--- or ═══ style)
# ---------------------------------------------------------------------------
DIVIDER_RE = re.compile(
    r'(?m)^([ \t]*// [-═]{3,}[ \t]*\n'   # opening dashes or double-lines
    r'(?:[ \t]*//[^\n]*\n)+'              # content lines
    r'[ \t]*// [-═]{3,}[ \t]*)',          # closing dashes
)

def extract_text(block):
    """Pull content lines out of a divider block, stripped."""
    lines = []
    all_lines = block.splitlines()
    for line in all_lines[1:-1]:  # skip first and last (the dash lines)
        stripped = re.sub(r'^[ \t]*//[ \t]*', '', line).strip()
        if stripped:
            lines.append(stripped)
    return '\n'.join(lines) if len(lines) > 1 else (lines[0] if lines else '')

def make_pt_line(english_block, pt_text, indent):
    """Format the [PT-BR] comment line to insert after the English block."""
    # Use same dash style as original
    if '═' in english_block:
        dashes = '═' * 53
    else:
        dashes = '-' * 67
    return f'{indent}// {dashes}\n{indent}// [PT-BR] {pt_text}\n{indent}// {dashes}'

def already_has_pt(text, pos):
    """Check if [PT-BR] already follows this block within 3 lines."""
    snippet = text[pos:pos + 300]
    return any('[PT-BR]' in l for l in snippet.split('\n')[:4])

def process(filepath):
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        original = f.read()

    # Find all divider blocks, work backwards to preserve positions
    matches = list(DIVIDER_RE.finditer(original))
    if not matches:
        return 0

    insertions = []  # (insert_pos, text_to_insert)

    for m in matches:
        if already_has_pt(original, m.end()):
            continue

        eng = extract_text(m.group(0))
        pt = TRANSLATIONS.get(eng)
        if not pt:
            # Try a shorter first-line-only match
            first_line = eng.split('\n')[0].strip()
            pt = TRANSLATIONS.get(first_line)

        if not pt:
            continue  # no translation found — leave untouched

        indent = re.match(r'^([ \t]*)', m.group(0)).group(1)
        pt_comment = make_pt_line(m.group(0), pt, indent)
        insertions.append((m.end(), '\n' + pt_comment))

    if not insertions:
        return 0

    # Apply insertions in reverse order
    new_text = original
    for pos, ins in reversed(insertions):
        new_text = new_text[:pos] + ins + new_text[pos:]

    backup = filepath + '.patch18.bak'
    shutil.copy2(filepath, backup)

    had_bom = original.startswith('\ufeff')
    with open(filepath, 'w', encoding='utf-8-sig' if had_bom else 'utf-8') as f:
        f.write(new_text)

    return len(insertions)

FILES = [
    'ULexer.pas', 'UAST.pas', 'UParser.pas', 'UInterpreter.pas',
    'UValidator.pas', 'UObjectRuntime.pas', 'UGraphics.pas', 'USQLite.pas',
    'UUnitLoader.pas', 'UTheme.pas', 'UMainForm.pas', 'ULearnTab.pas',
    'UProjectTab.pas', 'UExampleProjects.pas', 'UMacroTab.pas',
    'UMacroLibrary.pas', 'UAboutDialog.pas', 'UPreferencesDialog.pas',
    'UFormBuilderTab.pas', 'UFormDef.pas',
]

def main():
    src = os.path.abspath(next((a for a in sys.argv[1:] if not a.startswith('--')), '.'))
    print()
    print('=' * 68)
    print('  Pythia Patch 18 \u2014 Add PT-BR Inline Comment Translations')
    print(f'  Target : {src}')
    print(f'  Date   : {datetime.now().strftime("%Y-%m-%d %H:%M")}')
    print(f'  Translations available: {len(TRANSLATIONS)}')
    print('=' * 68)
    print()

    total_files = 0
    total_blocks = 0

    for filename in FILES:
        filepath = os.path.join(src, filename)
        if not os.path.exists(filepath):
            print(f'[ {filename} ]  \u26a0  Not found \u2014 skipped')
            print()
            continue
        print(f'[ {filename} ]')
        n = process(filepath)
        if n == 0:
            print('  \u2013  No matching section headers found.')
        else:
            print(f'  \u2713  Inserted {n} [PT-BR] block(s).')
            print(f'  Backup \u2192 {filename}.patch18.bak')
            total_files += 1
            total_blocks += n
        print()

    # Report unmatched blocks (for adding to TRANSLATIONS later)
    print('=' * 68)
    print(f'  Done.  Files changed: {total_files}  |  Blocks inserted: {total_blocks}')
    print()
    print('  Any section headers not in the translation table were left')
    print('  untouched. Add them to TRANSLATIONS in this script and re-run.')
    print('=' * 68)
    print()


if __name__ == '__main__':
    main()