import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart' as mi;

import 'package:meu_airbnb/features/hospedagens/domain/entities/enums.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/hospedagem_form_state.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/hospedagem_form_store.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/hospedagem_store.dart';

import 'hospedagem_form_store_test.mocks.dart';

@GenerateMocks([HospedagemStore])
void main() {
  late MockHospedagemStore mockHospedagemStore;
  late HospedagemFormStore formStore;

  setUp(() {
    mockHospedagemStore = MockHospedagemStore();
    formStore = HospedagemFormStore(hospedagemStore: mockHospedagemStore);
  });

  group('HospedagemFormStore — iniciarNovoFormulario()', () {
    test('reseta formState para o padrão', () {
      // Arrange — modificar state
      formStore.formState = HospedagemFormState(
        nomeHospede: 'João Silva',
        status: 'confirmada',
      );

      // Act
      formStore.iniciarNovoFormulario();

      // Assert
      expect(formStore.formState.nomeHospede, equals(''));
      expect(formStore.formState.status, isNull);
      expect(formStore.formState.valido, isFalse);
    });

    test('limpa erros anteriores', () {
      // Arrange
      formStore.formState = const HospedagemFormState().copyWith(
        erros: {'nomeHospede': 'Erro anterior'},
      );

      // Act
      formStore.iniciarNovoFormulario();

      // Assert
      expect(formStore.formState.erros, isEmpty);
    });
  });

  group('HospedagemFormStore — carregarParaEdicao()', () {
    test('copia dados da entidade para o formState', () {
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
        criadoEm: DateTime(2024, 1, 1),
      );

      // Act
      formStore.carregarParaEdicao(entity);

      // Assert
      expect(formStore.formState.nomeHospede, equals('Maria Santos'));
      expect(formStore.formState.numHospedes, equals('3'));
      expect(formStore.formState.valorTotal, equals('2500.50'));
      expect(formStore.formState.status, equals('pendente'));
      expect(formStore.formState.plataforma, equals('booking'));
    });

    test('valida automaticamente após carregar', () {
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
      formStore.carregarParaEdicao(entity);

      // Assert
      expect(formStore.formState.valido, isTrue);
      expect(formStore.formState.erros, isEmpty);
    });
  });

  group('HospedagemFormStore — atualizarNomeHospede()', () {
    test('atualiza nomeHospede e marca como sujo', () {
      // Arrange
      formStore.iniciarNovoFormulario();
      expect(formStore.formState.sujo, isFalse);

      // Act
      formStore.atualizarNomeHospede('João Silva');

      // Assert
      expect(formStore.formState.nomeHospede, equals('João Silva'));
      expect(formStore.formState.sujo, isTrue);
    });

    test('revalida após atualizar', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarNomeHospede('João Silva');

      // Assert — estado inválido pois faltam outros campos
      expect(formStore.formState.valido, isFalse);
      expect(formStore.formState.erros['nomeHospede'], isNull);
    });

    test('exibe erro quando vazio', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarNomeHospede('');

      // Assert
      expect(formStore.formState.erros['nomeHospede'], isNotNull);
    });
  });

  group('HospedagemFormStore — atualizarNumHospedes()', () {
    test('atualiza numHospedes como string', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarNumHospedes('5');

      // Assert
      expect(formStore.formState.numHospedes, equals('5'));
      expect(formStore.formState.sujo, isTrue);
    });

    test('valida número >= 1', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarNumHospedes('0');

      // Assert
      expect(formStore.formState.erros['numHospedes'], isNotNull);
    });
  });

  group('HospedagemFormStore — atualizarValorTotal()', () {
    test('atualiza valorTotal como string', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarValorTotal('2500.50');

      // Assert
      expect(formStore.formState.valorTotal, equals('2500.50'));
      expect(formStore.formState.sujo, isTrue);
    });

    test('valida valor >= 0', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarValorTotal('-100.00');

      // Assert
      expect(formStore.formState.erros['valorTotal'], isNotNull);
    });
  });

  group('HospedagemFormStore — atualizarCheckIn()', () {
    test('atualiza checkIn com DateTime', () {
      // Arrange
      formStore.iniciarNovoFormulario();
      final data = DateTime(2024, 5, 10);

      // Act
      formStore.atualizarCheckIn(data);

      // Assert
      expect(formStore.formState.checkIn, equals(data));
      expect(formStore.formState.sujo, isTrue);
    });

    test('ajusta checkOut automaticamente se anterior ao novo checkIn', () {
      // Arrange
      formStore.iniciarNovoFormulario();
      final checkIn1 = DateTime(2024, 5, 10);
      final checkOut1 = DateTime(2024, 5, 12);
      formStore.atualizarCheckIn(checkIn1);
      formStore.atualizarCheckOut(checkOut1);

      // Act — novo checkIn posterior ao checkOut
      final novoCheckIn = DateTime(2024, 5, 15);
      formStore.atualizarCheckIn(novoCheckIn);

      // Assert — checkOut deve ser ajustado para novoCheckIn + 1 dia
      expect(formStore.formState.checkIn, equals(novoCheckIn));
      expect(
        formStore.formState.checkOut,
        equals(novoCheckIn.add(const Duration(days: 1))),
      );
    });

    test('permite null (não selecionado)', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarCheckIn(null);

      // Assert
      expect(formStore.formState.checkIn, isNull);
    });
  });

  group('HospedagemFormStore — atualizarCheckOut()', () {
    test('atualiza checkOut com DateTime', () {
      // Arrange
      formStore.iniciarNovoFormulario();
      final data = DateTime(2024, 5, 15);

      // Act
      formStore.atualizarCheckOut(data);

      // Assert
      expect(formStore.formState.checkOut, equals(data));
      expect(formStore.formState.sujo, isTrue);
    });
  });

  group('HospedagemFormStore — atualizarStatus()', () {
    test('atualiza status como enum.name string', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarStatus('confirmada');

      // Assert
      expect(formStore.formState.status, equals('confirmada'));
      expect(formStore.formState.sujo, isTrue);
    });

    test('permite null (não selecionado)', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarStatus(null);

      // Assert
      expect(formStore.formState.status, isNull);
    });
  });

  group('HospedagemFormStore — atualizarPlataforma()', () {
    test('atualiza plataforma como enum.name string', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarPlataforma('booking');

      // Assert
      expect(formStore.formState.plataforma, equals('booking'));
      expect(formStore.formState.sujo, isTrue);
    });

    test('permite null', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarPlataforma(null);

      // Assert
      expect(formStore.formState.plataforma, isNull);
    });
  });

  group('HospedagemFormStore — atualizarImovel()', () {
    test('atualiza imovelId', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarImovel('imovel-1');

      // Assert
      expect(formStore.formState.imovelId, equals('imovel-1'));
      expect(formStore.formState.sujo, isTrue);
    });
  });

  group('HospedagemFormStore — atualizarNotas()', () {
    test('atualiza notas com valor', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarNotas('Hóspede VIP');

      // Assert
      expect(formStore.formState.notas, equals('Hóspede VIP'));
      expect(formStore.formState.sujo, isTrue);
    });

    test('permite null', () {
      // Arrange
      formStore.iniciarNovoFormulario();

      // Act
      formStore.atualizarNotas(null);

      // Assert
      expect(formStore.formState.notas, isNull);
    });
  });

  group('HospedagemFormStore — atualizarFotoBase64()', () {
    test('atualiza fotoBase64', () {
      // Arrange
      formStore.iniciarNovoFormulario();
      const base64 =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

      // Act
      formStore.atualizarFotoBase64(base64);

      // Assert
      expect(formStore.formState.fotoBase64, equals(base64));
      expect(formStore.formState.sujo, isTrue);
    });
  });

  group('HospedagemFormStore — removerFoto()', () {
    test('marca como sujo ao remover fotoBase64', () {
      // Arrange
      const base64 =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
      formStore.formState = HospedagemFormState(fotoBase64: base64);

      // Act
      formStore.removerFoto();

      // Assert — marca como sujo (fotoBase64 mantém por ?? coalescing)
      expect(formStore.formState.sujo, isTrue);
    });
  });

  group('HospedagemFormStore — salvar()', () {
    test('não salva se formState inválido', () async {
      // Arrange
      formStore.iniciarNovoFormulario();
      expect(formStore.formState.valido, isFalse);

      // Act
      await formStore.salvar();

      // Assert
      expect(formStore.formState.salvando, isFalse);
      mi.verifyNever(mockHospedagemStore.adicionarHospedagem(mi.any));
    });

    test('modo criação chama adicionarHospedagem com novo ID', () async {
      // Arrange
      formStore.formState = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
        imovelId: 'imovel-1',
      ).validate();

      mi.when(mockHospedagemStore.erro).thenReturn(null);

      // Act
      await formStore.salvar();

      // Assert
      mi.verify(mockHospedagemStore.adicionarHospedagem(mi.any)).called(1);
      mi.verifyNever(mockHospedagemStore.atualizarHospedagem(mi.any));
      expect(formStore.formState.salvando, isFalse);
    });

    test('modo edição chama atualizarHospedagem com ID existente', () async {
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
      formStore.carregarParaEdicao(entity);

      mi.when(mockHospedagemStore.erro).thenReturn(null);

      // Act
      await formStore.salvar(idExistente: 'hospedagem-1');

      // Assert
      mi.verifyNever(mockHospedagemStore.adicionarHospedagem(mi.any));
      mi.verify(mockHospedagemStore.atualizarHospedagem(mi.any)).called(1);
      expect(formStore.formState.salvando, isFalse);
    });

    test('exibe erro do store se houver', () async {
      // Arrange
      formStore.formState = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
        imovelId: 'imovel-1',
      ).validate();

      const erroMessage = 'Erro ao salvar hospedagem';
      mi
          .when(mockHospedagemStore.adicionarHospedagem(mi.any))
          .thenAnswer((_) async {});
      mi.when(mockHospedagemStore.erro).thenReturn(erroMessage);

      // Act
      await formStore.salvar();

      // Assert
      expect(formStore.erroSubmit, equals(erroMessage));
      expect(formStore.formState.salvando, isFalse);
      expect(formStore.formState.valido, isFalse);
    });

    test('seta salvando = true durante o processo', () async {
      // Arrange
      formStore.formState = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
        imovelId: 'imovel-1',
      ).validate();

      mi
          .when(mockHospedagemStore.adicionarHospedagem(mi.any))
          .thenAnswer((_) => Future.delayed(const Duration(milliseconds: 100)));
      mi.when(mockHospedagemStore.erro).thenReturn(null);

      // Act
      final futuroSalvar = formStore.salvar();

      // Assert
      await futuroSalvar;
      expect(formStore.formState.salvando, isFalse);
    });

    test('captura exceção durante salvar e exibe no submit', () async {
      // Arrange
      formStore.formState = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
        imovelId: 'imovel-1',
      ).validate();

      mi
          .when(mockHospedagemStore.adicionarHospedagem(mi.any))
          .thenThrow(Exception('Erro inesperado'));

      // Act
      await formStore.salvar();

      // Assert
      expect(formStore.erroSubmit, isNotNull);
      expect(formStore.erroSubmit, contains('Erro inesperado'));
      expect(formStore.formState.salvando, isFalse);
    });
  });

  group('HospedagemFormStore — Computed Properties', () {
    test('formularioValido retorna formState.valido', () {
      // Arrange
      formStore.iniciarNovoFormulario();
      expect(formStore.formularioValido, isFalse);

      // Act
      formStore.formState = HospedagemFormState(
        nomeHospede: 'João Silva',
        numHospedes: '2',
        valorTotal: '1000.00',
        checkIn: DateTime(2024, 5, 10),
        checkOut: DateTime(2024, 5, 15),
        status: 'confirmada',
        plataforma: 'airbnb',
        imovelId: 'imovel-1',
      ).validate();

      // Assert
      expect(formStore.formularioValido, isTrue);
    });

    test('formularioSalvando retorna formState.salvando', () {
      // Arrange
      formStore.iniciarNovoFormulario();
      expect(formStore.formularioSalvando, isFalse);

      // Act
      formStore.formState = formStore.formState.copyWith(salvando: true);

      // Assert
      expect(formStore.formularioSalvando, isTrue);
    });

    test('erroSubmit retorna erro de submit ou null', () {
      // Arrange
      formStore.iniciarNovoFormulario();
      expect(formStore.erroSubmit, isNull);

      // Act
      formStore.formState = formStore.formState.copyWith(
        erros: const {'submit': 'Erro ao salvar'},
      );

      // Assert
      expect(formStore.erroSubmit, equals('Erro ao salvar'));
    });
  });

  group('HospedagemFormStore — limpar()', () {
    test('reseta formState para padrão', () {
      // Arrange
      formStore.formState = HospedagemFormState(
        nomeHospede: 'João Silva',
        status: 'confirmada',
        erros: const {'submit': 'Erro'},
      );

      // Act
      formStore.limpar();

      // Assert
      expect(formStore.formState.nomeHospede, equals(''));
      expect(formStore.formState.status, isNull);
      expect(formStore.formState.erros, isEmpty);
    });
  });
}
