import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:meu_airbnb/core/erros/falhas.dart';
import 'package:meu_airbnb/core/usecases/usecase.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/entidades/enums.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/entidades/hospedagem_entidade.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/entidades/imovel_entidade.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/usecases/obter_hospedagens.dart';

import 'hospedagem_repositorio_mock.mocks.dart';

void main() {
  late MockHospedagemRepositorio mockRepositorio;
  late ObterHospedagens useCase;

  setUp(() {
    mockRepositorio = MockHospedagemRepositorio();
    provideDummy<Either<Falha, List<HospedagemEntidade>>>(
      Right<Falha, List<HospedagemEntidade>>([]),
    );
    provideDummy<Either<Falha, List<ImovelEntidade>>>(
      Right<Falha, List<ImovelEntidade>>([]),
    );
    useCase = ObterHospedagens(mockRepositorio);
  });

  final hospedagensFixture = [
    HospedagemEntidade(
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
        final resultado = await useCase.chamar(const SemParametros());

        // Assert
        expect(resultado, Right(hospedagensFixture));
        verify(mockRepositorio.obterTodas()).called(1);
      },
    );

    test(
      'deve retornar Left(FalhaCache) quando repositório retorna falha',
      () async {
        // Arrange
        const falha = FalhaCache('erro ao ler hospedagens');
        when(
          mockRepositorio.obterTodas(),
        ).thenAnswer((_) async => const Left(falha));

        // Act
        final resultado = await useCase.chamar(const SemParametros());

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
        final resultado = await useCase.chamar(const SemParametros());

        // Assert
        expect(resultado.isRight(), isTrue);
        expect(resultado.getRight().toNullable(), isEmpty);
      },
    );

    test('não deve chamar outros métodos do repositório', () async {
      // Arrange
      when(
        mockRepositorio.obterTodas(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      await useCase.chamar(const SemParametros());

      // Assert
      verifyNever(mockRepositorio.obterImoveis());
    });
  });
}
