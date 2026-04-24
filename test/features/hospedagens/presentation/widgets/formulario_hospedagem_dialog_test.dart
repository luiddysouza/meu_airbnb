import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meu_airbnb/core/di/injecao.dart';
import 'package:meu_airbnb/core/erros/failures.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/enums.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/imovel_entity.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/hospedagem_form_store.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/hospedagem_store.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/widgets/formulario_hospedagem_dialog.dart';
import 'package:mockito/mockito.dart';

import '../stores/usecases_mock.mocks.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _app(Widget child) => MaterialApp(theme: DsTemaApp.tema, home: child);

HospedagemStore _criarStore({
  required MockAdicionarHospedagem mockAdicionar,
  required MockAtualizarHospedagem mockAtualizar,
  required MockDeletarHospedagem mockDeletar,
  required MockObterHospedagens mockObter,
}) => HospedagemStore(mockObter, mockAdicionar, mockAtualizar, mockDeletar);

const _imoveis = [
  ImovelEntity(id: 'imovel-1', nome: 'Casa Praia'),
  ImovelEntity(id: 'imovel-2', nome: 'Apto Centro'),
];

final _hospedagemFixture = HospedagemEntity(
  id: 'id-1',
  nomeHospede: 'João Silva',
  checkIn: DateTime(2024, 3, 10),
  checkOut: DateTime(2024, 3, 15),
  numHospedes: 2,
  valorTotal: 800.0,
  status: StatusHospedagem.confirmada,
  plataforma: Plataforma.airbnb,
  imovelId: 'imovel-1',
  criadoEm: DateTime(2024, 1, 1),
);

// ---------------------------------------------------------------------------
// Testes
// ---------------------------------------------------------------------------

void main() {
  late MockObterHospedagens mockObter;
  late MockAdicionarHospedagem mockAdicionar;
  late MockAtualizarHospedagem mockAtualizar;
  late MockDeletarHospedagem mockDeletar;
  late HospedagemStore store;

  setUp(() {
    mockObter = MockObterHospedagens();
    mockAdicionar = MockAdicionarHospedagem();
    mockAtualizar = MockAtualizarHospedagem();
    mockDeletar = MockDeletarHospedagem();

    provideDummy<Either<Failure, List<HospedagemEntity>>>(
      const Right<Failure, List<HospedagemEntity>>([]),
    );
    provideDummy<Either<Failure, HospedagemEntity>>(
      Right<Failure, HospedagemEntity>(_hospedagemFixture),
    );
    provideDummy<Either<Failure, void>>(const Right<Failure, void>(null));

    store = _criarStore(
      mockAdicionar: mockAdicionar,
      mockAtualizar: mockAtualizar,
      mockDeletar: mockDeletar,
      mockObter: mockObter,
    );

    // Registrar HospedagemFormStore no GetIt com o store mockado
    if (sl.isRegistered<HospedagemFormStore>()) {
      sl.unregister<HospedagemFormStore>();
    }
    sl.registerFactory<HospedagemFormStore>(
      () => HospedagemFormStore(hospedagemStore: store),
    );
  });

  tearDown(() {
    if (sl.isRegistered<HospedagemFormStore>()) {
      sl.unregister<HospedagemFormStore>();
    }
  });

  // ── Modo criação ──────────────────────────────────────────────────────────

  group('FormularioHospedagemDialog — modo criação', () {
    testWidgets('exibe título "Nova hospedagem" no modo criação', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => FormularioHospedagemDialog.mostrar(
                  ctx,
                  imoveis: _imoveis,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nova hospedagem'), findsOneWidget);
    });

    testWidgets('renderiza campos do formulário', (tester) async {
      // Arrange
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => FormularioHospedagemDialog.mostrar(
                  ctx,
                  imoveis: _imoveis,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Assert — campos essenciais presentes
      expect(find.text('Nome do hóspede'), findsOneWidget);
      expect(find.text('Check-in'), findsAtLeastNWidgets(1));
      expect(find.text('Check-out'), findsAtLeastNWidgets(1));
      expect(find.text('Hóspedes'), findsOneWidget);
      expect(find.text('Valor total (R\$)'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Plataforma'), findsOneWidget);
    });

    testWidgets('exibe botão "Criar hospedagem"', (tester) async {
      // Arrange
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => FormularioHospedagemDialog.mostrar(
                  ctx,
                  imoveis: [],
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Criar hospedagem'), findsOneWidget);
    });

    testWidgets('exibe dropdown de imóveis quando lista não está vazia', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => FormularioHospedagemDialog.mostrar(
                  ctx,
                  imoveis: _imoveis,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Assert — dropdown de imóvel presente
      expect(find.text('Selecione o imóvel'), findsOneWidget);
    });

    testWidgets('fecha dialog retornando false ao tocar em Cancelar', (
      tester,
    ) async {
      // Arrange
      bool? resultado;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () async {
                  resultado = await FormularioHospedagemDialog.mostrar(
                    ctx,
                    imoveis: [],
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Cancelar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Assert
      expect(resultado, isFalse);
      expect(find.byType(FormularioHospedagemDialog), findsNothing);
    });

    testWidgets('exibe erro de validação quando nome está vazio', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => FormularioHospedagemDialog.mostrar(
                  ctx,
                  imoveis: [],
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      // Clica Criar sem preencher nome
      await tester.ensureVisible(find.text('Criar hospedagem'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Criar hospedagem'));
      await tester.pumpAndSettle();

      // Assert — mensagem de validação aparece
      expect(find.text('Informe o nome do hóspede'), findsOneWidget);
    });

    testWidgets('chama adicionarHospedagem ao salvar formulário válido', (
      tester,
    ) async {
      // Arrange
      when(mockAdicionar(any)).thenAnswer(
        (_) async => Right<Failure, HospedagemEntity>(_hospedagemFixture),
      );

      // Cria store pré-configurado com dados válidos (bypass do iniciarNovoFormulario)
      final formStorePreConfigurado = HospedagemFormStore(
        hospedagemStore: store,
      );
      formStorePreConfigurado.carregarParaEdicao(_hospedagemFixture);

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => FormularioHospedagemDialog.mostrar(
                  ctx,
                  imoveis: [],
                  formStoreOverride: formStorePreConfigurado,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Criar hospedagem'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Criar hospedagem'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockAdicionar(any)).called(1);
    });
  });

  // ── Modo edição ────────────────────────────────────────────────────────────

  group('FormularioHospedagemDialog — modo edição', () {
    testWidgets('exibe título "Editar hospedagem" no modo edição', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => FormularioHospedagemDialog.mostrar(
                  ctx,
                  imoveis: _imoveis,
                  hospedagem: _hospedagemFixture,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Editar hospedagem'), findsOneWidget);
    });

    testWidgets('pré-preenche campos com dados da hospedagem', (tester) async {
      // Arrange
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => FormularioHospedagemDialog.mostrar(
                  ctx,
                  imoveis: _imoveis,
                  hospedagem: _hospedagemFixture,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Assert — nome do hóspede pré-preenchido
      expect(find.text('João Silva'), findsOneWidget);
    });

    testWidgets('exibe botão "Salvar alterações" no modo edição', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => FormularioHospedagemDialog.mostrar(
                  ctx,
                  imoveis: [],
                  hospedagem: _hospedagemFixture,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Salvar alterações'), findsOneWidget);
    });

    testWidgets('chama atualizarHospedagem ao salvar no modo edição', (
      tester,
    ) async {
      // Arrange
      when(mockAtualizar(any)).thenAnswer(
        (_) async => Right<Failure, HospedagemEntity>(_hospedagemFixture),
      );

      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => FormularioHospedagemDialog.mostrar(
                  ctx,
                  imoveis: _imoveis,
                  hospedagem: _hospedagemFixture,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockAtualizar(any)).called(1);
      verifyNever(mockAdicionar(any));
    });

    testWidgets(
      'exibe erro e mantém dialog aberto quando store retorna falha',
      (tester) async {
        // Arrange
        when(mockAtualizar(any)).thenAnswer(
          (_) async => const Left<Failure, HospedagemEntity>(
            CacheFailure('Erro ao salvar'),
          ),
        );

        await tester.pumpWidget(
          _app(
            Scaffold(
              body: Builder(
                builder: (ctx) => TextButton(
                  onPressed: () => FormularioHospedagemDialog.mostrar(
                    ctx,
                    imoveis: _imoveis,
                    hospedagem: _hospedagemFixture,
                  ),
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Salvar alterações'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Salvar alterações'));
        await tester.pumpAndSettle();

        // Assert — dialog continua aberto + mensagem de erro
        expect(find.text('Erro ao salvar'), findsOneWidget);
        expect(find.byType(FormularioHospedagemDialog), findsOneWidget);
      },
    );

    testWidgets('fecha dialog retornando true em caso de sucesso', (
      tester,
    ) async {
      // Arrange
      when(mockAtualizar(any)).thenAnswer(
        (_) async => Right<Failure, HospedagemEntity>(_hospedagemFixture),
      );

      bool? resultado;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () async {
                  resultado = await FormularioHospedagemDialog.mostrar(
                    ctx,
                    imoveis: _imoveis,
                    hospedagem: _hospedagemFixture,
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      // Assert
      expect(resultado, isTrue);
      expect(find.byType(FormularioHospedagemDialog), findsNothing);
    });
  });
}

