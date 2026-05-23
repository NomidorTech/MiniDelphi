#!/usr/bin/env python3
"""
patch17_portuguese_headers.py  —  Pythia Patch 17
Add Portuguese (pt-BR) description headers beneath the English ones
in every .pas source file.

Structure added after the existing English description block:

    // =============================================================================
    // [PT-BR] UXxx.pas  -  <translated description>
    // ...
    // =============================================================================

Usage:
    python patch17_portuguese_headers.py <path-to-source-folder>

Safe to re-run: skips files that already contain [PT-BR].
Writes a .patch17.bak backup next to each file it changes.
"""

import sys, os, re, shutil
from datetime import datetime

# ---------------------------------------------------------------------------
#  Portuguese translations for each file's description block.
#  Key   = unique phrase that identifies the English description block.
#  Value = the full Portuguese block to insert after it.
#
#  Translation notes:
#    - Technical terms (AST, VCL, INI, GPL, MCP) are kept in English.
#    - Pascal keywords (begin, end, uses, var) are kept as-is.
#    - "Pythia" is never translated.
# ---------------------------------------------------------------------------
PT_BLOCKS = {

    # ── Pythia.dpr ──────────────────────────────────────────────────────────
    'Pythia.dpr  -  Project file for Pythia': """\
// =============================================================================
// [PT-BR] Pythia.dpr  -  Arquivo de projeto do Pythia
//
//  Unidades neste projeto:
//    ULexer.pas             — Analisador léxico (tokenizador)
//    UAST.pas               — Definições dos nós da Árvore Sintática Abstrata
//    UParser.pas            — Analisador sintático (descida recursiva)
//    UInterpreter.pas       — Interpretador em modo árvore (runtime)
//    UMainForm.pas          — Formulário principal VCL
//    UUnitLoader.pas        — Sistema de importação de unidades (.mdp uses)
//    UTheme.pas             — Wrapper de estilos VCL
//    UPreferencesDialog.pas — Diálogo de preferências de tema
// =============================================================================""",

    # ── ULexer.pas ──────────────────────────────────────────────────────────
    'ULexer.pas  -  Lexical Analyser for Pythia': """\
// =============================================================================
// [PT-BR] ULexer.pas  -  Analisador Léxico do Pythia
//  Divide o texto-fonte em uma sequência de tokens.
//  Compatível com Embarcadero Delphi 13 / Win64 / VCL
// =============================================================================""",

    # ── UAST.pas ────────────────────────────────────────────────────────────
    'Abstract Syntax Tree node definitions': """\
// =============================================================================
// [PT-BR] UAST.pas  -  Definições dos nós da Árvore Sintática Abstrata (AST)
//  Cada nó representa uma construção da linguagem Pascal:
//  declarações, instruções, expressões e o programa completo.
// =============================================================================""",

    # ── UParser.pas ─────────────────────────────────────────────────────────
    'UParser.pas  -  Recursive-descent parser for Pythia': """\
// =============================================================================
// [PT-BR] UParser.pas  -  Analisador Sintático do Pythia (descida recursiva)
//  Consome a lista de tokens produzida pelo TLexer e constrói a AST TProgramNode.
// =============================================================================""",

    # ── UInterpreter.pas ────────────────────────────────────────────────────
    'UInterpreter.pas  -  Tree-walking interpreter for Pythia': """\
// =============================================================================
// [PT-BR] UInterpreter.pas  -  Interpretador em Modo Árvore do Pythia
//  Percorre a AST produzida pelo TParser e executa cada nó diretamente.
//  Nenhum código de máquina é gerado — este módulo É o "runtime".
// =============================================================================""",

    # ── UValidator.pas ──────────────────────────────────────────────────────
    'UValidator.pas  -  Pre-run validation pass for Pythia': """\
// =============================================================================
// [PT-BR] UValidator.pas  -  Passo de validação pré-execução do Pythia
//  Chamado entre o parse e a execução. Percorre a AST e o texto-fonte
//  para capturar erros comuns antes que o interpretador os toque.
// =============================================================================""",

    # ── UMainForm.pas ───────────────────────────────────────────────────────
    'UMainForm.pas  -  VCL front-end for Pythia': """\
// =============================================================================
// [PT-BR] UMainForm.pas  -  Interface VCL principal do Pythia
//  Estilizado via VCL Styles (TStyleManager). Consulte UTheme.pas para detalhes.
// =============================================================================""",

    # ── UTheme.pas ──────────────────────────────────────────────────────────
    'UTheme.pas': """\
// =============================================================================
// [PT-BR] UTheme.pas  —  Wrapper fino em torno dos VCL Styles (TStyleManager).
//
//  Modos de tema:
//     tmDark           — aplica um estilo escuro (Carbon)
//     tmLight          — aplica um estilo claro (Iceberg Classico)
//     tmFollowWindows  — lê o registro do sistema e escolhe claro/escuro
//
//  A API pública é preservada: Theme.Mode, Theme.Subscribe, Theme.ApplyForm etc.
//  Os métodos Apply* são operações nulas — o VCL Styles cuida de toda a pintura.
//
//  Persistência: salvo em <exe>.settings.ini como antes.
// =============================================================================""",

    # ── ULearnTab.pas ───────────────────────────────────────────────────────
    'ULearnTab.pas  -  "Learn Delphi" interactive teaching tab': """\
// =============================================================================
// [PT-BR] ULearnTab.pas  -  Aba interativa de ensino "Aprenda Pascal"
//
//  Arquitetura
//  ───────────
//  TLearnCurriculum   — contém todas as lições e desafios (dados puros)
//  TAnswerChecker     — executa o código do aluno e decide aprovado/reprovado
//  TProgressStore     — lembra quais desafios foram concluídos (arquivo INI)
//  TLearnTab          — painel VCL que controla tudo
//  TCertificateForm   — janela de certificado ao concluir todos os desafios
//
//  Estratégias de verificação (TCheckKind)
//  ───────────────────────────────────────
//  ckExactOutput      — saída deve corresponder exatamente à string esperada
//  ckContainsAll      — saída deve conter todas as strings da lista de verificação
//  ckOutputIsNumber   — saída (sem espaços) deve ser um número igual a N
//  ckOutputInRange    — número da saída deve estar entre Lo e Hi
//  ckLineCount        — saída deve ter exatamente N linhas
//  ckAnyOutput        — qualquer saída não vazia é aprovada (exercícios livres)
// =============================================================================""",

    # ── UProjectTab.pas ─────────────────────────────────────────────────────
    'UProjectTab.pas  —  Project IDE tab for Pythia': """\
// =============================================================================
// [PT-BR] UProjectTab.pas  —  Aba IDE de Projetos do Pythia (estilo Delphi)
//
//  Modelo de Projeto
//  ─────────────────
//  O arquivo .mdproj É o projeto. Sua seção [Source] contém o código-fonte
//  principal. Não existe um arquivo .mdp separado para o programa principal —
//  o fonte fica dentro do próprio .mdproj (como um .dpr do Delphi real).
//
//  A seção [Files] lista os arquivos .mdp de biblioteca usados pelo projeto.
//  Os caminhos são relativos ao .mdproj para que os projetos sejam portáteis.
//
//  Barra de ferramentas
//  ────────────────────
//  Apenas Run / Stop / Insert. Todas as operações de arquivo são acessadas
//  pelo menu File do formulário principal, que chama os métodos Do* desta aba.
//
//  API pública para integração com menus
//  ──────────────────────────────────────
//    DoNewFile, DoOpenFile, DoSave, DoSaveAs
//    DoNewProject, DoOpenProject, DoCloseProject
//    DoRun, ViewProjectSource
//    HasProject  — flag somente leitura
// =============================================================================""",

    # ── UExampleProjects.pas ────────────────────────────────────────────────
    'UExampleProjects.pas  —  30 fully-documented Pythia example projects': """\
// =============================================================================
// [PT-BR] UExampleProjects.pas  —  30 projetos de exemplo do Pythia totalmente documentados
//
//  Cada exemplo é uma string de código-fonte .mdp autocontida com:
//    • Um bloco de cabeçalho explicando o que o programa faz e o que ensina
//    • Comentários em cada linha não trivial
//    • Momentos de ensino destacados com  // *** NOTA: ...
//
//  Usado pelo UProjectTab para popular o painel de Exemplos.
// =============================================================================""",

    # ── UUnitLoader.pas ─────────────────────────────────────────────────────
    'UUnitLoader.pas  —  Unit import system for': """\
// =============================================================================
// [PT-BR] UUnitLoader.pas  —  Sistema de importação de unidades do Pythia
//
//  Permite que um programa .mdp importe rotinas de outros arquivos .mdp:
//
//      uses
//        'MatematicaHelper.mdp',
//        'StringUtils.mdp';
//
//  Um arquivo .mdp de biblioteca não possui bloco principal begin..end —
//  apenas declarações de var e procedure/function. Se possuir um bloco
//  principal, ele é silenciosamente ignorado (apenas as rotinas são importadas).
//
//  Arquitetura
//  ───────────
//  TUnitLoader.LoadUnits(MainSource, BaseDir)
//    1. Verifica a cláusula uses do código-fonte principal em busca de nomes
//    2. Carrega cada arquivo do disco (relativo a BaseDir)
//    3. Faz o léxico e parse de cada um
//    4. Coleta todos os nós TRoutineDecl em uma lista plana
//    5. Retorna essa lista — o interpretador a mescla com as rotinas do programa principal
//
//  Importações circulares são detectadas e ignoradas.
//  Arquivos ausentes geram uma mensagem de erro clara.
// =============================================================================""",

    # ── UObjectRuntime.pas ──────────────────────────────────────────────────
    'TObjectInstance': """\
// =============================================================================
// [PT-BR] UObjectRuntime.pas  —  Suporte a classes e objetos em tempo de execução
//  Implementa instâncias de objetos, herança, métodos virtuais e o registro
//  global de classes usado pelo interpretador do Pythia.
// =============================================================================""",

    # ── UGraphics.pas ───────────────────────────────────────────────────────
    'GfxOpen': """\
// =============================================================================
// [PT-BR] UGraphics.pas  —  Funções gráficas integradas do Pythia (GfxXxx)
//  Fornece uma janela de desenho simples acessível a partir de programas .mdp
//  via GfxOpen, GfxLine, GfxRect, GfxCircle, GfxText e outros.
// =============================================================================""",

    # ── USQLite.pas ─────────────────────────────────────────────────────────
    'DbOpen': """\
// =============================================================================
// [PT-BR] USQLite.pas  —  Funções integradas de banco de dados do Pythia (DbXxx)
//  Fornece acesso SQLite a programas .mdp via DbOpen, DbExec, DbQuery e outros.
//  Requer sqlite3.dll ao lado do Pythia.exe.
// =============================================================================""",

    # ── UFormBuilderTab.pas ─────────────────────────────────────────────────
    'UFormBuilderTab.pas  —  Visual form designer tab': """\
// =============================================================================
// [PT-BR] UFormBuilderTab.pas  —  Aba de designer visual de formulários
//
//  Layout
//  ──────
//    Topo:     barra de ferramentas — Novo / Abrir / Salvar / Salvar Como / Excluir
//    Esquerda: lista de arquivos .mdfrm no projeto atual
//    Centro-E: paleta vertical (Ponteiro / Label / Button / Edit)
//    Centro:   superfície de design
//    Direita:  Inspetor de Objetos
//
//  Estilizado pelo VCL Styles (via UTheme). Sem código de cor por controle.
// =============================================================================""",

    # ── UFormDef.pas ────────────────────────────────────────────────────────
    'TFormDef': """\
// =============================================================================
// [PT-BR] UFormDef.pas  —  Modelo de definição de formulário (.mdfrm)
//  Define TFormDef e TControlDef — as estruturas de dados que representam
//  um formulário Pythia e seus controles, usados pelo UFormBuilderTab.
// =============================================================================""",

    # ── UMacroTab.pas ───────────────────────────────────────────────────────
    'UMacroTab.pas  -  Macros tab UI': """\
// =============================================================================
// [PT-BR] UMacroTab.pas  -  Interface da aba de Macros
//
//  Macros ficam em:  %USERPROFILE%\\Documents\\MiniDelphi\\Macros\\
//  Cada macro é um arquivo .mdp com metadados no cabeçalho:
//
//      // @name        Nome da Macro
//      // @description Descrição em uma linha
//      // @category    Grupo ao qual pertence
//
//  Funcionalidades
//  ───────────────
//   • Árvore de macros agrupadas por @category
//   • Editor de código-fonte para a macro selecionada
//   • Botões Run / Stop / Save / New
//   • Alternância "Confiável" por macro: permite chamadas Shell* silenciosamente
//   • Propagação inicial de macros a partir do UMacroLibrary
// =============================================================================""",

    # ── UMacroLibrary.pas ───────────────────────────────────────────────────
    'UMacroLibrary.pas  -  Curated starter library': """\
// =============================================================================
// [PT-BR] UMacroLibrary.pas  -  Biblioteca inicial de macros de automação
//
//  Cada macro é um arquivo .mdp autocontido com metadados no comentário
//  de cabeçalho:
//
//      // @name        Nome legível da macro
//      // @description Resumo em uma linha exibido na lista
//      // @category    Grupo em que aparece
//
//  Na primeira execução, a aba Macros verifica a pasta de macros do usuário
//  e a propaga com essas macros iniciais se estiver vazia.
//  O usuário pode editar, excluir ou estendê-las livremente.
// =============================================================================""",

    # ── UAboutDialog.pas ────────────────────────────────────────────────────
    'Programmer': """\
// =============================================================================
// [PT-BR] UAboutDialog.pas  —  Diálogo "Sobre" e Guia do Programador
//  Exibe informações de versão, licença e uma referência rápida da linguagem
//  Pascal suportada pelo Pythia.
// =============================================================================""",

    # ── UPreferencesDialog.pas ──────────────────────────────────────────────
    'Preferences': """\
// =============================================================================
// [PT-BR] UPreferencesDialog.pas  —  Diálogo de Preferências (View → Preferences)
//  Permite ao usuário escolher entre os modos de tema:
//  Escuro (Carbon), Claro (Iceberg Classico) ou Seguir o Windows.
// =============================================================================""",
}

# ---------------------------------------------------------------------------
#  The description block regex: matches the SECOND ===...=== block
#  (the one after the copyright block that describes the file's purpose)
# ---------------------------------------------------------------------------
DESC_BLOCK_RE = re.compile(
    r'(// =+\n'           # opening ===
    r'(?://[^\n]*\n)+'    # one or more // lines
    r'// =+)',            # closing ===
    re.MULTILINE
)

def find_description_block(text):
    """
    Return (match, block_index) for the SECOND ===...=== block in the file.
    The first block is the copyright block; the second is the description.
    Returns (None, -1) if fewer than two blocks exist.
    """
    matches = list(DESC_BLOCK_RE.finditer(text))
    if len(matches) >= 2:
        return matches[1], matches[1].end()
    return None, -1

def already_patched(text):
    return '[PT-BR]' in text

def find_translation(text):
    """Return the Portuguese block to insert, or None if no match."""
    for key, pt_block in PT_BLOCKS.items():
        if key in text:
            return pt_block
    return None

def process(filepath):
    if not os.path.exists(filepath):
        return 'missing', ['  ⚠  Not found — skipped']

    with open(filepath, 'r', encoding='utf-8-sig') as f:
        original = f.read()

    if already_patched(original):
        return 'skip', ['  ✓  Already has [PT-BR] block — skipped']

    pt_block = find_translation(original)
    if pt_block is None:
        return 'skip', [f'  –  No translation key matched — skipped']

    match, insert_at = find_description_block(original)
    if insert_at == -1:
        return 'skip', ['  –  Could not locate description block — skipped']

    # Insert the Portuguese block immediately after the English description block
    new_text = original[:insert_at] + '\n\n' + pt_block + original[insert_at:]

    # Verify no new lines > 1023 chars
    bad = [(i+1, len(l)) for i, l in enumerate(new_text.splitlines()) if len(l) > 1023]
    if bad:
        return 'error', [f'  ✗  Line {ln} too long ({llen} chars) — skipped' for ln, llen in bad]

    backup = filepath + '.patch17.bak'
    shutil.copy2(filepath, backup)

    had_bom = original.startswith('\ufeff')
    with open(filepath, 'w', encoding='utf-8-sig' if had_bom else 'utf-8') as f:
        f.write(new_text)

    return 'changed', [
        f'  Inserted [PT-BR] block after English description',
        f'  Backup → {os.path.basename(backup)}',
    ]

FILES = [
    'Pythia.dpr',
    'ULexer.pas',
    'UAST.pas',
    'UParser.pas',
    'UInterpreter.pas',
    'UValidator.pas',
    'UMainForm.pas',
    'UTheme.pas',
    'ULearnTab.pas',
    'UProjectTab.pas',
    'UExampleProjects.pas',
    'UUnitLoader.pas',
    'UObjectRuntime.pas',
    'UGraphics.pas',
    'USQLite.pas',
    'UFormBuilderTab.pas',
    'UFormDef.pas',
    'UMacroTab.pas',
    'UMacroLibrary.pas',
    'UAboutDialog.pas',
    'UPreferencesDialog.pas',
]

def main():
    src = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else '.')
    print()
    print('=' * 68)
    print('  Pythia Patch 17 — Portuguese (pt-BR) Description Headers')
    print(f'  Target : {src}')
    print(f'  Date   : {datetime.now().strftime("%Y-%m-%d %H:%M")}')
    print('=' * 68)
    print()

    counts = {'changed': 0, 'skip': 0, 'missing': 0, 'error': 0}

    for filename in FILES:
        filepath = os.path.join(src, filename)
        print(f'[ {filename} ]')
        status, lines = process(filepath)
        counts[status] = counts.get(status, 0) + 1
        for l in lines:
            print(l)
        print()

    print('=' * 68)
    print(f"  Done.  Changed: {counts['changed']}  |  "
          f"Skipped: {counts['skip']}  |  "
          f"Not found: {counts['missing']}")
    print()
    print('  Backups written as <file>.patch17.bak next to each changed file.')
    print('  Delete them once the build compiles cleanly.')
    print('=' * 68)
    print()

if __name__ == '__main__':
    main()