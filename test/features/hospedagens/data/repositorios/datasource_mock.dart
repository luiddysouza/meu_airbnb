import 'package:mockito/annotations.dart';
import 'package:meu_airbnb/features/hospedagens/data/datasources/hospedagem_local_datasource.dart';

/// Gera o MockHospedagemLocalDataSource usado nos testes do repositório.
///
/// Execute: `dart run build_runner build --delete-conflicting-outputs`
@GenerateMocks([HospedagemLocalDataSource])
void main() {}
