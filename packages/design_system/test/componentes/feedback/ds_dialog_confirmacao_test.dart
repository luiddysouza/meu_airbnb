import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsDialogConfirmacao', () {
    testWidgets('exibe titulo e mensagem no dialog', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => DsDialogConfirmacao.mostrar(
                  ctx,
                  titulo: 'Excluir item',
                  mensagem: 'Tem certeza?',
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Excluir item'), findsOneWidget);
      expect(find.text('Tem certeza?'), findsOneWidget);
    });

    testWidgets('exibe botoes com rotulos padrao', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => DsDialogConfirmacao.mostrar(
                  ctx,
                  titulo: 'Título',
                  mensagem: 'Mensagem',
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Confirmar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('exibe rotulos customizados quando fornecidos', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => DsDialogConfirmacao.mostrar(
                  ctx,
                  titulo: 'Remover',
                  mensagem: 'Deseja remover?',
                  rotuloConfirmar: 'Sim, remover',
                  rotuloCancelar: 'Não',
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Sim, remover'), findsOneWidget);
      expect(find.text('Não'), findsOneWidget);
    });

    testWidgets('retorna false ao tocar em cancelar', (tester) async {
      // Arrange
      bool? resultado;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () async {
                  resultado = await DsDialogConfirmacao.mostrar(
                    ctx,
                    titulo: 'Título',
                    mensagem: 'Mensagem',
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Assert
      expect(resultado, isFalse);
    });

    testWidgets('retorna true ao tocar em confirmar', (tester) async {
      // Arrange
      bool? resultado;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () async {
                  resultado = await DsDialogConfirmacao.mostrar(
                    ctx,
                    titulo: 'Título',
                    mensagem: 'Mensagem',
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      // Assert
      expect(resultado, isTrue);
    });

    testWidgets('fecha o dialog ao tocar em cancelar', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => DsDialogConfirmacao.mostrar(
                  ctx,
                  titulo: 'Título',
                  mensagem: 'Mensagem',
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Assert — dialog fechou
      expect(find.text('Título'), findsNothing);
    });

    testWidgets('renderiza sem erros com destrutivo=true', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => DsDialogConfirmacao.mostrar(
                  ctx,
                  titulo: 'Excluir',
                  mensagem: 'Ação irreversível',
                  destrutivo: true,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Assert
      expect(tester.takeException(), isNull);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
