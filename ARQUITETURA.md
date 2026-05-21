# Arquitetura

O Pythia é um ambiente de aprendizado de Pascal desenvolvido em Delphi 13 (Athens) para Win64. Este documento descreve como o código está organizado e as razões por trás das principais decisões de design.

---

## Visão geral de alto nível

```
Código-fonte
    │
    ▼
 ULexer          → TList<TToken>
    │
    ▼
 UParser         → TProgramNode  (AST)
    │
    ▼
 UValidator      → erros / avisos
    │
    ▼
 UUnitLoader     → integra rotinas .mdp importadas na AST
    │
    ▼
 UInterpreter    → executa a árvore
    │
    ├── UObjectRuntime   (heap de classes/objetos)
    ├── UGraphics        (builtins Gfx* → janela gráfica)
    └── USQLite          (builtins Db* → sqlite3.dll)
```

O IDE envolve esse pipeline em um aplicativo VCL com seis abas. Toda a execução ocorre na thread principal.

---

## Mapa de unidades

| Camada | Unidade | Responsabilidade |
|---|---|---|
| **Motor da linguagem** | `ULexer` | Código-fonte → `TList<TToken>` |
| | `UParser` | Tokens → `TProgramNode` AST |
| | `UAST` | Definições de todos os tipos de nós da AST |
| | `UValidator` | Verificações estáticas pós-análise, pré-execução |
| | `UInterpreter` | Executor por travessia de árvore |
| **Extensões em tempo de execução** | `UObjectRuntime` | Instanciação de classes, acesso a campos, despacho via vtable |
| | `UUnitLoader` | Cláusula `uses` — carrega e integra arquivos de biblioteca `.mdp` |
| | `UGraphics` | Builtins `Gfx*` e a janela gráfica |
| | `USQLite` | Builtins `Db*` via `sqlite3.dll` carregado dinamicamente |
| **Shell do IDE** | `UMainForm` | Formulário VCL principal, hospedeiro das abas, roteamento de menus |
| | `UProjectTab` | Aba Projetos — editor, árvore, Executar/Parar, operações de arquivo |
| | `ULearnTab` | Aba Aprender — currículo, verificador de desafios, progresso |
| | `UFormBuilderTab` | Aba Formulários — designer visual (Fase 1) |
| | `UFormDef` | Modelo de definição de formulário `.mdfrm` |
| | `UMacroTab` | Aba Macros |
| | `UMacroLibrary` | Armazenamento de macros e modelos iniciais |
| | `UExampleProjects` | Mais de 40 programas de exemplo incorporados (strings embutidas) |
| **Infraestrutura** | `UTheme` | Wrapper de VCL Styles (Escuro / Claro / Seguir Windows) |
| | `UPreferencesDialog` | Diálogo Ver → Preferências |
| | `UAboutDialog` | Diálogo Sobre + referência de programação incorporada |

---

## Motor da linguagem

### Analisador léxico (`ULexer`)

Tokenizador de passagem única. Lê o código-fonte caractere por caractere e emite uma `TList<TToken>` plana. Cada token registra `Kind`, `Text`, `Line` e `Col` — a posição é armazenada no token em vez de ser reconstruída depois, tornando as mensagens de erro precisas sem custo adicional.

### Analisador sintático (`UParser`)

Analisador de descida recursiva clássico. Um método por produção gramatical (`ParseProgram`, `ParseBlock`, `ParseStatement`, `ParseExpr`, …). Retorna um único `TProgramNode`; o chamador é responsável por liberá-lo.

A análise de expressões usa uma cadeia de precedência:

```
ParseOrExpr → ParseAndExpr → ParseRelExpr → ParseAddExpr
    → ParseMulExpr → ParseUnaryExpr → ParsePrimary
```

`EParseError` carrega `Line` e `Col` como campos separados, para que o IDE possa exibir a posição sem duplicá-la no texto da mensagem.

A gramática OOP é totalmente suportada: `ParseClassDecl`, `ParseInterfaceDecl`, `ParseMethodDecl`, declarações `var` inline.

### AST (`UAST`)

`TASTNode` é a base; cada nó registra `Line` e `Col`. Hierarquia de subclasses:

- **Nós de expressão** — literais (int, float, string, bool, nil), referências a variáveis, operadores binários/unários, chamadas de função, acesso a arrays/campos, conversões de tipo.
- **Nós de instrução** — atribuição, writeln/readln, todo o controle de fluxo (`if`, `while`, `repeat`, `for`, `case`, `caseof`), chamadas de procedimento, `exit`/`break`/`continue`, instruções OOP.
- **Nós de declaração** — `TVarDecl`, `TParamDecl`, `TRoutineDecl`, `TClassDecl`, `TInterfaceDecl`, `TMethodDecl`.
- **Nível de topo** — `TProgramNode` possui variáveis globais, rotinas, declarações de classes/interfaces e o bloco principal.

A propriedade segue `TObjectList<T>` com `OwnsObjects = True` em toda parte; os destrutores cascateiam corretamente.

### Validador (`UValidator`)

Roda entre a análise sintática e a execução. Verificações (não exaustivas):

1. Bloco principal `begin..end` ausente
2. Corpo do programa vazio
3. Uso de variável / rotina não declarada (builtins estão na lista de permissões)
4. Função sem atribuição a `Result` (melhor esforço)
5. `while true do` sem `break`/`exit`
6. Literais de divisão por zero
7. Número errado de argumentos em rotinas conhecidas
8. String usada em contexto aritmético

Manter a validação separada da análise sintática significa que erros sintáticos e semânticos são reportados de forma independente, sem que nenhuma das fases fique complicada pelas preocupações da outra.

### Interpretador (`UInterpreter`)

Travessia de árvore. `TInterpreter.Run`:

1. Chama `TUnitLoader` para resolver a cláusula `uses` e integrar as rotinas importadas.
2. Registra todos os procedimentos/funções incorporados.
3. Declara as variáveis globais.
4. Chama `ExecBlock` no bloco principal.

`ExecStmt` despacha por tipo de nó com uma cadeia `if … is … then` — idiomático em Delphi para um padrão visitante sem interface visitante.

A transferência de controle (`exit`, `break`, `continue`) usa exceções (`EExitSignal`, `EBreakSignal`, `EContinueSignal`) capturadas nos contextos envolventes apropriados.

Um contador de passos (`Tick`) impõe um limite máximo de execução, protegendo a interface contra loops infinitos no código dos alunos.

---

## Extensões em tempo de execução

### Runtime de objetos (`UObjectRuntime`)

Trata a instanciação de classes (`TMyClass.Create`), armazenamento de campos, busca e despacho de métodos, cadeias de herança e `Self`. A declaração de classe em tempo de compilação (AST) é separada da representação de objeto em tempo de execução aqui.

### Carregador de unidades (`UUnitLoader`)

Resolve a cláusula `uses` de um programa `.mdp`:

1. Analisa os nomes de arquivos entre aspas na cláusula `uses`.
2. Carrega cada arquivo do disco relativamente a `BaseDir`.
3. Analisa léxica e sintaticamente e extrai os nós `TRoutineDecl`.
4. Integra-os na AST do programa principal antes da execução.

Os arquivos de biblioteca `.mdp` contêm apenas declarações — sem bloco `begin..end`. Se um bloco principal estiver presente, é ignorado silenciosamente. Importações circulares são detectadas e ignoradas.

### Gráficos (`UGraphics`)

Implementa os builtins `Gfx*`. Como o interpretador roda na thread VCL principal, a pintura é síncrona: `InvalidateRect + UpdateWindow` força um `WM_PAINT` imediato antes de retornar. Não é necessária sincronização de threads.

### SQLite (`USQLite`)

Encapsula `sqlite3.dll` via carregamento dinâmico. A DLL é opcional — programas que não usam os builtins `Db*` funcionam normalmente sem ela.

---

## Shell do IDE

### Formulário principal (`UMainForm`)

Hospeda seis páginas `TTabSheet` e possui uma instância de cada módulo de aba. O menu Arquivo delega para os métodos `Do*` da aba ativa. O menu Ver fornece inspeção do fluxo de tokens e da AST na aba Compilador.

A ordem de inicialização importa: `Theme.Load` roda antes de `Application.CreateForm` para que os VCL Styles sejam aplicados antes de qualquer janela ser pintada.

### Aba Projetos (`UProjectTab`)

Os arquivos `.mdproj` estão no formato INI com três seções:

```ini
[Project]
Name=MyApp

[Files]
0=MathLib.mdp

[Source]
program MyApp;
uses 'MathLib.mdp';
begin
  writeln(Add(2, 3));
end.
```

O código-fonte do programa principal vive em `[Source]` (como um `.dpr` real do Delphi). Os caminhos de biblioteca em `[Files]` são relativos ao arquivo `.mdproj`. O botão Parar define `FInterp.FStop`, que o contador de passos verifica em cada `Tick`.

### Aba Aprender (`ULearnTab`)

Modelo do currículo: `TLearnCurriculum → TLesson → TChallenge`.

Cada `TChallenge` tem: instrução, dica, esqueleto inicial, solução de referência, estratégia de verificação (`TCheckKind`) e valor em pontos. Estratégias de verificação: correspondência exata de saída, contém todas as substrings, saída numérica, intervalo, contagem de linhas.

O verificador roda o código do aluno através do mesmo pipeline `TLexer → TParser → TInterpreter` que a aba Compilador. O progresso (IDs concluídos, pontos, nome do aluno) é salvo em disco.

### Construtor de formulários (`UFormBuilderTab`)

Designer visual de Fase 1 para arquivos `.mdfrm`. Paleta: Ponteiro, Rótulo, Botão, Campo de texto. Colocação por arrastar e soltar, inspetor de objetos, deslocamento por teclas de seta (1px), Delete para remover. A pré-visualização em tempo de execução usa `TForm.CreateNew` com controles VCL reais.

`TFormDef` (em `UFormDef`) é o modelo de dados. As propriedades são armazenadas em um `TDictionary<string, string>`. O campo `OnClick` guarda um nome de procedimento — pronto para a ligação da Fase 2 ao interpretador, ainda não invocado.

### Projetos de exemplo (`UExampleProjects`)

Todos os exemplos são embutidos como constantes de string — nenhum arquivo externo é necessário. Cada exemplo segue um modelo consistente: bloco de cabeçalho, comentários por linha, notas de ensino `// *** NOTE:`. Os exemplos com múltiplos arquivos demonstram o sistema `uses`/biblioteca em contexto.

---

## Modelo de threading

Tudo roda na thread principal. Não existe uma thread de interpretador em segundo plano. Isso simplifica o modelo gráfico (pintura síncrona), elimina a necessidade de estruturas de dados thread-safe no interpretador e evita condições de corrida entre o VCL e o estado do interpretador. A contrapartida é que um programa lento ou infinito trava a interface — mitigado pelo contador de passos e pelo botão Parar.

---

## Formatos de arquivo

| Extensão | Formato | Descrição |
|---|---|---|
| `.mdp` | Pascal em texto simples | Arquivo fonte — programa ou biblioteca |
| `.mdproj` | INI (`[Project]` `[Files]` `[Source]`) | Arquivo de projeto |
| `.mdfrm` | INI | Definição de formulário (controles + propriedades) |
| `Pythia.settings.ini` | INI | Preferências do usuário (tema escolhido) |

---

## Trabalho futuro

- **Construtor de formulários Fase 2** — ligar os nomes de manipuladores `OnClick` a chamadas do interpretador.
- **Depurador** — execução passo a passo com inspeção de variáveis em cada passo.
- **Análise estática mais robusta** — uma tabela de símbolos simples com tipos inferidos permitiria detectar mais incompatibilidades de tipos antes da execução.
- **VM de bytecode** — uma VM baseada em pilha melhoraria o desempenho em loops intensos e programas gráficos pesados sem alterar fundamentalmente a arquitetura.
- **Suite de testes do interpretador** — um conjunto de pequenos programas com saídas conhecidas, separado do verificador de desafios, para proteger contra regressões.
