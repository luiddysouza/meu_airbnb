import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meu_airbnb/core/erros/failures.dart';
import 'package:meu_airbnb/core/usecases/usecase.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/imovel_entity.dart';
import 'package:meu_airbnb/features/hospedagens/domain/usecases/obter_imoveis.dart';
import 'package:mockito/mockito.dart';

import 'hospedagem_repository_mock.mocks.dart';

void main() {
  late MockHospedagemRepository mockRepositorio;
  late ObterImoveis useCase;

  setUp(() {
    mockRepositorio = MockHospedagemRepository();
    provideDummy<Either<Failure, List<ImovelEntity>>>(
      const Right<Failure, List<ImovelEntity>>([]),
    );
    provideDummy<Either<Failure, List<HospedagemEntity>>>(
      const Right<Failure, List<HospedagemEntity>>([]),
    );
    useCase = ObterImoveis(mockRepositorio);
  });

  const imoveisFixture = [
    ImovelEntity(id: 'i-1', nome: 'Apto Centro SP'),
    ImovelEntity(id: 'i-2', nome: 'Casa Praia Ubatuba'),
  ];

  group('ObterImoveis', () {
    test(
      'deve retornar Right(lista) quando repositório retorna com sucesso',
      () async {
        // Arrange
        when(
          mockRepositorio.obterImoveis(),
        ).thenAnswer((_) async => const Right(imoveisFixture));

        // Act
        final resultado = await useCase.call(const NoParams());

        // Assert
        expect(resultado, const Right(imoveisFixture));
        verify(mockRepositorio.obterImoveis()).called(1);
      },
    );

    test(
      'deve retornar Left(CacheFailure) quando repositório retorna Failure',
      () async {
        // Arrange
        const falha = CacheFailure('erro ao ler imóveis');
        when(
          mockRepositorio.obterImoveis(),
        ).thenAnswer((_) async => const Left(falha));

        // Act
        final resultado = await useCase.call(const NoParams());

        // Assert
        expect(resultado, const Left(falha));
        verify(mockRepositorio.obterImoveis()).called(1);
      },
    );

    test('deve retornar Right(lista vazia) quando não há imóveis', () async {
      // Arrange
      when(
        mockRepositorio.obterImoveis(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final resultado = await useCase.call(const NoParams());

      // Assert
      expect(resultado.isRight(), isTrue);
      expect(resultado.getRight().toNullable(), isEmpty);
    });

    test('não deve call outros métodos do repositório', () async {
      // Arrange
      when(
        mockRepositorio.obterImoveis(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      await useCase.call(const NoParams());

      // Assert
      verifyNever(mockRepositorio.obterTodas());
    });
  });
}
