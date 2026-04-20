import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/core/sdui/cubit/sdui_cubit.dart';
import 'package:meu_airbnb/core/sdui/cubit/sdui_estado.dart';
import 'package:meu_airbnb/core/sdui/modelos/no_sdui.dart';

/// JSON SDUI mínimo válido, usado como asset fictício nos testes.
const _jsonValido = '''
{
  "tela": "teste",
  "componentes": [
    {
      "tipo": "botao_primario",
      "propriedades": { "rotulo": "OK" }
    },
    {
      "tipo": "estado_vazio",
      "propriedades": { "mensagem": "Sem dados" }
    }
  ]
}
''';

const _jsonInvalido = 'isso nao e json';

/// Registra um asset fictício no rootBundle para uso em testes.
void _registrarAsset(String caminho, String conteudo) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        if (key == caminho) {
          return ByteData.sublistView(
            Uint8List.fromList(utf8.encode(conteudo)),
          );
        }
        return null;
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SduiEstado', () {
    test('SduiInicial é igual a outra SduiInicial', () {
      expect(const SduiInicial(), equals(const SduiInicial()));
    });

    test('SduiCarregando é igual a outra SduiCarregando', () {
      expect(const SduiCarregando(), equals(const SduiCarregando()));
    });

    test('SduiSucesso com mesma arvore são iguais', () {
      const arvore = [NoSdui(tipo: 'botao_primario')];
      expect(const SduiSucesso(arvore), equals(const SduiSucesso(arvore)));
    });

    test('SduiErro com mesma mensagem são iguais', () {
      expect(const SduiErro('falha'), equals(const SduiErro('falha')));
    });

    test('SduiErro com mensagens diferentes não são iguais', () {
      expect(const SduiErro('a'), isNot(equals(const SduiErro('b'))));
    });
  });

  group('SduiCubit', () {
    test('estado inicial é SduiInicial', () {
      expect(SduiCubit().state, isA<SduiInicial>());
    });

    test('arvoreAtual retorna null quando estado é SduiInicial', () {
      expect(SduiCubit().arvoreAtual, isNull);
    });

    blocTest<SduiCubit, SduiEstado>(
      'carregarTela emite [SduiCarregando, SduiSucesso] com JSON válido',
      setUp: () => _registrarAsset('assets/mock/tela_teste.json', _jsonValido),
      build: () => SduiCubit(),
      act: (cubit) =>
          cubit.carregarTela(caminhoAsset: 'assets/mock/tela_teste.json'),
      expect: () => [const SduiCarregando(), isA<SduiSucesso>()],
    );

    blocTest<SduiCubit, SduiEstado>(
      'SduiSucesso contém a arvore parseada corretamente',
      setUp: () => _registrarAsset('assets/mock/tela_teste.json', _jsonValido),
      build: () => SduiCubit(),
      act: (cubit) =>
          cubit.carregarTela(caminhoAsset: 'assets/mock/tela_teste.json'),
      verify: (cubit) {
        final estado = cubit.state as SduiSucesso;
        expect(estado.arvore.length, 2);
        expect(estado.arvore[0].tipo, 'botao_primario');
        expect(estado.arvore[1].tipo, 'estado_vazio');
      },
    );

    blocTest<SduiCubit, SduiEstado>(
      'arvoreAtual retorna a lista após SduiSucesso',
      setUp: () => _registrarAsset('assets/mock/tela_teste.json', _jsonValido),
      build: () => SduiCubit(),
      act: (cubit) =>
          cubit.carregarTela(caminhoAsset: 'assets/mock/tela_teste.json'),
      verify: (cubit) {
        expect(cubit.arvoreAtual, isNotNull);
        expect(cubit.arvoreAtual!.length, 2);
      },
    );

    blocTest<SduiCubit, SduiEstado>(
      'carregarTela emite [SduiCarregando, SduiErro] com JSON inválido',
      setUp: () =>
          _registrarAsset('assets/mock/tela_invalida.json', _jsonInvalido),
      build: () => SduiCubit(),
      act: (cubit) =>
          cubit.carregarTela(caminhoAsset: 'assets/mock/tela_invalida.json'),
      expect: () => [const SduiCarregando(), isA<SduiErro>()],
    );

    blocTest<SduiCubit, SduiEstado>(
      'SduiErro contém mensagem sobre JSON inválido',
      setUp: () =>
          _registrarAsset('assets/mock/tela_invalida.json', _jsonInvalido),
      build: () => SduiCubit(),
      act: (cubit) =>
          cubit.carregarTela(caminhoAsset: 'assets/mock/tela_invalida.json'),
      verify: (cubit) {
        final estado = cubit.state as SduiErro;
        expect(estado.mensagem, contains('JSON inválido'));
      },
    );

    blocTest<SduiCubit, SduiEstado>(
      'carregarTela pode ser chamado múltiplas vezes',
      setUp: () => _registrarAsset('assets/mock/tela_teste.json', _jsonValido),
      build: () => SduiCubit(),
      act: (cubit) async {
        await cubit.carregarTela(caminhoAsset: 'assets/mock/tela_teste.json');
        await cubit.carregarTela(caminhoAsset: 'assets/mock/tela_teste.json');
      },
      expect: () => [
        const SduiCarregando(),
        isA<SduiSucesso>(),
        const SduiCarregando(),
        isA<SduiSucesso>(),
      ],
    );
  });
}
