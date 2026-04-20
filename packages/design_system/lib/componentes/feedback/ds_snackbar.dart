import 'package:flutter/material.dart';

import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/tipografia.dart';

abstract final class DsSnackbar {
  static void sucesso(
    BuildContext context, {
    required String mensagem,
    Duration duracao = const Duration(seconds: 3),
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
    Duration duracao = const Duration(seconds: 4),
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
    Duration duracao = const Duration(seconds: 3),
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
              Icon(icone, color: DsCores.branco, size: 20),
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
