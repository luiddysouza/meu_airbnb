import 'package:mockito/annotations.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/repositorios/hospedagem_repositorio.dart';

/// Gera o MockHospedagemRepositorio usado nos testes de use cases.
///
/// Arquivo de entrada para build_runner. Execute:
/// `dart run build_runner build --delete-conflicting-outputs`
@GenerateMocks([HospedagemRepositorio])
void main() {}
