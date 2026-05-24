// ---------------------------------------------------------------------------
Add('Sudoku', 'Games & Fun', 'Full graphical Sudoku with iterative generator, daily challenge and SQLite saves',
  '// ============================================================' + #13#10 +
  '// SUDOKU  —  Pythia Pascal  —  Nomidor Software' + #13#10 +
  '// No Exit statements — all control flow uses boolean flags' + #13#10 +
  '// ============================================================' + #13#10 +
  '' + #13#10 +
  'var' + #13#10 +
  '  WIN_W  : Integer;' + #13#10 +
  '  WIN_H  : Integer;' + #13#10 +
  '  CELL   : Integer;' + #13#10 +
  '  GRID_X : Integer;' + #13#10 +
  '  GRID_Y : Integer;' + #13#10 +
  '  GRID_W : Integer;' + #13#10 +
  '' + #13#10 +
  'var' + #13#10 +
  '  board    : array of Integer;' + #13#10 +
  '  given    : array of Integer;' + #13#10 +
  '  solution : array of Integer;' + #13#10 +
  '' + #13#10 +
  'var' + #13#10 +
  '  selRow    : Integer;' + #13#10 +
  '  selCol    : Integer;' + #13#10 +
  '  gameWon   : Boolean;' + #13#10 +
  '  gameMode  : Integer;' + #13#10 +
  '  elapsed   : Integer;' + #13#10 +
  '  lastSec   : Integer;' + #13#10 +
  '  wasDown   : Boolean;' + #13#10 +
  '  dbPath    : String;' + #13#10 +
  '  tickCount : Integer;' + #13#10 +
  '  hintsUsed : Integer;' + #13#10 +
  '' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '//  UTILITY' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '' + #13#10 +
  'function RC(r, c: Integer): Integer;' + #13#10 +
  'begin' + #13#10 +
  '  Result := r * 9 + c;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'function Pad2(n: Integer): String;' + #13#10 +
  'begin' + #13#10 +
  '  if n < 10 then Result := ''0'' + IntToStr(n)' + #13#10 +
  '  else            Result := IntToStr(n);' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'function FmtTime(secs: Integer): String;' + #13#10 +
  'begin' + #13#10 +
  '  Result := Pad2(secs div 60) + '':'' + Pad2(secs mod 60);' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '//  CONFLICT DETECTION — no Exit, uses boolean short-circuit' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '' + #13#10 +
  'function Conflicts(r, c, d: Integer): Boolean;' + #13#10 +
  'var' + #13#10 +
  '  i, br, bc, dr, dc, tr, tc : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  Result := False;' + #13#10 +
  '  if d = 0 then' + #13#10 +
  '  begin' + #13#10 +
  '    Result := False;' + #13#10 +
  '  end' + #13#10 +
  '  else' + #13#10 +
  '  begin' + #13#10 +
  '    // Row check' + #13#10 +
  '    i := 0;' + #13#10 +
  '    while (i < 9) and (not Result) do' + #13#10 +
  '    begin' + #13#10 +
  '      if (i <> c) and (board[RC(r, i)] = d) then Result := True;' + #13#10 +
  '      i := i + 1;' + #13#10 +
  '    end;' + #13#10 +
  '' + #13#10 +
  '    // Column check' + #13#10 +
  '    i := 0;' + #13#10 +
  '    while (i < 9) and (not Result) do' + #13#10 +
  '    begin' + #13#10 +
  '      if (i <> r) and (board[RC(i, c)] = d) then Result := True;' + #13#10 +
  '      i := i + 1;' + #13#10 +
  '    end;' + #13#10 +
  '' + #13#10 +
  '    // Box check' + #13#10 +
  '    if not Result then' + #13#10 +
  '    begin' + #13#10 +
  '      br := (r div 3) * 3;' + #13#10 +
  '      bc := (c div 3) * 3;' + #13#10 +
  '      dr := 0;' + #13#10 +
  '      while (dr < 3) and (not Result) do' + #13#10 +
  '      begin' + #13#10 +
  '        dc := 0;' + #13#10 +
  '        while (dc < 3) and (not Result) do' + #13#10 +
  '        begin' + #13#10 +
  '          tr := br + dr;' + #13#10 +
  '          tc := bc + dc;' + #13#10 +
  '          if (tr <> r) or (tc <> c) then' + #13#10 +
  '            if board[RC(tr, tc)] = d then Result := True;' + #13#10 +
  '          dc := dc + 1;' + #13#10 +
  '        end;' + #13#10 +
  '        dr := dr + 1;' + #13#10 +
  '      end;' + #13#10 +
  '    end;' + #13#10 +
  '  end;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '//  ITERATIVE BOARD FILLER — no Exit, no Break' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '' + #13#10 +
  'procedure FillBoard;' + #13#10 +
  'var' + #13#10 +
  '  order  : array of Integer;' + #13#10 +
  '  tryAt  : array of Integer;' + #13#10 +
  '  pos, i, j, tmp, digit : Integer;' + #13#10 +
  '  found  : Boolean;' + #13#10 +
  'begin' + #13#10 +
  '  SetLength(order, 81 * 9);' + #13#10 +
  '  SetLength(tryAt, 81);' + #13#10 +
  '' + #13#10 +
  '  for pos := 0 to 80 do' + #13#10 +
  '  begin' + #13#10 +
  '    for i := 0 to 8 do order[pos * 9 + i] := i + 1;' + #13#10 +
  '    for i := 8 downto 1 do' + #13#10 +
  '    begin' + #13#10 +
  '      j   := Random(i + 1);' + #13#10 +
  '      tmp := order[pos * 9 + i];' + #13#10 +
  '      order[pos * 9 + i] := order[pos * 9 + j];' + #13#10 +
  '      order[pos * 9 + j] := tmp;' + #13#10 +
  '    end;' + #13#10 +
  '    tryAt[pos] := 0;' + #13#10 +
  '  end;' + #13#10 +
  '' + #13#10 +
  '  pos := 0;' + #13#10 +
  '  while (pos >= 0) and (pos < 81) do' + #13#10 +
  '  begin' + #13#10 +
  '    found := False;' + #13#10 +
  '    while (tryAt[pos] < 9) and (not found) do' + #13#10 +
  '    begin' + #13#10 +
  '      digit := order[pos * 9 + tryAt[pos]];' + #13#10 +
  '      tryAt[pos] := tryAt[pos] + 1;' + #13#10 +
  '      if not Conflicts(pos div 9, pos mod 9, digit) then' + #13#10 +
  '      begin' + #13#10 +
  '        board[pos] := digit;' + #13#10 +
  '        found := True;' + #13#10 +
  '      end;' + #13#10 +
  '    end;' + #13#10 +
  '' + #13#10 +
  '    if found then' + #13#10 +
  '      pos := pos + 1' + #13#10 +
  '    else' + #13#10 +
  '    begin' + #13#10 +
  '      board[pos] := 0;' + #13#10 +
  '      tryAt[pos] := 0;' + #13#10 +
  '      for i := 0 to 8 do order[pos * 9 + i] := i + 1;' + #13#10 +
  '      for i := 8 downto 1 do' + #13#10 +
  '      begin' + #13#10 +
  '        j   := Random(i + 1);' + #13#10 +
  '        tmp := order[pos * 9 + i];' + #13#10 +
  '        order[pos * 9 + i] := order[pos * 9 + j];' + #13#10 +
  '        order[pos * 9 + j] := tmp;' + #13#10 +
  '      end;' + #13#10 +
  '      pos := pos - 1;' + #13#10 +
  '    end;' + #13#10 +
  '  end;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '//  PUZZLE GENERATOR' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '' + #13#10 +
  'procedure GeneratePuzzle(difficulty: Integer);' + #13#10 +
  'var' + #13#10 +
  '  toRemove, attempts, pos, i : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  for i := 0 to 80 do board[i] := 0;' + #13#10 +
  '  FillBoard;' + #13#10 +
  '  for i := 0 to 80 do solution[i] := board[i];' + #13#10 +
  '' + #13#10 +
  '  if difficulty = 1 then toRemove := 36' + #13#10 +
  '  else if difficulty = 2 then toRemove := 46' + #13#10 +
  '  else toRemove := 54;' + #13#10 +
  '' + #13#10 +
  '  attempts := 0;' + #13#10 +
  '  while (toRemove > 0) and (attempts < 300) do' + #13#10 +
  '  begin' + #13#10 +
  '    pos := Random(81);' + #13#10 +
  '    if board[pos] <> 0 then' + #13#10 +
  '    begin' + #13#10 +
  '      board[pos] := 0;' + #13#10 +
  '      dec(toRemove);' + #13#10 +
  '    end;' + #13#10 +
  '    inc(attempts);' + #13#10 +
  '  end;' + #13#10 +
  '' + #13#10 +
  '  for i := 0 to 80 do' + #13#10 +
  '    if board[i] <> 0 then given[i] := 1' + #13#10 +
  '    else                   given[i] := 0;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '//  DAILY CHALLENGE' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '' + #13#10 +
  'procedure SeedFromDate;' + #13#10 +
  'var' + #13#10 +
  '  ds      : String;' + #13#10 +
  '  y, m, d : Integer;' + #13#10 +
  '  seed, i : Integer;' + #13#10 +
  '  waste   : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  ds   := DateStr;' + #13#10 +
  '  y    := StrToInt(Copy(ds, 1, 4));' + #13#10 +
  '  m    := StrToInt(Copy(ds, 6, 2));' + #13#10 +
  '  d    := StrToInt(Copy(ds, 9, 2));' + #13#10 +
  '  seed := y * 10000 + m * 100 + d;' + #13#10 +
  '  Randomize;' + #13#10 +
  '  for i := 1 to (seed mod 997) + 1 do' + #13#10 +
  '    waste := Random(1000);' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '//  PERSISTÊNCIA SQLite / SQLite PERSISTENCE' + #13#10 +
  '//  Banco de dados: pythia.db / Database: pythia.db' + #13#10 +
  '//  Tabelas / Tables:' + #13#10 +
  '//    sudoku_state      — jogo atual / current game' + #13#10 +
  '//    sudoku_best_times — melhores tempos / best times' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '' + #13#10 +
  'procedure InitDB;' + #13#10 +
  'begin' + #13#10 +
  '  DbOpen(dbPath);' + #13#10 +
  '  // Cria tabelas se não existirem / Create tables if they don''t exist' + #13#10 +
  '  DbExec(''CREATE TABLE IF NOT EXISTS sudoku_state ('' +' + #13#10 +
  '    ''id INTEGER PRIMARY KEY,'' +' + #13#10 +
  '    ''board TEXT,'' +' + #13#10 +
  '    ''given TEXT,'' +' + #13#10 +
  '    ''solution TEXT,'' +' + #13#10 +
  '    ''mode INTEGER,'' +' + #13#10 +
  '    ''elapsed INTEGER,'' +' + #13#10 +
  '    ''saved_at TEXT'' +' + #13#10 +
  '  '')'');' + #13#10 +
  '  DbExec(''CREATE TABLE IF NOT EXISTS sudoku_best_times ('' +' + #13#10 +
  '    ''mode INTEGER PRIMARY KEY,'' +' + #13#10 +
  '    ''best_seconds INTEGER,'' +' + #13#10 +
  '    ''achieved_at TEXT'' +' + #13#10 +
  '  '')'');' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'procedure SaveBestTime(diff, secs: Integer);' + #13#10 +
  'var' + #13#10 +
  '  existing : Integer;' + #13#10 +
  '  row      : String;' + #13#10 +
  'begin' + #13#10 +
  '  InitDB;' + #13#10 +
  '  row := DbQueryValue(''SELECT best_seconds FROM sudoku_best_times WHERE mode = '' + IntToStr(diff));' + #13#10 +
  '  if row = '''' then' + #13#10 +
  '  begin' + #13#10 +
  '    DbExec(''INSERT INTO sudoku_best_times (mode, best_seconds, achieved_at) VALUES ('' +' + #13#10 +
  '      IntToStr(diff) + '', '' + IntToStr(secs) + '', '''''' + DateStr + '''''')'');' + #13#10 +
  '  end' + #13#10 +
  '  else' + #13#10 +
  '  begin' + #13#10 +
  '    existing := StrToInt(row);' + #13#10 +
  '    if secs < existing then' + #13#10 +
  '      DbExec(''UPDATE sudoku_best_times SET best_seconds = '' + IntToStr(secs) +' + #13#10 +
  '        '', achieved_at = '''''' + DateStr + '''''''' +' + #13#10 +
  '        '' WHERE mode = '' + IntToStr(diff));' + #13#10 +
  '  end;' + #13#10 +
  '  DbClose;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'function LoadBestTime(diff: Integer): Integer;' + #13#10 +
  'var' + #13#10 +
  '  row : String;' + #13#10 +
  'begin' + #13#10 +
  '  InitDB;' + #13#10 +
  '  row := DbQueryValue(''SELECT best_seconds FROM sudoku_best_times WHERE mode = '' + IntToStr(diff));' + #13#10 +
  '  DbClose;' + #13#10 +
  '  if row = '''' then Result := 0' + #13#10 +
  '  else              Result := StrToInt(row);' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'procedure SaveState;' + #13#10 +
  'var' + #13#10 +
  '  bline, gline, sline : String;' + #13#10 +
  '  i                   : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  bline := '''';' + #13#10 +
  '  gline := '''';' + #13#10 +
  '  sline := '''';' + #13#10 +
  '  for i := 0 to 80 do' + #13#10 +
  '  begin' + #13#10 +
  '    bline := bline + IntToStr(board[i]);' + #13#10 +
  '    gline := gline + IntToStr(given[i]);' + #13#10 +
  '    sline := sline + IntToStr(solution[i]);' + #13#10 +
  '  end;' + #13#10 +
  '' + #13#10 +
  '  InitDB;' + #13#10 +
  '  DbExec(''DELETE FROM sudoku_state'');' + #13#10 +
  '  DbExec(''INSERT INTO sudoku_state (board, given, solution, mode, elapsed, saved_at) VALUES ('''''' +' + #13#10 +
  '    bline + '''''','''''' +' + #13#10 +
  '    gline + '''''','''''' +' + #13#10 +
  '    sline + '''''','' +' + #13#10 +
  '    IntToStr(gameMode) + '','' +' + #13#10 +
  '    IntToStr(elapsed) + '','''''' +' + #13#10 +
  '    DateStr + '' '' + TimeStr + '''''')'');' + #13#10 +
  '  DbClose;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'function LoadState: Boolean;' + #13#10 +
  'var' + #13#10 +
  '  bstr, gstr, sstr, mstr, estr : String;' + #13#10 +
  '  i                             : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  Result := False;' + #13#10 +
  '  InitDB;' + #13#10 +
  '  bstr := DbQueryValue(''SELECT board     FROM sudoku_state LIMIT 1'');' + #13#10 +
  '  gstr := DbQueryValue(''SELECT given     FROM sudoku_state LIMIT 1'');' + #13#10 +
  '  sstr := DbQueryValue(''SELECT solution  FROM sudoku_state LIMIT 1'');' + #13#10 +
  '  mstr := DbQueryValue(''SELECT mode      FROM sudoku_state LIMIT 1'');' + #13#10 +
  '  estr := DbQueryValue(''SELECT elapsed   FROM sudoku_state LIMIT 1'');' + #13#10 +
  '  DbClose;' + #13#10 +
  '' + #13#10 +
  '  if (Length(bstr) = 81) and (Length(gstr) = 81) and (Length(sstr) = 81) then' + #13#10 +
  '  begin' + #13#10 +
  '    for i := 0 to 80 do' + #13#10 +
  '    begin' + #13#10 +
  '      board[i]    := StrToInt(Copy(bstr, i + 1, 1));' + #13#10 +
  '      given[i]    := StrToInt(Copy(gstr, i + 1, 1));' + #13#10 +
  '      solution[i] := StrToInt(Copy(sstr, i + 1, 1));' + #13#10 +
  '    end;' + #13#10 +
  '    if mstr <> '''' then gameMode := StrToInt(mstr);' + #13#10 +
  '    if estr <> '''' then elapsed  := StrToInt(estr);' + #13#10 +
  '    Result := True;' + #13#10 +
  '  end;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '//  WIN CHECK — no Exit' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '' + #13#10 +
  'function CheckWin: Boolean;' + #13#10 +
  'var i : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  Result := True;' + #13#10 +
  '  i := 0;' + #13#10 +
  '  while (i < 81) and Result do' + #13#10 +
  '  begin' + #13#10 +
  '    if board[i] <> solution[i] then Result := False;' + #13#10 +
  '    i := i + 1;' + #13#10 +
  '  end;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '//  DRAWING' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '' + #13#10 +
  'procedure DrawGrid;' + #13#10 +
  'var' + #13#10 +
  '  r, c, x, y, digit, i : Integer;' + #13#10 +
  '  isSel, isGiv, hasCon  : Boolean;' + #13#10 +
  '  s                     : String;' + #13#10 +
  'begin' + #13#10 +
  '  GfxColor(''black'');' + #13#10 +
  '  GfxFillRect(0, 0, WIN_W, WIN_H);' + #13#10 +
  '' + #13#10 +
  '  for r := 0 to 8 do' + #13#10 +
  '  begin' + #13#10 +
  '    for c := 0 to 8 do' + #13#10 +
  '    begin' + #13#10 +
  '      x := GRID_X + c * CELL;' + #13#10 +
  '      y := GRID_Y + r * CELL;' + #13#10 +
  '' + #13#10 +
  '      digit  := board[RC(r, c)];' + #13#10 +
  '      isSel  := (r = selRow) and (c = selCol);' + #13#10 +
  '      isGiv  := given[RC(r, c)] = 1;' + #13#10 +
  '      hasCon := (digit <> 0) and Conflicts(r, c, digit);' + #13#10 +
  '' + #13#10 +
  '      if isSel then' + #13#10 +
  '        GfxColor(''#003366'')' + #13#10 +
  '      else if hasCon then' + #13#10 +
  '        GfxColor(''#330000'')' + #13#10 +
  '      else if isGiv then' + #13#10 +
  '        GfxColor(''#141428'')' + #13#10 +
  '      else' + #13#10 +
  '        GfxColor(''#0a0a1a'');' + #13#10 +
  '      GfxFillRect(x + 1, y + 1, CELL - 2, CELL - 2);' + #13#10 +
  '' + #13#10 +
  '      if digit <> 0 then' + #13#10 +
  '      begin' + #13#10 +
  '        GfxSetFont(22, isGiv);' + #13#10 +
  '        if hasCon then       GfxColor(''red'')' + #13#10 +
  '        else if isSel then   GfxColor(''cyan'')' + #13#10 +
  '        else if isGiv then   GfxColor(''white'')' + #13#10 +
  '        else                 GfxColor(''#7ec8e3'');' + #13#10 +
  '        s := IntToStr(digit);' + #13#10 +
  '        GfxDrawText(x + 18, y + 14, s);' + #13#10 +
  '      end;' + #13#10 +
  '    end;' + #13#10 +
  '  end;' + #13#10 +
  '' + #13#10 +
  '  for i := 0 to 9 do' + #13#10 +
  '  begin' + #13#10 +
  '    if (i mod 3) = 0 then GfxColor(''white'')' + #13#10 +
  '    else                  GfxColor(''#333355'');' + #13#10 +
  '    GfxDrawLine(GRID_X,          GRID_Y + i * CELL, GRID_X + GRID_W, GRID_Y + i * CELL);' + #13#10 +
  '    GfxDrawLine(GRID_X + i * CELL, GRID_Y,          GRID_X + i * CELL, GRID_Y + GRID_W);' + #13#10 +
  '  end;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'procedure DrawStatus;' + #13#10 +
  'var' + #13#10 +
  '  sy, best : Integer;' + #13#10 +
  '  mstr     : String;' + #13#10 +
  'begin' + #13#10 +
  '  sy := GRID_Y + GRID_W + 10;' + #13#10 +
  '  GfxColor(''black'');' + #13#10 +
  '  GfxFillRect(0, sy - 2, WIN_W, 56);' + #13#10 +
  '' + #13#10 +
  '  if gameMode = 1 then mstr := ''EASY''' + #13#10 +
  '  else if gameMode = 2 then mstr := ''MEDIUM''' + #13#10 +
  '  else if gameMode = 3 then mstr := ''HARD''' + #13#10 +
  '  else mstr := ''DAILY  '' + DateStr;' + #13#10 +
  '' + #13#10 +
  '  GfxSetFont(11, True);' + #13#10 +
  '  GfxColor(''#9999bb'');' + #13#10 +
  '  GfxDrawText(GRID_X, sy, mstr);' + #13#10 +
  '' + #13#10 +
  '  GfxSetFont(14, True);' + #13#10 +
  '  if gameWon then GfxColor(''lime'')' + #13#10 +
  '  else            GfxColor(''white'');' + #13#10 +
  '  GfxDrawText(GRID_X + 190, sy, FmtTime(elapsed));' + #13#10 +
  '' + #13#10 +
  '  best := LoadBestTime(gameMode);' + #13#10 +
  '  if best > 0 then' + #13#10 +
  '  begin' + #13#10 +
  '    GfxSetFont(11, False);' + #13#10 +
  '    GfxColor(''#777788'');' + #13#10 +
  '    GfxDrawText(GRID_X + 320, sy + 2, ''Best: '' + FmtTime(best));' + #13#10 +
  '  end;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'procedure DrawButtons;' + #13#10 +
  'var' + #13#10 +
  '  by, bh, bw, i, bx : Integer;' + #13#10 +
  '  lbl                : String;' + #13#10 +
  '  clr                : String;' + #13#10 +
  'begin' + #13#10 +
  '  by := GRID_Y + GRID_W + 44;' + #13#10 +
  '  bh := 36;' + #13#10 +
  '  bw := 108;' + #13#10 +
  '' + #13#10 +
  '  for i := 0 to 3 do' + #13#10 +
  '  begin' + #13#10 +
  '    bx := GRID_X + i * 118;' + #13#10 +
  '' + #13#10 +
  '    if i = 0 then begin lbl := ''Easy'';   clr := ''#1a472a''; end' + #13#10 +
  '    else if i = 1 then begin lbl := ''Medium''; clr := ''#1a3a47''; end' + #13#10 +
  '    else if i = 2 then begin lbl := ''Hard'';   clr := ''#472a1a''; end' + #13#10 +
  '    else begin lbl := ''Daily''; clr := ''#2e1a47''; end;' + #13#10 +
  '' + #13#10 +
  '    GfxColor(clr);' + #13#10 +
  '    GfxFillRect(bx, by, bw, bh);' + #13#10 +
  '    GfxColor(''#445566'');' + #13#10 +
  '    GfxDrawRect(bx, by, bw, bh);' + #13#10 +
  '    GfxSetFont(13, True);' + #13#10 +
  '    GfxColor(''white'');' + #13#10 +
  '    GfxDrawText(bx + 20, by + 10, lbl);' + #13#10 +
  '  end;' + #13#10 +
  '' + #13#10 +
  '  // Hint button — Easy mode only' + #13#10 +
  '  if (gameMode = 1) and (not gameWon) then' + #13#10 +
  '  begin' + #13#10 +
  '    GfxColor(''#4a4a00'');' + #13#10 +
  '    GfxFillRect(GRID_X + GRID_W - 64, GRID_Y - 34, 64, 26);' + #13#10 +
  '    GfxColor(''#888800'');' + #13#10 +
  '    GfxDrawRect(GRID_X + GRID_W - 64, GRID_Y - 34, 64, 26);' + #13#10 +
  '    GfxSetFont(11, True);' + #13#10 +
  '    GfxColor(''yellow'');' + #13#10 +
  '    GfxDrawText(GRID_X + GRID_W - 52, GRID_Y - 28, ''Hint'');' + #13#10 +
  '  end;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'procedure DrawWin;' + #13#10 +
  'var cx, cy : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  cx := GRID_X + 70;' + #13#10 +
  '  cy := GRID_Y + (GRID_W div 2) - 30;' + #13#10 +
  '  GfxSetFont(30, True);' + #13#10 +
  '  GfxColor(''lime'');' + #13#10 +
  '  GfxDrawText(cx, cy, ''SOLVED!'');' + #13#10 +
  '  GfxSetFont(14, False);' + #13#10 +
  '  GfxColor(''yellow'');' + #13#10 +
  '  GfxDrawText(cx + 10, cy + 40, ''Time: '' + FmtTime(elapsed));' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'procedure DrawAll;' + #13#10 +
  'begin' + #13#10 +
  '  DrawGrid;' + #13#10 +
  '  DrawStatus;' + #13#10 +
  '  DrawButtons;' + #13#10 +
  '  if gameWon then DrawWin;' + #13#10 +
  '  GfxShow;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '//  HIT TESTING — no Exit' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '' + #13#10 +
  'function HitCell(px, py: Integer; var r, c: Integer): Boolean;' + #13#10 +
  'var gx, gy : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  gx := px - GRID_X;' + #13#10 +
  '  gy := py - GRID_Y;' + #13#10 +
  '  if (gx >= 0) and (gy >= 0) and (gx < GRID_W) and (gy < GRID_W) then' + #13#10 +
  '  begin' + #13#10 +
  '    c      := gx div CELL;' + #13#10 +
  '    r      := gy div CELL;' + #13#10 +
  '    Result := True;' + #13#10 +
  '  end' + #13#10 +
  '  else' + #13#10 +
  '    Result := False;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'function HitButton(px, py: Integer): Integer;' + #13#10 +
  'var by, bh, bw, i, bx : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  by := GRID_Y + GRID_W + 44;' + #13#10 +
  '  bh := 36;' + #13#10 +
  '  bw := 108;' + #13#10 +
  '  Result := 0;' + #13#10 +
  '  if (py >= by) and (py <= by + bh) then' + #13#10 +
  '  begin' + #13#10 +
  '    i := 0;' + #13#10 +
  '    while (i < 4) and (Result = 0) do' + #13#10 +
  '    begin' + #13#10 +
  '      bx := GRID_X + i * 118;' + #13#10 +
  '      if (px >= bx) and (px <= bx + bw) then' + #13#10 +
  '        Result := i + 1;' + #13#10 +
  '      i := i + 1;' + #13#10 +
  '    end;' + #13#10 +
  '  end;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'function HitHint(px, py: Integer): Boolean;' + #13#10 +
  'var hx, hy : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  hx := GRID_X + GRID_W - 64;' + #13#10 +
  '  hy := GRID_Y - 34;' + #13#10 +
  '  Result := (gameMode = 1) and (not gameWon)' + #13#10 +
  '        and (px >= hx) and (px <= hx + 64)' + #13#10 +
  '        and (py >= hy) and (py <= hy + 26);' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '//  GIVE HINT' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '' + #13#10 +
  'procedure GiveHint;' + #13#10 +
  'var' + #13#10 +
  '  candidates : array of Integer;' + #13#10 +
  '  count, i, pick : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  SetLength(candidates, 81);' + #13#10 +
  '  count := 0;' + #13#10 +
  '  for i := 0 to 80 do' + #13#10 +
  '    if (board[i] = 0) and (given[i] = 0) then' + #13#10 +
  '    begin' + #13#10 +
  '      candidates[count] := i;' + #13#10 +
  '      count := count + 1;' + #13#10 +
  '    end;' + #13#10 +
  '' + #13#10 +
  '  if count > 0 then' + #13#10 +
  '  begin' + #13#10 +
  '    pick         := candidates[Random(count)];' + #13#10 +
  '    board[pick]  := solution[pick];' + #13#10 +
  '    given[pick]  := 1;' + #13#10 +
  '    inc(hintsUsed);' + #13#10 +
  '    selRow := pick div 9;' + #13#10 +
  '    selCol := pick mod 9;' + #13#10 +
  '  end;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '//  START GAME' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '' + #13#10 +
  'procedure StartGame(difficulty: Integer);' + #13#10 +
  'var' + #13#10 +
  '  firstEmpty, fi : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  gameMode  := difficulty;' + #13#10 +
  '  gameWon   := False;' + #13#10 +
  '  selRow    := -1;' + #13#10 +
  '  selCol    := -1;' + #13#10 +
  '  elapsed   := 0;' + #13#10 +
  '  lastSec   := -1;' + #13#10 +
  '  hintsUsed := 0;' + #13#10 +
  '' + #13#10 +
  '  if difficulty = 4 then' + #13#10 +
  '  begin' + #13#10 +
  '    SeedFromDate;' + #13#10 +
  '    GeneratePuzzle(2);' + #13#10 +
  '  end' + #13#10 +
  '  else' + #13#10 +
  '  begin' + #13#10 +
  '    Randomize;' + #13#10 +
  '    GeneratePuzzle(difficulty);' + #13#10 +
  '  end;' + #13#10 +
  '' + #13#10 +
  '  SaveState;' + #13#10 +
  '' + #13#10 +
  '  // Seleciona automaticamente a primeira célula vazia' + #13#10 +
  '  firstEmpty := -1;' + #13#10 +
  '  fi := 0;' + #13#10 +
  '  while (fi < 81) and (firstEmpty = -1) do' + #13#10 +
  '  begin' + #13#10 +
  '    if given[fi] = 0 then firstEmpty := fi;' + #13#10 +
  '    fi := fi + 1;' + #13#10 +
  '  end;' + #13#10 +
  '  if firstEmpty >= 0 then' + #13#10 +
  '  begin' + #13#10 +
  '    selRow := firstEmpty div 9;' + #13#10 +
  '    selCol := firstEmpty mod 9;' + #13#10 +
  '  end;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '//  MAIN' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '' + #13#10 +
  'var' + #13#10 +
  '  i, mx, my, btn, hr, hc : Integer;' + #13#10 +
  '  isDown, needDrw         : Boolean;' + #13#10 +
  '  key                     : String;' + #13#10 +
  '  fi2                     : Integer;' + #13#10 +
  '' + #13#10 +
  'begin' + #13#10 +
  '  WIN_W  := 560;' + #13#10 +
  '  WIN_H  := 620;' + #13#10 +
  '  CELL   := 54;' + #13#10 +
  '  GRID_X := 28;' + #13#10 +
  '  GRID_Y := 40;' + #13#10 +
  '  GRID_W := 9 * CELL;' + #13#10 +
  '' + #13#10 +
  '  dbPath  := GetAppPath + ''pythia.db'';' + #13#10 +
  '' + #13#10 +
  '  SetLength(board,    81);' + #13#10 +
  '  SetLength(given,    81);' + #13#10 +
  '  SetLength(solution, 81);' + #13#10 +
  '' + #13#10 +
  '  for i := 0 to 80 do' + #13#10 +
  '  begin' + #13#10 +
  '    board[i]    := 0;' + #13#10 +
  '    given[i]    := 0;' + #13#10 +
  '    solution[i] := 0;' + #13#10 +
  '  end;' + #13#10 +
  '' + #13#10 +
  '  GfxOpen(WIN_W, WIN_H, ''Sudoku  —  Pythia  v1.0'');' + #13#10 +
  '' + #13#10 +
  '  if LoadState then' + #13#10 +
  '  begin' + #13#10 +
  '    // Pergunta se quer retomar ou novo jogo' + #13#10 +
  '    // Ask if user wants to resume or start new' + #13#10 +
  '    if Confirm(''Jogo salvo encontrado. Retomar?'' + chr(10) + ''Saved game found. Resume?'') then' + #13#10 +
  '    begin' + #13#10 +
  '      // Retoma o jogo salvo / Resume saved game' + #13#10 +
  '      gameWon := CheckWin;' + #13#10 +
  '    end' + #13#10 +
  '    else' + #13#10 +
  '    begin' + #13#10 +
  '      // Começa novo jogo fácil / Start new easy game' + #13#10 +
  '      StartGame(1);' + #13#10 +
  '    end;' + #13#10 +
  '  end' + #13#10 +
  '  else' + #13#10 +
  '    StartGame(1);' + #13#10 +
  '' + #13#10 +
  '  gameWon   := CheckWin;' + #13#10 +
  '  wasDown   := False;' + #13#10 +
  '  tickCount := 0;' + #13#10 +
  '  hintsUsed := 0;' + #13#10 +
  '' + #13#10 +
  '  // Se o jogo foi carregado (não gerado), seleciona a primeira célula vazia' + #13#10 +
  '  if (selRow < 0) and (not gameWon) then' + #13#10 +
  '  begin' + #13#10 +
  '    fi2 := 0;' + #13#10 +
  '    while (fi2 < 81) and (selRow < 0) do' + #13#10 +
  '    begin' + #13#10 +
  '      if given[fi2] = 0 then' + #13#10 +
  '      begin' + #13#10 +
  '        selRow := fi2 div 9;' + #13#10 +
  '        selCol := fi2 mod 9;' + #13#10 +
  '      end;' + #13#10 +
  '      fi2 := fi2 + 1;' + #13#10 +
  '    end;' + #13#10 +
  '  end;' + #13#10 +
  '' + #13#10 +
  '  DrawAll;' + #13#10 +
  '' + #13#10 +
  '  while GfxRunning do' + #13#10 +
  '  begin' + #13#10 +
  '    Sleep(50);' + #13#10 +
  '    inc(tickCount);' + #13#10 +
  '' + #13#10 +
  '    if not gameWon then' + #13#10 +
  '    begin' + #13#10 +
  '      if (tickCount mod 20) = 0 then' + #13#10 +
  '      begin' + #13#10 +
  '        inc(elapsed);' + #13#10 +
  '        if elapsed <> lastSec then' + #13#10 +
  '        begin' + #13#10 +
  '          lastSec := elapsed;' + #13#10 +
  '          DrawAll;' + #13#10 +
  '        end;' + #13#10 +
  '      end;' + #13#10 +
  '    end;' + #13#10 +
  '' + #13#10 +
  '    mx     := GfxMouseX;' + #13#10 +
  '    my     := GfxMouseY;' + #13#10 +
  '    isDown := GfxMouseDown;' + #13#10 +
  '' + #13#10 +
  '    if isDown and (not wasDown) then' + #13#10 +
  '    begin' + #13#10 +
  '      btn := HitButton(mx, my);' + #13#10 +
  '      if btn > 0 then' + #13#10 +
  '      begin' + #13#10 +
  '        StartGame(btn);' + #13#10 +
  '        DrawAll;' + #13#10 +
  '      end' + #13#10 +
  '      else if HitHint(mx, my) then' + #13#10 +
  '      begin' + #13#10 +
  '        GiveHint;' + #13#10 +
  '        SaveState;' + #13#10 +
  '        DrawAll;' + #13#10 +
  '      end' + #13#10 +
  '      else if (not gameWon) and HitCell(mx, my, hr, hc) then' + #13#10 +
  '      begin' + #13#10 +
  '        if given[RC(hr, hc)] = 0 then' + #13#10 +
  '        begin' + #13#10 +
  '          selRow := hr;' + #13#10 +
  '          selCol := hc;' + #13#10 +
  '        end' + #13#10 +
  '        else' + #13#10 +
  '        begin' + #13#10 +
  '          selRow := -1;' + #13#10 +
  '          selCol := -1;' + #13#10 +
  '        end;' + #13#10 +
  '        DrawAll;' + #13#10 +
  '      end;' + #13#10 +
  '    end;' + #13#10 +
  '    wasDown := isDown;' + #13#10 +
  '' + #13#10 +
  '    while GfxKeyPressed do' + #13#10 +
  '    begin' + #13#10 +
  '      key     := GfxReadKey;' + #13#10 +
  '      needDrw := False;' + #13#10 +
  '' + #13#10 +
  '      if (not gameWon) and (selRow >= 0) and (selCol >= 0) then' + #13#10 +
  '      begin' + #13#10 +
  '        if (key >= ''1'') and (key <= ''9'') then' + #13#10 +
  '        begin' + #13#10 +
  '          board[RC(selRow, selCol)] := StrToInt(key);' + #13#10 +
  '          needDrw := True;' + #13#10 +
  '          if CheckWin then' + #13#10 +
  '          begin' + #13#10 +
  '            gameWon := True;' + #13#10 +
  '            SaveBestTime(gameMode, elapsed);' + #13#10 +
  '            // Limpa estado salvo ao vencer / Clear saved state on win' + #13#10 +
  '            InitDB;' + #13#10 +
  '            DbExec(''DELETE FROM sudoku_state'');' + #13#10 +
  '            DbClose;' + #13#10 +
  '          end;' + #13#10 +
  '        end' + #13#10 +
  '        else if (key = ''BACK'') or (key = ''DEL'') or (key = ''0'') then' + #13#10 +
  '        begin' + #13#10 +
  '          board[RC(selRow, selCol)] := 0;' + #13#10 +
  '          needDrw := True;' + #13#10 +
  '        end' + #13#10 +
  '        else if key = ''UP''    then begin if selRow > 0 then dec(selRow); needDrw := True; end' + #13#10 +
  '        else if key = ''DOWN''  then begin if selRow < 8 then inc(selRow); needDrw := True; end' + #13#10 +
  '        else if key = ''LEFT''  then begin if selCol > 0 then dec(selCol); needDrw := True; end' + #13#10 +
  '        else if key = ''RIGHT'' then begin if selCol < 8 then inc(selCol); needDrw := True; end;' + #13#10 +
  '      end' + #13#10 +
  '      else if key = ''ESC'' then' + #13#10 +
  '      begin' + #13#10 +
  '        selRow  := -1;' + #13#10 +
  '        selCol  := -1;' + #13#10 +
  '        needDrw := True;' + #13#10 +
  '      end;' + #13#10 +
  '' + #13#10 +
  '      if needDrw then' + #13#10 +
  '      begin' + #13#10 +
  '        SaveState;' + #13#10 +
  '        DrawAll;' + #13#10 +
  '      end;' + #13#10 +
  '    end;' + #13#10 +
  '  end;' + #13#10 +
  '' + #13#10 +
  '  GfxClose;' + #13#10 +
  'end.' + #13#10);

