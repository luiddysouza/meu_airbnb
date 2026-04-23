import 'package:flutter/material.dart';

import '../../tokens/animacoes.dart';
import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/icones.dart';
import '../../tokens/tipografia.dart';

abstract final class DsSnackbar {
  static void sucesso(
    BuildContext context, {
    required String mensagem,
    Duration duracao = DsAnimacoes.snackbarCurta,
  }) {
    _mostrar(
      context,
      mensagem: mensagem,
      cor: DsCores.sucesso,
      icone: Icons.check_circle_outline,
      duracao: duracao,
    );
  }

  static void erro(
    BuildContext context, {
    required String mensagem,
    Duration duracao = DsAnimacoes.snackbarLonga,
  }) {
    _mostrar(
      context,
      mensagem: mensagem,
      cor: DsCores.erro,
      icone: Icons.error_outline,
      duracao: duracao,
    );
  }

  static void info(
    BuildContext context, {
    required String mensagem,
    Duration duracao = DsAnimacoes.snackbarCurta,
  }) {
    _mostrar(
      context,
      mensagem: mensagem,
      cor: DsCores.info,
      icone: Icons.info_outline,
      duracao: duracao,
    );
  }

  static void _mostrar(
    BuildContext context, {
    required String mensagem,
    required Color cor,
    required IconData icone,
    required Duration duracao,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duracao,
          backgroundColor: cor,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(DsEspacamentos.radiusSm),
            ),
          ),
          content: Row(
            children: [
              Icon(icone, color: DsCores.branco, size: DsIcones.lg),
              const SizedBox(width: DsEspacamentos.sm),
              Expanded(
                child: Text(
                  mensagem,
                  style: DsTipografia.bodyMedium.copyWith(
                    color: DsCores.branco,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
