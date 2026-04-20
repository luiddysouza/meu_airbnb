# Server-Driven UI (SDUI) — meu_airbnb

## O que é Server-Driven UI?

Server-Driven UI é um padrão arquitetural onde a **interface do usuário é descrita por dados** (geralmente JSON) vindos de um servidor, em vez de ser definida estaticamente no código do app. O app recebe uma descrição declarativa da tela — quais componentes exibir, em que ordem, com quais propriedades — e monta os widgets dinamicamente a partir dessa descrição.

A ideia central é simples: **o servidor diz "o quê" mostrar, o app decide "como" mostrar**. O JSON diz "aqui vai um seletor de datas, depois um dropdown, depois uma lista". O app pega cada instrução e a traduz para um widget concreto do Design System.

### Analogia

Imagine um restaurante onde o cardápio muda diariamente. Em vez de reimprimir o cardápio inteiro a cada mudança, o chef envia uma lista de pratos para o garçom, que monta o cardápio na hora. O garçom não precisa saber cozinhar — ele só precisa saber traduzir cada item da lista para a formatação do cardápio. Se amanhã o chef trocar a ordem dos pratos ou adicionar um novo, o garçom renderiza o cardápio atualizado sem que ninguém precise reimprimir nada.

No `meu_airbnb`, o "chef" é o JSON, o "garçom" é a engine SDUI, e o "cardápio" é a tela renderizada.

### Por que usar SDUI neste projeto?

No contexto do `meu_airbnb`, SDUI não é usado por necessidade de deploy remoto — os JSONs são locais. O valor está em **demonstrar a capacidade de construir uma arquitetura flexível**:

1. **Diferencial técnico para portfólio** — Poucas empresas implementam SDUI, e poucos desenvolvedores demonstram essa habilidade. Mostra maturidade arquitetural e capacidade de projetar sistemas extensíveis.
2. **Separação radical de responsabilidades** — A tela não conhece os componentes específicos. O JSON descreve a estrutura, o `WidgetFactory` traduz para widgets. Mudar a tela é mudar o JSON.
3. **Extensibilidade** — Para adicionar uma nova tela, basta criar um novo JSON e registrar novos tipos no factory. Zero código de layout precisa ser escrito.
4. **Preparação para backend real** — A arquitetura está pronta para trocar o JSON local por uma resposta de API. O `SduiCubit` só precisa mudar de `rootBundle.loadString` para `http.get`.

---

## Arquitetura da Engine SDUI

A engine é composta por 5 peças que formam um pipeline linear:

```
JSON (String)
  │
  ▼
SduiParser         →  parsear(json) → List<SduiNode>
  │
  ▼
SduiCubit          →  carregarTela() → emite SduiState
  │
  ▼
SduiRenderer       →  percorre List<SduiNode> recursivamente
  │
  ▼
WidgetFactory      →  construir(no) → Widget do Design System
  │
  ▼
Tela renderizada
```

Cada peça tem uma única responsabilidade e pode ser testada isoladamente. Nenhuma depende das MobX stores — a conexão com dados reativos acontece nos builders do `WidgetFactory`, não na engine em si.

### Localização no projeto

```
lib/core/sdui/
├── models/
│   ├── sdui_node.dart          # Nó da árvore
│   └── sdui_action.dart        # Ação associada a um nó
├── parser/
│   └── sdui_parser.dart      # JSON String → List<SduiNode>
├── renderer/
│   └── sdui_renderer.dart    # List<SduiNode> → Widget tree
├── factory/
│   └── widget_factory.dart   # Registry tipo → builder
└── cubit/
    ├── sdui_cubit.dart       # Orquestra o pipeline
    └── sdui_state.dart      # Estados: Inicial, Carregando, Sucesso, Erro
```

---

## Schema JSON: a linguagem do SDUI

### Estrutura de um nó

Todo nó SDUI segue o mesmo contrato:

```json
{
  "tipo": "nome_do_componente",
  "propriedades": { },
  "filhos": [ ],
  "acao": {
    "tipo": "nome_da_acao",
    "payload": { }
  }
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `tipo` | `String` | Sim | Identificador que mapeia para um builder no `WidgetFactory` |
| `propriedades` | `Map<String, dynamic>` | Não (default: `{}`) | Dados para configurar o widget (rótulos, valores, flags) |
| `filhos` | `List<Map>` | Não (default: `[]`) | Nós filhos, renderizados recursivamente |
| `acao` | `Map` | Não (default: `null`) | Ação disparada pela interação do usuário |

O campo `acao` tem seu próprio sub-schema:

| Campo | Tipo | Descrição |
|---|---|---|
| `tipo` | `String` | Nome da ação (ex: `filtrar_por_data`, `filtrar_por_imovel`) |
| `payload` | `Map<String, dynamic>` | Dados adicionais para a ação |

### Exemplo real: tela de hospedagens

Este é o JSON que descreve a tela principal do app (`assets/mock/tela_hospedagens.json`):

```json
{
  "tela": "hospedagens",
  "componentes": [
    {
      "tipo": "seletor_data_range",
      "propriedades": {
        "rotulo_inicio": "Check-in",
        "rotulo_fim": "Check-out"
      },
      "acao": {
        "tipo": "filtrar_por_data",
        "payload": {}
      }
    },
    {
      "tipo": "dropdown",
      "propriedades": {
        "rotulo": "Imóvel",
        "opcoes_source": "imoveis"
      },
      "acao": {
        "tipo": "filtrar_por_imovel",
        "payload": {}
      }
    },
    {
      "tipo": "lista",
      "propriedades": {
        "item_tipo": "card_hospedagem",
        "dados_source": "hospedagens_filtradas",
        "vazio_mensagem": "Nenhuma hospedagem encontrada"
      }
    }
  ]
}
```

**Leitura do JSON:**
1. Renderize um `DsDateRangePicker` com rótulos "Check-in" e "Check-out". Quando o usuário selecionar um período, dispare a ação `filtrar_por_data`.
2. Renderize um `DsDropdown` com rótulo "Imóvel". As opções vêm da fonte `imoveis`. Quando selecionar, dispare `filtrar_por_imovel`.
3. Renderize uma `DsLista` cujos itens são `card_hospedagem`. Os dados vêm de `hospedagens_filtradas`. Se não houver itens, mostre "Nenhuma hospedagem encontrada".

Note que o JSON não contém dados de negócio — apenas referências a fontes de dados (`opcoes_source`, `dados_source`). Os dados reais vêm dos MobX stores, injetados via `get_it` nos builders do `WidgetFactory`.

---

## Peça 1: Modelos — SduiNode e SduiAction

Os modelos são a representação Dart do schema JSON. São classes `Equatable` e imutáveis.

### SduiNode

```dart
class SduiNode extends Equatable {
  const SduiNode({
    required this.tipo,
    this.propriedades = const {},
    this.filhos = const [],
    this.acao,
  });

  final String tipo;
  final Map<String, dynamic> propriedades;
  final List<SduiNode> filhos;
  final SduiAction? acao;

  factory SduiNode.fromJson(Map<String, dynamic> json) { ... }
}
```

**Pontos-chave:**
- `filhos` é uma lista de `SduiNode` — isso cria a **recursividade**. Um nó pode conter nós filhos, que por sua vez podem conter mais filhos, formando uma árvore.
- `propriedades` é um `Map<String, dynamic>` porque cada tipo de widget tem propriedades diferentes. O `WidgetFactory` é quem sabe interpretar esse mapa para cada tipo.
- `Equatable` permite comparar nós por valor, essencial para o `bloc_test` comparar estados do Cubit.

### SduiAction

```dart
class SduiAction extends Equatable {
  const SduiAction({required this.tipo, this.payload = const {}});

  final String tipo;
  final Map<String, dynamic> payload;

  factory SduiAction.fromJson(Map<String, dynamic> json) { ... }
}
```

A ação é um VO (Value Object) simples. O `tipo` identifica qual handler executar, e o `payload` carrega dados extras. Na integração SDUI ↔ MobX, o `tipo` da ação será mapeado para métodos dos stores (ex: `filtrar_por_data` → `filtroStore.selecionarPeriodo()`).

---

## Peça 2: SduiParser — JSON → List\<SduiNode\>

```dart
abstract final class SduiParser {
  static List<SduiNode> parsear(String jsonString) {
    final mapa = jsonDecode(jsonString) as Map<String, dynamic>;
    final componentes = mapa['componentes'] as List<dynamic>? ?? [];
    return componentes
        .map((item) => SduiNode.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
```

**Por que `abstract final class`?** — O parser é um namespace puro com método estático. Não pode ser instanciado nem herdado. É o mesmo padrão usado nos tokens do Design System.

**Contrato:**
- Entrada: `String` JSON com chave `componentes` contendo um array de nós
- Saída: `List<SduiNode>` — a árvore parseada
- Erro: lança `FormatException` se o JSON for inválido

**O que o parser NÃO faz:**
- Não valida se os `tipo` existem no `WidgetFactory` — isso é responsabilidade do factory (retorna `SizedBox.shrink` para tipos desconhecidos)
- Não carrega o JSON do disco — isso é responsabilidade do `SduiCubit`
- Não constrói widgets — isso é responsabilidade do `SduiRenderer`

Essa separação de responsabilidades é intencional. Cada peça faz uma única coisa e pode ser testada de forma isolada.

---

## Peça 3: WidgetFactory — o registry tipo → Widget

O `WidgetFactory` é o coração da engine. Ele mantém um `Map<String, BuilderSdui>` que mapeia cada `tipo` SDUI para uma função que constrói o widget correspondente.

### Assinatura do builder

```dart
typedef BuilderSdui = Widget Function(
  BuildContext context,
  SduiNode no,
  Widget Function(BuildContext, SduiNode) renderizarFilho,
);
```

Cada builder recebe:
1. `context` — o `BuildContext` do Flutter
2. `no` — o nó SDUI sendo processado (com suas propriedades, filhos, ação)
3. `renderizarFilho` — um callback para renderizar nós filhos recursivamente

O terceiro parâmetro é o que permite composição. Um builder de "coluna" pode call `renderizarFilho` para cada filho na lista `no.filhos`, montando uma árvore de widgets sem limite de profundidade.

### API pública

```dart
class WidgetFactory {
  void registrar(String tipo, BuilderSdui builder);  // adiciona tipo
  bool temTipo(String tipo);                          // verifica registro
  Widget construir(context, no, renderizarFilho);     // constrói widget
}
```

### Tipos registrados

O `WidgetFactory.padrao()` vem pré-configurado com os 7 tipos do projeto:

| Tipo SDUI | Widget DS | Dados reativos? | Propriedades lidas do JSON |
|---|---|---|---|
| `seletor_data_range` | `DsDateRangePicker` | Não | `rotulo_inicio`, `rotulo_fim` |
| `dropdown` | `DsDropdown` | Sim | `rotulo`, `opcoes_source` |
| `lista` | `DsLista` | Sim | `item_tipo`, `dados_source`, `vazio_mensagem` |
| `card_hospedagem` | `DsCardHospedagem` | Sim | `nome_hospede`, `check_in`, `check_out`, `valor_total`, `status`, `nome_imovel` |
| `botao_primario` | `DsBotaoPrimario` | Não | `rotulo` |
| `estado_vazio` | `DsEstadoVazio` | Não | `mensagem` |
| `carregando` | `DsCarregando` | Não | `mensagem` |

### Fallback para tipos desconhecidos

Se um JSON contiver `"tipo": "componente_novo"` e esse tipo não estiver registrado, o factory retorna `SizedBox.shrink()` — um widget invisível de tamanho zero. A tela não quebra, apenas ignora o componente desconhecido. Isso é intencional: a engine deve ser resiliente a JSONs com tipos que o app ainda não suporta.

### Anatomia de um builder

```dart
static Widget _buildSeletorDataRange(
  BuildContext context,
  SduiNode no,
  Widget Function(BuildContext, SduiNode) renderizarFilho,
) {
  final props = no.propriedades;
  return DsDateRangePicker(
    rotuloInicio: props['rotulo_inicio'] as String? ?? 'Check-in',
    rotuloFim: props['rotulo_fim'] as String? ?? 'Check-out',
    aoSelecionar: (_) {},
  );
}
```

**Padrões observados:**
1. Lê de `no.propriedades` com cast + fallback (`as String? ?? 'valor_padrao'`). Nunca assume que a chave existe — protege contra JSONs incompletos.
2. Retorna um componente do Design System (prefixo `Ds`). Nunca constrói widgets Flutter brutos.
3. O callback `aoSelecionar` está vazio nesta fase. Na integração SDUI ↔ MobX, ele será conectado ao `filtroStore.selecionarPeriodo()`.

---

## Peça 4: SduiRenderer — renderização recursiva

```dart
class SduiRenderer extends StatelessWidget {
  const SduiRenderer({
    super.key,
    required this.nos,
    required this.fabrica,
  });

  final List<SduiNode> nos;
  final WidgetFactory fabrica;

  Widget _renderizarNo(BuildContext context, SduiNode no) {
    return fabrica.construir(context, no, _renderizarNo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: nos.map((no) => _renderizarNo(context, no)).toList(),
    );
  }
}
```

O renderer é propositalmente simples. Ele:
1. Recebe a lista de nós raiz (`nos`) e a fábrica de widgets (`factory`)
2. Para cada nó raiz, chama `_renderizarNo`
3. `_renderizarNo` delega para `fabrica.construir`, passando **a si mesmo** como callback de renderização recursiva

O ponto-chave é a recursividade via callback. Quando um builder precisa renderizar filhos (ex: um builder de "coluna"), ele chama `renderizarFilho(context, filhoNo)`, que por sua vez chama `fabrica.construir` novamente. Isso forma uma árvore de chamadas que espelha a árvore de nós do JSON.

```
SduiRenderer.build
  └── _renderizarNo(nó_coluna)
        └── fabrica.construir(nó_coluna)
              └── builder de coluna chama renderizarFilho para cada filho
                    └── _renderizarNo(nó_botao)
                          └── fabrica.construir(nó_botao)
                                └── retorna DsBotaoPrimario
```

---

## Peça 5: SduiCubit — o orquestrador

O Cubit orquestra o pipeline: carrega o JSON, parseia, e emite o resultado como estado.

### Estados

```dart
sealed class SduiState extends Equatable { ... }

final class SduiInitial     extends SduiState { ... }
final class SduiLoading  extends SduiState { ... }
final class SduiSuccess     extends SduiState { List<SduiNode> arvore; }
final class SduiError        extends SduiState { String mensagem; }
```

**Por que `sealed class`?** — Garante que o compilador sabe de todos os subtipos. Em um `switch` ou `BlocBuilder`, o Dart avisa se você esquecer de tratar um estado. É mais seguro que uma classe abstrata aberta.

### Fluxo do carregarTela

```dart
Future<void> carregarTela({String caminhoAsset = _caminhoAsset}) async {
  emit(const SduiLoading());          // 1. UI mostra loading
  try {
    final json = await rootBundle.loadString(caminhoAsset);  // 2. Carrega
    final arvore = SduiParser.parsear(json);                 // 3. Parseia
    emit(SduiSuccess(arvore));                               // 4. Sucesso
  } on FormatException catch (e) {
    emit(SduiError('JSON inválido: ${e.message}'));           // 4. Erro parse
  } catch (e) {
    emit(SduiError('Erro ao carregar tela: $e'));             // 4. Erro geral
  }
}
```

O método é `async` porque `rootBundle.loadString` é assíncrono. Quando trocar para uma API real, basta substituir essa chamada por `http.get` — o restante do pipeline não muda.

### Consumo na tela

```dart
BlocBuilder<SduiCubit, SduiState>(
  builder: (context, estado) => switch (estado) {
    SduiInitial()    => const SizedBox.shrink(),
    SduiLoading() => const DsCarregando(),
    SduiError(:final mensagem) => DsEstadoVazio(mensagem: mensagem),
    SduiSuccess(:final arvore) => SduiRenderer(
      nos: arvore,
      fabrica: WidgetFactory.padrao(),
    ),
  },
)
```

O `BlocBuilder` reage a cada estado emitido pelo Cubit. Quando o estado é `SduiSuccess`, o `SduiRenderer` renderiza a árvore inteira a partir da lista de nós.

---

## Fluxo completo: do JSON à tela

Reunindo todas as peças:

```
1. App inicia
   └── SduiCubit.carregarTela()
        └── emit(SduiLoading)
             └── UI exibe DsCarregando

2. rootBundle.loadString('assets/mock/tela_hospedagens.json')
   └── retorna String JSON

3. SduiParser.parsear(json)
   └── jsonDecode → Map
        └── map['componentes'] → List<dynamic>
             └── .map(SduiNode.fromJson) → List<SduiNode>

4. emit(SduiSuccess(arvore))
   └── BlocBuilder reconstrói

5. SduiRenderer(nos: arvore, fabrica: WidgetFactory.padrao())
   └── para cada nó raiz:
        └── fabrica.construir(context, no, _renderizarNo)
             └── builder registrado retorna widget do Design System

6. Tela renderizada:
   ┌──────────────────────────────┐
   │ [DsDateRangePicker]          │  ← tipo: seletor_data_range
   │ [DsDropdown]                 │  ← tipo: dropdown
   │ [DsLista]                    │  ← tipo: lista
   │   └── DsEstadoVazio          │     (itens vazios nesta fase)
   └──────────────────────────────┘
```

---

## SDUI ↔ MobX: dois mundos que coexistem

Este é o ponto arquitetural mais importante do projeto. A engine SDUI define a **estrutura** da tela. Os MobX stores fornecem os **dados reativos**. Eles se encontram em um único lugar: os builders do `WidgetFactory`.

### Dois tipos de widgets

| Tipo | Vem de | Exemplo |
|---|---|---|
| **Estrutura/layout** | Puramente SDUI | Scaffold, seletores, dropdown (estrutura) |
| **Dados** | SDUI (estrutura) + MobX (dados) | Lista de hospedagens, cards |

### Como funciona a injeção

Na integração SDUI ↔ MobX (fase futura), os builders que precisam de dados reativos vão buscar os stores via `get_it`:

```dart
static Widget _buildLista(BuildContext context, SduiNode no, ...) {
  final filtroStore = GetIt.I<FiltroStore>();  // ← injeção via DI

  return Observer(                             // ← reatividade MobX
    builder: (_) => DsLista(
      itens: filtroStore.hospedagensFiltradas  // ← dados reativos
          .map((h) => DsCardHospedagem(...))
          .toList(),
      mensagemVazia: no.propriedades['vazio_mensagem'] ?? '',
    ),
  );
}
```

**Separação de responsabilidades preservada:**
- O `SduiCubit` não conhece MobX — ele só parseia JSON e emite a árvore
- O `SduiRenderer` não conhece stores — ele só percorre nós e chama o factory
- O `WidgetFactory` é o único ponto de contato entre SDUI e MobX
- Os MobX stores não sabem que o SDUI existe — eles só expõem observables

### Por que não usar Cubit para tudo?

| Aspecto | Cubit | MobX |
|---|---|---|
| **Modelo mental** | Eventos discretos → estados imutáveis | Observables mutáveis → reações automáticas |
| **Ideal para** | Pipeline linear (carrega → parseia → sucesso/erro) | Listas reativas com filtros compostos e computeds |
| **SDUI engine** | Perfeito — estados claros, previsíveis | Overkill — não precisa de reatividade granular |
| **Dados de negócio** | Verboso — cada mudança de filtro seria um novo estado inteiro | Natural — `@computed hospedagensFiltradas` recalcula automaticamente |

Usar ambos demonstra conhecimento dos trade-offs, não indecisão.

---

## Como adicionar um novo tipo SDUI

### Passo 1: Definir o JSON

```json
{
  "tipo": "separador",
  "propriedades": {
    "espessura": 2,
    "cor": "neutra_300"
  }
}
```

### Passo 2: Criar ou reutilizar componente do Design System

Se o componente já existe (ex: `DsDivider`), pule para o passo 3. Se não existe, crie-o seguindo o processo documentado em [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md).

### Passo 3: Registrar o builder no WidgetFactory

```dart
fabrica.registrar('separador', (context, no, renderizarFilho) {
  final props = no.propriedades;
  return Divider(
    thickness: (props['espessura'] as num?)?.toDouble() ?? 1.0,
  );
});
```

### Passo 4: Adicionar teste

```dart
testWidgets('builder separador renderiza Divider', (tester) async {
  final fabrica = WidgetFactory.padrao();
  fabrica.registrar('separador', ...);

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (ctx) => fabrica.construir(
          ctx,
          const SduiNode(tipo: 'separador', propriedades: {'espessura': 2}),
          (_, _) => const SizedBox(),
        ),
      ),
    ),
  ));

  expect(find.byType(Divider), findsOneWidget);
});
```

### Passo 5: Usar no JSON

Adicione o novo nó em `assets/mock/tela_hospedagens.json` (ou em qualquer outro JSON SDUI) e a engine renderiza automaticamente.

### Checklist

- [ ] Componente do Design System existe (ou foi criado)
- [ ] Builder registrado no `WidgetFactory.padrao()`
- [ ] Teste de widget cobre o novo builder
- [ ] JSON SDUI atualizado com o novo tipo
- [ ] Tabela de tipos neste documento atualizada

---

## Testes

A engine SDUI possui **41 testes** organizados em 3 arquivos:

| Arquivo | Testes | O que cobre |
|---|---|---|
| `sdui_parser_test.dart` | 11 | Parse de JSON, filhos recursivos, defaults, Equatable, FormatException |
| `sdui_renderer_test.dart` | 17 | WidgetFactory (registro, construção, fallback, 7 tipos), SduiRenderer (renderização, recursão, lista vazia), DsLista |
| `sdui_cubit_test.dart` | 13 | Estados Equatable, fluxo Carregando → Sucesso, árvore parseada, arvoreAtual, fluxo de erro, chamadas múltiplas |

Todos seguem o padrão AAA (Arrange / Act / Assert) e usam `bloc_test` para os testes do Cubit.

---

## Resumo da hierarquia

```
JSON String
  └── SduiParser.parsear()     → List<SduiNode>        (dados)
       └── SduiCubit            → SduiState          (orquestração)
            └── SduiRenderer    → Widget tree          (renderização)
                 └── WidgetFactory → Widget do DS      (tradução tipo → widget)
                      └── [MobX stores via get_it]     (dados reativos, fase futura)
```

Cada camada depende apenas da anterior. O parser não sabe o que é um widget. O renderer não sabe o que é um Cubit. O factory não sabe de onde veio a árvore. Essa independência é o que torna a engine testável, extensível e substituível.
