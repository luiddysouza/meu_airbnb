import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

/// Serviço para encoding base64 de arquivos em Isolate.
///
/// Usa Isolate.run() para não bloquear a UI thread durante encoding
/// de arquivos de imagem grandes.
///
/// Padrão: App thread chama [encodarImagemBase64], que dispara
/// isolate separada, retornando `Future<String>` com base64 completo.
class Base64IsolateService {
  /// Encoda arquivo de imagem para base64 em isolate separada.
  ///
  /// Evita UI freeze ao processar imagens grandes (> 5MB).
  /// A encoding acontece em thread separada, retornando resultado
  /// apenas quando completo.
  ///
  /// Parâmetros:
  /// - [caminhoArquivo]: Caminho absoluto do arquivo
  ///
  /// Retorna: String com conteúdo base64 do arquivo.
  /// Lança [FileSystemException] se arquivo não existe.
  /// Lança [Exception] se encoding falha.
  ///
  /// Uso:
  /// ```dart
  /// final base64 = await Base64IsolateService.encodarImagemBase64(
  ///   '/path/to/image.jpg',
  /// );
  /// ```
  static Future<String> encodarImagemBase64(String caminhoArquivo) async {
    return Isolate.run(() => _encodarNoIsolate(caminhoArquivo));
  }

  /// Função estática que roda dentro do isolate.
  /// Não pode acessar contexto de Flutter (BuildContext, globals, etc).
  static String _encodarNoIsolate(String caminhoArquivo) {
    final arquivo = File(caminhoArquivo);

    // Valida se arquivo existe
    if (!arquivo.existsSync()) {
      throw FileSystemException('Arquivo não encontrado', caminhoArquivo);
    }

    // Lê arquivo em bytes
    final bytes = arquivo.readAsBytesSync();

    // Encoda para base64
    final base64String = base64Encode(bytes);

    return base64String;
  }
}
