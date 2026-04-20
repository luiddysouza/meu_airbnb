import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/falhas.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositorios/hospedagem_repositorio.dart';

/// Remove a hospedagem com o id fornecido.
class DeletarHospedagem implements UseCase<void, String> {
  const DeletarHospedagem(this._repositorio);

  final HospedagemRepositorio _repositorio;

  @override
  Future<Either<Falha, void>> chamar(String params) {
    return _repositorio.deletar(params);
  }
}
