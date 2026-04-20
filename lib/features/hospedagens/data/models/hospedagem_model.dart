import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/hospedagem_entity.dart';

part 'hospedagem_model.g.dart';

/// Modelo de dados para [HospedagemEntity].
///
/// Responsável pela serialização/deserialização JSON e pela conversão
/// de/para a entidade de domínio.
@JsonSerializable(explicitToJson: true)
class HospedagemModel {
  const HospedagemModel({
    required this.id,
    required this.nomeHospede,
    this.telefone,
    required this.checkIn,
    required this.checkOut,
    required this.numHospedes,
    required this.valorTotal,
    required this.status,
    required this.plataforma,
    required this.imovelId,
    this.notas,
    required this.criadoEm,
  });

  final String id;
  final String nomeHospede;
  final String? telefone;
  final DateTime checkIn;
  final DateTime checkOut;
  final int numHospedes;
  final double valorTotal;
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  final StatusHospedagem status;
  @JsonKey(fromJson: _plataformaFromJson, toJson: _plataformaToJson)
  final Plataforma plataforma;
  final String imovelId;
  final String? notas;
  final DateTime criadoEm;

  factory HospedagemModel.fromJson(Map<String, dynamic> json) =>
      _$HospedagemModelFromJson(json);

  Map<String, dynamic> toJson() => _$HospedagemModelToJson(this);

  factory HospedagemModel.fromEntity(HospedagemEntity entidade) {
    return HospedagemModel(
      id: entidade.id,
      nomeHospede: entidade.nomeHospede,
      telefone: entidade.telefone,
      checkIn: entidade.checkIn,
      checkOut: entidade.checkOut,
      numHospedes: entidade.numHospedes,
      valorTotal: entidade.valorTotal,
      status: entidade.status,
      plataforma: entidade.plataforma,
      imovelId: entidade.imovelId,
      notas: entidade.notas,
      criadoEm: entidade.criadoEm,
    );
  }

  HospedagemEntity toEntity() {
    return HospedagemEntity(
      id: id,
      nomeHospede: nomeHospede,
      telefone: telefone,
      checkIn: checkIn,
      checkOut: checkOut,
      numHospedes: numHospedes,
      valorTotal: valorTotal,
      status: status,
      plataforma: plataforma,
      imovelId: imovelId,
      notas: notas,
      criadoEm: criadoEm,
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers de enum para json_serializable
// ---------------------------------------------------------------------------

StatusHospedagem _statusFromJson(String valor) =>
    StatusHospedagem.values.byName(valor);

String _statusToJson(StatusHospedagem status) => status.name;

Plataforma _plataformaFromJson(String valor) => Plataforma.values.byName(valor);

String _plataformaToJson(Plataforma plataforma) => plataforma.name;
