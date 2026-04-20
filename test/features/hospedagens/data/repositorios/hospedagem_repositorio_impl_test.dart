import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:meu_airbnb/core/erros/falhas.dart';
import 'package:meu_airbnb/features/hospedagens/data/repositorios/hospedagem_repositorio_impl.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/entidades/enums.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/entidades/hospedagem_entidade.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/entidades/imovel_entidade.dart';

import 'datasource_mock.mocks.dart';

HospedagemEntidade _hospedagemFixture() => HospedagemEntidade(
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
  late HospedagemRepositorioImpl repositorio;

  setUp(() {
    mockDataSource = MockHospedagemLocalDataSource();
    repositorio = HospedagemRepositorioImpl(mockDataSource);
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
      'deve retornar Left(FalhaCache) quando datasource lança exceção',
      () async {
        // Arrange
        when(mockDataSource.obterTodas()).thenThrow(Exception('disco cheio'));

        // Act
        final resultado = await repositorio.obterTodas();

        // Assert
        expect(resultado.isLeft(), isTrue);
        resultado.fold(
          (falha) => expect(falha, isA<FalhaCache>()),
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
      'deve retornar Left(FalhaCache) quando datasource lança exceção',
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
          (falha) => expect(falha, isA<FalhaCache>()),
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

    test('deve retornar Left(FalhaCache) quando id não existe', () async {
      // Arrange
      when(
        mockDataSource.atualizar(any),
      ).thenThrow(Exception('Hospedagem não encontrada.'));

      // Act
      final resultado = await repositorio.atualizar(_hospedagemFixture());

      // Assert
      expect(resultado.isLeft(), isTrue);
      resultado.fold((falha) {
        expect(falha, isA<FalhaCache>());
        expect(falha.mensagem, contains('Erro ao atualizar'));
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

    test('deve retornar Left(FalhaCache) quando id não existe', () async {
      // Arrange
      when(
        mockDataSource.deletar(any),
      ).thenThrow(Exception('Hospedagem não encontrada.'));

      // Act
      final resultado = await repositorio.deletar('id-inexistente');

      // Assert
      expect(resultado.isLeft(), isTrue);
      resultado.fold(
        (falha) => expect(falha, isA<FalhaCache>()),
        (_) => fail('deveria ser Left'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // obterImoveis
  // ---------------------------------------------------------------------------
  group('obterImoveis', () {
    const imoveisFixture = [ImovelEntidade(id: 'i-1', nome: 'Apto Centro SP')];

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
      'deve retornar Left(FalhaCache) quando datasource lança exceção',
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
