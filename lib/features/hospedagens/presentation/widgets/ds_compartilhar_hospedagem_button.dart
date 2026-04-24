import 'package:flutter/material.dart';
import 'package:meu_airbnb/core/platform/share_channel.dart';
import 'package:meu_airbnb/features/hospedagens/domain/entities/hospedagem_entity.dart';

/// Widget para compartilhar uma hospedagem via Intent nativo do Android.
///
/// Integra-se com o MethodChannel `br.com.meuairbnb.meu_airbnb/share`.
/// Em plataformas não-suportadas (iOS, web), desabilita silenciosamente.
///
/// Exemplo de uso em um card:
/// ```dart
/// DsCompartilharHospedagemButton(
///   hospedagem: hospedagem,
///   onCompartilhado: () => mostrarSnackbar('Compartilhado!'),
///   onErro: (e) => mostrarSnackbar('Erro: $e'),
/// )
/// ```
class DsCompartilharHospedagemButton extends StatefulWidget {
  final HospedagemEntity hospedagem;
  final VoidCallback? onCompartilhado;
  final Function(String)? onErro;

  const DsCompartilharHospedagemButton({
    super.key,
    required this.hospedagem,
    this.onCompartilhado,
    this.onErro,
  });

  @override
  State<DsCompartilharHospedagemButton> createState() =>
      _DsCompartilharHospedagemButtonState();
}

class _DsCompartilharHospedagemButtonState
    extends State<DsCompartilharHospedagemButton> {
  bool _carregando = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _carregando ? null : _compartilhar,
      icon: _carregando
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.share),
      label: _carregando
          ? const Text('Compartilhando...')
          : const Text('Compartilhar'),
    );
  }

  Future<void> _compartilhar() async {
    setState(() => _carregando = true);

    try {
      final descricao = _construirDescricao();
      final sucesso = await ShareChannel.compartilharHospedagem(
        titulo: widget.hospedagem.nomeHospede,
        descricao: descricao,
      );

      if (mounted) {
        setState(() => _carregando = false);

        if (sucesso) {
          widget.onCompartilhado?.call();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hospedagem compartilhada!')),
            );
          }
        } else {
          // Usuário cancelou ou erro silencioso (ex: em iOS)
          widget.onErro?.call('Compartilhamento cancelado');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
        widget.onErro?.call(e.toString());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao compartilhar: $e')));
      }
    }
  }

  /// Constrói descrição formatada da hospedagem para compartilhamento.
  String _construirDescricao() {
    final linhas = <String>[];

    linhas.add('🏠 Hospedagem');
    linhas.add('Hóspede: ${widget.hospedagem.nomeHospede}');
    linhas.add('Quantos: ${widget.hospedagem.numHospedes} pessoas');

    final checkIn = widget.hospedagem.checkIn;
    final checkOut = widget.hospedagem.checkOut;
    if (checkIn != null && checkOut != null) {
      final checkInFormatado = _formatarData(checkIn);
      final checkOutFormatado = _formatarData(checkOut);
      linhas.add('Período: $checkInFormatado até $checkOutFormatado');
    }

    linhas.add('Valor: R\$ ${widget.hospedagem.valorTotal.toStringAsFixed(2)}');
    linhas.add('Status: ${widget.hospedagem.status}');
    linhas.add('Plataforma: ${widget.hospedagem.plataforma}');

    final notas = widget.hospedagem.notas;
    if (notas?.isNotEmpty ?? false) {
      linhas.add('Notas: $notas');
    }

    return linhas.join('\n');
  }

  /// Formata DateTime para string dd/MM/yyyy.
  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
}
