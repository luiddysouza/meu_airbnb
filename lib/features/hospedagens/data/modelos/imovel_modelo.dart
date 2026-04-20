import '../../dominio/entidades/imovel_entidade.dart';

/// Modelo de dados para [ImovelEntidade].
///
/// Responsável pela serialização/deserialização JSON e pela conversão
/// de/para a entidade de domínio.
class ImovelModelo {
  const ImovelModelo({required this.id, required this.nome, this.endereco});

  final String id;
  final String nome;
  final String? endereco;

  factory ImovelModelo.fromJson(Map<String, dynamic> json) {
    return ImovelModelo(
      id: json['id'] as String,
      nome: json['nome'] as String,
      endereco: json['endereco'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome, 'endereco': endereco};
  }

  factory ImovelModelo.fromEntity(ImovelEntidade entidade) {
    return ImovelModelo(
      id: entidade.id,
      nome: entidade.nome,
      endereco: entidade.endereco,
    );
  }

  ImovelEntidade toEntity() {
    return ImovelEntidade(id: id, nome: nome, endereco: endereco);
  }
}
