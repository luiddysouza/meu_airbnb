# meu_airbnb

[![Flutter CI](https://github.com/luiddysouza/meu_airbnb/actions/workflows/flutter.yml/badge.svg)](https://github.com/luiddysouza/meu_airbnb/actions/workflows/flutter.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Aplicativo **Flutter web + mobile** para gerenciamento de hospedagens de Airbnb.  
Projeto de portfólio com foco em arquitetura avançada: **Clean Architecture**, **Server-Driven UI**, dois gerenciadores de estado (**Cubit** + **MobX**) e **Design System** próprio em package separado.

---

## Funcionalidades

- Tela de **splash** com indicador de carregamento e redirecionamento automático
- **Login com autenticação mock** e guard de rota (rotas protegidas redirecionam para `/login`)
- Listar, criar, editar e excluir hospedagens com **optimistic updates**
- Filtrar por período (check-in / check-out) e por imóvel — com **botão de limpar (X)** em cada filtro
- Interface **responsiva** — sidebar em desktop (≥ 900 px), coluna única em mobile
- Layout definido por JSON (**Server-Driven UI**) — trocar o JSON muda a UI sem recompilar
- Confirmação de exclusão e snackbar de feedback (sucesso / erro)
- Catálogo visual interativo dos componentes (**Widgetbook**)
- Cobertura de testes ≥ 80 %

---

## Arquitetura

```
Presentation  →  Domain  ←  Data
      ↑
  SDUI Engine (Cubit)
      ↑
  JSON mock (assets/)
```

| Camada | Responsabilidade |
|---|---|
| **Domain** | Entidades, use cases, contratos de repositório. Zero dependências externas. |
| **Data** | Modelos JSON, datasource em memória (simula latência), `RepositoryImpl`. |
| **Presentation** | Stores MobX, páginas, widgets. Acessa domínio via use cases. |
| **SDUI Engine** | Parse JSON → árvore `SduiNode` → `WidgetFactory` → widgets do Design System. |

### Fluxo completo

```
JSON mock (assets/)
  → SduiCubit        (parse + emite SduiState)
    → SduiRenderer   (percorre árvore recursivamente)
      → WidgetFactory (registry tipo → widget DS)
        → Observer   (flutter_mobx — dados reativos)
          → MobX Stores (CRUD + Optimistic State)
            → Use Cases → Either<Failure, T>
              → Repository → DataSource (memória)
```

### State Management split

| Gerenciador | Responsabilidade | Motivo |
|---|---|---|
| **Cubit** (`flutter_bloc`) | Engine SDUI: parse JSON, estados `loading / success / error` da widget tree | Estados discretos, previsíveis, unidirecionais |
| **MobX** (`mobx` + `flutter_mobx`) | Estado das hospedagens, filtros, CRUD, optimistic updates | Reatividade granular, `@observable` + `@computed` |

> Regra: Cubit nunca gerencia dados de negócio. MobX nunca gerencia a engine SDUI.

### Optimistic State

```
1. Usuário dispara ação
   → Store salva snapshot do estado atual
2. Lista atualizada imediatamente
   → Observer reflete na UI (feedback instantâneo)
3. Use case chama DataSource (Future.delayed simula latência)
4a. Right(sucesso) → descarta snapshot
4b. Left(Failure)  → restaura snapshot + seta erro → snackbar
```

---

## Server-Driven UI (SDUI)

O JSON `assets/mock/tela_hospedagens.json` descreve a árvore de widgets da tela principal.  
Alterar o JSON muda o layout **sem recompilar** a lógica de negócio.

```json
{
  "tela": "hospedagens",
  "componentes": [
    { "tipo": "seletor_data_range", "propriedades": { "rotulo_inicio": "Check-in", "rotulo_fim": "Check-out" }, "acao": { "tipo": "filtrar_por_data" } },
    { "tipo": "dropdown",           "propriedades": { "rotulo": "Imóvel", "opcoes_source": "imoveis" },         "acao": { "tipo": "filtrar_por_imovel" } },
    { "tipo": "lista",              "propriedades": { "dados_source": "hospedagens_filtradas" } }
  ]
}
```

| Tipo SDUI | Componente DS | Dados reativos? |
|---|---|---|
| `seletor_data_range` | `DsDateRangePicker` | Não |
| `dropdown` | `DsDropdown` | Sim |
| `lista` | `DsLista` + `Observer` | Sim |
| `card_hospedagem` | `DsCardHospedagem` | Sim |
| `botao_primario` | `DsBotaoPrimario` | Não |
| `estado_vazio` | `DsEstadoVazio` | Não |
| `carregando` | `DsCarregando` | Não |

Documentação completa: [docs/SDUI.md](docs/SDUI.md)

---

## Design System

Package Dart separado em `packages/design_system/`.  
Todos os componentes usam tokens (`DsCores`, `DsTipografia`, `DsEspacamentos`, `DsSombras`) — sem valores hardcoded.

```
packages/design_system/lib/
├── tokens/        # cores, tipografia, espaçamentos, sombras
├── tema/          # ThemeData + ThemeExtension
└── componentes/
    ├── botoes/    # DsBotaoPrimario, DsBotaoSecundario, DsBotaoIcone
    ├── cards/     # DsCardHospedagem
    ├── inputs/    # DsTextField
    ├── selectores/# DsDateRangePicker, DsDropdown
    ├── imagens/   # DsImagemBase64
    ├── listas/    # DsLista, DsListTile
    ├── feedback/  # DsSnackbar, DsEstadoVazio, DsCarregando, DsDialogConfirmacao
    └── layout/    # DsScaffoldResponsivo, DsAppBar
```

Documentação completa: [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md)

---

## Estrutura de Pastas

```
meu_airbnb/
├── .github/
│   ├── copilot-instructions.md      # Contexto de arquitetura para Copilot
│   ├── prompts/                     # Prompts reutilizáveis para IA (slash commands)
│   └── workflows/flutter.yml        # CI/CD — analyze + test + build
├── assets/mock/                     # JSONs SDUI + dados mock
├── packages/design_system/          # Design System (package separado)
├── widgetbook/                      # Catálogo visual de componentes
├── lib/
│   ├── core/
│   │   ├── di/          # get_it — injecao.dart
│   │   ├── erros/       # Failure abstrata + CacheFailure
│   │   ├── platform/    # Platform Channels (share, conectividade, galeria, biometrica)
│   │   ├── roteamento/  # go_router (splash → login → /)
│   │   ├── sdui/        # Engine SDUI (models, parser, renderer, factory, cubit)
│   │   ├── services/    # Base64IsolateService (encoding em isolate)
│   │   └── usecases/    # Contrato UseCase<Output, Params>
│   └── features/
│       ├── auth/        # AuthStore + LoginPagina + UsuarioEntity
│       ├── hospedagens/ # data / domain / presentation
│       └── splash/      # SplashPagina
├── test/                            # Testes unitários e de widget
└── docs/                            # Documentação detalhada
```

---

## Dependências

### Produção

| Pacote | Versão | Uso |
|---|---|---|
| `flutter_bloc` | ^9.0.0 | Cubit para SDUI engine |
| `mobx` | ^2.4.0 | Estado reativo do domínio |
| `flutter_mobx` | ^2.2.0 | Observer widgets |
| `get_it` | ^8.0.0 | Injeção de dependências |
| `fpdart` | ^1.1.0 | `Either<Failure, T>` |
| `equatable` | ^2.0.5 | Comparação de entidades por valor |
| `uuid` | ^4.5.0 | Geração de IDs únicos |
| `go_router` | ^14.0.0 | Roteamento (deep links web) |

### Dev

| Pacote | Uso |
|---|---|
| `mobx_codegen` | Gera `.g.dart` para MobX |
| `json_serializable` | Gera `fromJson`/`toJson` |
| `build_runner` | Code generation |
| `mockito` | Mocks para testes |
| `bloc_test` | Testes de Cubit |

---

## Setup

### Pré-requisitos

- Flutter SDK (stable) — `flutter --version`
- Dart SDK ^3.11.4

### Instalação

```bash
# Clone
git clone https://github.com/luiddysouza/meu_airbnb.git
cd meu_airbnb

# Dependências
flutter pub get
cd packages/design_system && flutter pub get && cd ../..
cd widgetbook && flutter pub get && cd ..

# Geração de código (MobX + JSON serialization + mocks)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Executar

```bash
# App (web)
flutter run -d chrome

# App (mobile)
flutter run

# Widgetbook (catálogo visual)
cd widgetbook && flutter run -d chrome
```

---

## Testes

```bash
# App principal (com cobertura)
flutter test --coverage

# Design System
cd packages/design_system && flutter test
```

**303 testes** cobrindo: use cases, repository impl, MobX stores (com `reaction()`), Cubit (com `bloc_test`), widgets do Design System, WidgetFactory, SDUI parser/renderer, páginas, dialogs e platform channels.

---

## CI/CD

GitHub Actions (`.github/workflows/flutter.yml`) — executado em push/PR para `main`:

1. `flutter pub get` (app + design_system + widgetbook)
2. `build_runner build` — gera código MobX + JSON + mocks
3. `flutter analyze --fatal-infos` — zero warnings
4. `flutter test --coverage` — app
5. `flutter test` — design_system
6. `flutter build web --release`
7. `flutter build apk --debug`

---

## Workflow IA

Prompts reutilizáveis em `.github/prompts/` (disponíveis como slash commands no Copilot via `/`):

| Prompt | Uso |
|---|---|
| `criar-componente.prompt.md` | Cria componente no DS (widget + Widgetbook + teste) |
| `criar-feature.prompt.md` | Cria feature completa (entidade → use case → store → SDUI) |
| `review-code.prompt.md` | Checklist de review (arquitetura, testes, SDUI, Either, optimistic) |
| `gerar-json-sdui.prompt.md` | Gera JSON SDUI para nova tela |

Contexto de arquitetura (carregado automaticamente): `.github/copilot-instructions.md`

---

## Documentação

| Arquivo | Conteúdo |
|---|---|
| [docs/SDUI.md](docs/SDUI.md) | Engine SDUI — schema JSON, tipos, como adicionar novos tipos |
| [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) | Tokens, componentes, padrões visuais |
| [docs/ARQUITETURA.md](docs/ARQUITETURA.md) | Camadas, fluxo de dados, decisões de design |
| [docs/FORMULARIOS.md](docs/FORMULARIOS.md) | Padrão Blueprint/Ser Humano para formulários reativos com MobX |
| [docs/DECISOES.md](docs/DECISOES.md) | ADRs — decisões com contexto e alternativas |
| [docs/PROXIMOS_PASSOS.md](docs/PROXIMOS_PASSOS.md) | Roadmap pós-MVP |

---

## Próximos Passos

Veja [docs/PROXIMOS_PASSOS.md](docs/PROXIMOS_PASSOS.md) para o roadmap completo.

---

## Licença

MIT — veja [LICENSE](LICENSE).
