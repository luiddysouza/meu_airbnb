import 'package:flutter/material.dart';

import '../../tokens/espacamentos.dart';
import '../feedback/ds_estado_vazio.dart';

class DsLista extends StatelessWidget {
  const DsLista({
    super.key,
    required this.itens,
    this.mensagemVazia = 'Nenhum item encontrado',
  });

  final List<Widget> itens;
  final String mensagemVazia;

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty) {
      return DsEstadoVazio(mensagem: mensagemVazia);
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itens.length,
      separatorBuilder: (_, _) => const SizedBox(height: DsEspacamentos.sm),
      itemBuilder: (_, i) => itens[i],
    );
  }
}
