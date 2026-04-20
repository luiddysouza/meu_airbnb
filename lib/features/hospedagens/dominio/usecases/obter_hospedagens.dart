import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/falhas.dart';
import '../../../../core/usecases/usecase.dart';
import '../entidades/hospedagem_entidade.dart';
import '../repositorios/hospedagem_repositorio.dart';

/// Retorna a lista completa de hospedagens.
class ObterHospedagens
    implements UseCase<List<HospedagemEntidade>, SemParametros> {
  const ObterHospedagens(this._repositorio);

  final HospedagemRepositorio _repositorio;

  @override
  Future<Either<Falha, List<HospedagemEntidade>>> chamar(SemParametros params) {
    return _repositorio.obterTodas();
  }
}
