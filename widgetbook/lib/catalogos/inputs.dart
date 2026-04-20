import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

final inputsFolder = WidgetbookFolder(
  name: 'Inputs',
  children: [
    WidgetbookComponent(
      name: 'DsTextField',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => _TextFieldPreview(
            rotulo: context.knobs.string(label: 'Rótulo', initialValue: 'Nome'),
          ),
        ),
        WidgetbookUseCase(
          name: 'Com helper text',
          builder: (context) => const _TextFieldPreview(
            rotulo: 'E-mail',
            textoHelper: 'Informe seu melhor e-mail',
          ),
        ),
        WidgetbookUseCase(
          name: 'Com hint text',
          builder: (context) => const _TextFieldPreview(
            rotulo: 'Telefone',
            textoHint: '+55 11 99999-0000',
            tipoTeclado: TextInputType.phone,
          ),
        ),
        WidgetbookUseCase(
          name: 'Com ícone prefix',
          builder: (context) => const _TextFieldPreview(
            rotulo: 'Pesquisar',
            prefixIcone: Icons.search,
          ),
        ),
        WidgetbookUseCase(
          name: 'Multilinhas',
          builder: (context) =>
              const _TextFieldPreview(rotulo: 'Notas', maxLinhas: 4),
        ),
        WidgetbookUseCase(
          name: 'Desabilitado',
          builder: (context) => const _TextFieldPreview(
            rotulo: 'ID',
            valorInicial: 'abc-123',
            habilitado: false,
          ),
        ),
      ],
    ),
  ],
);

// --- Wrapper stateful para DsTextField ---

class _TextFieldPreview extends StatefulWidget {
  const _TextFieldPreview({
    required this.rotulo,
    this.textoHelper,
    this.textoHint,
    this.tipoTeclado,
    this.prefixIcone,
    this.maxLinhas = 1,
    this.habilitado = true,
    this.valorInicial,
  });

  final String rotulo;
  final String? textoHelper;
  final String? textoHint;
  final TextInputType? tipoTeclado;
  final IconData? prefixIcone;
  final int? maxLinhas;
  final bool habilitado;
  final String? valorInicial;

  @override
  State<_TextFieldPreview> createState() => _TextFieldPreviewState();
}

class _TextFieldPreviewState extends State<_TextFieldPreview> {
  late final TextEditingController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = TextEditingController(text: widget.valorInicial);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DsTextField(
        rotulo: widget.rotulo,
        controlador: _controlador,
        textoHelper: widget.textoHelper,
        textoHint: widget.textoHint,
        tipoTeclado: widget.tipoTeclado,
        prefixIcone: widget.prefixIcone,
        maxLinhas: widget.maxLinhas,
        habilitado: widget.habilitado,
      ),
    );
  }
}
