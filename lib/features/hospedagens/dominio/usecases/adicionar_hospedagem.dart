import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/falhas.dart';
import '../../../../core/usecases/usecase.dart';
import '../entidades/hospedagem_entidade.dart';
import '../repositorios/hospedagem_repositorio.dart';

/// Adiciona uma nova hospedagem e retorna a entidade persistida.
class AdicionarHospedagem
    implements UseCase<HospedagemEntidade, HospedagemEntidade> {
  const AdicionarHospedagem(this._repositorio);

  final HospedagemRepositorio _repositorio;

  @override
  Future<Either<Falha, HospedagemEntidade>> chamar(HospedagemEntidade params) {
    return _repositorio.adicionar(params);
  }
}
