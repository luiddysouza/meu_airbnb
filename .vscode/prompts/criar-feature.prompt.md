---
mode: agent
description: Cria uma feature completa seguindo Clean Architecture — entidade, use cases, datasource, repositório, store MobX e integração SDUI.
---

Crie uma nova feature completa no projeto `meu_airbnb` seguindo Clean Architecture com SDUI e MobX.

## Feature

**Nome**: [NOME_DA_FEATURE — ex: Imovel, Relatorio]
**Descrição**: [o que a feature faz]
**Entidade principal**: [campos e tipos]

---

## O que deve ser gerado

### 1. Domain — Entidade (`lib/features/<feature>/dominio/entidades/<nome>_entidade.dart`)

- Extende `Equatable`.
- Implementa `copyWith`.
- Inclui todos os campos descritos acima.
- Zero dependências externas (apenas `equatable` e `fpdart` são permitidos no domain).

### 2. Domain — Contrato de Repositório (`lib/features/<feature>/dominio/repositorios/<nome>_repositorio.dart`)

- Classe abstrata.
- Todos os métodos retornam `Future<Either<Falha, T>>`.
- Métodos padrão: `obterTodos`, `obterPorId`, `adicionar`, `atualizar`, `deletar`.

### 3. Domain — Use Cases (`lib/features/<feature>/dominio/usecases/`)

- Um arquivo por use case.
- Cada use case implementa `UseCase<Output, Params>`.
- Retorna `Future<Either<Falha, T>>` — nunca lança exceções.
- Crie: `ObterTodos<Feature>`, `Adicionar<Feature>`, `Atualizar<Feature>`, `Deletar<Feature>`.

### 4. Data — Modelo (`lib/features/<feature>/data/modelos/<nome>_modelo.dart`)

- Usa `json_serializable` (`@JsonSerializable()`).
- Implementa `fromEntity(entidade)` e `toEntity()`.
- Implementa `fromJson` e `toJson`.

### 5. Data — DataSource (`lib/features/<feature>/data/datasources/<nome>_local_datasource.dart`)

- Carrega dados de `assets/mock/<nome>s.json` no método `init()`.
- Mantém cópia mutável em memória (`List<Modelo>`).
- Cada operação CRUD simula latência com `Future.delayed(Duration(milliseconds: X))`.
- Lança exceções em caso de erro (o repositório as captura e converte).
- Assets são **read-only** — nunca tente escrever em `assets/`.

### 6. Data — Repositório Impl (`lib/features/<feature>/data/repositorios/<nome>_repositorio_impl.dart`)

- Implementa o contrato do domain.
- Cada método faz `try/catch`: sucesso → `Right(valor)`, exceção → `Left(FalhaCache(mensagem))`.
- Converte modelos ↔ entidades via `fromEntity`/`toEntity`.

### 7. Presentation — Store MobX (`lib/features/<feature>/apresentacao/stores/<nome>_store.dart`)

Siga o padrão obrigatório de **Optimistic State**:

```
1. Salva snapshot do estado atual
2. Atualiza a lista imediatamente (Observer reflete na UI)
3. Chama o use case
4a. Right → descarta snapshot
4b. Left  → restaura snapshot + seta erro
```

Observables obrigatórios:
- `@observable ObservableList<Entidade> itens`
- `@observable bool carregando`
- `@observable String? erro`

Actions obrigatórias:
- `@action carregarTodos()`
- `@action adicionar(entidade)` — com optimistic state
- `@action atualizar(entidade)` — com optimistic state
- `@action deletar(id)` — com optimistic state

### 8. DI — Registro (`lib/core/di/injecao.dart`)

- Adicione os registros na ordem correta: DataSource → RepositorioImpl → UseCases → Store.
- Nunca instanciar dependências fora do `injecao.dart`.

### 9. Mock JSON (`assets/mock/<nome>s.json`)

- 5–8 registros fictícios e realistas.
- Todos os campos obrigatórios preenchidos.
- IDs no formato UUID v4.

### 10. Testes unitários

**Use cases** (`test/features/<feature>/dominio/usecases/`):
- Gere com `@GenerateMocks([<Nome>Repositorio])`.
- Teste sucesso → `Right(valor)` e falha → `Left(Falha)`.

**Repository impl** (`test/features/<feature>/data/repositorios/`):
- Mock do datasource.
- Teste: sucesso retorna `Right`, exceção retorna `Left(FalhaCache)`.

**Store MobX** (`test/features/<feature>/apresentacao/stores/`):
- Use `reaction()` para capturar mudanças de observables.
- Teste: carregamento popula lista, optimistic update reflete antes de confirmar, rollback restaura estado em falha.

---

## Referências do projeto

- Padrão de erros: `lib/core/erros/falhas.dart`
- Contrato UseCase: `lib/core/usecases/usecase.dart`
- Feature existente para referência: `lib/features/hospedagens/`
- Convenção: português em tudo (classes, métodos, variáveis, arquivos)
