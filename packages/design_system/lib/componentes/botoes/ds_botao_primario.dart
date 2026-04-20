import 'package:flutter/material.dart';

import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/tipografia.dart';

class DsBotaoPrimario extends StatelessWidget {
  const DsBotaoPrimario({
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
    return ElevatedButton(
      onPressed: carregando ? null : aoTocar,
      style: ElevatedButton.styleFrom(
        backgroundColor: DsCores.primaria,
        foregroundColor: DsCores.branco,
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
        minimumSize: const Size(double.infinity, 48),
      ),
      child: _buildFilho(),
    );
  }

  Widget _buildFilho() {
    if (carregando) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(DsCores.branco),
        ),
      );
    }
    if (icone != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 18),
          const SizedBox(width: DsEspacamentos.xs),
          Text(rotulo),
        ],
      );
    }
    return Text(rotulo);
  }
}
