import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/core/platform/conectividade_channel.dart';
import 'package:meu_airbnb/features/hospedagens/presentation/stores/conectividade_store.dart';
import 'package:mobx/mobx.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ConectividadeChannel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConectividadeStore', () {
    group('ConectividadeStore inicialização', () {
      test('deve iniciar com estaOnline=true por padrão', () {
        final store = ConectividadeStore();
        expect(store.estaOnline, true);
        expect(store.statusTexto, 'online');
      });

      test('deve ter observable estaOnline', () {
        final store = ConectividadeStore();
        expect(store.estaOnline, isA<bool>());
      });

      test('deve ter observable statusTexto', () {
        final store = ConectividadeStore();
        expect(store.statusTexto, isA<String>());
      });
    });

    group('ConectividadeStore atualização de status', () {
      test(
        'deve atualizar estaOnline para true quando recebe "online"',
        () async {
          final store = ConectividadeStore();
          store.atualizarStatus('online');
          expect(store.estaOnline, true);
          expect(store.statusTexto, 'online');
        },
      );

      test(
        'deve atualizar estaOnline para false quando recebe "offline"',
        () async {
          final store = ConectividadeStore();
          store.atualizarStatus('offline');
          expect(store.estaOnline, false);
          expect(store.statusTexto, 'offline');
        },
      );

      test('deve aceitar sequência de mudanças de status', () async {
        final store = ConectividadeStore();

        store.atualizarStatus('online');
        expect(store.estaOnline, true);

        store.atualizarStatus('offline');
        expect(store.estaOnline, false);

        store.atualizarStatus('online');
        expect(store.estaOnline, true);
      });
    });

    group('ConectividadeStore carregarStatusAtual', () {
      test('deve existir e ser chamável', () async {
        final store = ConectividadeStore();
        // Apenas verifica que o método existe e pode ser chamado
        final future = store.carregarStatusAtual();
        expect(future, isA<Future<void>>());
        // Não aguardamos porque pode falhar sem impl nativa
      });
    });

    group('ConectividadeStore lifecycle', () {
      test('iniciar() deve registrar listener sem exceção', () {
        final store = ConectividadeStore();
        expect(() => store.iniciar(), isNot(throwsException));
        store.parar();
      });

      test('parar() deve cancelar subscription sem exceção', () {
        final store = ConectividadeStore();
        store.iniciar();
        expect(() => store.parar(), isNot(throwsException));
      });

      test('deve permitir iniciar/parar múltiplas vezes', () {
        final store = ConectividadeStore();
        store.iniciar();
        store.parar();
        store.iniciar();
        expect(store.estaOnline, isA<bool>());
        store.parar();
      });
    });

    group('ConectividadeStore reatividade MobX', () {
      test('mudanças em estaOnline devem ser observáveis', () async {
        final store = ConectividadeStore();
        final estados = <bool>[];

        reaction((_) => store.estaOnline, (bool estado) => estados.add(estado));

        // Initial state: true (não é capturado por reaction)
        store.atualizarStatus('offline');
        store.atualizarStatus('online');

        await Future.delayed(const Duration(milliseconds: 50));
        // Apenas as mudanças após reaction() são capturadas
        expect(estados.length, greaterThanOrEqualTo(1));
      });

      test('Observer deve reagir a mudanças de statusTexto', () async {
        final store = ConectividadeStore();
        final statuses = <String>[];

        reaction(
          (_) => store.statusTexto,
          (String status) => statuses.add(status),
        );

        store.atualizarStatus('offline');
        store.atualizarStatus('online');

        await Future.delayed(const Duration(milliseconds: 50));
        expect(statuses.contains('offline'), true);
        expect(statuses.contains('online'), true);
      });
    });
  });
}
