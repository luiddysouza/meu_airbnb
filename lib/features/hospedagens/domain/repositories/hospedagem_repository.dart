import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/failures.dart';
import '../entities/hospedagem_entity.dart';
import '../entities/imovel_entity.dart';

/// Contrato do repositório de hospedagens.
///
/// A camada de domínio depende apenas desta interface.
/// A implementação concreta fica em `data/repositories/`.
abstract interface class HospedagemRepository {
  /// Retorna todas as hospedagens cadastradas.
  Future<Either<Failure, List<HospedagemEntity>>> obterTodas();

  /// Adiciona uma nova hospedagem e retorna a entidade persistida.
  Future<Either<Failure, HospedagemEntity>> adicionar(
    HospedagemEntity hospedagem,
  );

  /// Atualiza uma hospedagem existente e retorna a entidade atualizada.
  Future<Either<Failure, HospedagemEntity>> atualizar(
    HospedagemEntity hospedagem,
  );

  /// Remove a hospedagem com o [id] fornecido.
  Future<Either<Failure, void>> deletar(String id);

  /// Retorna todos os imóveis cadastrados.
  Future<Either<Failure, List<ImovelEntity>>> obterImoveis();
}
