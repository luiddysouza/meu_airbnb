# Design System — meu_airbnb

## O que é um Design System?

Um Design System é um conjunto de **padrões, regras e componentes reutilizáveis** que formam a linguagem visual de um produto. Ele não é apenas uma coleção de widgets bonitos — é um **contrato** entre design e código que garante consistência visual, reduz retrabalho e acelera o desenvolvimento.

A analogia mais direta é a de uma **fábrica de peças padronizadas**: em vez de cada desenvolvedor construir seu próprio botão, campo de texto ou card, todos usam as mesmas peças, que foram projetadas, testadas e catalogadas previamente. Quando uma peça precisa mudar — por exemplo, o raio de borda de todos os botões — a mudança acontece **em um único lugar** e se propaga para todo o produto.

### Por que isolar em um package separado?

No `meu_airbnb`, o Design System vive em `packages/design_system/`, um **package Dart independente** do app principal. Isso traz três benefícios concretos:

1. **Separação de responsabilidades** — O app principal (`lib/`) não precisa conhecer cores hexadecimais, tamanhos de fonte ou espaçamentos. Ele importa `package:design_system/design_system.dart` e usa componentes prontos.
2. **Reutilização** — Se amanhã o autor criar outro app (ex: um painel administrativo), pode reaproveitar o mesmo Design System sem copiar código.
3. **Testabilidade** — Cada componente é testado isoladamente, sem depender de stores, use cases ou infraestrutura do app.

---

## Tokens: o vocabulário do Design System

### O que são tokens?

O termo **token** vem da indústria de Design Systems (popularizado por ferramentas como Figma, Style Dictionary e Material Design). Um token é a **menor unidade de decisão visual** — um valor atômico que representa uma escolha de design.

Em vez de espalhar `Color(0xFFFF5A5F)` por 30 arquivos, você define **uma vez**:

```dart
static const Color primaria = Color(0xFFFF5A5F);
```

E referencia por nome: `DsCores.primaria`. O nome "token" existe porque esses valores funcionam como **fichas de um vocabulário compartilhado** entre designers e desenvolvedores. Quando um designer diz "use a cor primária", o desenvolvedor sabe exatamente qual constante usar. O valor concreto (hex, px, font-weight) pode mudar sem que nenhum componente precise ser reescrito.

### Por que não usar direto o ThemeData do Flutter?

O `ThemeData` do Flutter é poderoso, mas genérico. Ele não tem campos para "cor de status confirmada", "espaçamento entre cards" ou "sombra nível 2". Tokens preenchem essa lacuna — são **extensões semânticas** que dão significado ao design do produto.

No `meu_airbnb`, o `ThemeData` é montado **a partir dos tokens** (em `tema_app.dart`), mas os componentes referenciam diretamente os tokens para clareza.

### Categorias de tokens neste projeto

| Categoria | Classe | O que define | Exemplo |
|---|---|---|---------|
| **Cores** | `DsCores` | Paleta completa: primária, secundária, neutras, semânticas, status | `DsCores.primaria`, `DsCores.erro` |
| **Tipografia** | `DsTipografia` | Escala tipográfica M3 (display → label) com `fontSize`, `fontWeight`, `letterSpacing` e `height` (line-height) | `DsTipografia.titleMedium`, `DsTipografia.bodySmall` |
| **Espaçamentos e Alturas** | `DsEspacamentos`, `DsAlturas` | Escala de espaçamento (múltiplos de 4), breakpoints, border radius, alturas de componentes | `DsEspacamentos.md` (16), `DsAlturas.botaoPadrao` (48) |
| **Sombras** | `DsSombras` | Níveis de elevação como `List<BoxShadow>` | `DsSombras.nivel1`, `DsSombras.nivel2` |
| **Ícones** | `DsIcones` | Escala de tamanhos de ícones (xs → xl) | `DsIcones.md` (18), `DsIcones.xl` (64) |
| **Bordas** | `DsBordas` | Espessuras de borda e stroke de progress indicator | `DsBordas.fina` (1.5), `DsBordas.media` (2.0) |
| **Animações** | `DsAnimacoes` | Durações padrão de animações de UI | `DsAnimacoes.snackbarCurta` (3s), `DsAnimacoes.snackbarLonga` (4s) |

### Anatomia de um arquivo de token

Todos os tokens seguem o mesmo padrão:

```dart
// packages/design_system/lib/tokens/cores.dart
import 'package:flutter/material.dart';

abstract final class DsCores {
  static const Color primaria = Color(0xFFFF5A5F);
  static const Color erro     = Color(0xFFD93025);
  // ...
}
```

- **`abstract final class`** — Não pode ser instanciada nem estendida. Funciona como namespace puro.
- **`static const`** — Valores definidos em tempo de compilação. Zero custo em runtime.
- **Sem dependência externa** — Tokens só importam `package:flutter/material.dart`.

### Escala de espaçamentos e a regra dos múltiplos de 4

A escala de espaçamentos segue a convenção **4-point grid**, amplamente adotada em Design Systems (Material, Ant, Carbon):

```
xxs = 4 | xs = 8 | sm = 12 | md = 16 | lg = 24 | xl = 32 | xxl = 48 | xxxl = 64
```

A ideia é que todos os espaçamentos são múltiplos de 4 (com exceção de `sm = 12`, que é 3×4 para cobrir o meio-termo). Isso garante alinhamento visual consistente em qualquer combinação de paddings e margins.

### Line-height na escala tipográfica

Todos os 15 `TextStyle` em `DsTipografia` incluem a propriedade `height` (multiplicador de line-height = lineHeight ÷ fontSize), seguindo a especificação do **Material Design 3**:

| Categoria | Exemplo | fontSize | lineHeight | height |
|---|---|---|---|---|
| Display | `displayLarge` | 57px | 64px | 1.12 |
| Headline | `headlineLarge` | 32px | 40px | 1.25 |
| Title | `titleMedium` | 16px | 24px | 1.50 |
| Body | `bodyMedium` | 14px | 20px | 1.43 |
| Label | `labelSmall` | 11px | 16px | 1.45 |

Isso é essencial para pixel-perfect: Figma sempre especifica line-height, e sem a propriedade `height` no Flutter a altura dos blocos de texto não bate com os frames do Figma.

---

## Componentes: peças montadas com tokens

### Convenções

1. **Prefixo `Ds`** — Todo componente público do Design System começa com `Ds` (ex: `DsBotaoPrimario`, `DsCardHospedagem`). Isso evita colisão com widgets do Flutter (`TextField` vs `DsTextField`) e deixa claro que o componente pertence ao Design System.

2. **Nenhum valor hardcoded** — Componentes nunca usam `Color(0xFF...)`, `16.0` ou `'Roboto'` diretamente. Sempre referenciam tokens: `DsCores.primaria`, `DsEspacamentos.md`, `DsTipografia.labelLarge`, `DsIcones.md`, `DsBordas.fina`, `DsAnimacoes.snackbarCurta`.

3. **Construtor `const`** — Sempre que possível, construtores são `const` para permitir otimização em árvores de widgets.

4. **Parâmetros em português** — Seguindo a convenção do projeto: `rotulo`, `aoTocar`, `carregando`, `aoLimpar`, não `label`, `onTap`, `loading`, `onClear`.

### Parâmetro `aoLimpar` nos seletores

`DsDateRangePicker` e `DsDropdown` aceitam o parâmetro opcional `aoLimpar: VoidCallback?`. Quando fornecido e há um valor selecionado, o componente exibe um ícone de fechar (X) que, ao ser tocado, chama o callback para limpar o filtro.

```dart
DsDateRangePicker(
  rotuloInicio: 'Check-in',
  rotuloFim: 'Check-out',
  periodoSelecionado: filtroStore.periodoSelecionado,
  aoSelecionar: filtroStore.selecionarPeriodo,
  aoLimpar: () => filtroStore.selecionarPeriodo(null), // botão X aparecerá
)

DsDropdown(
  rotulo: 'Imóvel',
  opcoes: opcoes,
  valorSelecionado: filtroStore.imovelSelecionadoId,
  aoSelecionar: filtroStore.selecionarImovel,
  aoLimpar: () => filtroStore.selecionarImovel(null),  // botão X aparecerá
)
```

> `DsDropdown` usa `key: ValueKey(valorSelecionado)` internamente para forçar rebuild reativo quando o valor é zerado externamente.

### Estrutura de pastas dos componentes

```
packages/design_system/lib/componentes/
├── botoes/        DsBotaoPrimario, DsBotaoSecundario, DsBotaoIcone
├── cards/         DsCardHospedagem
├── inputs/        DsTextField
├── selectores/    DsDateRangePicker, DsDropdown
├── listas/        DsListTile
├── feedback/      DsEstadoVazio, DsCarregando, DsSnackbar
└── layout/        DsScaffoldResponsivo, DsAppBarAdaptativa
```

### Anatomia de um componente

Usando o `DsBotaoPrimario` como exemplo:

```dart
// 1. Imports — apenas Flutter + tokens do próprio DS
import 'package:flutter/material.dart';
import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/tipografia.dart';

// 2. Classe — StatelessWidget com const constructor
class DsBotaoPrimario extends StatelessWidget {
  const DsBotaoPrimario({
    super.key,
    required this.rotulo,     // parâmetros obrigatórios primeiro
    this.aoTocar,             // callback nulável = botão desabilitável
    this.carregando = false,  // estado de loading
    this.icone,               // ícone opcional
  });

  // 3. Campos — declarados após o construtor, todos final
  final String rotulo;
  final VoidCallback? aoTocar;
  final bool carregando;
  final IconData? icone;

  // 4. Build — usa tokens, nunca valores literais
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: carregando ? null : aoTocar,
      style: ElevatedButton.styleFrom(
        backgroundColor: DsCores.primaria,              // ← token de cor
        foregroundColor: DsCores.branco,                // ← token de cor
        padding: const EdgeInsets.symmetric(
          horizontal: DsEspacamentos.lg,               // ← token de espaçamento
          vertical: DsEspacamentos.md,                 // ← token de espaçamento
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(DsEspacamentos.radiusMd),  // ← token de radius
          ),
        ),
        textStyle: DsTipografia.labelLarge,            // ← token de tipografia
        minimumSize: const Size(0, DsAlturas.botaoPadrao), // ← token de altura
      ),
      child: _buildFilho(),
    );
  }

  // 5. Métodos privados — renderização condicional
  Widget _buildFilho() {
    if (carregando) {
      return const SizedBox.square(
        dimension: DsAlturas.spinnerBotao,              // ← token de altura
        child: CircularProgressIndicator(
          strokeWidth: DsBordas.progressIndicator,      // ← token de borda
          valueColor: AlwaysStoppedAnimation<Color>(DsCores.branco),
        ),
      );
    }
    if (icone != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: DsIcones.md),               // ← token de ícone
          const SizedBox(width: DsEspacamentos.xs),
          Text(rotulo),
        ],
      );
    }
    return Text(rotulo);
  }
}
```

**Pontos-chave:**
- O componente **não sabe** qual tela vai usá-lo. Ele recebe dados por parâmetro e dispara callbacks.
- O estado de `carregando` desabilita o botão e troca o conteúdo por um spinner — sem que a tela precise gerenciar isso.
- Todo valor visual vem de um token. Se amanhã o raio de borda mudar de 12 para 16, basta alterar `DsEspacamentos.radiusMd`.

---

## Como criar um novo componente

### Passo a passo

**1. Crie o arquivo do widget em `packages/design_system/lib/componentes/<categoria>/`**

```dart
// packages/design_system/lib/componentes/feedback/ds_alerta.dart
import 'package:flutter/material.dart';
import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/tipografia.dart';

class DsAlerta extends StatelessWidget {
  const DsAlerta({
    super.key,
    required this.mensagem,
    this.tipo = TipoAlerta.info,
    this.aoDismissar,
  });

  final String mensagem;
  final TipoAlerta tipo;
  final VoidCallback? aoDismissar;

  Color get _cor {
    switch (tipo) {
      case TipoAlerta.sucesso: return DsCores.sucesso;
      case TipoAlerta.erro:    return DsCores.erro;
      case TipoAlerta.alerta:  return DsCores.alerta;
      case TipoAlerta.info:    return DsCores.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DsEspacamentos.md),
      decoration: BoxDecoration(
        color: _cor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(
          Radius.circular(DsEspacamentos.radiusSm),
        ),
        border: Border.all(color: _cor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(mensagem, style: DsTipografia.bodyMedium),
          ),
          if (aoDismissar != null)
            IconButton(
              onPressed: aoDismissar,
              icon: const Icon(Icons.close, size: 18),
            ),
        ],
      ),
    );
  }
}

enum TipoAlerta { sucesso, erro, alerta, info }
```

**2. Exporte no barrel (`design_system.dart`)**

```dart
export 'componentes/feedback/ds_alerta.dart';
```

**3. Crie o teste unitário**

```dart
// packages/design_system/test/componentes/feedback/ds_alerta_test.dart
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsAlerta', () {
    testWidgets('renderiza mensagem', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: DsAlerta(mensagem: 'Atenção!')),
      ));
      expect(find.text('Atenção!'), findsOneWidget);
    });

    testWidgets('dispara aoDismissar', (tester) async {
      var disparado = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DsAlerta(
            mensagem: 'Erro',
            tipo: TipoAlerta.erro,
            aoDismissar: () => disparado = true,
          ),
        ),
      ));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(disparado, isTrue);
    });
  });
}
```

**4. Adicione ao Widgetbook**

```dart
// widgetbook/lib/catalogos/exibicao.dart (ou novo arquivo)
WidgetbookComponent(
  name: 'DsAlerta',
  useCases: [
    WidgetbookUseCase(
      name: 'Info',
      builder: (context) => const DsAlerta(mensagem: 'Informação importante'),
    ),
    WidgetbookUseCase(
      name: 'Erro',
      builder: (context) => const DsAlerta(
        mensagem: 'Algo deu errado',
        tipo: TipoAlerta.erro,
      ),
    ),
  ],
),
```

**5. Valide**

```bash
cd packages/design_system && dart analyze && flutter test
```

### Checklist para cada novo componente

- [ ] Widget criado em `componentes/<categoria>/ds_<nome>.dart`
- [ ] Usa **apenas tokens** (nunca valores hardcoded — nem `size: 18`, `width: 2`, `Duration(seconds: 3)`, `height: 48`)
- [ ] Prefixo `Ds` no nome da classe
- [ ] Construtor `const` quando possível
- [ ] Parâmetros nomeados em português
- [ ] Export adicionado no barrel `design_system.dart`

---

## Pixel-Perfect e integração com Figma

### O que é pixel-perfect?

Pixel-perfect significa que o layout implementado em código reproduz exatamente o que foi desenhado no Figma: mesmos espaçamentos, alturas, tamanhos de fonte, line-heights, espessuras de borda e comportamento responsivo. Para isso ser possível, **cada valor visível na tela deve vir de um token** — não de um literal número escondido dentro de um widget.

### Auditoria realizada

O projeto passou por uma auditoria completa de pixel-perfect. Os problemas encontrados e corrigidos foram organizados em 7 commits:

| Commit | O que foi feito |
|---|---|
| `chore(ds): google_fonts e Roboto via tema` | `fontFamily: 'Roboto'` existia no código mas sem bundle. Adicionado `google_fonts` ao DS e `GoogleFonts.robotoTextTheme()` no `DsTemaApp`. Em iOS e Web sem CDN, sem isso a fonte cai para o sistema operacional (SF Pro, system-ui), quebrando qualquer comparação com Figma. |
| `feat(ds/tokens): tokens de ícone, borda, altura e animação` | Criados `DsIcones`, `DsBordas`, `DsAnimacoes` e `DsAlturas` para cobrir as é categorias que faltavam. Antes, valores como `size: 14`, `width: 1.5`, `height: 20` e `Duration(seconds: 3)` estavam espalhados em 13+ locais. |
| `feat(ds/tokens): line-height na escala tipográfica` | Adicionada a propriedade `height` em todos os 15 `TextStyle`. Sem line-height, a altura de blocos de texto no Flutter não bate com os frames do Figma. |
| `refactor(ds/botoes): hardcoded → tokens` | `DsBotaoPrimario`, `DsBotaoSecundario` e `DsBotaoIcone` migrados. Altura 48, spinner 20×20, strokeWidth 2 e icon 18 agora vêm de tokens. |
| `refactor(ds/cards-inputs-seletores): hardcoded → tokens` | `DsCardHospedagem`, `DsTextField`, `DsDropdown` e `DsDateRangePicker` migrados. |
| `refactor(ds/feedback): hardcoded → tokens` | `DsEstadoVazio` (icon 64) e `DsSnackbar` (icon 20, durações) migrados. |
| `fix(app): dialog responsivo + maxWidthConteudo no scaffold` | `FormularioHospedagemDialog` tinha `width: 480` fixo — agora é responsivo (480px em desktop, largura da tela − padding em mobile). `DsScaffoldResponsivo` passou a enforcar `DsEspacamentos.maxWidthConteudo` (1440px) em telas ultra-wide. |

### Regra pós-auditoria

Todo valor novo deve vir de um token existente. Se não houver token adequado, **crie um token antes de criar o componente**. Nunca introduza um literal numérico diretamente em um widget.

```dart
// ❌ Errado
Icon(Icons.edit, size: 20)
SizedBox(height: 48)
BorderSide(width: 1.5)
Duration(seconds: 3)

// ✅ Correto
Icon(Icons.edit, size: DsIcones.lg)
SizedBox(height: DsAlturas.botaoPadrao)
BorderSide(width: DsBordas.fina)
DsAnimacoes.snackbarCurta
```

### Como importar um Figma

Com o sistema de tokens completo, o fluxo de importação de um Figma é:

1. **Mapeie os valores do Figma para tokens existentes.** Ex: o Figma usa `line-height: 24` para textos de `16px` → `DsTipografia.bodyLarge` já tem `height: 1.50`.
2. **Para valores não cobertos, atualize o token.** Ex: se o Figma usa `line-height: 22` para `bodyLarge`, atualize `height` em `DsTipografia.bodyLarge` — todos os componentes que o usam são atualizados automaticamente.
3. **Verifique breakpoints.** `DsEspacamentos.breakpointTablet = 900` e `breakpointMobile = 600` devem corresponder aos breakpoints definidos no Figma.
4. **Valide no Widgetbook.** Cada componente tem entrada no Widgetbook — use-o para comparar visualmente com os frames do Figma antes de integrar nas telas.
- [ ] Teste unitário com padrão AAA (Arrange / Act / Assert)
- [ ] Entrada no Widgetbook com pelo menos 2 use cases
- [ ] `dart analyze` sem issues

---

## Tema: a ponte entre tokens e Material Design

O arquivo `tema_app.dart` monta o `ThemeData` do Flutter **a partir dos tokens**:

```dart
static ThemeData get tema => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: DsCores.primaria,    // ← token alimenta o M3
    // ...
  ),
  textTheme: TextTheme(
    titleLarge: DsTipografia.titleLarge,  // ← tokens de tipografia
    bodyMedium: DsTipografia.bodyMedium,
    // ...
  ),
  extensions: [const DsTemaExtensao()],  // ← extensão para tokens extras
);
```

E `DsTemaExtensao` carrega valores que o `ThemeData` padrão não suporta — como cores de status de hospedagem. Isso permite acessar via `Theme.of(context).extension<DsTemaExtensao>()` quando necessário, mas os componentes do DS já referenciam os tokens diretamente.

---

## Widgetbook: o catálogo vivo

O Widgetbook (em `widgetbook/`) é um app Flutter separado que renderiza cada componente do Design System em isolamento, com knobs interativos para alterar propriedades em tempo real.

Ele serve a três propósitos:

1. **Documentação visual** — Qualquer pessoa pode rodar `cd widgetbook && flutter run -d chrome` e ver todos os componentes disponíveis, sem precisar navegar pelo app principal.
2. **Teste visual** — Validar que os componentes se comportam corretamente em diferentes estados (carregando, desabilitado, com/sem dados).
3. **Portfólio** — Demonstra maturidade profissional: o desenvolvedor não apenas cria componentes, mas os organiza e cataloga.

---

## Resumo da hierarquia

```
Tokens (valores atômicos)
  └── definem → Tema (ThemeData + extensões)
  └── alimentam → Componentes (widgets reutilizáveis)
                    └── catalogados no → Widgetbook (catálogo visual)
                    └── consumidos pelo → App (páginas e features)
```

Cada camada depende apenas da anterior. Se uma cor muda no token, o tema se atualiza, todos os componentes que usam aquela cor mudam, e o Widgetbook reflete a mudança automaticamente. O app principal não precisa ser alterado.
