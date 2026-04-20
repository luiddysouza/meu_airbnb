import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/core/sdui/modelos/acao_sdui.dart';
import 'package:meu_airbnb/core/sdui/modelos/no_sdui.dart';
import 'package:meu_airbnb/core/sdui/parser/sdui_parser.dart';

void main() {
  group('SduiParser', () {
    const jsonValido = '''
    {
      "tela": "hospedagens",
      "componentes": [
        {
          "tipo": "seletor_data_range",
          "propriedades": {
            "rotulo_inicio": "Check-in",
            "rotulo_fim": "Check-out"
          },
          "acao": {
            "tipo": "filtrar_por_data",
            "payload": {}
          }
        },
        {
          "tipo": "dropdown",
          "propriedades": {
            "rotulo": "Imóvel",
            "opcoes_source": "imoveis"
          },
          "acao": {
            "tipo": "filtrar_por_imovel",
            "payload": {}
          }
        },
        {
          "tipo": "lista",
          "propriedades": {
            "dados_source": "hospedagens_filtradas"
          }
        }
      ]
    }
    ''';

    test('parseia o número correto de componentes', () {
      // Arrange + Act
      final resultado = SduiParser.parsear(jsonValido);

      // Assert
      expect(resultado.length, 3);
    });

    test('parseia o tipo de cada nó corretamente', () {
      // Arrange + Act
      final resultado = SduiParser.parsear(jsonValido);

      // Assert
      expect(resultado[0].tipo, 'seletor_data_range');
      expect(resultado[1].tipo, 'dropdown');
      expect(resultado[2].tipo, 'lista');
    });

    test('parseia propriedades do nó corretamente', () {
      // Arrange + Act
      final resultado = SduiParser.parsear(jsonValido);

      // Assert
      expect(resultado[0].propriedades['rotulo_inicio'], 'Check-in');
      expect(resultado[0].propriedades['rotulo_fim'], 'Check-out');
      expect(resultado[1].propriedades['rotulo'], 'Imóvel');
    });

    test('parseia acao do nó corretamente', () {
      // Arrange + Act
      final resultado = SduiParser.parsear(jsonValido);

      // Assert
      expect(resultado[0].acao, isA<AcaoSdui>());
      expect(resultado[0].acao!.tipo, 'filtrar_por_data');
      expect(resultado[1].acao!.tipo, 'filtrar_por_imovel');
      expect(resultado[2].acao, isNull);
    });

    test('parseia filhos recursivamente', () {
      // Arrange
      const jsonComFilhos = '''
      {
        "componentes": [
          {
            "tipo": "coluna",
            "propriedades": {},
            "filhos": [
              {
                "tipo": "botao_primario",
                "propriedades": { "rotulo": "Salvar" }
              }
            ]
          }
        ]
      }
      ''';

      // Act
      final resultado = SduiParser.parsear(jsonComFilhos);

      // Assert
      expect(resultado[0].filhos.length, 1);
      expect(resultado[0].filhos[0].tipo, 'botao_primario');
      expect(resultado[0].filhos[0].propriedades['rotulo'], 'Salvar');
    });

    test('retorna lista vazia quando componentes está ausente', () {
      // Arrange
      const jsonSemComponentes = '{ "tela": "vazia" }';

      // Act
      final resultado = SduiParser.parsear(jsonSemComponentes);

      // Assert
      expect(resultado, isEmpty);
    });

    test('retorna lista vazia quando componentes é um array vazio', () {
      // Arrange
      const jsonArrayVazio = '{ "componentes": [] }';

      // Act
      final resultado = SduiParser.parsear(jsonArrayVazio);

      // Assert
      expect(resultado, isEmpty);
    });

    test('nó sem propriedades usa mapa vazio', () {
      // Arrange
      const json = '''
      {
        "componentes": [
          { "tipo": "carregando" }
        ]
      }
      ''';

      // Act
      final resultado = SduiParser.parsear(json);

      // Assert
      expect(resultado[0].propriedades, isEmpty);
      expect(resultado[0].filhos, isEmpty);
      expect(resultado[0].acao, isNull);
    });

    test('lança FormatException para JSON inválido', () {
      // Arrange
      const jsonInvalido = 'isso nao e um json';

      // Act + Assert
      expect(
        () => SduiParser.parsear(jsonInvalido),
        throwsA(isA<FormatException>()),
      );
    });

    test('NoSdui com mesmos valores são iguais (Equatable)', () {
      // Arrange
      const no1 = NoSdui(
        tipo: 'botao_primario',
        propriedades: {'rotulo': 'OK'},
      );
      const no2 = NoSdui(
        tipo: 'botao_primario',
        propriedades: {'rotulo': 'OK'},
      );

      // Assert
      expect(no1, equals(no2));
    });

    test('AcaoSdui com mesmos valores são iguais (Equatable)', () {
      // Arrange
      const acao1 = AcaoSdui(tipo: 'navegar', payload: {'rota': '/home'});
      const acao2 = AcaoSdui(tipo: 'navegar', payload: {'rota': '/home'});

      // Assert
      expect(acao1, equals(acao2));
    });
  });
}
