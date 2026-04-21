import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:meu_airbnb/core/erros/failures.dart';
import 'package:meu_airbnb/core/sdui/factory/widget_factory.dart';
import 'package:meu_airbnb/core/sdui/models/sdui_node.dart';
import 'package:meu_airbnb/core/sdui/renderer/sdui_renderer.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/imovel_entity.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/filtro_store.dart';
import 'package:mockito/mockito.dart';

import '../../features/hospedagens/presentation/stores/usecases_mock.mocks.dart';

Widget _app(Widget child) => MaterialApp(
  theme: DsTemaApp.tema,
  home: Scaffold(body: child),
);

void main() {
  // ===== WidgetFactory =====
  group('WidgetFactory', () {
    late WidgetFactory fabrica;

    setUp(() => fabrica = WidgetFactory());

    test('registrar adiciona tipo ao registro', () {
      // Arrange + Act
      fabrica.registrar('teste', (_, _, _) => const SizedBox());

      // Assert
      expect(fabrica.temTipo('teste'), isTrue);
    });

    test('tipo não registrado retorna false', () {
      expect(fabrica.temTipo('desconhecido'), isFalse);
    });

    test('registrar sobrescreve builder existente', () {
      // Arrange
      fabrica.registrar('tipo', (_, _, _) => const Text('primeiro'));
      fabrica.registrar('tipo', (_, _, _) => const Text('segundo'));

      // Assert — apenas o segundo deve estar no registro
      expect(fabrica.temTipo('tipo'), isTrue);
    });

    testWidgets('construir chama builder registrado', (tester) async {
      // Arrange
      fabrica.registrar(
        'rotulo',
        (_, no, _) => Text(no.propriedades['valor'] as String),
      );

      // Act
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (ctx) => fabrica.construir(
              ctx,
              const SduiNode(tipo: 'rotulo', propriedades: {'valor': 'Olá'}),
              (c, n) => fabrica.construir(c, n, (_, _) => const SizedBox()),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Olá'), findsOneWidget);
    });

    testWidgets('construir retorna SizedBox.shrink para tipo não registrado', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (ctx) => fabrica.construir(
              ctx,
              const SduiNode(tipo: 'nao_existe'),
              (c, n) => fabrica.construir(c, n, (_, _) => const SizedBox()),
            ),
          ),
        ),
      );

      // Assert — nenhum erro, widget vazio renderizado
      expect(tester.takeException(), isNull);
    });

    testWidgets('WidgetFactory.padrao registra os 7 tipos SDUI', (
      tester,
    ) async {
      // Arrange
      final fabricaPadrao = WidgetFactory.padrao();

      // Assert
      expect(fabricaPadrao.temTipo('seletor_data_range'), isTrue);
      expect(fabricaPadrao.temTipo('dropdown'), isTrue);
      expect(fabricaPadrao.temTipo('lista'), isTrue);
      expect(fabricaPadrao.temTipo('card_hospedagem'), isTrue);
      expect(fabricaPadrao.temTipo('botao_primario'), isTrue);
      expect(fabricaPadrao.temTipo('estado_vazio'), isTrue);
      expect(fabricaPadrao.temTipo('carregando'), isTrue);
    });

    testWidgets('builder estado_vazio renderiza DsEstadoVazio', (tester) async {
      // Arrange
      final fabricaPadrao = WidgetFactory.padrao();

      // Act
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (ctx) => fabricaPadrao.construir(
              ctx,
              const SduiNode(
                tipo: 'estado_vazio',
                propriedades: {'mensagem': 'Lista vazia'},
              ),
              (c, n) =>
                  fabricaPadrao.construir(c, n, (_, _) => const SizedBox()),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(DsEstadoVazio), findsOneWidget);
      expect(find.text('Lista vazia'), findsOneWidget);
    });

    testWidgets('builder carregando renderiza DsCarregando', (tester) async {
      // Arrange
      final fabricaPadrao = WidgetFactory.padrao();

      // Act
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (ctx) => fabricaPadrao.construir(
              ctx,
              const SduiNode(tipo: 'carregando'),
              (c, n) =>
                  fabricaPadrao.construir(c, n, (_, _) => const SizedBox()),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(DsCarregando), findsOneWidget);
    });
  });

  // ===== SduiRenderer =====
  group('SduiRenderer', () {
    late WidgetFactory fabrica;

    setUp(() {
      fabrica = WidgetFactory();
      fabrica.registrar(
        'texto',
        (_, no, _) => Text(no.propriedades['valor'] as String? ?? ''),
      );
    });

    testWidgets('renderiza lista de nós corretamente', (tester) async {
      // Arrange
      final nos = [
        const SduiNode(tipo: 'texto', propriedades: {'valor': 'Primeiro'}),
        const SduiNode(tipo: 'texto', propriedades: {'valor': 'Segundo'}),
      ];

      // Act
      await tester.pumpWidget(_app(SduiRenderer(nos: nos, fabrica: fabrica)));

      // Assert
      expect(find.text('Primeiro'), findsOneWidget);
      expect(find.text('Segundo'), findsOneWidget);
    });

    testWidgets('ignora tipos não registrados sem lançar erro', (tester) async {
      // Arrange
      final nos = [const SduiNode(tipo: 'nao_existe')];

      // Act
      await tester.pumpWidget(_app(SduiRenderer(nos: nos, fabrica: fabrica)));

      // Assert
      expect(tester.takeException(), isNull);
    });

    testWidgets('renderiza filhos recursivamente', (tester) async {
      // Arrange
      fabrica.registrar('coluna', (context, no, renderizarFilho) {
        return Column(
          children: no.filhos.map((f) => renderizarFilho(context, f)).toList(),
        );
      });

      final nos = [
        const SduiNode(
          tipo: 'coluna',
          filhos: [
            SduiNode(tipo: 'texto', propriedades: {'valor': 'filho 1'}),
            SduiNode(tipo: 'texto', propriedades: {'valor': 'filho 2'}),
          ],
        ),
      ];

      // Act
      await tester.pumpWidget(_app(SduiRenderer(nos: nos, fabrica: fabrica)));

      // Assert
      expect(find.text('filho 1'), findsOneWidget);
      expect(find.text('filho 2'), findsOneWidget);
    });

    testWidgets('renderiza lista vazia sem erros', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(
        _app(SduiRenderer(nos: const [], fabrica: fabrica)),
      );

      // Assert
      expect(tester.takeException(), isNull);
    });

    testWidgets('usa WidgetFactory.padrao com JSON da tela de hospedagens', (
      tester,
    ) async {
      // Arrange — configura DI com FiltroStore para os builders reativos
      final mockObterImoveis = MockObterImoveis();
      provideDummy<Either<Failure, List<ImovelEntity>>>(
        Right<Failure, List<ImovelEntity>>([]),
      );
      final filtroStore = FiltroStore(mockObterImoveis);
      GetIt.instance.registerSingleton<FiltroStore>(filtroStore);
      addTearDown(GetIt.instance.reset);

      final fabricaPadrao = WidgetFactory.padrao();
      const nos = [
        SduiNode(
          tipo: 'seletor_data_range',
          propriedades: {
            'rotulo_inicio': 'Check-in',
            'rotulo_fim': 'Check-out',
          },
        ),
        SduiNode(tipo: 'dropdown', propriedades: {'rotulo': 'Imóvel'}),
        SduiNode(
          tipo: 'lista',
          propriedades: {'vazio_mensagem': 'Nenhuma hospedagem encontrada'},
        ),
      ];

      // Act
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            child: SduiRenderer(nos: nos, fabrica: fabricaPadrao),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert — os 3 componentes são renderizados sem erros
      expect(find.byType(DsDateRangePicker), findsOneWidget);
      expect(find.byType(DsDropdown), findsOneWidget);
      expect(find.byType(DsLista), findsOneWidget);
    });
  });

  // ===== DsLista =====
  group('DsLista', () {
    testWidgets('renderiza itens quando lista não está vazia', (tester) async {
      // Arrange
      final itens = [
        const Text('Item A'),
        const Text('Item B'),
        const Text('Item C'),
      ];

      // Act
      await tester.pumpWidget(
        _app(SingleChildScrollView(child: DsLista(itens: itens))),
      );

      // Assert
      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
      expect(find.text('Item C'), findsOneWidget);
    });

    testWidgets('exibe DsEstadoVazio quando lista está vazia', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(_app(const DsLista(itens: [])));

      // Assert
      expect(find.byType(DsEstadoVazio), findsOneWidget);
    });

    testWidgets('usa mensagemVazia customizada', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(
        _app(
          const DsLista(
            itens: [],
            mensagemVazia: 'Nenhuma hospedagem encontrada',
          ),
        ),
      );

      // Assert
      expect(find.text('Nenhuma hospedagem encontrada'), findsOneWidget);
    });

    testWidgets('usa mensagem padrão quando mensagemVazia não é fornecida', (
      tester,
    ) async {
      // Arrange + Act
      await tester.pumpWidget(_app(const DsLista(itens: [])));

      // Assert
      expect(find.text('Nenhum item encontrado'), findsOneWidget);
    });
  });
}
