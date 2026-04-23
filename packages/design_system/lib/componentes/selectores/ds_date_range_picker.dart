import 'package:flutter/material.dart';

import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/icones.dart';
import '../../tokens/tipografia.dart';

class DsDateRangePicker extends StatelessWidget {
  const DsDateRangePicker({
    super.key,
    required this.rotuloInicio,
    required this.rotuloFim,
    required this.aoSelecionar,
    this.periodoSelecionado,
    this.primeiroDia,
    this.ultimoDia,
    this.aoLimpar,
  });

  final String rotuloInicio;
  final String rotuloFim;
  final DateTimeRange? periodoSelecionado;
  final ValueChanged<DateTimeRange> aoSelecionar;
  final DateTime? primeiroDia;
  final DateTime? ultimoDia;
  final VoidCallback? aoLimpar;

  static String _formatarData(DateTime? data) {
    if (data == null) return '—';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  Future<void> _abrirSeletor(BuildContext context) async {
    final resultado = await showDateRangePicker(
      context: context,
      firstDate: primeiroDia ?? DateTime(2020),
      lastDate: ultimoDia ?? DateTime(2030),
      initialDateRange: periodoSelecionado,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: DsCores.branco,
            surface: DsCores.branco,
            surfaceContainerHigh: DsCores.branco,
            surfaceContainerHighest: DsCores.branco,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: DsCores.cinza900),
          ),
        ),
        child: child!,
      ),
    );
    if (resultado != null) aoSelecionar(resultado);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CampoData(
            rotulo: rotuloInicio,
            valor: _formatarData(periodoSelecionado?.start),
            aoTocar: () => _abrirSeletor(context),
          ),
        ),
        const SizedBox(width: DsEspacamentos.sm),
        Expanded(
          child: _CampoData(
            rotulo: rotuloFim,
            valor: _formatarData(periodoSelecionado?.end),
            aoTocar: () => _abrirSeletor(context),
          ),
        ),
        if (periodoSelecionado != null && aoLimpar != null) ...[
          const SizedBox(width: DsEspacamentos.xs),
          IconButton(
            onPressed: aoLimpar,
            icon: const Icon(
              Icons.close,
              size: DsIcones.md,
              color: DsCores.cinza500,
            ),
            tooltip: 'Limpar filtro',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ],
    );
  }
}

class _CampoData extends StatelessWidget {
  const _CampoData({
    required this.rotulo,
    required this.valor,
    required this.aoTocar,
  });

  final String rotulo;
  final String valor;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      borderRadius: const BorderRadius.all(
        Radius.circular(DsEspacamentos.radiusSm),
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: rotulo,
          suffixIcon: const Icon(Icons.calendar_today, size: DsIcones.md),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(DsEspacamentos.radiusSm),
            ),
            borderSide: BorderSide(color: DsCores.cinza300),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(DsEspacamentos.radiusSm),
            ),
            borderSide: BorderSide(color: DsCores.cinza300),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DsEspacamentos.md,
            vertical: DsEspacamentos.sm,
          ),
        ),
        child: Text(valor, style: DsTipografia.bodyMedium),
      ),
    );
  }
}
