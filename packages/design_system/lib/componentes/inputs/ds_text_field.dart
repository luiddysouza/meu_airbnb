import 'package:flutter/material.dart';

import '../../tokens/bordas.dart';
import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/tipografia.dart';

class DsTextField extends StatelessWidget {
  const DsTextField({
    super.key,
    required this.rotulo,
    required this.controlador,
    this.textoHelper,
    this.validador,
    this.obscureText = false,
    this.tipoTeclado,
    this.prefixIcone,
    this.habilitado = true,
    this.aoMudar,
    this.maxLinhas = 1,
    this.textoHint,
  });

  final String rotulo;
  final TextEditingController controlador;
  final String? textoHelper;
  final FormFieldValidator<String>? validador;
  final bool obscureText;
  final TextInputType? tipoTeclado;
  final IconData? prefixIcone;
  final bool habilitado;
  final ValueChanged<String>? aoMudar;
  final int? maxLinhas;
  final String? textoHint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      obscureText: obscureText,
      keyboardType: tipoTeclado,
      enabled: habilitado,
      onChanged: aoMudar,
      validator: validador,
      maxLines: maxLinhas,
      style: DsTipografia.bodyLarge.copyWith(color: DsCores.cinza900),
      decoration: InputDecoration(
        labelText: rotulo,
        hintText: textoHint,
        helperText: textoHelper,
        prefixIcon: prefixIcone != null ? Icon(prefixIcone) : null,
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
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(DsEspacamentos.radiusSm),
          ),
          borderSide: BorderSide(color: DsCores.erro),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(DsEspacamentos.radiusSm),
          ),
          borderSide: BorderSide(color: DsCores.erro, width: DsBordas.media),
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
