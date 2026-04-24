import 'package:flutter_test/flutter_test.dart';

import 'package:meu_airbnb/core/platform/galeria_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GaleriaChannel', () {
    test('deve ter method selecionarImagem', () {
      expect(GaleriaChannel.selecionarImagem, isNotNull);
    });

    test('deve ter method isGaleriaDisponivel', () {
      expect(GaleriaChannel.isGaleriaDisponivel, isNotNull);
    });

    test('selecionarImagem deve ser uma Function', () {
      expect(GaleriaChannel.selecionarImagem, isA<Function>());
    });

    test('isGaleriaDisponivel deve ser uma Function', () {
      expect(GaleriaChannel.isGaleriaDisponivel, isA<Function>());
    });

    test('ambas funções devem existir e ser callable', () {
      expect(GaleriaChannel.selecionarImagem, isNotNull);
      expect(GaleriaChannel.isGaleriaDisponivel, isNotNull);
      expect([
        GaleriaChannel.selecionarImagem,
        GaleriaChannel.isGaleriaDisponivel,
      ], everyElement(isA<Function>()));
    });
  });
}
