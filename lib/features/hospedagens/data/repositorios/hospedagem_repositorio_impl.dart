import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/falhas.dart';
import '../../dominio/entidades/hospedagem_entidade.dart';
import '../../dominio/entidades/imovel_entidade.dart';
import '../../dominio/repositorios/hospedagem_repositorio.dart';
import '../datasources/hospedagem_local_datasource.dart';

/// Implementação concreta de [HospedagemRepositorio] que usa o datasource local.
///
/// Captura todas as exceções do datasource e as converte em [Left(FalhaCache)].
/// Sucessos são embrulhados em [Right].
class HospedagemRepositorioImpl implements HospedagemRepositorio {
  const HospedagemRepositorioImpl(this._dataSource);

  final HospedagemLocalDataSource _dataSource;

  @override
  Future<Either<Falha, List<HospedagemEntidade>>> obterTodas() async {
    try {
      final hospedagens = await _dataSource.obterTodas();
      return Right(hospedagens);
    } catch (e) {
      return Left(FalhaCache('Erro ao obter hospedagens: $e'));
    }
  }

  @override
  Future<Either<Falha, HospedagemEntidade>> adicionar(
    HospedagemEntidade hospedagem,
  ) async {
    try {
      final resultado = await _dataSource.adicionar(hospedagem);
      return Right(resultado);
    } catch (e) {
      return Left(FalhaCache('Erro ao adicionar hospedagem: $e'));
    }
  }

  @override
  Future<Either<Falha, HospedagemEntidade>> atualizar(
    HospedagemEntidade hospedagem,
  ) async {
    try {
      final resultado = await _dataSource.atualizar(hospedagem);
      return Right(resultado);
    } catch (e) {
      return Left(FalhaCache('Erro ao atualizar hospedagem: $e'));
    }
  }

  @override
  Future<Either<Falha, void>> deletar(String id) async {
    try {
      await _dataSource.deletar(id);
      return const Right(null);
    } catch (e) {
      return Left(FalhaCache('Erro ao deletar hospedagem: $e'));
    }
  }

  @override
  Future<Either<Falha, List<ImovelEntidade>>> obterImoveis() async {
    try {
      final imoveis = await _dataSource.obterImoveis();
      return Right(imoveis);
    } catch (e) {
      return Left(FalhaCache('Erro ao obter imóveis: $e'));
    }
  }
}
