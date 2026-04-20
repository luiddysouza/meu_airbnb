import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsListTile', () {
    testWidgets('renderiza titulo', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DsListTile(titulo: 'Item 1')),
        ),
      );

      // Assert
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('renderiza subtitulo quando fornecido', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DsListTile(titulo: 'Item 1', subtitulo: 'Detalhe do item'),
          ),
        ),
      );

      // Assert
      expect(find.text('Detalhe do item'), findsOneWidget);
    });

    testWidgets('dispara aoTocar ao pressionar', (WidgetTester tester) async {
      // Arrange
      var tocado = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsListTile(titulo: 'Item 1', aoTocar: () => tocado = true),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(DsListTile));
      await tester.pump();

      // Assert
      expect(tocado, isTrue);
    });

    testWidgets('nao dispara aoTocar quando desabilitado', (
      WidgetTester tester,
    ) async {
      // Arrange
      var tocado = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsListTile(
              titulo: 'Item 1',
              habilitado: false,
              aoTocar: () => tocado = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(DsListTile), warnIfMissed: false);
      await tester.pump();

      // Assert
      expect(tocado, isFalse);
    });

    testWidgets('renderiza leading e trailing quando fornecidos', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DsListTile(
              titulo: 'Item',
              leading: Icon(Icons.home),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
