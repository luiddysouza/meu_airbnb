import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/main.dart';

void main() {
  testWidgets('MeuAirbnbApp renderiza sem erros', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuAirbnbApp());
    expect(find.text('meu_airbnb — em construção'), findsOneWidget);
  });
}
