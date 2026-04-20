import 'package:equatable/equatable.dart';

/// Classe base para todos os erros do domínio.
///
/// Use cases retornam `Either<Falha, T>` em vez de lançar exceções.
abstract class Falha extends Equatable {
  const Falha(this.mensagem);

  final String mensagem;

  @override
  List<Object?> get props => [mensagem];
}

/// Falha originada de operação de leitura/escrita em cache (datasource local).
final class FalhaCache extends Falha {
  const FalhaCache(super.mensagem);
}

/// Falha originada de chamada a servidor remoto.
final class FalhaServidor extends Falha {
  const FalhaServidor(super.mensagem);
}
