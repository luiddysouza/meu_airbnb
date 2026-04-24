import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injecao.dart';
import '../../../../core/sdui/cubit/sdui_cubit.dart';
import '../../../../core/sdui/cubit/sdui_state.dart';
import '../../../../core/sdui/factory/widget_factory.dart';
import '../../../../core/sdui/models/sdui_node.dart';
import '../../../../core/sdui/renderer/sdui_renderer.dart';
import '../stores/filtro_store.dart';
import '../stores/hospedagem_store.dart';
import '../widgets/formulario_hospedagem_dialog.dart';

/// Página principal de hospedagens.
///
/// Responsabilidades:
/// - Cria e gerencia o [SduiCubit] local (lifecycle via [initState]/[dispose])
/// - Dispara o carregamento da árvore SDUI e dos dados de negócio
/// - Usa [BlocBuilder] para alternar entre os estados: loading, sucesso, erro
/// - Em sucesso: separa os nós de filtro (sidebar) da lista (conteúdo principal)
///   e entrega ao [DsScaffoldResponsivo] para layout responsivo
class HospedagensPagina extends StatefulWidget {
  const HospedagensPagina({super.key});

  @override
  State<HospedagensPagina> createState() => _HospedagensPaginaState();
}

class _HospedagensPaginaState extends State<HospedagensPagina> {
  late final SduiCubit _sduiCubit;

  /// Uma única instância da fábrica por página — evita recriar a cada rebuild.
  final _fabricaSdui = WidgetFactory.padrao();

  @override
  void initState() {
    super.initState();
    _sduiCubit = sl<SduiCubit>();
    _sduiCubit.carregarTela();
    sl<HospedagemStore>().carregarHospedagens();
    sl<FiltroStore>().carregarImoveis();
  }

  @override
  void dispose() {
    _sduiCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SduiCubit>.value(
      value: _sduiCubit,
      child: BlocBuilder<SduiCubit, SduiState>(
        builder: (context, state) {
          if (state is SduiLoading || state is SduiInitial) {
            return const DsScaffoldResponsivo(
              titulo: 'Hospedagens',
              conteudoPrincipal: DsCarregando(mensagem: 'Carregando tela...'),
            );
          }

          if (state is SduiError) {
            return DsScaffoldResponsivo(
              titulo: 'Hospedagens',
              conteudoPrincipal: DsEstadoVazio(mensagem: state.mensagem),
            );
          }

          if (state is SduiSuccess) {
            return _buildTela(state.arvore);
          }

          // Fallback — nunca deveria ocorrer com SduiState sealed
          return const DsScaffoldResponsivo(
            titulo: 'Hospedagens',
            conteudoPrincipal: SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildTela(List<SduiNode> arvore) {
    // Separa os nós de filtro (sidebar) da lista (conteúdo principal)
    final nosSidebar = arvore.where((n) => n.tipo != 'lista').toList();
    final nosMain = arvore.where((n) => n.tipo == 'lista').toList();

    return DsScaffoldResponsivo(
      titulo: 'Hospedagens',
      botaoAcaoFlutuante: FloatingActionButton(
        onPressed: _abrirFormularioCriacao,
        backgroundColor: DsCores.primaria,
        foregroundColor: DsCores.branco,
        tooltip: 'Nova hospedagem',
        child: const Icon(Icons.add),
      ),
      conteudoSidebar: nosSidebar.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(DsEspacamentos.md),
              child: SduiRenderer(nos: nosSidebar, fabrica: _fabricaSdui),
            )
          : null,
      conteudoPrincipal: Padding(
        padding: const EdgeInsets.all(DsEspacamentos.md),
        child: SduiRenderer(nos: nosMain, fabrica: _fabricaSdui),
      ),
    );
  }

  Future<void> _abrirFormularioCriacao() async {
    final hospedagemStore = sl<HospedagemStore>();
    final filtroStore = sl<FiltroStore>();

    final salvo = await FormularioHospedagemDialog.mostrar(
      context,
      imoveis: filtroStore.imoveis,
    );

    if (!mounted) return;

    if (salvo) {
      if (hospedagemStore.erro != null) {
        DsSnackbar.erro(context, mensagem: hospedagemStore.erro!);
      } else {
        DsSnackbar.sucesso(context, mensagem: 'Hospedagem criada com sucesso!');
      }
    }
  }
}
