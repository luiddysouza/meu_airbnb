import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:meu_airbnb/core/erros/falhas.dart';
import 'package:meu_airbnb/core/usecases/usecase.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/entidades/hospedagem_entidade.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/entidades/imovel_entidade.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/usecases/obter_imoveis.dart';

import 'hospedagem_repositorio_mock.mocks.dart';

void main() {
  late MockHospedagemRepositorio mockRepositorio;
  late ObterImoveis useCase;

  setUp(() {
    mockRepositorio = MockHospedagemRepositorio();
    provideDummy<Either<Falha, List<ImovelEntidade>>>(
      Right<Falha, List<ImovelEntidade>>([]),
    );
    provideDummy<Either<Falha, List<HospedagemEntidade>>>(
      Right<Falha, List<HospedagemEntidade>>([]),
    );
    useCase = ObterImoveis(mockRepositorio);
  });

  const imoveisFixture = [
    ImovelEntidade(id: 'i-1', nome: 'Apto Centro SP'),
    ImovelEntidade(id: 'i-2', nome: 'Casa Praia Ubatuba'),
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
        final resultado = await useCase.chamar(const SemParametros());

        // Assert
        expect(resultado, const Right(imoveisFixture));
        verify(mockRepositorio.obterImoveis()).called(1);
      },
    );

    test(
      'deve retornar Left(FalhaCache) quando repositório retorna falha',
      () async {
        // Arrange
        const falha = FalhaCache('erro ao ler imóveis');
        when(
          mockRepositorio.obterImoveis(),
        ).thenAnswer((_) async => const Left(falha));

        // Act
        final resultado = await useCase.chamar(const SemParametros());

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
      final resultado = await useCase.chamar(const SemParametros());

      // Assert
      expect(resultado.isRight(), isTrue);
      expect(resultado.getRight().toNullable(), isEmpty);
    });

    test('não deve chamar outros métodos do repositório', () async {
      // Arrange
      when(
        mockRepositorio.obterImoveis(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      await useCase.chamar(const SemParametros());

      // Assert
      verifyNever(mockRepositorio.obterTodas());
    });
  });
}
