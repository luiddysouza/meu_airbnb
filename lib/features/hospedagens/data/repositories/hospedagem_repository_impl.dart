import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/failures.dart';
import '../../domain/entities/hospedagem_entity.dart';
import '../../domain/entities/imovel_entity.dart';
import '../../domain/repositories/hospedagem_repository.dart';
import '../datasources/hospedagem_local_datasource.dart';

/// Implementação concreta de [HospedagemRepository] que usa o datasource local.
///
/// Captura todas as exceções do datasource e as converte em [Left(CacheFailure)].
/// Sucessos são embrulhados em [Right].
class HospedagemRepositoryImpl implements HospedagemRepository {
  const HospedagemRepositoryImpl(this._dataSource);

  final HospedagemLocalDataSource _dataSource;

  @override
  Future<Either<Failure, List<HospedagemEntity>>> obterTodas() async {
    try {
      final hospedagens = await _dataSource.obterTodas();
      return Right(hospedagens);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter hospedagens: $e'));
    }
  }

  @override
  Future<Either<Failure, HospedagemEntity>> adicionar(
    HospedagemEntity hospedagem,
  ) async {
    try {
      final resultado = await _dataSource.adicionar(hospedagem);
      return Right(resultado);
    } catch (e) {
      return Left(CacheFailure('Erro ao adicionar hospedagem: $e'));
    }
  }

  @override
  Future<Either<Failure, HospedagemEntity>> atualizar(
    HospedagemEntity hospedagem,
  ) async {
    try {
      final resultado = await _dataSource.atualizar(hospedagem);
      return Right(resultado);
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar hospedagem: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletar(String id) async {
    try {
      await _dataSource.deletar(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar hospedagem: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ImovelEntity>>> obterImoveis() async {
    try {
      final imoveis = await _dataSource.obterImoveis();
      return Right(imoveis);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter imóveis: $e'));
    }
  }
}
