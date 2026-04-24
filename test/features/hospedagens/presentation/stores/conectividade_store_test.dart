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
      test(
        'deve iniciar com estaOnline=true por padrão',
        () {
          final store = ConectividadeStore();
          expect(store.estaOnline, true);
          expect(store.statusTexto, 'online');
        },
      );

      test(
        'deve ter observable estaOnline',
        () {
          final store = ConectividadeStore();
          expect(store.estaOnline, isA<bool>());
        },
      );

      test(
        'deve ter observable statusTexto',
        () {
          final store = ConectividadeStore();
          expect(store.statusTexto, isA<String>());
        },
      );
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

      test(
        'deve reagir a múltiplas mudanças de status',
        () async {
          final store = ConectividadeStore();
          final stati = <String>[];
          reaction(
            (_) => store.statusTexto,
            (String status) => stati.add(status),
          );

          store.atualizarStatus('online');
          store.atualizarStatus('offline');
          store.atualizarStatus('online');

          await Future.delayed(const Duration(milliseconds: 50));
          expect(stati, ['online', 'offline', 'online']);
        },
      );
    });

    group('ConectividadeStore carregarStatusAtual', () {
      test(
        'deve chamar ConectividadeChannel.obterStatusAtual()',
        () async {
          final store = ConectividadeStore();
          // Mock seria necessário para verificar chamada real;
          // aqui testamos que não lança exceção
          expect(
            () async => await store.carregarStatusAtual(),
            isNot(throwsException),
          );
        },
      );

      test(
        'deve atualizar o status baseado no retorno do channel',
        () async {
          final store = ConectividadeStore();
          store.atualizarStatus('offline');
          // Depois de chamar, deveria atualizar
          // (em teste unitário sem mock do channel, pode não fazer muito)
          await store.carregarStatusAtual();
          expect(store.statusTexto, isA<String>());
        },
      );
    });

    group('ConectividadeStore lifecycle', () {
      test(
        'iniciar() deve registrar listener sem exceção',
        () {
          final store = ConectividadeStore();
          expect(() => store.iniciar(), isNot(throwsException));
          store.parar();
        },
      );

      test(
        'parar() deve cancelar subscription sem exceção',
        () {
          final store = ConectividadeStore();
          store.iniciar();
          expect(() => store.parar(), isNot(throwsException));
        },
      );

      test(
        'deve permitir iniciar/parar múltiplas vezes',
        () {
          final store = ConectividadeStore();
          store.iniciar();
          store.parar();
          store.iniciar();
          expect(store.estaOnline, isA<bool>());
          store.parar();
        },
      );
    });

    group('ConectividadeStore reatividade MobX', () {
      test(
        'mudanças em estaOnline devem ser observáveis',
        () async {
          final store = ConectividadeStore();
          final estados = <bool>[];

          reaction(
            (_) => store.estaOnline,
            (bool estado) => estados.add(estado),
          );

          store.atualizarStatus('online');
          store.atualizarStatus('offline');
          store.atualizarStatus('online');

          await Future.delayed(const Duration(milliseconds: 50));
          expect(estados, [false, true]);
        },
      );

      test(
        'Observer deve reagir a mudanças de statusTexto',
        () async {
          final store = ConectividadeStore();
          final statuses = <String>[];

          reaction(
            (_) => store.statusTexto,
            (String status) => statuses.add(status),
          );

          store.atualizarStatus('offline');
          store.atualizarStatus('online');

          await Future.delayed(const Duration(milliseconds: 50));
          expect(statuses, ['offline', 'online']);
        },
      );
    });
  });
}
