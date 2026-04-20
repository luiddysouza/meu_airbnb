import 'package:equatable/equatable.dart';

import '../models/sdui_node.dart';

sealed class SduiState extends Equatable {
  const SduiState();
}

final class SduiInitial extends SduiState {
  const SduiInitial();

  @override
  List<Object?> get props => [];
}

final class SduiLoading extends SduiState {
  const SduiLoading();

  @override
  List<Object?> get props => [];
}

final class SduiSuccess extends SduiState {
  const SduiSuccess(this.arvore);

  final List<SduiNode> arvore;

  @override
  List<Object?> get props => [arvore];
}

final class SduiError extends SduiState {
  const SduiError(this.mensagem);

  final String mensagem;

  @override
  List<Object?> get props => [mensagem];
}
