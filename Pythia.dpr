program Pythia;
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
// =============================================================================
//  Pythia.dpr  -  Project file for Pythia
//
//  Units in this project:
//    ULexer.pas        — Tokeniser
//    UAST.pas          — Abstract Syntax Tree node definitions
//    UParser.pas       — Recursive-descent parser
//    UInterpreter.pas  — Tree-walking interpreter / runtime
//    UMainForm.pas        — VCL main form
//    UUnitLoader.pas      — Unit import system (.mdp uses clause)
//    UTheme.pas           — VCL Styles theme wrapper
//    UPreferencesDialog.pas — Theme preference dialog
// =============================================================================
uses
  Vcl.Forms,
  UTheme in 'UTheme.pas',
  UPreferencesDialog in 'UPreferencesDialog.pas',
  UMainForm in 'UMainForm.pas' {FormMain},
  ULexer in 'ULexer.pas',
  UAST in 'UAST.pas',
  UParser in 'UParser.pas',
  UInterpreter in 'UInterpreter.pas',
  ULearnTab in 'ULearnTab.pas',
  UProjectTab in 'UProjectTab.pas',
  UMacroLibrary in 'UMacroLibrary.pas',
  UExampleProjects in 'UExampleProjects.pas',
  UUnitLoader in 'UUnitLoader.pas',
  USQLite in 'USQLite.pas',
  UObjectRuntime in 'UObjectRuntime.pas',
  UValidator in 'UValidator.pas',
  UGraphics in 'UGraphics.pas',
  UAboutDialog in 'UAboutDialog.pas',
  UFormBuilderTab in 'UFormBuilderTab.pas',
  UFormDef in 'UFormDef.pas',
  UMacroTab in 'UMacroTab.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Iceberg Classico');
  Application.Title := 'Pythia';

  // Apply theme BEFORE creating any forms so VCL Styles paints correctly.
  Theme.Load;

  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
