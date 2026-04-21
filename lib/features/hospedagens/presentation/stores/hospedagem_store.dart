import 'package:mobx/mobx.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/hospedagem_entity.dart';
import '../../domain/usecases/adicionar_hospedagem.dart';
import '../../domain/usecases/atualizar_hospedagem.dart';
import '../../domain/usecases/deletar_hospedagem.dart';
import '../../domain/usecases/obter_hospedagens.dart';
import '../../../../core/usecases/usecase.dart';

part 'hospedagem_store.g.dart';

// ignore: library_private_types_in_public_api
class HospedagemStore = _HospedagemStore with _$HospedagemStore;

/// Store MobX responsável pelo estado das hospedagens.
///
/// Implementa o padrão Optimistic State em todas as ações de mutação:
/// 1. Salva snapshot do estado atual
/// 2. Aplica mudança imediatamente na lista (UI reflete na hora)
/// 3. Chama o use case (simula latência)
/// 4a. Right → descarta snapshot (confirma estado)
/// 4b. Left → restaura snapshot + seta [erro]
abstract class _HospedagemStore with Store {
  _HospedagemStore(
    this._obterHospedagens,
    this._adicionarHospedagem,
    this._atualizarHospedagem,
    this._deletarHospedagem,
  );

  final ObterHospedagens _obterHospedagens;
  final AdicionarHospedagem _adicionarHospedagem;
  final AtualizarHospedagem _atualizarHospedagem;
  final DeletarHospedagem _deletarHospedagem;

  static const _uuid = Uuid();

  // ── Observables ────────────────────────────────────────────────────────────

  @observable
  ObservableList<HospedagemEntity> hospedagens = ObservableList();

  @observable
  bool carregando = false;

  @observable
  String? erro;

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Carrega todas as hospedagens do repositório.
  @action
  Future<void> carregarHospedagens() async {
    carregando = true;
    erro = null;

    final resultado = await _obterHospedagens(const NoParams());

    resultado.fold(
      (failure) {
        erro = failure.mensagem;
        carregando = false;
      },
      (lista) {
        hospedagens = ObservableList.of(lista);
        carregando = false;
      },
    );
  }

  /// Adiciona uma nova hospedagem com ID gerado automaticamente.
  ///
  /// O [id] e [criadoEm] são preenchidos aqui se ainda não definidos.
  @action
  Future<void> adicionarHospedagem(HospedagemEntity hospedagem) async {
    erro = null;
    final novaHospedagem = hospedagem.id.isEmpty
        ? hospedagem.copyWith(id: _uuid.v4(), criadoEm: DateTime.now())
        : hospedagem;

    // Optimistic: aplica imediatamente
    final snapshot = List<HospedagemEntity>.from(hospedagens);
    hospedagens.add(novaHospedagem);

    final resultado = await _adicionarHospedagem(novaHospedagem);

    resultado.fold(
      (failure) {
        // Rollback
        hospedagens = ObservableList.of(snapshot);
        erro = failure.mensagem;
      },
      (_) {
        // Confirma — estado já está correto
      },
    );
  }

  /// Atualiza uma hospedagem existente pelo id.
  @action
  Future<void> atualizarHospedagem(HospedagemEntity hospedagem) async {
    erro = null;
    final snapshot = List<HospedagemEntity>.from(hospedagens);

    // Optimistic: atualiza imediatamente
    final indice = hospedagens.indexWhere((h) => h.id == hospedagem.id);
    if (indice != -1) {
      hospedagens[indice] = hospedagem;
    }

    final resultado = await _atualizarHospedagem(hospedagem);

    resultado.fold(
      (failure) {
        // Rollback
        hospedagens = ObservableList.of(snapshot);
        erro = failure.mensagem;
      },
      (_) {
        // Confirma
      },
    );
  }

  /// Remove a hospedagem com o [id] informado.
  @action
  Future<void> deletarHospedagem(String id) async {
    erro = null;
    final snapshot = List<HospedagemEntity>.from(hospedagens);

    // Optimistic: remove imediatamente
    hospedagens.removeWhere((h) => h.id == id);

    final resultado = await _deletarHospedagem(id);

    resultado.fold(
      (failure) {
        // Rollback
        hospedagens = ObservableList.of(snapshot);
        erro = failure.mensagem;
      },
      (_) {
        // Confirma
      },
    );
  }

  /// Limpa o erro atual.
  @action
  void limparErro() => erro = null;
}
