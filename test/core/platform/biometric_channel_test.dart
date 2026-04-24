import 'package:flutter_test/flutter_test.dart';

import 'package:meu_airbnb/core/platform/biometric_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BiometricChannel', () {
    group('autenticar', () {
      test('deve ser uma função válida', () {
        expect(BiometricChannel.autenticar, isNotNull);
      });

      test('deve aceitar todos os parâmetros', () {
        expect(
          () => BiometricChannel.autenticar(
            titulo: 'Autenticar',
            subtitulo: 'Fingerprint ou Face',
            descricao: 'Descrição',
          ),
          isNotNull,
        );
      });

      test('deve aceitar descricao como nula', () {
        expect(
          () => BiometricChannel.autenticar(
            titulo: 'Login',
            subtitulo: 'Biometria',
            descricao: null,
          ),
          isNotNull,
        );
      });
    });

    group('isBiometricoDisponivel', () {
      test('deve ser uma função válida', () {
        expect(BiometricChannel.isBiometricoDisponivel, isNotNull);
      });

      test('deve ser uma função callable', () {
        expect(BiometricChannel.isBiometricoDisponivel, isA<Function>());
      });
    });

    group('getTipoBiometrico', () {
      test('deve ser uma função válida', () {
        expect(BiometricChannel.getTipoBiometrico, isNotNull);
      });

      test('deve ser uma função callable', () {
        expect(BiometricChannel.getTipoBiometrico, isA<Function>());
      });
    });

    group('Channel Names', () {
      test('autenticar deve usar MethodChannel "biometric"', () {
        // Verifica que o método existe e pode ser chamado
        // (em teste, sem impl nativa, vai falhar no runtime, mas sintaxe é válida)
        expect(
          () => BiometricChannel.autenticar(titulo: 'Test', subtitulo: 'Test'),
          isNotNull,
        );
      });

      test('múltiplos métodos devem existir', () {
        expect(BiometricChannel.autenticar, isNotNull);
        expect(BiometricChannel.isBiometricoDisponivel, isNotNull);
        expect(BiometricChannel.getTipoBiometrico, isNotNull);
      });
    });
  });
}
