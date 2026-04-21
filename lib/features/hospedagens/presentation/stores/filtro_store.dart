import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import '../../domain/entities/hospedagem_entity.dart';
import '../../domain/usecases/obter_imoveis.dart';
import '../../domain/entities/imovel_entity.dart';
import '../../../../core/usecases/usecase.dart';

part 'filtro_store.g.dart';

// ignore: library_private_types_in_public_api
class FiltroStore = _FiltroStore with _$FiltroStore;

/// Store MobX responsável pelos filtros e pela lista de hospedagens filtradas.
///
/// Depende de [HospedagemStore.hospedagens] como fonte de dados — recebe
/// a referência da [ObservableList] e o computed [hospedagensFiltradas]
/// reage automaticamente a mudanças nela.
abstract class _FiltroStore with Store {
  _FiltroStore(this._obterImoveis);

  final ObterImoveis _obterImoveis;

  // ── Observables ────────────────────────────────────────────────────────────

  /// Todas as hospedagens — referência à lista do HospedagemStore.
  /// Definida externamente logo após a criação dos stores no DI.
  @observable
  ObservableList<HospedagemEntity> todasHospedagens = ObservableList();

  @observable
  DateTimeRange? periodoSelecionado;

  @observable
  String? imovelSelecionadoId;

  @observable
  List<ImovelEntity> imoveis = [];

  @observable
  String? erro;

  // ── Computed ───────────────────────────────────────────────────────────────

  /// Lista de hospedagens filtrada pelo período e/ou imóvel selecionados.
  ///
  /// Recalcula automaticamente sempre que [todasHospedagens],
  /// [periodoSelecionado] ou [imovelSelecionadoId] mudam.
  @computed
  List<HospedagemEntity> get hospedagensFiltradas {
    var lista = todasHospedagens.toList();

    if (periodoSelecionado != null) {
      final inicio = periodoSelecionado!.start;
      final fim = periodoSelecionado!.end;
      lista = lista.where((h) {
        // Inclui hospedagens que se sobrepõem ao período selecionado
        return !h.checkOut.isBefore(inicio) && !h.checkIn.isAfter(fim);
      }).toList();
    }

    if (imovelSelecionadoId != null) {
      lista = lista.where((h) => h.imovelId == imovelSelecionadoId).toList();
    }

    return lista;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  @action
  void selecionarPeriodo(DateTimeRange? periodo) {
    periodoSelecionado = periodo;
  }

  @action
  void selecionarImovel(String? id) {
    imovelSelecionadoId = id;
  }

  @action
  void limparFiltros() {
    periodoSelecionado = null;
    imovelSelecionadoId = null;
  }

  /// Carrega a lista de imóveis do repositório (para preencher o dropdown).
  @action
  Future<void> carregarImoveis() async {
    erro = null;
    final resultado = await _obterImoveis(const NoParams());

    resultado.fold(
      (failure) => erro = failure.mensagem,
      (lista) => imoveis = lista,
    );
  }
}
