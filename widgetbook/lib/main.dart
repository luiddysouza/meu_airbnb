import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'catalogos/botoes.dart';
import 'catalogos/exibicao.dart';
import 'catalogos/inputs.dart';
import 'catalogos/layout.dart';
import 'catalogos/selectores.dart';

void main() => runApp(const _Catalogo());

class _Catalogo extends StatelessWidget {
  const _Catalogo();

  @override
  Widget build(BuildContext context) {
    return Widgetbook(
      addons: [
        MaterialThemeAddon(
          themes: [WidgetbookTheme(name: 'Claro', data: DsTemaApp.tema)],
        ),
        TextScaleAddon(min: 1.0, max: 1.5),
      ],
      directories: [
        botoesFolder,
        inputsFolder,
        seletoresFolder,
        exibicaoFolder,
        layoutFolder,
      ],
    );
  }
}
