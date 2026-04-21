import 'package:flutter_test/flutter_test.dart';
import 'package:meu_airbnb/features/hospedagens/data/models/hospedagem_model.dart';
import 'package:meu_airbnb/features/hospedagens/data/models/imovel_model.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/enums.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/imovel_entity.dart';

final _checkIn = DateTime(2024, 1, 10, 14);
final _checkOut = DateTime(2024, 1, 15, 11);
final _criadoEm = DateTime(2024, 1, 1);

Map<String, dynamic> _hospedagemJson() => {
  'id': 'id-1',
  'nomeHospede': 'João Silva',
  'telefone': '+55 11 99999-0000',
  'checkIn': _checkIn.toIso8601String(),
  'checkOut': _checkOut.toIso8601String(),
  'numHospedes': 2,
  'valorTotal': 500.0,
  'status': 'confirmada',
  'plataforma': 'airbnb',
  'imovelId': 'imovel-1',
  'notas': 'Hóspede VIP',
  'criadoEm': _criadoEm.toIso8601String(),
};

HospedagemEntity _entidadeFixture() => HospedagemEntity(
  id: 'id-1',
  nomeHospede: 'João Silva',
  telefone: '+55 11 99999-0000',
  checkIn: _checkIn,
  checkOut: _checkOut,
  numHospedes: 2,
  valorTotal: 500.0,
  status: StatusHospedagem.confirmada,
  plataforma: Plataforma.airbnb,
  imovelId: 'imovel-1',
  notas: 'Hóspede VIP',
  criadoEm: _criadoEm,
);

void main() {
  group('HospedagemModel', () {
    group('fromJson', () {
      test('converte todos os campos corretamente', () {
        // Arrange
        final json = _hospedagemJson();

        // Act
        final modelo = HospedagemModel.fromJson(json);

        // Assert
        expect(modelo.id, 'id-1');
        expect(modelo.nomeHospede, 'João Silva');
        expect(modelo.telefone, '+55 11 99999-0000');
        expect(modelo.checkIn, _checkIn);
        expect(modelo.checkOut, _checkOut);
        expect(modelo.numHospedes, 2);
        expect(modelo.valorTotal, 500.0);
        expect(modelo.status, StatusHospedagem.confirmada);
        expect(modelo.plataforma, Plataforma.airbnb);
        expect(modelo.imovelId, 'imovel-1');
        expect(modelo.notas, 'Hóspede VIP');
        expect(modelo.criadoEm, _criadoEm);
      });

      test('campos opcionais nulos são parseados como null', () {
        // Arrange
        final json = _hospedagemJson()
          ..['telefone'] = null
          ..['notas'] = null;

        // Act
        final modelo = HospedagemModel.fromJson(json);

        // Assert
        expect(modelo.telefone, isNull);
        expect(modelo.notas, isNull);
      });

      test('status "pendente" é convertido corretamente', () {
        // Arrange
        final json = _hospedagemJson()..['status'] = 'pendente';

        // Act
        final modelo = HospedagemModel.fromJson(json);

        // Assert
        expect(modelo.status, StatusHospedagem.pendente);
      });

      test('plataforma "booking" é convertida corretamente', () {
        // Arrange
        final json = _hospedagemJson()..['plataforma'] = 'booking';

        // Act
        final modelo = HospedagemModel.fromJson(json);

        // Assert
        expect(modelo.plataforma, Plataforma.booking);
      });
    });

    group('toJson', () {
      test('serializa todos os campos corretamente', () {
        // Arrange
        final modelo = HospedagemModel.fromJson(_hospedagemJson());

        // Act
        final json = modelo.toJson();

        // Assert
        expect(json['id'], 'id-1');
        expect(json['nomeHospede'], 'João Silva');
        expect(json['status'], 'confirmada');
        expect(json['plataforma'], 'airbnb');
      });

      test('toJson → fromJson preserva os dados (round-trip)', () {
        // Arrange
        final original = HospedagemModel.fromJson(_hospedagemJson());

        // Act
        final json = original.toJson();
        final restaurado = HospedagemModel.fromJson(json);

        // Assert
        expect(restaurado.id, original.id);
        expect(restaurado.status, original.status);
        expect(restaurado.checkIn, original.checkIn);
        expect(restaurado.valorTotal, original.valorTotal);
      });
    });

    group('fromEntity / toEntity', () {
      test('fromEntity converte entidade para modelo corretamente', () {
        // Arrange
        final entidade = _entidadeFixture();

        // Act
        final modelo = HospedagemModel.fromEntity(entidade);

        // Assert
        expect(modelo.id, entidade.id);
        expect(modelo.nomeHospede, entidade.nomeHospede);
        expect(modelo.status, entidade.status);
        expect(modelo.valorTotal, entidade.valorTotal);
      });

      test('toEntity converte modelo para entidade corretamente', () {
        // Arrange
        final modelo = HospedagemModel.fromJson(_hospedagemJson());

        // Act
        final entidade = modelo.toEntity();

        // Assert
        expect(entidade.id, modelo.id);
        expect(entidade.nomeHospede, modelo.nomeHospede);
        expect(entidade.status, modelo.status);
        expect(entidade.checkIn, modelo.checkIn);
      });

      test('fromEntity → toEntity preserva todos os campos', () {
        // Arrange
        final original = _entidadeFixture();

        // Act
        final modelo = HospedagemModel.fromEntity(original);
        final restaurada = modelo.toEntity();

        // Assert
        expect(restaurada, equals(original));
      });
    });
  });

  group('ImovelModel', () {
    const imovelJson = {
      'id': 'i-1',
      'nome': 'Apto Centro SP',
      'endereco': 'Rua Augusta, 1500',
    };

    test('fromJson converte corretamente', () {
      // Act
      final modelo = ImovelModel.fromJson(imovelJson);

      // Assert
      expect(modelo.id, 'i-1');
      expect(modelo.nome, 'Apto Centro SP');
      expect(modelo.endereco, 'Rua Augusta, 1500');
    });

    test('fromJson com endereço null', () {
      // Arrange
      const json = {'id': 'i-2', 'nome': 'Studio', 'endereco': null};

      // Act
      final modelo = ImovelModel.fromJson(json);

      // Assert
      expect(modelo.endereco, isNull);
    });

    test('toJson serializa corretamente', () {
      // Arrange
      final modelo = ImovelModel.fromJson(imovelJson);

      // Act
      final json = modelo.toJson();

      // Assert
      expect(json['id'], 'i-1');
      expect(json['nome'], 'Apto Centro SP');
    });

    test('fromEntity → toEntity preserva todos os campos', () {
      // Arrange
      const entidade = ImovelEntity(
        id: 'i-1',
        nome: 'Apto Centro SP',
        endereco: 'Rua Augusta, 1500',
      );

      // Act
      final modelo = ImovelModel.fromEntity(entidade);
      final restaurada = modelo.toEntity();

      // Assert
      expect(restaurada, equals(entidade));
    });
  });
}
