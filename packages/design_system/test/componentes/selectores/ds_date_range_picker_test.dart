import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DsDateRangePicker', () {
    testWidgets('renderiza com rotulos', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsDateRangePicker(
              rotuloInicio: 'Check-in',
              rotuloFim: 'Check-out',
              aoSelecionar: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Check-in'), findsOneWidget);
      expect(find.text('Check-out'), findsOneWidget);
    });

    testWidgets('exibe traco quando sem periodo selecionado', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsDateRangePicker(
              rotuloInicio: 'Check-in',
              rotuloFim: 'Check-out',
              aoSelecionar: (_) {},
            ),
          ),
        ),
      );

      // Assert — exibe "—" para as duas datas nao selecionadas
      expect(find.text('—'), findsNWidgets(2));
    });

    testWidgets('exibe datas formatadas quando periodo selecionado', (
      WidgetTester tester,
    ) async {
      // Arrange
      final periodo = DateTimeRange(
        start: DateTime(2026, 4, 20),
        end: DateTime(2026, 4, 25),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsDateRangePicker(
              rotuloInicio: 'Check-in',
              rotuloFim: 'Check-out',
              periodoSelecionado: periodo,
              aoSelecionar: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('20/04/2026'), findsOneWidget);
      expect(find.text('25/04/2026'), findsOneWidget);
    });

    testWidgets('exibe icone de calendario', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DsDateRangePicker(
              rotuloInicio: 'Check-in',
              rotuloFim: 'Check-out',
              aoSelecionar: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.calendar_today), findsNWidgets(2));
    });
  });
}
