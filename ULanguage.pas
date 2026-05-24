unit ULanguage;


// =============================================================================
// Pythia -- ambiente de aprendizado Pascal / Pascal learning environment
// Copyright (C) 2026 Nomidor Software, LLC.
// GPL v3 — veja/see https://www.gnu.org/licenses/gpl-3.0.html
// =============================================================================
//
//  ULanguage.pas  -  Sistema de internacionalização (i18n) do Pythia
//                    Pythia internationalisation (i18n) system
//
//  Idiomas embutidos / Built-in languages:
//    en  English       (padrão / default)
//    pt  Português
//    fr  Français
//    es  Español
//    uk  Українська
//    de  Deutsch
//    it  Italiano
//    ja  日本語
//    zh  简体中文
//    ko  한국어
//    hi  हिन्दी
//    ar  العربية
//    es-419  Español Latinoamericano
//
//  Pacotes externos / External packs:
//    Arquivos INI em <exedir>\LangPacks\<code>.ini
//    INI files in <exedir>\LangPacks\<code>.ini
//    Formato / Format:
//      [Meta]
//      Name=My Language
//      Code=xx
//      Author=Community
//      Version=1.0
//      [Strings]
//      TabCompiler=...
//      BtnRun=...
//      (uma chave por string / one key per string)
//
//  Uso / Usage:
//    Lang.SetLanguage('pt');
//    Caption := Lang.S(lsBtnRun);
//
//  Persistência / Persistence:
//    pythia.ini → [Language] Code=en|pt|fr|...
// =============================================================================

interface

uses
  System.SysUtils, System.IniFiles, System.IOUtils,
  System.Classes, System.Generics.Collections;

type
  // Identificadores de strings / UI string identifiers
  TLangString = (
    lsTabCompiler, lsTabCalculator, lsTabLearn, lsTabProjects,
    lsTabForms, lsTabMacros,
    lsBtnRun, lsBtnStop, lsBtnClear,
    lsBtnNew, lsBtnOpen, lsBtnSave, lsBtnSaveAs, lsBtnDelete,
    lsMenuFile, lsMenuView, lsMenuHelp,
    lsMenuNewFile, lsMenuOpenFile, lsMenuSave, lsMenuSaveAs, lsMenuExit,
    lsMenuPreferences, lsMenuAbout, lsMenuExamples,
    lsMenuTokens, lsMenuAST, lsMenuProjectSrc,
    lsStatusReady, lsStatusCleared, lsStatusRunning, lsStatusDone,
    lsStatusError, lsStatusExLoaded, lsStatusSaved, lsStatusOpened,
    lsCalcPrompt, lsCalcBtn, lsCalcHint,
    lsProjectAndExamples, lsExampleProjects, lsSourceEditor, lsOutput,
    lsPrefsTitle, lsPrefsAppearance, lsPrefsLanguage, lsPrefsTheme,
    lsPrefsLangNote,
    lsPrefsThemeDark, lsPrefsThemeLight, lsPrefsThemeSys, lsPrefsThemeNote,
    lsPrefsBtnOK, lsPrefsBtnCancel,
    lsDlgOpenFilter, lsDlgSaveFilter, lsDlgConfirmDelete, lsDlgUnsaved,
    lsMacroTrusted, lsMacroRun, lsMacroNew,
    lsFormNew, lsFormPalette, lsFormInspector, lsFormPreview,
    lsLearnTitle, lsLearnNext, lsLearnPrev, lsLearnCheck, lsLearnHint,
    lsAboutTitle,
    // Ferramenta de pack / Pack tool
    lsLangPackEditor, lsLangPackNew, lsLangPackSave, lsLangPackTest,
    lsLangPackName, lsLangPackCode, lsLangPackAuthor, lsLangPackVersion,
    lsLangPackInstalled, lsLangPackRestart
  );

  // Um pacote de idioma carregado / A loaded language pack
  TLangPack = class
  public
    Code     : string;   // 'pt', 'ja', 'zh', etc.
    Name     : string;   // display name in its own language
    Author   : string;
    Version  : string;
    IsBuiltIn: Boolean;
    Strings  : array[TLangString] of string;
  end;

  TLanguageManager = class
  private
    FPacks      : TObjectList<TLangPack>;  // todos os packs / all packs
    FActive     : TLangPack;              // pack ativo / active pack
    FIniPath    : string;                 // pythia.ini
    FPacksDir   : string;                 // <exedir>\LangPacks\
    procedure LoadBuiltIns;
    procedure LoadExternalPacks;
    procedure LoadPackFromIni(const Path: string);
    procedure LoadPreference;
    procedure SavePreference;
    function  FindPack(const Code: string): TLangPack;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   SetLanguage(const Code: string);
    function    S(ID: TLangString): string;
    function    ActiveCode: string;
    function    ActiveName: string;
    function    PacksDir: string;
    function    AllPacks: TObjectList<TLangPack>;
    // Retorna os nomes das chaves para o editor / Returns key names for editor
    class function KeyName(ID: TLangString): string;
    class function AllKeyNames: TArray<string>;
  end;

var
  Lang : TLanguageManager;

procedure InitLanguage;

// String keys for external pack INI files
// (must match order of TLangString enum)
const
  LANG_KEYS : array[TLangString] of string = (
    'TabCompiler', 'TabCalculator', 'TabLearn', 'TabProjects',
    'TabForms', 'TabMacros',
    'BtnRun', 'BtnStop', 'BtnClear',
    'BtnNew', 'BtnOpen', 'BtnSave', 'BtnSaveAs', 'BtnDelete',
    'MenuFile', 'MenuView', 'MenuHelp',
    'MenuNewFile', 'MenuOpenFile', 'MenuSave', 'MenuSaveAs', 'MenuExit',
    'MenuPreferences', 'MenuAbout', 'MenuExamples',
    'MenuTokens', 'MenuAST', 'MenuProjectSrc',
    'StatusReady', 'StatusCleared', 'StatusRunning', 'StatusDone',
    'StatusError', 'StatusExLoaded', 'StatusSaved', 'StatusOpened',
    'CalcPrompt', 'CalcBtn', 'CalcHint',
    'ProjectAndExamples', 'ExampleProjects', 'SourceEditor', 'Output',
    'PrefsTitle', 'PrefsAppearance', 'PrefsLanguage', 'PrefsTheme',
    'PrefsLangNote',
    'PrefsThemeDark', 'PrefsThemeLight', 'PrefsThemeSys', 'PrefsThemeNote',
    'PrefsBtnOK', 'PrefsBtnCancel',
    'DlgOpenFilter', 'DlgSaveFilter', 'DlgConfirmDelete', 'DlgUnsaved',
    'MacroTrusted', 'MacroRun', 'MacroNew',
    'FormNew', 'FormPalette', 'FormInspector', 'FormPreview',
    'LearnTitle', 'LearnNext', 'LearnPrev', 'LearnCheck', 'LearnHint',
    'AboutTitle',
    'LangPackEditor', 'LangPackNew', 'LangPackSave', 'LangPackTest',
    'LangPackName', 'LangPackCode', 'LangPackAuthor', 'LangPackVersion',
    'LangPackInstalled', 'LangPackRestart'
  );

// =============================================================================
implementation
// =============================================================================

// ---------------------------------------------------------------------------
//  Dados embutidos / Built-in string data
//  Cada array tem exatamente um elemento por TLangString
// ---------------------------------------------------------------------------

type TStrTable = array[TLangString] of string;

const EN : TStrTable = (
  'Compiler','Calculator','Learn Delphi','Projects','Forms','Macros',
  'Run','Stop','Clear',
  'New','Open','Save','Save As...','Delete',
  'File','View','Help',
  'New File','Open File...','Save','Save As...','Exit',
  'Preferences...','About Pythia...','Examples',
  'Show Tokens','Show AST','View Project Source',
  'Ready.','Cleared.','Running...','Done.','Runtime error.',
  'Example loaded -- click Run to execute.','Saved.','Opened.',
  'Expression:','Calculate',
  'Type an expression and press Enter or Calculate',
  'Project and Examples','Example Projects','Source Editor','Output',
  'Preferences','Appearance','Language','Theme',
  'Restart Pythia to apply language changes.',
  'Dark  (Carbon)','Light  (Iceberg Classico)','Follow Windows setting',
  'Click an option to preview. OK commits, Cancel reverts.',
  'OK','Cancel',
  'Pythia Source|*.mdp|All Files|*.*',
  'Pythia Source|*.mdp|All Files|*.*',
  'Delete this file?','Unsaved changes. Save now?',
  'Trusted','Run Macro','New Macro',
  'New Form','Palette','Object Inspector','Preview',
  'Learn Delphi','Next','Previous','Check Answer','Hint',
  'About Pythia',
  'Language Pack Editor','New Pack','Save Pack','Test Pack',
  'Language Name','Language Code','Author','Version',
  'Pack installed successfully.','Restart to apply.'
);

const PT : TStrTable = (
  'Compilador','Calculadora','Aprender Delphi','Projetos','Formulários','Macros',
  'Executar','Parar','Limpar',
  'Novo','Abrir','Salvar','Salvar Como...','Excluir',
  'Arquivo','Exibir','Ajuda',
  'Novo Arquivo','Abrir Arquivo...','Salvar','Salvar Como...','Sair',
  'Preferências...','Sobre o Pythia...','Exemplos',
  'Mostrar Tokens','Mostrar AST','Ver Código do Projeto',
  'Pronto.','Limpo.','Executando...','Concluído.','Erro de execução.',
  'Exemplo carregado -- clique em Executar.','Salvo.','Aberto.',
  'Expressão:','Calcular',
  'Digite uma expressão e pressione Enter ou Calcular',
  'Projeto e Exemplos','Projetos de Exemplo','Editor de Código','Saída',
  'Preferências','Aparência','Idioma','Tema',
  'Reinicie o Pythia para aplicar as alterações de idioma.',
  'Escuro  (Carbon)','Claro  (Iceberg Classico)','Seguir configuração do Windows',
  'Clique para pré-visualizar. OK confirma, Cancelar reverte.',
  'OK','Cancelar',
  'Código Pythia|*.mdp|Todos os Arquivos|*.*',
  'Código Pythia|*.mdp|Todos os Arquivos|*.*',
  'Excluir este arquivo?','Alterações não salvas. Salvar agora?',
  'Confiável','Executar Macro','Nova Macro',
  'Novo Formulário','Paleta','Inspetor de Objetos','Pré-visualizar',
  'Aprender Delphi','Próximo','Anterior','Verificar Resposta','Dica',
  'Sobre o Pythia',
  'Editor de Pacotes de Idioma','Novo Pacote','Salvar Pacote','Testar Pacote',
  'Nome do Idioma','Código do Idioma','Autor','Versão',
  'Pacote instalado com sucesso.','Reinicie para aplicar.'
);

const FR : TStrTable = (
  'Compilateur','Calculatrice','Apprendre Delphi','Projets','Formulaires','Macros',
  'Exécuter','Arrêter','Effacer',
  'Nouveau','Ouvrir','Enregistrer','Enregistrer sous...','Supprimer',
  'Fichier','Affichage','Aide',
  'Nouveau fichier','Ouvrir un fichier...','Enregistrer','Enregistrer sous...','Quitter',
  'Préférences...','À propos de Pythia...','Exemples',
  'Afficher les tokens','Afficher l''AST','Voir le source du projet',
  'Prêt.','Effacé.','Exécution...','Terminé.','Erreur d''exécution.',
  'Exemple chargé -- cliquez sur Exécuter.','Enregistré.','Ouvert.',
  'Expression :','Calculer',
  'Saisissez une expression et appuyez sur Entrée ou Calculer',
  'Projet et exemples','Exemples de projets','Éditeur de code','Sortie',
  'Préférences','Apparence','Langue','Thème',
  'Redémarrez Pythia pour appliquer les changements de langue.',
  'Sombre  (Carbon)','Clair  (Iceberg Classico)','Suivre les paramètres Windows',
  'Cliquez pour prévisualiser. OK valide, Annuler rétablit.',
  'OK','Annuler',
  'Source Pythia|*.mdp|Tous les fichiers|*.*',
  'Source Pythia|*.mdp|Tous les fichiers|*.*',
  'Supprimer ce fichier ?','Modifications non enregistrées. Enregistrer ?',
  'Approuvé','Exécuter la macro','Nouvelle macro',
  'Nouveau formulaire','Palette','Inspecteur d''objets','Aperçu',
  'Apprendre Delphi','Suivant','Précédent','Vérifier la réponse','Indice',
  'À propos de Pythia',
  'Éditeur de packs de langue','Nouveau pack','Enregistrer le pack','Tester le pack',
  'Nom de la langue','Code de la langue','Auteur','Version',
  'Pack installé avec succès.','Redémarrez pour appliquer.'
);

const ES : TStrTable = (
  'Compilador','Calculadora','Aprender Delphi','Proyectos','Formularios','Macros',
  'Ejecutar','Detener','Limpiar',
  'Nuevo','Abrir','Guardar','Guardar como...','Eliminar',
  'Archivo','Ver','Ayuda',
  'Nuevo archivo','Abrir archivo...','Guardar','Guardar como...','Salir',
  'Preferencias...','Acerca de Pythia...','Ejemplos',
  'Mostrar tokens','Mostrar AST','Ver fuente del proyecto',
  'Listo.','Limpiado.','Ejecutando...','Completado.','Error de ejecución.',
  'Ejemplo cargado -- haga clic en Ejecutar.','Guardado.','Abierto.',
  'Expresión:','Calcular',
  'Escriba una expresión y presione Enter o Calcular',
  'Proyecto y ejemplos','Proyectos de ejemplo','Editor de código','Salida',
  'Preferencias','Apariencia','Idioma','Tema',
  'Reinicie Pythia para aplicar los cambios de idioma.',
  'Oscuro  (Carbon)','Claro  (Iceberg Classico)','Seguir configuración de Windows',
  'Haga clic para previsualizar. OK confirma, Cancelar revierte.',
  'OK','Cancelar',
  'Fuente Pythia|*.mdp|Todos los archivos|*.*',
  'Fuente Pythia|*.mdp|Todos los archivos|*.*',
  '¿Eliminar este archivo?','¿Cambios no guardados. ¿Guardar ahora?',
  'De confianza','Ejecutar macro','Nueva macro',
  'Nuevo formulario','Paleta','Inspector de objetos','Vista previa',
  'Aprender Delphi','Siguiente','Anterior','Verificar respuesta','Pista',
  'Acerca de Pythia',
  'Editor de paquetes de idioma','Nuevo paquete','Guardar paquete','Probar paquete',
  'Nombre del idioma','Código del idioma','Autor','Versión',
  'Paquete instalado correctamente.','Reinicie para aplicar.'
);

const UK : TStrTable = (
  'Компілятор','Калькулятор','Вивчити Delphi','Проєкти','Форми','Макроси',
  'Запустити','Зупинити','Очистити',
  'Новий','Відкрити','Зберегти','Зберегти як...','Видалити',
  'Файл','Вигляд','Довідка',
  'Новий файл','Відкрити файл...','Зберегти','Зберегти як...','Вийти',
  'Параметри...','Про Pythia...','Приклади',
  'Показати токени','Показати AST','Переглянути код проєкту',
  'Готово.','Очищено.','Виконання...','Завершено.','Помилка виконання.',
  'Приклад завантажено -- натисніть Запустити.','Збережено.','Відкрито.',
  'Вираз:','Обчислити',
  'Введіть вираз і натисніть Enter або Обчислити',
  'Проєкт і приклади','Приклади проєктів','Редактор коду','Вивід',
  'Параметри','Зовнішній вигляд','Мова','Тема',
  'Перезапустіть Pythia для застосування змін мови.',
  'Темна  (Carbon)','Світла  (Iceberg Classico)','Слідувати налаштуванням Windows',
  'Натисніть для попереднього перегляду. OK підтверджує, Скасувати скасовує.',
  'OK','Скасувати',
  'Джерело Pythia|*.mdp|Усі файли|*.*',
  'Джерело Pythia|*.mdp|Усі файли|*.*',
  'Видалити цей файл?','Незбережені зміни. Зберегти зараз?',
  'Довірений','Запустити макрос','Новий макрос',
  'Нова форма','Палітра','Інспектор об''єктів','Попередній перегляд',
  'Вивчити Delphi','Наступний','Попередній','Перевірити відповідь','Підказка',
  'Про Pythia',
  'Редактор мовних пакетів','Новий пакет','Зберегти пакет','Тестувати пакет',
  'Назва мови','Код мови','Автор','Версія',
  'Пакет встановлено успішно.','Перезапустіть для застосування.'
);

const DE : TStrTable = (
  'Compiler','Rechner','Delphi lernen','Projekte','Formulare','Makros',
  'Ausführen','Stoppen','Löschen',
  'Neu','Öffnen','Speichern','Speichern unter...','Entfernen',
  'Datei','Ansicht','Hilfe',
  'Neue Datei','Datei öffnen...','Speichern','Speichern unter...','Beenden',
  'Einstellungen...','Über Pythia...','Beispiele',
  'Token anzeigen','AST anzeigen','Projektquelle anzeigen',
  'Bereit.','Gelöscht.','Wird ausgeführt...','Fertig.','Laufzeitfehler.',
  'Beispiel geladen -- klicken Sie auf Ausführen.','Gespeichert.','Geöffnet.',
  'Ausdruck:','Berechnen',
  'Geben Sie einen Ausdruck ein und drücken Sie Enter oder Berechnen',
  'Projekt und Beispiele','Beispielprojekte','Quellcode-Editor','Ausgabe',
  'Einstellungen','Erscheinungsbild','Sprache','Design',
  'Starten Sie Pythia neu, um die Sprachänderungen anzuwenden.',
  'Dunkel  (Carbon)','Hell  (Iceberg Classico)','Windows-Einstellung folgen',
  'Klicken zum Vorschau. OK bestätigt, Abbrechen verwirft.',
  'OK','Abbrechen',
  'Pythia-Quelle|*.mdp|Alle Dateien|*.*',
  'Pythia-Quelle|*.mdp|Alle Dateien|*.*',
  'Diese Datei löschen?','Ungespeicherte Änderungen. Jetzt speichern?',
  'Vertrauenswürdig','Makro ausführen','Neues Makro',
  'Neues Formular','Palette','Objekt-Inspektor','Vorschau',
  'Delphi lernen','Weiter','Zurück','Antwort prüfen','Hinweis',
  'Über Pythia',
  'Sprachpaket-Editor','Neues Paket','Paket speichern','Paket testen',
  'Sprachname','Sprachcode','Autor','Version',
  'Paket erfolgreich installiert.','Neustart zum Anwenden.'
);

const IT : TStrTable = (
  'Compilatore','Calcolatrice','Impara Delphi','Progetti','Moduli','Macro',
  'Esegui','Ferma','Cancella',
  'Nuovo','Apri','Salva','Salva come...','Elimina',
  'File','Visualizza','Aiuto',
  'Nuovo file','Apri file...','Salva','Salva come...','Esci',
  'Preferenze...','Informazioni su Pythia...','Esempi',
  'Mostra token','Mostra AST','Visualizza sorgente progetto',
  'Pronto.','Cancellato.','In esecuzione...','Completato.','Errore di esecuzione.',
  'Esempio caricato -- clicca Esegui.','Salvato.','Aperto.',
  'Espressione:','Calcola',
  'Digita un''espressione e premi Invio o Calcola',
  'Progetto ed esempi','Progetti di esempio','Editor del codice','Output',
  'Preferenze','Aspetto','Lingua','Tema',
  'Riavvia Pythia per applicare le modifiche alla lingua.',
  'Scuro  (Carbon)','Chiaro  (Iceberg Classico)','Segui impostazioni Windows',
  'Clicca per anteprima. OK conferma, Annulla ripristina.',
  'OK','Annulla',
  'Sorgente Pythia|*.mdp|Tutti i file|*.*',
  'Sorgente Pythia|*.mdp|Tutti i file|*.*',
  'Eliminare questo file?','Modifiche non salvate. Salvare ora?',
  'Attendibile','Esegui macro','Nuova macro',
  'Nuovo modulo','Tavolozza','Ispettore oggetti','Anteprima',
  'Impara Delphi','Avanti','Indietro','Verifica risposta','Suggerimento',
  'Informazioni su Pythia',
  'Editor pacchetti lingua','Nuovo pacchetto','Salva pacchetto','Testa pacchetto',
  'Nome lingua','Codice lingua','Autore','Versione',
  'Pacchetto installato con successo.','Riavvia per applicare.'
);

const JA : TStrTable = (
  'コンパイラ','電卓','Delphiを学ぶ','プロジェクト','フォーム','マクロ',
  '実行','停止','クリア',
  '新規','開く','保存','名前を付けて保存...','削除',
  'ファイル','表示','ヘルプ',
  '新しいファイル','ファイルを開く...','保存','名前を付けて保存...','終了',
  '設定...','Pythiaについて...','例',
  'トークンを表示','ASTを表示','プロジェクトソースを表示',
  '準備完了.','クリアしました.','実行中...','完了.','実行エラー.',
  '例を読み込みました -- 実行をクリック.','保存しました.','開きました.',
  '式:','計算',
  '式を入力してEnterまたは計算を押してください',
  'プロジェクトと例','サンプルプロジェクト','ソースエディタ','出力',
  '設定','外観','言語','テーマ',
  '言語の変更を適用するにはPythiaを再起動してください.',
  'ダーク  (Carbon)','ライト  (Iceberg Classico)','Windowsの設定に従う',
  'クリックでプレビュー. OKで確定, キャンセルで戻す.',
  'OK','キャンセル',
  'Pythiaソース|*.mdp|すべてのファイル|*.*',
  'Pythiaソース|*.mdp|すべてのファイル|*.*',
  'このファイルを削除しますか?','未保存の変更があります. 保存しますか?',
  '信頼済み','マクロを実行','新しいマクロ',
  '新しいフォーム','パレット','オブジェクトインスペクタ','プレビュー',
  'Delphiを学ぶ','次へ','前へ','回答を確認','ヒント',
  'Pythiaについて',
  '言語パックエディタ','新しいパック','パックを保存','パックをテスト',
  '言語名','言語コード','著者','バージョン',
  'パックが正常にインストールされました.','適用するには再起動してください.'
);

const ZH : TStrTable = (
  '编译器','计算器','学习 Delphi','项目','窗体','宏',
  '运行','停止','清除',
  '新建','打开','保存','另存为...','删除',
  '文件','视图','帮助',
  '新建文件','打开文件...','保存','另存为...','退出',
  '首选项...','关于 Pythia...','示例',
  '显示标记','显示 AST','查看项目源码',
  '就绪.','已清除.','运行中...','完成.','运行时错误.',
  '示例已加载 -- 点击运行.','已保存.','已打开.',
  '表达式:','计算',
  '输入表达式并按 Enter 或点击计算',
  '项目和示例','示例项目','源代码编辑器','输出',
  '首选项','外观','语言','主题',
  '重启 Pythia 以应用语言更改.',
  '深色  (Carbon)','浅色  (Iceberg Classico)','跟随 Windows 设置',
  '点击预览. 确定提交, 取消还原.',
  '确定','取消',
  'Pythia 源文件|*.mdp|所有文件|*.*',
  'Pythia 源文件|*.mdp|所有文件|*.*',
  '删除此文件?','有未保存的更改. 立即保存?',
  '受信任','运行宏','新建宏',
  '新建窗体','调色板','对象检查器','预览',
  '学习 Delphi','下一个','上一个','检查答案','提示',
  '关于 Pythia',
  '语言包编辑器','新建包','保存包','测试包',
  '语言名称','语言代码','作者','版本',
  '包安装成功.','重启以应用.'
);

const KO : TStrTable = (
  '컴파일러','계산기','Delphi 배우기','프로젝트','폼','매크로',
  '실행','중지','지우기',
  '새로 만들기','열기','저장','다른 이름으로 저장...','삭제',
  '파일','보기','도움말',
  '새 파일','파일 열기...','저장','다른 이름으로 저장...','종료',
  '환경설정...','Pythia 정보...','예제',
  '토큰 표시','AST 표시','프로젝트 소스 보기',
  '준비.','지워졌습니다.','실행 중...','완료.','런타임 오류.',
  '예제 로드됨 -- 실행을 클릭하세요.','저장됨.','열렸습니다.',
  '식:','계산',
  '식을 입력하고 Enter 또는 계산을 누르세요',
  '프로젝트 및 예제','예제 프로젝트','소스 편집기','출력',
  '환경설정','모양','언어','테마',
  '언어 변경을 적용하려면 Pythia를 다시 시작하세요.',
  '어둡게  (Carbon)','밝게  (Iceberg Classico)','Windows 설정 따르기',
  '클릭하여 미리보기. 확인은 적용, 취소는 되돌리기.',
  '확인','취소',
  'Pythia 소스|*.mdp|모든 파일|*.*',
  'Pythia 소스|*.mdp|모든 파일|*.*',
  '이 파일을 삭제하시겠습니까?','저장되지 않은 변경사항. 지금 저장하시겠습니까?',
  '신뢰됨','매크로 실행','새 매크로',
  '새 폼','팔레트','오브젝트 인스펙터','미리보기',
  'Delphi 배우기','다음','이전','답 확인','힌트',
  'Pythia 정보',
  '언어 팩 편집기','새 팩','팩 저장','팩 테스트',
  '언어 이름','언어 코드','작성자','버전',
  '팩이 성공적으로 설치되었습니다.','적용하려면 다시 시작하세요.'
);

const HI : TStrTable = (
  'कंपाइलर','कैलकुलेटर','Delphi सीखें','प्रोजेक्ट','फॉर्म','मैक्रो',
  'चलाएं','रोकें','साफ़ करें',
  'नया','खोलें','सहेजें','इस नाम से सहेजें...','हटाएं',
  'फ़ाइल','देखें','सहायता',
  'नई फ़ाइल','फ़ाइल खोलें...','सहेजें','इस नाम से सहेजें...','बाहर निकलें',
  'प्राथमिकताएं...','Pythia के बारे में...','उदाहरण',
  'टोकन दिखाएं','AST दिखाएं','प्रोजेक्ट स्रोत देखें',
  'तैयार.','साफ़ किया.','चल रहा है...','पूर्ण.','रनटाइम त्रुटि.',
  'उदाहरण लोड हुआ -- चलाएं पर क्लिक करें.','सहेजा गया.','खोला गया.',
  'अभिव्यक्ति:','गणना करें',
  'अभिव्यक्ति दर्ज करें और Enter दबाएं या गणना करें',
  'प्रोजेक्ट और उदाहरण','उदाहरण प्रोजेक्ट','स्रोत संपादक','आउटपुट',
  'प्राथमिकताएं','रूप','भाषा','थीम',
  'भाषा परिवर्तन लागू करने के लिए Pythia पुनः आरंभ करें.',
  'गहरा  (Carbon)','हल्का  (Iceberg Classico)','Windows सेटिंग का अनुसरण करें',
  'पूर्वावलोकन के लिए क्लिक करें. OK लागू करता है, रद्द करें वापस करता है.',
  'ठीक है','रद्द करें',
  'Pythia स्रोत|*.mdp|सभी फ़ाइलें|*.*',
  'Pythia स्रोत|*.mdp|सभी फ़ाइलें|*.*',
  'इस फ़ाइल को हटाएं?','सहेजे न गए परिवर्तन. अभी सहेजें?',
  'विश्वसनीय','मैक्रो चलाएं','नया मैक्रो',
  'नया फॉर्म','पैलेट','ऑब्जेक्ट इंस्पेक्टर','पूर्वावलोकन',
  'Delphi सीखें','अगला','पिछला','उत्तर जांचें','संकेत',
  'Pythia के बारे में',
  'भाषा पैक संपादक','नया पैक','पैक सहेजें','पैक परीक्षण करें',
  'भाषा का नाम','भाषा कोड','लेखक','संस्करण',
  'पैक सफलतापूर्वक स्थापित हुआ.','लागू करने के लिए पुनः आरंभ करें.'
);

const AR : TStrTable = (
  'المترجم','الحاسبة','تعلم Delphi','المشاريع','النماذج','وحدات الماكرو',
  'تشغيل','إيقاف','مسح',
  'جديد','فتح','حفظ','حفظ باسم...','حذف',
  'ملف','عرض','مساعدة',
  'ملف جديد','فتح ملف...','حفظ','حفظ باسم...','خروج',
  'التفضيلات...','حول Pythia...','أمثلة',
  'إظهار الرموز','إظهار AST','عرض مصدر المشروع',
  'جاهز.','تم المسح.','جارٍ التشغيل...','اكتمل.','خطأ في وقت التشغيل.',
  'تم تحميل المثال -- انقر تشغيل.','تم الحفظ.','تم الفتح.',
  'تعبير:','احسب',
  'أدخل تعبيراً واضغط Enter أو احسب',
  'المشروع والأمثلة','مشاريع الأمثلة','محرر المصدر','المخرجات',
  'التفضيلات','المظهر','اللغة','السمة',
  'أعد تشغيل Pythia لتطبيق تغييرات اللغة.',
  'داكن  (Carbon)','فاتح  (Iceberg Classico)','اتباع إعدادات Windows',
  'انقر للمعاينة. موافق للتطبيق, إلغاء للرجوع.',
  'موافق','إلغاء',
  'مصدر Pythia|*.mdp|جميع الملفات|*.*',
  'مصدر Pythia|*.mdp|جميع الملفات|*.*',
  'حذف هذا الملف?','تغييرات غير محفوظة. حفظ الآن?',
  'موثوق','تشغيل الماكرو','ماكرو جديد',
  'نموذج جديد','لوحة الألوان','مفتش الكائنات','معاينة',
  'تعلم Delphi','التالي','السابق','تحقق من الإجابة','تلميح',
  'حول Pythia',
  'محرر حزم اللغة','حزمة جديدة','حفظ الحزمة','اختبار الحزمة',
  'اسم اللغة','رمز اللغة','المؤلف','الإصدار',
  'تم تثبيت الحزمة بنجاح.','أعد التشغيل للتطبيق.'
);

const ES_LATAM : TStrTable = (
  'Compilador','Calculadora','Aprender Delphi','Proyectos','Formularios','Macros',
  'Ejecutar','Detener','Limpiar',
  'Nuevo','Abrir','Guardar','Guardar como...','Eliminar',
  'Archivo','Ver','Ayuda',
  'Nuevo archivo','Abrir archivo...','Guardar','Guardar como...','Salir',
  'Preferencias...','Acerca de Pythia...','Ejemplos',
  'Mostrar tokens','Mostrar AST','Ver fuente del proyecto',
  'Listo.','Limpiado.','Ejecutando...','Completado.','Error de ejecución.',
  'Ejemplo cargado -- haga clic en Ejecutar.','Guardado.','Abierto.',
  'Expresión:','Calcular',
  'Escriba una expresión y presione Enter o Calcular',
  'Proyecto y ejemplos','Proyectos de ejemplo','Editor de código','Salida',
  'Preferencias','Apariencia','Idioma','Tema',
  'Reinicie Pythia para aplicar los cambios de idioma.',
  'Oscuro  (Carbon)','Claro  (Iceberg Classico)','Seguir configuración de Windows',
  'Haga clic para obtener una vista previa. OK confirma, Cancelar revierte.',
  'OK','Cancelar',
  'Fuente Pythia|*.mdp|Todos los archivos|*.*',
  'Fuente Pythia|*.mdp|Todos los archivos|*.*',
  '¿Eliminar este archivo?','Cambios sin guardar. ¿Guardar ahora?',
  'De confianza','Ejecutar macro','Nueva macro',
  'Nuevo formulario','Paleta','Inspector de objetos','Vista previa',
  'Aprender Delphi','Siguiente','Anterior','Verificar respuesta','Pista',
  'Acerca de Pythia',
  'Editor de paquetes de idioma','Nuevo paquete','Guardar paquete','Probar paquete',
  'Nombre del idioma','Código del idioma','Autor','Versión',
  'Paquete instalado correctamente.','Reinicie para aplicar.'
);

// ---------------------------------------------------------------------------
//  Metadados dos idiomas embutidos / Built-in language metadata
// ---------------------------------------------------------------------------
type
  TBuiltInMeta = record
    Code, Name: string;
    Table: ^TStrTable;
  end;

// ===========================================================================
//  TLangPack
// ===========================================================================

{ TLanguageManager }

procedure TLanguageManager.LoadBuiltIns;

  procedure Add(const Code, Name: string; const Table: TStrTable);
  var P : TLangPack; ID : TLangString;
  begin
    P           := TLangPack.Create;
    P.Code      := Code;
    P.Name      := Name;
    P.Author    := 'Nomidor Software';
    P.Version   := '1.0';
    P.IsBuiltIn := True;
    for ID := Low(TLangString) to High(TLangString) do
      P.Strings[ID] := Table[ID];
    FPacks.Add(P);
  end;

begin
  Add('en',     'English',          EN);
  Add('pt',     'Português',        PT);
  Add('fr',     'Français',         FR);
  Add('es',     'Español',          ES);
  Add('es-419', 'Español (Latinoamérica)', ES_LATAM);
  Add('uk',     'Українська',       UK);
  Add('de',     'Deutsch',          DE);
  Add('it',     'Italiano',         IT);
  Add('ja',     '日本語',           JA);
  Add('zh',     '简体中文',         ZH);
  Add('ko',     '한국어',           KO);
  Add('hi',     'हिन्दी',           HI);
  Add('ar',     'العربية',          AR);
end;

// ---------------------------------------------------------------------------
//  Carrega pacotes externos de LangPacks\ / Load external packs
// ---------------------------------------------------------------------------
procedure TLanguageManager.LoadExternalPacks;
var
  Files : TArray<string>;
  F     : string;
begin
  if not TDirectory.Exists(FPacksDir) then
  begin
    TDirectory.CreateDirectory(FPacksDir);
    Exit;
  end;
  Files := TDirectory.GetFiles(FPacksDir, '*.ini');
  for F in Files do LoadPackFromIni(F);
end;

procedure TLanguageManager.LoadPackFromIni(const Path: string);
var
  Ini  : TIniFile;
  P    : TLangPack;
  Code : string;
  ID   : TLangString;
  EN_P : TLangPack;
begin
  Ini := TIniFile.Create(Path);
  try
    Code := Ini.ReadString('Meta', 'Code', '');
    if Code = '' then Exit;

    // Se já temos este código, pula / If we already have this code, skip
    if Assigned(FindPack(Code)) then Exit;

    P           := TLangPack.Create;
    P.Code      := Code;
    P.Name      := Ini.ReadString('Meta', 'Name',    Code);
    P.Author    := Ini.ReadString('Meta', 'Author',  'Community');
    P.Version   := Ini.ReadString('Meta', 'Version', '1.0');
    P.IsBuiltIn := False;

    // Começa com inglês como fallback / Start with English as fallback
    EN_P := FindPack('en');
    if Assigned(EN_P) then
      for ID := Low(TLangString) to High(TLangString) do
        P.Strings[ID] := EN_P.Strings[ID];

    // Sobrescreve com strings do arquivo / Override with strings from file
    for ID := Low(TLangString) to High(TLangString) do
    begin
      var Val := Ini.ReadString('Strings', LANG_KEYS[ID], '');
      if Val <> '' then P.Strings[ID] := Val;
    end;

    FPacks.Add(P);
  finally
    Ini.Free;
  end;
end;

function TLanguageManager.FindPack(const Code: string): TLangPack;
var P : TLangPack;
begin
  Result := nil;
  for P in FPacks do
    if SameText(P.Code, Code) then begin Result := P; Exit; end;
end;

procedure TLanguageManager.LoadPreference;
var
  Ini  : TIniFile;
  Code : string;
  P    : TLangPack;
begin
  if not FileExists(FIniPath) then Exit;
  Ini := TIniFile.Create(FIniPath);
  try
    Code := Ini.ReadString('Language', 'Code', 'en');
    P    := FindPack(Code);
    if Assigned(P) then FActive := P;
  finally
    Ini.Free;
  end;
end;

procedure TLanguageManager.SavePreference;
var Ini : TIniFile;
begin
  Ini := TIniFile.Create(FIniPath);
  try
    Ini.WriteString('Language', 'Code', FActive.Code);
  finally
    Ini.Free;
  end;
end;

constructor TLanguageManager.Create;
begin
  inherited Create;
  FPacks    := TObjectList<TLangPack>.Create(True);
  FIniPath  := ExtractFilePath(ParamStr(0)) + 'pythia.ini';
  FPacksDir := ExtractFilePath(ParamStr(0)) + 'LangPacks\';
  LoadBuiltIns;
  LoadExternalPacks;
  FActive := FindPack('en');  // fallback
  LoadPreference;
end;

destructor TLanguageManager.Destroy;
begin
  FPacks.Free;
  inherited;
end;

procedure TLanguageManager.SetLanguage(const Code: string);
var P : TLangPack;
begin
  P := FindPack(Code);
  if Assigned(P) then
  begin
    FActive := P;
    SavePreference;
  end;
end;

function TLanguageManager.S(ID: TLangString): string;
begin
  if Assigned(FActive) then Result := FActive.Strings[ID]
  else                       Result := EN[ID];  // fallback de segurança
end;

function TLanguageManager.ActiveCode: string;
begin
  if Assigned(FActive) then Result := FActive.Code else Result := 'en';
end;

function TLanguageManager.ActiveName: string;
begin
  if Assigned(FActive) then Result := FActive.Name else Result := 'English';
end;

function TLanguageManager.PacksDir: string;
begin
  Result := FPacksDir;
end;

function TLanguageManager.AllPacks: TObjectList<TLangPack>;
begin
  Result := FPacks;
end;

class function TLanguageManager.KeyName(ID: TLangString): string;
begin
  Result := LANG_KEYS[ID];
end;

class function TLanguageManager.AllKeyNames: TArray<string>;
var ID : TLangString; I : Integer;
begin
  SetLength(Result, Ord(High(TLangString)) + 1);
  I := 0;
  for ID := Low(TLangString) to High(TLangString) do
  begin
    Result[I] := LANG_KEYS[ID];
    Inc(I);
  end;
end;

procedure InitLanguage;
begin
  if not Assigned(Lang) then Lang := TLanguageManager.Create;
end;

initialization
  Lang := nil;

finalization
  Lang.Free;
  Lang := nil;

end.
