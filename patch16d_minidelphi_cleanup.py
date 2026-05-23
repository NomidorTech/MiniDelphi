#!/usr/bin/env python3
"""
patch16d_minidelphi_cleanup.py  —  Pythia Patch 16d
Remove remaining 'MiniDelphi' references from description blocks
in UGraphics.pas and UObjectRuntime.pas.

These were missed by Patch 16 because both files already had GPL v3
headers and were skipped by the already_patched() check.

Usage:
    py patch16d_minidelphi_cleanup.py <source-folder>
    py patch16d_minidelphi_cleanup.py C:\\holder\\MiniDelphi\\MiniDelphi
"""

import sys, os, re, shutil
from datetime import datetime

# ---------------------------------------------------------------------------
#  Each entry: (regex_pattern, replacement, description)
#  Using re.sub so we handle em-dash / en-dash / hyphen variants safely.
# ---------------------------------------------------------------------------
FILE_FIXES = {

    'UGraphics.pas': [
        (
            r'// MiniDelphi Toy Compiler & Learning IDE\r?\n(// Copyright)',
            '// Pythia \u2014 A Pascal Learning Environment\n\\1',
            "Copyright block first line: 'MiniDelphi Toy Compiler' \u2192 'Pythia \u2014 A Pascal Learning Environment'",
        ),
        (
            r'//  UGraphics\.pas  -  Thread-safe animation window for MiniDelphi',
            '//  UGraphics.pas  -  Thread-safe animation window for Pythia',
            "Description: 'animation window for MiniDelphi' \u2192 '...for Pythia'",
        ),
        (
            r'//    The MiniDelphi interpreter runs on the MAIN thread\.',
            '//    The Pythia interpreter runs on the MAIN thread.',
            "Description: 'MiniDelphi interpreter' \u2192 'Pythia interpreter'",
        ),
    ],

    'UObjectRuntime.pas': [
        (
            r'//  UObjectRuntime\.pas  [\u2013\u2014\-]+  Object-oriented runtime for MiniDelphi',
            '//  UObjectRuntime.pas  \u2014  Object-oriented runtime for Pythia',
            "Description title: 'runtime for MiniDelphi' \u2192 'runtime for Pythia'",
        ),
        (
            r'//  When MiniDelphi runs  dog := TDog\.Create:',
            '//  When Pythia runs  dog := TDog.Create:',
            "Example comment: 'When MiniDelphi runs dog := TDog.Create' \u2192 'When Pythia runs...'",
        ),
        (
            r'//  When MiniDelphi runs  dog\.Speak:',
            '//  When Pythia runs  dog.Speak:',
            "Example comment: 'When MiniDelphi runs dog.Speak' \u2192 'When Pythia runs...'",
        ),
    ],
}


def process(filepath, fixes):
    if not os.path.exists(filepath):
        return 'missing', ['  \u26a0  Not found \u2014 skipped']

    with open(filepath, 'r', encoding='utf-8-sig') as f:
        original = f.read()

    header = '\n'.join(original.splitlines()[:40])
    if 'MiniDelphi' not in header:
        return 'skip', ['  \u2713  Already clean \u2014 skipped']

    text = original
    changes = []

    for pattern, replacement, desc in fixes:
        new_text, n = re.subn(pattern, replacement, text)
        if n > 0:
            text = new_text
            changes.append(f'  \u2713  {desc}')

    if text == original:
        remaining = [l.strip() for l in original.splitlines()[:40] if 'MiniDelphi' in l]
        lines = ['  \u26a0  No patterns matched. MiniDelphi still in header:']
        lines += [f'      {l}' for l in remaining]
        return 'error', lines

    # Verify clean
    remaining = [l.strip() for l in text.splitlines()[:40] if 'MiniDelphi' in l]
    if remaining:
        status = 'warn'
        changes.append('  \u26a0  WARNING: MiniDelphi still present:')
        changes += [f'      {l}' for l in remaining]
    else:
        status = 'changed'
        changes.append('  \u2713  Header is clean.')

    backup = filepath + '.patch16d.bak'
    shutil.copy2(filepath, backup)
    changes.append(f'  Backup \u2192 {os.path.basename(backup)}')

    had_bom = original.startswith('\ufeff')
    with open(filepath, 'w', encoding='utf-8-sig' if had_bom else 'utf-8') as f:
        f.write(text)

    return status, changes


def main():
    src = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else '.')
    print()
    print('=' * 68)
    print('  Pythia Patch 16d \u2014 Remove remaining MiniDelphi from headers')
    print(f'  Target : {src}')
    print(f'  Date   : {datetime.now().strftime("%Y-%m-%d %H:%M")}')
    print('=' * 68)
    print()

    counts = {'changed': 0, 'skip': 0, 'missing': 0, 'error': 0, 'warn': 0}

    for filename, fixes in FILE_FIXES.items():
        filepath = os.path.join(src, filename)
        print(f'[ {filename} ]')
        status, lines = process(filepath, fixes)
        counts[status] = counts.get(status, 0) + 1
        for l in lines:
            print(l)
        print()

    print('=' * 68)
    print(f"  Done.  Changed: {counts['changed']}  |  "
          f"Skipped: {counts['skip']}  |  "
          f"Not found: {counts['missing']}")
    print()
    print('  Backups written as <file>.patch16d.bak next to each changed file.')
    print('  Delete them once the build compiles cleanly.')
    print('=' * 68)
    print()


if __name__ == '__main__':
    main()