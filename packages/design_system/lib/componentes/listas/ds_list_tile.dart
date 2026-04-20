import 'package:flutter/material.dart';

import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/sombras.dart';
import '../../tokens/tipografia.dart';

class DsListTile extends StatelessWidget {
  const DsListTile({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.leading,
    this.trailing,
    this.aoTocar,
    this.selecionado = false,
    this.habilitado = true,
  });

  final String titulo;
  final String? subtitulo;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? aoTocar;
  final bool selecionado;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: habilitado ? aoTocar : null,
      borderRadius: const BorderRadius.all(
        Radius.circular(DsEspacamentos.radiusSm),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: selecionado ? DsCores.cinza100 : DsCores.branco,
          borderRadius: const BorderRadius.all(
            Radius.circular(DsEspacamentos.radiusSm),
          ),
          boxShadow: selecionado ? DsSombras.nivel1 : null,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DsEspacamentos.md,
          vertical: DsEspacamentos.sm,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: DsEspacamentos.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: DsTipografia.bodyLarge.copyWith(
                      color: habilitado ? DsCores.cinza900 : DsCores.cinza300,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitulo != null) ...[
                    const SizedBox(height: DsEspacamentos.xxs),
                    Text(
                      subtitulo!,
                      style: DsTipografia.bodySmall.copyWith(
                        color: habilitado ? DsCores.cinza500 : DsCores.cinza300,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: DsEspacamentos.md),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
