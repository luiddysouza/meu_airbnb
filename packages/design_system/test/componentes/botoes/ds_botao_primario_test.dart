import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsBotaoPrimario', () {
    testWidgets('renderiza com rotulo', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: DsBotaoPrimario(rotulo: 'Salvar')),
      ));

      // Assert
      expect(find.text('Salvar'), findsOneWidget);
    });

    testWidgets('dispara aoTocar ao pressionar', (WidgetTester tester) async {
      // Arrange
      var tocado = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DsBotaoPrimario(
            rotulo: 'Salvar',
            aoTocar: () => tocado = true,
          ),
        ),
      ));

      // Act
      await tester.tap(find.byType(DsBotaoPrimario));
      await tester.pump();

      // Assert
      expect(tocado, isTrue);
    });

    testWidgets('exibe CircularProgressIndicator quando carregando',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: DsBotaoPrimario(rotulo: 'Salvar', carregando: true),
        ),
      ));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Salvar'), findsNothing);
    });

    testWidgets('renderiza com icone', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: DsBotaoPrimario(rotulo: 'Adicionar', icone: Icons.add),
        ),
      ));

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Adicionar'), findsOneWidget);
    });

    testWidgets('nao dispara quando aoTocar e nulo', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: DsBotaoPrimario(rotulo: 'Salvar')),
      ));

      // Act & Assert (nao deve lancar excecao)
      await tester.tap(find.byType(DsBotaoPrimario), warnIfMissed: false);
      await tester.pump();
    });
  });
}
