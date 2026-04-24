import 'package:flutter/services.dart';

/// Wrapper para autenticação biométrica via Android BiometricPrompt
///
/// Suporta fingerprint e face unlock. Graceful fallback em iOS/web.
class BiometricChannel {
  static const _platform = MethodChannel(
    'br.com.meuairbnb.meu_airbnb/biometric',
  );

  /// Autenticação biométrica com feedback visual (BiometricPrompt).
  ///
  /// Mostra diálogo nativo do Android com opções de fingerprint/face.
  /// Retorna true se autenticação foi bem-sucedida, false caso contrário.
  ///
  /// Parâmetros:
  /// - [titulo]: Título do diálogo (ex: "Autenticar com biometria")
  /// - [subtitulo]: Subtítulo descritivo
  /// - [descricao]: Descrição completa (opcional)
  ///
  /// Lança [PlatformException] se dispositivo não suporta biometria.
  /// Em iOS/web, retorna false sem exceção (graceful degradation).
  ///
  /// Uso:
  /// ```dart
  /// try {
  ///   final autenticado = await BiometricChannel.autenticar(
  ///     titulo: 'Faça login',
  ///     subtitulo: 'Use sua biometria',
  ///   );
  ///   if (autenticado) {
  ///     // Prosseguir com login
  ///   }
  /// } on PlatformException catch (e) {
  ///   // Dispositivo não suporta biometria
  /// }
  /// ```
  static Future<bool> autenticar({
    required String titulo,
    required String subtitulo,
    String? descricao,
  }) async {
    try {
      final resultado = await _platform.invokeMethod<bool>(
        'autenticar',
        {
          'titulo': titulo,
          'subtitulo': subtitulo,
          'descricao': descricao,
        },
      );
      return resultado ?? false;
    } on PlatformException {
      // Em iOS/web: sem suporte a biometria
      rethrow;
    }
  }

  /// Verifica se dispositivo possui sensores biométricos disponíveis.
  ///
  /// Retorna true se device suporta fingerprint OU face.
  /// Retorna false em iOS/web ou se dispositivo não tiver sensores.
  ///
  /// Uso:
  /// ```dart
  /// final disponivel = await BiometricChannel.isBiometricoDisponivel();
  /// if (disponivel) {
  ///   // Exibe opção de login com biometria
  /// }
  /// ```
  static Future<bool> isBiometricoDisponivel() async {
    try {
      final resultado = await _platform.invokeMethod<bool>(
        'isBiometricoDisponivel',
      );
      return resultado ?? false;
    } on PlatformException {
      // iOS/web: sem suporte
      return false;
    }
  }

  /// Tipo de sensor biométrico disponível no dispositivo.
  ///
  /// Retorna 'fingerprint', 'face', 'ambos' ou 'nenhum'.
  ///
  /// Uso:
  /// ```dart
  /// final tipo = await BiometricChannel.getTipoBiometrico();
  /// print('Sensor: $tipo'); // 'fingerprint', 'face', etc
  /// ```
  static Future<String> getTipoBiometrico() async {
    try {
      final resultado = await _platform.invokeMethod<String>(
        'getTipoBiometrico',
      );
      return resultado ?? 'nenhum';
    } on PlatformException {
      return 'nenhum';
    }
  }
}
