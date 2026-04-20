// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hospedagem_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HospedagemModel _$HospedagemModelFromJson(Map<String, dynamic> json) =>
    HospedagemModel(
      id: json['id'] as String,
      nomeHospede: json['nomeHospede'] as String,
      telefone: json['telefone'] as String?,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      numHospedes: (json['numHospedes'] as num).toInt(),
      valorTotal: (json['valorTotal'] as num).toDouble(),
      status: _statusFromJson(json['status'] as String),
      plataforma: _plataformaFromJson(json['plataforma'] as String),
      imovelId: json['imovelId'] as String,
      notas: json['notas'] as String?,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
    );

Map<String, dynamic> _$HospedagemModelToJson(HospedagemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nomeHospede': instance.nomeHospede,
      'telefone': instance.telefone,
      'checkIn': instance.checkIn.toIso8601String(),
      'checkOut': instance.checkOut.toIso8601String(),
      'numHospedes': instance.numHospedes,
      'valorTotal': instance.valorTotal,
      'status': _statusToJson(instance.status),
      'plataforma': _plataformaToJson(instance.plataforma),
      'imovelId': instance.imovelId,
      'notas': instance.notas,
      'criadoEm': instance.criadoEm.toIso8601String(),
    };
