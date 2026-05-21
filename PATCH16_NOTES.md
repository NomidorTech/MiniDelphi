# Pythia — Patch 16: GPL v3 License Header Standardisation

**Date:** 2026-05-21  
**Author:** Nomidor Software, LLC  
**Type:** Non-functional / Legal  
**Risk:** Zero — comments only, no code changes

---

## Summary

Standardises all source file copyright headers to GPL v3.  
Fixes inconsistency where some files still carried the old  
"All rights reserved / MiniDelphi" header from before the  
project was renamed to Pythia and open-sourced under GPL v3.

Also fixes two functional strings in `Pythia.dpr`:
- `Application.Title` was `'MiniDelphi Toy Compiler'` → `'Pythia'`
- Internal `.dpr` description comment still said `MiniDelphi.dpr`

The `LICENSE` file already exists and is correct.  
`UMacroTab.pas`, `UMainForm.pas`, `UParser.pas`, `UValidator.pas`,  
and `UInterpreter.pas` already had correct GPL v3 headers — untouched.

---

## Files Changed

| File | Change |
|---|---|
| `Pythia.dpr` | Header + Application.Title + description comment |
| `UProjectTab.pas` | Header only |
| `UExampleProjects.pas` | Header + "MiniDelphi" → "Pythia" in description |
| `UUnitLoader.pas` | Header only |
| `ULearnTab.pas` | Header only |
| `UFormBuilderTab.pas` | Header only |
| `UTheme.pas` | Header only |
| `UAST.pas` | Header added (had none) |

## Files Untouched (already correct)

`UMacroTab.pas`, `UMainForm.pas`, `UParser.pas`, `UValidator.pas`, `UInterpreter.pas`

---

## Standard Header Applied

```pascal
// =============================================================================
// Pythia — A Pascal Learning Environment
// Copyright (C) 2026 Nomidor Software, LLC.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// See the LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
```

---

## How to Apply

Each file in the `patch16/` folder contains only the **replacement header block**.  
For each file:

1. Open the original `.pas` / `.dpr` in Delphi
2. Select from the first `//` line down to (and including) the closing `// ===...===` line of the OLD copyright block
3. Paste the replacement from the corresponding file in `patch16/`
4. Save — no other changes needed

For `Pythia.dpr` also update the two strings noted in that file's patch.
