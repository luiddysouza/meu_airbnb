import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/enums.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/imovel_entity.dart';

HospedagemEntity _hospedagemFixture() => HospedagemEntity(
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
  group('HospedagemEntity', () {
    group('Equatable', () {
      test('duas instâncias com os mesmos campos são iguais', () {
        // Arrange
        final h1 = _hospedagemFixture();
        final h2 = _hospedagemFixture();

        // Assert
        expect(h1, equals(h2));
      });

      test('instâncias com nomes diferentes não são iguais', () {
        // Arrange
        final h1 = _hospedagemFixture();
        final h2 = _hospedagemFixture().copyWith(nomeHospede: 'Maria');

        // Assert
        expect(h1, isNot(equals(h2)));
      });
    });

    group('copyWith', () {
      test('copyWith sem argumentos retorna entidade equivalente', () {
        // Arrange
        final original = _hospedagemFixture();

        // Act
        final copia = original.copyWith();

        // Assert
        expect(copia, equals(original));
      });

      test('copyWith altera apenas os campos fornecidos', () {
        // Arrange
        final original = _hospedagemFixture();

        // Act
        final atualizada = original.copyWith(
          nomeHospede: 'Maria Souza',
          valorTotal: 750.0,
          status: StatusHospedagem.concluida,
        );

        // Assert
        expect(atualizada.nomeHospede, 'Maria Souza');
        expect(atualizada.valorTotal, 750.0);
        expect(atualizada.status, StatusHospedagem.concluida);
        // Campos não alterados permanecem iguais
        expect(atualizada.id, original.id);
        expect(atualizada.checkIn, original.checkIn);
        expect(atualizada.imovelId, original.imovelId);
      });

      test('copyWith altera telefone', () {
        // Arrange
        final original = _hospedagemFixture();

        // Act
        final atualizada = original.copyWith(telefone: '11999999999');

        // Assert
        expect(atualizada.telefone, '11999999999');
        expect(original.telefone, isNull);
      });

      test('copyWith altera notas', () {
        // Arrange
        final original = _hospedagemFixture();

        // Act
        final atualizada = original.copyWith(notas: 'Hóspede VIP');

        // Assert
        expect(atualizada.notas, 'Hóspede VIP');
      });
    });

    test('campos opcionais são nulos por padrão', () {
      // Arrange
      final h = _hospedagemFixture();

      // Assert
      expect(h.telefone, isNull);
      expect(h.notas, isNull);
    });
  });

  group('ImovelEntity', () {
    test('duas instâncias com os mesmos campos são iguais (Equatable)', () {
      // Arrange
      const i1 = ImovelEntity(id: 'i-1', nome: 'Apto Centro');
      const i2 = ImovelEntity(id: 'i-1', nome: 'Apto Centro');

      // Assert
      expect(i1, equals(i2));
    });

    test('instâncias com ids diferentes não são iguais', () {
      // Arrange
      const i1 = ImovelEntity(id: 'i-1', nome: 'Apto');
      const i2 = ImovelEntity(id: 'i-2', nome: 'Apto');

      // Assert
      expect(i1, isNot(equals(i2)));
    });

    test('endereço opcional é nulo por padrão', () {
      // Arrange
      const imovel = ImovelEntity(id: 'i-1', nome: 'Apto');

      // Assert
      expect(imovel.endereco, isNull);
    });

    test('endereço é incluído na comparação Equatable', () {
      // Arrange
      const i1 = ImovelEntity(id: 'i-1', nome: 'Apto', endereco: 'Rua A');
      const i2 = ImovelEntity(id: 'i-1', nome: 'Apto', endereco: 'Rua B');

      // Assert
      expect(i1, isNot(equals(i2)));
    });
  });

  group('Enums', () {
    test('StatusHospedagem tem 4 valores', () {
      expect(StatusHospedagem.values.length, 4);
    });

    test('Plataforma tem 4 valores', () {
      expect(Plataforma.values.length, 4);
    });

    test('StatusHospedagem contém todos os status esperados', () {
      expect(StatusHospedagem.values, contains(StatusHospedagem.confirmada));
      expect(StatusHospedagem.values, contains(StatusHospedagem.pendente));
      expect(StatusHospedagem.values, contains(StatusHospedagem.cancelada));
      expect(StatusHospedagem.values, contains(StatusHospedagem.concluida));
    });

    test('Plataforma contém todas as plataformas esperadas', () {
      expect(Plataforma.values, contains(Plataforma.airbnb));
      expect(Plataforma.values, contains(Plataforma.booking));
      expect(Plataforma.values, contains(Plataforma.direto));
      expect(Plataforma.values, contains(Plataforma.outro));
    });
  });
}
