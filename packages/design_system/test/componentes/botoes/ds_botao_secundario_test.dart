import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsBotaoSecundario', () {
    testWidgets('renderiza com rotulo', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: DsBotaoSecundario(rotulo: 'Cancelar')),
      ));

      // Assert
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('dispara aoTocar ao pressionar', (WidgetTester tester) async {
      // Arrange
      var tocado = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DsBotaoSecundario(
            rotulo: 'Cancelar',
            aoTocar: () => tocado = true,
          ),
        ),
      ));

      // Act
      await tester.tap(find.byType(DsBotaoSecundario));
      await tester.pump();

      // Assert
      expect(tocado, isTrue);
    });

    testWidgets('exibe CircularProgressIndicator quando carregando',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: DsBotaoSecundario(rotulo: 'Cancelar', carregando: true),
        ),
      ));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cancelar'), findsNothing);
    });

    testWidgets('renderiza com icone', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: DsBotaoSecundario(rotulo: 'Editar', icone: Icons.edit),
        ),
      ));

      // Assert
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.text('Editar'), findsOneWidget);
    });
  });
}
