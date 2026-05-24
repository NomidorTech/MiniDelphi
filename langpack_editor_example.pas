// ---------------------------------------------------------------------------
Add('Language Pack Editor', 'Tools', 'Crie e edite pacotes de idioma personalizados para o Pythia / Create and edit custom language packs for Pythia',
  '// ============================================================' + #13#10 +
  '// Editor de Pacotes de Idioma — Pythia' + #13#10 +
  '// Language Pack Editor — Pythia' + #13#10 +
  '// Nomidor Software, LLC' + #13#10 +
  '//' + #13#10 +
  '// Crie ou edite pacotes de idioma personalizados para o Pythia.' + #13#10 +
  '// Create or edit custom language packs for Pythia.' + #13#10 +
  '//' + #13#10 +
  '// O arquivo é salvo em:' + #13#10 +
  '// The file is saved to:' + #13#10 +
  '//   <pastaDoExe>\LangPacks\<codigo>.ini' + #13#10 +
  '//' + #13#10 +
  '// Formato / Format:' + #13#10 +
  '//   [Meta]' + #13#10 +
  '//   Name=Meu Idioma' + #13#10 +
  '//   Code=xx' + #13#10 +
  '//   Author=Seu Nome' + #13#10 +
  '//   Version=1.0' + #13#10 +
  '//   [Strings]' + #13#10 +
  '//   TabCompiler=...' + #13#10 +
  '//   BtnRun=...' + #13#10 +
  '//   ...' + #13#10 +
  '// ============================================================' + #13#10 +
  '' + #13#10 +
  'var' + #13#10 +
  '  packPath  : String;' + #13#10 +
  '  packName  : String;' + #13#10 +
  '  packCode  : String;' + #13#10 +
  '  packAuthor: String;' + #13#10 +
  '  packVer   : String;' + #13#10 +
  '' + #13#10 +
  '// Todas as chaves que precisam ser traduzidas' + #13#10 +
  '// All keys that need to be translated' + #13#10 +
  'var' + #13#10 +
  '  keys : array of String;' + #13#10 +
  '  vals : array of String;' + #13#10 +
  '' + #13#10 +
  'procedure InitKeys;' + #13#10 +
  'begin' + #13#10 +
  '  SetLength(keys, 76);' + #13#10 +
  '  SetLength(vals, 76);' + #13#10 +
  '' + #13#10 +
  '  keys[0]  := ''TabCompiler'';     keys[1]  := ''TabCalculator'';' + #13#10 +
  '  keys[2]  := ''TabLearn'';        keys[3]  := ''TabProjects'';' + #13#10 +
  '  keys[4]  := ''TabForms'';        keys[5]  := ''TabMacros'';' + #13#10 +
  '  keys[6]  := ''BtnRun'';          keys[7]  := ''BtnStop'';' + #13#10 +
  '  keys[8]  := ''BtnClear'';        keys[9]  := ''BtnNew'';' + #13#10 +
  '  keys[10] := ''BtnOpen'';         keys[11] := ''BtnSave'';' + #13#10 +
  '  keys[12] := ''BtnSaveAs'';       keys[13] := ''BtnDelete'';' + #13#10 +
  '  keys[14] := ''MenuFile'';        keys[15] := ''MenuView'';' + #13#10 +
  '  keys[16] := ''MenuHelp'';        keys[17] := ''MenuNewFile'';' + #13#10 +
  '  keys[18] := ''MenuOpenFile'';    keys[19] := ''MenuSave'';' + #13#10 +
  '  keys[20] := ''MenuSaveAs'';      keys[21] := ''MenuExit'';' + #13#10 +
  '  keys[22] := ''MenuPreferences''; keys[23] := ''MenuAbout'';' + #13#10 +
  '  keys[24] := ''MenuExamples'';    keys[25] := ''MenuTokens'';' + #13#10 +
  '  keys[26] := ''MenuAST'';         keys[27] := ''MenuProjectSrc'';' + #13#10 +
  '  keys[28] := ''StatusReady'';     keys[29] := ''StatusCleared'';' + #13#10 +
  '  keys[30] := ''StatusRunning'';   keys[31] := ''StatusDone'';' + #13#10 +
  '  keys[32] := ''StatusError'';     keys[33] := ''StatusExLoaded'';' + #13#10 +
  '  keys[34] := ''StatusSaved'';     keys[35] := ''StatusOpened'';' + #13#10 +
  '  keys[36] := ''CalcPrompt'';      keys[37] := ''CalcBtn'';' + #13#10 +
  '  keys[38] := ''CalcHint'';' + #13#10 +
  '  keys[39] := ''ProjectAndExamples''; keys[40] := ''ExampleProjects'';' + #13#10 +
  '  keys[41] := ''SourceEditor'';    keys[42] := ''Output'';' + #13#10 +
  '  keys[43] := ''PrefsTitle'';      keys[44] := ''PrefsAppearance'';' + #13#10 +
  '  keys[45] := ''PrefsLanguage'';   keys[46] := ''PrefsTheme'';' + #13#10 +
  '  keys[47] := ''PrefsLangNote'';' + #13#10 +
  '  keys[48] := ''PrefsThemeDark'';  keys[49] := ''PrefsThemeLight'';' + #13#10 +
  '  keys[50] := ''PrefsThemeSys'';   keys[51] := ''PrefsThemeNote'';' + #13#10 +
  '  keys[52] := ''PrefsBtnOK'';      keys[53] := ''PrefsBtnCancel'';' + #13#10 +
  '  keys[54] := ''DlgOpenFilter'';   keys[55] := ''DlgSaveFilter'';' + #13#10 +
  '  keys[56] := ''DlgConfirmDelete''; keys[57] := ''DlgUnsaved'';' + #13#10 +
  '  keys[58] := ''MacroTrusted'';    keys[59] := ''MacroRun'';' + #13#10 +
  '  keys[60] := ''MacroNew'';' + #13#10 +
  '  keys[61] := ''FormNew'';         keys[62] := ''FormPalette'';' + #13#10 +
  '  keys[63] := ''FormInspector'';   keys[64] := ''FormPreview'';' + #13#10 +
  '  keys[65] := ''LearnTitle'';      keys[66] := ''LearnNext'';' + #13#10 +
  '  keys[67] := ''LearnPrev'';       keys[68] := ''LearnCheck'';' + #13#10 +
  '  keys[69] := ''LearnHint'';' + #13#10 +
  '  keys[70] := ''AboutTitle'';' + #13#10 +
  '  keys[71] := ''LangPackEditor'';  keys[72] := ''LangPackNew'';' + #13#10 +
  '  keys[73] := ''LangPackSave'';    keys[74] := ''LangPackTest'';' + #13#10 +
  '  keys[75] := ''LangPackName'';' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'procedure LoadExistingPack(filename: String);' + #13#10 +
  'var' + #13#10 +
  '  content, line, key, val : String;' + #13#10 +
  '  i, eqpos               : Integer;' + #13#10 +
  '  inStrings              : Boolean;' + #13#10 +
  'begin' + #13#10 +
  '  if not FileExists(filename) then' + #13#10 +
  '  begin' + #13#10 +
  '    writeln(''Arquivo não encontrado: '' + filename);' + #13#10 +
  '    writeln(''File not found: '' + filename);' + #13#10 +
  '    writeln(''Iniciando pacote em branco / Starting blank pack.'');' + #13#10 +
  '    exit;' + #13#10 +
  '  end;' + #13#10 +
  '' + #13#10 +
  '  content   := ReadFile(filename);' + #13#10 +
  '  inStrings := False;' + #13#10 +
  '' + #13#10 +
  '  // Processa linha por linha' + #13#10 +
  '  var lines : array of String;' + #13#10 +
  '  SetLength(lines, 0);' + #13#10 +
  '' + #13#10 +
  '  // Divide em linhas manualmente' + #13#10 +
  '  var pos1, pos2 : Integer;' + #13#10 +
  '  pos1 := 1;' + #13#10 +
  '  pos2 := Pos(chr(10), content);' + #13#10 +
  '  while pos2 > 0 do' + #13#10 +
  '  begin' + #13#10 +
  '    SetLength(lines, Length(lines) + 1);' + #13#10 +
  '    lines[Length(lines) - 1] := Copy(content, pos1, pos2 - pos1);' + #13#10 +
  '    pos1 := pos2 + 1;' + #13#10 +
  '    pos2 := Pos(chr(10), Copy(content, pos1, Length(content)));' + #13#10 +
  '    if pos2 > 0 then pos2 := pos2 + pos1 - 1;' + #13#10 +
  '  end;' + #13#10 +
  '  if pos1 <= Length(content) then' + #13#10 +
  '  begin' + #13#10 +
  '    SetLength(lines, Length(lines) + 1);' + #13#10 +
  '    lines[Length(lines) - 1] := Copy(content, pos1, Length(content));' + #13#10 +
  '  end;' + #13#10 +
  '' + #13#10 +
  '  for i := 0 to Length(lines) - 1 do' + #13#10 +
  '  begin' + #13#10 +
  '    line := Trim(lines[i]);' + #13#10 +
  '    if line = ''[Meta]'' then inStrings := False' + #13#10 +
  '    else if line = ''[Strings]'' then inStrings := True' + #13#10 +
  '    else if (not inStrings) and (Pos(''='', line) > 0) then' + #13#10 +
  '    begin' + #13#10 +
  '      eqpos := Pos(''='', line);' + #13#10 +
  '      key   := Trim(Copy(line, 1, eqpos - 1));' + #13#10 +
  '      val   := Trim(Copy(line, eqpos + 1, Length(line)));' + #13#10 +
  '      if key = ''Name''    then packName   := val' + #13#10 +
  '      else if key = ''Code''    then packCode   := val' + #13#10 +
  '      else if key = ''Author''  then packAuthor := val' + #13#10 +
  '      else if key = ''Version'' then packVer    := val;' + #13#10 +
  '    end' + #13#10 +
  '    else if inStrings and (Pos(''='', line) > 0) then' + #13#10 +
  '    begin' + #13#10 +
  '      eqpos := Pos(''='', line);' + #13#10 +
  '      key   := Trim(Copy(line, 1, eqpos - 1));' + #13#10 +
  '      val   := Trim(Copy(line, eqpos + 1, Length(line)));' + #13#10 +
  '      var ki : Integer;' + #13#10 +
  '      for ki := 0 to Length(keys) - 1 do' + #13#10 +
  '        if keys[ki] = key then vals[ki] := val;' + #13#10 +
  '    end;' + #13#10 +
  '  end;' + #13#10 +
  '  writeln(''Pacote carregado / Pack loaded: '' + packName + ''  ['' + packCode + '']'');' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'procedure SavePack;' + #13#10 +
  'var' + #13#10 +
  '  content : String;' + #13#10 +
  '  i       : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  if packCode = '''' then' + #13#10 +
  '  begin' + #13#10 +
  '    writeln(''Erro: código do idioma não definido / Error: language code not set.'');' + #13#10 +
  '    exit;' + #13#10 +
  '  end;' + #13#10 +
  '' + #13#10 +
  '  content := ''[Meta]'' + chr(13) + chr(10);' + #13#10 +
  '  content := content + ''Name=''    + packName   + chr(13) + chr(10);' + #13#10 +
  '  content := content + ''Code=''    + packCode   + chr(13) + chr(10);' + #13#10 +
  '  content := content + ''Author=''  + packAuthor + chr(13) + chr(10);' + #13#10 +
  '  content := content + ''Version='' + packVer    + chr(13) + chr(10);' + #13#10 +
  '  content := content + chr(13) + chr(10);' + #13#10 +
  '  content := content + ''[Strings]'' + chr(13) + chr(10);' + #13#10 +
  '' + #13#10 +
  '  for i := 0 to Length(keys) - 1 do' + #13#10 +
  '    if vals[i] <> '''' then' + #13#10 +
  '      content := content + keys[i] + ''='' + vals[i] + chr(13) + chr(10);' + #13#10 +
  '' + #13#10 +
  '  packPath := GetAppPath + ''LangPacks\'' + packCode + ''.ini'';' + #13#10 +
  '  WriteFile(packPath, content);' + #13#10 +
  '  writeln('''');' + #13#10 +
  '  writeln(''Pacote salvo em / Pack saved to:'');' + #13#10 +
  '  writeln(''  '' + packPath);' + #13#10 +
  '  writeln('''');' + #13#10 +
  '  writeln(''Reinicie o Pythia para carregar o novo idioma.'');' + #13#10 +
  '  writeln(''Restart Pythia to load the new language.'');' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'procedure ShowMenu;' + #13#10 +
  'begin' + #13#10 +
  '  writeln('''');' + #13#10 +
  '  writeln(''======================================'');' + #13#10 +
  '  writeln(''  Editor de Pacotes de Idioma / Language Pack Editor'');' + #13#10 +
  '  writeln(''======================================'');' + #13#10 +
  '  writeln(''  Idioma / Language: '' + packName + ''  ['' + packCode + '']'');' + #13#10 +
  '  writeln(''  Autor / Author:    '' + packAuthor);' + #13#10 +
  '  writeln(''  Versão / Version:  '' + packVer);' + #13#10 +
  '  writeln(''--------------------------------------'');' + #13#10 +
  '  writeln(''  1. Definir metadados / Set metadata'');' + #13#10 +
  '  writeln(''  2. Traduzir strings / Translate strings'');' + #13#10 +
  '  writeln(''  3. Ver strings atuais / View current strings'');' + #13#10 +
  '  writeln(''  4. Salvar pacote / Save pack'');' + #13#10 +
  '  writeln(''  5. Carregar pacote existente / Load existing pack'');' + #13#10 +
  '  writeln(''  0. Sair / Exit'');' + #13#10 +
  '  writeln(''======================================'');' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'procedure SetMetadata;' + #13#10 +
  'begin' + #13#10 +
  '  writeln('''');' + #13#10 +
  '  writeln(''--- Metadados / Metadata ---'');' + #13#10 +
  '  writeln(''Nome do idioma (ex: Español): '');' + #13#10 +
  '  packName   := InputBox(''Metadados'', ''Nome do idioma / Language name:'', packName);' + #13#10 +
  '  packCode   := InputBox(''Metadados'', ''Código (ex: es, de, ja):'', packCode);' + #13#10 +
  '  packAuthor := InputBox(''Metadados'', ''Autor / Author:'', packAuthor);' + #13#10 +
  '  packVer    := InputBox(''Metadados'', ''Versão / Version:'', packVer);' + #13#10 +
  '  writeln(''Metadados definidos / Metadata set.'');' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'procedure TranslateStrings;' + #13#10 +
  'var' + #13#10 +
  '  i   : Integer;' + #13#10 +
  '  val : String;' + #13#10 +
  'begin' + #13#10 +
  '  writeln('''');' + #13#10 +
  '  writeln(''--- Tradução / Translation ---'');' + #13#10 +
  '  writeln(''Pressione Enter para manter o valor atual.'');' + #13#10 +
  '  writeln(''Press Enter to keep the current value.'');' + #13#10 +
  '  writeln('''');' + #13#10 +
  '' + #13#10 +
  '  for i := 0 to Length(keys) - 1 do' + #13#10 +
  '  begin' + #13#10 +
  '    writeln(''['' + IntToStr(i + 1) + ''/'' + IntToStr(Length(keys)) + ''] '' + keys[i]);' + #13#10 +
  '    if vals[i] <> '''' then' + #13#10 +
  '      writeln(''  Atual / Current: '' + vals[i]);' + #13#10 +
  '    val := InputBox(''Tradução'', keys[i] + '':'', vals[i]);' + #13#10 +
  '    if val <> '''' then vals[i] := val;' + #13#10 +
  '  end;' + #13#10 +
  '  writeln('''');' + #13#10 +
  '  writeln(''Tradução concluída / Translation complete.'');' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  'procedure ViewStrings;' + #13#10 +
  'var i : Integer;' + #13#10 +
  'begin' + #13#10 +
  '  writeln('''');' + #13#10 +
  '  writeln(''--- Strings Atuais / Current Strings ---'');' + #13#10 +
  '  for i := 0 to Length(keys) - 1 do' + #13#10 +
  '  begin' + #13#10 +
  '    if vals[i] <> '''' then' + #13#10 +
  '      writeln(''  '' + keys[i] + '' = '' + vals[i])' + #13#10 +
  '    else' + #13#10 +
  '      writeln(''  '' + keys[i] + '' = (não traduzido / not translated)'');' + #13#10 +
  '  end;' + #13#10 +
  'end;' + #13#10 +
  '' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '//  MAIN' + #13#10 +
  '// ===========================================================================' + #13#10 +
  '' + #13#10 +
  'var' + #13#10 +
  '  choice : String;' + #13#10 +
  '  running: Boolean;' + #13#10 +
  '  i      : Integer;' + #13#10 +
  '' + #13#10 +
  'begin' + #13#10 +
  '  InitKeys;' + #13#10 +
  '' + #13#10 +
  '  // Inicializa valores com strings em branco' + #13#10 +
  '  for i := 0 to Length(vals) - 1 do vals[i] := '''';' + #13#10 +
  '' + #13#10 +
  '  // Metadados padrão / Default metadata' + #13#10 +
  '  packName   := '''';' + #13#10 +
  '  packCode   := '''';' + #13#10 +
  '  packAuthor := '''';' + #13#10 +
  '  packVer    := ''1.0'';' + #13#10 +
  '' + #13#10 +
  '  writeln(''Editor de Pacotes de Idioma do Pythia'');' + #13#10 +
  '  writeln(''Pythia Language Pack Editor'');' + #13#10 +
  '  writeln('''');' + #13#10 +
  '  writeln(''Para carregar um pacote existente, informe o caminho.'');' + #13#10 +
  '  writeln(''To load an existing pack, enter the path.'');' + #13#10 +
  '  writeln(''(Deixe em branco para criar novo / Leave blank to create new)'');' + #13#10 +
  '  writeln('''');' + #13#10 +
  '' + #13#10 +
  '  var existingPath : String;' + #13#10 +
  '  existingPath := InputBox(''Carregar Pacote'', ''Caminho do arquivo .ini (ou deixe em branco):'', '''');' + #13#10 +
  '  if existingPath <> '''' then' + #13#10 +
  '    LoadExistingPack(existingPath);' + #13#10 +
  '' + #13#10 +
  '  running := True;' + #13#10 +
  '  while running do' + #13#10 +
  '  begin' + #13#10 +
  '    ShowMenu;' + #13#10 +
  '    choice := InputBox(''Menu'', ''Escolha / Choose (0-5):'', '''');' + #13#10 +
  '' + #13#10 +
  '    if choice = ''1'' then SetMetadata' + #13#10 +
  '    else if choice = ''2'' then TranslateStrings' + #13#10 +
  '    else if choice = ''3'' then ViewStrings' + #13#10 +
  '    else if choice = ''4'' then SavePack' + #13#10 +
  '    else if choice = ''5'' then' + #13#10 +
  '    begin' + #13#10 +
  '      var path2 : String;' + #13#10 +
  '      path2 := InputBox(''Carregar'', ''Caminho do .ini:'', '''');' + #13#10 +
  '      if path2 <> '''' then LoadExistingPack(path2);' + #13#10 +
  '    end' + #13#10 +
  '    else if choice = ''0'' then running := False;' + #13#10 +
  '  end;' + #13#10 +
  '' + #13#10 +
  '  writeln('''');' + #13#10 +
  '  writeln(''Até logo! / Goodbye!'');' + #13#10 +
  'end.' + #13#10);

