import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsAppBarAdaptativa', () {
    testWidgets('renderiza titulo', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(appBar: DsAppBarAdaptativa(titulo: 'Hospedagens')),
        ),
      );

      // Assert
      expect(find.text('Hospedagens'), findsOneWidget);
    });

    testWidgets('renderiza acoes quando fornecidas', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: DsAppBarAdaptativa(
              titulo: 'Hospedagens',
              acoes: [Icon(Icons.add)],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('implementa PreferredSizeWidget com altura correta', (
      WidgetTester tester,
    ) async {
      // Arrange
      const appBar = DsAppBarAdaptativa(titulo: 'Teste');

      // Assert
      expect(appBar.preferredSize.height, equals(kToolbarHeight));
    });
  });

  group('DsScaffoldResponsivo', () {
    testWidgets('renderiza titulo e conteudo principal', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: DsScaffoldResponsivo(
            titulo: 'Hospedagens',
            conteudoPrincipal: Text('Lista aqui'),
          ),
        ),
      );

      // Assert
      expect(find.text('Hospedagens'), findsOneWidget);
      expect(find.text('Lista aqui'), findsOneWidget);
    });

    testWidgets(
      'renderiza sidebar no layout mobile (largura < breakpointTablet)',
      (WidgetTester tester) async {
        // Arrange — viewport mobile
        tester.view.physicalSize = const Size(599, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(
            home: DsScaffoldResponsivo(
              titulo: 'Hospedagens',
              conteudoSidebar: Text('Filtros'),
              conteudoPrincipal: Text('Lista'),
            ),
          ),
        );

        // Assert — ambos visíveis em mobile (coluna única com scroll)
        expect(find.text('Filtros'), findsOneWidget);
        expect(find.text('Lista'), findsOneWidget);
      },
    );

    testWidgets(
      'renderiza sidebar no layout desktop (largura >= breakpointTablet)',
      (WidgetTester tester) async {
        // Arrange — viewport desktop
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(
            home: DsScaffoldResponsivo(
              titulo: 'Hospedagens',
              conteudoSidebar: Text('Filtros'),
              conteudoPrincipal: Text('Lista'),
            ),
          ),
        );

        // Assert — sidebar e conteúdo em Row (desktop)
        expect(find.text('Filtros'), findsOneWidget);
        expect(find.text('Lista'), findsOneWidget);
      },
    );

    testWidgets('renderiza FAB quando fornecido', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: DsScaffoldResponsivo(
            titulo: 'Hospedagens',
            conteudoPrincipal: const Text('Lista'),
            botaoAcaoFlutuante: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
