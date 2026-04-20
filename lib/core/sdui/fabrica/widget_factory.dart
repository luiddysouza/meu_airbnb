import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../modelos/no_sdui.dart';

/// Assinatura de um builder de widget SDUI.
///
/// Recebe o [BuildContext], o [NoSdui] a ser renderizado e um callback
/// [renderizarFilho] para renderização recursiva dos nós filhos.
typedef BuilderSdui =
    Widget Function(
      BuildContext context,
      NoSdui no,
      Widget Function(BuildContext, NoSdui) renderizarFilho,
    );

/// Registry que mapeia tipos SDUI → widgets do Design System.
///
/// Uso básico:
/// ```dart
/// final fabrica = WidgetFactory.padrao();
/// final widget = fabrica.construir(context, no, renderizarFilho);
/// ```
///
/// Para registrar builders customizados ou sobrescrever os padrão:
/// ```dart
/// fabrica.registrar('meu_tipo', (ctx, no, renderFilho) => MeuWidget());
/// ```
class WidgetFactory {
  WidgetFactory();

  final Map<String, BuilderSdui> _registro = {};

  /// Registra um [builder] para o [tipo] SDUI informado.
  /// Sobrescreve o builder existente se o tipo já estiver registrado.
  void registrar(String tipo, BuilderSdui builder) {
    _registro[tipo] = builder;
  }

  /// Retorna `true` se [tipo] possui um builder registrado.
  bool temTipo(String tipo) => _registro.containsKey(tipo);

  /// Constrói o widget correspondente ao [no].
  /// Retorna [SizedBox.shrink] como fallback para tipos não registrados.
  Widget construir(
    BuildContext context,
    NoSdui no,
    Widget Function(BuildContext, NoSdui) renderizarFilho,
  ) {
    final builder = _registro[no.tipo];
    if (builder == null) return const SizedBox.shrink();
    return builder(context, no, renderizarFilho);
  }

  // ---------------------------------------------------------------------------
  // Factory constructor com os 7 builders padrão do SDUI
  // ---------------------------------------------------------------------------

  /// Cria uma [WidgetFactory] pré-configurada com os builders dos 7 tipos
  /// SDUI registrados no schema do projeto.
  ///
  /// Os builders de widgets reativos (dropdown, lista) serão conectados
  /// aos MobX stores na integração SDUI ↔ MobX (Commit 12).
  factory WidgetFactory.padrao() {
    final fabrica = WidgetFactory();
    fabrica.registrar('seletor_data_range', _buildSeletorDataRange);
    fabrica.registrar('dropdown', _buildDropdown);
    fabrica.registrar('lista', _buildLista);
    fabrica.registrar('card_hospedagem', _buildCardHospedagem);
    fabrica.registrar('botao_primario', _buildBotaoPrimario);
    fabrica.registrar('estado_vazio', _buildEstadoVazio);
    fabrica.registrar('carregando', _buildCarregando);
    return fabrica;
  }

  // ---------------------------------------------------------------------------
  // Builders estáticos — estrutura definida pelo SDUI, dados via propriedades
  // ---------------------------------------------------------------------------

  static Widget _buildSeletorDataRange(
    BuildContext context,
    NoSdui no,
    Widget Function(BuildContext, NoSdui) renderizarFilho,
  ) {
    final props = no.propriedades;
    return DsDateRangePicker(
      rotuloInicio: props['rotulo_inicio'] as String? ?? 'Check-in',
      rotuloFim: props['rotulo_fim'] as String? ?? 'Check-out',
      aoSelecionar: (_) {},
    );
  }

  static Widget _buildDropdown(
    BuildContext context,
    NoSdui no,
    Widget Function(BuildContext, NoSdui) renderizarFilho,
  ) {
    final props = no.propriedades;
    return DsDropdown(
      rotulo: props['rotulo'] as String? ?? '',
      opcoes: const [],
      aoSelecionar: (_) {},
    );
  }

  static Widget _buildLista(
    BuildContext context,
    NoSdui no,
    Widget Function(BuildContext, NoSdui) renderizarFilho,
  ) {
    final props = no.propriedades;
    return DsLista(
      itens: const [],
      mensagemVazia:
          props['vazio_mensagem'] as String? ?? 'Nenhuma hospedagem encontrada',
    );
  }

  static Widget _buildCardHospedagem(
    BuildContext context,
    NoSdui no,
    Widget Function(BuildContext, NoSdui) renderizarFilho,
  ) {
    final props = no.propriedades;
    return DsCardHospedagem(
      nomeHospede: props['nome_hospede'] as String? ?? '',
      checkIn:
          DateTime.tryParse(props['check_in'] as String? ?? '') ??
          DateTime.now(),
      checkOut:
          DateTime.tryParse(props['check_out'] as String? ?? '') ??
          DateTime.now(),
      valorTotal: (props['valor_total'] as num?)?.toDouble() ?? 0.0,
      status: _statusDe(props['status'] as String? ?? 'pendente'),
      nomeImovel: props['nome_imovel'] as String?,
    );
  }

  static Widget _buildBotaoPrimario(
    BuildContext context,
    NoSdui no,
    Widget Function(BuildContext, NoSdui) renderizarFilho,
  ) {
    final props = no.propriedades;
    return DsBotaoPrimario(rotulo: props['rotulo'] as String? ?? '');
  }

  static Widget _buildEstadoVazio(
    BuildContext context,
    NoSdui no,
    Widget Function(BuildContext, NoSdui) renderizarFilho,
  ) {
    final props = no.propriedades;
    return DsEstadoVazio(mensagem: props['mensagem'] as String? ?? '');
  }

  static Widget _buildCarregando(
    BuildContext context,
    NoSdui no,
    Widget Function(BuildContext, NoSdui) renderizarFilho,
  ) {
    final props = no.propriedades;
    return DsCarregando(mensagem: props['mensagem'] as String?);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static StatusHospedagemDs _statusDe(String status) {
    switch (status) {
      case 'confirmada':
        return StatusHospedagemDs.confirmada;
      case 'cancelada':
        return StatusHospedagemDs.cancelada;
      case 'concluida':
        return StatusHospedagemDs.concluida;
      default:
        return StatusHospedagemDs.pendente;
    }
  }
}
