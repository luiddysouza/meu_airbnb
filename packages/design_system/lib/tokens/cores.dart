import 'package:flutter/material.dart';

abstract final class DsCores {
  // Primária
  static const Color primaria = Color(0xFFFF5A5F);
  static const Color primariaDark = Color(0xFFE0484D);
  static const Color primariaLight = Color(0xFFFF8A8E);

  // Secundária
  static const Color secundaria = Color(0xFF00A699);
  static const Color secundariaDark = Color(0xFF007A70);
  static const Color secundariaLight = Color(0xFF33C5BA);

  // Neutras
  static const Color cinza900 = Color(0xFF1A1A1A);
  static const Color cinza700 = Color(0xFF484848);
  static const Color cinza500 = Color(0xFF767676);
  static const Color cinza300 = Color(0xFFB0B0B0);
  static const Color cinza100 = Color(0xFFF7F7F7);
  static const Color branco = Color(0xFFFFFFFF);

  // Semânticas
  static const Color sucesso = Color(0xFF008A05);
  static const Color erro = Color(0xFFD93025);
  static const Color alerta = Color(0xFFF5A623);
  static const Color info = Color(0xFF0071C2);

  // Status de hospedagem
  static const Color confirmada = Color(0xFF008A05);
  static const Color pendente = Color(0xFFF5A623);
  static const Color cancelada = Color(0xFFD93025);
  static const Color concluida = Color(0xFF767676);
}
