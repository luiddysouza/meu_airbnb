import 'dart:convert';

import '../models/sdui_node.dart';

abstract final class SduiParser {
  /// Converte uma [String] JSON no formato SDUI em uma lista de [SduiNode].
  ///
  /// Espera um objeto JSON com a chave `componentes` contendo um array
  /// de nós. Lança [FormatException] se o JSON for inválido ou mal-formado.
  static List<SduiNode> parsear(String jsonString) {
    final mapa = jsonDecode(jsonString) as Map<String, dynamic>;
    final componentes = mapa['componentes'] as List<dynamic>? ?? [];
    return componentes
        .map((item) => SduiNode.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
