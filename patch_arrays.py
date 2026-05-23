#!/usr/bin/env python3
"""
patch_arrays.py  -  Adds full dynamic array runtime to UInterpreter.pas.

TArrayValue uses TList (non-generic) with heap-allocated PValue pointers
to avoid the TList<TValue> circular-reference problem (TValue not yet
defined when TArrayValue is declared).

Usage:
    python patch_arrays.py
    python patch_arrays.py UInterpreter.pas

A .bak backup is written before any changes.
"""

import sys, os, shutil

# ─────────────────────────────────────────────────────────────
# 1. PValue pointer type + TArrayValue — insert before TValueKind
# ─────────────────────────────────────────────────────────────
OLD_VALUEKINDDECL = "  TValueKind = (vkInt, vkFloat, vkString, vkBool, vkNil, vkObject);"

NEW_VALUEKINDDECL = (
    "  // Pointer to TValue — used by TArrayValue to avoid circular generics\n"
    "  PValue = ^TValue;\n"
    "\n"
    "  // Dynamic array of TValue stored as heap pointers\n"
    "  TArrayValue = class\n"
    "  public\n"
    "    Items : TList;   // each element is a PValue (heap-allocated TValue)\n"
    "    constructor Create;\n"
    "    destructor  Destroy; override;\n"
    "    function  GetItem(Idx: Integer): TValue;\n"
    "    procedure SetItem(Idx: Integer; const V: TValue);\n"
    "    procedure AddItem(const V: TValue);\n"
    "    function  Count: Integer;\n"
    "  end;\n"
    "\n"
    "  TValueKind = (vkInt, vkFloat, vkString, vkBool, vkNil, vkObject, vkArray);"
)

# ─────────────────────────────────────────────────────────────
# 2. Add ArrVal field to TValue record
# ─────────────────────────────────────────────────────────────
OLD_OBJVAL_FIELD = "    ObjVal  : TObjectInstance;   // for vkObject — must be here with other fields"

NEW_OBJVAL_FIELD = (
    "    ObjVal  : TObjectInstance;   // for vkObject — must be here with other fields\n"
    "    ArrVal  : TArrayValue;       // for vkArray"
)

# ─────────────────────────────────────────────────────────────
# 3. Add MakeArray static declaration to TValue
# ─────────────────────────────────────────────────────────────
OLD_MAKENIL_DECL = "    class function MakeNil                        : TValue; static;"

NEW_MAKENIL_DECL = (
    "    class function MakeNil                        : TValue; static;\n"
    "    class function MakeArray (V: TArrayValue)     : TValue; static;"
)

# ─────────────────────────────────────────────────────────────
# 4. Add private method declarations to TInterpreter
# ─────────────────────────────────────────────────────────────
OLD_EVALCALLEXPR_DECL = (
    "    function  EvalCallExpr   (Node: TCallExpr;    Env: TEnvironment) : TValue;"
)

NEW_EVALCALLEXPR_DECL = (
    "    function  EvalCallExpr        (Node: TCallExpr;             Env: TEnvironment) : TValue;\n"
    "    function  EvalArrayIndex      (Node: TArrayIndexExpr;       Env: TEnvironment) : TValue;\n"
    "    procedure ExecArrayIndexAssign(Node: TArrayIndexAssignStmt; Env: TEnvironment);"
)

# ─────────────────────────────────────────────────────────────
# 5. TArrayValue + MakeArray implementations — after MakeNil impl
# ─────────────────────────────────────────────────────────────
OLD_AFTER_MAKENIL = (
    "class function TValue.MakeNil: TValue;\n"
    "begin\n"
    "  Result.Kind := vkNil;\n"
    "  Result.IVal := 0;\n"
    "  Result.FVal := 0;\n"
    "  Result.SVal := '';\n"
    "  Result.BVal := False;\n"
    "end;"
)

NEW_AFTER_MAKENIL = (
    "class function TValue.MakeNil: TValue;\n"
    "begin\n"
    "  Result.Kind := vkNil;\n"
    "  Result.IVal := 0;\n"
    "  Result.FVal := 0;\n"
    "  Result.SVal := '';\n"
    "  Result.BVal := False;\n"
    "end;\n"
    "\n"
    "class function TValue.MakeArray(V: TArrayValue): TValue;\n"
    "begin\n"
    "  Result.Kind   := vkArray;\n"
    "  Result.IVal   := 0;\n"
    "  Result.FVal   := 0;\n"
    "  Result.SVal   := '';\n"
    "  Result.BVal   := False;\n"
    "  Result.ObjVal := nil;\n"
    "  Result.ArrVal := V;\n"
    "end;\n"
    "\n"
    "{ TArrayValue }\n"
    "\n"
    "constructor TArrayValue.Create;\n"
    "begin\n"
    "  inherited;\n"
    "  Items := TList.Create;\n"
    "end;\n"
    "\n"
    "destructor TArrayValue.Destroy;\n"
    "var\n"
    "  I : Integer;\n"
    "begin\n"
    "  for I := 0 to Items.Count - 1 do\n"
    "    Dispose(PValue(Items[I]));\n"
    "  Items.Free;\n"
    "  inherited;\n"
    "end;\n"
    "\n"
    "function TArrayValue.GetItem(Idx: Integer): TValue;\n"
    "begin\n"
    "  Result := PValue(Items[Idx])^;\n"
    "end;\n"
    "\n"
    "procedure TArrayValue.SetItem(Idx: Integer; const V: TValue);\n"
    "begin\n"
    "  PValue(Items[Idx])^ := V;\n"
    "end;\n"
    "\n"
    "procedure TArrayValue.AddItem(const V: TValue);\n"
    "var\n"
    "  P : PValue;\n"
    "begin\n"
    "  New(P);\n"
    "  P^ := V;\n"
    "  Items.Add(P);\n"
    "end;\n"
    "\n"
    "function TArrayValue.Count: Integer;\n"
    "begin\n"
    "  Result := Items.Count;\n"
    "end;"
)

# ─────────────────────────────────────────────────────────────
# 6. Replace Length handler + add SetLength handler
# ─────────────────────────────────────────────────────────────
OLD_LENGTH_LINE = (
    "  else if N = 'length'      then Val := TValue.MakeInt  (Length(A(0).SVal))"
)

NEW_LENGTH_AND_SETLENGTH = (
    "  else if N = 'length'      then\n"
    "  begin\n"
    "    var LEN_Arg : TValue;\n"
    "    LEN_Arg := A(0);\n"
    "    if LEN_Arg.Kind = vkArray then\n"
    "      Val := TValue.MakeInt(LEN_Arg.ArrVal.Count)\n"
    "    else\n"
    "      Val := TValue.MakeInt(Length(LEN_Arg.ToStr));\n"
    "  end\n"
    "\n"
    "  else if N = 'setlength'   then\n"
    "  begin\n"
    "    // SetLength(arr, newSize)\n"
    "    var SL_Name   : string;\n"
    "    var SL_NewLen : Integer;\n"
    "    var SL_Val    : TValue;\n"
    "    SL_NewLen := A(1).ToInt;\n"
    "    if SL_NewLen < 0 then SL_NewLen := 0;\n"
    "    if (Args.Count > 0) and (Args[0] is TVarExpr) then\n"
    "      SL_Name := TVarExpr(Args[0]).Name\n"
    "    else\n"
    "      SL_Name := '';\n"
    "    if (SL_Name = '') or not CallerEnv.GetVar(SL_Name, SL_Val)\n"
    "       or (SL_Val.Kind <> vkArray) then\n"
    "      SL_Val := TValue.MakeArray(TArrayValue.Create);\n"
    "    while SL_Val.ArrVal.Count < SL_NewLen do\n"
    "      SL_Val.ArrVal.AddItem(TValue.MakeInt(0));\n"
    "    while SL_Val.ArrVal.Count > SL_NewLen do\n"
    "    begin\n"
    "      Dispose(PValue(SL_Val.ArrVal.Items[SL_Val.ArrVal.Count - 1]));\n"
    "      SL_Val.ArrVal.Items.Delete(SL_Val.ArrVal.Count - 1);\n"
    "    end;\n"
    "    if SL_Name <> '' then\n"
    "      CallerEnv.SetVar(SL_Name, SL_Val);\n"
    "    Val := TValue.MakeNil;\n"
    "  end"
)

# ─────────────────────────────────────────────────────────────
# 7. Wire TArrayIndexExpr into EvalExpr
# ─────────────────────────────────────────────────────────────
OLD_EVALEXPR_TAIL = (
    "  if Node is TCreateExpr     then Result := EvalCreateExpr   (TCreateExpr(Node),     Env)\n"
    "  else\n"
    "    Result := TValue.MakeNil;"
)

NEW_EVALEXPR_TAIL = (
    "  if Node is TCreateExpr     then Result := EvalCreateExpr   (TCreateExpr(Node),     Env) else\n"
    "  if Node is TArrayIndexExpr then Result := EvalArrayIndex   (TArrayIndexExpr(Node), Env)\n"
    "  else\n"
    "    Result := TValue.MakeNil;"
)

# ─────────────────────────────────────────────────────────────
# 8. Wire TArrayIndexAssignStmt into ExecStmt
# ─────────────────────────────────────────────────────────────
OLD_EXECSTMT_FIELD = (
    "  if Node is TFieldAssignStmt    then ExecFieldAssign    (TFieldAssignStmt(Node),    Env)"
)

NEW_EXECSTMT_FIELD = (
    "  if Node is TFieldAssignStmt      then ExecFieldAssign      (TFieldAssignStmt(Node),      Env)\n"
    "  else if Node is TArrayIndexAssignStmt then ExecArrayIndexAssign(TArrayIndexAssignStmt(Node), Env)"
)

# ─────────────────────────────────────────────────────────────
# 9. EvalArrayIndex + ExecArrayIndexAssign implementations
# ─────────────────────────────────────────────────────────────
OLD_EVALCALLEXPR_IMPL = (
    "function TInterpreter.EvalCallExpr(Node: TCallExpr; Env: TEnvironment): TValue;\n"
    "begin\n"
    "  if not CallBuiltin(Node.Name, Node.Args, Env, Result) then\n"
    "    Result := CallRoutine(Node.Name, Node.Args, Env);\n"
    "end;"
)

NEW_EVALCALLEXPR_IMPL = (
    "function TInterpreter.EvalCallExpr(Node: TCallExpr; Env: TEnvironment): TValue;\n"
    "begin\n"
    "  if not CallBuiltin(Node.Name, Node.Args, Env, Result) then\n"
    "    Result := CallRoutine(Node.Name, Node.Args, Env);\n"
    "end;\n"
    "\n"
    "function TInterpreter.EvalArrayIndex(Node: TArrayIndexExpr;\n"
    "  Env: TEnvironment): TValue;\n"
    "var\n"
    "  ArrVal : TValue;\n"
    "  Idx    : Integer;\n"
    "begin\n"
    "  ArrVal := EvalExpr(Node.Target, Env);\n"
    "  if ArrVal.Kind <> vkArray then\n"
    "    raise Exception.Create(\n"
    "      'Tried to index something that is not an array.' + sLineBreak +\n"
    "      'Use SetLength(arr, n) to initialise a dynamic array first.');\n"
    "  Idx := EvalExpr(Node.Index, Env).ToInt;\n"
    "  if (Idx < 0) or (Idx >= ArrVal.ArrVal.Count) then\n"
    "    raise Exception.CreateFmt(\n"
    "      'Array index %d out of bounds (size %d, valid range 0..%d).',\n"
    "      [Idx, ArrVal.ArrVal.Count, ArrVal.ArrVal.Count - 1]);\n"
    "  Result := ArrVal.ArrVal.GetItem(Idx);\n"
    "end;\n"
    "\n"
    "procedure TInterpreter.ExecArrayIndexAssign(Node: TArrayIndexAssignStmt;\n"
    "  Env: TEnvironment);\n"
    "var\n"
    "  ArrVal : TValue;\n"
    "  Idx    : Integer;\n"
    "  NewVal : TValue;\n"
    "  VName  : string;\n"
    "begin\n"
    "  NewVal := EvalExpr(Node.Value, Env);\n"
    "  if not (Node.Target is TVarExpr) then\n"
    "    raise Exception.Create('Array assignment target must be a simple variable.');\n"
    "  VName := TVarExpr(Node.Target).Name;\n"
    "  if not Env.GetVar(VName, ArrVal) or (ArrVal.Kind <> vkArray) then\n"
    "    raise Exception.CreateFmt(\n"
    "      '\"%%s\" is not an array. Use SetLength(%s, n) first.', [VName, VName]);\n"
    "  Idx := EvalExpr(Node.Index, Env).ToInt;\n"
    "  if (Idx < 0) or (Idx >= ArrVal.ArrVal.Count) then\n"
    "    raise Exception.CreateFmt(\n"
    "      'Array index %%d out of bounds (size %%d, valid 0..%%d).',\n"
    "      [Idx, ArrVal.ArrVal.Count, ArrVal.ArrVal.Count - 1]);\n"
    "  // SetItem writes through the pointer — no env writeback needed\n"
    "  ArrVal.ArrVal.SetItem(Idx, NewVal);\n"
    "end;"
)


def apply(source, old, new, label):
    if old not in source:
        print(f"  WARNING: anchor not found for '{label}' — skipping")
        return source, False
    return source.replace(old, new, 1), True


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "UInterpreter.pas"
    if not os.path.isfile(path):
        print(f"Error: file not found: {path}")
        sys.exit(1)

    with open(path, "r", encoding="utf-8-sig") as fh:
        original = fh.read()

    if "vkArray" in original:
        print("Array runtime already present — nothing to do.")
        sys.exit(0)

    bak = path + ".bak"
    shutil.copy2(path, bak)
    print(f"Backup -> {bak}")

    s = original
    changes = 0

    patches = [
        (OLD_VALUEKINDDECL,     NEW_VALUEKINDDECL,     "PValue + TArrayValue decl + vkArray"),
        (OLD_OBJVAL_FIELD,      NEW_OBJVAL_FIELD,       "ArrVal field in TValue"),
        (OLD_MAKENIL_DECL,      NEW_MAKENIL_DECL,       "MakeArray declaration"),
        (OLD_EVALCALLEXPR_DECL, NEW_EVALCALLEXPR_DECL, "private method declarations"),
        (OLD_AFTER_MAKENIL,     NEW_AFTER_MAKENIL,      "MakeArray + TArrayValue impl"),
        (OLD_LENGTH_LINE,       NEW_LENGTH_AND_SETLENGTH,"Length + SetLength handlers"),
        (OLD_EVALEXPR_TAIL,     NEW_EVALEXPR_TAIL,      "EvalExpr array wire"),
        (OLD_EXECSTMT_FIELD,    NEW_EXECSTMT_FIELD,     "ExecStmt array wire"),
        (OLD_EVALCALLEXPR_IMPL, NEW_EVALCALLEXPR_IMPL,  "EvalArrayIndex + ExecArrayIndexAssign impl"),
    ]

    for old, new, label in patches:
        s, ok = apply(s, old, new, label)
        if ok:
            print(f"  + {label}")
            changes += 1

    with open(path, "w", encoding="utf-8") as fh:
        fh.write(s)

    print(f"Done. {changes}/{len(patches)} patches applied to {path}")


if __name__ == "__main__":
    main()