import 'package:flutter/material.dart';
import '../tokens/cores.dart';

@immutable
class DsTemaExtensao extends ThemeExtension<DsTemaExtensao> {
  final Color corStatusConfirmada;
  final Color corStatusPendente;
  final Color corStatusCancelada;
  final Color corStatusConcluida;

  const DsTemaExtensao({
    this.corStatusConfirmada = DsCores.confirmada,
    this.corStatusPendente = DsCores.pendente,
    this.corStatusCancelada = DsCores.cancelada,
    this.corStatusConcluida = DsCores.concluida,
  });

  @override
  DsTemaExtensao copyWith({
    Color? corStatusConfirmada,
    Color? corStatusPendente,
    Color? corStatusCancelada,
    Color? corStatusConcluida,
  }) => DsTemaExtensao(
    corStatusConfirmada: corStatusConfirmada ?? this.corStatusConfirmada,
    corStatusPendente: corStatusPendente ?? this.corStatusPendente,
    corStatusCancelada: corStatusCancelada ?? this.corStatusCancelada,
    corStatusConcluida: corStatusConcluida ?? this.corStatusConcluida,
  );

  @override
  DsTemaExtensao lerp(DsTemaExtensao? other, double t) {
    if (other == null) return this;
    return DsTemaExtensao(
      corStatusConfirmada: Color.lerp(
        corStatusConfirmada,
        other.corStatusConfirmada,
        t,
      )!,
      corStatusPendente: Color.lerp(
        corStatusPendente,
        other.corStatusPendente,
        t,
      )!,
      corStatusCancelada: Color.lerp(
        corStatusCancelada,
        other.corStatusCancelada,
        t,
      )!,
      corStatusConcluida: Color.lerp(
        corStatusConcluida,
        other.corStatusConcluida,
        t,
      )!,
    );
  }
}
