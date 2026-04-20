---
mode: agent
description: Gera o JSON SDUI para uma nova tela usando os tipos já registrados no WidgetFactory do projeto meu_airbnb.
---

Gere o JSON SDUI para a tela descrita abaixo, usando **apenas** os tipos registrados no `WidgetFactory` do projeto `meu_airbnb`.

## Tela

**Nome da tela**: [ex: relatorios, imoveis, detalhes_hospedagem]
**Descrição**: [o que a tela exibe e o que o usuário pode fazer]
**Layout**: [descreva a estrutura visual — ex: filtros no topo, lista centralizada, botão de ação no rodapé]

---

## Tipos disponíveis no WidgetFactory

Use **somente** os tipos abaixo. Não invente tipos novos.

| Tipo SDUI | Componente DS | Dados reativos? | Notas |
|---|---|---|---|
| `seletor_data_range` | `DsDateRangePicker` | Não | Dispara ação `filtrar_por_data` |
| `dropdown` | `DsDropdown` | Sim (`imovelStore`) | Dispara ação `filtrar_por_imovel` |
| `lista` | `DsLista` + `Observer` | Sim | Usa `dados_source` para indicar a fonte reativa |
| `card_hospedagem` | `DsCardHospedagem` | Sim | Item individual da lista |
| `botao_primario` | `DsBotaoPrimario` | Não | Dispara ações customizadas via `acao` |
| `estado_vazio` | `DsEstadoVazio` | Não | Exibido quando lista está vazia |
| `carregando` | `DsCarregando` | Não | Exibido durante carregamento |

Se a tela exigir um tipo novo, **não crie** — liste ao final quais tipos precisariam ser adicionados ao `WidgetFactory` e ao `docs/SDUI.md`.

---

## Schema de um nó SDUI

```json
{
  "tipo": "nome_do_componente",
  "propriedades": {},
  "filhos": [],
  "acao": {
    "tipo": "nome_da_acao",
    "payload": {}
  }
}
```

- `tipo` (obrigatório): string com o nome do tipo registrado no `WidgetFactory`.
- `propriedades` (opcional): chaves e valores específicos do componente (labels, opções, etc.).
- `filhos` (opcional): lista de nós filhos para componentes container.
- `acao` (opcional): ação disparada pelo componente (`tipo` + `payload` opcionais).

---

## Saída esperada

### 1. Arquivo JSON

Caminho sugerido: `assets/mock/tela_<nome>.json`

```json
{
  "tela": "<nome>",
  "componentes": [
    // árvore de nós gerada aqui
  ]
}
```

### 2. Registro no WidgetFactory (se necessário)

Se a tela exigir tipos novos, liste:
- Nome do tipo SDUI.
- Componente do Design System correspondente (ou a ser criado).
- Se haverá dados reativos (MobX).
- Builder a adicionar em `lib/core/sdui/fabrica/widget_factory.dart`.

### 3. Atualização do docs/SDUI.md

Tabela atualizada com os novos tipos, para incluir em `docs/SDUI.md`.

---

## Referências do projeto

- JSON existente: `assets/mock/tela_hospedagens.json`
- WidgetFactory: `lib/core/sdui/fabrica/widget_factory.dart`
- Documentação SDUI: `docs/SDUI.md`
