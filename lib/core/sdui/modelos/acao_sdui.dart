import 'package:equatable/equatable.dart';

class AcaoSdui extends Equatable {
  const AcaoSdui({required this.tipo, this.payload = const {}});

  final String tipo;
  final Map<String, dynamic> payload;

  factory AcaoSdui.fromJson(Map<String, dynamic> json) {
    return AcaoSdui(
      tipo: json['tipo'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
    );
  }

  @override
  List<Object?> get props => [tipo, payload];
}
