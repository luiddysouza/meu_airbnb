import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/hospedagem_entity.dart';
import '../repositories/hospedagem_repository.dart';

/// Adiciona uma nova hospedagem e retorna a entidade persistida.
class AdicionarHospedagem
    implements UseCase<HospedagemEntity, HospedagemEntity> {
  const AdicionarHospedagem(this._repositorio);

  final HospedagemRepository _repositorio;

  @override
  Future<Either<Failure, HospedagemEntity>> call(HospedagemEntity params) {
    return _repositorio.adicionar(params);
  }
}
