#!/usr/bin/env python3
"""
patch_validator.py  -  Adds missing builtins to UValidator.pas.

Appends only the names that are missing and updates the array bound
to match the real entry count exactly.

Names ensured present:
    inireadstr, iniwritestr, inireadint, iniwriteint,
    datestr, timestr, strtointdef,
    shell, shellwait, shellhidden,
    urlencode, getenvvar

Usage:
    python patch_validator.py
    python patch_validator.py UValidator.pas

A .bak backup is written before any changes.
"""

import sys
import os
import re
import shutil

REQUIRED = [
    "inireadstr", "iniwritestr", "inireadint", "iniwriteint",
    "datestr", "timestr", "strtointdef",
    "shell", "shellwait", "shellhidden",
    "urlencode", "getenvvar",
]


def find_builtins_array(source):
    """
    Locate the BUILTINS array in the source.
    Returns (start, end, old_bound, body) or None.
    - start/end: character positions of the entire declaration
    - old_bound: the integer N in array[0..N]
    - body: the text between '(' and ')' exclusive
    """
    # Find BUILTINS : array[0..N] of string = (
    header_re = re.compile(
        r"BUILTINS\s*:\s*array\[0\.\.(\d+)\]\s*of\s*string\s*=\s*\(",
        re.IGNORECASE,
    )
    hm = header_re.search(source)
    if not hm:
        return None

    old_bound  = int(hm.group(1))
    body_start = hm.end()   # position just after the opening (

    # Find the matching closing );
    # We track nesting depth (though const arrays don't nest, be safe)
    depth = 1
    i = body_start
    while i < len(source) and depth > 0:
        if source[i] == "(":
            depth += 1
        elif source[i] == ")":
            depth -= 1
        i += 1
    # i now points one past the closing )
    # Check for the ; after )
    body_end = i - 1   # position of the )
    # The full declaration runs from BUILTINS to and including the ; after )
    semi = source.find(";", body_end)
    if semi == -1:
        semi = body_end

    decl_start = hm.start()
    decl_end   = semi + 1

    body = source[body_start:body_end]
    return decl_start, decl_end, old_bound, body


def patch_builtins(source):
    """
    Append missing names and fix the bound.
    Returns (modified_source, added_names, was_changed).
    """
    result = find_builtins_array(source)
    if result is None:
        print("  ERROR: BUILTINS array not found.", file=sys.stderr)
        return source, [], False

    decl_start, decl_end, old_bound, body = result

    # Names already present
    existing_lower = {n.lower() for n in re.findall(r"'([^']+)'", body)}

    # Which are missing?
    missing = [n for n in REQUIRED if n.lower() not in existing_lower]
    if not missing:
        return source, [], False

    # Build addition
    addition = (
        "\n    // INI / date / shell additions\n    "
        + ",".join(f"'{n}'" for n in missing)
        + "\n  "
    )
    new_body = body.rstrip() + addition

    # Count ALL entries to set bound correctly
    all_entries = re.findall(r"'([^']+)'", new_body)
    new_bound   = len(all_entries) - 1   # array[0..N]

    # Rebuild declaration
    header = (
        f"BUILTINS : array[0..{new_bound}] of string = ("
    )
    new_decl = header + new_body + ");"

    modified = source[:decl_start] + new_decl + source[decl_end:]
    return modified, missing, True


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "UValidator.pas"

    if not os.path.isfile(path):
        print(f"Error: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    with open(path, "r", encoding="utf-8-sig") as fh:
        original = fh.read()

    # Guard
    existing_lower = {n.lower() for n in re.findall(r"'([^']+)'", original)}
    if all(n in existing_lower for n in REQUIRED):
        print("All required builtins already present — nothing to do.")
        sys.exit(0)

    bak = path + ".bak"
    shutil.copy2(path, bak)
    print(f"Backup -> {bak}")

    source, added, changed = patch_builtins(original)

    if not changed:
        print("No changes made.")
        sys.exit(1)

    # Final count check
    result2 = find_builtins_array(source)
    if result2:
        _, _, new_bound, new_body = result2
        count = len(re.findall(r"'([^']+)'", new_body))
        declared = new_bound + 1
        if count == declared:
            print(f"  Array bound: 0..{new_bound} ({declared} entries) — correct.")
        else:
            print(f"  WARNING: {count} entries but bound says {declared}.",
                  file=sys.stderr)

    print(f"  + Added {len(added)} names: {', '.join(added)}")

    with open(path, "w", encoding="utf-8") as fh:
        fh.write(source)

    print(f"Done. {path} updated.")


if __name__ == "__main__":
    main()