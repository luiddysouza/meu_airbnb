import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsEstadoVazio', () {
    testWidgets('renderiza mensagem', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DsEstadoVazio(mensagem: 'Nenhuma hospedagem encontrada'),
          ),
        ),
      );

      // Assert
      expect(find.text('Nenhuma hospedagem encontrada'), findsOneWidget);
    });

    testWidgets('renderiza icone padrao', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DsEstadoVazio(mensagem: 'Vazio')),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renderiza icone customizado quando fornecido', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DsEstadoVazio(
              mensagem: 'Sem filtros',
              icone: Icons.filter_list_off,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.filter_list_off), findsOneWidget);
    });

    testWidgets('renderiza botao de acao quando fornecido', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsEstadoVazio(
              mensagem: 'Vazio',
              rotuloAcao: 'Adicionar',
              aoAcionar: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Adicionar'), findsOneWidget);
    });

    testWidgets('dispara aoAcionar ao pressionar botao', (
      WidgetTester tester,
    ) async {
      // Arrange
      var acionado = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsEstadoVazio(
              mensagem: 'Vazio',
              rotuloAcao: 'Adicionar',
              aoAcionar: () => acionado = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Adicionar'));
      await tester.pump();

      // Assert
      expect(acionado, isTrue);
    });
  });

  group('DsCarregando', () {
    testWidgets('renderiza CircularProgressIndicator', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DsCarregando())),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renderiza mensagem quando fornecida', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DsCarregando(mensagem: 'Carregando...')),
        ),
      );

      // Assert
      expect(find.text('Carregando...'), findsOneWidget);
    });

    testWidgets('nao renderiza mensagem quando ausente', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DsCarregando())),
      );

      // Assert
      expect(find.byType(Text), findsNothing);
    });
  });
}
