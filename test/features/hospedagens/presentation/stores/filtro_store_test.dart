import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:mobx/mobx.dart' hide when;
import 'package:meu_airbnb/core/erros/failures.dart';
import 'package:meu_airbnb/core/usecases/usecase.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/enums.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/imovel_entity.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/filtro_store.dart';

import 'usecases_mock.mocks.dart';

// Atalho para o when do mockito sem ambiguidade
import 'package:mockito/mockito.dart' as mockito;

void main() {
  late MockObterImoveis mockObterImoveis;
  late FiltroStore store;

  final imovel1 = const ImovelEntity(id: 'imovel-1', nome: 'Casa A');
  final imovel2 = const ImovelEntity(id: 'imovel-2', nome: 'Casa B');

  HospedagemEntity criarHospedagem({
    required String id,
    required String imovelId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) => HospedagemEntity(
    id: id,
    nomeHospede: 'Hóspede',
    checkIn: checkIn,
    checkOut: checkOut,
    numHospedes: 1,
    valorTotal: 100.0,
    status: StatusHospedagem.confirmada,
    plataforma: Plataforma.airbnb,
    imovelId: imovelId,
    criadoEm: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockObterImoveis = MockObterImoveis();

    provideDummy<Either<Failure, List<ImovelEntity>>>(
      Right<Failure, List<ImovelEntity>>([]),
    );

    store = FiltroStore(mockObterImoveis);
  });

  // ── hospedagensFiltradas ──────────────────────────────────────────────────

  group('FiltroStore.hospedagensFiltradas — sem filtro', () {
    test(
      'deve retornar todas as hospedagens quando nenhum filtro está ativo',
      () {
        // Arrange
        final h1 = criarHospedagem(
          id: 'h1',
          imovelId: 'imovel-1',
          checkIn: DateTime(2024, 1, 10),
          checkOut: DateTime(2024, 1, 15),
        );
        final h2 = criarHospedagem(
          id: 'h2',
          imovelId: 'imovel-2',
          checkIn: DateTime(2024, 2, 1),
          checkOut: DateTime(2024, 2, 5),
        );
        store.todasHospedagens = ObservableList.of([h1, h2]);

        // Act + Assert
        expect(store.hospedagensFiltradas, [h1, h2]);
      },
    );
  });

  group('FiltroStore.hospedagensFiltradas — filtro por período', () {
    test('deve incluir hospedagem que se sobrepõe ao período', () {
      // Arrange — hospedagem: 10~15 jan; período: 13~20 jan (overlap)
      final h = criarHospedagem(
        id: 'h1',
        imovelId: 'imovel-1',
        checkIn: DateTime(2024, 1, 10),
        checkOut: DateTime(2024, 1, 15),
      );
      store.todasHospedagens = ObservableList.of([h]);
      store.selecionarPeriodo(
        DateTimeRange(start: DateTime(2024, 1, 13), end: DateTime(2024, 1, 20)),
      );

      // Act + Assert
      expect(store.hospedagensFiltradas, contains(h));
    });

    test('deve excluir hospedagem que não se sobrepõe ao período', () {
      // Arrange — hospedagem: 1~5 jan; período: 10~20 jan (sem overlap)
      final h = criarHospedagem(
        id: 'h1',
        imovelId: 'imovel-1',
        checkIn: DateTime(2024, 1, 1),
        checkOut: DateTime(2024, 1, 5),
      );
      store.todasHospedagens = ObservableList.of([h]);
      store.selecionarPeriodo(
        DateTimeRange(start: DateTime(2024, 1, 10), end: DateTime(2024, 1, 20)),
      );

      // Act + Assert
      expect(store.hospedagensFiltradas, isEmpty);
    });

    test(
      'deve incluir hospedagem com datas exatamente no limite do período',
      () {
        // Arrange — hospedagem: 10~15 jan; período: 15~20 jan (toca na borda)
        final h = criarHospedagem(
          id: 'h1',
          imovelId: 'imovel-1',
          checkIn: DateTime(2024, 1, 10),
          checkOut: DateTime(2024, 1, 15),
        );
        store.todasHospedagens = ObservableList.of([h]);
        store.selecionarPeriodo(
          DateTimeRange(
            start: DateTime(2024, 1, 15),
            end: DateTime(2024, 1, 20),
          ),
        );

        // Act + Assert
        expect(store.hospedagensFiltradas, contains(h));
      },
    );
  });

  group('FiltroStore.hospedagensFiltradas — filtro por imóvel', () {
    test('deve retornar apenas hospedagens do imóvel selecionado', () {
      // Arrange
      final h1 = criarHospedagem(
        id: 'h1',
        imovelId: 'imovel-1',
        checkIn: DateTime(2024, 1, 1),
        checkOut: DateTime(2024, 1, 5),
      );
      final h2 = criarHospedagem(
        id: 'h2',
        imovelId: 'imovel-2',
        checkIn: DateTime(2024, 1, 1),
        checkOut: DateTime(2024, 1, 5),
      );
      store.todasHospedagens = ObservableList.of([h1, h2]);
      store.selecionarImovel('imovel-1');

      // Act + Assert
      expect(store.hospedagensFiltradas, [h1]);
    });
  });

  group('FiltroStore.hospedagensFiltradas — filtros combinados', () {
    test('deve aplicar filtro de período E imóvel simultaneamente', () {
      // Arrange
      final h1 = criarHospedagem(
        id: 'h1',
        imovelId: 'imovel-1',
        checkIn: DateTime(2024, 1, 10),
        checkOut: DateTime(2024, 1, 15),
      );
      final h2 = criarHospedagem(
        id: 'h2',
        imovelId: 'imovel-2',
        checkIn: DateTime(2024, 1, 10),
        checkOut: DateTime(2024, 1, 15),
      );
      final h3 = criarHospedagem(
        id: 'h3',
        imovelId: 'imovel-1',
        checkIn: DateTime(2024, 3, 1),
        checkOut: DateTime(2024, 3, 5),
      );
      store.todasHospedagens = ObservableList.of([h1, h2, h3]);
      store.selecionarImovel('imovel-1');
      store.selecionarPeriodo(
        DateTimeRange(start: DateTime(2024, 1, 12), end: DateTime(2024, 1, 20)),
      );

      // Act + Assert — apenas h1 passa pelos dois filtros
      expect(store.hospedagensFiltradas, [h1]);
    });
  });

  // ── Actions ───────────────────────────────────────────────────────────────

  group('FiltroStore.limparFiltros', () {
    test('deve limpar período e imóvel selecionados', () {
      // Arrange
      store.selecionarPeriodo(
        DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 31)),
      );
      store.selecionarImovel('imovel-1');

      // Act
      store.limparFiltros();

      // Assert
      expect(store.periodoSelecionado, isNull);
      expect(store.imovelSelecionadoId, isNull);
    });
  });

  group('FiltroStore.carregarImoveis', () {
    test('deve popular imoveis em caso de sucesso', () async {
      // Arrange
      mockito
          .when(mockObterImoveis(const NoParams()))
          .thenAnswer((_) async => Right([imovel1, imovel2]));

      // Act
      await store.carregarImoveis();

      // Assert
      expect(store.imoveis, [imovel1, imovel2]);
      expect(store.erro, isNull);
    });

    test('deve setar erro quando use case falha', () async {
      // Arrange
      mockito
          .when(mockObterImoveis(const NoParams()))
          .thenAnswer(
            (_) async => Left(const CacheFailure('Falha ao carregar imóveis')),
          );

      // Act
      await store.carregarImoveis();

      // Assert
      expect(store.imoveis, isEmpty);
      expect(store.erro, 'Falha ao carregar imóveis');
    });
  });

  group('FiltroStore.todasHospedagens — vinculação reativa', () {
    test(
      'computed hospedagensFiltradas deve refletir mudanças na lista vinculada',
      () {
        // Arrange — lista compartilhada com HospedagemStore
        final lista = ObservableList<HospedagemEntity>();
        store.todasHospedagens = lista;

        final h = criarHospedagem(
          id: 'h1',
          imovelId: 'imovel-1',
          checkIn: DateTime(2024, 1, 1),
          checkOut: DateTime(2024, 1, 5),
        );

        // Act — muda a lista externa; computed deve reagir
        lista.add(h);

        // Assert
        expect(store.hospedagensFiltradas, contains(h));
      },
    );
  });
}
