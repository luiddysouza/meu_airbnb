import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

const _opcoes = [
  DsOpcaoDropdown(valor: 'id-1', rotulo: 'Apto Centro SP'),
  DsOpcaoDropdown(valor: 'id-2', rotulo: 'Casa Praia Ubatuba'),
  DsOpcaoDropdown(valor: 'id-3', rotulo: 'Studio Pinheiros'),
];

final seletoresFolder = WidgetbookFolder(
  name: 'Seletores',
  children: [
    WidgetbookComponent(
      name: 'DsDateRangePicker',
      useCases: [
        WidgetbookUseCase(
          name: 'Sem período',
          builder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: _DateRangePickerPreview(),
          ),
        ),
        WidgetbookUseCase(
          name: 'Com período selecionado',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: _DateRangePickerPreview(
              periodoInicial: DateTimeRange(
                start: DateTime(2026, 4, 20),
                end: DateTime(2026, 4, 25),
              ),
            ),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'DsDropdown',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: _DropdownPreview(),
          ),
        ),
        WidgetbookUseCase(
          name: 'Com valor selecionado',
          builder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: _DropdownPreview(valorInicial: 'id-2'),
          ),
        ),
        WidgetbookUseCase(
          name: 'Desabilitado',
          builder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: _DropdownPreview(habilitado: false),
          ),
        ),
      ],
    ),
  ],
);

// --- Wrappers stateful ---

class _DateRangePickerPreview extends StatefulWidget {
  const _DateRangePickerPreview({this.periodoInicial});

  final DateTimeRange? periodoInicial;

  @override
  State<_DateRangePickerPreview> createState() =>
      _DateRangePickerPreviewState();
}

class _DateRangePickerPreviewState extends State<_DateRangePickerPreview> {
  DateTimeRange? _periodo;

  @override
  void initState() {
    super.initState();
    _periodo = widget.periodoInicial;
  }

  @override
  Widget build(BuildContext context) {
    return DsDateRangePicker(
      rotuloInicio: 'Check-in',
      rotuloFim: 'Check-out',
      periodoSelecionado: _periodo,
      aoSelecionar: (p) => setState(() => _periodo = p),
    );
  }
}

class _DropdownPreview extends StatefulWidget {
  const _DropdownPreview({this.valorInicial, this.habilitado = true});

  final String? valorInicial;
  final bool habilitado;

  @override
  State<_DropdownPreview> createState() => _DropdownPreviewState();
}

class _DropdownPreviewState extends State<_DropdownPreview> {
  String? _valor;

  @override
  void initState() {
    super.initState();
    _valor = widget.valorInicial;
  }

  @override
  Widget build(BuildContext context) {
    return DsDropdown(
      rotulo: 'Imóvel',
      opcoes: _opcoes,
      valorSelecionado: _valor,
      habilitado: widget.habilitado,
      aoSelecionar: (v) => setState(() => _valor = v),
    );
  }
}
