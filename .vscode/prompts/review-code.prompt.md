---
mode: agent
description: Revisa código do projeto meu_airbnb verificando arquitetura, testes, SDUI compliance, Either usage, optimistic pattern e responsividade.
---

Revise o código abaixo (ou o arquivo atualmente aberto) contra os padrões do projeto `meu_airbnb`.

## Código a revisar

[Cole aqui o código ou o diff a ser revisado — ou referencie o arquivo aberto]

---

## Checklist de Review

### Arquitetura (Clean Architecture)

- [ ] Domain não importa pacotes externos além de `equatable` e `fpdart`.
- [ ] Use cases não chamam datasources diretamente — apenas repositórios.
- [ ] Stores MobX não chamam datasources diretamente — apenas use cases.
- [ ] SDUI renderer não conhece as stores — injeção ocorre no `WidgetFactory`.
- [ ] Componentes visuais estão em `packages/design_system/`, não em `lib/core/` ou `lib/features/`.
- [ ] Nenhuma dependência de camada superior em camada inferior (ex: Data importando Presentation).

### Tratamento de Erros (fpdart Either)

- [ ] Use cases retornam `Future<Either<Falha, T>>` — nunca lançam exceções.
- [ ] Repository impl usa `try/catch` e converte exceções em `Left(FalhaCache(...))`.
- [ ] Stores MobX fazem `fold()` no resultado: `Left` → rollback + erro, `Right` → confirma.
- [ ] Não há `try/catch` em use cases (exceções são do domínio do repositório).

### Optimistic State Pattern

- [ ] Ação salva snapshot antes de modificar o estado.
- [ ] Lista é atualizada imediatamente (antes de chamar o use case).
- [ ] Em caso de `Left` (falha), o snapshot é restaurado.
- [ ] Em caso de `Left`, o campo `erro` é preenchido e o snackbar é exibido.
- [ ] Em caso de `Right` (sucesso), o snapshot é descartado.

### SDUI Compliance

- [ ] Novo tipo SDUI está registrado no `WidgetFactory`.
- [ ] Novo tipo SDUI está documentado em `docs/SDUI.md`.
- [ ] Widgets de estrutura/layout vêm puramente do SDUI (sem lógica de negócio).
- [ ] Widgets de dados são envolvidos em `Observer` do flutter_mobx.
- [ ] `WidgetFactory` injeta stores via `get_it` (não recebe stores como parâmetro no construtor).

### MobX Stores

- [ ] Todos os observables têm `@observable`.
- [ ] Todos os métodos que modificam observables têm `@action`.
- [ ] Computed values usam `@computed` (não recalculam manualmente).
- [ ] `ObservableList` é usado para listas (não `List` comum).
- [ ] Arquivo `.g.dart` está sendo gerado por `build_runner`.

### Cubit (SDUI Engine)

- [ ] `SduiCubit` gerencia apenas estados da engine SDUI (`SduiInicial`, `SduiCarregando`, `SduiSucesso`, `SduiErro`).
- [ ] `SduiCubit` não acessa dados de negócio diretamente.
- [ ] Estados Cubit são imutáveis e extendem `SduiEstado`.

### Design System

- [ ] Todo componente tem prefixo `Ds`.
- [ ] Usa apenas tokens (`DsCores`, `DsTipografia`, `DsEspacamentos`, `DsSombras`) — sem valores hardcoded.
- [ ] Novo componente tem entrada no Widgetbook.
- [ ] Novo componente tem teste unitário.

### Responsividade

- [ ] Usa `LayoutBuilder` nativo — sem pacotes de responsividade externos.
- [ ] Breakpoints referenciados via tokens (`DsEspacamentos.breakpointMobile`, etc.).
- [ ] Layout web (≥ 900px): sidebar + área principal.
- [ ] Layout mobile (< 900px): coluna única.

### Testes

- [ ] Padrão AAA (Arrange / Act / Assert) em todos os testes.
- [ ] Mocks gerados com `@GenerateMocks([...])` do mockito.
- [ ] Testes de use case verificam `Right` em sucesso e `Left(Falha)` em erro.
- [ ] Testes de store usam `reaction()` para capturar mudanças de observables.
- [ ] Testes de Cubit usam `bloc_test`.
- [ ] Cobertura mínima de 80% nas camadas testadas.

### Convenções de Nomeação

- [ ] Todo o código está em **português** (classes, métodos, variáveis, arquivos, parâmetros).
- [ ] Entidades terminam em `Entidade` (ex: `HospedagemEntidade`).
- [ ] Modelos terminam em `Modelo` (ex: `HospedagemModelo`).
- [ ] Use cases com verbo no infinitivo (ex: `ObterHospedagens`, `AdicionarHospedagem`).
- [ ] Stores terminam em `Store` (ex: `HospedagemStore`).

### Injeção de Dependências

- [ ] Nenhuma dependência instanciada diretamente em páginas ou stores.
- [ ] Todos os registros estão em `lib/core/di/injecao.dart`.
- [ ] Ordem de registro respeitada: DataSource → RepositorioImpl → UseCases → Stores → SduiCubit.

### Geral

- [ ] `flutter analyze` passaria sem warnings.
- [ ] Sem `print()` ou `debugPrint()` em código de produção.
- [ ] Assets `assets/mock/` não são escritos em runtime (apenas leitura na inicialização).

---

## Formato da resposta

Para cada item com problema, indique:
1. **Item do checklist** que falhou.
2. **Localização** (arquivo + linha, se possível).
3. **Problema** descrito em uma frase.
4. **Correção sugerida** com o código correto.
