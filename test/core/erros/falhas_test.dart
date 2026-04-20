import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/core/erros/failures.dart';

void main() {
  group('CacheFailure', () {
    test('duas instâncias com mesma mensagem são iguais (Equatable)', () {
      // Arrange
      const f1 = CacheFailure('erro de cache');
      const f2 = CacheFailure('erro de cache');

      // Act & Assert
      expect(f1, equals(f2));
    });

    test('instâncias com mensagens diferentes não são iguais', () {
      // Arrange
      const f1 = CacheFailure('erro A');
      const f2 = CacheFailure('erro B');

      // Act & Assert
      expect(f1, isNot(equals(f2)));
    });

    test('expõe a mensagem corretamente', () {
      // Arrange
      const failure = CacheFailure('Failure ao ler dados locais');

      // Assert
      expect(failure.mensagem, 'Failure ao ler dados locais');
    });
  });

  group('ServerFailure', () {
    test('duas instâncias com mesma mensagem são iguais (Equatable)', () {
      // Arrange
      const f1 = ServerFailure('erro de servidor');
      const f2 = ServerFailure('erro de servidor');

      // Act & Assert
      expect(f1, equals(f2));
    });

    test('CacheFailure e ServerFailure com mesma mensagem não são iguais', () {
      // Arrange
      const cache = CacheFailure('mensagem');
      const server = ServerFailure('mensagem');

      // Act & Assert
      expect(cache, isNot(equals(server)));
    });

    test('CacheFailure é subclasse de Failure', () {
      // Arrange
      const failure = CacheFailure('x');

      // Assert
      expect(failure, isA<Failure>());
    });

    test('ServerFailure é subclasse de Failure', () {
      // Arrange
      const failure = ServerFailure('x');

      // Assert
      expect(failure, isA<Failure>());
    });

    test('mensagens diferentes em ServerFailure não são iguais', () {
      // Arrange
      const f1 = ServerFailure('erro X');
      const f2 = ServerFailure('erro Y');

      // Assert
      expect(f1, isNot(equals(f2)));
    });
  });
}
