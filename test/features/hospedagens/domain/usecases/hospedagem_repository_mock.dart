import 'package:meu_airbnb/features/hospedagens/domain/repositories/hospedagem_repository.dart';
import 'package:mockito/annotations.dart';

/// Gera o MockHospedagemRepository usado nos testes de use cases.
///
/// Arquivo de entrada para build_runner. Execute:
/// `dart run build_runner build --delete-conflicting-outputs`
@GenerateMocks([HospedagemRepository])
void main() {}
