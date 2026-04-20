import 'package:flutter/material.dart';

import '../fabrica/widget_factory.dart';
import '../modelos/no_sdui.dart';

/// Percorre recursivamente uma lista de [NoSdui] e constrói a árvore de
/// widgets usando a [WidgetFactory] fornecida.
///
/// Cada nó é renderizado pelo builder registrado no factory. Nós filhos
/// são renderizados recursivamente via o callback [_renderizarNo].
class SduiRenderer extends StatelessWidget {
  const SduiRenderer({super.key, required this.nos, required this.fabrica});

  final List<NoSdui> nos;
  final WidgetFactory fabrica;

  Widget _renderizarNo(BuildContext context, NoSdui no) {
    return fabrica.construir(context, no, _renderizarNo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: nos.map((no) => _renderizarNo(context, no)).toList(),
    );
  }
}
