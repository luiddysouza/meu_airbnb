import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:meu_airbnb/core/erros/failures.dart';
import 'package:meu_airbnb/features/hospedagens/domain/usecases/deletar_hospedagem.dart';

import 'hospedagem_repository_mock.mocks.dart';

void main() {
  late MockHospedagemRepository mockRepositorio;
  late DeletarHospedagem useCase;

  setUp(() {
    mockRepositorio = MockHospedagemRepository();
    provideDummy<Either<Failure, void>>(const Right(null));
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
        final resultado = await useCase.call('id-1');

        // Assert
        expect(resultado.isRight(), isTrue);
        verify(mockRepositorio.deletar('id-1')).called(1);
      },
    );

    test(
      'deve retornar Left(CacheFailure) quando repositório retorna Failure',
      () async {
        // Arrange
        const Failure = CacheFailure('hospedagem não encontrada');
        when(
          mockRepositorio.deletar('id-inexistente'),
        ).thenAnswer((_) async => const Left(Failure));

        // Act
        final resultado = await useCase.call('id-inexistente');

        // Assert
        expect(resultado, const Left(Failure));
      },
    );

    test('deve passar o id recebido diretamente ao repositório', () async {
      // Arrange
      when(
        mockRepositorio.deletar(any),
      ).thenAnswer((_) async => const Right(null));

      // Act
      await useCase.call('id-alvo');

      // Assert
      verify(mockRepositorio.deletar('id-alvo')).called(1);
      verifyNoMoreInteractions(mockRepositorio);
    });
  });
}
