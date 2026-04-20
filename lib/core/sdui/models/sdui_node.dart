import 'package:equatable/equatable.dart';

import 'sdui_action.dart';

class SduiNode extends Equatable {
  const SduiNode({
    required this.tipo,
    this.propriedades = const {},
    this.filhos = const [],
    this.acao,
  });

  final String tipo;
  final Map<String, dynamic> propriedades;
  final List<SduiNode> filhos;
  final SduiAction? acao;

  factory SduiNode.fromJson(Map<String, dynamic> json) {
    return SduiNode(
      tipo: json['tipo'] as String,
      propriedades: Map<String, dynamic>.from(
        json['propriedades'] as Map? ?? {},
      ),
      filhos: (json['filhos'] as List<dynamic>? ?? [])
          .map((filho) => SduiNode.fromJson(filho as Map<String, dynamic>))
          .toList(),
      acao: json['acao'] != null
          ? SduiAction.fromJson(json['acao'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [tipo, propriedades, filhos, acao];
}
