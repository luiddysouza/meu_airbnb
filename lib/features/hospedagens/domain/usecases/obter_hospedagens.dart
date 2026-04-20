import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/hospedagem_entity.dart';
import '../repositories/hospedagem_repository.dart';

/// Retorna a lista completa de hospedagens.
class ObterHospedagens
    implements UseCase<List<HospedagemEntity>, NoParams> {
  const ObterHospedagens(this._repositorio);

  final HospedagemRepository _repositorio;

  @override
  Future<Either<Failure, List<HospedagemEntity>>> call(NoParams params) {
    return _repositorio.obterTodas();
  }
}
