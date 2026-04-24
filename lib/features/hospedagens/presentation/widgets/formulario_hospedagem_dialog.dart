import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../core/di/injecao.dart';
import '../../domain/entities/hospedagem_entity.dart';
import '../../domain/entities/imovel_entity.dart';
import '../stores/hospedagem_form_store.dart';

/// Dialog com formulário para criar ou editar uma [HospedagemEntity].
///
/// Shell fino que exibe os campos em um [AlertDialog] com scroll.
/// Toda a lógica de estado é delegada a [HospedagemFormStore] via MobX.
/// O dialog é meramente um renderizador que reflete as mudanças do store em tempo real.
///
/// ## Padrão: Blueprint/Ser Humano
/// O formulário segue o padrão imutável onde:
/// - [HospedagemFormState] = blueprint em construção (pode ser incompleto)
/// - [HospedagemEntity] = ser humano completo e válido (pronto para persistência)
/// - [HospedagemFormStore] = engenheiro que orquestra as transições
///
/// ## Uso:
/// ```dart
/// final salvo = await FormularioHospedagemDialog.mostrar(
///   context,
///   imoveis: filtroStore.imoveis,
///   hospedagem: hospedagemExistente, // opcional
/// );
/// if (salvo) DsSnackbar.sucesso(context, mensagem: 'Hospedagem salva!');
/// ```
class FormularioHospedagemDialog extends StatefulWidget {
  const FormularioHospedagemDialog({
    super.key,
    required this.imoveis,
    this.hospedagem,
    this.formStoreOverride,
  });

  /// Lista de imóveis disponíveis para o dropdown.
  final List<ImovelEntity> imoveis;

  /// Hospedagem a editar. `null` indica modo de criação.
  final HospedagemEntity? hospedagem;

  /// Override do store para testes — quando fornecido, GetIt não é consultado
  /// e o estado do store não é reinicializado.
  final HospedagemFormStore? formStoreOverride;

  /// Abre o dialog e retorna `true` se o formulário foi salvo com sucesso.
  static Future<bool> mostrar(
    BuildContext context, {
    required List<ImovelEntity> imoveis,
    HospedagemEntity? hospedagem,
    HospedagemFormStore? formStoreOverride,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => FormularioHospedagemDialog(
        imoveis: imoveis,
        hospedagem: hospedagem,
        formStoreOverride: formStoreOverride,
      ),
    );
    return resultado ?? false;
  }

  @override
  State<FormularioHospedagemDialog> createState() =>
      _FormularioHospedagemDialogState();
}

class _FormularioHospedagemDialogState
    extends State<FormularioHospedagemDialog> {
  final _formKey = GlobalKey<FormState>();

  // ── TextEditingControllers — Artefatos puros de UI ──────────────────────────
  // Mantemos aqui apenas porque o Flutter usa para sincronizar com DsTextField.
  // O estado real vive no HospedagemFormStore.formState.

  late final TextEditingController _nomeHospedeCtrl;
  late final TextEditingController _numHospedesCtrl;
  late final TextEditingController _valorTotalCtrl;
  late final TextEditingController _notasCtrl;

  // ── Store MobX ─────────────────────────────────────────────────────────────
  late final HospedagemFormStore _formStore;

  bool get _edicao => widget.hospedagem != null;

  @override
  void initState() {
    super.initState();

    // Usar store injetado (para testes) ou obter via get_it
    _formStore = widget.formStoreOverride ?? sl<HospedagemFormStore>();

    // Inicializar controllers vazios (sincronização em tempo real via Observer)
    _nomeHospedeCtrl = TextEditingController();
    _numHospedesCtrl = TextEditingController();
    _valorTotalCtrl = TextEditingController();
    _notasCtrl = TextEditingController();

    // Quando formStoreOverride é fornecido, o store já está pré-configurado;
    // apenas sincroniza os controllers com o estado existente.
    if (widget.formStoreOverride != null) {
      _nomeHospedeCtrl.text = _formStore.formState.nomeHospede;
      _numHospedesCtrl.text = _formStore.formState.numHospedes;
      _valorTotalCtrl.text = _formStore.formState.valorTotal;
      _notasCtrl.text = _formStore.formState.notas ?? '';
      return;
    }

    // Configurar o estado inicial do formulário
    if (_edicao) {
      _formStore.carregarParaEdicao(widget.hospedagem!);
      // Sincronizar controllers com dados carregados
      _nomeHospedeCtrl.text = _formStore.formState.nomeHospede;
      _numHospedesCtrl.text = _formStore.formState.numHospedes;
      _valorTotalCtrl.text = _formStore.formState.valorTotal;
      _notasCtrl.text = _formStore.formState.notas ?? '';
    } else {
      _formStore.iniciarNovoFormulario();
    }
  }

  @override
  void dispose() {
    _nomeHospedeCtrl.dispose();
    _numHospedesCtrl.dispose();
    _valorTotalCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarCheckIn() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _formStore.formState.checkIn ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Check-in',
    );
    if (data != null) {
      _formStore.atualizarCheckIn(data);
    }
  }

  Future<void> _selecionarCheckOut() async {
    final inicio = _formStore.formState.checkIn ?? DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate:
          (_formStore.formState.checkOut != null &&
              _formStore.formState.checkOut!.isAfter(inicio))
          ? _formStore.formState.checkOut!
          : inicio,
      firstDate: inicio,
      lastDate: DateTime(2030),
      helpText: 'Check-out',
    );
    if (data != null) {
      _formStore.atualizarCheckOut(data);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    // Salvar com ID se for edição, sem ID se for criação
    await _formStore.salvar(idExistente: widget.hospedagem?.id);

    // Verificar se salvou com sucesso (sem erro de submit)
    if (!mounted) return;
    if (_formStore.erroSubmit == null && _formStore.formularioValido) {
      Navigator.of(context).pop(true);
    } else if (!_formStore.formularioValido) {
      // Re-validar após o Observer reconstruir para exibir erros por campo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _formKey.currentState?.validate();
      });
    }
  }

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DsCores.branco,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(DsEspacamentos.radiusMd),
        ),
      ),
      title: Text(
        _edicao ? 'Editar hospedagem' : 'Nova hospedagem',
        style: DsTipografia.titleMedium.copyWith(color: DsCores.cinza900),
      ),
      content: SizedBox(
        width:
            MediaQuery.of(context).size.width >= DsEspacamentos.breakpointTablet
            ? 480
            : MediaQuery.of(context).size.width - DsEspacamentos.md * 2,
        child: Observer(
          builder: (_) {
            final state = _formStore.formState;

            // Sincronizar controllers com o state (sem disparar listeners)
            _nomeHospedeCtrl.text = state.nomeHospede;
            _numHospedesCtrl.text = state.numHospedes;
            _valorTotalCtrl.text = state.valorTotal;
            _notasCtrl.text = state.notas ?? '';

            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Erro de submit (se houver) ────────────────────────────
                    if (state.erros['submit'] != null) ...[
                      _ErroFormulario(mensagem: state.erros['submit']!),
                      const SizedBox(height: DsEspacamentos.md),
                    ],

                    // ── Nome do hóspede ────────────────────────────────────────
                    DsTextField(
                      rotulo: 'Nome do hóspede',
                      controlador: _nomeHospedeCtrl,
                      validador: (v) => state.erros['nomeHospede'],
                    ),
                    const SizedBox(height: DsEspacamentos.md),

                    // ── Datas: Check-in e Check-out ─────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _CampoData(
                            rotulo: 'Check-in',
                            valor: state.checkIn != null
                                ? _formatarData(state.checkIn!)
                                : '—',
                            erro: state.erros['checkIn'],
                            aoTocar: _selecionarCheckIn,
                          ),
                        ),
                        const SizedBox(width: DsEspacamentos.sm),
                        Expanded(
                          child: _CampoData(
                            rotulo: 'Check-out',
                            valor: state.checkOut != null
                                ? _formatarData(state.checkOut!)
                                : '—',
                            erro: state.erros['checkOut'],
                            aoTocar: _selecionarCheckOut,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DsEspacamentos.md),

                    // ── Número de hóspedes e Valor total ───────────────────
                    Row(
                      children: [
                        Expanded(
                          child: DsTextField(
                            rotulo: 'Hóspedes',
                            controlador: _numHospedesCtrl,
                            tipoTeclado: TextInputType.number,
                            validador: (v) => state.erros['numHospedes'],
                          ),
                        ),
                        const SizedBox(width: DsEspacamentos.sm),
                        Expanded(
                          child: DsTextField(
                            rotulo: 'Valor total (R\$)',
                            controlador: _valorTotalCtrl,
                            tipoTeclado: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validador: (v) => state.erros['valorTotal'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DsEspacamentos.md),

                    // ── Status ─────────────────────────────────────────────
                    DsDropdown(
                      rotulo: 'Status',
                      opcoes: _opcoesStatus,
                      valorSelecionado: state.status,
                      aoSelecionar: _formStore.atualizarStatus,
                    ),
                    const SizedBox(height: DsEspacamentos.md),

                    // ── Plataforma ─────────────────────────────────────────
                    DsDropdown(
                      rotulo: 'Plataforma',
                      opcoes: _opcoesPlataforma,
                      valorSelecionado: state.plataforma,
                      aoSelecionar: _formStore.atualizarPlataforma,
                    ),

                    // ── Imóvel (se houver) ─────────────────────────────────
                    if (widget.imoveis.isNotEmpty) ...[
                      const SizedBox(height: DsEspacamentos.md),
                      DsDropdown(
                        rotulo: 'Selecione o imóvel',
                        opcoes: widget.imoveis
                            .map(
                              (i) =>
                                  DsOpcaoDropdown(valor: i.id, rotulo: i.nome),
                            )
                            .toList(),
                        valorSelecionado: state.imovelId,
                        aoSelecionar: _formStore.atualizarImovel,
                      ),
                    ],

                    const SizedBox(height: DsEspacamentos.md),

                    // ── Notas ──────────────────────────────────────────────
                    DsTextField(
                      rotulo: 'Notas (opcional)',
                      controlador: _notasCtrl,
                      maxLinhas: 3,
                    ),
                    const SizedBox(height: DsEspacamentos.lg),

                    // ── Botões: Cancelar e Salvar ──────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: state.salvando
                              ? null
                              : () => Navigator.of(context).pop(false),
                          child: Text(
                            'Cancelar',
                            style: DsTipografia.labelLarge.copyWith(
                              color: DsCores.cinza500,
                            ),
                          ),
                        ),
                        const SizedBox(width: DsEspacamentos.sm),
                        DsBotaoPrimario(
                          rotulo: _edicao
                              ? 'Salvar alterações'
                              : 'Criar hospedagem',
                          carregando: state.salvando,
                          aoTocar: state.salvando ? null : _salvar,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Opções de dropdown ────────────────────────────────────────────────────────

const _opcoesStatus = [
  DsOpcaoDropdown(valor: 'confirmada', rotulo: 'Confirmada'),
  DsOpcaoDropdown(valor: 'pendente', rotulo: 'Pendente'),
  DsOpcaoDropdown(valor: 'cancelada', rotulo: 'Cancelada'),
  DsOpcaoDropdown(valor: 'concluida', rotulo: 'Concluída'),
];

const _opcoesPlataforma = [
  DsOpcaoDropdown(valor: 'airbnb', rotulo: 'Airbnb'),
  DsOpcaoDropdown(valor: 'booking', rotulo: 'Booking'),
  DsOpcaoDropdown(valor: 'direto', rotulo: 'Direto'),
  DsOpcaoDropdown(valor: 'outro', rotulo: 'Outro'),
];

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _CampoData extends StatelessWidget {
  const _CampoData({
    required this.rotulo,
    required this.valor,
    required this.aoTocar,
    this.erro,
  });

  final String rotulo;
  final String valor;
  final VoidCallback aoTocar;
  final String? erro;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: aoTocar,
          borderRadius: const BorderRadius.all(
            Radius.circular(DsEspacamentos.radiusSm),
          ),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: rotulo,
              suffixIcon: const Icon(
                Icons.calendar_today,
                size: 18,
                color: DsCores.cinza500,
              ),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(DsEspacamentos.radiusSm),
                ),
                borderSide: BorderSide(
                  color: erro != null ? DsCores.erro : DsCores.cinza300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(DsEspacamentos.radiusSm),
                ),
                borderSide: BorderSide(
                  color: erro != null ? DsCores.erro : DsCores.cinza300,
                ),
              ),
            ),
            child: Text(
              valor,
              style: DsTipografia.bodyLarge.copyWith(color: DsCores.cinza900),
            ),
          ),
        ),
        if (erro != null) ...[
          const SizedBox(height: 4),
          Text(
            erro!,
            style: DsTipografia.bodySmall.copyWith(color: DsCores.erro),
          ),
        ],
      ],
    );
  }
}

class _ErroFormulario extends StatelessWidget {
  const _ErroFormulario({required this.mensagem});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DsEspacamentos.sm),
      decoration: BoxDecoration(
        color: DsCores.erro.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(
          Radius.circular(DsEspacamentos.radiusSm),
        ),
        border: Border.all(color: DsCores.erro.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: DsCores.erro, size: 18),
          const SizedBox(width: DsEspacamentos.xs),
          Expanded(
            child: Text(
              mensagem,
              style: DsTipografia.bodySmall.copyWith(color: DsCores.erro),
            ),
          ),
        ],
      ),
    );
  }
}
