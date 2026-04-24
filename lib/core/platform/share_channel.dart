import 'package:flutter/services.dart';

/// Interface para compartilhamento nativo via Intent (Android)
///
/// Permite compartilhar dados de hospedagens via sistema nativo de sharing,
/// disparando Intent.ACTION_SEND para abrir app selecionado pelo usuário.
class ShareChannel {
  static const _platform = MethodChannel('br.com.meuairbnb.meu_airbnb/share');

  /// Compartilha hospedagem através do Intent nativo do Android.
  ///
  /// Parâmetros:
  /// - [titulo]: Título da hospedagem (ex: "Casa na Praia - Bahia")
  /// - [descricao]: Descrição completa para compartilhar
  /// - [url]: URL opcional para adicionar ao texto (futuro: deep link)
  ///
  /// Lança [PlatformException] se o canal não responder (ex: em iOS ou web).
  /// Em caso de sucesso, retorna true; false se usuário cancelar.
  ///
  /// Exemplo:
  /// ```dart
  /// await ShareChannel.compartilharHospedagem(
  ///   titulo: 'Casa na Praia',
  ///   descricao: 'Acomodação para 4 pessoas, R\$ 350/noite',
  ///   url: 'https://airbnb.com/hospedagens/123',
  /// );
  /// ```
  static Future<bool> compartilharHospedagem({
    required String titulo,
    required String descricao,
    String? url,
  }) async {
    try {
      final resultado = await _platform.invokeMethod<bool>(
        'compartilharHospedagem',
        {'titulo': titulo, 'descricao': descricao, 'url': url},
      );
      return resultado ?? false;
    } on PlatformException {
      // Se estiver rodando em iOS, web ou simulador sem suporte a Intent
      // Retorna false gracefully sem lançar exceção
      return false;
    }
  }

  /// Compartilha múltiplas hospedagens em um texto formatado.
  ///
  /// Agrupa informações de hospedagens em um único texto bem formatado.
  /// Útil para compartilhar lista de opções ou roteiro.
  ///
  /// Exemplo:
  /// ```dart
  /// await ShareChannel.compartilharLista(
  ///   titulo: 'Minhas Hospedagens Favoritas',
  ///   hospedagens: [
  ///     {'nome': 'Casa 1', 'valor': 'R\$ 200'},
  ///     {'nome': 'Casa 2', 'valor': 'R\$ 300'},
  ///   ],
  /// );
  /// ```
  static Future<bool> compartilharLista({
    required String titulo,
    required List<Map<String, String>> hospedagens,
  }) async {
    try {
      final resultado = await _platform.invokeMethod<bool>(
        'compartilharLista',
        {'titulo': titulo, 'hospedagens': hospedagens},
      );
      return resultado ?? false;
    } on PlatformException {
      // Se estiver rodando em iOS, web ou simulador sem suporte a Intent
      // Retorna false gracefully sem lançar exceção
      return false;
    }
  }
}
