import 'package:fpdart/fpdart.dart';

import '../erros/failures.dart';

/// Contrato base para todos os use cases do domínio.
///
/// Cada use case recebe [Params] e retorna `Future<Either<Failure, Output>>`.
///
/// Para use cases sem parâmetros, use [NoParams] como [Params].
///
/// Exemplo:
/// ```dart
/// class ObterHospedagens implements UseCase<List<HospedagemEntity>, NoParams> {
///   @override
///   Future<Either<Failure, List<HospedagemEntity>>> call(NoParams params) async {
///     return repositorio.obterTodas();
///   }
/// }
/// ```
abstract interface class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}

/// Tipo sentinela para use cases sem parâmetros.
final class NoParams {
  const NoParams();
}
