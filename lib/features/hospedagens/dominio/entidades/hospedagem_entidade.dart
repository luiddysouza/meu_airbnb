import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Entidade de domínio que representa uma hospedagem.
///
/// Imutável. Use [copyWith] para criar versões modificadas.
class HospedagemEntidade extends Equatable {
  const HospedagemEntidade({
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
  final StatusHospedagem status;
  final Plataforma plataforma;
  final String imovelId;
  final String? notas;
  final DateTime criadoEm;

  HospedagemEntidade copyWith({
    String? id,
    String? nomeHospede,
    String? telefone,
    DateTime? checkIn,
    DateTime? checkOut,
    int? numHospedes,
    double? valorTotal,
    StatusHospedagem? status,
    Plataforma? plataforma,
    String? imovelId,
    String? notas,
    DateTime? criadoEm,
  }) {
    return HospedagemEntidade(
      id: id ?? this.id,
      nomeHospede: nomeHospede ?? this.nomeHospede,
      telefone: telefone ?? this.telefone,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      numHospedes: numHospedes ?? this.numHospedes,
      valorTotal: valorTotal ?? this.valorTotal,
      status: status ?? this.status,
      plataforma: plataforma ?? this.plataforma,
      imovelId: imovelId ?? this.imovelId,
      notas: notas ?? this.notas,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nomeHospede,
    telefone,
    checkIn,
    checkOut,
    numHospedes,
    valorTotal,
    status,
    plataforma,
    imovelId,
    notas,
    criadoEm,
  ];
}
