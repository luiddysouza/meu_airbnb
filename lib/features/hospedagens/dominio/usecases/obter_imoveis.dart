import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/falhas.dart';
import '../../../../core/usecases/usecase.dart';
import '../entidades/imovel_entidade.dart';
import '../repositorios/hospedagem_repositorio.dart';

/// Retorna a lista de imóveis cadastrados.
class ObterImoveis implements UseCase<List<ImovelEntidade>, SemParametros> {
  const ObterImoveis(this._repositorio);

  final HospedagemRepositorio _repositorio;

  @override
  Future<Either<Falha, List<ImovelEntidade>>> chamar(SemParametros params) {
    return _repositorio.obterImoveis();
  }
}
