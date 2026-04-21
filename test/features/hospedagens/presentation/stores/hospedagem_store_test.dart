import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:meu_airbnb/core/erros/failures.dart';
import 'package:meu_airbnb/core/usecases/usecase.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/enums.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/hospedagem_store.dart';

import 'usecases_mock.mocks.dart';

void main() {
  late MockObterHospedagens mockObterHospedagens;
  late MockAdicionarHospedagem mockAdicionarHospedagem;
  late MockAtualizarHospedagem mockAtualizarHospedagem;
  late MockDeletarHospedagem mockDeletarHospedagem;
  late HospedagemStore store;

  final hospedagemFixture = HospedagemEntity(
    id: 'id-1',
    nomeHospede: 'João Silva',
    checkIn: DateTime(2024, 1, 10),
    checkOut: DateTime(2024, 1, 15),
    numHospedes: 2,
    valorTotal: 500.0,
    status: StatusHospedagem.confirmada,
    plataforma: Plataforma.airbnb,
    imovelId: 'imovel-1',
    criadoEm: DateTime(2024, 1, 1),
  );

  final hospedagemAtualizada = hospedagemFixture.copyWith(
    nomeHospede: 'João Atualizado',
  );

  setUp(() {
    mockObterHospedagens = MockObterHospedagens();
    mockAdicionarHospedagem = MockAdicionarHospedagem();
    mockAtualizarHospedagem = MockAtualizarHospedagem();
    mockDeletarHospedagem = MockDeletarHospedagem();

    provideDummy<Either<Failure, List<HospedagemEntity>>>(
      Right<Failure, List<HospedagemEntity>>([]),
    );
    provideDummy<Either<Failure, HospedagemEntity>>(
      Right<Failure, HospedagemEntity>(hospedagemFixture),
    );
    provideDummy<Either<Failure, void>>(const Right<Failure, void>(null));

    store = HospedagemStore(
      mockObterHospedagens,
      mockAdicionarHospedagem,
      mockAtualizarHospedagem,
      mockDeletarHospedagem,
    );
  });

  group('HospedagemStore.carregarHospedagens', () {
    test(
      'deve popular hospedagens e limpar carregando em caso de sucesso',
      () async {
        // Arrange
        when(
          mockObterHospedagens(const NoParams()),
        ).thenAnswer((_) async => Right([hospedagemFixture]));

        // Act
        await store.carregarHospedagens();

        // Assert
        expect(store.hospedagens, [hospedagemFixture]);
        expect(store.carregando, isFalse);
        expect(store.erro, isNull);
      },
    );

    test(
      'deve setar erro e limpar carregando quando repositório falha',
      () async {
        // Arrange
        when(
          mockObterHospedagens(const NoParams()),
        ).thenAnswer((_) async => Left(const CacheFailure('Erro de cache')));

        // Act
        await store.carregarHospedagens();

        // Assert
        expect(store.hospedagens, isEmpty);
        expect(store.carregando, isFalse);
        expect(store.erro, 'Erro de cache');
      },
    );
  });

  group('HospedagemStore.adicionarHospedagem', () {
    test('deve manter hospedagem na lista após sucesso do use case', () async {
      // Arrange
      when(
        mockAdicionarHospedagem(any),
      ).thenAnswer((_) async => Right(hospedagemFixture));

      // Act
      await store.adicionarHospedagem(hospedagemFixture);

      // Assert
      expect(store.hospedagens, contains(hospedagemFixture));
      expect(store.erro, isNull);
    });

    test('deve fazer rollback e setar erro quando use case falha', () async {
      // Arrange
      when(
        mockAdicionarHospedagem(any),
      ).thenAnswer((_) async => Left(const CacheFailure('Falha ao salvar')));

      // Act
      await store.adicionarHospedagem(hospedagemFixture);

      // Assert
      expect(store.hospedagens, isEmpty);
      expect(store.erro, 'Falha ao salvar');
    });
  });

  group('HospedagemStore.atualizarHospedagem', () {
    setUp(() async {
      // Pré-carrega a lista com uma hospedagem
      when(
        mockObterHospedagens(const NoParams()),
      ).thenAnswer((_) async => Right([hospedagemFixture]));
      await store.carregarHospedagens();
    });

    test(
      'deve atualizar hospedagem na lista após sucesso do use case',
      () async {
        // Arrange
        when(
          mockAtualizarHospedagem(any),
        ).thenAnswer((_) async => Right(hospedagemAtualizada));

        // Act
        await store.atualizarHospedagem(hospedagemAtualizada);

        // Assert
        expect(store.hospedagens.first.nomeHospede, 'João Atualizado');
        expect(store.erro, isNull);
      },
    );

    test('deve fazer rollback e setar erro quando use case falha', () async {
      // Arrange
      when(
        mockAtualizarHospedagem(any),
      ).thenAnswer((_) async => Left(const CacheFailure('Falha ao atualizar')));

      // Act
      await store.atualizarHospedagem(hospedagemAtualizada);

      // Assert
      expect(store.hospedagens.first.nomeHospede, 'João Silva');
      expect(store.erro, 'Falha ao atualizar');
    });
  });

  group('HospedagemStore.deletarHospedagem', () {
    setUp(() async {
      when(
        mockObterHospedagens(const NoParams()),
      ).thenAnswer((_) async => Right([hospedagemFixture]));
      await store.carregarHospedagens();
    });

    test('deve remover hospedagem da lista após sucesso do use case', () async {
      // Arrange
      when(
        mockDeletarHospedagem(any),
      ).thenAnswer((_) async => const Right<Failure, void>(null));

      // Act
      await store.deletarHospedagem(hospedagemFixture.id);

      // Assert
      expect(store.hospedagens, isEmpty);
      expect(store.erro, isNull);
    });

    test('deve fazer rollback e setar erro quando use case falha', () async {
      // Arrange
      when(
        mockDeletarHospedagem(any),
      ).thenAnswer((_) async => Left(const CacheFailure('Falha ao deletar')));

      // Act
      await store.deletarHospedagem(hospedagemFixture.id);

      // Assert
      expect(store.hospedagens, contains(hospedagemFixture));
      expect(store.erro, 'Falha ao deletar');
    });
  });

  group('HospedagemStore.limparErro', () {
    test('deve limpar o campo erro', () async {
      // Arrange — seta erro via carregamento falho
      when(
        mockObterHospedagens(const NoParams()),
      ).thenAnswer((_) async => Left(const CacheFailure('Erro')));
      await store.carregarHospedagens();
      expect(store.erro, isNotNull);

      // Act
      store.limparErro();

      // Assert
      expect(store.erro, isNull);
    });
  });

  group('HospedagemStore — id gerado automaticamente', () {
    test('deve gerar id quando hospedagem passada tem id vazio', () async {
      // Arrange
      final semId = hospedagemFixture.copyWith(id: '');
      when(
        mockAdicionarHospedagem(any),
      ).thenAnswer((_) async => Right(hospedagemFixture));

      // Act
      await store.adicionarHospedagem(semId);

      // Assert — hospedagem adicionada tem id não vazio
      expect(store.hospedagens.first.id, isNotEmpty);
    });
  });
}
