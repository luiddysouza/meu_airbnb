import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:meu_airbnb/core/erros/failures.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/enums.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/domain/usecases/adicionar_hospedagem.dart';

import 'hospedagem_repository_mock.mocks.dart';

void main() {
  late MockHospedagemRepository mockRepositorio;
  late AdicionarHospedagem useCase;

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
    useCase = AdicionarHospedagem(mockRepositorio);
  });

  final novaHospedagem = HospedagemEntity(
    id: 'id-novo',
    nomeHospede: 'Maria Souza',
    checkIn: DateTime(2024, 3, 1),
    checkOut: DateTime(2024, 3, 5),
    numHospedes: 1,
    valorTotal: 300.0,
    status: StatusHospedagem.pendente,
    plataforma: Plataforma.booking,
    imovelId: 'imovel-2',
    criadoEm: DateTime(2024, 2, 28),
  );

  group('AdicionarHospedagem', () {
    test(
      'deve retornar Right(entidade) quando repositório adiciona com sucesso',
      () async {
        // Arrange
        when(
          mockRepositorio.adicionar(novaHospedagem),
        ).thenAnswer((_) async => Right(novaHospedagem));

        // Act
        final resultado = await useCase.call(novaHospedagem);

        // Assert
        expect(resultado, Right(novaHospedagem));
        verify(mockRepositorio.adicionar(novaHospedagem)).called(1);
      },
    );

    test(
      'deve retornar Left(CacheFailure) quando repositório retorna Failure',
      () async {
        // Arrange
        const Failure = CacheFailure('erro ao salvar hospedagem');
        when(
          mockRepositorio.adicionar(novaHospedagem),
        ).thenAnswer((_) async => const Left(Failure));

        // Act
        final resultado = await useCase.call(novaHospedagem);

        // Assert
        expect(resultado, const Left(Failure));
      },
    );

    test(
      'deve passar a entidade recebida diretamente ao repositório',
      () async {
        // Arrange
        when(
          mockRepositorio.adicionar(any),
        ).thenAnswer((_) async => Right(novaHospedagem));

        // Act
        await useCase.call(novaHospedagem);

        // Assert
        verify(mockRepositorio.adicionar(novaHospedagem)).called(1);
        verifyNoMoreInteractions(mockRepositorio);
      },
    );
  });
}
