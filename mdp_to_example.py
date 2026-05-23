#!/usr/bin/env python3
"""
mdp_to_example.py
-----------------
Converts a .mdp source file into a Delphi Add() call suitable for
pasting directly into UExampleProjects.pas inside the Build procedure.

Usage:
    python mdp_to_example.py <file.mdp> <Name> <Category> <Description>

Example:
    python mdp_to_example.py sudoku.mdp "Sudoku" "Games & Fun" \
        "Full graphical Sudoku with generator, daily challenge and INI saves"

Output is written to <stem>_example.pas and also printed to stdout.

Conversion rules (matching the existing UExampleProjects.pas style):
  - Each source line  →  '<escaped line>' + #13#10 +
  - Empty lines       →  '' + #13#10 +
  - Single quotes     →  '' (doubled, Delphi convention)
  - Last line of source gets a trailing #13#10 with no further +
  - The whole thing is wrapped in Add('Name', 'Cat', 'Desc', <source>);
"""

import sys
import os
import textwrap


def escape_pascal_string(line: str) -> str:
    """Escape a single source line for embedding in a Delphi string literal."""
    return line.replace("'", "''")


def mdp_to_delphi_add(
    source: str,
    name: str,
    category: str,
    description: str,
) -> str:
    """
    Turn raw .mdp source text into a Delphi Add(...) call.

    The output style matches UExampleProjects.pas exactly:

        Add('Name', 'Category', 'Description',
        '<line1>' + #13#10 +
        '<line2>' + #13#10 +
        ...
        '<lastline>');
    """
    lines = source.splitlines()

    # Remove trailing blank lines (keep internal ones)
    while lines and lines[-1].strip() == "":
        lines.pop()

    delphi_lines = []
    for i, line in enumerate(lines):
        escaped = escape_pascal_string(line)
        is_last = i == len(lines) - 1

        if escaped == "":
            # Blank line — empty string literal
            literal = "''"
        else:
            literal = f"'{escaped}'"

        if is_last:
            delphi_lines.append(f"{literal} + #13#10")
        else:
            delphi_lines.append(f"{literal} + #13#10 +")

    # Indent every source line by two spaces inside the Add() call
    indented_source = "\n".join(f"  {l}" for l in delphi_lines)

    # Escape the description (unlikely to contain quotes, but be safe)
    esc_name = escape_pascal_string(name)
    esc_cat  = escape_pascal_string(category)
    esc_desc = escape_pascal_string(description)

    result = (
        f"// {'-' * 75}\n"
        f"Add('{esc_name}', '{esc_cat}', '{esc_desc}',\n"
        f"{indented_source});\n"
    )
    return result


def main() -> None:
    if len(sys.argv) < 5:
        print(
            "Usage: mdp_to_example.py <file.mdp> <Name> <Category> <Description>",
            file=sys.stderr,
        )
        sys.exit(1)

    mdp_path    = sys.argv[1]
    name        = sys.argv[2]
    category    = sys.argv[3]
    description = sys.argv[4]

    if not os.path.isfile(mdp_path):
        print(f"Error: file not found: {mdp_path}", file=sys.stderr)
        sys.exit(1)

    with open(mdp_path, "r", encoding="utf-8") as fh:
        source = fh.read()

    output = mdp_to_delphi_add(source, name, category, description)

    # Write to a .pas sidecar file
    stem     = os.path.splitext(mdp_path)[0]
    out_path = stem + "_example.pas"
    with open(out_path, "w", encoding="utf-8") as fh:
        fh.write(output)

    # Also print to stdout for easy copy-paste
    print(output)
    print(f"\n[Written to {out_path}]", file=sys.stderr)


if __name__ == "__main__":
    main()