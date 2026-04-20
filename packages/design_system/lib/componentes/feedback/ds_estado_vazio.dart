import 'package:flutter/material.dart';

import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/tipografia.dart';

class DsEstadoVazio extends StatelessWidget {
  const DsEstadoVazio({
    super.key,
    required this.mensagem,
    this.icone = Icons.inbox_outlined,
    this.rotuloAcao,
    this.aoAcionar,
  });

  final String mensagem;
  final IconData icone;
  final String? rotuloAcao;
  final VoidCallback? aoAcionar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DsEspacamentos.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 64, color: DsCores.cinza300),
            const SizedBox(height: DsEspacamentos.md),
            Text(
              mensagem,
              style: DsTipografia.bodyLarge.copyWith(color: DsCores.cinza500),
              textAlign: TextAlign.center,
            ),
            if (rotuloAcao != null && aoAcionar != null) ...[
              const SizedBox(height: DsEspacamentos.lg),
              TextButton(
                onPressed: aoAcionar,
                child: Text(
                  rotuloAcao!,
                  style: DsTipografia.labelLarge.copyWith(
                    color: DsCores.primaria,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
