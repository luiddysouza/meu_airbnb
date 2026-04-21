import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/core/di/injecao.dart';
import 'package:meu_airbnb/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await inicializarDependencias();
  });

  tearDownAll(() async {
    await sl.reset();
  });

  testWidgets('MeuAirbnbApp renderiza sem erros', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuAirbnbApp());
    // pumpAndSettle aguarda os timers de latência simulada do datasource (300ms)
    await tester.pumpAndSettle(const Duration(seconds: 5));
    // Verifica apenas que o app renderiza sem lançar exceções.
    // O conteúdo da tela principal evolui a cada commit — não testar texto fixo.
    expect(find.byType(MeuAirbnbApp), findsOneWidget);
  });
}
