import 'dart:async';

import 'package:meu_airbnb/core/platform/conectividade_channel.dart';
import 'package:mobx/mobx.dart';

part 'conectividade_store.g.dart';

/// Store MobX que monitora o status de conectividade.
class ConectividadeStore = ConectividadeStoreBase with _$ConectividadeStore;

abstract class ConectividadeStoreBase with Store {
  late StreamSubscription<String> _subscription;

  @observable
  bool estaOnline = true;

  @observable
  String statusTexto = 'online';

  /// Inicializa o listener de eventos de conectividade.
  /// Deve ser chamado na inicialização da app.
  void iniciar() {
    _subscription = ConectividadeChannel.obterStatusStream().listen((status) {
      atualizarStatus(status);
    });
  }

  /// Para de escutar eventos de conectividade.
  /// Deve ser chamado no dispose/cleanup.
  void parar() {
    _subscription.cancel();
  }

  @action
  void atualizarStatus(String status) {
    statusTexto = status;
    estaOnline = status == 'online';
  }

  /// Obtém o status atual sem aguardar stream.
  /// Útil para checks iniciais.
  @action
  Future<void> carregarStatusAtual() async {
    final status = await ConectividadeChannel.obterStatusAtual();
    atualizarStatus(status);
  }
}
