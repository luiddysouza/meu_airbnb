import 'package:equatable/equatable.dart';

/// Classe base para todos os erros do domínio.
///
/// Use cases retornam `Either<Failure, T>` em vez de lançar exceções.
abstract class Failure extends Equatable {
  const Failure(this.mensagem);

  final String mensagem;

  @override
  List<Object?> get props => [mensagem];
}

/// Failure originada de operação de leitura/escrita em cache (datasource local).
final class CacheFailure extends Failure {
  const CacheFailure(super.mensagem);
}

/// Failure originada de chamada a servidor remoto.
final class ServerFailure extends Failure {
  const ServerFailure(super.mensagem);
}
