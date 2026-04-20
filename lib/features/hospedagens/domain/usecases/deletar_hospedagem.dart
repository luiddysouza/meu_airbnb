import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/hospedagem_repository.dart';

/// Remove a hospedagem com o id fornecido.
class DeletarHospedagem implements UseCase<void, String> {
  const DeletarHospedagem(this._repositorio);

  final HospedagemRepository _repositorio;

  @override
  Future<Either<Failure, void>> call(String params) {
    return _repositorio.deletar(params);
  }
}
