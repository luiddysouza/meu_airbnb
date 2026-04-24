import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:meu_airbnb/core/erros/failures.dart';
import 'package:meu_airbnb/core/sdui/cubit/sdui_cubit.dart';
import 'package:meu_airbnb/core/sdui/cubit/sdui_state.dart';
import 'package:meu_airbnb/core/sdui/models/sdui_node.dart';
import 'package:meu_airbnb/core/usecases/usecase.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/enums.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/imovel_entity.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/paginas/hospedagens_pagina.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/filtro_store.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/hospedagem_form_store.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/hospedagem_store.dart';
import 'package:mockito/mockito.dart';

import '../stores/usecases_mock.mocks.dart';

// ---------------------------------------------------------------------------
// Cubit stub — intercepta carregarTela() e não faz nada, permitindo controle
// manual do estado via emit() nos testes.
// ---------------------------------------------------------------------------
class _SduiCubitStub extends SduiCubit {
  @override
  Future<void> carregarTela({
    String caminhoAsset = 'assets/mock/tela_hospedagens.json',
  }) async {
    // No-op — estado é controlado pelo teste
  }
}

Widget _app(Widget child) => MaterialApp(theme: DsTemaApp.tema, home: child);

void main() {
  late MockObterHospedagens mockObterHospedagens;
  late MockAdicionarHospedagem mockAdicionarHospedagem;
  late MockAtualizarHospedagem mockAtualizarHospedagem;
  late MockDeletarHospedagem mockDeletarHospedagem;
  late MockObterImoveis mockObterImoveis;
  late HospedagemStore hospedagemStore;
  late FiltroStore filtroStore;
  late _SduiCubitStub sduiCubit;

  setUp(() {
    mockObterHospedagens = MockObterHospedagens();
    mockAdicionarHospedagem = MockAdicionarHospedagem();
    mockAtualizarHospedagem = MockAtualizarHospedagem();
    mockDeletarHospedagem = MockDeletarHospedagem();
    mockObterImoveis = MockObterImoveis();

    provideDummy<Either<Failure, List<HospedagemEntity>>>(
      const Right<Failure, List<HospedagemEntity>>([]),
    );
    provideDummy<Either<Failure, List<ImovelEntity>>>(
      const Right<Failure, List<ImovelEntity>>([]),
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

    // Mocks dos use cases retornam listas vazias por padrão
    when(
      mockObterHospedagens(const NoParams()),
    ).thenAnswer((_) async => const Right<Failure, List<HospedagemEntity>>([]));
    when(
      mockObterImoveis(const NoParams()),
    ).thenAnswer((_) async => const Right<Failure, List<ImovelEntity>>([]));

    hospedagemStore = HospedagemStore(
      mockObterHospedagens,
      mockAdicionarHospedagem,
      mockAtualizarHospedagem,
      mockDeletarHospedagem,
    );
    filtroStore = FiltroStore(mockObterImoveis);
    sduiCubit = _SduiCubitStub();

    GetIt.instance
      ..registerSingleton<HospedagemStore>(hospedagemStore)
      ..registerSingleton<FiltroStore>(filtroStore)
      ..registerFactory<HospedagemFormStore>(
        () => HospedagemFormStore(hospedagemStore: hospedagemStore),
      )
      // Factory retorna sempre o mesmo stub — página usa sl<SduiCubit>() em initState
      ..registerFactory<SduiCubit>(() => sduiCubit);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  // ── Estado loading / initial ──────────────────────────────────────────────

  group('HospedagensPagina — estado loading', () {
    testWidgets('exibe DsCarregando quando estado é SduiInitial', (
      tester,
    ) async {
      // Arrange — cubit começa em SduiInitial (sem emit)
      await tester.pumpWidget(_app(const HospedagensPagina()));

      // Assert
      expect(find.byType(DsCarregando), findsOneWidget);
      expect(find.byType(DsScaffoldResponsivo), findsOneWidget);
    });

    testWidgets('exibe DsCarregando quando estado é SduiLoading', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_app(const HospedagensPagina()));

      // Act
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      sduiCubit.emit(const SduiLoading());
      await tester.pump();

      // Assert
      expect(find.byType(DsCarregando), findsOneWidget);
    });
  });

  // ── Estado sucesso ────────────────────────────────────────────────────────

  group('HospedagensPagina — estado sucesso', () {
    final arvoreFixture = [
      const SduiNode(
        tipo: 'seletor_data_range',
        propriedades: {'rotulo_inicio': 'Check-in', 'rotulo_fim': 'Check-out'},
      ),
      const SduiNode(tipo: 'dropdown', propriedades: {'rotulo': 'Imóvel'}),
      const SduiNode(
        tipo: 'lista',
        propriedades: {'vazio_mensagem': 'Nenhuma hospedagem encontrada'},
      ),
    ];

    testWidgets('exibe DsScaffoldResponsivo com widgets SDUI', (tester) async {
      // Arrange
      await tester.pumpWidget(_app(const HospedagensPagina()));

      // Act — emite sucesso com a árvore completa
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      sduiCubit.emit(SduiSuccess(arvoreFixture));
      await tester.pump();

      // Assert
      expect(find.byType(DsScaffoldResponsivo), findsOneWidget);
      expect(find.byType(DsDateRangePicker), findsOneWidget);
      expect(find.byType(DsDropdown), findsOneWidget);
      expect(find.byType(DsLista), findsOneWidget);
    });

    testWidgets('não exibe DsCarregando após sucesso', (tester) async {
      // Arrange + Act
      await tester.pumpWidget(_app(const HospedagensPagina()));
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      sduiCubit.emit(SduiSuccess(arvoreFixture));
      await tester.pump();

      // Assert
      expect(find.byType(DsCarregando), findsNothing);
    });

    testWidgets('exibe estado vazio da lista quando não há hospedagens', (
      tester,
    ) async {
      // Arrange — filtroStore.todasHospedagens vazia (default)
      await tester.pumpWidget(_app(const HospedagensPagina()));
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      sduiCubit.emit(SduiSuccess(arvoreFixture));
      await tester.pump();

      // Assert — DsLista exibe DsEstadoVazio internamente
      expect(find.text('Nenhuma hospedagem encontrada'), findsOneWidget);
    });

    testWidgets('renderiza sem erros quando arvore está vazia', (tester) async {
      // Act
      await tester.pumpWidget(_app(const HospedagensPagina()));
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      sduiCubit.emit(const SduiSuccess([]));
      await tester.pump();

      // Assert
      expect(tester.takeException(), isNull);
      expect(find.byType(DsScaffoldResponsivo), findsOneWidget);
    });
  });

  // ── Estado erro ───────────────────────────────────────────────────────────

  group('HospedagensPagina — estado erro', () {
    testWidgets('exibe DsEstadoVazio com mensagem de erro', (tester) async {
      // Arrange
      await tester.pumpWidget(_app(const HospedagensPagina()));

      // Act
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      sduiCubit.emit(const SduiError('Falha ao carregar tela'));
      await tester.pump();

      // Assert
      expect(find.byType(DsEstadoVazio), findsOneWidget);
      expect(find.text('Falha ao carregar tela'), findsOneWidget);
      expect(find.byType(DsCarregando), findsNothing);
    });
  });

  // ── BlocProvider ─────────────────────────────────────────────────────────

  group('HospedagensPagina — BlocProvider', () {
    testWidgets('SduiCubit está disponível na árvore via BlocProvider', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_app(const HospedagensPagina()));

      // Assert — o contexto deve ser um descendente do BlocProvider
      // DsCarregando é filho da árvore SDUI dentro do BlocProvider
      final contextDescendente = tester.element(find.byType(DsCarregando));
      expect(
        () => BlocProvider.of<SduiCubit>(contextDescendente),
        returnsNormally,
      );
    });
  });

  // ── FAB ────────────────────────────────────────────────────────────────────

  group('HospedagensPagina — FAB', () {
    final arvoreFixture = [
      const SduiNode(
        tipo: 'seletor_data_range',
        propriedades: {'rotulo_inicio': 'Check-in', 'rotulo_fim': 'Check-out'},
      ),
      const SduiNode(tipo: 'dropdown', propriedades: {'rotulo': 'Imóvel'}),
      const SduiNode(
        tipo: 'lista',
        propriedades: {'vazio_mensagem': 'Nenhuma hospedagem encontrada'},
      ),
    ];

    testWidgets('exibe FAB quando estado é SduiSuccess', (tester) async {
      // Arrange
      await tester.pumpWidget(_app(const HospedagensPagina()));

      // Act
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      sduiCubit.emit(SduiSuccess(arvoreFixture));
      await tester.pump();

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('FAB abre FormularioHospedagemDialog no modo criação', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_app(const HospedagensPagina()));
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      sduiCubit.emit(SduiSuccess(arvoreFixture));
      // pumpAndSettle aguarda a animação de entrada do FAB
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert — dialog de criação está aberto
      expect(find.text('Nova hospedagem'), findsOneWidget);
    });

    testWidgets('FAB não aparece no estado SduiLoading', (tester) async {
      // Arrange
      await tester.pumpWidget(_app(const HospedagensPagina()));
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      sduiCubit.emit(const SduiLoading());
      await tester.pump();

      // Assert
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}
