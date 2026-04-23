import 'package:flutter/material.dart';

import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import 'ds_app_bar_adaptativa.dart';

/// Scaffold responsivo com dois layouts:
///
/// - **Desktop** (≥ [DsEspacamentos.breakpointTablet]): sidebar à esquerda +
///   área principal à direita, sem Drawer.
/// - **Mobile** (< [DsEspacamentos.breakpointTablet]): coluna única — sidebar
///   no topo (se fornecida), conteúdo principal abaixo. Drawer opcional.
class DsScaffoldResponsivo extends StatelessWidget {
  const DsScaffoldResponsivo({
    super.key,
    required this.titulo,
    required this.conteudoPrincipal,
    this.conteudoSidebar,
    this.acoes,
    this.botaoAcaoFlutuante,
    this.drawer,
  });

  final String titulo;
  final Widget conteudoPrincipal;
  final Widget? conteudoSidebar;
  final List<Widget>? acoes;
  final Widget? botaoAcaoFlutuante;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop =
            constraints.maxWidth >= DsEspacamentos.breakpointTablet;

        if (isDesktop) {
          return _LayoutDesktop(
            titulo: titulo,
            conteudoPrincipal: conteudoPrincipal,
            conteudoSidebar: conteudoSidebar,
            acoes: acoes,
            botaoAcaoFlutuante: botaoAcaoFlutuante,
          );
        }

        return _LayoutMobile(
          titulo: titulo,
          conteudoPrincipal: conteudoPrincipal,
          conteudoSidebar: conteudoSidebar,
          acoes: acoes,
          botaoAcaoFlutuante: botaoAcaoFlutuante,
          drawer: drawer,
        );
      },
    );
  }
}

class _LayoutDesktop extends StatelessWidget {
  const _LayoutDesktop({
    required this.titulo,
    required this.conteudoPrincipal,
    this.conteudoSidebar,
    this.acoes,
    this.botaoAcaoFlutuante,
  });

  final String titulo;
  final Widget conteudoPrincipal;
  final Widget? conteudoSidebar;
  final List<Widget>? acoes;
  final Widget? botaoAcaoFlutuante;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsCores.cinza100,
      appBar: DsAppBarAdaptativa(titulo: titulo, acoes: acoes),
      floatingActionButton: botaoAcaoFlutuante,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (conteudoSidebar != null)
            SizedBox(
              width: DsEspacamentos.larguraSidebar,
              child: ColoredBox(color: DsCores.branco, child: conteudoSidebar!),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: DsEspacamentos.maxWidthConteudo,
                ),
                child: conteudoPrincipal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayoutMobile extends StatelessWidget {
  const _LayoutMobile({
    required this.titulo,
    required this.conteudoPrincipal,
    this.conteudoSidebar,
    this.acoes,
    this.botaoAcaoFlutuante,
    this.drawer,
  });

  final String titulo;
  final Widget conteudoPrincipal;
  final Widget? conteudoSidebar;
  final List<Widget>? acoes;
  final Widget? botaoAcaoFlutuante;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsCores.cinza100,
      appBar: DsAppBarAdaptativa(titulo: titulo, acoes: acoes),
      drawer: drawer,
      floatingActionButton: botaoAcaoFlutuante,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (conteudoSidebar != null)
              ColoredBox(color: DsCores.branco, child: conteudoSidebar!),
            conteudoPrincipal,
          ],
        ),
      ),
    );
  }
}
