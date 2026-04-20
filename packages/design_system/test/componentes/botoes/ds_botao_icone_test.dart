import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsBotaoIcone', () {
    testWidgets('renderiza com icone', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: DsBotaoIcone(icone: Icons.delete)),
      ));

      // Assert
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('dispara aoTocar ao pressionar', (WidgetTester tester) async {
      // Arrange
      var tocado = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DsBotaoIcone(
            icone: Icons.delete,
            aoTocar: () => tocado = true,
          ),
        ),
      ));

      // Act
      await tester.tap(find.byType(DsBotaoIcone));
      await tester.pump();

      // Assert
      expect(tocado, isTrue);
    });

    testWidgets('exibe CircularProgressIndicator quando carregando',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: DsBotaoIcone(icone: Icons.delete, carregando: true),
        ),
      ));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renderiza Tooltip quando tooltip fornecido',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: DsBotaoIcone(icone: Icons.delete, tooltip: 'Excluir'),
        ),
      ));

      // Assert
      expect(find.byType(Tooltip), findsOneWidget);
    });
  });
}
