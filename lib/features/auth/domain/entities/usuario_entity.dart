import 'package:equatable/equatable.dart';

/// Entidade que representa o usuário autenticado.
class UsuarioEntity extends Equatable {
  const UsuarioEntity({
    required this.id,
    required this.email,
    required this.nome,
  });

  final String id;
  final String email;
  final String nome;

  @override
  List<Object?> get props => [id, email, nome];
}
