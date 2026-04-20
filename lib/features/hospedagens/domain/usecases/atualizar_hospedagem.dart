import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/hospedagem_entity.dart';
import '../repositories/hospedagem_repository.dart';

/// Atualiza uma hospedagem existente e retorna a entidade atualizada.
class AtualizarHospedagem
    implements UseCase<HospedagemEntity, HospedagemEntity> {
  const AtualizarHospedagem(this._repositorio);

  final HospedagemRepository _repositorio;

  @override
  Future<Either<Failure, HospedagemEntity>> call(HospedagemEntity params) {
    return _repositorio.atualizar(params);
  }
}
