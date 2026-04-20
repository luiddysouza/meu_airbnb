import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsTextField', () {
    testWidgets('renderiza com rotulo', (WidgetTester tester) async {
      // Arrange
      final controlador = TextEditingController();
      addTearDown(controlador.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsTextField(rotulo: 'Nome', controlador: controlador),
          ),
        ),
      );

      // Assert
      expect(find.text('Nome'), findsOneWidget);
    });

    testWidgets('exibe textoHelper quando fornecido', (
      WidgetTester tester,
    ) async {
      // Arrange
      final controlador = TextEditingController();
      addTearDown(controlador.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsTextField(
              rotulo: 'E-mail',
              controlador: controlador,
              textoHelper: 'Informe o e-mail de contato',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Informe o e-mail de contato'), findsOneWidget);
    });

    testWidgets('dispara aoMudar ao digitar', (WidgetTester tester) async {
      // Arrange
      String? valorCapturado;
      final controlador = TextEditingController();
      addTearDown(controlador.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsTextField(
              rotulo: 'Nome',
              controlador: controlador,
              aoMudar: (valor) => valorCapturado = valor,
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(DsTextField), 'Joao');
      await tester.pump();

      // Assert
      expect(valorCapturado, 'Joao');
    });

    testWidgets('exibe erro de validacao quando Form.validate() chamado', (
      WidgetTester tester,
    ) async {
      // Arrange
      final chaveFormulario = GlobalKey<FormState>();
      final controlador = TextEditingController();
      addTearDown(controlador.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: chaveFormulario,
              child: DsTextField(
                rotulo: 'Nome',
                controlador: controlador,
                validador: (valor) => (valor == null || valor.isEmpty)
                    ? 'Campo obrigatorio'
                    : null,
              ),
            ),
          ),
        ),
      );

      // Act
      chaveFormulario.currentState!.validate();
      await tester.pump();

      // Assert
      expect(find.text('Campo obrigatorio'), findsOneWidget);
    });
  });
}
