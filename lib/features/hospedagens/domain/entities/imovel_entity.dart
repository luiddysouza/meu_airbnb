import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa um imóvel cadastrado.
class ImovelEntity extends Equatable {
  const ImovelEntity({required this.id, required this.nome, this.endereco});

  final String id;
  final String nome;
  final String? endereco;

  @override
  List<Object?> get props => [id, nome, endereco];
}
