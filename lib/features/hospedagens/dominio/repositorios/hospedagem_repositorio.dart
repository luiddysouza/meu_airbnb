import 'package:fpdart/fpdart.dart';

import '../../../../core/erros/falhas.dart';
import '../entidades/hospedagem_entidade.dart';
import '../entidades/imovel_entidade.dart';

/// Contrato do repositório de hospedagens.
///
/// A camada de domínio depende apenas desta interface.
/// A implementação concreta fica em `data/repositorios/`.
abstract interface class HospedagemRepositorio {
  /// Retorna todas as hospedagens cadastradas.
  Future<Either<Falha, List<HospedagemEntidade>>> obterTodas();

  /// Adiciona uma nova hospedagem e retorna a entidade persistida.
  Future<Either<Falha, HospedagemEntidade>> adicionar(
    HospedagemEntidade hospedagem,
  );

  /// Atualiza uma hospedagem existente e retorna a entidade atualizada.
  Future<Either<Falha, HospedagemEntidade>> atualizar(
    HospedagemEntidade hospedagem,
  );

  /// Remove a hospedagem com o [id] fornecido.
  Future<Either<Falha, void>> deletar(String id);

  /// Retorna todos os imóveis cadastrados.
  Future<Either<Falha, List<ImovelEntidade>>> obterImoveis();
}
