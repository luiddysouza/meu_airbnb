import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:meu_airbnb/core/erros/falhas.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/entidades/enums.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/entidades/hospedagem_entidade.dart';
import 'package:meu_airbnb/features/hospedagens/dominio/usecases/adicionar_hospedagem.dart';

import 'hospedagem_repositorio_mock.mocks.dart';

void main() {
  late MockHospedagemRepositorio mockRepositorio;
  late AdicionarHospedagem useCase;

  setUp(() {
    mockRepositorio = MockHospedagemRepositorio();
    provideDummy<Either<Falha, HospedagemEntidade>>(
      Right(
        HospedagemEntidade(
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

  final novaHospedagem = HospedagemEntidade(
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
        final resultado = await useCase.chamar(novaHospedagem);

        // Assert
        expect(resultado, Right(novaHospedagem));
        verify(mockRepositorio.adicionar(novaHospedagem)).called(1);
      },
    );

    test(
      'deve retornar Left(FalhaCache) quando repositório retorna falha',
      () async {
        // Arrange
        const falha = FalhaCache('erro ao salvar hospedagem');
        when(
          mockRepositorio.adicionar(novaHospedagem),
        ).thenAnswer((_) async => const Left(falha));

        // Act
        final resultado = await useCase.chamar(novaHospedagem);

        // Assert
        expect(resultado, const Left(falha));
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
        await useCase.chamar(novaHospedagem);

        // Assert
        verify(mockRepositorio.adicionar(novaHospedagem)).called(1);
        verifyNoMoreInteractions(mockRepositorio);
      },
    );
  });
}
