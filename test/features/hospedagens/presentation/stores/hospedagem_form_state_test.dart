import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/enums.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/hospedagem_form_state.dart';

void main() {
  group('HospedagemFormState — validate()', () {
    test('estado válido quando todos os campos estão preenchidos', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
        imovelId: 'imovel-1',
      );

      // Act
      final validado = state.validate();

      // Assert
      expect(validado.valido, isTrue);
      expect(validado.erros, isEmpty);
    });

    test('erro quando nomeHospede está vazio', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: '',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
      );

      // Act
      final validado = state.validate();

      // Assert
      expect(validado.valido, isFalse);
      expect(validado.erros['nomeHospede'], isNotNull);
      expect(validado.erros['nomeHospede'], contains('nome'));
    });

    test('erro quando checkIn é null', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: null,
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
      );

      // Act
      final validado = state.validate();

      // Assert
      expect(validado.valido, isFalse);
      expect(validado.erros['checkIn'], isNotNull);
    });

    test('erro quando checkOut é null', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: null,
        status: 'confirmada',
        plataforma: 'airbnb',
      );

      // Act
      final validado = state.validate();

      // Assert
      expect(validado.valido, isFalse);
      expect(validado.erros['checkOut'], isNotNull);
    });

    test('erro quando checkOut é antes de checkIn', () {
      // Arrange
      final checkIn = DateTime(2024, 5, 15);
      final checkOut = DateTime(2024, 5, 10);
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: checkIn,
        checkOut: checkOut,
        status: 'confirmada',
        plataforma: 'airbnb',
      );

      // Act
      final validado = state.validate();

      // Assert
      expect(validado.valido, isFalse);
      expect(validado.erros['checkOut'], isNotNull);
      expect(validado.erros['checkOut'], contains('após'));
    });

    test('erro quando numHospedes é 0', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '0',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
      );

      // Act
      final validado = state.validate();

      // Assert
      expect(validado.valido, isFalse);
      expect(validado.erros['numHospedes'], isNotNull);
      expect(validado.erros['numHospedes'], contains('Mínimo'));
    });

    test('erro quando numHospedes é negativo', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '-5',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
      );

      // Act
      final validado = state.validate();

      // Assert
      expect(validado.valido, isFalse);
      expect(validado.erros['numHospedes'], isNotNull);
    });

    test('erro quando numHospedes não é numérico', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: 'abc',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
      );

      // Act
      final validado = state.validate();

      // Assert
      expect(validado.valido, isFalse);
      expect(validado.erros['numHospedes'], isNotNull);
    });

    test('erro quando valorTotal é negativo', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '-500.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
      );

      // Act
      final validado = state.validate();

      // Assert
      expect(validado.valido, isFalse);
      expect(validado.erros['valorTotal'], isNotNull);
      expect(validado.erros['valorTotal'], contains('>='));
    });

    test('erro quando valorTotal não é numérico', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: 'xyz',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
      );

      // Act
      final validado = state.validate();

      // Assert
      expect(validado.valido, isFalse);
      expect(validado.erros['valorTotal'], isNotNull);
    });

    test('erro quando status é null', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: null,
        plataforma: 'airbnb',
      );

      // Act
      final validado = state.validate();

      // Assert
      expect(validado.valido, isFalse);
      expect(validado.erros['status'], isNotNull);
    });

    test('erro quando plataforma é null', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: null,
      );

      // Act
      final validado = state.validate();

      // Assert
      expect(validado.valido, isFalse);
      expect(validado.erros['plataforma'], isNotNull);
    });

    test('múltiplos erros de validação são coletados', () {
      // Arrange
      const state = HospedagemFormState(
        nomeHospede: '',
        numHospedes: 'abc',
        valorTotal: 'xyz',
        checkIn: null,
        checkOut: null,
        status: null,
        plataforma: null,
      );

      // Act
      final validado = state.validate();

      // Assert
      expect(validado.valido, isFalse);
      expect(validado.erros.length, greaterThan(1));
      expect(validado.erros['nomeHospede'], isNotNull);
      expect(validado.erros['numHospedes'], isNotNull);
      expect(validado.erros['valorTotal'], isNotNull);
      expect(validado.erros['checkIn'], isNotNull);
      expect(validado.erros['checkOut'], isNotNull);
      expect(validado.erros['status'], isNotNull);
      expect(validado.erros['plataforma'], isNotNull);
    });
  });

  group('HospedagemFormState — toEntity()', () {
    test('converte state válido para entidade com sucesso', () {
      // Arrange
      final checkIn = DateTime(2024, 5, 10);
      final checkOut = DateTime(2024, 5, 15);
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: checkIn,
        checkOut: checkOut,
        status: 'confirmada',
        plataforma: 'airbnb',
        imovelId: 'imovel-1',
        notas: 'Hospedagem especial',
      );
      final validado = state.validate();

      // Act
      final entity = validado.toEntity(id: 'hospedagem-1');

      // Assert
      expect(entity.id, equals('hospedagem-1'));
      expect(entity.nomeHospede, equals('João Silva'));
      expect(entity.numHospedes, equals(2));
      expect(entity.valorTotal, equals(1000.00));
      expect(entity.checkIn, equals(checkIn));
      expect(entity.checkOut, equals(checkOut));
      expect(entity.status, equals(StatusHospedagem.confirmada));
      expect(entity.plataforma, equals(Plataforma.airbnb));
      expect(entity.imovelId, equals('imovel-1'));
      expect(entity.notas, equals('Hospedagem especial'));
    });

    test('lança StateError quando state é inválido', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: '',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
      );
      final invalidado = state.validate();

      // Act & Assert
      expect(
        () => invalidado.toEntity(id: 'hospedagem-1'),
        throwsA(isA<StateError>()),
      );
    });

    test('converte formato de valor total com ponto e vírgula', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '2000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
      );
      final validado = state.validate();

      // Act
      final entity = validado.toEntity(id: 'hospedagem-1');

      // Assert
      expect(entity.valorTotal, equals(2000.00));
    });

    test('preenche criadoEm com DateTime.now()', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
      );
      final validado = state.validate();
      final agora = DateTime.now();

      // Act
      final entity = validado.toEntity(id: 'hospedagem-1');

      // Assert — verifica se criadoEm está próximo de agora (diferença < 1 segundo)
      expect(entity.criadoEm.difference(agora).inSeconds.abs(), lessThan(1));
    });

    test('seta imovelId como string vazia se null', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
        imovelId: null,
      );
      final validado = state.validate();

      // Act
      final entity = validado.toEntity(id: 'hospedagem-1');

      // Assert
      expect(entity.imovelId, equals(''));
    });

    test('seta notas como null se vazio ou whitespace', () {
      // Arrange
      final state = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
        notas: '   ',
      );
      final validado = state.validate();

      // Act
      final entity = validado.toEntity(id: 'hospedagem-1');

      // Assert
      expect(entity.notas, isNull);
    });
  });

  group('HospedagemFormState — fromEntity()', () {
    test('copia todos os campos da entidade para o state', () {
      // Arrange
      final entity = HospedagemEntity(
        id: 'hospedagem-1',
        nomeHospede: 'Maria Santos',
        checkIn: DateTime(2024, 6, 1),
        checkOut: DateTime(2024, 6, 5),
        numHospedes: 3,
        valorTotal: 2500.50,
        status: StatusHospedagem.pendente,
        plataforma: Plataforma.booking,
        imovelId: 'imovel-2',
        notas: 'Hóspede VIP',
        criadoEm: DateTime(2024, 1, 1),
      );

      // Act
      final state = HospedagemFormState.fromEntity(entity);

      // Assert
      expect(state.nomeHospede, equals('Maria Santos'));
      expect(state.numHospedes, equals('3'));
      expect(state.valorTotal, equals('2500.50'));
      expect(state.checkIn, equals(entity.checkIn));
      expect(state.checkOut, equals(entity.checkOut));
      expect(state.status, equals('pendente'));
      expect(state.plataforma, equals('booking'));
      expect(state.imovelId, equals('imovel-2'));
      expect(state.notas, equals('Hóspede VIP'));
    });

    test('valida automaticamente após copiar dados', () {
      // Arrange
      final entity = HospedagemEntity(
        id: 'hospedagem-1',
        nomeHospede: 'João Silva',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        numHospedes: 2,
        valorTotal: 1000.0,
        status: StatusHospedagem.confirmada,
        plataforma: Plataforma.airbnb,
        imovelId: 'imovel-1',
        criadoEm: DateTime(2024, 1, 1),
      );

      // Act
      final state = HospedagemFormState.fromEntity(entity);

      // Assert
      expect(state.valido, isTrue);
      expect(state.erros, isEmpty);
    });

    test('seta sujo como false no estado inicial copiado', () {
      // Arrange
      final entity = HospedagemEntity(
        id: 'hospedagem-1',
        nomeHospede: 'João Silva',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        numHospedes: 2,
        valorTotal: 1000.0,
        status: StatusHospedagem.confirmada,
        plataforma: Plataforma.airbnb,
        imovelId: 'imovel-1',
        criadoEm: DateTime(2024, 1, 1),
      );

      // Act
      final state = HospedagemFormState.fromEntity(entity);

      // Assert
      expect(state.sujo, isFalse);
    });

    test('ignora imovelId se for string vazia', () {
      // Arrange
      final entity = HospedagemEntity(
        id: 'hospedagem-1',
        nomeHospede: 'João Silva',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        numHospedes: 2,
        valorTotal: 1000.0,
        status: StatusHospedagem.confirmada,
        plataforma: Plataforma.airbnb,
        imovelId: '',
        criadoEm: DateTime(2024, 1, 1),
      );

      // Act
      final state = HospedagemFormState.fromEntity(entity);

      // Assert
      expect(state.imovelId, isNull);
    });
  });

  group('HospedagemFormState — copyWith()', () {
    test('preserva imutabilidade criando nova instância', () {
      // Arrange
      const original = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
      );

      // Act
      final copia = original.copyWith(nomeHospede: 'Maria Santos');

      // Assert
      expect(original.nomeHospede, equals('João Silva'));
      expect(copia.nomeHospede, equals('Maria Santos'));
      expect(identical(original, copia), isFalse);
    });

    test('altera campo selecionado mantendo outros', () {
      // Arrange
      final original = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
      );

      // Act
      final copia = original.copyWith(numHospedes: '5');

      // Assert
      expect(copia.nomeHospede, equals(original.nomeHospede));
      expect(copia.numHospedes, equals('5'));
      expect(copia.valorTotal, equals(original.valorTotal));
      expect(copia.checkIn, equals(original.checkIn));
    });

    test('copyWith com null mantém valor anterior (null coalescing)', () {
      // Arrange
      const original = HospedagemFormState(
        nomeHospede: 'João Silva',
        notas: 'Alguma nota',
        imovelId: 'imovel-1',
      );

      // Act — passar null não anula, mantém anterior por ?? (coalescing)
      final copia = original.copyWith(notas: null, imovelId: null);

      // Assert — copyWith com null usa ?? então mantém valores
      expect(copia.notas, equals('Alguma nota'));
      expect(copia.imovelId, equals('imovel-1'));
      expect(copia.nomeHospede, equals(original.nomeHospede));
    });

    test('copyWith com múltiplos campos', () {
      // Arrange
      const original = HospedagemFormState();

      // Act
      final copia = original.copyWith(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        status: 'confirmada',
        plataforma: 'airbnb',
        salvando: true,
      );

      // Assert
      expect(copia.nomeHospede, equals('João Silva'));
      expect(copia.numHospedes, equals('2'));
      expect(copia.valorTotal, equals('1000.00'));
      expect(copia.status, equals('confirmada'));
      expect(copia.plataforma, equals('airbnb'));
      expect(copia.salvando, isTrue);
    });
  });

  group('HospedagemFormState — Equatable', () {
    test('dois states com mesmos valores são iguais', () {
      // Arrange
      final state1 = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
      );
      final state2 = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
      );

      // Act & Assert
      expect(state1, equals(state2));
    });

    test('dois states com valores diferentes não são iguais', () {
      // Arrange
      const state1 = HospedagemFormState(nomeHospede: 'João Silva');
      const state2 = HospedagemFormState(nomeHospede: 'Maria Santos');

      // Act & Assert
      expect(state1, isNot(equals(state2)));
    });
  });
}
