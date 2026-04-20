import 'package:flutter/material.dart';
import '../tokens/cores.dart';
import '../tokens/tipografia.dart';
import 'tema_extensoes.dart';

abstract final class DsTemaApp {
  static ThemeData get tema => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: DsCores.primaria,
      primary: DsCores.primaria,
      secondary: DsCores.secundaria,
      error: DsCores.erro,
      surface: DsCores.branco,
      onPrimary: DsCores.branco,
      onSecondary: DsCores.branco,
      onError: DsCores.branco,
      onSurface: DsCores.cinza900,
    ),
    textTheme: TextTheme(
      displayLarge: DsTipografia.displayLarge,
      displayMedium: DsTipografia.displayMedium,
      displaySmall: DsTipografia.displaySmall,
      headlineLarge: DsTipografia.headlineLarge,
      headlineMedium: DsTipografia.headlineMedium,
      headlineSmall: DsTipografia.headlineSmall,
      titleLarge: DsTipografia.titleLarge,
      titleMedium: DsTipografia.titleMedium,
      titleSmall: DsTipografia.titleSmall,
      bodyLarge: DsTipografia.bodyLarge,
      bodyMedium: DsTipografia.bodyMedium,
      bodySmall: DsTipografia.bodySmall,
      labelLarge: DsTipografia.labelLarge,
      labelMedium: DsTipografia.labelMedium,
      labelSmall: DsTipografia.labelSmall,
    ),
    extensions: const [DsTemaExtensao()],
  );
}
