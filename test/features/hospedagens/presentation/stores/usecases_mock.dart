import 'package:meu_airbnb/features/hospedagens/domain/usecases/adicionar_hospedagem.dart';
import 'package:meu_airbnb/features/hospedagens/domain/usecases/atualizar_hospedagem.dart';
import 'package:meu_airbnb/features/hospedagens/domain/usecases/deletar_hospedagem.dart';
import 'package:meu_airbnb/features/hospedagens/domain/usecases/obter_hospedagens.dart';
import 'package:meu_airbnb/features/hospedagens/domain/usecases/obter_imoveis.dart';
import 'package:mockito/annotations.dart';

/// Gera mocks dos use cases usados pelos stores MobX.
///
/// Execute: `dart run build_runner build --delete-conflicting-outputs`
@GenerateMocks([
  ObterHospedagens,
  AdicionarHospedagem,
  AtualizarHospedagem,
  DeletarHospedagem,
  ObterImoveis,
])
void main() {}
