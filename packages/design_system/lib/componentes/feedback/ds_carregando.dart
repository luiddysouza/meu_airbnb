import 'package:flutter/material.dart';

import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/tipografia.dart';

class DsCarregando extends StatelessWidget {
  const DsCarregando({super.key, this.mensagem});

  final String? mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DsEspacamentos.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(DsCores.primaria),
            ),
            if (mensagem != null) ...[
              const SizedBox(height: DsEspacamentos.md),
              Text(
                mensagem!,
                style: DsTipografia.bodyMedium.copyWith(
                  color: DsCores.cinza500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
