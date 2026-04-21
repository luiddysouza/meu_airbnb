import 'package:meu_airbnb/features/hospedagens/data/datasources/hospedagem_local_datasource.dart';
import 'package:mockito/annotations.dart';

/// Gera o MockHospedagemLocalDataSource usado nos testes do repositório.
///
/// Execute: `dart run build_runner build --delete-conflicting-outputs`
@GenerateMocks([HospedagemLocalDataSource])
void main() {}
