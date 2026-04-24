# Decisões de Arquitetura (ADRs) — meu_airbnb

Cada ADR (Architecture Decision Record) documenta uma escolha técnica relevante: o contexto que motivou a decisão, as alternativas consideradas e as consequências.

---

## ADR-001: Package separado para o Design System

**Status**: Aceito

**Contexto**  
O projeto precisava de um conjunto de componentes visuais reutilizáveis com tokens de design. A questão era onde colocar esses componentes: dentro de `lib/core/`, em `lib/shared/` ou em um package Dart separado.

**Decisão**  
Criado o package `packages/design_system/` com seu próprio `pubspec.yaml` e conjunto de testes.

**Alternativas consideradas**
- `lib/core/widgets/` — simples, mas mistura infraestrutura de app com componentes visuais; sem isolamento de dependências
- `lib/shared/` — igual ao anterior, sem vantagens de isolamento

**Consequências**
- (+) Separação de responsabilidades clara: o app consome o DS via `package:design_system/design_system.dart`
- (+) Testável isoladamente — testes do DS não dependem de stores ou use cases
- (+) Reutilizável: outro app pode importar o mesmo package
- (+) Forçou o uso consistente de tokens (sem valores hardcoded no app)
- (-) Exige `pub get` adicional e `path` dependency no `pubspec.yaml`

---

## ADR-002: Split Cubit (SDUI) + MobX (domínio)

**Status**: Aceito

**Contexto**  
O app precisava de dois tipos distintos de gerenciamento de estado: (a) estados discretos da engine SDUI (`initial → loading → success/error`) e (b) estado reativo multidimensional das hospedagens (lista + filtros compostos + CRUD).

**Decisão**  
Usar **Cubit** (`flutter_bloc`) para a engine SDUI e **MobX** (`mobx` + `flutter_mobx`) para o estado das hospedagens. Os dois mundos nunca se misturam — a ponte ocorre no `WidgetFactory` via `get_it`.

**Alternativas consideradas**
- Apenas Cubit — estados compostos (lista + filtros) exigiriam Bloc completo com eventos complexos, ou múltiplos Cubits aninhados
- Apenas MobX — gerenciar o ciclo SDUI (loading/error) com observables é possível mas perde a elegância do `bloc_test` e do histórico de estados
- Apenas Provider/Riverpod — opções válidas, mas menos expressivas para o padrão SDUI discreto + reatividade granular
- GetX — conveniente, mas combina roteamento + DI + estado de forma acoplada; dificulta testes

**Consequências**
- (+) Cada gerenciador é usado no contexto ideal para o qual foi projetado
- (+) `bloc_test` com `expect: [Loading(), Success()]` é elegante para SDUI
- (+) `@computed hospedagensFiltradas` recalcula automaticamente — sem boilerplate de emit
- (+) Demonstra versatilidade técnica no portfólio
- (-) Dois paradigmas de estado a aprender/manter
- (-) Requer disciplina para não misturar (documentado nas copilot-instructions)

---

## ADR-003: Either<Failure, T> com fpdart

**Status**: Aceito

**Contexto**  
Tratamento de erros no fluxo Domain → Data → Presentation. A alternativa clássica são exceções com `try/catch` em cascata.

**Decisão**  
Use cases retornam `Future<Either<Failure, T>>`. Repositórios convertem exceções em `Left(CacheFailure(...))`. Stores fazem `fold()`.

**Alternativas consideradas**
- `try/catch` em cada camada — funcional, mas exceções como fluxo de controle são anti-pattern; difícil de testar cenários de erro
- `Result<T>` manual — válido, mas reinventar o que `fpdart` já oferece não agrega valor
- `sealed class` do Dart — opção moderna, mas mais verbosa para o caso de uso

**Consequências**
- (+) Erros são **valores**, não exceções — forçado a tratá-los no `fold()`
- (+) Impossível "esquecer" de tratar um erro (o compilador força o `fold`)
- (+) Testes de erro são simples: `when(...).thenAnswer((_) async => Left(CacheFailure(...)))`
- (+) Demonstra programação funcional aplicada no portfólio
- (-) Curva de aprendizado para quem não conhece `Either`
- (-) Dependência de `fpdart` no domain (aceito pois `fpdart` é utilitário puro)

---

## ADR-004: Assets read-only — DataSource em memória

**Status**: Aceito

**Contexto**  
Flutter não permite escrita em `assets/` em runtime. Era preciso definir como o datasource lidaria com CRUD sem backend real.

**Decisão**  
`HospedagemLocalDataSource.inicializar()` carrega os JSONs dos assets **uma vez** para listas mutáveis em memória. Todas as operações CRUD operam sobre essas listas. `Future.delayed` simula latência de rede.

**Alternativas consideradas**
- `shared_preferences` — persistência simples, mas introduz dependência externa sem valor para portfólio
- `sqflite` / `drift` (SQLite) — persistência real, mas complexidade desnecessária para demonstração de arquitetura
- `hive` / `isar` — idem acima

**Consequências**
- (+) Zero dependências externas de armazenamento
- (+) Assets intactos — read-only, sem risco de corrupção
- (+) `Future.delayed` exercita o caminho assíncrono e o optimistic state
- (+) Fácil substituição futura: trocar `HospedagemLocalDataSource` por `HospedagemRemoteDataSource` sem mudar Domain nem Presentation
- (-) Dados não persistem entre sessões (reinicializa do JSON a cada execução)

---

## ADR-005: get_it para injeção de dependências

**Status**: Aceito

**Contexto**  
O projeto precisava de DI para conectar DataSource → Repository → UseCase → Store → SduiCubit. A alternativa de DI manual (como no Task_Manager de referência) funcionaria, mas limitaria flexibilidade em testes.

**Decisão**  
Usar `get_it` com singleton global `sl`. Registrar dependências em `lib/core/di/injecao.dart` em ordem topológica.

**Alternativas consideradas**
- DI manual (construtores passados para baixo) — sem dependência, mas verboso; dificulta testes de integração
- `injectable` — geração de código para DI, mais automático, mas code gen extra sem benefício proporcional para escopo atual
- Riverpod como DI — válido, mas misturaria DI com gerenciamento de estado

**Consequências**
- (+) `sl<T>()` disponível em qualquer lugar após inicialização
- (+) `GetIt.instance.reset()` simplifica setup/teardown de testes
- (+) Substituição de implementações em testes é trivial (`registerSingleton<T>(mock)`)
- (-) Service locator é considerado anti-pattern por alguns — mas aceitável para portfólio Flutter

---

## ADR-006: LayoutBuilder nativo para responsividade

**Status**: Aceito

**Contexto**  
O app precisa funcionar em web (desktop/tablet) e mobile com layouts distintos: sidebar + lista em desktop, coluna única em mobile.

**Decisão**  
`LayoutBuilder` com breakpoints definidos nos tokens (`DsEspacamentos.breakpointMobile = 600`, `DsEspacamentos.breakpointDesktop = 900`). Sem pacotes externos.

**Alternativas consideradas**
- `responsive_framework` — conveniente, mas dependência extra sem benefício para o escopo do projeto
- `flutter_adaptive_scaffold` (Material 3) — opinionado, não alinha com o Design System próprio
- `media_query` direto — funcional, mas `LayoutBuilder` é mais correto (reage a restrições do widget, não da tela)

**Consequências**
- (+) Zero dependências extras
- (+) Demonstra domínio do Flutter framework nativo
- (+) Breakpoints centralizados nos tokens — mudança de valor propaga para toda a UI
- (-) Mais código de layout manual comparado a pacotes de responsividade

---

## ADR-007: go_router para roteamento

**Status**: Aceito

**Contexto**  
Aplicação Flutter web precisa de roteamento real para deep links e funcionamento do botão "voltar" do browser.

**Decisão**  
`go_router` com rota única `/` → `HospedagensPagina`. Estrutura preparada para expansão.

**Alternativas consideradas**
- `Navigator` 2.0 manual — verboso, sem benefício proporcional
- `auto_route` — geração de código para rotas, overhead desnecessário para app de tela única
- `fluro` — menos mantido, sem vantagem sobre `go_router`

**Consequências**
- (+) URLs funcionam no browser (deep link, refresh não perde a rota)
- (+) Adição de novas rotas é trivial
- (+) Mantido pelo time do Flutter
- (-) Configuração inicial mais complexa que `Navigator` 1.0 para apps simples

---

## ADR-008: Widgetbook como catálogo de componentes

**Status**: Aceito

**Contexto**  
Componentes do Design System precisam ser visualizados e testados isoladamente. A alternativa seria uma tela de "kitchen sink" no próprio app.

**Decisão**  
App separado em `widgetbook/` usando o package `widgetbook`. Cada componente tem `WidgetbookUseCase` com `knobs`.

**Alternativas consideradas**
- Tela de kitchen sink no app — simples, mas sem interatividade (knobs), sem organização por categoria
- Storybook (via Flutter Web embarcado) — não é o padrão Flutter

**Consequências**
- (+) Desenvolvimento de componentes isolado do app
- (+) Knobs permitem explorar props variáveis sem código
- (+) Organizado por categoria (botoes, cards, inputs, etc.)
- (+) Diferencial técnico no portfólio
- (-) App separado a manter (`pub get`, build separado)

---

## ADR-009: Infraestrutura pixel-perfect — auditoria e tokenização completa

**Status**: Aceito

**Contexto**  
Apesar do sistema de tokens já cobrir cores, espaçamentos, tipografia e sombras, uma auditoria identificou que várias categorias de valores permaneciam hardcoded nos componentes: tamanhos de ícone (14, 16, 18, 20, 64px), espessuras de borda (1.5, 2.0px), alturas de botão (48px), dimensões de spinner (20×20px), durações de animação (3s, 4s) e a propriedade `height` (line-height) ausente em todos os 15 `TextStyle`. Além disso, a fonte Roboto era referenciada por nome sem bundle, e o dialog de formulário tinha largura fixa de 480px sem responsividade.

**Decisão**  
Realizar uma auditoria sistemática e corrigir todas as fragilidades em 7 commits atômicos:

1. Adicionar `google_fonts` ao Design System e aplicar `GoogleFonts.robotoTextTheme()` no `DsTemaApp` para garantir Roboto em todas as plataformas.
2. Criar tokens `DsIcones`, `DsBordas`, `DsAnimacoes` e expandir `DsEspacamentos` com `DsAlturas`.
3. Adicionar `height` (line-height) em todos os 15 `TextStyle` de `DsTipografia`, seguindo spec Material Design 3.
4–6. Migrar todos os componentes para os novos tokens (botões, cards, inputs, seletores, feedback).
7. Tornar o `FormularioHospedagemDialog` responsivo e enforcar `maxWidthConteudo` no scaffold desktop.

**Alternativas consideradas**
- Corrigir caso a caso ao surgir — reactívo, mas permite que valores hardcoded se acumulem silenciosamente
- Usar `lint` customizado para bloquear literais numéricos em widgets — complexidade de configuração desproporcionalmente alta
- Bundlar fontes em `assets/fonts/` em vez de `google_fonts` — válido, mas `google_fonts` é mais simples para portfólio e permite atualizações automáticas

**Consequências**
- (+) Qualquer valor visível na tela tem origem rastreable em um token — mudar um token propaga para todos os componentes
- (+) Line-heights explícitos fazem a altura de blocos de texto bater com frames do Figma
- (+) Fonte Roboto garantida cross-platform (não depende de fonte do sistema)
- (+) Dialog responsivo funciona corretamente em mobile sem layout quebrado
- (+) Conteúdo desktop respeitado até 1440px de largura máxima
- (+) Checklist de novo componente atualizado: proíbe literais numéricos
- (-) Dependência de rede para `google_fonts` no primeiro carregamento (offline: fonte de sistema como fallback)

---

## ADR-010: Padrão Blueprint/Ser Humano para formulários

**Status**: Aceito

**Contexto**  
Formulários reativos (hospedagens, imoveis) precisavam gerenciar estado que pode estar incompleto, inválido ou em transição. A alternativa tradicional (state no widget) é frágil; state no store inteiro é acoplado e difícil de testar.

A questão central: onde vive o estado do formulário durante edição, e como garantir que nunca se persista dados inválidos?

**Decisão**  
Padrão **Blueprint/Ser Humano** em dois níveis:

1. **HospedagemFormState** (Equatable + imutável) — blueprint (bluepadrão pode estar incompleto)
   - Campos como `String` (aceita input inválido, ex: `numHospedes = "abc"`)
   - `Map<String, String> erros` — erros validação
   - `bool valido` — pode ser convertido em entidade?
   - `copyWith()` + `validate()` → nova instância com erros preenchidos
   - `toEntity(id)` — converte para `HospedagemEntity` ou falha com `StateError`

2. **HospedagemFormStore** (MobX) — orquestrador
   - `@observable HospedagemFormState formState` — único observable
   - `@action atualizarX(...)` — copyWith + validate
   - `@action salvar()` — toEntity + persistência via use case + tratamento de erro

3. **HospedagemEntity** (Domain) — Ser Humano (sempre válido)
   - Campos tipados corretamente (`int numHospedes`, `double valorTotal`, `StatusHospedagem status`)
   - Apenas entidades válidas podem existir no domínio

**Alternativas consideradas**

1. State no Widget + Provider — simples para forms simples, mas frágil: perder dados ao pop/push, sem reuso de lógica
2. Store com múltiplos @observables (`nomeHospede`, `numHospedes`, `validacoes`, ...) — reativo, mas explosão de observables; difícil sincronizar validações
3. Store com `ViewModel` imutável — similar ao blueprint, mas sem separação clara entre transitório (form) e persistível (entity)
4. JSON serialization direto — `toJson()`/`fromJson()` em Entity — mistura responsabilidades; Entity se torna bag of data
5. StatefulWidget autossuficiente com `autovalidateMode` — Flutter padrão, mas validação prematura, perda de dados no pop

**Consequências**

- (+) Garantia de tipo: impossível persistir `numHospedes = "abc"` ou `valido = true` com erros preenchidos
- (+) Imutabilidade: cada ação de usuário cria novo state → histórico perfeito para debugging, undo/redo futuro
- (+) Reatividade limpa: um único `@observable` simplifica; MobX não fica saturado
- (+) Testabilidade: `HospedagemFormState` é Equatable puro (29 testes sem mock); `HospedagemFormStore` mocka só HospedagemStore (34 testes com 100% cobertura)
- (+) Reutilização: `carregarParaEdicao()` + `iniciarNovoFormulario()` rápido; mesmo padrão em múltiplos formulários
- (+) UX: validação não é mostrada prematuramente (campo `sujo` controla); erro de submit aparece após tentar salvar
- (+) Portfólio: demonstra compreensão de padrões funcionais (imutabilidade, Either, validação bipolarizada)

- (-) Curva de aprendizado: desenvoltor acostumado com forms simples vê "over-engineering" inicial
- (-) Boilerplate: `copyWith()`, `validate()`, `toEntity()`, `fromEntity()` em cada form novo
- (-) Dependência de MobX + Equatable (mas aceito pois já usados em outros contextos)

---

## ADR-011: Gerenciamento de imagens com Isolate.run() para base64

**Status**: Planejado (Commit 10)

**Contexto**  
Hospedagens podem ter foto. Capturar da câmera ou galeria produz `Uint8List`. Encoding para base64 é CPU-bound (~10-50ms em imagens médias); bloqueia a UI thread.

**Decisão**  
Usar `Isolate.run(base64Encode)` em `Commit 10` para offload da encoding. Widget `DsImagemBase64` renderiza o base64 via `Image.memory(base64Decode(...))` com skeleton loading.

**Alternativas consideradas**
- `compute()` (flutter.foundation) — wrapper sobre Isolate, mais simples, mas menos controle
- Base64 síncrono com `Future.microtask()` — ainda bloqueia UI
- Enviar original `Uint8List` para backend — fora de escopo (sem backend real)

**Consequências**
- (+) Base64 encoding não trava UI
- (+) Demonstra concorrência em Dart/Flutter (portfolio)
- (+) Isolate.run() é o padrão moderno (1.5+ preferível a `compute()`)

- (-) Overhead de isolate para imagens pequeninhas (<1MB) é mínimo mas perceptível
- (-) Erro em isolate é mais verboso de debugar

---

## Relação com Documentação

Cada ADR tem documentação detalhada:
- **ADR-002** → `docs/SDUI.md` (engine SDUI, WidgetFactory)
- **ADR-010** → `docs/FORMULARIOS.md` (Blueprint/Ser Humano, ciclos de vida)
- **ADR-011** → `docs/PROCESSAMENTO_IMAGEM.md` (planejado)
