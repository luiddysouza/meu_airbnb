import 'package:meu_airbnb/core/platform/biometric_channel.dart';
import 'package:mobx/mobx.dart';

part 'biometric_store.g.dart';

/// Store MobX que gerencia estado de autenticação biométrica.
class BiometricStore = BiometricStoreBase with _$BiometricStore;

abstract class BiometricStoreBase with Store {
  @observable
  bool autenticando = false;

  @observable
  bool disponivel = false;

  @observable
  String tipoBiometrico = 'nenhum';

  @observable
  String? erro;

  /// Inicializa verificação de disponibilidade de biometria.
  /// Deve ser chamado na app startup (ex: no MyApp ou no boot).
  @action
  Future<void> verificarDisponibilidade() async {
    try {
      final disponibilidadeResult =
          await BiometricChannel.isBiometricoDisponivel();
      disponivel = disponibilidadeResult;

      if (disponivel) {
        tipoBiometrico = await BiometricChannel.getTipoBiometrico();
      }
      erro = null;
    } catch (e) {
      disponivel = false;
      tipoBiometrico = 'nenhum';
      erro = 'Erro ao verificar biometria: $e';
    }
  }

  /// Inicia fluxo de autenticação biométrica.
  ///
  /// Mostra BiometricPrompt nativo. Retorna true em sucesso,
  /// false se usuário cancelou ou falha na autenticação.
  @action
  Future<bool> autenticar({
    required String titulo,
    required String subtitulo,
    String? descricao,
  }) async {
    autenticando = true;
    erro = null;

    try {
      final resultado = await BiometricChannel.autenticar(
        titulo: titulo,
        subtitulo: subtitulo,
        descricao: descricao,
      );
      autenticando = false;
      return resultado;
    } catch (e) {
      autenticando = false;
      erro = 'Erro na autenticação: $e';
      rethrow;
    }
  }

  /// Limpa mensagem de erro.
  @action
  void limparErro() {
    erro = null;
  }
}
