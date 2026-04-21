import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/core/sdui/factory/widget_factory.dart';
import 'package:meu_airbnb/core/sdui/models/sdui_node.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

/// Builder simples usado como stub nos testes.
Widget _builderSentinela(
  BuildContext ctx,
  SduiNode no,
  Widget Function(BuildContext, SduiNode) _,
) => Text('sentinela:${no.tipo}');

/// Builder que renderiza um nó filho (para testar o callback renderizarFilho).
Widget _builderComFilho(
  BuildContext ctx,
  SduiNode no,
  Widget Function(BuildContext, SduiNode) renderizarFilho,
) {
  if (no.filhos.isEmpty) return const SizedBox.shrink();
  return renderizarFilho(ctx, no.filhos.first);
}

// ---------------------------------------------------------------------------
// Testes
// ---------------------------------------------------------------------------

void main() {
  // ── API básica do registry ─────────────────────────────────────────────────

  group('WidgetFactory — registry', () {
    test('temTipo retorna false para tipo não registrado', () {
      // Arrange
      final fabrica = WidgetFactory();

      // Act + Assert
      expect(fabrica.temTipo('tipo_inexistente'), isFalse);
    });

    test('temTipo retorna true após registrar um tipo', () {
      // Arrange
      final fabrica = WidgetFactory();

      // Act
      fabrica.registrar('meu_tipo', _builderSentinela);

      // Assert
      expect(fabrica.temTipo('meu_tipo'), isTrue);
    });

    test('registrar sobrescreve builder existente', () {
      // Arrange
      final fabrica = WidgetFactory();
      fabrica.registrar('tipo_a', _builderSentinela);

      // Act — sobrescreve com novo builder
      fabrica.registrar('tipo_a', _builderComFilho);

      // Assert — ainda tem o tipo
      expect(fabrica.temTipo('tipo_a'), isTrue);
    });

    test('temTipo retorna false para tipo diferente do registrado', () {
      // Arrange
      final fabrica = WidgetFactory();
      fabrica.registrar('tipo_a', _builderSentinela);

      // Act + Assert
      expect(fabrica.temTipo('tipo_b'), isFalse);
    });
  });

  // ── construir ──────────────────────────────────────────────────────────────

  group('WidgetFactory — construir', () {
    testWidgets('retorna SizedBox.shrink para tipo não registrado (fallback)', (
      tester,
    ) async {
      // Arrange
      final fabrica = WidgetFactory();
      const no = SduiNode(tipo: 'tipo_desconhecido');

      // Act
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (ctx) =>
                fabrica.construir(ctx, no, (c, n) => const SizedBox()),
          ),
        ),
      );

      // Assert — apenas SizedBox sem texto
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('sentinela:tipo_desconhecido'), findsNothing);
    });

    testWidgets('chama o builder registrado para o tipo do nó', (tester) async {
      // Arrange
      final fabrica = WidgetFactory();
      fabrica.registrar('rotulo', _builderSentinela);
      const no = SduiNode(tipo: 'rotulo');

      // Act
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (ctx) =>
                fabrica.construir(ctx, no, (c, n) => const SizedBox()),
          ),
        ),
      );

      // Assert — texto 'sentinela:rotulo' renderizado pelo builder
      expect(find.text('sentinela:rotulo'), findsOneWidget);
    });

    testWidgets('passa renderizarFilho corretamente para o builder', (
      tester,
    ) async {
      // Arrange
      final fabrica = WidgetFactory();
      fabrica.registrar('pai', _builderComFilho);
      fabrica.registrar('filho', _builderSentinela);

      const no = SduiNode(
        tipo: 'pai',
        filhos: [SduiNode(tipo: 'filho')],
      );

      // Act
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (ctx) => fabrica.construir(
              ctx,
              no,
              (c, n) => fabrica.construir(c, n, (_, _) => const SizedBox()),
            ),
          ),
        ),
      );

      // Assert — builder do filho foi invocado
      expect(find.text('sentinela:filho'), findsOneWidget);
    });

    testWidgets('não usa builder de outro tipo registrado (isolamento)', (
      tester,
    ) async {
      // Arrange
      final fabrica = WidgetFactory();
      fabrica.registrar('tipo_a', _builderSentinela);
      const no = SduiNode(tipo: 'tipo_b');

      // Act
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (ctx) =>
                fabrica.construir(ctx, no, (c, n) => const SizedBox()),
          ),
        ),
      );

      // Assert — builder de tipo_a não foi chamado
      expect(find.text('sentinela:tipo_a'), findsNothing);
      expect(find.text('sentinela:tipo_b'), findsNothing);
    });
  });

  // ── WidgetFactory.padrao ───────────────────────────────────────────────────

  group('WidgetFactory.padrao', () {
    test('registra todos os 7 tipos SDUI do schema', () {
      // Arrange + Act
      final fabrica = WidgetFactory.padrao();

      // Assert — tipos definidos na tabela do PLANO_DE_ACAO e docs/SDUI.md
      expect(fabrica.temTipo('seletor_data_range'), isTrue);
      expect(fabrica.temTipo('dropdown'), isTrue);
      expect(fabrica.temTipo('lista'), isTrue);
      expect(fabrica.temTipo('card_hospedagem'), isTrue);
      expect(fabrica.temTipo('botao_primario'), isTrue);
      expect(fabrica.temTipo('estado_vazio'), isTrue);
      expect(fabrica.temTipo('carregando'), isTrue);
    });

    test('não registra tipo fora do schema', () {
      // Arrange + Act
      final fabrica = WidgetFactory.padrao();

      // Assert
      expect(fabrica.temTipo('tipo_fora_do_schema'), isFalse);
    });

    test('pode ser instanciada múltiplas vezes sem conflito', () {
      // Arrange + Act
      final fabrica1 = WidgetFactory.padrao();
      final fabrica2 = WidgetFactory.padrao();

      // Assert — instâncias independentes
      expect(fabrica1.temTipo('botao_primario'), isTrue);
      expect(fabrica2.temTipo('botao_primario'), isTrue);
    });

    test('novo builder registrado após padrao() não afeta outra instância', () {
      // Arrange
      final fabrica1 = WidgetFactory.padrao();
      final fabrica2 = WidgetFactory.padrao();

      // Act
      fabrica1.registrar('tipo_extra', _builderSentinela);

      // Assert — fabrica2 não tem o tipo extra
      expect(fabrica1.temTipo('tipo_extra'), isTrue);
      expect(fabrica2.temTipo('tipo_extra'), isFalse);
    });
  });
}
