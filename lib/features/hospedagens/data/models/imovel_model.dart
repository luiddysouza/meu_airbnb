import '../../domain/entities/imovel_entity.dart';

/// Modelo de dados para [ImovelEntity].
///
/// Responsável pela serialização/deserialização JSON e pela conversão
/// de/para a entidade de domínio.
class ImovelModel {
  const ImovelModel({required this.id, required this.nome, this.endereco});

  final String id;
  final String nome;
  final String? endereco;

  factory ImovelModel.fromJson(Map<String, dynamic> json) {
    return ImovelModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      endereco: json['endereco'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome, 'endereco': endereco};
  }

  factory ImovelModel.fromEntity(ImovelEntity entidade) {
    return ImovelModel(
      id: entidade.id,
      nome: entidade.nome,
      endereco: entidade.endereco,
    );
  }

  ImovelEntity toEntity() {
    return ImovelEntity(id: id, nome: nome, endereco: endereco);
  }
}
