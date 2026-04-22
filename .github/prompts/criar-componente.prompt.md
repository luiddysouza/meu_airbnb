---
mode: agent
description: Cria um novo componente no Design System (packages/design_system/) seguindo os padrões do projeto.
---

Crie um novo componente no Design System do projeto `meu_airbnb` com o nome e especificações abaixo.

## Componente

**Nome**: [NOME_DO_COMPONENTE — ex: DsBadgeStatus]
**Categoria**: [botoes | cards | inputs | selectores | listas | feedback | layout]
**Descrição**: [o que o componente faz e quando usar]

## Propriedades

[Liste as propriedades do componente, ex:]
- `label` (String, obrigatório)
- `onTap` (VoidCallback?, opcional)
- `variante` (enum, ex: primario / secundario)

## Comportamento

[Descreva interações, estados (loading, disabled, error) e casos de borda]

---

## O que deve ser gerado

### 1. Widget (`packages/design_system/lib/componentes/<categoria>/ds_<nome>.dart`)

- Use apenas tokens do Design System (`DsCores`, `DsTipografia`, `DsEspacamentos`, `DsSombras`).
- Nunca use valores hardcoded de cor, tamanho ou fonte.
- Prefixo `Ds` obrigatório no nome da classe.
- Adicione `const` no construtor quando possível.
- Exporte no barrel `packages/design_system/lib/design_system.dart`.

### 2. Entrada no Widgetbook (`widgetbook/lib/componentes/<categoria>/ds_<nome>_usecase.dart`)

- Crie um `WidgetbookUseCase` com knobs para todas as propriedades variáveis.
- Registre no catálogo do Widgetbook (`widgetbook/lib/main.dart`).

### 3. Teste unitário (`packages/design_system/test/componentes/<categoria>/ds_<nome>_test.dart`)

- **Padrão**: AAA (Arrange / Act / Assert).
- Testes obrigatórios:
  - Renderiza sem erros com propriedades mínimas.
  - Renderiza sem erros com todas as propriedades preenchidas.
  - Callback `onTap` (ou similar) é disparado ao interagir.
  - Variantes visuais (se houver enum de variante) renderizam sem erros.

---

## Referências do projeto

- Tokens: `packages/design_system/lib/tokens/`
- Componentes existentes: `packages/design_system/lib/componentes/`
- Convenção de nomes: português, prefixo `Ds`
