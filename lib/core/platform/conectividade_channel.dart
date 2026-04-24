import 'package:flutter/services.dart';

/// Wrapper para EventChannel de conectividade.
/// Monitora mudanças no status de conexão (online/offline).
class ConectividadeChannel {
  static const _platformEvent = EventChannel(
    'br.com.meuairbnb.meu_airbnb/conectividade',
  );

  static const _platformMethod = MethodChannel(
    'br.com.meuairbnb.meu_airbnb/conectividade/status',
  );

  /// Stream de eventos de conectividade.
  /// Emite strings: 'online' ou 'offline'.
  ///
  /// Uso:
  /// ```dart
  /// ConectividadeChannel.obterStatusStream().listen((status) {
  ///   print('Status: $status');
  /// });
  /// ```
  static Stream<String> obterStatusStream() {
    return _platformEvent.receiveBroadcastStream().cast<String>();
  }

  /// Obtém o status atual de conectividade.
  /// Retorna 'online' ou 'offline'.
  ///
  /// Uso:
  /// ```dart
  /// final status = await ConectividadeChannel.obterStatusAtual();
  /// print(status); // 'online' ou 'offline'
  /// ```
  static Future<String> obterStatusAtual() async {
    try {
      final resultado = await _platformMethod.invokeMethod<String>(
        'obterStatusAtual',
      );
      return resultado ?? 'offline';
    } on PlatformException {
      // Em iOS/web, retorna offline (não suportado)
      return 'offline';
    } on MissingPluginException {
      // Canal não registrado (ex: testes unitários, web, desktop)
      return 'offline';
    }
  }
}
