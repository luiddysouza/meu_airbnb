import 'package:equatable/equatable.dart';

class SduiAction extends Equatable {
  const SduiAction({required this.tipo, this.payload = const {}});

  final String tipo;
  final Map<String, dynamic> payload;

  factory SduiAction.fromJson(Map<String, dynamic> json) {
    return SduiAction(
      tipo: json['tipo'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
    );
  }

  @override
  List<Object?> get props => [tipo, payload];
}
