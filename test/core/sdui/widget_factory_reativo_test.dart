import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart' hide when;
import 'package:mockito/mockito.dart';
import 'package:meu_airbnb/core/erros/failures.dart';
import 'package:meu_airbnb/core/sdui/factory/widget_factory.dart';
import 'package:meu_airbnb/core/sdui/models/sdui_node.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/enums.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/imovel_entity.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/filtro_store.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/hospedagem_store.dart';

import '../../features/hospedagens/presentation/stores/usecases_mock.mocks.dart';

Widget _app(Widget child) => MaterialApp(
  theme: DsTemaApp.tema,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  late MockObterImoveis mockObterImoveis;
  late MockObterHospedagens mockObterHospedagens;
  late MockAdicionarHospedagem mockAdicionarHospedagem;
  late MockAtualizarHospedagem mockAtualizarHospedagem;
  late MockDeletarHospedagem mockDeletarHospedagem;
  late FiltroStore filtroStore;
  late HospedagemStore hospedagemStore;

  setUp(() {
    mockObterImoveis = MockObterImoveis();
    mockObterHospedagens = MockObterHospedagens();
    mockAdicionarHospedagem = MockAdicionarHospedagem();
    mockAtualizarHospedagem = MockAtualizarHospedagem();
    mockDeletarHospedagem = MockDeletarHospedagem();

    provideDummy<Either<Failure, List<ImovelEntity>>>(
      Right<Failure, List<ImovelEntity>>([]),
    );
    provideDummy<Either<Failure, List<HospedagemEntity>>>(
      Right<Failure, List<HospedagemEntity>>([]),
    );
    provideDummy<Either<Failure, HospedagemEntity>>(
      Right<Failure, HospedagemEntity>(
        HospedagemEntity(
          id: '',
          nomeHospede: '',
          checkIn: DateTime(2024),
          checkOut: DateTime(2024),
          numHospedes: 1,
          valorTotal: 0,
          status: StatusHospedagem.pendente,
          plataforma: Plataforma.airbnb,
          imovelId: '',
          criadoEm: DateTime(2024),
        ),
      ),
    );
    provideDummy<Either<Failure, void>>(const Right<Failure, void>(null));

    filtroStore = FiltroStore(mockObterImoveis);
    hospedagemStore = HospedagemStore(
      mockObterHospedagens,
      mockAdicionarHospedagem,
      mockAtualizarHospedagem,
      mockDeletarHospedagem,
    );

    GetIt.instance
      ..registerSingleton<FiltroStore>(filtroStore)
      ..registerSingleton<HospedagemStore>(hospedagemStore);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget _construir(SduiNode no) => Builder(
    builder: (ctx) =>
        WidgetFactory.padrao().construir(ctx, no, (c, n) => const SizedBox()),
  );

  // ── seletor_data_range ────────────────────────────────────────────────────

  group('WidgetFactory.padrao — seletor_data_range', () {
    const no = SduiNode(
      tipo: 'seletor_data_range',
      propriedades: {'rotulo_inicio': 'Entrada', 'rotulo_fim': 'Saída'},
    );

    testWidgets('renderiza DsDateRangePicker envolto em Observer', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(_app(_construir(no)));

      // Assert
      expect(find.byType(Observer), findsWidgets);
      expect(find.byType(DsDateRangePicker), findsOneWidget);
    });

    testWidgets('rótulos do SDUI são repassados ao DsDateRangePicker', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(_app(_construir(no)));

      // Assert — verifica textos dos rótulos na tela
      expect(find.text('Entrada'), findsOneWidget);
      expect(find.text('Saída'), findsOneWidget);
    });

    testWidgets('usa rótulos padrão quando props estão ausentes', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        _app(_construir(const SduiNode(tipo: 'seletor_data_range'))),
      );

      // Assert
      expect(find.text('Check-in'), findsOneWidget);
      expect(find.text('Check-out'), findsOneWidget);
    });

    testWidgets(
      'reconstrói ao selecionar período — periodoSelecionado refletido',
      (tester) async {
        // Arrange
        await tester.pumpWidget(_app(_construir(no)));
        expect(filtroStore.periodoSelecionado, isNull);

        // Act — muda o observable diretamente
        runInAction(
          () => filtroStore.selecionarPeriodo(
            DateTimeRange(
              start: DateTime(2024, 1, 10),
              end: DateTime(2024, 1, 20),
            ),
          ),
        );
        await tester.pump();

        // Assert — Observer reconstruiu sem erro
        expect(tester.takeException(), isNull);
        expect(filtroStore.periodoSelecionado, isNotNull);
      },
    );
  });

  // ── dropdown ─────────────────────────────────────────────────────────────

  group('WidgetFactory.padrao — dropdown', () {
    const no = SduiNode(tipo: 'dropdown', propriedades: {'rotulo': 'Imóvel'});

    testWidgets('renderiza DsDropdown envolto em Observer', (tester) async {
      // Act
      await tester.pumpWidget(_app(_construir(no)));

      // Assert
      expect(find.byType(Observer), findsWidgets);
      expect(find.byType(DsDropdown), findsOneWidget);
    });

    testWidgets('exibe opções vindas de filtroStore.imoveis', (tester) async {
      // Arrange — adiciona imóveis ao store
      runInAction(() {
        filtroStore.imoveis = [
          const ImovelEntity(id: 'i1', nome: 'Casa Praia'),
          const ImovelEntity(id: 'i2', nome: 'Apto Centro'),
        ];
      });

      // Act
      await tester.pumpWidget(_app(_construir(no)));

      // Assert — DsDropdown recebeu 2 opções
      final dropdown = tester.widget<DsDropdown>(find.byType(DsDropdown));
      expect(dropdown.opcoes.length, 2);
      expect(dropdown.opcoes.first.rotulo, 'Casa Praia');
      expect(dropdown.opcoes.last.rotulo, 'Apto Centro');
    });

    testWidgets('lista de opções atualiza quando imoveis muda no store', (
      tester,
    ) async {
      // Arrange — começa sem imóveis
      await tester.pumpWidget(_app(_construir(no)));
      var dropdown = tester.widget<DsDropdown>(find.byType(DsDropdown));
      expect(dropdown.opcoes, isEmpty);

      // Act — Observer reage à mudança
      runInAction(() {
        filtroStore.imoveis = [const ImovelEntity(id: 'i1', nome: 'Nova Casa')];
      });
      await tester.pump();

      // Assert
      dropdown = tester.widget<DsDropdown>(find.byType(DsDropdown));
      expect(dropdown.opcoes.length, 1);
      expect(dropdown.opcoes.first.rotulo, 'Nova Casa');
    });

    testWidgets('reflete imovelSelecionadoId do store', (tester) async {
      // Arrange
      runInAction(() {
        filtroStore.imoveis = [const ImovelEntity(id: 'i1', nome: 'Casa')];
        filtroStore.selecionarImovel('i1');
      });

      // Act
      await tester.pumpWidget(_app(_construir(no)));

      // Assert
      final dropdown = tester.widget<DsDropdown>(find.byType(DsDropdown));
      expect(dropdown.valorSelecionado, 'i1');
    });
  });

  // ── lista ─────────────────────────────────────────────────────────────────

  group('WidgetFactory.padrao — lista', () {
    const no = SduiNode(
      tipo: 'lista',
      propriedades: {'vazio_mensagem': 'Sem hospedagens'},
    );

    HospedagemEntity criarHospedagem(String id) => HospedagemEntity(
      id: id,
      nomeHospede: 'Hóspede $id',
      checkIn: DateTime(2024, 1, 10),
      checkOut: DateTime(2024, 1, 15),
      numHospedes: 2,
      valorTotal: 500.0,
      status: StatusHospedagem.confirmada,
      plataforma: Plataforma.airbnb,
      imovelId: 'imovel-1',
      criadoEm: DateTime(2024, 1, 1),
    );

    testWidgets('renderiza DsLista envolto em Observer', (tester) async {
      // Act
      await tester.pumpWidget(_app(_construir(no)));

      // Assert
      expect(find.byType(Observer), findsWidgets);
      expect(find.byType(DsLista), findsOneWidget);
    });

    testWidgets(
      'exibe mensagem de estado vazio quando hospedagensFiltradas está vazia',
      (tester) async {
        // Act
        await tester.pumpWidget(_app(_construir(no)));

        // Assert
        expect(find.text('Sem hospedagens'), findsOneWidget);
      },
    );

    testWidgets('renderiza DsCardHospedagem para cada hospedagem filtrada', (
      tester,
    ) async {
      // Arrange
      runInAction(() {
        filtroStore.todasHospedagens.addAll([
          criarHospedagem('h1'),
          criarHospedagem('h2'),
        ]);
      });

      // Act
      await tester.pumpWidget(_app(_construir(no)));

      // Assert
      expect(find.byType(DsCardHospedagem), findsNWidgets(2));
    });

    testWidgets('exibe nome do imóvel no card quando imovel está no store', (
      tester,
    ) async {
      // Arrange
      runInAction(() {
        filtroStore.imoveis = [
          const ImovelEntity(id: 'imovel-1', nome: 'Casa da Praia'),
        ];
        filtroStore.todasHospedagens.add(criarHospedagem('h1'));
      });

      // Act
      await tester.pumpWidget(_app(_construir(no)));

      // Assert
      expect(find.text('Casa da Praia'), findsOneWidget);
    });

    testWidgets('lista reconstrói ao adicionar hospedagem ao store', (
      tester,
    ) async {
      // Arrange — começa vazia
      await tester.pumpWidget(_app(_construir(no)));
      expect(find.byType(DsCardHospedagem), findsNothing);

      // Act
      runInAction(() {
        filtroStore.todasHospedagens.add(criarHospedagem('h1'));
      });
      await tester.pump();

      // Assert
      expect(find.byType(DsCardHospedagem), findsOneWidget);
    });

    testWidgets(
      'usa mensagem padrão quando prop vazio_mensagem não está no SDUI',
      (tester) async {
        // Act
        await tester.pumpWidget(
          _app(_construir(const SduiNode(tipo: 'lista'))),
        );

        // Assert
        expect(find.text('Nenhuma hospedagem encontrada'), findsOneWidget);
      },
    );
  });

  // ── lista — callbacks CRUD ────────────────────────────────────────────────

  group('WidgetFactory.padrao — lista callbacks CRUD', () {
    const no = SduiNode(
      tipo: 'lista',
      propriedades: {'vazio_mensagem': 'Sem hospedagens'},
    );

    HospedagemEntity criarHospedagem(String id) => HospedagemEntity(
      id: id,
      nomeHospede: 'Hóspede $id',
      checkIn: DateTime(2024, 1, 10),
      checkOut: DateTime(2024, 1, 15),
      numHospedes: 2,
      valorTotal: 500.0,
      status: StatusHospedagem.confirmada,
      plataforma: Plataforma.airbnb,
      imovelId: 'imovel-1',
      criadoEm: DateTime(2024, 1, 1),
    );

    testWidgets('cards exibem botão de editar', (tester) async {
      // Arrange
      runInAction(() {
        filtroStore.todasHospedagens.add(criarHospedagem('h1'));
      });

      // Act
      await tester.pumpWidget(_app(_construir(no)));

      // Assert — ícone de edição presente
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('cards exibem botão de deletar', (tester) async {
      // Arrange
      runInAction(() {
        filtroStore.todasHospedagens.add(criarHospedagem('h1'));
      });

      // Act
      await tester.pumpWidget(_app(_construir(no)));

      // Assert — ícone de deletar presente
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets(
      'toque em deletar exibe DsDialogConfirmacao com nome do hóspede',
      (tester) async {
        // Arrange
        runInAction(() {
          filtroStore.todasHospedagens.add(criarHospedagem('h1'));
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: DsTemaApp.tema,
            home: Scaffold(body: SingleChildScrollView(child: _construir(no))),
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // Assert — dialog de confirmação aparece com nome do hóspede
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Excluir hospedagem'), findsOneWidget);
        expect(find.textContaining('Hóspede h1'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets('confirmar exclusão chama deletarHospedagem no store', (
      tester,
    ) async {
      // Arrange
      when(
        mockDeletarHospedagem(any),
      ).thenAnswer((_) async => const Right<Failure, void>(null));

      runInAction(() {
        filtroStore.todasHospedagens.add(criarHospedagem('h1'));
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: DsTemaApp.tema,
          home: Scaffold(body: SingleChildScrollView(child: _construir(no))),
        ),
      );

      // Act — toca deletar, confirma no dialog
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockDeletarHospedagem(any)).called(1);
    });

    testWidgets('cancelar exclusão não chama deletarHospedagem', (
      tester,
    ) async {
      // Arrange
      runInAction(() {
        filtroStore.todasHospedagens.add(criarHospedagem('h1'));
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: DsTemaApp.tema,
          home: Scaffold(body: SingleChildScrollView(child: _construir(no))),
        ),
      );

      // Act — toca deletar, cancela no dialog
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Assert
      verifyNever(mockDeletarHospedagem(any));
    });

    testWidgets(
      'toque em editar abre FormularioHospedagemDialog em modo edição',
      (tester) async {
        // Arrange
        runInAction(() {
          filtroStore.todasHospedagens.add(criarHospedagem('h1'));
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: DsTemaApp.tema,
            home: Scaffold(body: SingleChildScrollView(child: _construir(no))),
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        // Assert — dialog de edição aberto
        expect(find.text('Editar hospedagem'), findsOneWidget);
      },
    );
  });
}
