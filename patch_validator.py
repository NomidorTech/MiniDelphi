#!/usr/bin/env python3
"""
patch_validator.py  -  Expands the BUILTINS array in UValidator.pas.

Adds INI builtins (inireadstr, iniwritestr, inireadint, iniwriteint)
plus other missing names: datestr, timestr, strtointdef, shell,
shellwait, shellhidden, urlencode, getenvvar.

Usage:
    python patch_validator.py
    python patch_validator.py UValidator.pas

A .bak backup is written before any changes.
"""

import sys
import os
import re
import shutil

NEW_BUILTINS = (
    "  BUILTINS : array[0..94] of string = (\n"
    "    // Math\n"
    "    'abs','sqr','sqrt','round','trunc','int','frac',\n"
    "    'sin','cos','ln','exp','pi','power','max','min','odd',\n"
    "    'succ','pred','inc','dec','random','randomize',\n"
    "    // String\n"
    "    'length','copy','pos','uppercase','lowercase','trim',\n"
    "    'inttostr','strtoint','strtointdef','strtofloat','floattostr',\n"
    "    'str','val','chr','ord',\n"
    "    // UI\n"
    "    'showmessage','inputbox','confirm','showinfobox',\n"
    "    'showwarningbox','showerrorbox',\n"
    "    // File dialogs\n"
    "    'openfiledialog','savefiledialog','selectdirectorydialog',\n"
    "    // File I/O\n"
    "    'writefile','appendfile','readfile','fileexists',\n"
    "    'deletefile','getapppath','getdesktoppath',\n"
    "    // Database\n"
    "    'dbopen','dbclose','dbexec','dbquery','dbqueryvalue',\n"
    "    'dblasterror','dbisopen','dbfilename',\n"
    "    // INI\n"
    "    'inireadstr','iniwritestr','inireadint','iniwriteint',\n"
    "    // Date / time / env\n"
    "    'datestr','timestr','getenvvar','urlencode',\n"
    "    // Shell\n"
    "    'shell','shellwait','shellhidden',\n"
    "    // Graphics\n"
    "    'gfxopen','gfxclose','gfxclear','gfxshow','gfxdelay','gfxrunning',\n"
    "    'gfxcolor','gfxpenwidth',\n"
    "    'gfxdrawline','gfxdrawrect','gfxfillrect',\n"
    "    'gfxdrawcircle','gfxfillcircle',\n"
    "    'gfxdrawellipse','gfxfillellipse',\n"
    "    'gfxdrawtext','gfxsetfont','gfxdrawpixel',\n"
    "    'gfxkeypressed','gfxreadkey',\n"
    "    'gfxmousex','gfxmousey','gfxmousedown',\n"
    "    // Special\n"
    "    'writeln','write','readln','result'\n"
    "  );"
)


def replace_builtins(source):
    pattern = re.compile(
        r"BUILTINS\s*:\s*array\[0\.\.\d+\]\s*of\s*string\s*=\s*\(.*?\);",
        re.DOTALL | re.IGNORECASE,
    )
    match = pattern.search(source)
    if not match:
        print("  ERROR: BUILTINS array not found.", file=sys.stderr)
        print("  Apply patch3_UValidator.txt manually.", file=sys.stderr)
        return source, False
    modified = source[: match.start()] + NEW_BUILTINS + source[match.end():]
    return modified, True


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "UValidator.pas"
    if not os.path.isfile(path):
        print(f"Error: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    with open(path, "r", encoding="utf-8-sig") as fh:
        original = fh.read()

    if "inireadstr" in original.lower():
        print("Already patched — nothing to do.")
        sys.exit(0)

    bak = path + ".bak"
    shutil.copy2(path, bak)
    print(f"Backup -> {bak}")

    source, changed = replace_builtins(original)
    if not changed:
        sys.exit(1)

    m = re.search(r"BUILTINS\s*:\s*array\[0\.\.(\d+)\]", source, re.IGNORECASE)
    n = int(m.group(1)) + 1 if m else -1
    print(f"  + BUILTINS replaced ({n} entries)")

    with open(path, "w", encoding="utf-8") as fh:
        fh.write(source)
    print(f"Done. {path} updated.")


if __name__ == "__main__":
    main()
