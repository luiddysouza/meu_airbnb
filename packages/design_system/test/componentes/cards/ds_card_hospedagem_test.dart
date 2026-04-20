import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final checkIn = DateTime(2026, 4, 20);
  final checkOut = DateTime(2026, 4, 25);

  group('DsCardHospedagem', () {
    testWidgets('renderiza nome do hospede e valor', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsCardHospedagem(
              nomeHospede: 'Ana Paula',
              checkIn: checkIn,
              checkOut: checkOut,
              status: StatusHospedagemDs.confirmada,
              valorTotal: 1850.00,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Ana Paula'), findsOneWidget);
      expect(find.text('R\$ 1850,00'), findsOneWidget);
    });

    testWidgets('renderiza badge de status correto', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsCardHospedagem(
              nomeHospede: 'Carlos',
              checkIn: checkIn,
              checkOut: checkOut,
              status: StatusHospedagemDs.pendente,
              valorTotal: 620.00,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Pendente'), findsOneWidget);
    });

    testWidgets('renderiza datas formatadas', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsCardHospedagem(
              nomeHospede: 'Mariana',
              checkIn: checkIn,
              checkOut: checkOut,
              status: StatusHospedagemDs.confirmada,
              valorTotal: 4200.00,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('20/04/2026'), findsOneWidget);
      expect(find.textContaining('25/04/2026'), findsOneWidget);
    });

    testWidgets('renderiza nome do imovel quando fornecido', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsCardHospedagem(
              nomeHospede: 'Pedro',
              checkIn: checkIn,
              checkOut: checkOut,
              status: StatusHospedagemDs.confirmada,
              valorTotal: 900.00,
              nomeImovel: 'Apto Centro SP',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Apto Centro SP'), findsOneWidget);
    });

    testWidgets('dispara aoEditar e aoDeletar', (WidgetTester tester) async {
      // Arrange
      var editado = false;
      var deletado = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsCardHospedagem(
              nomeHospede: 'Sofia',
              checkIn: checkIn,
              checkOut: checkOut,
              status: StatusHospedagemDs.confirmada,
              valorTotal: 750.00,
              aoEditar: () => editado = true,
              aoDeletar: () => deletado = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      // Assert
      expect(editado, isTrue);
      expect(deletado, isTrue);
    });

    testWidgets('exibe todos os badges de status sem erro', (
      WidgetTester tester,
    ) async {
      for (final status in StatusHospedagemDs.values) {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DsCardHospedagem(
                nomeHospede: 'Teste',
                checkIn: checkIn,
                checkOut: checkOut,
                status: status,
                valorTotal: 100.00,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(DsCardHospedagem), findsOneWidget);
      }
    });
  });
}
