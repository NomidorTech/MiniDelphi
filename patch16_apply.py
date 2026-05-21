#!/usr/bin/env python3
"""
patch16_apply.py  —  Pythia Patch 16
GPL v3 License Header Standardisation
Nomidor Software, LLC  —  2026-05-21

Usage:
    python patch16_apply.py <path-to-pythia-source-folder>

    If no path is given, the current directory is used.

What it does:
    - Replaces the old "All rights reserved / MiniDelphi" copyright block
      at the top of each .pas file and Pythia.dpr with the standard GPL v3 header
    - Fixes Application.Title in Pythia.dpr  ('MiniDelphi Toy Compiler' -> 'Pythia')
    - Fixes the internal .dpr description comment
    - Fixes "MiniDelphi" -> "Pythia" in UExampleProjects.pas description block
    - Fixes "MiniDelphi Toy Compiler" -> "Pythia" in ULexer.pas description block
    - Leaves all other file content byte-for-byte identical
    - Prints a clear summary of every change made
    - Safe to re-run: skips files that already have the correct header
    - Writes a .patch16.bak backup next to each file it changes
"""

import sys, os, re, shutil
from datetime import datetime

# ---------------------------------------------------------------------------
#  Standard GPL v3 short header — applied to every file
# ---------------------------------------------------------------------------
GPL_HEADER = (
    "// =============================================================================\n"
    "// Pythia \u2014 A Pascal Learning Environment\n"
    "// Copyright (C) 2026 Nomidor Software, LLC.\n"
    "//\n"
    "// This program is free software: you can redistribute it and/or modify\n"
    "// it under the terms of the GNU General Public License as published by\n"
    "// the Free Software Foundation, either version 3 of the License, or\n"
    "// (at your option) any later version.\n"
    "//\n"
    "// See the LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html\n"
    "// ============================================================================="
)

# ---------------------------------------------------------------------------
#  Regex: matches the old "Copyright (c)" block (first === block only)
# ---------------------------------------------------------------------------
OLD_HEADER_RE = re.compile(
    r'// =+\r?\n'
    r'// Copyright \(c\) \d+ Nomidor[^\n]*\n'
    r'(?:// [^\n]*\n|//\n)*?'   # non-greedy: stops at first closing ===
    r'// =+',
    re.MULTILINE
)

def already_patched(text):
    return 'GNU General Public License' in text or 'gpl-3.0' in text

def replace_header(text, filename):
    changes = []
    m = OLD_HEADER_RE.search(text)
    if m:
        old = m.group(0)
        text = text[:m.start()] + GPL_HEADER + text[m.end():]
        changes.append(f'  Replaced old copyright block ({len(old.splitlines())} lines)')
    else:
        # No recognised block — insert after the first line
        lines = text.splitlines(keepends=True)
        text = lines[0] + '\n' + GPL_HEADER + '\n' + ''.join(lines[1:])
        changes.append('  No old header found — inserted GPL v3 header after line 1')
    return text, changes

# ---------------------------------------------------------------------------
#  Per-file extra fixes
# ---------------------------------------------------------------------------
def fix_pythia_dpr(text):
    changes = []
    subs = [
        ("Application.Title := 'MiniDelphi Toy Compiler';",
         "Application.Title := 'Pythia';",
         "Application.Title: 'MiniDelphi Toy Compiler' -> 'Pythia'"),
        ("//  MiniDelphi.dpr  -  Project file for the MiniDelphi Toy Compiler",
         "//  Pythia.dpr  -  Project file for Pythia",
         "Description comment: MiniDelphi.dpr -> Pythia.dpr"),
    ]
    for old, new, desc in subs:
        if old in text:
            text = text.replace(old, new)
            changes.append(f'  {desc}')
    return text, changes

def fix_example_projects(text):
    changes = []
    subs = [
        ("//  UExampleProjects.pas  \u2014  30 fully-documented MiniDelphi example projects",
         "//  UExampleProjects.pas  \u2014  30 fully-documented Pythia example projects",
         "Description: 'MiniDelphi example projects' -> 'Pythia example projects'"),
    ]
    for old, new, desc in subs:
        if old in text:
            text = text.replace(old, new)
            changes.append(f'  {desc}')
    return text, changes

def fix_lexer(text):
    changes = []
    subs = [
        ("//  ULexer.pas  -  Lexical Analyser for the MiniDelphi Toy Compiler",
         "//  ULexer.pas  -  Lexical Analyser for Pythia",
         "Description: 'MiniDelphi Toy Compiler' -> 'Pythia'"),
    ]
    for old, new, desc in subs:
        if old in text:
            text = text.replace(old, new)
            changes.append(f'  {desc}')
    return text, changes

# ---------------------------------------------------------------------------
#  Files to process: (filename, extra_fix_or_None)
# ---------------------------------------------------------------------------
FILES = [
    ('Pythia.dpr',             fix_pythia_dpr),
    ('ULexer.pas',             fix_lexer),
    ('UProjectTab.pas',        None),
    ('UExampleProjects.pas',   fix_example_projects),
    ('UUnitLoader.pas',        None),
    ('ULearnTab.pas',          None),
    ('UFormBuilderTab.pas',    None),
    ('UTheme.pas',             None),
    ('UAST.pas',               None),
    ('UMacroLibrary.pas',      None),
    ('UObjectRuntime.pas',     None),
    ('UGraphics.pas',          None),
    ('USQLite.pas',            None),
    ('UAboutDialog.pas',       None),
    ('UPreferencesDialog.pas', None),
    ('UFormDef.pas',           None),
]

ALREADY_CORRECT = [
    'UMacroTab.pas',
    'UMainForm.pas',
    'UParser.pas',
    'UValidator.pas',
    'UInterpreter.pas',
]

# ---------------------------------------------------------------------------
#  Main
# ---------------------------------------------------------------------------
def process(filepath, extra_fix):
    if not os.path.exists(filepath):
        return 'missing', ['  \u26a0  File not found \u2014 skipped']

    with open(filepath, 'r', encoding='utf-8-sig') as f:
        original = f.read()

    if already_patched(original):
        return 'skip', ['  \u2713  Already has GPL v3 header \u2014 skipped']

    text = original
    all_changes = []

    text, ch = replace_header(text, os.path.basename(filepath))
    all_changes.extend(ch)

    if extra_fix:
        text, ch = extra_fix(text)
        all_changes.extend(ch)

    if text == original:
        return 'skip', ['  (no changes needed)']

    backup = filepath + '.patch16.bak'
    shutil.copy2(filepath, backup)

    had_bom = original.startswith('\ufeff')
    enc = 'utf-8-sig' if had_bom else 'utf-8'
    with open(filepath, 'w', encoding=enc) as f:
        f.write(text)

    all_changes.append(f'  Backup \u2192 {os.path.basename(backup)}')
    return 'changed', all_changes


def main():
    src = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else '.')
    print()
    print('=' * 68)
    print('  Pythia Patch 16 \u2014 GPL v3 Header Standardisation')
    print(f'  Target : {src}')
    print(f'  Date   : {datetime.now().strftime("%Y-%m-%d %H:%M")}')
    print('=' * 68)
    print()

    counts = {'changed': 0, 'skip': 0, 'missing': 0}

    for filename, extra_fix in FILES:
        filepath = os.path.join(src, filename)
        print(f'[ {filename} ]')
        status, lines = process(filepath, extra_fix)
        counts[status] += 1
        for l in lines:
            print(l)
        print()

    print('[ Already correct \u2014 untouched ]')
    for f in ALREADY_CORRECT:
        print(f'  \u2713  {f}')
    print()

    print('=' * 68)
    print(f"  Done.  Changed: {counts['changed']}  |  "
          f"Skipped: {counts['skip']}  |  "
          f"Not found: {counts['missing']}")
    print()
    print('  Backups written as <file>.patch16.bak next to each changed file.')
    print('  Delete them once you have verified the build compiles cleanly.')
    print('=' * 68)
    print()


if __name__ == '__main__':
    main()
