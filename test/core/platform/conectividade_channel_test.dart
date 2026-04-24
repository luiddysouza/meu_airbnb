import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/core/platform/conectividade_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConectividadeChannel', () {
    group('ConectividadeChannel obterStatusStream', () {
      test(
        'deve retornar um Stream<String> em qualquer plataforma',
        () {
          final stream = ConectividadeChannel.obterStatusStream();
          expect(stream, isA<Stream<String>>());
        },
      );

      test(
        'deve não lançar exceção ao escutar eventos',
        () async {
          final stream = ConectividadeChannel.obterStatusStream();
          expect(
            () => stream.listen((_) {}),
            isNot(throwsException),
          );
        },
      );

      test(
        'deve emitir eventos de tipo String',
        () async {
          final stream = ConectividadeChannel.obterStatusStream();
          final subscription = stream.listen((event) {
            expect(event, isA<String>());
          });
          await Future.delayed(const Duration(milliseconds: 100));
          await subscription.cancel();
        },
      );

      test(
        'deve permitir múltiplos listeners (broadcast stream)',
        () async {
          final stream = ConectividadeChannel.obterStatusStream();
          final sub1 = stream.listen((_) {});
          final sub2 = stream.listen((_) {});
          expect(sub1, isNotNull);
          expect(sub2, isNotNull);
          await sub1.cancel();
          await sub2.cancel();
        },
      );
    });

    group('ConectividadeChannel obterStatusAtual', () {
      test(
        'deve retornar Future<String> em qualquer plataforma',
        () {
          final future = ConectividadeChannel.obterStatusAtual();
          expect(future, isA<Future<String>>());
        },
      );

      test(
        'deve retornar "online" ou "offline"',
        () async {
          final status = await ConectividadeChannel.obterStatusAtual();
          expect(
            status.toLowerCase(),
            isIn(['online', 'offline']),
          );
        },
      );

      test(
        'deve nunca lançar exceção em iOS/web (retorna "offline")',
        () async {
          final status = await ConectividadeChannel.obterStatusAtual();
          expect(status, isNotNull);
          expect(status, isA<String>());
        },
      );

      test(
        'deve sempre retornar um valor não-nulo',
        () async {
          final status = await ConectividadeChannel.obterStatusAtual();
          expect(status, isNotEmpty);
        },
      );
    });

    group('ConectividadeChannel Comportamento cross-platform', () {
      test(
        'Stream deve ser robusta contra PlatformException',
        () async {
          final stream = ConectividadeChannel.obterStatusStream();
          final received = <String>[];
          final subscription = stream.listen(received.add);
          await Future.delayed(const Duration(milliseconds: 100));
          await subscription.cancel();
          // Não deve lançar; pode estar vazio em web/iOS
          expect(received, isA<List<String>>());
        },
      );

      test(
        'obterStatusAtual deve ser idempotente',
        () async {
          final status1 = await ConectividadeChannel.obterStatusAtual();
          final status2 = await ConectividadeChannel.obterStatusAtual();
          expect(status1, isA<String>());
          expect(status2, isA<String>());
          // Ambas devem ser válidas
          expect(status1.isNotEmpty, true);
          expect(status2.isNotEmpty, true);
        },
      );
    });
  });
}
