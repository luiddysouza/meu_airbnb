import 'package:flutter/material.dart';

import '../../tokens/cores.dart';
import '../../tokens/espacamentos.dart';
import '../../tokens/sombras.dart';
import '../../tokens/tipografia.dart';

enum StatusHospedagemDs { confirmada, pendente, cancelada, concluida }

class DsCardHospedagem extends StatelessWidget {
  const DsCardHospedagem({
    super.key,
    required this.nomeHospede,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.valorTotal,
    this.nomeImovel,
    this.aoTocar,
    this.aoEditar,
    this.aoDeletar,
  });

  final String nomeHospede;
  final DateTime checkIn;
  final DateTime checkOut;
  final StatusHospedagemDs status;
  final double valorTotal;
  final String? nomeImovel;
  final VoidCallback? aoTocar;
  final VoidCallback? aoEditar;
  final VoidCallback? aoDeletar;

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  static String _formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        decoration: BoxDecoration(
          color: DsCores.branco,
          borderRadius: const BorderRadius.all(
            Radius.circular(DsEspacamentos.radiusMd),
          ),
          boxShadow: DsSombras.nivel1,
        ),
        padding: const EdgeInsets.all(DsEspacamentos.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCabecalho(),
            const SizedBox(height: DsEspacamentos.sm),
            _buildDatas(),
            if (nomeImovel != null) ...[
              const SizedBox(height: DsEspacamentos.xs),
              _buildImovel(),
            ],
            const SizedBox(height: DsEspacamentos.sm),
            _buildRodape(),
          ],
        ),
      ),
    );
  }

  Widget _buildCabecalho() {
    return Row(
      children: [
        Expanded(
          child: Text(
            nomeHospede,
            style: DsTipografia.titleMedium.copyWith(color: DsCores.cinza900),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: DsEspacamentos.xs),
        _BadgeStatus(status: status),
      ],
    );
  }

  Widget _buildDatas() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 14, color: DsCores.cinza500),
        const SizedBox(width: DsEspacamentos.xxs),
        Text(
          '${_formatarData(checkIn)} → ${_formatarData(checkOut)}',
          style: DsTipografia.bodySmall.copyWith(color: DsCores.cinza500),
        ),
      ],
    );
  }

  Widget _buildImovel() {
    return Row(
      children: [
        const Icon(Icons.home_outlined, size: 14, color: DsCores.cinza500),
        const SizedBox(width: DsEspacamentos.xxs),
        Expanded(
          child: Text(
            nomeImovel!,
            style: DsTipografia.bodySmall.copyWith(color: DsCores.cinza500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRodape() {
    return Row(
      children: [
        Text(
          _formatarValor(valorTotal),
          style: DsTipografia.titleMedium.copyWith(color: DsCores.primaria),
        ),
        const Spacer(),
        if (aoEditar != null)
          IconButton(
            onPressed: aoEditar,
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: DsCores.cinza500,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Editar',
          ),
        if (aoEditar != null && aoDeletar != null)
          const SizedBox(width: DsEspacamentos.xs),
        if (aoDeletar != null)
          IconButton(
            onPressed: aoDeletar,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: DsCores.erro,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Excluir',
          ),
      ],
    );
  }
}

class _BadgeStatus extends StatelessWidget {
  const _BadgeStatus({required this.status});

  final StatusHospedagemDs status;

  static Color _corDeFundo(StatusHospedagemDs status) {
    switch (status) {
      case StatusHospedagemDs.confirmada:
        return DsCores.confirmada;
      case StatusHospedagemDs.pendente:
        return DsCores.pendente;
      case StatusHospedagemDs.cancelada:
        return DsCores.cancelada;
      case StatusHospedagemDs.concluida:
        return DsCores.concluida;
    }
  }

  static String _rotulo(StatusHospedagemDs status) {
    switch (status) {
      case StatusHospedagemDs.confirmada:
        return 'Confirmada';
      case StatusHospedagemDs.pendente:
        return 'Pendente';
      case StatusHospedagemDs.cancelada:
        return 'Cancelada';
      case StatusHospedagemDs.concluida:
        return 'Concluída';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = _corDeFundo(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DsEspacamentos.xs,
        vertical: DsEspacamentos.xxs,
      ),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: const BorderRadius.all(
          Radius.circular(DsEspacamentos.radiusXl),
        ),
      ),
      child: Text(
        _rotulo(status),
        style: DsTipografia.labelSmall.copyWith(color: DsCores.branco),
      ),
    );
  }
}
