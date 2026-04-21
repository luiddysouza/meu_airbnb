import 'package:flutter/material.dart';

import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/tipografia.dart';

/// Dialog de confirmação reutilizável do Design System.
///
/// Exibe um [AlertDialog] com título, mensagem e dois botões: confirmar e
/// cancelar. Retorna `true` se o usuário confirmar, `false` caso contrário.
///
/// Uso:
/// ```dart
/// final confirmado = await DsDialogConfirmacao.mostrar(
///   context,
///   titulo: 'Excluir hospedagem',
///   mensagem: 'Essa ação não pode ser desfeita.',
///   destrutivo: true,
/// );
/// if (confirmado) { ... }
/// ```
abstract final class DsDialogConfirmacao {
  /// Exibe o dialog e retorna `true` se o usuário tocar em confirmar.
  ///
  /// - [titulo]: título do dialog.
  /// - [mensagem]: corpo descritivo.
  /// - [rotuloConfirmar]: texto do botão de confirmação (default: 'Confirmar').
  /// - [rotuloCancelar]: texto do botão de cancelamento (default: 'Cancelar').
  /// - [destrutivo]: se `true`, o botão de confirmação usa [DsCores.erro].
  static Future<bool> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    String rotuloConfirmar = 'Confirmar',
    String rotuloCancelar = 'Cancelar',
    bool destrutivo = false,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(DsEspacamentos.radiusMd),
          ),
        ),
        title: Text(
          titulo,
          style: DsTipografia.titleMedium.copyWith(color: DsCores.cinza900),
        ),
        content: Text(
          mensagem,
          style: DsTipografia.bodyMedium.copyWith(color: DsCores.cinza700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              rotuloCancelar,
              style: DsTipografia.labelLarge.copyWith(color: DsCores.cinza500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: destrutivo ? DsCores.erro : DsCores.primaria,
            ),
            child: Text(rotuloConfirmar, style: DsTipografia.labelLarge),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }
}
