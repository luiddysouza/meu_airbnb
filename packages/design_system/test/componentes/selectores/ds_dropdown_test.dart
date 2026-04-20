import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsDropdown', () {
    const opcoes = [
      DsOpcaoDropdown(valor: 'op1', rotulo: 'Opcao 1'),
      DsOpcaoDropdown(valor: 'op2', rotulo: 'Opcao 2'),
    ];

    testWidgets('renderiza com rotulo', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DsDropdown(
            rotulo: 'Imovel',
            opcoes: opcoes,
            aoSelecionar: (_) {},
          ),
        ),
      ));

      // Assert
      expect(find.text('Imovel'), findsOneWidget);
    });

    testWidgets('dispara aoSelecionar ao escolher opcao',
        (WidgetTester tester) async {
      // Arrange
      String? valorSelecionado;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DsDropdown(
            rotulo: 'Imovel',
            opcoes: opcoes,
            aoSelecionar: (valor) => valorSelecionado = valor,
          ),
        ),
      ));

      // Act
      await tester.tap(find.byType(DsDropdown));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Opcao 1').last);
      await tester.pumpAndSettle();

      // Assert
      expect(valorSelecionado, 'op1');
    });

    testWidgets('exibe valor selecionado quando valorSelecionado fornecido',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DsDropdown(
            rotulo: 'Imovel',
            opcoes: opcoes,
            valorSelecionado: 'op2',
            aoSelecionar: (_) {},
          ),
        ),
      ));

      // Assert
      expect(find.text('Opcao 2'), findsOneWidget);
    });

    testWidgets('nao dispara aoSelecionar quando desabilitado',
        (WidgetTester tester) async {
      // Arrange
      var chamado = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DsDropdown(
            rotulo: 'Imovel',
            opcoes: opcoes,
            habilitado: false,
            aoSelecionar: (_) => chamado = true,
          ),
        ),
      ));

      // Act
      await tester.tap(find.byType(DsDropdown), warnIfMissed: false);
      await tester.pump();

      // Assert
      expect(chamado, isFalse);
    });
  });
}
