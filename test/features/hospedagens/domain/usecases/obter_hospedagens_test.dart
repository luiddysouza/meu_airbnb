import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meu_airbnb/core/erros/failures.dart';
import 'package:meu_airbnb/core/usecases/usecase.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/enums.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/imovel_entity.dart';
import 'package:meu_airbnb/features/hospedagens/domain/usecases/obter_hospedagens.dart';
import 'package:mockito/mockito.dart';

import 'hospedagem_repository_mock.mocks.dart';

void main() {
  late MockHospedagemRepository mockRepositorio;
  late ObterHospedagens useCase;

  setUp(() {
    mockRepositorio = MockHospedagemRepository();
    provideDummy<Either<Failure, List<HospedagemEntity>>>(
      const Right<Failure, List<HospedagemEntity>>([]),
    );
    provideDummy<Either<Failure, List<ImovelEntity>>>(
      const Right<Failure, List<ImovelEntity>>([]),
    );
    useCase = ObterHospedagens(mockRepositorio);
  });

  final hospedagensFixture = [
    HospedagemEntity(
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
    ),
  ];

  group('ObterHospedagens', () {
    test(
      'deve retornar Right(lista) quando repositório retorna com sucesso',
      () async {
        // Arrange
        when(
          mockRepositorio.obterTodas(),
        ).thenAnswer((_) async => Right(hospedagensFixture));

        // Act
        final resultado = await useCase.call(const NoParams());

        // Assert
        expect(resultado, Right(hospedagensFixture));
        verify(mockRepositorio.obterTodas()).called(1);
      },
    );

    test(
      'deve retornar Left(CacheFailure) quando repositório retorna Failure',
      () async {
        // Arrange
        const falha = CacheFailure('erro ao ler hospedagens');
        when(
          mockRepositorio.obterTodas(),
        ).thenAnswer((_) async => const Left(falha));

        // Act
        final resultado = await useCase.call(const NoParams());

        // Assert
        expect(resultado, const Left(falha));
        verify(mockRepositorio.obterTodas()).called(1);
      },
    );

    test(
      'deve retornar Right(lista vazia) quando não há hospedagens',
      () async {
        // Arrange
        when(
          mockRepositorio.obterTodas(),
        ).thenAnswer((_) async => const Right([]));

        // Act
        final resultado = await useCase.call(const NoParams());

        // Assert
        expect(resultado.isRight(), isTrue);
        expect(resultado.getRight().toNullable(), isEmpty);
      },
    );

    test('não deve call outros métodos do repositório', () async {
      // Arrange
      when(
        mockRepositorio.obterTodas(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      await useCase.call(const NoParams());

      // Assert
      verifyNever(mockRepositorio.obterImoveis());
    });
  });
}
