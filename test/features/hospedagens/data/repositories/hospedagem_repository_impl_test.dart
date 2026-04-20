import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:meu_airbnb/core/erros/failures.dart';
import 'package:meu_airbnb/features/hospedagens/data/repositories/hospedagem_repository_impl.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/enums.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/imovel_entity.dart';

import 'datasource_mock.mocks.dart';

HospedagemEntity _hospedagemFixture() => HospedagemEntity(
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

void main() {
  late MockHospedagemLocalDataSource mockDataSource;
  late HospedagemRepositoryImpl repositorio;

  setUp(() {
    mockDataSource = MockHospedagemLocalDataSource();
    repositorio = HospedagemRepositoryImpl(mockDataSource);
  });

  // ---------------------------------------------------------------------------
  // obterTodas
  // ---------------------------------------------------------------------------
  group('obterTodas', () {
    test(
      'deve retornar Right(lista) quando datasource retorna com sucesso',
      () async {
        // Arrange
        final lista = [_hospedagemFixture()];
        when(mockDataSource.obterTodas()).thenAnswer((_) async => lista);

        // Act
        final resultado = await repositorio.obterTodas();

        // Assert
        expect(resultado, Right(lista));
      },
    );

    test(
      'deve retornar Left(CacheFailure) quando datasource lança exceção',
      () async {
        // Arrange
        when(mockDataSource.obterTodas()).thenThrow(Exception('disco cheio'));

        // Act
        final resultado = await repositorio.obterTodas();

        // Assert
        expect(resultado.isLeft(), isTrue);
        resultado.fold(
          (Failure) => expect(Failure, isA<CacheFailure>()),
          (_) => fail('deveria ser Left'),
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // adicionar
  // ---------------------------------------------------------------------------
  group('adicionar', () {
    test(
      'deve retornar Right(entidade) quando datasource adiciona com sucesso',
      () async {
        // Arrange
        final hospedagem = _hospedagemFixture();
        when(
          mockDataSource.adicionar(hospedagem),
        ).thenAnswer((_) async => hospedagem);

        // Act
        final resultado = await repositorio.adicionar(hospedagem);

        // Assert
        expect(resultado, Right(hospedagem));
      },
    );

    test(
      'deve retornar Left(CacheFailure) quando datasource lança exceção',
      () async {
        // Arrange
        when(
          mockDataSource.adicionar(any),
        ).thenThrow(Exception('erro ao salvar'));

        // Act
        final resultado = await repositorio.adicionar(_hospedagemFixture());

        // Assert
        expect(resultado.isLeft(), isTrue);
        resultado.fold(
          (Failure) => expect(Failure, isA<CacheFailure>()),
          (_) => fail('deveria ser Left'),
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // atualizar
  // ---------------------------------------------------------------------------
  group('atualizar', () {
    test(
      'deve retornar Right(entidade) quando datasource atualiza com sucesso',
      () async {
        // Arrange
        final hospedagem = _hospedagemFixture();
        when(
          mockDataSource.atualizar(hospedagem),
        ).thenAnswer((_) async => hospedagem);

        // Act
        final resultado = await repositorio.atualizar(hospedagem);

        // Assert
        expect(resultado, Right(hospedagem));
      },
    );

    test('deve retornar Left(CacheFailure) quando id não existe', () async {
      // Arrange
      when(
        mockDataSource.atualizar(any),
      ).thenThrow(Exception('Hospedagem não encontrada.'));

      // Act
      final resultado = await repositorio.atualizar(_hospedagemFixture());

      // Assert
      expect(resultado.isLeft(), isTrue);
      resultado.fold((Failure) {
        expect(Failure, isA<CacheFailure>());
        expect(Failure.mensagem, contains('Erro ao atualizar'));
      }, (_) => fail('deveria ser Left'));
    });
  });

  // ---------------------------------------------------------------------------
  // deletar
  // ---------------------------------------------------------------------------
  group('deletar', () {
    test(
      'deve retornar Right(void) quando datasource remove com sucesso',
      () async {
        // Arrange
        when(mockDataSource.deletar('id-1')).thenAnswer((_) async {});

        // Act
        final resultado = await repositorio.deletar('id-1');

        // Assert
        expect(resultado.isRight(), isTrue);
      },
    );

    test('deve retornar Left(CacheFailure) quando id não existe', () async {
      // Arrange
      when(
        mockDataSource.deletar(any),
      ).thenThrow(Exception('Hospedagem não encontrada.'));

      // Act
      final resultado = await repositorio.deletar('id-inexistente');

      // Assert
      expect(resultado.isLeft(), isTrue);
      resultado.fold(
        (Failure) => expect(Failure, isA<CacheFailure>()),
        (_) => fail('deveria ser Left'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // obterImoveis
  // ---------------------------------------------------------------------------
  group('obterImoveis', () {
    const imoveisFixture = [ImovelEntity(id: 'i-1', nome: 'Apto Centro SP')];

    test(
      'deve retornar Right(lista) quando datasource retorna com sucesso',
      () async {
        // Arrange
        when(
          mockDataSource.obterImoveis(),
        ).thenAnswer((_) async => imoveisFixture);

        // Act
        final resultado = await repositorio.obterImoveis();

        // Assert
        expect(resultado, const Right(imoveisFixture));
      },
    );

    test(
      'deve retornar Left(CacheFailure) quando datasource lança exceção',
      () async {
        // Arrange
        when(mockDataSource.obterImoveis()).thenThrow(Exception('sem dados'));

        // Act
        final resultado = await repositorio.obterImoveis();

        // Assert
        expect(resultado.isLeft(), isTrue);
      },
    );
  });
}
