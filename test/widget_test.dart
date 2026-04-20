import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/main.dart';

void main() {
  testWidgets('MeuAirbnbApp renderiza sem erros', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuAirbnbApp());
    // Verifica apenas que o app renderiza sem lançar exceções.
    // O conteúdo da tela principal evolui a cada commit — não testar texto fixo.
    expect(find.byType(MeuAirbnbApp), findsOneWidget);
  });
}
