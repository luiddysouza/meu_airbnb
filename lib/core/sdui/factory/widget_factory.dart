import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../features/hospedagens/presentation/stores/filtro_store.dart';
import '../../../features/hospedagens/presentation/stores/hospedagem_store.dart';
import '../../../features/hospedagens/presentation/widgets/formulario_hospedagem_dialog.dart';
import '../../di/injecao.dart';
import '../models/sdui_node.dart';

/// Assinatura de um builder de widget SDUI.
///
/// Recebe o [BuildContext], o [SduiNode] a ser renderizado e um callback
/// [renderizarFilho] para renderização recursiva dos nós filhos.
typedef BuilderSdui =
    Widget Function(
      BuildContext context,
      SduiNode no,
      Widget Function(BuildContext, SduiNode) renderizarFilho,
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
    SduiNode no,
    Widget Function(BuildContext, SduiNode) renderizarFilho,
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
  /// Os builders reativos (seletor_data_range, dropdown, lista) são conectados
  /// aos MobX stores via [sl] (get_it). O store é resolvido de forma lazy
  /// durante a construção do widget, após o DI estar inicializado.
  factory WidgetFactory.padrao() {
    final fabrica = WidgetFactory();
    // Builders reativos — instance methods que acessam FiltroStore via DI
    fabrica.registrar('seletor_data_range', fabrica._buildSeletorDataRange);
    fabrica.registrar('dropdown', fabrica._buildDropdown);
    fabrica.registrar('lista', fabrica._buildLista);
    // Builders estáticos — sem dependência de stores
    fabrica.registrar('card_hospedagem', _buildCardHospedagem);
    fabrica.registrar('botao_primario', _buildBotaoPrimario);
    fabrica.registrar('estado_vazio', _buildEstadoVazio);
    fabrica.registrar('carregando', _buildCarregando);
    return fabrica;
  }

  // ---------------------------------------------------------------------------
  // Builders reativos — conectados ao FiltroStore via get_it
  // ---------------------------------------------------------------------------

  Widget _buildSeletorDataRange(
    BuildContext context,
    SduiNode no,
    Widget Function(BuildContext, SduiNode) renderizarFilho,
  ) {
    final filtroStore = sl<FiltroStore>();
    final props = no.propriedades;
    return Observer(
      builder: (_) => DsDateRangePicker(
        rotuloInicio: props['rotulo_inicio'] as String? ?? 'Check-in',
        rotuloFim: props['rotulo_fim'] as String? ?? 'Check-out',
        periodoSelecionado: filtroStore.periodoSelecionado,
        aoSelecionar: (range) => filtroStore.selecionarPeriodo(range),
        aoLimpar: () => filtroStore.selecionarPeriodo(null),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    SduiNode no,
    Widget Function(BuildContext, SduiNode) renderizarFilho,
  ) {
    final filtroStore = sl<FiltroStore>();
    final props = no.propriedades;
    return Observer(
      builder: (_) => DsDropdown(
        rotulo: props['rotulo'] as String? ?? '',
        opcoes: filtroStore.imoveis
            .map((i) => DsOpcaoDropdown(valor: i.id, rotulo: i.nome))
            .toList(),
        valorSelecionado: filtroStore.imovelSelecionadoId,
        aoSelecionar: filtroStore.selecionarImovel,
        aoLimpar: () => filtroStore.selecionarImovel(null),
      ),
    );
  }

  Widget _buildLista(
    BuildContext context,
    SduiNode no,
    Widget Function(BuildContext, SduiNode) renderizarFilho,
  ) {
    final filtroStore = sl<FiltroStore>();
    final hospedagemStore = sl<HospedagemStore>();
    final props = no.propriedades;
    return Observer(
      builder: (_) {
        final hospedagens = filtroStore.hospedagensFiltradas;
        return DsLista(
          mensagemVazia:
              props['vazio_mensagem'] as String? ??
              'Nenhuma hospedagem encontrada',
          itens: hospedagens.map((h) {
            final imovelMatch = filtroStore.imoveis.where(
              (i) => i.id == h.imovelId,
            );
            final nomeImovel = imovelMatch.isEmpty
                ? null
                : imovelMatch.first.nome;
            return DsCardHospedagem(
              nomeHospede: h.nomeHospede,
              checkIn: h.checkIn,
              checkOut: h.checkOut,
              valorTotal: h.valorTotal,
              status: _statusDe(h.status.name),
              nomeImovel: nomeImovel,
              aoEditar: () async {
                final salvo = await FormularioHospedagemDialog.mostrar(
                  context,
                  hospedagemStore: hospedagemStore,
                  imoveis: filtroStore.imoveis,
                  hospedagem: h,
                );
                if (!context.mounted) return;
                if (salvo) {
                  if (hospedagemStore.erro != null) {
                    DsSnackbar.erro(context, mensagem: hospedagemStore.erro!);
                  } else {
                    DsSnackbar.sucesso(
                      context,
                      mensagem: 'Hospedagem atualizada com sucesso!',
                    );
                  }
                }
              },
              aoDeletar: () async {
                final confirmado = await DsDialogConfirmacao.mostrar(
                  context,
                  titulo: 'Excluir hospedagem',
                  mensagem:
                      'Deseja excluir a hospedagem de ${h.nomeHospede}? '
                      'Essa ação não pode ser desfeita.',
                  rotuloConfirmar: 'Excluir',
                  destrutivo: true,
                );
                if (!confirmado) return;
                await hospedagemStore.deletarHospedagem(h.id);
                if (!context.mounted) return;
                if (hospedagemStore.erro != null) {
                  DsSnackbar.erro(context, mensagem: hospedagemStore.erro!);
                } else {
                  DsSnackbar.sucesso(
                    context,
                    mensagem: 'Hospedagem removida com sucesso!',
                  );
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  static Widget _buildCardHospedagem(
    BuildContext context,
    SduiNode no,
    Widget Function(BuildContext, SduiNode) renderizarFilho,
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
    SduiNode no,
    Widget Function(BuildContext, SduiNode) renderizarFilho,
  ) {
    final props = no.propriedades;
    return DsBotaoPrimario(rotulo: props['rotulo'] as String? ?? '');
  }

  static Widget _buildEstadoVazio(
    BuildContext context,
    SduiNode no,
    Widget Function(BuildContext, SduiNode) renderizarFilho,
  ) {
    final props = no.propriedades;
    return DsEstadoVazio(mensagem: props['mensagem'] as String? ?? '');
  }

  static Widget _buildCarregando(
    BuildContext context,
    SduiNode no,
    Widget Function(BuildContext, SduiNode) renderizarFilho,
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
