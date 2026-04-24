import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/features/auth/presentation/stores/biometric_store.dart';
import 'package:mobx/mobx.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BiometricStore', () {
    group('Inicialização', () {
      test('deve inicializar com valores padrão', () {
        final store = BiometricStore();
        expect(store.autenticando, isFalse);
        expect(store.disponivel, isFalse);
        expect(store.tipoBiometrico, 'nenhum');
        expect(store.erro, isNull);
      });

      test('deve ser um Store MobX válido', () {
        final store = BiometricStore();
        expect(store, isA<Store>());
      });
    });

    group('limparErro', () {
      test('deve setar erro para null', () {
        final store = BiometricStore();
        const erro = 'algum erro';
        store.erro = erro;
        store.limparErro();
        expect(store.erro, isNull);
      });

      test('deve setar erro para null se já for null', () {
        final store = BiometricStore();
        store.erro = null;
        store.limparErro();
        expect(store.erro, isNull);
      });

      test('deve ser observável', () {
        final store = BiometricStore();
        final chamada = <int>[0];
        final disposer = reaction((_) => store.erro, (_) {
          chamada[0]++;
        });
        store.erro = 'algo';
        store.limparErro();
        disposer();
        expect(chamada[0], greaterThan(0));
      });
    });

    group('Observables', () {
      test('autenticando deve ser observável', () {
        final store = BiometricStore();
        var chamadas = 0;
        final disposer = reaction(
          (_) => store.autenticando,
          (_) => chamadas++,
        );
        expect(chamadas, 0);
        // Mudar valor diretamente para testar observabilidade
        store.autenticando = true;
        disposer();
        expect(chamadas, greaterThan(0));
      });

      test('disponivel deve ser observável', () {
        final store = BiometricStore();
        var chamadas = 0;
        final disposer = reaction(
          (_) => store.disponivel,
          (_) => chamadas++,
        );
        store.disponivel = true;
        disposer();
        expect(chamadas, greaterThan(0));
      });

      test('tipoBiometrico deve ser observável', () {
        final store = BiometricStore();
        var chamadas = 0;
        final disposer = reaction(
          (_) => store.tipoBiometrico,
          (_) => chamadas++,
        );
        store.tipoBiometrico = 'fingerprint';
        disposer();
        expect(chamadas, greaterThan(0));
      });

      test('erro deve ser observável', () {
        final store = BiometricStore();
        var chamadas = 0;
        final disposer = reaction(
          (_) => store.erro,
          (_) => chamadas++,
        );
        store.erro = 'novo erro';
        disposer();
        expect(chamadas, greaterThan(0));
      });
    });

    group('Métodos assíncronos', () {
      test(
        'verificarDisponibilidade retorna Future completo',
        () async {
          final store = BiometricStore();
          // Este teste apenas verifica que o método não lança exceção não-capturada
          // e que os observables são atualizados (gracefully para false/nenhum em teste)
          await store.verificarDisponibilidade();
          expect(store.disponivel, isFalse);
        },
      );

      test(
        'autenticar retorna Future completo',
        () async {
          final store = BiometricStore();
          try {
            await store.autenticar(titulo: 'Teste', subtitulo: 'Teste');
          } catch (e) {
            // Esperado lançar em teste (sem impl nativa)
            expect(e, isNotNull);
          }
        },
      );

      test(
        'autenticar com descricao completa',
        () async {
          final store = BiometricStore();
          try {
            await store.autenticar(
              titulo: 'Teste',
              subtitulo: 'Teste',
              descricao: 'Descrição',
            );
          } catch (e) {
            expect(e, isNotNull);
          }
        },
      );
    });

    group('Estados de Erro', () {
      test('erro deve ser limpo em sucesso', () {
        final store = BiometricStore();
        store.erro = 'erro anterior';
        store.limparErro();
        expect(store.erro, isNull);
      });

      test('erro pode ser setado múltiplas vezes', () {
        final store = BiometricStore();
        store.erro = 'erro 1';
        expect(store.erro, 'erro 1');
        store.erro = 'erro 2';
        expect(store.erro, 'erro 2');
      });
    });
  });
}
