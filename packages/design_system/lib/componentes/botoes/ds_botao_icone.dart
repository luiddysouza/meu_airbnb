import 'package:flutter/material.dart';

import '../../tokens/bordas.dart';
import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';

class DsBotaoIcone extends StatelessWidget {
  const DsBotaoIcone({
    super.key,
    required this.icone,
    this.aoTocar,
    this.carregando = false,
    this.tooltip,
    this.cor,
  });

  final IconData icone;
  final VoidCallback? aoTocar;
  final bool carregando;
  final String? tooltip;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final corEfetiva = cor ?? DsCores.primaria;

    final botao = IconButton(
      onPressed: carregando ? null : aoTocar,
      icon: carregando
          ? SizedBox.square(
              dimension: DsAlturas.spinnerBotao,
              child: CircularProgressIndicator(
                strokeWidth: DsBordas.progressIndicator,
                valueColor: AlwaysStoppedAnimation<Color>(corEfetiva),
              ),
            )
          : Icon(icone, color: corEfetiva),
      padding: const EdgeInsets.all(DsEspacamentos.xs),
      style: IconButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(DsEspacamentos.radiusSm),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: botao);
    }
    return botao;
  }
}
