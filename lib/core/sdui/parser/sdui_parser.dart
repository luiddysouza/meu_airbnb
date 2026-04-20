import 'dart:convert';

import '../modelos/no_sdui.dart';

abstract final class SduiParser {
  /// Converte uma [String] JSON no formato SDUI em uma lista de [NoSdui].
  ///
  /// Espera um objeto JSON com a chave `componentes` contendo um array
  /// de nós. Lança [FormatException] se o JSON for inválido ou mal-formado.
  static List<NoSdui> parsear(String jsonString) {
    final mapa = jsonDecode(jsonString) as Map<String, dynamic>;
    final componentes = mapa['componentes'] as List<dynamic>? ?? [];
    return componentes
        .map((item) => NoSdui.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
