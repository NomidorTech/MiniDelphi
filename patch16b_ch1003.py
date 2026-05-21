#!/usr/bin/env python3
"""
patch16b_ch1003.py  —  Pythia Patch 16b
Fix F2069 'Line too long' in ULearnTab.pas Ch(1003) call.
Breaks the two monster single-line strings into + #13#10 + chains.

Usage:
    python patch16b_ch1003.py <path-to-ULearnTab.pas>

    If no path given, looks for ULearnTab.pas in the current directory.
"""

import sys, os, shutil

# ---------------------------------------------------------------------------
#  The exact old text to find (the two long lines, as they appear in the file)
# ---------------------------------------------------------------------------
OLD = (
    "       'function IsPrime(n: Integer): Boolean;' + #13#10 + 'var i : Integer;' + #13#10 + 'begin' + #13#10 + '  if n < 2 then begin Result := false; exit; end;' + #13#10 + '  Result := true; i := 2;' + #13#10 + '  while i*i <= n do begin' + #13#10 + '    if n mod i = 0 then begin Result := false; exit; end;' + #13#10 + '    inc(i);' + #13#10 + '  end;' + #13#10 + 'end;' + #13#10 + #13#10 + 'function IsSquare(n: Integer): Boolean;' + #13#10 + 'var r : Integer;' + #13#10 + 'begin' + #13#10 + '  r := round(sqrt(n));' + #13#10 + '  Result := (r * r = n);' + #13#10 + 'end;' + #13#10 + #13#10 + 'var i : Integer;' + #13#10 + 'begin' + #13#10 + '  for i := 1 to 15 do' + #13#10 + '  begin' + #13#10 + '    write(i, '' is '');' + #13#10 + '    if IsSquare(i) and not IsPrime(i) then writeln(''Perfect Square'')' + #13#10 + '    else if IsPrime(i) then writeln(''Prime'')' + #13#10 + '    else if i mod 15 = 0 then writeln(''FizzBuzz'')' + #13#10 + '    else if i mod 3 = 0 then writeln(''Fizz'')' + #13#10 + '    else if i mod 5 = 0 then writeln(''Buzz'')' + #13#10 + '    else writeln(''Plain'');' + #13#10 + '  end;' + #13#10 + 'end.',"
    "\n"
    "       'function IsPrime(n:Integer):Boolean; var i:Integer; begin if n<2 then begin Result:=false; exit; end; Result:=true; i:=2; while i*i<=n do begin if n mod i=0 then begin Result:=false; exit; end; inc(i); end; end; function IsSquare(n:Integer):Boolean; var r:Integer; begin r:=round(sqrt(n)); Result:=(r*r=n); end; var i:Integer; begin for i:=1 to 15 do begin write(i,'' is ''); if IsSquare(i) and not IsPrime(i) then writeln(''Perfect Square'') else if IsPrime(i) then writeln(''Prime'') else if i mod 15=0 then writeln(''FizzBuzz'') else if i mod 3=0 then writeln(''Fizz'') else if i mod 5=0 then writeln(''Buzz'') else writeln(''Plain''); end; end.',"
)

# ---------------------------------------------------------------------------
#  The replacement — same strings, split into short lines
# ---------------------------------------------------------------------------
NEW = (
    "       'function IsPrime(n: Integer): Boolean;'                            + #13#10 +\n"
    "       'var i : Integer;'                                                  + #13#10 +\n"
    "       'begin'                                                             + #13#10 +\n"
    "       '  if n < 2 then begin Result := false; exit; end;'                + #13#10 +\n"
    "       '  Result := true; i := 2;'                                        + #13#10 +\n"
    "       '  while i*i <= n do begin'                                        + #13#10 +\n"
    "       '    if n mod i = 0 then begin Result := false; exit; end;'        + #13#10 +\n"
    "       '    inc(i);'                                                       + #13#10 +\n"
    "       '  end;'                                                            + #13#10 +\n"
    "       'end;'                                                              + #13#10 +\n"
    "       ''                                                                  + #13#10 +\n"
    "       'function IsSquare(n: Integer): Boolean;'                           + #13#10 +\n"
    "       'var r : Integer;'                                                  + #13#10 +\n"
    "       'begin'                                                             + #13#10 +\n"
    "       '  r := round(sqrt(n));'                                            + #13#10 +\n"
    "       '  Result := (r * r = n);'                                         + #13#10 +\n"
    "       'end;'                                                              + #13#10 +\n"
    "       ''                                                                  + #13#10 +\n"
    "       'var i : Integer;'                                                  + #13#10 +\n"
    "       'begin'                                                             + #13#10 +\n"
    "       '  for i := 1 to 15 do'                                            + #13#10 +\n"
    "       '  begin'                                                           + #13#10 +\n"
    "       '    write(i, '' is '');'                                           + #13#10 +\n"
    "       '    if IsSquare(i) and not IsPrime(i) then writeln(''Perfect Square'')' + #13#10 +\n"
    "       '    else if IsPrime(i) then writeln(''Prime'')'                   + #13#10 +\n"
    "       '    else if i mod 15 = 0 then writeln(''FizzBuzz'')'              + #13#10 +\n"
    "       '    else if i mod 3 = 0 then writeln(''Fizz'')'                   + #13#10 +\n"
    "       '    else if i mod 5 = 0 then writeln(''Buzz'')'                   + #13#10 +\n"
    "       '    else writeln(''Plain'');'                                      + #13#10 +\n"
    "       '  end;'                                                            + #13#10 +\n"
    "       'end.',\n"
    "       'function IsPrime(n:Integer):Boolean;'                              + #13#10 +\n"
    "       'var i:Integer;'                                                    + #13#10 +\n"
    "       'begin'                                                             + #13#10 +\n"
    "       '  if n<2 then begin Result:=false; exit; end;'                    + #13#10 +\n"
    "       '  Result:=true; i:=2;'                                            + #13#10 +\n"
    "       '  while i*i<=n do begin'                                          + #13#10 +\n"
    "       '    if n mod i=0 then begin Result:=false; exit; end;'            + #13#10 +\n"
    "       '    inc(i);'                                                       + #13#10 +\n"
    "       '  end;'                                                            + #13#10 +\n"
    "       'end;'                                                              + #13#10 +\n"
    "       'function IsSquare(n:Integer):Boolean;'                             + #13#10 +\n"
    "       'var r:Integer;'                                                    + #13#10 +\n"
    "       'begin'                                                             + #13#10 +\n"
    "       '  r:=round(sqrt(n));'                                              + #13#10 +\n"
    "       '  Result:=(r*r=n);'                                                + #13#10 +\n"
    "       'end;'                                                              + #13#10 +\n"
    "       'var i:Integer;'                                                    + #13#10 +\n"
    "       'begin'                                                             + #13#10 +\n"
    "       '  for i:=1 to 15 do'                                              + #13#10 +\n"
    "       '  begin'                                                           + #13#10 +\n"
    "       '    write(i,'' is '');'                                            + #13#10 +\n"
    "       '    if IsSquare(i) and not IsPrime(i) then writeln(''Perfect Square'')' + #13#10 +\n"
    "       '    else if IsPrime(i) then writeln(''Prime'')'                   + #13#10 +\n"
    "       '    else if i mod 15=0 then writeln(''FizzBuzz'')'                + #13#10 +\n"
    "       '    else if i mod 3=0 then writeln(''Fizz'')'                     + #13#10 +\n"
    "       '    else if i mod 5=0 then writeln(''Buzz'')'                     + #13#10 +\n"
    "       '    else writeln(''Plain'');'                                      + #13#10 +\n"
    "       '  end;'                                                            + #13#10 +\n"
    "       'end.',"
)

def main():
    filepath = sys.argv[1] if len(sys.argv) > 1 else 'ULearnTab.pas'
    filepath = os.path.abspath(filepath)

    print(f'\nPythia Patch 16b — Fix Ch(1003) line-too-long')
    print(f'Target: {filepath}\n')

    if not os.path.exists(filepath):
        print(f'ERROR: File not found: {filepath}')
        sys.exit(1)

    with open(filepath, 'r', encoding='utf-8-sig') as f:
        original = f.read()

    if OLD not in original:
        if 'IsPrime(n: Integer): Boolean' in original and '#13#10 +\n' in original:
            print('Already patched — nothing to do.')
        else:
            print('ERROR: Could not find the expected Ch(1003) long lines.')
            print('Has the file already been edited manually?')
        sys.exit(0)

    # Verify replacement lines are all under 1023 chars
    bad = [(i+1, len(l)) for i, l in enumerate(NEW.splitlines()) if len(l) > 1023]
    if bad:
        for lineno, length in bad:
            print(f'INTERNAL ERROR: replacement line {lineno} is {length} chars')
        sys.exit(1)

    new_text = original.replace(OLD, NEW, 1)

    # Double-check all lines in the patched file
    long_lines = [(i+1, len(l)) for i, l in enumerate(new_text.splitlines()) if len(l) > 1023]
    if long_lines:
        print('WARNING: patched file still has long lines:')
        for lineno, length in long_lines:
            print(f'  Line {lineno}: {length} chars')
        sys.exit(1)

    backup = filepath + '.patch16b.bak'
    shutil.copy2(filepath, backup)
    print(f'Backup written → {os.path.basename(backup)}')

    had_bom = original.startswith('\ufeff')
    with open(filepath, 'w', encoding='utf-8-sig' if had_bom else 'utf-8') as f:
        f.write(new_text)

    print('Ch(1003) Starter and Solution split into short lines.')
    print('No long lines remain in the file.')
    print('\nDone. Build and verify, then delete the .bak file.\n')

if __name__ == '__main__':
    main()