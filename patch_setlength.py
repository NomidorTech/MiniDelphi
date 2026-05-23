#!/usr/bin/env python3
"""
patch_setlength.py  -  Adds SetLength and array-aware Length to UInterpreter.pas.

SetLength(arr, n) — resizes a dynamic array to n elements
Length(arr)       — returns element count for arrays (string length already works)

Also adds 'setlength' to UValidator.pas BUILTINS if that file is present.

Usage:
    python patch_setlength.py
    python patch_setlength.py UInterpreter.pas [UValidator.pas]

A .bak backup is written before any changes.
"""

import sys
import os
import re
import shutil

# ---------------------------------------------------------------------------
#  Anchor: insert after the closing 'end' of the 'randomize' handler.
#  The randomize block ends with:    Randomize;
#  followed by its closing           end
#  We find "Randomize;" and insert after the "end" on the next non-blank line.
# ---------------------------------------------------------------------------
ANCHOR = "Randomize;"

SETLENGTH_HANDLER = (
    "\n"
    "\n"
    "  else if N = 'setlength' then\n"
    "  begin\n"
    "    // SetLength(arr, newSize)\n"
    "    // Arg 0: the array variable (we need its name to write back)\n"
    "    // Arg 1: new integer size\n"
    "    var SL_Name   : string;\n"
    "    var SL_NewLen : Integer;\n"
    "    var SL_Val    : TValue;\n"
    "    var SL_Pad    : Integer;\n"
    "\n"
    "    SL_NewLen := A(1).ToInt;\n"
    "    if SL_NewLen < 0 then SL_NewLen := 0;\n"
    "\n"
    "    // Extract the variable name from the first argument node\n"
    "    if (Args.Count > 0) and (Args[0] is TVarExpr) then\n"
    "      SL_Name := TVarExpr(Args[0]).Name\n"
    "    else\n"
    "      SL_Name := '';\n"
    "\n"
    "    // Get or create the array value\n"
    "    if (SL_Name = '') or not CallerEnv.GetVar(SL_Name, SL_Val)\n"
    "       or (SL_Val.Kind <> vkArray) then\n"
    "    begin\n"
    "      SL_Val.Kind   := vkArray;\n"
    "      SL_Val.ArrVal := TArrayValue.Create;\n"
    "    end;\n"
    "\n"
    "    // Resize\n"
    "    while SL_Val.ArrVal.Items.Count < SL_NewLen do\n"
    "      SL_Val.ArrVal.Items.Add(TValue.MakeInt(0));\n"
    "    while SL_Val.ArrVal.Items.Count > SL_NewLen do\n"
    "      SL_Val.ArrVal.Items.Delete(SL_Val.ArrVal.Items.Count - 1);\n"
    "\n"
    "    if SL_Name <> '' then\n"
    "      CallerEnv.SetVar(SL_Name, SL_Val);\n"
    "    Val := TValue.MakeNil;\n"
    "  end\n"
)

# ---------------------------------------------------------------------------
#  Extend Length to handle arrays.
#  Find:    else if N = 'length' then
#               Val := TValue.MakeInt(Length(A(0).ToStr))
#  Replace with a begin..end block that checks vkArray first.
# ---------------------------------------------------------------------------
OLD_LENGTH_SNIPPET = "Val := TValue.MakeInt(Length(A(0).ToStr))"

NEW_LENGTH_BLOCK = (
    "begin\n"
    "    var LEN_Arg : TValue;\n"
    "    LEN_Arg := A(0);\n"
    "    if LEN_Arg.Kind = vkArray then\n"
    "      Val := TValue.MakeInt(LEN_Arg.ArrVal.Items.Count)\n"
    "    else\n"
    "      Val := TValue.MakeInt(Length(LEN_Arg.ToStr));\n"
    "  end"
)


def patch_setlength_handler(source):
    """Insert SetLength handler after the Randomize; line."""
    pos = source.find(ANCHOR)
    if pos == -1:
        print("  ERROR: anchor 'Randomize;' not found.", file=sys.stderr)
        return source, False
    eol = source.find("\n", pos)
    if eol == -1:
        eol = len(source)
    modified = source[:eol] + SETLENGTH_HANDLER + source[eol:]
    return modified, True


def patch_length_handler(source):
    """Extend the Length handler to support arrays."""
    pos = source.find(OLD_LENGTH_SNIPPET)
    if pos == -1:
        print("  WARNING: Length handler snippet not found — skipping array-Length patch.",
              file=sys.stderr)
        return source, False
    eol = source.find("\n", pos)
    if eol == -1:
        eol = len(source)
    modified = source[:pos] + NEW_LENGTH_BLOCK + source[eol:]
    return modified, True


def patch_validator_builtins(path):
    """Add 'setlength' to BUILTINS in UValidator.pas if missing."""
    if not os.path.isfile(path):
        return
    with open(path, "r", encoding="utf-8-sig") as fh:
        src = fh.read()
    if "'setlength'" in src.lower():
        print(f"  . {path}: 'setlength' already present")
        return

    # Find the closing ); of the BUILTINS array and insert before it
    pattern = re.compile(
        r"(BUILTINS\s*:\s*array\[0\.\.)(\d+)(\]\s*of\s*string\s*=\s*\()",
        re.IGNORECASE,
    )
    m = pattern.search(src)
    if not m:
        print(f"  WARNING: BUILTINS not found in {path}", file=sys.stderr)
        return

    old_bound = int(m.group(2))
    new_bound = old_bound + 1

    # Find closing ); after the header
    body_start = src.find("(", m.start()) + 1
    depth = 1
    i = body_start
    while i < len(src) and depth > 0:
        if src[i] == "(": depth += 1
        elif src[i] == ")": depth -= 1
        i += 1
    close_paren = i - 1   # position of )

    # Insert before the closing )
    insert = ",\n    'setlength'"
    modified = (
        src[:m.start(2)] + str(new_bound) + src[m.end(2):close_paren]
        + insert + src[close_paren:]
    )

    shutil.copy2(path, path + ".bak")
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(modified)
    print(f"  + Added 'setlength' to {path} (bound now 0..{new_bound})")


def main():
    interp_path = sys.argv[1] if len(sys.argv) > 1 else "UInterpreter.pas"
    valid_path  = sys.argv[2] if len(sys.argv) > 2 else "UValidator.pas"

    if not os.path.isfile(interp_path):
        print(f"Error: file not found: {interp_path}", file=sys.stderr)
        sys.exit(1)

    with open(interp_path, "r", encoding="utf-8-sig") as fh:
        original = fh.read()

    if "'setlength'" in original.lower():
        print("SetLength already present in UInterpreter.pas — nothing to do.")
    else:
        bak = interp_path + ".bak"
        shutil.copy2(interp_path, bak)
        print(f"Backup -> {bak}")

        source = original
        source, c1 = patch_setlength_handler(source)
        if c1:
            print("  + Inserted SetLength handler")

        source, c2 = patch_length_handler(source)
        if c2:
            print("  + Extended Length handler to support arrays")

        if c1 or c2:
            with open(interp_path, "w", encoding="utf-8") as fh:
                fh.write(source)
            print(f"Done. {interp_path} updated.")
        else:
            print("No changes made to UInterpreter.pas.")

    # Patch validator too if present
    if os.path.isfile(valid_path):
        patch_validator_builtins(valid_path)


if __name__ == "__main__":
    main()