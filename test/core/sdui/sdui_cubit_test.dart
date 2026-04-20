import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/core/sdui/cubit/sdui_cubit.dart';
import 'package:meu_airbnb/core/sdui/cubit/sdui_state.dart';
import 'package:meu_airbnb/core/sdui/models/sdui_node.dart';

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

  group('SduiState', () {
    test('SduiInitial é igual a outra SduiInitial', () {
      expect(const SduiInitial(), equals(const SduiInitial()));
    });

    test('SduiLoading é igual a outra SduiLoading', () {
      expect(const SduiLoading(), equals(const SduiLoading()));
    });

    test('SduiSuccess com mesma arvore são iguais', () {
      const arvore = [SduiNode(tipo: 'botao_primario')];
      expect(const SduiSuccess(arvore), equals(const SduiSuccess(arvore)));
    });

    test('SduiError com mesma mensagem são iguais', () {
      expect(const SduiError('Failure'), equals(const SduiError('Failure')));
    });

    test('SduiError com mensagens diferentes não são iguais', () {
      expect(const SduiError('a'), isNot(equals(const SduiError('b'))));
    });
  });

  group('SduiCubit', () {
    test('estado inicial é SduiInitial', () {
      expect(SduiCubit().state, isA<SduiInitial>());
    });

    test('arvoreAtual retorna null quando estado é SduiInitial', () {
      expect(SduiCubit().arvoreAtual, isNull);
    });

    blocTest<SduiCubit, SduiState>(
      'carregarTela emite [SduiLoading, SduiSuccess] com JSON válido',
      setUp: () => _registrarAsset('assets/mock/tela_teste.json', _jsonValido),
      build: () => SduiCubit(),
      act: (cubit) =>
          cubit.carregarTela(caminhoAsset: 'assets/mock/tela_teste.json'),
      expect: () => [const SduiLoading(), isA<SduiSuccess>()],
    );

    blocTest<SduiCubit, SduiState>(
      'SduiSuccess contém a arvore parseada corretamente',
      setUp: () => _registrarAsset('assets/mock/tela_teste.json', _jsonValido),
      build: () => SduiCubit(),
      act: (cubit) =>
          cubit.carregarTela(caminhoAsset: 'assets/mock/tela_teste.json'),
      verify: (cubit) {
        final estado = cubit.state as SduiSuccess;
        expect(estado.arvore.length, 2);
        expect(estado.arvore[0].tipo, 'botao_primario');
        expect(estado.arvore[1].tipo, 'estado_vazio');
      },
    );

    blocTest<SduiCubit, SduiState>(
      'arvoreAtual retorna a lista após SduiSuccess',
      setUp: () => _registrarAsset('assets/mock/tela_teste.json', _jsonValido),
      build: () => SduiCubit(),
      act: (cubit) =>
          cubit.carregarTela(caminhoAsset: 'assets/mock/tela_teste.json'),
      verify: (cubit) {
        expect(cubit.arvoreAtual, isNotNull);
        expect(cubit.arvoreAtual!.length, 2);
      },
    );

    blocTest<SduiCubit, SduiState>(
      'carregarTela emite [SduiLoading, SduiError] com JSON inválido',
      setUp: () =>
          _registrarAsset('assets/mock/tela_invalida.json', _jsonInvalido),
      build: () => SduiCubit(),
      act: (cubit) =>
          cubit.carregarTela(caminhoAsset: 'assets/mock/tela_invalida.json'),
      expect: () => [const SduiLoading(), isA<SduiError>()],
    );

    blocTest<SduiCubit, SduiState>(
      'SduiError contém mensagem sobre JSON inválido',
      setUp: () =>
          _registrarAsset('assets/mock/tela_invalida.json', _jsonInvalido),
      build: () => SduiCubit(),
      act: (cubit) =>
          cubit.carregarTela(caminhoAsset: 'assets/mock/tela_invalida.json'),
      verify: (cubit) {
        final estado = cubit.state as SduiError;
        expect(estado.mensagem, contains('JSON inválido'));
      },
    );

    blocTest<SduiCubit, SduiState>(
      'carregarTela pode ser chamado múltiplas vezes',
      setUp: () => _registrarAsset('assets/mock/tela_teste.json', _jsonValido),
      build: () => SduiCubit(),
      act: (cubit) async {
        await cubit.carregarTela(caminhoAsset: 'assets/mock/tela_teste.json');
        await cubit.carregarTela(caminhoAsset: 'assets/mock/tela_teste.json');
      },
      expect: () => [
        const SduiLoading(),
        isA<SduiSuccess>(),
        const SduiLoading(),
        isA<SduiSuccess>(),
      ],
    );
  });
}
