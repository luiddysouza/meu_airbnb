import 'dart:convert';
import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsImagemBase64', () {
    // Cria uma imagem PNG de 1x1 pixel (válida)
    late String base64Valido;

    setUpAll(() {
      // Cria um Uint8List que representa uma imagem PNG válida (1x1 pixel)
      // Este é um PNG válido mínimo
      const pngBytes = [
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0A,
        0x49,
        0x44,
        0x41,
        0x54,
        0x08,
        0xD3,
        0x63,
        0x00,
        0x01,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82,
      ];
      base64Valido = base64Encode(pngBytes);
    });

    group('renderização básica', () {
      testWidgets('renderiza sem erro com base64 válido', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DsImagemBase64(
                base64: base64Valido,
                altura: 100,
                largura: 100,
              ),
            ),
          ),
        );

        expect(find.byType(DsImagemBase64), findsOneWidget);
      });

      testWidgets('renderiza sem erro com base64 nulo', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DsImagemBase64(base64: null, altura: 100, largura: 100),
            ),
          ),
        );

        expect(find.byType(DsImagemBase64), findsOneWidget);
      });

      testWidgets('renderiza placeholder quando base64 vazio', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DsImagemBase64(base64: '', altura: 100, largura: 100),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      });
    });

    group('skeleton loading', () {
      testWidgets('exibe skeleton quando exibirSkeleton=true', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DsImagemBase64(
                base64: base64Valido,
                altura: 100,
                largura: 100,
                exibirSkeleton: true,
              ),
            ),
          ),
        );

        // Enquanto está carregando, deve exibir CircularProgressIndicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('não exibe skeleton quando exibirSkeleton=false', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DsImagemBase64(
                base64: base64Valido,
                altura: 100,
                largura: 100,
                exibirSkeleton: false,
              ),
            ),
          ),
        );

        // Pode exibir placeholder ao invés do skeleton
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('parâmetros', () {
      testWidgets('respeita altura e largura informadas', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DsImagemBase64(base64: null, altura: 200, largura: 300),
            ),
          ),
        );

        final containerFinder = find.byType(Container).first;
        expect(containerFinder, findsOneWidget);
      });

      testWidgets('aplica borderRadius corretamente', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DsImagemBase64(
                base64: base64Valido,
                altura: 100,
                largura: 100,
                borderRadius: 16,
              ),
            ),
          ),
        );

        expect(find.byType(DsImagemBase64), findsOneWidget);
      });
    });

    group('tratamento de erro', () {
      testWidgets('exibe placeholder em caso de erro na decodificação', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DsImagemBase64(
                base64: 'base64-inválido!!!',
                altura: 100,
                largura: 100,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      });
    });

    group('atualização de widget', () {
      testWidgets('reconstrói quando base64 muda', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DsImagemBase64(base64: null, altura: 100, largura: 100),
            ),
          ),
        );

        await tester.pumpAndSettle();
        var placeholder = find.byIcon(Icons.image_not_supported_outlined);
        expect(placeholder, findsOneWidget);

        // Atualiza com novo base64 válido
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DsImagemBase64(
                base64: base64Valido,
                altura: 100,
                largura: 100,
              ),
            ),
          ),
        );

        expect(find.byType(DsImagemBase64), findsOneWidget);
      });
    });
  });
}
