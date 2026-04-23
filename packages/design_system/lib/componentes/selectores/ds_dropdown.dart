import 'package:flutter/material.dart';

import '../../tokens/bordas.dart';
import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/icones.dart';
import '../../tokens/tipografia.dart';

class DsOpcaoDropdown {
  const DsOpcaoDropdown({required this.valor, required this.rotulo});

  final String valor;
  final String rotulo;
}

class DsDropdown extends StatelessWidget {
  const DsDropdown({
    super.key,
    required this.rotulo,
    required this.opcoes,
    required this.aoSelecionar,
    this.valorSelecionado,
    this.habilitado = true,
    this.textoHelper,
    this.aoLimpar,
  });

  final String rotulo;
  final List<DsOpcaoDropdown> opcoes;
  final String? valorSelecionado;
  final ValueChanged<String?> aoSelecionar;
  final bool habilitado;
  final String? textoHelper;
  final VoidCallback? aoLimpar;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: valorSelecionado,
      onChanged: habilitado ? aoSelecionar : null,
      items: opcoes
          .map(
            (opcao) => DropdownMenuItem<String>(
              value: opcao.valor,
              child: Text(opcao.rotulo, style: DsTipografia.bodyMedium),
            ),
          )
          .toList(),
      decoration: InputDecoration(
        labelText: rotulo,
        helperText: textoHelper,
        suffix: (aoLimpar != null && valorSelecionado != null)
            ? GestureDetector(
                onTap: aoLimpar,
                child: const Icon(
                  Icons.close,
                  size: DsIcones.sm,
                  color: DsCores.cinza500,
                ),
              )
            : null,
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
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(DsEspacamentos.radiusSm),
          ),
          borderSide: BorderSide(
            color: DsCores.primaria,
            width: DsBordas.media,
          ),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(DsEspacamentos.radiusSm),
          ),
          borderSide: BorderSide(color: DsCores.cinza100),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DsEspacamentos.md,
          vertical: DsEspacamentos.sm,
        ),
        filled: !habilitado,
        fillColor: habilitado ? null : DsCores.cinza100,
      ),
    );
  }
}
