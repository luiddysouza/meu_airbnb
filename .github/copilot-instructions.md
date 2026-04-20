# Copilot Instructions — meu_airbnb

Projeto Flutter (web + mobile) para gerenciamento de hospedagens de Airbnb.
Portfólio avançado com Clean Architecture, Server-Driven UI, dois gerenciadores de estado e Design System próprio.

---

## Arquitetura

### Camadas (Clean Architecture)

```
Presentation  →  Domain  ←  Data
     ↑
  SDUI Engine (Cubit)
     ↑
  JSON Response (assets/mock/)
```

- **Domain**: entidades, use cases, contratos de repositório. Zero dependências externas.
- **Data**: modelos (`fromJson`/`toJson`/`fromEntity`/`toEntity`), datasource em memória, `RepositorioImpl`.
- **Presentation**: stores MobX, páginas, widgets. Acessa domínio via use cases.
- **SDUI Engine** (`lib/core/sdui/`): parse de JSON → árvore de `NoSdui` → `WidgetFactory` → widgets do Design System.

### Fluxo de dados

```
JSON mock (assets/) → carrega em memória na inicialização
  → SduiCubit (parse + emite widget tree)
    → SduiRenderer (renderiza usando WidgetFactory)
      → Widgets do Design System
        → Observer (flutter_mobx) envolve widgets de dados
          → MobX Stores (CRUD + Optimistic State)
            → Use Cases → Either<Falha, T>
              → Repository → DataSource (memória, simula latência)
```

---

## Gerenciamento de Estado — Split Cubit / MobX

| Gerenciador | Usa para | Motivo |
|---|---|---|
| **Cubit** (`flutter_bloc`) | SDUI Engine: parse do JSON, estados `loading/sucesso/erro` da widget tree | Estados discretos, previsíveis, unidirecionais |
| **MobX** (`mobx` + `flutter_mobx`) | Estado das hospedagens, filtros (data + imóvel), CRUD, optimistic updates | Reatividade granular, observables + computed |

**Nunca** misturar: Cubit não gerencia dados de negócio; MobX não gerencia a engine SDUI.

---

## Server-Driven UI (SDUI)

- O JSON (`assets/mock/tela_hospedagens.json`) descreve a árvore de widgets por `tipo`, `propriedades`, `filhos` e `acao`.
- `SduiParser` converte o JSON em `List<NoSdui>`.
- `WidgetFactory` é um registry `Map<String, WidgetBuilder>` que mapeia `tipo` → Widget do Design System.
- `SduiRenderer` percorre a árvore recursivamente e monta os widgets.
- Widgets de **estrutura/layout** (scaffold, seletores) vêm puramente do SDUI.
- Widgets de **dados** (lista, cards) combinam SDUI (estrutura) + `Observer` MobX (dados reativos).
- `WidgetFactory` injeta os stores MobX via `get_it` nos builders que precisam de dados.

### Schema de um nó SDUI

```json
{
  "tipo": "nome_do_componente",
  "propriedades": {},
  "filhos": [],
  "acao": { "tipo": "nome_da_acao", "payload": {} }
}
```

### Tipos registrados no WidgetFactory

| Tipo SDUI | Componente DS | Dados reativos? |
|---|---|---|
| `seletor_data_range` | `DsDateRangePicker` | Não |
| `dropdown` | `DsDropdown` | Sim (`imovelStore`) |
| `lista` | `DsLista` + `Observer` | Sim (`filtroStore.hospedagensFiltradas`) |
| `card_hospedagem` | `DsCardHospedagem` | Sim |
| `botao_primario` | `DsBotaoPrimario` | Não |
| `estado_vazio` | `DsEstadoVazio` | Não |
| `carregando` | `DsCarregando` | Não |

---

## Tratamento de Erros (fpdart)

- Use cases **sempre** retornam `Future<Either<Falha, T>>`. Nunca lançar exceções como fluxo de controle.
- Repository captura exceções do datasource e retorna `Left(FalhaCache(...))`.
- MobX stores fazem `fold()`:
  - `Left` → rollback do optimistic state + seta `erro`.
  - `Right` → confirma estado, descarta snapshot.
- Hierarquia: `Falha` (abstrata, Equatable) → `FalhaCache`, `FalhaServidor` (futuro).

---

## Optimistic State Pattern

```
1. Usuário dispara ação
   → Store salva snapshot do estado atual
2. Store atualiza lista imediatamente
   → Observer reflete na UI (feedback instantâneo)
3. Use case chama datasource (simula latência com Future.delayed)
4a. Right(sucesso) → descarta snapshot
4b. Left(falha)   → restaura snapshot + seta erro → snackbar de erro
```

Sempre implementar este padrão em `adicionarHospedagem`, `atualizarHospedagem`, `deletarHospedagem`.

---

## Convenções de Nomeação (Português)

Todo código do projeto usa **português**, incluindo variáveis, métodos, classes, arquivos e parâmetros.

| Contexto | Exemplo |
|---|---|
| Entidades | `HospedagemEntidade`, `ImovelEntidade` |
| Modelos | `HospedagemModelo` |
| Use cases | `ObterHospedagens`, `AdicionarHospedagem` |
| Repositórios | `HospedagemRepositorio`, `HospedagemRepositorioImpl` |
| Datasource | `HospedagemLocalDataSource` |
| Stores MobX | `HospedagemStore`, `FiltroStore` |
| Cubit | `SduiCubit`, `SduiEstado` |
| Estados Cubit | `SduiInicial`, `SduiCarregando`, `SduiSucesso`, `SduiErro` |
| Design System | `DsCardHospedagem`, `DsBotaoPrimario`, `DsDropdown` |
| SDUI | `NoSdui`, `AcaoSdui`, `SduiParser`, `SduiRenderer`, `WidgetFactory` |
| Enums | `StatusHospedagem.confirmada`, `Plataforma.airbnb` |
| Erros | `Falha`, `FalhaCache`, `FalhaServidor` |
| Campos | `nomeHospede`, `checkIn`, `checkOut`, `imovelId`, `valorTotal` |
| Métodos | `carregarHospedagens()`, `selecionarPeriodo()`, `filtrarPorImovel()` |

---

## Design System (`packages/design_system/`)

- Package Dart separado. Nunca colocar componentes visuais em `lib/core/` ou `lib/features/`.
- Todos os tokens ficam em `lib/tokens/` (cores, tipografia, espaçamentos, sombras).
- Todo componente novo exige: widget → entrada no Widgetbook → teste unitário.
- Prefixo `Ds` em todos os componentes públicos (ex: `DsBotaoPrimario`, `DsCardHospedagem`).

---

## Responsividade

- **Ferramenta**: `LayoutBuilder` nativo. **Nunca** usar pacotes de responsividade externos.
- **Breakpoints** (definidos em `tokens/espacamentos.dart`):
  - `mobile`: < 600px
  - `tablet`: 600px – 899px
  - `desktop`: ≥ 900px
- **Web (≥ 900px)**: sidebar com filtros à esquerda + área principal com lista à direita.
- **Mobile (< 900px)**: coluna única — filtros no topo, lista abaixo.

---

## Estrutura de Pastas

```
lib/
├── core/
│   ├── erros/         # Falha abstrata + subclasses
│   ├── usecases/      # Contrato UseCase<Output, Params>
│   ├── di/            # get_it setup (injecao.dart)
│   ├── roteamento/    # go_router (rotas.dart)
│   └── sdui/
│       ├── modelos/   # NoSdui, AcaoSdui
│       ├── parser/    # SduiParser
│       ├── renderizador/ # SduiRenderer
│       ├── fabrica/   # WidgetFactory
│       └── cubit/     # SduiCubit, SduiEstado
└── features/
    └── hospedagens/
        ├── data/
        │   ├── datasources/
        │   ├── modelos/
        │   └── repositorios/
        ├── dominio/
        │   ├── entidades/
        │   ├── repositorios/
        │   └── usecases/
        └── apresentacao/
            ├── stores/   # MobX (HospedagemStore, FiltroStore)
            ├── paginas/
            └── widgets/
```

---

## Padrão de Testes

- **Framework**: `flutter_test` + `mockito` + `bloc_test`.
- **Padrão**: AAA (Arrange / Act / Assert) em todos os testes.
- **Mocks**: gerar com `@GenerateMocks([...])` do mockito.
- **Use cases**: mock do repositório → verificar `Right` em sucesso, `Left(Falha)` em erro.
- **Repository impl**: mock do datasource → verificar conversão exceção → `Left`, valor → `Right`.
- **MobX stores**: usar `reaction()` para capturar mudanças de observables. Testar carregamento, optimistic update e rollback.
- **Cubit**: usar `bloc_test` com `expect: [SduiCarregando(), SduiSucesso(...)]`.
- **Design System**: widget testa renderização sem erros + callbacks disparados.
- **Cobertura mínima**: 80%.

---

## Injeção de Dependências

- Usar `get_it` (singleton configurado em `core/di/injecao.dart`).
- Ordem de registro: DataSource → RepositorioImpl → UseCases → Stores MobX → SduiCubit.
- Nunca instanciar dependências diretamente nas páginas ou stores.

---

## Dependências principais

```yaml
# produção
flutter_bloc: ^9.x      # Cubit para SDUI engine
mobx: ^2.x              # Estado reativo do domínio
flutter_mobx: ^2.x      # Observer widgets
get_it: ^8.x            # Injeção de dependências
equatable: ^2.x         # Comparação de entidades por valor
uuid: ^4.x              # IDs únicos
fpdart: ^1.x            # Either<Falha, T>
go_router: ^14.x        # Roteamento web/mobile

# dev
mobx_codegen: ^2.x      # Geração .g.dart para MobX
json_serializable: ^6.x # fromJson/toJson
build_runner: ^2.x      # Code generation
mockito: ^5.x           # Mocks para testes
bloc_test: ^9.x         # Testes de Cubit
```

---

## Regras gerais

1. Domain nunca importa pacotes externos (exceto `equatable`, `fpdart`).
2. Use cases nunca lançam exceções — sempre retornam `Either`.
3. Stores MobX nunca chamam datasources diretamente — apenas via use cases.
4. SDUI renderer nunca conhece as stores — a injeção acontece no `WidgetFactory`.
5. Assets em `assets/mock/` são **read-only**. Datasource carrega na inicialização e mantém cópia mutável em memória.
6. Novos componentes do Design System sempre têm entrada no Widgetbook.
7. Ao adicionar novo tipo SDUI: registrar no `WidgetFactory` + documentar na tabela do `docs/SDUI.md`.
