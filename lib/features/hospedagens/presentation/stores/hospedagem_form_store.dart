import 'package:mobx/mobx.dart';

import '../../domain/entities/hospedagem_entity.dart';
import 'hospedagem_form_state.dart';
import 'hospedagem_store.dart';

part 'hospedagem_form_store.g.dart';

// ignore: library_private_types_in_public_api
class HospedagemFormStore = _HospedagemFormStore with _$HospedagemFormStore;

/// Store MobX responsável por orquestrar o ciclo de vida do formulário.
///
/// O formulário segue o padrão Blueprint/Ser Humano:
/// - Um único @observable `formState` gerencia todas as transições
/// - Actions atualizam campos incrementalmente com `copyWith()` + `validate()`
/// - Métodos `iniciarNovoFormulario()` e `carregarParaEdicao()` configuram o estado inicial
/// - Action `salvar()` converte o blueprint em entidade e persiste via `HospedagemStore`
///
/// ## Ciclo de Vida Típico (Criação)
/// ```
/// 1. iniciarNovoFormulario()         → formState = vazio
/// 2. atualizarNomeHospede('João')    → formState = nome atualizado + revalidado
/// 3. ... (atualiza outros campos)
/// 4. formState.valido == true        → botão "Salvar" habilitado
/// 5. salvar()                         → converte para entidade + chama HospedagemStore
/// ```
///
/// ## Ciclo de Vida Típico (Edição)
/// ```
/// 1. carregarParaEdicao(hospedagem)  → formState = dados carregados + validado
/// 2. atualizarNomeHospede('Maria')   → formState = nome atualizado + revalidado
/// 3. ... (atualiza campos desejados)
/// 4. salvar()                         → converte para entidade + chama HospedagemStore.atualizarHospedagem
/// ```
abstract class _HospedagemFormStore with Store {
  _HospedagemFormStore({required HospedagemStore hospedagemStore})
    : _hospedagemStore = hospedagemStore;

  final HospedagemStore _hospedagemStore;

  // ═══════════════════════════════════════════════════════════════════════════
  // OBSERVABLES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Estado imutável do formulário — o único observable.
  /// Todas as mudanças transitam por aqui.
  @observable
  HospedagemFormState formState = const HospedagemFormState();

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPUTED
  // ═══════════════════════════════════════════════════════════════════════════

  /// Indica se o formulário está válido e pronto para ser salvo.
  @computed
  bool get formularioValido => formState.valido;

  /// Indica se o formulário está em processo de salvar.
  @computed
  bool get formularioSalvando => formState.salvando;

  /// Retorna a mensagem de erro de submit (se houver).
  @computed
  String? get erroSubmit => formState.erros['submit'];

  // ═══════════════════════════════════════════════════════════════════════════
  // INICIALIZAÇÃO
  // ═══════════════════════════════════════════════════════════════════════════

  /// Inicia um novo formulário vazio (modo criação).
  @action
  void iniciarNovoFormulario() {
    formState = const HospedagemFormState();
  }

  /// Carrega uma hospedagem existente para edição.
  ///
  /// Copia os dados da entidade para o state do formulário e aplica validação.
  @action
  void carregarParaEdicao(HospedagemEntity hospedagem) {
    formState = HospedagemFormState.fromEntity(hospedagem);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ATUALIZAR CAMPOS (Actions que revalidam)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Atualiza o nome do hóspede e revalida o formulário.
  @action
  void atualizarNomeHospede(String valor) {
    formState = formState.copyWith(nomeHospede: valor, sujo: true).validate();
  }

  /// Atualiza o número de hóspedes e revalida.
  @action
  void atualizarNumHospedes(String valor) {
    formState = formState.copyWith(numHospedes: valor, sujo: true).validate();
  }

  /// Atualiza o valor total e revalida.
  @action
  void atualizarValorTotal(String valor) {
    formState = formState.copyWith(valorTotal: valor, sujo: true).validate();
  }

  /// Atualiza as notas (opcional).
  @action
  void atualizarNotas(String? valor) {
    formState = formState.copyWith(notas: valor, sujo: true).validate();
  }

  /// Atualiza a data de check-in e revalida.
  /// Se atualizar para data posterior ao check-out, ajusta o check-out automaticamente.
  @action
  void atualizarCheckIn(DateTime? valor) {
    var novoState = formState.copyWith(checkIn: valor, sujo: true);

    // Se o novo check-in é após o check-out, ajusta o check-out
    if (valor != null &&
        novoState.checkOut != null &&
        novoState.checkOut!.isBefore(valor)) {
      novoState = novoState.copyWith(
        checkOut: valor.add(const Duration(days: 1)),
      );
    }

    formState = novoState.validate();
  }

  /// Atualiza a data de check-out e revalida.
  @action
  void atualizarCheckOut(DateTime? valor) {
    formState = formState.copyWith(checkOut: valor, sujo: true).validate();
  }

  /// Atualiza o status (como String do enum.name).
  @action
  void atualizarStatus(String? valor) {
    formState = formState.copyWith(status: valor, sujo: true).validate();
  }

  /// Atualiza a plataforma (como String do enum.name).
  @action
  void atualizarPlataforma(String? valor) {
    formState = formState.copyWith(plataforma: valor, sujo: true).validate();
  }

  /// Atualiza o ID do imóvel selecionado.
  @action
  void atualizarImovel(String? valor) {
    formState = formState.copyWith(imovelId: valor, sujo: true).validate();
  }

  /// Atualiza a foto em base64 e revalida.
  @action
  void atualizarFotoBase64(String? valor) {
    formState = formState.copyWith(fotoBase64: valor, sujo: true).validate();
  }

  /// Remove a foto (seta fotoBase64 para vazio/null).
  @action
  void removerFoto() {
    formState = formState.copyWith(fotoBase64: null, sujo: true).validate();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SALVAR
  // ═══════════════════════════════════════════════════════════════════════════

  /// Salva o formulário: valida, converte para entidade e persiste.
  ///
  /// Fluxo:
  /// 1. Se o state não estiver válido, valida e retorna cedo (força exibição de erros)
  /// 2. Seta `salvando = true` para desabilitar o botão
  /// 3. Converte o blueprint em entidade com ID (novo) ou reusa o ID existente
  /// 4. Chama `HospedagemStore` (adicionar ou atualizar)
  /// 5. Trata resultado com `fold()`:
  ///    - Left (erro) → adiciona erro ao state + reseta salvando
  ///    - Right (sucesso) → reseta salvando (caller pode fechar dialog ou navegar)
  ///
  /// Argumentos:
  /// - **idExistente**: Se informado, indica modo edição (reutiliza o ID).
  ///   Se null, modo criação (gera novo ID).
  @action
  Future<void> salvar({String? idExistente}) async {
    // Validar novamente para garantir que todos os erros estejam preenchidos
    if (!formState.valido) {
      formState = formState.validate();
      return;
    }

    // Seta estado de salvando
    formState = formState.copyWith(salvando: true);

    try {
      // Converter blueprint em entidade
      // Se é edição, reutiliza o ID; se é criação, gera novo ID
      final id = idExistente ?? _gerarNovoId();
      final hospedagem = formState.toEntity(id: id);

      // Persistir via HospedagemStore (decide entre add ou update)
      if (idExistente != null) {
        // Modo edição
        await _hospedagemStore.atualizarHospedagem(hospedagem);
      } else {
        // Modo criação
        await _hospedagemStore.adicionarHospedagem(hospedagem);
      }

      // Verificar se houve erro no store
      final erroDoStore = _hospedagemStore.erro;
      if (erroDoStore != null) {
        // Rollback: adiciona erro ao state e reseta salvando
        formState = formState.copyWith(
          salvando: false,
          erros: {...formState.erros, 'submit': erroDoStore},
          valido: false,
        );
      } else {
        // Sucesso: reseta salvando (o caller pode fechar o dialog)
        formState = formState.copyWith(salvando: false);
      }
    } catch (e) {
      // Erro inesperado durante a conversão ou persistência
      formState = formState.copyWith(
        salvando: false,
        erros: {...formState.erros, 'submit': e.toString()},
        valido: false,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITÁRIOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Gera um novo ID único para hospedagem (será injetado via get_it em um future refactor).
  String _gerarNovoId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Limpa o formulário para um novo ciclo.
  @action
  void limpar() {
    formState = const HospedagemFormState();
  }
}
