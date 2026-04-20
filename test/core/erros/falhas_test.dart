import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/core/erros/falhas.dart';

void main() {
  group('FalhaCache', () {
    test('duas instâncias com mesma mensagem são iguais (Equatable)', () {
      // Arrange
      const falha1 = FalhaCache('erro de cache');
      const falha2 = FalhaCache('erro de cache');

      // Act & Assert
      expect(falha1, equals(falha2));
    });

    test('instâncias com mensagens diferentes não são iguais', () {
      // Arrange
      const falha1 = FalhaCache('erro A');
      const falha2 = FalhaCache('erro B');

      // Act & Assert
      expect(falha1, isNot(equals(falha2)));
    });

    test('expõe a mensagem corretamente', () {
      // Arrange
      const falha = FalhaCache('falha ao ler dados locais');

      // Assert
      expect(falha.mensagem, 'falha ao ler dados locais');
    });
  });

  group('FalhaServidor', () {
    test('duas instâncias com mesma mensagem são iguais (Equatable)', () {
      // Arrange
      const falha1 = FalhaServidor('erro de servidor');
      const falha2 = FalhaServidor('erro de servidor');

      // Act & Assert
      expect(falha1, equals(falha2));
    });

    test('FalhaCache e FalhaServidor com mesma mensagem não são iguais', () {
      // Arrange
      const falhaCache = FalhaCache('mensagem');
      const falhaServidor = FalhaServidor('mensagem');

      // Act & Assert
      expect(falhaCache, isNot(equals(falhaServidor)));
    });

    test('FalhaCache é subclasse de Falha', () {
      // Arrange
      const falha = FalhaCache('x');

      // Assert
      expect(falha, isA<Falha>());
    });

    test('FalhaServidor é subclasse de Falha', () {
      // Arrange
      const falha = FalhaServidor('x');

      // Assert
      expect(falha, isA<Falha>());
    });
  });
}
