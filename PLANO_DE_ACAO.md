# Plano de Ação — meu_airbnb

> Documento de ideação e planejamento completo do projeto **meu_airbnb**.
> Serve como referência para entender como o projeto foi concebido, quais decisões foram tomadas e por quê.

---

## Índice

1. [Contexto e Motivação](#contexto-e-motivação)
2. [Processo de Planejamento](#processo-de-planejamento)
3. [Decisões Técnicas](#decisões-técnicas)
4. [Arquitetura](#arquitetura)
5. [Entidades](#entidades)
6. [Schema JSON SDUI](#schema-json-sdui)
7. [Estrutura de Pastas](#estrutura-de-pastas)
8. [Dependências](#dependências)
9. [Fases de Implementação](#fases-de-implementação)
10. [Correções da Revisão Crítica](#correções-da-revisão-crítica)
11. [Critérios de Verificação](#critérios-de-verificação)
12. [Workflow de Desenvolvimento com IA](#workflow-de-desenvolvimento-com-ia)
13. [Próximos Passos (pós-MVP)](#próximos-passos-pós-mvp)

---

## Contexto e Motivação

### Por que este projeto existe

O **meu_airbnb** é um aplicativo Flutter (web + mobile) para gerenciamento de hospedagens de Airbnb, construído como peça de portfólio. O objetivo é demonstrar domínio técnico avançado em Flutter, indo além de um CRUD convencional.

### Relação com o Task_Manager

Este projeto é uma evolução natural do **Task_Manager** (mesmo autor), que demonstrou Clean Architecture básica com Provider + Hive. O `meu_airbnb` herda os princípios arquiteturais (Clean Arch, separação de camadas, testes por camada) mas avança significativamente em complexidade e diferencial técnico.

### Quatro eixos de diferencial técnico

1. **Server-Driven UI (SDUI)** — Toda a interface é descrita por um JSON que simula a resposta de um backend. Uma engine dedicada (Cubit) parseia esse JSON e monta a árvore de widgets dinamicamente usando componentes de um Design System próprio. Demonstra capacidade de construir arquiteturas flexíveis onde a UI pode ser alterada sem re-deploy do app.

2. **Dois gerenciadores de estado com propósitos distintos** — Em vez de escolher um único gerenciador, o projeto usa Cubit e MobX deliberadamente em papéis complementares. Cubit gerencia a engine SDUI (estados discretos, previsíveis) enquanto MobX gerencia o estado de negócio (listas reativas, filtros compostos, optimistic updates). Demonstra conhecimento prático dos trade-offs de cada abordagem.

3. **Optimistic State** — Toda ação de CRUD reflete imediatamente na UI antes da confirmação do "backend" (simulado com delay). Se falhar, há rollback automático. Prepara a arquitetura para um backend real e demonstra tratamento avançado de UX.

4. **Design System como package** — Componentes visuais isolados em um package Dart reutilizável, com tokens de design (cores, tipografia, espaçamentos), catalogados em Widgetbook. Demonstra capacidade de criar sistemas de design escaláveis.

### Funcionalidades do MVP

- Selecionar intervalo de datas (check-in / check-out)
- Filtrar hospedagens por data e por imóvel
- Listar hospedagens no(s) dia(s) selecionado(s)
- Criar, editar e excluir hospedagens (CRUD completo)
- Suporte a múltiplos imóveis
- Layout responsivo (web: sidebar + conteúdo / mobile: coluna única)
- Feedback visual imediato (optimistic updates)

---

## Processo de Planejamento

O planejamento foi feito iterativamente com assistência de IA (GitHub Copilot), seguindo este fluxo:

### 1. Exploração

Análise completa do Task_Manager como referência:
- Arquitetura (Clean Arch, 3 camadas, DI manual)
- CI/CD (GitHub Actions: analyze → test → build)
- README (badges, estrutura, decisões, deps)
- Testes (26 testes unitários, mockito, padrão AAA)
- Padrões de código (português, feature-first, Equatable)

### 2. Alinhamento

Série de perguntas para definir escopo:

| Pergunta | Resposta |
|---|---|
| Nome do projeto | `meu_airbnb` |
| Tipo de mock | JSON local em `assets/mock/` |
| Design System | Package separado (`packages/design_system/`) |
| Campos da hospedagem | Completo (nome, check-in/out, status, valor, telefone, nº hóspedes, notas, plataforma, imóvel) |
| Catálogo visual | Sim, com Widgetbook |
| Idioma do código | Português |
| Divisão Cubit/MobX | Cubit = SDUI engine / MobX = domínio reativo |
| Workflow IA | Configurações de contexto para Copilot + prompts reutilizáveis |
| Múltiplos imóveis | Sim, com filtro por imóvel |
| Plataforma | Flutter Web + Mobile (mesmo codebase, responsivo) |

### 3. Design

Plano detalhado com fases, commits, estrutura, entidades e schema SDUI.

### 4. Revisão Crítica

8 correções/melhorias identificadas e incorporadas (detalhadas na seção [Correções da Revisão Crítica](#correções-da-revisão-crítica)).

---

## Decisões Técnicas

| Decisão | Escolha | Alternativas | Motivo |
|---|---|---|---|
| **Nome** | `meu_airbnb` | `airbnb_manager`, `hosting_manager` | Definido pelo autor |
| **Dados mock** | JSON local em `assets/mock/`, carregados em memória | Mock server (json_server) | Zero dependências externas, sem custos; assets são read-only, então datasource mantém cópia mutável em memória |
| **Design System** | Package separado (`packages/design_system/`) | Integrado em `lib/core/` | Melhor para portfólio, reutilizável, separação clara |
| **Catálogo** | Widgetbook | Storybook, sem catálogo | Showcase interativo, diferencial para portfólio |
| **Idioma** | Português | Inglês | Consistência com Task_Manager, preferência do autor |
| **SDUI engine** | Cubit (`flutter_bloc`) | Bloc, Provider | Previsível, unidirecional, estados discretos claros (loading/sucesso/erro) |
| **Estado de negócio** | MobX (`mobx` + `flutter_mobx`) | Riverpod, GetX | Reatividade granular, observables + computed, ideal para listas com filtros compostos |
| **Erros** | `Either<Failure, T>` via `fpdart` | try/catch + exceções | Mais maduro, elimina exceções como fluxo de controle, mostra maturidade no portfólio |
| **Roteamento** | `go_router` | Navigator 2.0 manual, auto_route | Necessário para web (deep links, browser back), setup mínimo |
| **DI** | `get_it` | DI manual (como Task_Manager), injectable | Substituição planejada do DI manual, sem code gen extra |
| **Comparação** | `equatable` | `==` manual | Já validado no Task_Manager, elimina boilerplate |
| **IDs** | `uuid` | auto-increment | Funciona offline, sem colisão, já validado no Task_Manager |
| **Responsividade** | `LayoutBuilder` nativo + breakpoints nos tokens | `responsive_framework`, `flutter_adaptive_scaffold` | Sem pacote extra, mostra domínio do framework |
| **CI/CD** | GitHub Actions (free tier) | GitLab CI, CircleCI | Mesmo do Task_Manager, zero custos |

---

## Arquitetura

### Camadas (Clean Architecture adaptada)

```
Presentation  →  Domain  ←  Data
     ↑
  SDUI Engine (Cubit)
     ↑
  JSON Response (mock)
```

| Camada | Responsabilidade | Depende de |
|---|---|---|
| **Domain** | Regras de negócio puras (entidades, usecases, contratos) | Nada (zero deps externas) |
| **Data** | Implementações concretas (modelos, datasource, repository impl) | Domain |
| **Presentation** | UI e gerenciamento de estado (stores MobX, páginas, widgets) | Domain |
| **SDUI Engine** | Parse de JSON, montagem da árvore de widgets, rendering | Design System, Domain (via stores) |

### Fluxo de Dados Completo

```
JSON mock (assets/) → carrega em memória na inicialização
  → SduiCubit (parse + emite widget tree)
    → SduiRenderer (renderiza usando WidgetFactory)
      → Widgets do Design System
        → Widgets de dados envolvidos em Observer (flutter_mobx)
          → Ações disparam MobX Stores (CRUD + Optimistic State)
            → Use Cases retornam Either<Failure, T> (fpdart)
              → Repository → DataSource (em memória, simula latência)
```

### Server-Driven UI (SDUI)

- JSON define a árvore de widgets: tipo, propriedades, filhos, ações
- `SduiCubit` recebe o JSON, parseia e emite a árvore de componentes
- `WidgetFactory` (registry) mapeia `type` do JSON → Widget Flutter do Design System
- `SduiRenderer` renderiza recursivamente a árvore
- Alterar o JSON muda a UI sem recompilar a lógica de negócio

### Reatividade SDUI ↔ MobX

Este é um ponto arquitetural crítico. Dois mundos coexistem:

- **Widgets de estrutura/layout** (scaffold, seletores de data, dropdowns) → vêm puramente do SDUI
- **Widgets de dados** (lista de hospedagens, cards) → combinam SDUI (define a estrutura) + MobX (fornece dados reativos)

Como funciona:
1. O `WidgetFactory` injeta os MobX stores (via `get_it`) nos builders dos widgets que precisam de dados
2. Esses widgets são envolvidos em `Observer` do flutter_mobx para reagir a mudanças
3. Exemplo: SDUI define `{"tipo": "lista", "dados_source": "hospedagens_filtradas"}` → WidgetFactory cria um `Observer` que observa `filtroStore.hospedagensFiltradas` e renderiza a lista

### State Management Split

| Gerenciador | Responsabilidade | Justificativa |
|---|---|---|
| **Cubit** (flutter_bloc) | Parse do JSON SDUI, estado da widget tree, loading/error da UI engine | Previsível, unidirecional, ideal para estados discretos com transições claras |
| **MobX** (mobx + flutter_mobx) | Estado reativo das hospedagens, filtros (data + imóvel), CRUD, optimistic updates | Reatividade granular, observables + computed, ideal para listas reativas com múltiplos filtros |
| **go_router** | Navegação e roteamento | Necessário para web (deep links, browser back/forward) |

### Optimistic State Pattern

```
1. Ação do usuário
   → Salva snapshot do estado atual no MobX Store
2. Atualiza MobX Store imediatamente
   → UI reflete via Observer (feedback instantâneo)
3. Envia para "backend"
   → DataSource simula delay com Future.delayed
4a. Sucesso
   → Descarta snapshot, confirma estado
4b. Failure
   → Restaura snapshot (rollback)
   → Mostra erro via snackbar
```

### Tratamento de Erros (fpdart)

```
DataSource (lança exceção)
  → Repository (captura, retorna Left(Failure))
    → UseCase (propaga Either)
      → MobX Store (fold: Left → rollback + erro, Right → confirma)
```

- Use cases retornam `Future<Either<Failure, T>>` em vez de lançar exceções
- Hierarquia: `Failure` (abstrata, Equatable) → `CacheFailure`, `ServerFailure` (futuro)

### Responsividade

- **Abordagem**: `LayoutBuilder` nativo (sem pacotes extras)
- **Breakpoints** (definidos nos tokens do Design System):
  - `mobile`: < 600
  - `tablet`: 600 - 899
  - `desktop`: ≥ 900
- **Layout web (≥ 900)**: sidebar com filtros + área principal com lista
- **Layout mobile (< 900)**: coluna única, filtros no topo, lista abaixo

---

## Entidades

### HospedagemEntity

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | `String` (UUID) | Identificador único |
| `nomeHospede` | `String` | Nome do hóspede |
| `telefone` | `String?` | Telefone de contato |
| `checkIn` | `DateTime` | Data de entrada |
| `checkOut` | `DateTime` | Data de saída |
| `numHospedes` | `int` | Número de hóspedes |
| `valorTotal` | `double` | Valor total da hospedagem |
| `status` | `StatusHospedagem` | `confirmada`, `pendente`, `cancelada`, `concluida` |
| `plataforma` | `Plataforma` | `airbnb`, `booking`, `direto`, `outro` |
| `imovelId` | `String` | ID do imóvel |
| `notas` | `String?` | Observações |
| `criadoEm` | `DateTime` | Data de criação |

### ImovelEntity

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | `String` (UUID) | Identificador único |
| `nome` | `String` | Nome do imóvel (ex: "Apto Centro SP") |
| `endereco` | `String?` | Endereço |

### Enums

```dart
enum StatusHospedagem { confirmada, pendente, cancelada, concluida }
enum Plataforma { airbnb, booking, direto, outro }
```

---

## Schema JSON SDUI

### Estrutura de um nó

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

### Exemplo: tela principal de hospedagens

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

### Tipos registrados no WidgetFactory

| Tipo SDUI | Componente do Design System | Dados reativos? |
|---|---|---|
| `seletor_data_range` | `DsDateRangePicker` | Não (dispara ação) |
| `dropdown` | `DsDropdown` | Sim (opções vêm de `imovelStore`) |
| `lista` | `DsLista` com `Observer` | Sim (dados de `filtroStore.hospedagensFiltradas`) |
| `card_hospedagem` | `DsCardHospedagem` | Sim (item individual) |
| `botao_primario` | `DsBotaoPrimario` | Não (dispara ação) |
| `estado_vazio` | `DsEstadoVazio` | Não |
| `carregando` | `DsCarregando` | Não |

---

## Estrutura de Pastas

```
meu_airbnb/
├── .github/
│   ├── copilot-instructions.md        # Contexto para Copilot
│   └── workflows/
│       └── flutter.yml                # CI/CD
│
├── .vscode/
│   └── prompts/                       # Prompts reutilizáveis para Copilot
│       ├── criar-componente.prompt.md
│       ├── criar-feature.prompt.md
│       ├── review-code.prompt.md
│       └── gerar-json-sdui.prompt.md
│
├── packages/
│   └── design_system/
│       ├── pubspec.yaml
│       ├── lib/
│       │   ├── design_system.dart     # Barrel export
│       │   ├── tokens/
│       │   │   ├── cores.dart         # Paleta de cores
│       │   │   ├── tipografia.dart    # Estilos de texto
│       │   │   ├── espacamentos.dart  # Constantes de spacing + breakpoints
│       │   │   └── sombras.dart       # Elevações
│       │   ├── tema/
│       │   │   ├── tema_app.dart      # ThemeData + extensões
│       │   │   └── tema_extensoes.dart # ThemeExtension customizadas
│       │   └── componentes/
│       │       ├── botoes/            # Primário, secundário, ícone
│       │       ├── cards/             # Card hospedagem, card genérico
│       │       ├── inputs/            # Text field, form field
│       │       ├── selectores/        # Date range picker, dropdown
│       │       ├── listas/            # Lista genérica, list tile
│       │       ├── feedback/          # Snackbar, loading, empty state
│       │       └── layout/            # Scaffold responsivo, app bar
│       └── test/
│
├── assets/
│   └── mock/
│       ├── tela_hospedagens.json      # JSON SDUI da tela principal
│       ├── hospedagens.json           # Dados mock de hospedagens
│       └── imoveis.json              # Dados mock de imóveis
│
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── erros/
│   │   │   └── failures.dart            # Failure abstrata + CacheFailure
│   │   ├── usecases/
│   │   │   └── usecase.dart           # UseCase<Output, Params> → Either
│   │   ├── di/
│   │   │   └── injecao.dart           # get_it setup
│   │   ├── roteamento/
│   │   │   └── rotas.dart             # go_router config
│   │   └── sdui/
│   │       ├── models/
│   │       │   ├── sdui_node.dart       # Nó da árvore (tipo, props, filhos, ações)
│   │       │   └── sdui_action.dart     # Ação (tipo, payload)
│   │       ├── parser/
│   │       │   └── sdui_parser.dart   # JSON → List<SduiNode>
│   │       ├── renderer/
│   │       │   └── sdui_renderer.dart # SduiNode → Widget (recursivo + Observer)
│   │       ├── factory/
│   │       │   └── widget_factory.dart # Registry tipo→builder (injeta stores)
│   │       └── cubit/
│   │           ├── sdui_cubit.dart
│   │           └── sdui_state.dart
│   │
│   └── features/
│       └── hospedagens/
│           ├── data/
│           │   ├── datasources/
│           │   │   └── hospedagem_local_datasource.dart
│           │   ├── models/
│           │   │   └── hospedagem_model.dart
│           │   └── repositories/
│           │       └── hospedagem_repository_impl.dart
│           ├── domain/
│           │   ├── entities/
│           │   │   ├── hospedagem_entity.dart
│           │   │   └── imovel_entity.dart
│           │   ├── repositories/
│           │   │   └── hospedagem_repository.dart
│           │   └── usecases/
│           │       ├── obter_hospedagens.dart
│           │       ├── adicionar_hospedagem.dart
│           │       ├── atualizar_hospedagem.dart
│           │       ├── deletar_hospedagem.dart
│           │       └── obter_imoveis.dart
│           └── presentation/
│               ├── stores/
│               │   ├── hospedagem_store.dart
│               │   └── filtro_store.dart
│               ├── paginas/
│               │   └── hospedagens_pagina.dart
│               └── widgets/
│                   └── hospedagem_detalhes.dart
│
├── widgetbook/
│   ├── pubspec.yaml
│   └── lib/
│       └── main.dart
│
├── test/
│   ├── core/
│   │   └── sdui/
│   │       ├── sdui_parser_test.dart
│   │       ├── sdui_renderer_test.dart
│   │       └── sdui_cubit_test.dart
│   └── features/
│       └── hospedagens/
│           ├── data/
│           │   └── repositories/
│           │       └── hospedagem_repositorio_impl_test.dart
│           ├── domain/
│           │   └── usecases/
│           │       ├── obter_hospedagens_test.dart
│           │       ├── adicionar_hospedagem_test.dart
│           │       ├── atualizar_hospedagem_test.dart
│           │       └── deletar_hospedagem_test.dart
│           └── presentation/
│               └── stores/
│                   ├── hospedagem_store_test.dart
│                   └── filtro_store_test.dart
│
├── docs/
│   ├── ARQUITETURA.md
│   ├── PROXIMOS_PASSOS.md
│   ├── SDUI.md
│   ├── DECISOES.md
│   └── PLANO_DE_ACAO.md              # ← Este arquivo
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## Dependências

### dependencies

| Pacote | Uso |
|---|---|
| `flutter_bloc` | Cubit para SDUI engine |
| `mobx` | Estado reativo do domínio |
| `flutter_mobx` | Observer widgets |
| `get_it` | Injeção de dependências |
| `equatable` | Comparação de entidades por valor |
| `uuid` | Geração de IDs únicos |
| `fpdart` | `Either<Failure, T>` — tratamento funcional de erros |
| `go_router` | Roteamento (necessário para web) |
| `json_annotation` | Anotações para serialização JSON |
| `cupertino_icons` | Ícones |
| `design_system` | Package local (`path: packages/design_system`) |

### dev_dependencies

| Pacote | Uso |
|---|---|
| `mobx_codegen` | Geração de código MobX (`.g.dart`) |
| `json_serializable` | Geração de `fromJson`/`toJson` |
| `build_runner` | Code generation (MobX + JSON) |
| `mockito` | Geração de mocks para testes |
| `bloc_test` | Testes de Cubit |
| `flutter_lints` | Boas práticas de lint |

---

## Fases de Implementação

### Fase 1 — Fundação (commits 1–4)

**Commit 1: Scaffold do projeto**
- `flutter create meu_airbnb` com suporte a web + mobile
- Estrutura de pastas completa (conforme seção acima)
- `pubspec.yaml` com todas as dependências
- `analysis_options.yaml` (extends `flutter_lints`)

**Commit 2: Design System — Tokens**
- Criar package `packages/design_system/`
- Tokens: cores (paleta primária, secundária, semântica), tipografia (escala M3), espaçamentos (4, 8, 12, 16, 24, 32, 48) + breakpoints (600, 900, 1200), sombras (3 níveis de elevação)
- `ThemeData` com M3 + `ColorScheme.fromSeed`
- `ThemeExtension` customizadas para tokens extras

**Commit 3a: Design System — Componentes de input**
- Botões: primário, secundário, ícone (com loading state)
- Text fields: com validação, label, helper text
- Date range picker: seletor de check-in / check-out
- Dropdown: seletor genérico com label

**Commit 3b: Design System — Componentes de exibição**
- Card hospedagem: nome, datas, status badge, valor
- List tile: item genérico de lista
- Empty state: ícone + mensagem + ação opcional
- Loading indicator: shimmer ou circular
- Snackbar customizado: sucesso, erro, info

**Commit 3c: Design System — Componentes de layout**
- Scaffold responsivo: `LayoutBuilder` + breakpoints dos tokens
- App bar adaptativa: título + ações, adapta para web/mobile

**Commit 4: Widgetbook**
- Criar app `widgetbook/` com dependência do `design_system`
- Catalogar todos os componentes dos commits 3a, 3b, 3c
- Organizar por categoria (inputs, exibição, layout)

---

### Fase 2 — SDUI Engine (commits 5–7)

**Commit 5: Modelos SDUI**
- `SduiNode`: tipo (`String`), propriedades (`Map<String, dynamic>`), filhos (`List<SduiNode>`), ação (`SduiAction?`)
- `SduiAction`: tipo (`String`), payload (`Map<String, dynamic>`)
- `SduiParser`: `String` JSON → `List<SduiNode>` (com validação)

**Commit 6: Widget Factory + Renderer**
- `WidgetFactory`: registry `Map<String, WidgetBuilder>` com método `registrar(tipo, builder)`
- Builders dos 7 tipos SDUI registrados (tabela na seção Schema)
- Injeta MobX stores via `get_it` nos builders que precisam de dados reativos
- `SduiRenderer`: recebe `List<SduiNode>`, percorre recursivamente, usa `WidgetFactory` para montar widgets

**Commit 7: SduiCubit**
- Estados: `SduiInitial`, `SduiLoading`, `SduiSuccess(arvore)`, `SduiError(mensagem)`
- Carrega JSON de `assets/mock/tela_hospedagens.json`
- Parseia via `SduiParser`
- Tela consome via `BlocBuilder<SduiCubit, SduiState>`

---

### Fase 3 — Domínio + Dados (commits 8–10)

> Paralela à Fase 6 (mock JSON)

**Commit 8: Entidades + Contratos**
- `HospedagemEntity` (Equatable, `copyWith`)
- `ImovelEntity` (Equatable)
- Enums: `StatusHospedagem`, `Plataforma`
- `HospedagemRepository` (abstrato): métodos retornam `Future<Either<Failure, T>>`
- Use cases: `ObterHospedagens`, `AdicionarHospedagem`, `AtualizarHospedagem`, `DeletarHospedagem`, `ObterImoveis`
- Contrato `UseCase<Output, Params>` adaptado para retornar `Either`

**Commit 9: Camada Data**
- `HospedagemModel`: `fromJson`, `toJson`, `fromEntity`, `toEntity` (com `json_serializable`)
- `HospedagemLocalDataSource`:
  - `init()`: carrega `assets/mock/hospedagens.json` e `imoveis.json` para listas em memória
  - Cada operação CRUD simula latência com `Future.delayed(Duration(milliseconds: 300-800))`
  - Assets são read-only; todas as mutações acontecem na cópia em memória
- `HospedagemRepositoryImpl`: converte exceções em `Left(CacheFailure)`, sucessos em `Right(valor)`

**Commit 10: DI + Roteamento**
- `get_it` setup em `injecao.dart`: registra datasources, repositórios, use cases, stores MobX, SduiCubit
- `go_router` em `rotas.dart`: rota `/` → `HospedagensPagina` (expandível)
- `main.dart`: inicializa DI, cria `MaterialApp.router` com `go_router` e tema do Design System

---

### Fase 4 — Estado Reativo + UI (commits 11–14)

**Commit 11: MobX Stores**
- `HospedagemStore`:
  - `@observable ObservableList<HospedagemEntity> hospedagens`
  - `@observable bool carregando`
  - `@observable String? erro`
  - `@action carregarHospedagens()` — chama use case, faz `fold()`
  - `@action adicionarHospedagem(entidade)` — optimistic: salva snapshot → adiciona na lista → chama use case → `fold()`: Right descarta snapshot, Left restaura + seta erro
  - `@action atualizarHospedagem(entidade)` — mesmo padrão optimistic
  - `@action deletarHospedagem(id)` — mesmo padrão optimistic
- `FiltroStore`:
  - `@observable DateTimeRange? periodoSelecionado`
  - `@observable String? imovelSelecionadoId`
  - `@observable ObservableList<HospedagemEntity> todasHospedagens` (referência do HospedagemStore)
  - `@computed List<HospedagemEntity> hospedagensFiltradas` — filtra por período + imóvel
  - `@action selecionarPeriodo(DateTimeRange)`
  - `@action selecionarImovel(String? id)`

**Commit 12: Integração SDUI ↔ MobX**
- Conectar ações do SDUI aos métodos dos MobX stores:
  - `filtrar_por_data` → `filtroStore.selecionarPeriodo()`
  - `filtrar_por_imovel` → `filtroStore.selecionarImovel()`
  - `adicionar` → abre formulário → `hospedagemStore.adicionarHospedagem()`
  - `editar` → abre formulário → `hospedagemStore.atualizarHospedagem()`
  - `deletar` → confirma → `hospedagemStore.deletarHospedagem()`
- Widgets reativos do WidgetFactory envolvidos em `Observer`

**Commit 13: Tela principal**
- `HospedagensPagina`:
  - `BlocProvider` fornece `SduiCubit`
  - `BlocBuilder` renderiza a árvore SDUI
  - Dentro da árvore, widgets de dados usam `Observer` do MobX
  - Layout responsivo via scaffold do Design System (sidebar em web, coluna em mobile)

**Commit 14: CRUD completo**
- Formulário de criar/editar hospedagem (modal bottom sheet ou dialog):
  - Campos: nome hóspede, telefone, check-in, check-out, nº hóspedes, valor, status, plataforma, imóvel, notas
  - Validação de formulário
  - Modo criar vs editar (detecta por `hospedagem != null`)
- Confirmação de exclusão (dialog)
- Feedback visual: snackbar do Design System (sucesso/erro)
- Optimistic updates visíveis: ação reflete imediatamente, rollback visível em caso de Failure simulada

---

### Fase 5 — Qualidade + Documentação (commits 15–20)

**Commit 15: Testes unitários — Core**
- `sdui_parser_test.dart`: JSON válido parseia corretamente, JSON inválido retorna erro, campos opcionais
- `sdui_cubit_test.dart`: (com `bloc_test`) estados: inicial → carregando → sucesso/erro
- `widget_factory_test.dart`: tipo registrado retorna widget, tipo não registrado retorna fallback

**Commit 16: Testes unitários — Feature**
- Use cases: mock do repositório com `@GenerateMocks`, verificar que retorna `Right` em sucesso e `Left(Failure)` em erro
- Repository impl: mock do datasource, verificar conversão exceção → `Left`, sucesso → `Right`
- MobX stores: usar `reaction()` para capturar mudanças de observables, testar:
  - `carregarHospedagens` popula lista
  - Optimistic: adicionar reflete antes de confirmar
  - Rollback: simular Failure restaura estado anterior
  - Filtros: `computed` recalcula corretamente

**Commit 17: Testes de widget**
- Componentes do Design System: renderiza sem erros, interação dispara callbacks
- `HospedagensPagina`: estados loading/empty/com dados, interação com filtros

**Commit 18: CI/CD**
- GitHub Actions (`.github/workflows/flutter.yml`):
  ```yaml
  - flutter pub get
  - flutter pub run build_runner build --delete-conflicting-outputs
  - flutter analyze --fatal-infos
  - flutter test --coverage
  - flutter build web
  - flutter build apk --debug
  ```
- Triggers: push/PR para `main`
- Runner: `ubuntu-latest` (free tier, zero custos)
- Flutter version: estável mais recente

**Commit 19: Workflow IA**
- `.github/copilot-instructions.md`:
  - Arquitetura Clean Arch com SDUI
  - Convenções de nomeação em português
  - Split Cubit (SDUI) / MobX (domínio)
  - fpdart Either para tratamento de erros
  - Padrão de testes (AAA, mockito, reaction para MobX, bloc_test para Cubit)
  - Breakpoints responsivos definidos nos tokens
- `.vscode/prompts/criar-componente.prompt.md`: template para criar componente no Design System (tokens → widget → widgetbook entry → teste)
- `.vscode/prompts/criar-feature.prompt.md`: template para criar feature completa (entidade → usecase → store → JSON SDUI → WidgetFactory entry → UI)
- `.vscode/prompts/review-code.prompt.md`: checklist de review (arquitetura, testes, SDUI compliance, Either usage, optimistic pattern, responsividade)
- `.vscode/prompts/gerar-json-sdui.prompt.md`: gerar JSON SDUI para nova tela baseado nos componentes disponíveis no WidgetFactory

**Commit 20: Documentação**
- `README.md`: badges (CI, Flutter, Dart, License), sobre, features, arquitetura (diagrama), SDUI (explicação), estrutura de pastas, decisões técnicas (tabela), dependências (tabelas), setup, testes, CI, workflow IA, próximos passos
- `docs/ARQUITETURA.md`: detalhamento das camadas, fluxo SDUI, split Cubit/MobX, optimistic state, fpdart, responsividade
- `docs/SDUI.md`: schema JSON, tipos registrados, como adicionar novos tipos, como funciona a integração com MobX
- `docs/DECISOES.md`: ADRs (Architecture Decision Records) — cada decisão com contexto, alternativas e consequências
- `docs/PROXIMOS_PASSOS.md`: roadmap pós-MVP priorizado
- `docs/PLANO_DE_ACAO.md`: este arquivo (ideia inicial completa)

---

### Fase 6 — Mock JSON (paralelo com Fase 3)

**`assets/mock/imoveis.json`**
- 3 imóveis: "Apto Centro SP", "Casa Praia Ubatuba", "Studio Pinheiros"
- Cada um com id (UUID), nome e endereço

**`assets/mock/hospedagens.json`**
- 8-10 hospedagens fictícias
- Distribuídas entre os 3 imóveis
- Mix de plataformas (airbnb, booking, direto)
- Mix de status (confirmada, pendente, concluída, cancelada)
- Datas variadas (passado, presente, futuro)

**`assets/mock/tela_hospedagens.json`**
- JSON SDUI conforme schema documentado
- Define: seletor de data range, dropdown de imóvel, lista de hospedagens

---

## Correções da Revisão Crítica

Durante a fase de revisão, 8 problemas foram identificados e corrigidos no plano:

| # | Problema | Correção aplicada |
|---|---|---|
| 1 | **DataSource read-only** — O plano original lia/escrevia em `assets/mock/`, mas assets Flutter são read-only em runtime | Datasource carrega JSON de assets apenas na inicialização, mantém cópia mutável em memória para CRUD, simula latência com `Future.delayed` |
| 2 | **Reatividade SDUI ↔ MobX indefinida** — Não estava claro como widgets SDUI consumiriam dados reativos do MobX | Documentado: WidgetFactory injeta stores via `get_it`, widgets de dados envolvidos em `Observer`, widgets de layout vêm puramente do SDUI |
| 3 | **Sem roteamento web** — Web precisa de roteamento para deep links e browser back, mesmo com tela única | Adicionado `go_router` desde o início com rota única expandível |
| 4 | **try/catch para erros** — Usar exceções como fluxo de controle é anti-pattern, especialmente em portfólio | Adicionado `fpdart` com `Either<Failure, T>` em use cases e repository, MobX stores fazem `fold()` |
| 5 | **Commit 3 muito grande** — Todos os componentes do Design System em um único commit | Dividido em 3a (inputs), 3b (exibição), 3c (layout) |
| 6 | **Responsive strategy vaga** — "sidebar + content" sem detalhes de implementação | Definido: `LayoutBuilder` nativo, breakpoints nos tokens do Design System (600/900/1200), sem pacotes extras |
| 7 | **Testes MobX sem padrão** — Testar stores MobX requer abordagem específica não documentada | Documentado: usar `reaction()` do MobX para capturar mudanças de observables em testes |
| 8 | **CI sem build web** — Pipeline do Task_Manager só builda APK, mas meu_airbnb é web + mobile | Adicionado `flutter build web` ao pipeline do GitHub Actions |

---

## Critérios de Verificação

| # | Critério | Como verificar |
|---|---|---|
| 1 | Zero warnings | `flutter analyze --fatal-infos` |
| 2 | Testes passando (>80% cobertura) | `flutter test --coverage` |
| 3 | App funciona na web | `flutter run -d chrome` — layout responsivo |
| 4 | App funciona no mobile | `flutter run` — emulador/device |
| 5 | Widgetbook funciona | `cd widgetbook && flutter run` — todos os componentes visíveis |
| 6 | CRUD completo | Criar, editar, deletar hospedagem com feedback visual |
| 7 | Filtros funcionam | Filtrar por data range e por imóvel simultaneamente |
| 8 | Optimistic state | Ação reflete imediatamente; simular Failure causa rollback + snackbar de erro |
| 9 | SDUI funciona | Alterar JSON em `assets/mock/tela_hospedagens.json` muda a UI sem recompilar lógica |
| 10 | CI passa | GitHub Actions: analyze + test + build web + build apk |
| 11 | Roteamento web | Deep link no browser carrega tela correta, botão back funciona |

---

## Workflow de Desenvolvimento com IA

### Arquivos de contexto

| Arquivo | Propósito |
|---|---|
| `.github/copilot-instructions.md` | Regras do projeto: arquitetura, convenções, Clean Arch, SDUI, split Cubit/MobX, fpdart |
| `.vscode/prompts/criar-componente.prompt.md` | Template para criar componente no Design System |
| `.vscode/prompts/criar-feature.prompt.md` | Template para criar feature completa (entidade→usecase→store→UI) |
| `.vscode/prompts/review-code.prompt.md` | Checklist de review automatizada |
| `.vscode/prompts/gerar-json-sdui.prompt.md` | Gerar JSON SDUI para nova tela |

### Como funciona na prática

1. **Novo componente**: abrir prompt `criar-componente`, descrever o componente → IA gera token + widget + widgetbook entry + teste
2. **Nova feature**: abrir prompt `criar-feature`, descrever a feature → IA gera entidade + usecase + store + JSON SDUI + WidgetFactory entry
3. **Review**: abrir prompt `review-code` com o diff → IA verifica arquitetura, testes, SDUI compliance, Either usage
4. **Nova tela SDUI**: abrir prompt `gerar-json-sdui`, descrever a tela → IA gera JSON SDUI com tipos existentes do WidgetFactory

### Sem custos

- CI usa apenas GitHub Actions free tier (`ubuntu-latest`)
- Sem deploy, sem hosting, sem secrets pagos
- Sem GitHub Copilot API calls (apenas editor local)
- Sem serviços de IA pagos no pipeline

---

## Próximos Passos (pós-MVP)

| Prioridade | Item | Descrição |
|---|---|---|
| **Alta** | Backend real | Firebase/Supabase substituindo datasource em memória. Mesma interface de repositório |
| **Alta** | Autenticação | Firebase Auth ou similar. Cada usuário vê apenas seus imóveis |
| **Média** | Dashboard | Estatísticas: taxa de ocupação, receita mensal por imóvel, comparativo |
| **Média** | Calendário visual | Timeline view com ocupação por imóvel (month/week view) |
| **Média** | Notificações | Local notifications para check-in/check-out do dia |
| **Média** | Busca | Buscar hospedagem por nome do hóspede |
| **Baixa** | Dark mode | Tokens do Design System já preparados para suportar |
| **Baixa** | i18n | Internacionalização português/inglês |
| **Baixa** | Exportar dados | CSV/Excel com filtros aplicados |
