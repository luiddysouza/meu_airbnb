# Arquitetura — meu_airbnb

## Visão Geral

O `meu_airbnb` segue **Clean Architecture** adaptada para Flutter, com quatro camadas bem definidas:

```
┌──────────────────────────────────────────────────┐
│                  Presentation                    │
│   (MobX Stores, Páginas, Widgets, SDUI Engine)   │
└────────────────────┬─────────────────────────────┘
                     │ depende de
┌────────────────────▼─────────────────────────────┐
│                    Domain                        │
│       (Entidades, Use Cases, Contratos)          │
└────────────────────▲─────────────────────────────┘
                     │ implementa
┌────────────────────┴─────────────────────────────┐
│                     Data                         │
│   (Models, DataSource em memória, RepositoryImpl)│
└──────────────────────────────────────────────────┘
```

A **regra da dependência** é respeitada: camadas externas dependem de camadas internas, nunca o contrário. Domain não importa nenhum pacote externo além de `equatable` e `fpdart`.

---

## Camadas

### Domain

Núcleo da aplicação. Contém as regras de negócio puras, completamente isoladas de infraestrutura.

**Entidades**
- `HospedagemEntity` — Equatable, `copyWith`, campos imutáveis
- `ImovelEntity` — Equatable, campos imutáveis
- Enums: `StatusHospedagem`, `Plataforma`

**Contratos de repositório**
- `HospedagemRepository` — interface abstrata com métodos que retornam `Future<Either<Failure, T>>`

**Use Cases**
- Implementam `UseCase<Output, Params>`
- Delegam ao repositório — sem lógica extra
- Nunca lançam exceções — sempre retornam `Either`

| Use Case | Retorno |
|---|---|
| `ObterHospedagens` | `Either<Failure, List<HospedagemEntity>>` |
| `AdicionarHospedagem` | `Either<Failure, HospedagemEntity>` |
| `AtualizarHospedagem` | `Either<Failure, HospedagemEntity>` |
| `DeletarHospedagem` | `Either<Failure, void>` |
| `ObterImoveis` | `Either<Failure, List<ImovelEntity>>` |

**Tratamento de erros**
- `Failure` — classe abstrata, extende `Equatable`
- `CacheFailure` — falha da camada de dados local
- `ServerFailure` — reservado para integração futura com API

### Data

Implementações concretas dos contratos do domain.

**HospedagemModel**
- Gerado com `json_serializable` (`@JsonSerializable`)
- `fromJson` / `toJson` para serialização
- `fromEntity(entity)` / `toEntity()` para conversão com domain

**HospedagemLocalDataSource**
- `inicializar()` carrega `assets/mock/hospedagens.json` e `assets/mock/imoveis.json` para listas em memória
- Assets são **read-only** — toda mutação acontece na cópia em memória
- Cada operação CRUD usa `Future.delayed(300–800 ms)` para simular latência de rede
- Lança exceções nomeadas (`Exception('não encontrado')`) que o repositório captura

**HospedagemRepositoryImpl**
- Implementa `HospedagemRepository`
- Cada método usa `try/catch`: sucesso → `Right(valor)`, exceção → `Left(CacheFailure(...))`
- Converte `HospedagemModel` ↔ `HospedagemEntity` em cada operação

### Presentation

UI e estado reativo.

**Stores MobX**

`HospedagemStore`:
- `@observable ObservableList<HospedagemEntity> hospedagens`
- `@observable bool carregando`
- `@observable String? erro`
- Actions: `carregarHospedagens`, `adicionarHospedagem`, `atualizarHospedagem`, `deletarHospedagem`
- Todas as actions de escrita seguem o **Optimistic State Pattern**
- A lista é sempre mutada in-place (`..clear()..addAll()`) para preservar a referência usada pelo `FiltroStore`

`FiltroStore`:
- `@observable DateTimeRange? periodoSelecionado`
- `@observable String? imovelSelecionadoId`
- `@observable ObservableList<ImovelEntity> imoveis`
- `@computed List<HospedagemEntity> hospedagensFiltradas` — filtra por período + imóvel
- Mantém referência a `todasHospedagens` do `HospedagemStore` via binding externo
- `selecionarPeriodo(null)` e `selecionarImovel(null)` limpam os filtros (usados pelo botão X)

`AuthStore`:
- `@observable bool estaLogado`
- `@observable bool carregando`
- `@observable String? erro`
- `@action Future<void> entrar(email, senha)` — mock: valida e-mail não vazio + senha ≥ 6 chars
- `@action void sair()` — reseta o estado
- Pronto para substituir a lógica mock por chamada de API real

**Páginas e Widgets**
- `SplashPagina` — exibe logo + `DsCarregando`, redireciona para `/login` após 2 s
- `LoginPagina` — formulário e-mail + senha com `Observer` no erro e no botão; sucesso redireciona para `/`
- `HospedagensPagina` — consome `SduiCubit` via `BlocBuilder`
- `FormularioHospedagemDialog` — cria/edita hospedagem com campos completos, validação obrigatória e loading state
- Widgets de layout e dados vêm do Design System (`packages/design_system/`)

**Gerenciamento de Formulários — Padrão Blueprint/Ser Humano**

Formulários reativos seguem o padrão **Blueprint/Ser Humano** (ver [FORMULARIOS.md](FORMULARIOS.md) para detalhes):

- **HospedagemFormState** — estado transitório (incompleto, pode ter erros)
  - Equatable e imutável
  - Campos como `String` para aceitar input inválido
  - `validate()` retorna novo state com erros preenchidos
  - `toEntity(id)` converte para entidade ou falha com `StateError`

- **HospedagemFormStore** (MobX) — orquestrador
  - Um único `@observable HospedagemFormState formState`
  - Actions para atualizar cada campo (com revalidação automática)
  - `salvar()` com persistência via `HospedagemStore` + tratamento de erro
  - Testes: 100% cobertura (29 casos para FormState, 34 para FormStore)

Benefícios:
- Garantia de tipo — impossível persistir dados inválidos
- Reatividade simples — um único observable, não explosão de campos
- Testável isoladamente — FormState é puro (sem DI, mocks)
- UX melhorada — validação não é mostrada prematuramente

### SDUI Engine

Componente transversal em `lib/core/sdui/`. Processa JSON e monta a árvore de widgets dinamicamente.

Ver documentação detalhada em [SDUI.md](SDUI.md).

---

## Fluxo de Dados Detalhado

### Inicialização

```
main()
  → configurarInjecao()           # get_it registra todas as dependências
    → HospedagemLocalDataSource.inicializar()  # carrega assets para memória
    → FiltroStore.carregarImoveis()            # popula dropdown de imóveis
    → HospedagemStore.carregarHospedagens()    # popula lista principal
    → SduiCubit.carregarTela(...)              # parse do JSON SDUI
```

### CRUD com Optimistic State

```
Usuário toca "Excluir"
  → WidgetFactory._buildLista — callback aoDeletar
    → DsDialogConfirmacao.mostrar(...)         # aguarda confirmação
      ↓ confirmado
    → hospedagemStore.deletarHospedagem(id)
      → snapshot = List.from(hospedagens)      # salva estado atual
      → hospedagens.remove(id)                 # atualização imediata
        → Observer detecta mudança → UI reflete
      → DeletarHospedagem(id)                  # use case
        → HospedagemRepositoryImpl.deletar()
          → HospedagemLocalDataSource.deletar()
            → Future.delayed(500ms)            # simula latência
            4a. sucesso → snapshot = null
            4b. falha   → hospedagens = snapshot  # rollback
                        → erro = mensagem          # snackbar aparece
```

---

## State Management: Cubit vs MobX

A separação é uma **decisão de design intencional**, não uma preferência arbitrária.

### Por que Cubit para SDUI?

A engine SDUI tem um ciclo de vida simples e previsível:

```
Initial → Loading → Success(arvore) | Error(msg)
```

Estados discretos com transições unidirecionais — o modelo perfeito para Cubit. O `BlocBuilder` garante que a UI nunca exibe um estado inconsistente.

### Por que MobX para domínio?

O estado das hospedagens é **multidimensional e reativo**:
- Lista de hospedagens muda por CRUD
- Filtros por período e imóvel são computados sobre a mesma lista
- Múltiplos widgets diferentes observam partes distintas do estado

MobX `@computed` recalcula `hospedagensFiltradas` automaticamente quando `todasHospedagens`, `periodoSelecionado` ou `imovelSelecionadoId` mudam. Com Cubit, isso exigiria emissão manual de estados compostos a cada mudança.

### Regra de não-mistura

- **Cubit não acessa stores MobX** — `SduiCubit` não conhece `HospedagemStore`
- **Stores MobX não dependem do Cubit** — as stores acessam use cases diretamente
- A ponte entre os dois mundos acontece no `WidgetFactory`, que injeta as stores via `get_it` nos builders dos widgets de dados

---

## Responsividade

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final isDesktop = constraints.maxWidth >= DsEspacamentos.breakpointDesktop;
    if (isDesktop) return _layoutDesktop(...);
    return _layoutMobile(...);
  },
)
```

| Breakpoint | Valor | Layout |
|---|---|---|
| Mobile | < 600 px | Coluna única: filtros no topo, lista abaixo |
| Tablet | 600–899 px | Coluna única (igual mobile) |
| Desktop | ≥ 900 px | Sidebar (filtros) + área principal (lista) |

A implementação usa apenas `LayoutBuilder` nativo — sem pacotes externos de responsividade.

---

## Injeção de Dependências

`get_it` registrado em `lib/core/di/injecao.dart`. Ordem de registro:

```
DataSource
  → RepositoryImpl
    → Use Cases
      → Stores MobX (HospedagemStore, FiltroStore)
        → AuthStore
          → SduiCubit
```

Uso: `sl<HospedagemStore>()` em qualquer ponto do app após `inicializarDependencias()`.

Stores são registrados como `Singleton`; use cases como `Factory`; `SduiCubit` como `Factory`.

---

## Roteamento

GoRouter configurado em `lib/core/roteamento/rotas.dart`.

| Rota | Página | Protégida? |
|---|---|---|
| `/splash` | `SplashPagina` | Não |
| `/login` | `LoginPagina` | Não |
| `/` | `HospedagensPagina` | Sim |

`initialLocation: '/splash'` — a splash screen é sempre o ponto de entrada.

Guard global via `redirect`: se `AuthStore.estaLogado == false` e a rota não está no conjunto `{'/splash', '/login'}`, redireciona para `/login`. Quando o login é bem-sucedido, `context.go('/')` navega diretamente para a tela principal.

---

## Tratamento de Erros

```
DataSource (lança Exception)
  ↓ try/catch
RepositoryImpl → Left(CacheFailure('mensagem'))
  ↓ Either propagado
UseCase → retorna Left sem modificar
  ↓
Store MobX → fold():
  Left  → restaura snapshot + store.erro = mensagem
  Right → confirma estado + snapshot = null
    ↓
WidgetFactory callback → DsSnackbar.erro(context, mensagem: store.erro!)
```

Exceções **nunca** atravessam a fronteira Domain ↔ Data como fluxo de controle — são sempre convertidas em `Left(Failure)` no repositório.
