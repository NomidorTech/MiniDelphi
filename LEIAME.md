# Pythia

**Onde o Pascal começa.**

Pythia é um ambiente de aprendizado de Pascal para Windows. Combina um Pascal interpretado de verdade — com classes, recursão, entrada/saída de arquivos, gráficos e SQLite — a um IDE criado para ensinar a linguagem, em vez de escondê-la.

Desenvolvido em Delphi 13 (Athens). Win64.

<img width="1167" height="785" alt="image" src="https://github.com/user-attachments/assets/38c4d875-edc4-4456-beb7-aa91eab98630" />

---

## Por que o Pythia?

O Pascal é uma linguagem bonita com uma primeira hora difícil. Um programador que abre o IDE real do Delphi se depara com uma parede de menus, componentes, propriedades e ferramentas que nada têm a ver com aprender a linguagem em si. O Pythia é o resultado de remover tudo isso e manter apenas as partes que ajudam uma pessoa a aprender Pascal de verdade: um lugar para escrever código, um botão para executá-lo, exemplos que não pressupõem conhecimentos prévios, erros amigáveis e uma referência incorporada para cada funcionalidade.

É também uma bancada de trabalho limpa para programadores Pascal experientes que queiram experimentar sem abrir o IDE completo do Delphi.

O nome vem da Pítia — a sacerdotisa do Oráculo de Delfos. Assim como o Oráculo falava através dela, o Pascal fala através do Pythia.

---

## Funcionalidades

### Linguagem

- Sintaxe semelhante ao Pascal: `program`, `uses`, `var`, `procedure`, `function`, `begin..end`
- Tipos: `Integer`, `Real`, `String`, `Boolean`, mais objetos via `class`
- Controle de fluxo: `if..then..else`, `while..do`, `repeat..until`, `for..to..do`, `for..downto..do`
- `case..of` para inteiros com rótulos de vários valores e ramo `else`
- Extensão `caseof..of` para comparação de strings
- Classes: campos, métodos, construtores, `Self`, herança, métodos virtuais
- Recursão, recursão mútua, chamadas aninhadas
- Convenção de retorno `Result` para funções

### Rotinas incorporadas

- Saída: `writeln`, `write`
- Entrada: `readln`, `InputBox`
- Diálogos: `ShowMessage`, `Confirm`
- Matemática: `abs`, `sqr`, `sqrt`, `power`, `round`, `trunc`, `sin`, `cos`, `tan`, `ln`, `exp`, `pi`, `max`, `min`, `random`, `randomize`
- Strings: `length`, `uppercase`, `lowercase`, `copy`, `pos`, `trim`, `inttostr`, `strtoint`, `strtointdef`, `floattostr`, `strtofloat`
- Arquivos: `fileexists`, `readfile`, `writefile`, `appendfile`, `deletefile`
- Gráficos: `GfxOpen`, `GfxClose`, `GfxLine`, `GfxRect`, `GfxCircle`, `GfxText`, `GfxColor`, `GfxClear`, `GfxUpdate`
- Banco de dados: `DbOpen`, `DbClose`, `DbExec`, `DbQuery`, `DbNext`, `DbField` (requer `sqlite3.dll` ao lado do executável)
- Temporização: `Sleep`

### IDE

- **Aba Compilador** — editor de código à esquerda, saída à direita, fluxo de tokens na parte inferior. Clique com o botão direito para snippets de código, F5 para executar.
- **Aba Calculadora** — digite qualquer expressão e pressione Enter. `2 + 3 * sqrt(16)` funciona como esperado.
- **Aba Aprender Delphi** — 13 lições sobre os fundamentos da linguagem, mais 45 desafios graduados com dicas e um certificado de conclusão.
- **Aba Projetos** — projetos com múltiplos arquivos usando um arquivo `.mdproj`, arquivos de biblioteca `.mdp` e uma seção interna `[Source]` para o programa principal.
- **Aba Formulários** — um construtor visual de formulários (Fase 1) com paleta (Ponteiro / Rótulo / Botão / Campo de texto), arrastar e soltar, inspetor de objetos e pré-visualização modal em tempo de execução.
- **Aba Macros** — pequenos scripts que rodam sobre o projeto, com um sistema de confiança para macros que usam o shell.

### Extras do IDE

- Temas: Escuro (Carbon), Claro (Iceberg Classico) ou Seguir Windows — configurado em Ver → Preferências
- Três menus: Arquivo, Ver, Ajuda. Ajuda → Exemplos carrega qualquer um dos programas incorporados na aba Compilador.
- Clique com o botão direito em qualquer editor de código para um menu de snippets (`if..then`, `for`, `while`, esqueleto de classe, etc.)

---

## Compilação rápida

### Pré-requisitos

- **Embarcadero Delphi 13 (Athens)** com suporte a VCL Styles
- **Windows 10 ou 11** (o aplicativo é apenas Win64)
- Opcional: `sqlite3.dll` colocado ao lado do executável para usar os builtins `Db*`

### Compilar

1. Clone este repositório
2. Abra `Pythia.dpr` no Delphi
3. **Projeto → Opções → Aplicativo → Aparência** — marque as caixas para `Carbon`, `Iceberg Classico` e, opcionalmente, `Windows10 SlateGray` e `Glossy` como alternativas
4. **Projeto → Compilar** (Shift+F9)
5. Execute com **F9** ou inicie o `Pythia.exe` gerado

### Executar

O IDE abre na aba Compilador com um exemplo Hello World pré-carregado. Clique em **Executar** para rodá-lo. Experimente **Ajuda → Exemplos → FizzBuzz** para um primeiro programa um pouco mais interessante.

---

## Olá, Pythia

```pascal
program HelloWorld;
begin
  writeln('Hello, World!');
  writeln('Welcome to Pythia!');
end.
```

Um exemplo um pouco maior — `caseof` alternando em uma string:

```pascal
program AnimalSounds;

procedure Describe(animal: String);
begin
  write(animal, ' -> ');
  caseof animal of
    'cat'           : writeln('Meow!');
    'dog', 'hound'  : writeln('Woof!');
    'cow'           : writeln('Moo!');
  else
    writeln('Unknown!');
  end;
end;

begin
  Describe('cat');
  Describe('dog');
  Describe('unicorn');
end.
```

A recursão funciona como esperado:

```pascal
function Fact(n: Integer): Integer;
begin
  if n <= 1 then Result := 1
  else Result := n * Fact(n - 1);
end;

var i : Integer;
begin
  for i := 0 to 10 do writeln(i, '! = ', Fact(i));
end.
```

---

## Estrutura do projeto

Um projeto Pythia vive em uma pasta com um arquivo `.mdproj` e qualquer número de arquivos de biblioteca `.mdp` e arquivos de definição de formulário `.mdfrm`.

O `.mdproj` é um arquivo no formato INI com três seções:

```ini
[Project]
Name=MyApp

[Files]
0=MathLib.mdp
1=Strings.mdp

[Source]
program MyApp;
uses
  'MathLib.mdp',
  'Strings.mdp';
begin
  writeln(Add(2, 3));
end.
```

O programa principal vive em `[Source]`, exatamente como um `.dpr` real do Delphi. Os arquivos de biblioteca `.mdp` contêm apenas declarações (sem `begin..end`).

---

## Arquitetura

```
Pythia/
├── Pythia.dpr                # ponto de entrada do projeto
├── UMainForm.pas             # formulário VCL principal com as abas
├── ULexer.pas                # código-fonte → tokens
├── UParser.pas               # tokens → AST (descida recursiva)
├── UAST.pas                  # definições dos nós da AST
├── UValidator.pas            # verificações semânticas pós-análise
├── UInterpreter.pas          # interpretador por travessia de árvore
├── UObjectRuntime.pas        # suporte em tempo de execução para classes/objetos
├── UUnitLoader.pas           # cláusula uses / importação de .mdp
├── UGraphics.pas             # builtins Gfx*
├── USQLite.pas               # builtins Db* (via sqlite3.dll)
├── UProjectTab.pas           # aba Projetos
├── UFormBuilderTab.pas       # aba Formulários
├── UFormDef.pas              # modelo de definição de formulário .mdfrm
├── UMacroTab.pas             # aba Macros
├── UMacroLibrary.pas         # armazenamento de macros
├── ULearnTab.pas             # aba Aprender Delphi
├── UExampleProjects.pas      # projetos de exemplo incorporados
├── UAboutDialog.pas          # Sobre + Guia do Programador
├── UTheme.pas                # wrapper de VCL Styles
└── UPreferencesDialog.pas    # Ver → Preferências
```

---

## Licença

GPL-3.0. Consulte [LICENSE](LICENSE) para o texto completo.

Isso significa: você pode usar, modificar e distribuir o Pythia livremente, desde que os trabalhos derivados permaneçam licenciados sob GPL-3.0 e seu código-fonte seja disponibilizado.

---

## Autor

O Pythia é desenvolvido pela **Nomidor Software, LLC.**

Para bugs, sugestões ou contribuições, abra uma issue ou pull request no GitHub.
