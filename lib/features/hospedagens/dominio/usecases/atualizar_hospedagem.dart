import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/falhas.dart';
import '../../../../core/usecases/usecase.dart';
import '../entidades/hospedagem_entidade.dart';
import '../repositorios/hospedagem_repositorio.dart';

/// Atualiza uma hospedagem existente e retorna a entidade atualizada.
class AtualizarHospedagem
    implements UseCase<HospedagemEntidade, HospedagemEntidade> {
  const AtualizarHospedagem(this._repositorio);

  final HospedagemRepositorio _repositorio;

  @override
  Future<Either<Falha, HospedagemEntidade>> chamar(HospedagemEntidade params) {
    return _repositorio.atualizar(params);
  }
}
