unit UPreferencesDialog;

// =============================================================================
// Pythia -- ambiente de aprendizado Pascal / Pascal learning environment
// Copyright (C) 2026 Nomidor Software, LLC.
// GPL v3 — veja/see https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
//
//  UPreferencesDialog.pas  —  Diálogo modal de Preferências
//                              Modal Preferences dialog
//
//  Aba Aparência / Appearance tab  — tema escuro / claro / sistema
//  Aba Idioma / Language tab       — dropdown com todos os idiomas instalados
//
//  Idiomas embutidos: en pt fr es es-419 uk de it ja zh ko hi ar
//  External packs:    <exedir>\LangPacks\*.ini  (carregados automaticamente)
//
//  Persistência / Persistence: pythia.ini
// =============================================================================

interface

procedure ShowPreferencesDialog;

implementation

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Graphics, System.UITypes, Vcl.Dialogs,
  UTheme, ULanguage;

type
  TPrefsForm = class(TForm)
  private
    FPages      : TPageControl;
    FTabAppr    : TTabSheet;
    FTabLang    : TTabSheet;

    // Aparência / Appearance
    FGrpTheme   : TGroupBox;
    FRBDark     : TRadioButton;
    FRBLight    : TRadioButton;
    FRBSys      : TRadioButton;
    FLblSys     : TLabel;
    FLblThNote  : TLabel;

    // Idioma / Language
    FGrpLang    : TGroupBox;
    FLblLang    : TLabel;
    FComboLang  : TComboBox;   // dropdown com todos os idiomas / all languages
    FLblLangNote: TLabel;
    FLblPacksDir: TLabel;      // mostra onde ficam os packs / shows pack folder

    // Botões / Buttons
    FBtnOK      : TButton;
    FBtnCancel  : TButton;

    FOrigMode   : TThemeMode;
    FOrigCode   : string;      // código do idioma original / original language code

    procedure Build;
    procedure PopulateLanguageCombo;
    procedure OnThemeChange(Sender: TObject);
    procedure OnOK         (Sender: TObject);
    procedure OnCancel     (Sender: TObject);
  public
    constructor CreatePrefs(AOwner: TComponent);
  end;

procedure ShowPreferencesDialog;
var Dlg : TPrefsForm;
begin
  Dlg := TPrefsForm.CreatePrefs(Application);
  try Dlg.ShowModal;
  finally Dlg.Free; end;
end;

constructor TPrefsForm.CreatePrefs(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption     := Lang.S(lsPrefsTitle);
  Position    := poScreenCenter;
  Width       := 500;
  Height      := 460;
  BorderStyle := bsDialog;
  Font.Name   := 'Segoe UI';
  Font.Size   := 10;
  FOrigMode   := Theme.Mode;
  FOrigCode   := Lang.ActiveCode;
  Build;
end;

procedure TPrefsForm.Build;
var SysLabel : string;
begin
  FPages              := TPageControl.Create(Self);
  FPages.Parent       := Self;
  FPages.Align        := alClient;

  // ── Aba Aparência / Appearance Tab ───────────────────────────────────────
  FTabAppr             := TTabSheet.Create(FPages);
  FTabAppr.PageControl := FPages;
  FTabAppr.Caption     := '  ' + Lang.S(lsPrefsAppearance) + '  ';

  FGrpTheme         := TGroupBox.Create(FTabAppr);
  FGrpTheme.Parent  := FTabAppr;
  FGrpTheme.Caption := ' ' + Lang.S(lsPrefsTheme) + ' ';
  FGrpTheme.SetBounds(16, 16, 450, 220);

  FRBDark         := TRadioButton.Create(FGrpTheme);
  FRBDark.Parent  := FGrpTheme;
  FRBDark.Caption := Lang.S(lsPrefsThemeDark);
  FRBDark.SetBounds(20, 32, 400, 24);

  FRBLight         := TRadioButton.Create(FGrpTheme);
  FRBLight.Parent  := FGrpTheme;
  FRBLight.Caption := Lang.S(lsPrefsThemeLight);
  FRBLight.SetBounds(20, 60, 400, 24);

  FRBSys         := TRadioButton.Create(FGrpTheme);
  FRBSys.Parent  := FGrpTheme;
  FRBSys.Caption := Lang.S(lsPrefsThemeSys);
  FRBSys.SetBounds(20, 88, 400, 24);

  if Theme.Current = tkLight then SysLabel := '(Windows: Light)'
  else                            SysLabel := '(Windows: Dark)';
  FLblSys            := TLabel.Create(FGrpTheme);
  FLblSys.Parent     := FGrpTheme;
  FLblSys.Caption    := SysLabel;
  FLblSys.SetBounds(40, 116, 380, 20);
  FLblSys.Font.Color := clGrayText;

  FLblThNote            := TLabel.Create(FGrpTheme);
  FLblThNote.Parent     := FGrpTheme;
  FLblThNote.Caption    := Lang.S(lsPrefsThemeNote);
  FLblThNote.SetBounds(20, 172, 410, 36);
  FLblThNote.WordWrap   := True;
  FLblThNote.Font.Color := clGrayText;

  case Theme.Mode of
    tmDark          : FRBDark.Checked  := True;
    tmLight         : FRBLight.Checked := True;
    tmFollowWindows : FRBSys.Checked   := True;
  end;
  // Wire OnClick AFTER setting Checked to avoid nil-pointer during init
  FRBDark.OnClick  := OnThemeChange;
  FRBLight.OnClick := OnThemeChange;
  FRBSys.OnClick   := OnThemeChange;

  // ── Aba Idioma / Language Tab ─────────────────────────────────────────────
  FTabLang             := TTabSheet.Create(FPages);
  FTabLang.PageControl := FPages;
  FTabLang.Caption     := '  ' + Lang.S(lsPrefsLanguage) + '  ';

  FGrpLang         := TGroupBox.Create(FTabLang);
  FGrpLang.Parent  := FTabLang;
  FGrpLang.Caption := ' ' + Lang.S(lsPrefsLanguage) + ' ';
  FGrpLang.SetBounds(16, 16, 450, 280);

  // Label + Dropdown
  FLblLang         := TLabel.Create(FGrpLang);
  FLblLang.Parent  := FGrpLang;
  FLblLang.Caption := Lang.S(lsPrefsLanguage) + ':';
  FLblLang.SetBounds(20, 32, 200, 20);

  FComboLang             := TComboBox.Create(FGrpLang);
  FComboLang.Parent      := FGrpLang;
  FComboLang.Style       := csDropDownList;  // só leitura / read-only
  FComboLang.SetBounds(20, 54, 400, 28);
  PopulateLanguageCombo;

  // Nota de reinício / Restart note
  FLblLangNote            := TLabel.Create(FGrpLang);
  FLblLangNote.Parent     := FGrpLang;
  FLblLangNote.Caption    := Lang.S(lsPrefsLangNote);
  FLblLangNote.SetBounds(20, 100, 410, 40);
  FLblLangNote.WordWrap   := True;
  FLblLangNote.Font.Color := clGrayText;

  // Mostra a pasta dos packs externos / Show external packs folder
  FLblPacksDir            := TLabel.Create(FGrpLang);
  FLblPacksDir.Parent     := FGrpLang;
  FLblPacksDir.Caption    :=
    Lang.S(lsLangPackInstalled) + sLineBreak +
    Lang.PacksDir;
  FLblPacksDir.SetBounds(20, 156, 410, 50);
  FLblPacksDir.WordWrap   := True;
  FLblPacksDir.Font.Color := clGrayText;
  FLblPacksDir.Font.Size  := 8;

  // ── Botões / Buttons ──────────────────────────────────────────────────────
  FBtnOK         := TButton.Create(Self);
  FBtnOK.Parent  := Self;
  FBtnOK.Caption := Lang.S(lsPrefsBtnOK);
  FBtnOK.Width   := 96;  FBtnOK.Height := 30;
  FBtnOK.Anchors := [akRight, akBottom];
  FBtnOK.Left    := Self.ClientWidth - 210;
  FBtnOK.Top     := Self.ClientHeight - 46;
  FBtnOK.OnClick := OnOK;
  FBtnOK.Default := True;

  FBtnCancel         := TButton.Create(Self);
  FBtnCancel.Parent  := Self;
  FBtnCancel.Caption := Lang.S(lsPrefsBtnCancel);
  FBtnCancel.Width   := 96;  FBtnCancel.Height := 30;
  FBtnCancel.Anchors := [akRight, akBottom];
  FBtnCancel.Left    := Self.ClientWidth - 108;
  FBtnCancel.Top     := Self.ClientHeight - 46;
  FBtnCancel.OnClick := OnCancel;
  FBtnCancel.Cancel  := True;
end;

procedure TPrefsForm.PopulateLanguageCombo;
var
  P    : TLangPack;
  I    : Integer;
  Item : string;
begin
  FComboLang.Items.BeginUpdate;
  try
    FComboLang.Items.Clear;
    for I := 0 to Lang.AllPacks.Count - 1 do
    begin
      P    := Lang.AllPacks[I];
      // Mostra nome nativo + código / Show native name + code
      Item := P.Name + '  [' + P.Code + ']';
      if not P.IsBuiltIn then Item := Item + '  ✦';  // marca packs externos
      FComboLang.Items.AddObject(Item, P);
    end;
    // Seleciona o idioma ativo / Select the active language
    for I := 0 to FComboLang.Items.Count - 1 do
      if TLangPack(FComboLang.Items.Objects[I]).Code = Lang.ActiveCode then
      begin
        FComboLang.ItemIndex := I;
        Break;
      end;
    if FComboLang.ItemIndex < 0 then FComboLang.ItemIndex := 0;
  finally
    FComboLang.Items.EndUpdate;
  end;
end;

procedure TPrefsForm.OnThemeChange(Sender: TObject);
begin
  if      FRBDark.Checked  then Theme.SetMode(tmDark)
  else if FRBLight.Checked then Theme.SetMode(tmLight)
  else if FRBSys.Checked   then Theme.SetMode(tmFollowWindows);
end;

procedure TPrefsForm.OnOK(Sender: TObject);
var P : TLangPack;
begin
  // Aplica seleção de idioma / Apply language selection
  if FComboLang.ItemIndex >= 0 then
  begin
    P := TLangPack(FComboLang.Items.Objects[FComboLang.ItemIndex]);
    if Assigned(P) then Lang.SetLanguage(P.Code);
  end;
  ModalResult := mrOk;
end;

procedure TPrefsForm.OnCancel(Sender: TObject);
begin
  // Reverte tema / Revert theme
  if Theme.Mode <> FOrigMode then Theme.SetMode(FOrigMode);
  // Reverte idioma / Revert language
  if Lang.ActiveCode <> FOrigCode then Lang.SetLanguage(FOrigCode);
  ModalResult := mrCancel;
end;

end.
