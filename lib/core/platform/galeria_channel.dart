import 'package:flutter/services.dart';

/// Wrapper para seleção de imagens via Android ActivityResultContracts.
///
/// Delegado ao Android nativo (ActivityResultContracts.GetContent com mime type 'image/*').
/// Graceful fallback em iOS/web: retorna null.
class GaleriaChannel {
  static const _platform = MethodChannel('br.com.meuairbnb.meu_airbnb/galeria');

  /// Abre seletor de imagem nativo e retorna caminho do arquivo.
  ///
  /// Retorna o caminho absoluto do arquivo selecionado (ex: '/data/... /image.jpg').
  /// Retorna null se usuário cancelou a seleção ou em iOS/web.
  ///
  /// Uso:
  /// ```dart
  /// try {
  ///   final caminhoImagem = await GaleriaChannel.selecionarImagem();
  ///   if (caminhoImagem != null) {
  ///     // Usar caminho para encoding em Isolate
  ///   }
  /// } on PlatformException {
  ///   // Falha no acesso à galeria
  /// }
  /// ```
  static Future<String?> selecionarImagem() async {
    try {
      final resultado = await _platform.invokeMethod<String>(
        'selecionarImagem',
      );
      return resultado;
    } on PlatformException {
      // iOS/web: sem suporte a galeria nativa
      return null;
    }
  }

  /// Verifica se dispositivo possui acesso à galeria de fotos.
  ///
  /// Retorna true em Android (via ActivityResultContracts).
  /// Retorna false em iOS/web.
  static Future<bool> isGaleriaDisponivel() async {
    try {
      final resultado = await _platform.invokeMethod<bool>(
        'isGaleriaDisponivel',
      );
      return resultado ?? false;
    } on PlatformException {
      return false;
    }
  }
}
