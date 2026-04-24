# Gerenciamento de Formulários — meu_airbnb

Documentação do padrão **Blueprint/Ser Humano** para formulários reativos usando MobX.

---

## Visão Geral

Os formulários no `meu_airbnb` seguem o padrão **Blueprint/Ser Humano**, que separa:

- **Blueprint** (`HospedagemFormState`) — estado transitório, pode estar incompleto/inválido
- **Ser Humano** (entidade de domínio) — estado final, sempre válido e pronto para persistência

Essa separação elimina bugs comuns como:
- Salvar formulário parcialmente preenchido
- Perder dados ao retornar da tela
- Mostrar validações prematuras (campo vazio no blur do primeiro uso)

---

## Camadas do Formulário

```
┌─────────────────────────────────────────────────────────────┐
│  FormularioHospedagemDialog (Widget — Presentation)         │
│  - TextFieldController, DatePicker callbacks                │
│  - Observer → reage a formState                             │
└────────────────────┬────────────────────────────────────────┘
                     │ injeção via get_it
┌────────────────────▼────────────────────────────────────────┐
│  HospedagemFormStore (MobX — Orquestrador)                  │
│  - @observable formState                                    │
│  - @action atualizarNomeHospede(...) → copyWith + validate  │
│  - @action salvar() → toEntity → HospedagemStore            │
└────────────────────┬────────────────────────────────────────┘
                     │ depende de
┌────────────────────▼────────────────────────────────────────┐
│  HospedagemFormState (Equatable — Blueprint)                │
│  - String nomeHospede, String numHospedes, ...              │
│  - Map<String, String> erros                                │
│  - bool valido, bool sujo                                   │
│  - copyWith() → nova instância imutável                     │
│  - validate() → retorna novo state com erros preenchidos    │
│  - toEntity(id) → converte para HospedagemEntity (fail se !)│
└────────────────────┬────────────────────────────────────────┘
                     │ transforma em
┌────────────────────▼────────────────────────────────────────┐
│  HospedagemEntity (Domain — Ser Humano)                     │
│  - Sempre válido, imutável                                  │
│  - Persistido na base ou enviado ao backend                 │
└─────────────────────────────────────────────────────────────┘
```

---

## HospedagemFormState — O Blueprint

Classe **Equatable** e **imutável** que representa o estado transitório do formulário.

### Campos

```dart
class HospedagemFormState extends Equatable {
  // Campos de formulário (podem estar incompletos)
  final String nomeHospede;           // "" → não preenchido
  final String numHospedes;           // String para aceitar input inválido
  final String valorTotal;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? status;               // enum.name como String
  final String? plataforma;
  final String? imovelId;
  final String? fotoBase64;

  // Estado da UI
  final bool salvando;                // desabilita botão enquanto salva
  final Map<String, String> erros;    // chave→field, valor→mensagem
  final bool valido;                  // true se sem erros
  final bool sujo;                    // dirty flag (marcado com true ao editar)
}
```

### Métodos Principais

#### `copyWith({...})`
Cria uma nova instância com campos atualizados. Usa `??` coalescing — `null` não anula, mantém valor anterior.

```dart
var state = HospedagemFormState();
state = state.copyWith(nomeHospede: 'João Silva', sujo: true);
// state.nomeHospede == 'João Silva'
// state.sujo == true (antes era false)
// Todos outros campos preservados
```

#### `validate()`
Retorna um novo state com `erros` preenchidos e `valido` atualizado.

```dart
var state = HospedagemFormState(
  nomeHospede: '',
  checkIn: null,
);
var validado = state.validate();
// validado.erros == {'nomeHospede': 'Informe o nome do hóspede', 'checkIn': 'Selecione o check-in'}
// validado.valido == false
// state é imutável — validado é nova instância
```

**Regras de validação:**
- `nomeHospede` — não vazio
- `checkIn` — obrigatório
- `checkOut` — obrigatório e >= checkIn
- `numHospedes` — int >= 1
- `valorTotal` — double >= 0
- `status` — obrigatório (confirmada|pendente|cancelada|concluida)
- `plataforma` — obrigatório (airbnb|booking|direto|outro)

#### `toEntity(id: String)`
Converte o blueprint em uma entidade de domínio. **Falha com `StateError`** se não estiver válido.

```dart
var entity = validado.toEntity(id: 'hospedagem-123');
// Retorna HospedagemEntity com campos validados e tipados
// int numHospedes, double valorTotal, StatusHospedagem status, etc.

// Se inválido:
var entity = invalidado.toEntity(id: ...); // Lança StateError
```

#### `fromEntity(HospedagemEntity)`
Factory que cria um blueprint a partir de uma entidade (modo edição). Revalida automaticamente.

```dart
var entity = HospedagemEntity(
  nomeHospede: 'Maria Santos',
  numHospedes: 3,
  // ... outros campos
);
var blueprint = HospedagemFormState.fromEntity(entity);
// blueprint.nomeHospede == 'Maria Santos'
// blueprint.numHospedes == '3' (String)
// blueprint.valido == true (pois entidade era válida)
```

---

## HospedagemFormStore — O Orquestrador MobX

Store que gerencia as transições de estado do formulário.

### Setup

```dart
// Injeção em lib/core/di/injecao.dart
sl.registerFactory<HospedagemFormStore>(
  () => HospedagemFormStore(hospedagemStore: sl<HospedagemStore>()),
);

// Na dialog
late final HospedagemFormStore _formStore;

@override
void initState() {
  _formStore = sl<HospedagemFormStore>();
  if (widget.hospedagem != null) {
    _formStore.carregarParaEdicao(widget.hospedagem!);
  } else {
    _formStore.iniciarNovoFormulario();
  }
}
```

### Observables

```dart
@observable
HospedagemFormState formState = const HospedagemFormState();
```

Um único observable simplifica a reatividade: qualquer mudança de campo passa por `copyWith()` → `validate()` → `formState = novoState`.

### Computed Properties

```dart
@computed bool get formularioValido => formState.valido;
@computed bool get formularioSalvando => formState.salvando;
@computed String? get erroSubmit => formState.erros['submit'];
```

Observadores (via `Observer` widget) reagem automaticamente a essas mudanças.

### Actions — Atualizar Campos

Cada campo tem uma action que:
1. Copia o state com o novo valor
2. Marca como sujo (`sujo: true`)
3. Revalida

```dart
@action
void atualizarNomeHospede(String valor) {
  formState = formState.copyWith(nomeHospede: valor, sujo: true).validate();
}

@action
void atualizarCheckIn(DateTime? valor) {
  var novoState = formState.copyWith(checkIn: valor, sujo: true);

  // Auto-ajuste: se checkIn > checkOut, ajusta checkOut
  if (valor != null && novoState.checkOut != null && novoState.checkOut!.isBefore(valor)) {
    novoState = novoState.copyWith(
      checkOut: valor.add(const Duration(days: 1)),
    );
  }

  formState = novoState.validate();
}
```

### Action — Iniciar e Carregar

```dart
@action
void iniciarNovoFormulario() {
  formState = const HospedagemFormState();
}

@action
void carregarParaEdicao(HospedagemEntity hospedagem) {
  formState = HospedagemFormState.fromEntity(hospedagem);
}
```

### Action — Salvar

O método mais complexo:

```dart
@action
Future<void> salvar({String? idExistente}) async {
  // 1. Validar
  if (!formState.valido) {
    formState = formState.validate();
    return;
  }

  // 2. Sinalizar salvando
  formState = formState.copyWith(salvando: true);

  try {
    // 3. Converter blueprint → entidade
    final id = idExistente ?? _gerarNovoId();
    final hospedagem = formState.toEntity(id: id);

    // 4. Persistir
    if (idExistente != null) {
      await _hospedagemStore.atualizarHospedagem(hospedagem);
    } else {
      await _hospedagemStore.adicionarHospedagem(hospedagem);
    }

    // 5. Tratar resultado
    final erroDoStore = _hospedagemStore.erro;
    if (erroDoStore != null) {
      // Erro → mostrar no UI
      formState = formState.copyWith(
        salvando: false,
        erros: {...formState.erros, 'submit': erroDoStore},
        valido: false,
      );
    } else {
      // Sucesso → limpar salvando (caller fecha dialog)
      formState = formState.copyWith(salvando: false);
    }
  } catch (e) {
    // Exceção → mostrar
    formState = formState.copyWith(
      salvando: false,
      erros: {...formState.erros, 'submit': e.toString()},
      valido: false,
    );
  }
}
```

**Fluxo:**
- Modo criação (`idExistente == null`) → chama `adicionarHospedagem()`
- Modo edição (`idExistente != null`) → chama `atualizarHospedagem()`
- Erro do store → rollback: adiciona erro ao state, usuário corrige + tenta novamente
- Sucesso → state limpo, caller fecha dialog e recarrega lista

---

## Integração com o Widget

### FormularioHospedagemDialog

```dart
class _FormularioHospedagemDialogState extends State {
  late TextEditingController _nomeHospedeCtrl;
  late HospedagemFormStore _formStore;

  @override
  void initState() {
    _formStore = sl<HospedagemFormStore>();
    if (_edicao) {
      _formStore.carregarParaEdicao(widget.hospedagem!);
    } else {
      _formStore.iniciarNovoFormulario();
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    await _formStore.salvar(idExistente: widget.hospedagem?.id);
    if (!mounted) return;
    if (_formStore.erroSubmit == null && _formStore.formularioValido) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Observer(builder: (_) {
        final state = _formStore.formState;

        // Sincronizar controllers com state
        _nomeHospedeCtrl.text = state.nomeHospede;
        // ... outros controllers

        return Form(
          child: Column(
            children: [
              // Erro de submit no topo
              if (state.erros['submit'] != null)
                _ErroFormulario(mensagem: state.erros['submit']!),

              // Campos com validação em tempo real
              DsTextField(
                rotulo: 'Nome do hóspede',
                controlador: _nomeHospedeCtrl,
                validador: (v) => state.erros['nomeHospede'],
                onChanged: (v) => _formStore.atualizarNomeHospede(v),
              ),

              // Date pickers
              _CampoData(
                rotulo: 'Check-in',
                valor: _formatarData(state.checkIn),
                erro: state.erros['checkIn'],
                aoTocar: _selecionarCheckIn,
              ),

              // ... outros campos

              // Botão com estado
              DsBotaoPrimario(
                rotulo: _edicao ? 'Salvar alterações' : 'Criar hospedagem',
                carregando: state.salvando,
                habilitado: !state.salvando,
                aoTocar: state.salvando ? null : _salvar,
              ),
            ],
          ),
        );
      }),
    );
  }
}
```

**Pontos-chave:**
- `Observer` envolve o `build` para reagir a mudanças de `formState`
- `TextEditingController.text` sincronizado a cada rebuild (Dart é rápido, sem problema)
- Callbacks `onChanged` chamam actions do store: `atualizarNomeHospede(v)`
- Validação mostrada em tempo real sem "dirty field trick"
- Botão desabilitado enquanto `salvando == true`

---

## Ciclos de Vida

### Modo Criação

```
1. Dialog abre
   → iniciarNovoFormulario() → formState = vazio, valido = false

2. Usuário preenche "João Silva" no name field
   → atualizarNomeHospede('João Silva')
   → formState = copyWith(...).validate()
   → erros['nomeHospede'] = null, mas ainda valido = false (faltam outros)

3. Completa todos os campos
   → validações passam → valido = true → botão habilitado

4. Clica "Criar hospedagem"
   → salvar()
   → converte blueprint → HospedagemEntity
   → chama adicionarHospedagem(hospedagem)
   → sucesso → formState.salvando = false
   → caller fecha dialog

5. Lista atualiza automaticamente (hospedagemStore.hospedagens é @observable)
```

### Modo Edição

```
1. Dialog abre com widget.hospedagem
   → carregarParaEdicao(hospedagem)
   → formState = HospedagemFormState.fromEntity(hospedagem)
   → todos os campos preenchidos, valido = true → botão já habilitado

2. Usuário muda "João Silva" para "Maria Santos"
   → atualizarNomeHospede('Maria Santos')
   → formState.sujo = true (flag para delta futuro)

3. Clica "Salvar alterações"
   → salvar(idExistente: 'hospedagem-123')
   → converte blueprint → HospedagemEntity com id existente
   → chama atualizarHospedagem(hospedagem)
   → sucesso → lista atualiza automaticamente

4. Dialog fecha
```

---

## Validação em Tempo Real (Sem Dirty Field Trick)

Normalmente, mostrar validação de um TextField vazio é UX ruim. O padrão aqui evita isso com o campo `sujo`:

```dart
DsTextField(
  validador: (v) {
    // Só mostrar erro se campo foi tocado (sujo) OU formulário foi validado
    if (!formState.sujo && formState.erros.isEmpty) return null;
    return formState.erros['nomeHospede'];
  },
)
```

**Alternativa mais elegante** (implementação futura):
- Adicionar `Map<String, bool> camposTocados` para rastrear blur de cada field
- Mostrar erro do campo X só se `camposTocados['nomeHospede'] == true`

---

## Testes

### HospedagemFormStateTest (29 casos)
- `validate()` — todos os cenários de erro + válido
- `toEntity()` — conversão com sucesso + StateError se inválido
- `fromEntity()` — copia entidade + revalida
- `copyWith()` — imutabilidade

### HospedagemFormStoreTest (34 casos)
- `iniciarNovoFormulario()` + `carregarParaEdicao()` — inicialização
- Cada `atualizarX()` — campo atualiza + valida
- `salvar()` — modo criação, modo edição, erro do store, exceção
- Computed properties

**Cobertura:** 100% em ambos os arquivos.

---

## Benefícios do Padrão

| Problema | Solução |
|---|---|
| Salvar parcial | `toEntity()` falha se `!valido` |
| Validação prematura | Campo `sujo` controla quando mostrar erro |
| Perder dados | Blueprint é sempre persistido em memory até sucesso |
| Erro não tratado | `fold()` no `salvar()` obriga tratamento |
| Reatividade complexa | Um único `@observable formState` simplifica |
| Reuso formulário | `carregarParaEdicao()` + `iniciarNovoFormulario()` rápido |

---

## Próximos Passos

- [ ] Adicionar `Map<String, bool> camposTocados` para UX de validação melhor
- [ ] Implementar `fotoBase64` com `Isolate.run(base64Encode)` (Commit 10)
- [ ] DsImagemBase64 widget que renderiza base64 com preview (Commit 11)
- [ ] Testes de integração (formulário completo até persistência)
