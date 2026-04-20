import 'package:json_annotation/json_annotation.dart';

import '../../dominio/entidades/enums.dart';
import '../../dominio/entidades/hospedagem_entidade.dart';

part 'hospedagem_modelo.g.dart';

/// Modelo de dados para [HospedagemEntidade].
///
/// Responsável pela serialização/deserialização JSON e pela conversão
/// de/para a entidade de domínio.
@JsonSerializable(explicitToJson: true)
class HospedagemModelo {
  const HospedagemModelo({
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

  factory HospedagemModelo.fromJson(Map<String, dynamic> json) =>
      _$HospedagemModeloFromJson(json);

  Map<String, dynamic> toJson() => _$HospedagemModeloToJson(this);

  factory HospedagemModelo.fromEntity(HospedagemEntidade entidade) {
    return HospedagemModelo(
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

  HospedagemEntidade toEntity() {
    return HospedagemEntidade(
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
