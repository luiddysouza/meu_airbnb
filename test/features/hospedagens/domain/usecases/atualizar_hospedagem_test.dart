import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meu_airbnb/core/erros/failures.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/enums.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/domain/usecases/atualizar_hospedagem.dart';
import 'package:mockito/mockito.dart';

import 'hospedagem_repository_mock.mocks.dart';

void main() {
  late MockHospedagemRepository mockRepositorio;
  late AtualizarHospedagem useCase;

  setUp(() {
    mockRepositorio = MockHospedagemRepository();
    provideDummy<Either<Failure, HospedagemEntity>>(
      Right(
        HospedagemEntity(
          id: '',
          nomeHospede: '',
          checkIn: DateTime(2024),
          checkOut: DateTime(2024),
          numHospedes: 0,
          valorTotal: 0,
          status: StatusHospedagem.pendente,
          plataforma: Plataforma.outro,
          imovelId: '',
          criadoEm: DateTime(2024),
        ),
      ),
    );
    useCase = AtualizarHospedagem(mockRepositorio);
  });

  final hospedagemAtualizada = HospedagemEntity(
    id: 'id-1',
    nomeHospede: 'João Silva',
    checkIn: DateTime(2024, 1, 10),
    checkOut: DateTime(2024, 1, 15),
    numHospedes: 3,
    valorTotal: 600.0,
    status: StatusHospedagem.concluida,
    plataforma: Plataforma.airbnb,
    imovelId: 'imovel-1',
    criadoEm: DateTime(2024, 1, 1),
  );

  group('AtualizarHospedagem', () {
    test(
      'deve retornar Right(entidade) quando repositório atualiza com sucesso',
      () async {
        // Arrange
        when(
          mockRepositorio.atualizar(hospedagemAtualizada),
        ).thenAnswer((_) async => Right(hospedagemAtualizada));

        // Act
        final resultado = await useCase.call(hospedagemAtualizada);

        // Assert
        expect(resultado, Right(hospedagemAtualizada));
        verify(mockRepositorio.atualizar(hospedagemAtualizada)).called(1);
      },
    );

    test(
      'deve retornar Left(CacheFailure) quando repositório retorna Failure',
      () async {
        // Arrange
        const falha = CacheFailure('hospedagem não encontrada');
        when(
          mockRepositorio.atualizar(hospedagemAtualizada),
        ).thenAnswer((_) async => const Left(falha));

        // Act
        final resultado = await useCase.call(hospedagemAtualizada);

        // Assert
        expect(resultado, const Left(falha));
      },
    );

    test(
      'deve passar a entidade recebida diretamente ao repositório',
      () async {
        // Arrange
        when(
          mockRepositorio.atualizar(any),
        ).thenAnswer((_) async => Right(hospedagemAtualizada));

        // Act
        await useCase.call(hospedagemAtualizada);

        // Assert
        verify(mockRepositorio.atualizar(hospedagemAtualizada)).called(1);
        verifyNoMoreInteractions(mockRepositorio);
      },
    );
  });
}
