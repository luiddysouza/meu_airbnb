import 'package:fpdart/fpdart.dart';

import '../erros/falhas.dart';

/// Contrato base para todos os use cases do domínio.
///
/// Cada use case recebe [Params] e retorna `Future<Either<Falha, Output>>`.
///
/// Para use cases sem parâmetros, use [SemParametros] como [Params].
///
/// Exemplo:
/// ```dart
/// class ObterHospedagens implements UseCase<List<HospedagemEntidade>, SemParametros> {
///   @override
///   Future<Either<Falha, List<HospedagemEntidade>>> chamar(SemParametros params) async {
///     return repositorio.obterTodas();
///   }
/// }
/// ```
abstract interface class UseCase<Output, Params> {
  Future<Either<Falha, Output>> chamar(Params params);
}

/// Tipo sentinela para use cases sem parâmetros.
final class SemParametros {
  const SemParametros();
}
