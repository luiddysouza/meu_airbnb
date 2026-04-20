import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:meu_airbnb/core/erros/falhas.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/usecases/deletar_hospedagem.dart';

import 'hospedagem_repositorio_mock.mocks.dart';

void main() {
  late MockHospedagemRepositorio mockRepositorio;
  late DeletarHospedagem useCase;

  setUp(() {
    mockRepositorio = MockHospedagemRepositorio();
    provideDummy<Either<Falha, void>>(const Right(null));
    useCase = DeletarHospedagem(mockRepositorio);
  });

  group('DeletarHospedagem', () {
    test(
      'deve retornar Right(void) quando repositório remove com sucesso',
      () async {
        // Arrange
        when(
          mockRepositorio.deletar('id-1'),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final resultado = await useCase.chamar('id-1');

        // Assert
        expect(resultado.isRight(), isTrue);
        verify(mockRepositorio.deletar('id-1')).called(1);
      },
    );

    test(
      'deve retornar Left(FalhaCache) quando repositório retorna falha',
      () async {
        // Arrange
        const falha = FalhaCache('hospedagem não encontrada');
        when(
          mockRepositorio.deletar('id-inexistente'),
        ).thenAnswer((_) async => const Left(falha));

        // Act
        final resultado = await useCase.chamar('id-inexistente');

        // Assert
        expect(resultado, const Left(falha));
      },
    );

    test('deve passar o id recebido diretamente ao repositório', () async {
      // Arrange
      when(
        mockRepositorio.deletar(any),
      ).thenAnswer((_) async => const Right(null));

      // Act
      await useCase.chamar('id-alvo');

      // Assert
      verify(mockRepositorio.deletar('id-alvo')).called(1);
      verifyNoMoreInteractions(mockRepositorio);
    });
  });
}
