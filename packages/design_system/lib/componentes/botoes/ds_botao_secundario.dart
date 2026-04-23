import 'package:flutter/material.dart';

import '../../tokens/bordas.dart';
import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/icones.dart';
import '../../tokens/tipografia.dart';

class DsBotaoSecundario extends StatelessWidget {
  const DsBotaoSecundario({
    super.key,
    required this.rotulo,
    this.aoTocar,
    this.carregando = false,
    this.icone,
  });

  final String rotulo;
  final VoidCallback? aoTocar;
  final bool carregando;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: carregando ? null : aoTocar,
      style: OutlinedButton.styleFrom(
        foregroundColor: DsCores.primaria,
        side: const BorderSide(color: DsCores.primaria, width: DsBordas.fina),
        padding: const EdgeInsets.symmetric(
          horizontal: DsEspacamentos.lg,
          vertical: DsEspacamentos.md,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(DsEspacamentos.radiusMd),
          ),
        ),
        textStyle: DsTipografia.labelLarge,
        minimumSize: const Size(double.infinity, DsAlturas.botaoPadrao),
      ),
      child: _buildFilho(),
    );
  }

  Widget _buildFilho() {
    if (carregando) {
      return const SizedBox.square(
        dimension: DsAlturas.spinnerBotao,
        child: CircularProgressIndicator(
          strokeWidth: DsBordas.progressIndicator,
          valueColor: AlwaysStoppedAnimation<Color>(DsCores.primaria),
        ),
      );
    }
    if (icone != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: DsIcones.md),
          const SizedBox(width: DsEspacamentos.xs),
          Text(rotulo),
        ],
      );
    }
    return Text(rotulo);
  }
}
