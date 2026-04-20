import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/imovel_entity.dart';
import '../repositories/hospedagem_repository.dart';

/// Retorna a lista de imóveis cadastrados.
class ObterImoveis implements UseCase<List<ImovelEntity>, NoParams> {
  const ObterImoveis(this._repositorio);

  final HospedagemRepository _repositorio;

  @override
  Future<Either<Failure, List<ImovelEntity>>> call(NoParams params) {
    return _repositorio.obterImoveis();
  }
}
