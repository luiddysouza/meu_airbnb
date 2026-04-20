import 'package:flutter/material.dart';

import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/sombras.dart';
import '../../tokens/tipografia.dart';

/// App bar adaptativa para web e mobile.
///
/// - Mobile (< [DsEspacamentos.breakpointTablet]): exibe [leading] e [acoes]
/// - Desktop (≥ [DsEspacamentos.breakpointTablet]): oculta o [leading] (drawer
///   não se aplica ao layout com sidebar)
class DsAppBarAdaptativa extends StatelessWidget
    implements PreferredSizeWidget {
  const DsAppBarAdaptativa({
    super.key,
    required this.titulo,
    this.leading,
    this.acoes,
    this.elevacao = 0,
  });

  final String titulo;
  final Widget? leading;
  final List<Widget>? acoes;
  final double elevacao;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop =
            constraints.maxWidth >= DsEspacamentos.breakpointTablet;

        return AppBar(
          backgroundColor: DsCores.branco,
          foregroundColor: DsCores.cinza900,
          elevation: elevacao,
          scrolledUnderElevation: 1,
          shadowColor: DsSombras.nivel1.first.color,
          automaticallyImplyLeading: !isDesktop,
          leading: isDesktop ? null : leading,
          title: Text(
            titulo,
            style: DsTipografia.titleLarge.copyWith(color: DsCores.cinza900),
          ),
          actions: acoes,
        );
      },
    );
  }
}
