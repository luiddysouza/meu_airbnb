import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../factory/widget_factory.dart';
import '../models/sdui_node.dart';

/// Percorre recursivamente uma lista de [SduiNode] e constrói a árvore de
/// widgets usando a [WidgetFactory] fornecida.
///
/// Cada nó é renderizado pelo builder registrado no factory. Nós filhos
/// são renderizados recursivamente via o callback [_renderizarNo].
class SduiRenderer extends StatelessWidget {
  const SduiRenderer({super.key, required this.nos, required this.fabrica});

  final List<SduiNode> nos;
  final WidgetFactory fabrica;

  Widget _renderizarNo(BuildContext context, SduiNode no) {
    return fabrica.construir(context, no, _renderizarNo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsEspacamentos.md,
      children: nos.map((no) => _renderizarNo(context, no)).toList(),
    );
  }
}
