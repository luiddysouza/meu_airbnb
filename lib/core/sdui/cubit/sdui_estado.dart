import 'package:equatable/equatable.dart';

import '../modelos/no_sdui.dart';

sealed class SduiEstado extends Equatable {
  const SduiEstado();
}

final class SduiInicial extends SduiEstado {
  const SduiInicial();

  @override
  List<Object?> get props => [];
}

final class SduiCarregando extends SduiEstado {
  const SduiCarregando();

  @override
  List<Object?> get props => [];
}

final class SduiSucesso extends SduiEstado {
  const SduiSucesso(this.arvore);

  final List<NoSdui> arvore;

  @override
  List<Object?> get props => [arvore];
}

final class SduiErro extends SduiEstado {
  const SduiErro(this.mensagem);

  final String mensagem;

  @override
  List<Object?> get props => [mensagem];
}
