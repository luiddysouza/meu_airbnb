import 'package:equatable/equatable.dart';

import 'acao_sdui.dart';

class NoSdui extends Equatable {
  const NoSdui({
    required this.tipo,
    this.propriedades = const {},
    this.filhos = const [],
    this.acao,
  });

  final String tipo;
  final Map<String, dynamic> propriedades;
  final List<NoSdui> filhos;
  final AcaoSdui? acao;

  factory NoSdui.fromJson(Map<String, dynamic> json) {
    return NoSdui(
      tipo: json['tipo'] as String,
      propriedades: Map<String, dynamic>.from(
        json['propriedades'] as Map? ?? {},
      ),
      filhos: (json['filhos'] as List<dynamic>? ?? [])
          .map((filho) => NoSdui.fromJson(filho as Map<String, dynamic>))
          .toList(),
      acao: json['acao'] != null
          ? AcaoSdui.fromJson(json['acao'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [tipo, propriedades, filhos, acao];
}
