import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/hospedagem_entity.dart';
import '../../domain/entities/imovel_entity.dart';
import '../stores/hospedagem_store.dart';

/// Dialog com formulário para criar ou editar uma [HospedagemEntity].
///
/// Exibe os campos em um [AlertDialog] com scroll. O botão "Salvar" chama
/// a action correspondente do [HospedagemStore] e permanece em estado de
/// carregamento enquanto o use case executa. Em caso de sucesso, fecha o
/// dialog retornando `true`. Em caso de falha, exibe a mensagem de erro
/// sem fechar.
///
/// Uso:
/// ```dart
/// final salvo = await FormularioHospedagemDialog.mostrar(
///   context,
///   hospedagemStore: store,
///   imoveis: filtroStore.imoveis,
/// );
/// if (salvo) DsSnackbar.sucesso(context, mensagem: 'Hospedagem criada!');
/// ```
class FormularioHospedagemDialog extends StatefulWidget {
  const FormularioHospedagemDialog({
    super.key,
    required this.hospedagemStore,
    required this.imoveis,
    this.hospedagem,
  });

  /// Store que executa as actions de CRUD.
  final HospedagemStore hospedagemStore;

  /// Lista de imóveis disponíveis para o dropdown.
  final List<ImovelEntity> imoveis;

  /// Hospedagem a editar. `null` indica modo de criação.
  final HospedagemEntity? hospedagem;

  /// Abre o dialog e retorna `true` se o formulário foi salvo com sucesso.
  static Future<bool> mostrar(
    BuildContext context, {
    required HospedagemStore hospedagemStore,
    required List<ImovelEntity> imoveis,
    HospedagemEntity? hospedagem,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => FormularioHospedagemDialog(
        hospedagemStore: hospedagemStore,
        imoveis: imoveis,
        hospedagem: hospedagem,
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

  late final TextEditingController _nomeHospedeCtrl;
  late final TextEditingController _numHospedesCtrl;
  late final TextEditingController _valorTotalCtrl;
  late final TextEditingController _notasCtrl;

  DateTime? _checkIn;
  DateTime? _checkOut;
  StatusHospedagem? _status;
  Plataforma? _plataforma;
  String? _imovelId;

  bool _salvando = false;
  String? _erroFormulario;

  bool get _edicao => widget.hospedagem != null;

  @override
  void initState() {
    super.initState();
    final h = widget.hospedagem;
    _nomeHospedeCtrl = TextEditingController(text: h?.nomeHospede ?? '');
    _numHospedesCtrl = TextEditingController(
      text: h?.numHospedes.toString() ?? '',
    );
    _valorTotalCtrl = TextEditingController(
      text: h != null ? h.valorTotal.toStringAsFixed(2) : '',
    );
    _notasCtrl = TextEditingController(text: h?.notas ?? '');
    _checkIn = h?.checkIn;
    _checkOut = h?.checkOut;
    _status = h?.status;
    _plataforma = h?.plataforma;
    _imovelId = (h != null && h.imovelId.isNotEmpty) ? h.imovelId : null;

    // Garante que o imovelId existe na lista; se não, ignora.
    if (_imovelId != null && !widget.imoveis.any((i) => i.id == _imovelId)) {
      _imovelId = null;
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
      initialDate: _checkIn ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Check-in',
    );
    if (data != null) {
      setState(() {
        _checkIn = data;
        // Garante que checkOut não fique antes de checkIn.
        if (_checkOut != null && _checkOut!.isBefore(data)) {
          _checkOut = data.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selecionarCheckOut() async {
    final inicio = _checkIn ?? DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: (_checkOut != null && _checkOut!.isAfter(inicio))
          ? _checkOut!
          : inicio,
      firstDate: inicio,
      lastDate: DateTime(2030),
      helpText: 'Check-out',
    );
    if (data != null) {
      setState(() => _checkOut = data);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_checkIn == null || _checkOut == null) {
      setState(
        () => _erroFormulario = 'Selecione as datas de check-in e check-out',
      );
      return;
    }
    if (_status == null || _plataforma == null) {
      setState(() => _erroFormulario = 'Selecione o status e a plataforma');
      return;
    }
    if (widget.imoveis.isNotEmpty && _imovelId == null) {
      setState(() => _erroFormulario = 'Selecione o imóvel');
      return;
    }

    setState(() {
      _salvando = true;
      _erroFormulario = null;
    });

    final hospedagem = HospedagemEntity(
      id: widget.hospedagem?.id ?? '',
      nomeHospede: _nomeHospedeCtrl.text.trim(),
      checkIn: _checkIn!,
      checkOut: _checkOut!,
      numHospedes: int.tryParse(_numHospedesCtrl.text) ?? 1,
      valorTotal:
          double.tryParse(_valorTotalCtrl.text.replaceAll(',', '.')) ?? 0.0,
      status: _status!,
      plataforma: _plataforma!,
      imovelId: _imovelId ?? '',
      notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
      criadoEm: widget.hospedagem?.criadoEm ?? DateTime.now(),
    );

    if (_edicao) {
      await widget.hospedagemStore.atualizarHospedagem(hospedagem);
    } else {
      await widget.hospedagemStore.adicionarHospedagem(hospedagem);
    }

    if (!mounted) return;

    final erro = widget.hospedagemStore.erro;
    if (erro != null) {
      setState(() {
        _salvando = false;
        _erroFormulario = erro;
      });
    } else {
      Navigator.of(context).pop(true);
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
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_erroFormulario != null) ...[
                  _ErroFormulario(mensagem: _erroFormulario!),
                  const SizedBox(height: DsEspacamentos.md),
                ],
                DsTextField(
                  rotulo: 'Nome do hóspede',
                  controlador: _nomeHospedeCtrl,
                  validador: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe o nome do hóspede'
                      : null,
                ),
                const SizedBox(height: DsEspacamentos.md),
                Row(
                  children: [
                    Expanded(
                      child: _CampoData(
                        rotulo: 'Check-in',
                        valor: _checkIn != null
                            ? _formatarData(_checkIn!)
                            : '—',
                        aoTocar: _selecionarCheckIn,
                      ),
                    ),
                    const SizedBox(width: DsEspacamentos.sm),
                    Expanded(
                      child: _CampoData(
                        rotulo: 'Check-out',
                        valor: _checkOut != null
                            ? _formatarData(_checkOut!)
                            : '—',
                        aoTocar: _selecionarCheckOut,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DsEspacamentos.md),
                Row(
                  children: [
                    Expanded(
                      child: DsTextField(
                        rotulo: 'Hóspedes',
                        controlador: _numHospedesCtrl,
                        tipoTeclado: TextInputType.number,
                        validador: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 1) {
                            return 'Mínimo 1';
                          }
                          return null;
                        },
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
                        validador: (v) {
                          final n = double.tryParse(
                            (v ?? '').replaceAll(',', '.'),
                          );
                          if (n == null || n < 0) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DsEspacamentos.md),
                DsDropdown(
                  rotulo: 'Status',
                  opcoes: _opcoesStatus,
                  valorSelecionado: _status?.name,
                  aoSelecionar: (v) {
                    if (v != null) {
                      setState(
                        () => _status = StatusHospedagem.values.firstWhere(
                          (e) => e.name == v,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: DsEspacamentos.md),
                DsDropdown(
                  rotulo: 'Plataforma',
                  opcoes: _opcoesPlataforma,
                  valorSelecionado: _plataforma?.name,
                  aoSelecionar: (v) {
                    if (v != null) {
                      setState(
                        () => _plataforma = Plataforma.values.firstWhere(
                          (e) => e.name == v,
                        ),
                      );
                    }
                  },
                ),
                if (widget.imoveis.isNotEmpty) ...[
                  const SizedBox(height: DsEspacamentos.md),
                  DsDropdown(
                    rotulo: 'Imóvel',
                    opcoes: widget.imoveis
                        .map(
                          (i) => DsOpcaoDropdown(valor: i.id, rotulo: i.nome),
                        )
                        .toList(),
                    valorSelecionado: _imovelId,
                    aoSelecionar: (v) => setState(() => _imovelId = v),
                  ),
                ],
                const SizedBox(height: DsEspacamentos.md),
                DsTextField(
                  rotulo: 'Notas (opcional)',
                  controlador: _notasCtrl,
                  maxLinhas: 3,
                ),
                const SizedBox(height: DsEspacamentos.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _salvando
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
                      carregando: _salvando,
                      aoTocar: _salvando ? null : _salvar,
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          suffixIcon: const Icon(
            Icons.calendar_today,
            size: 18,
            color: DsCores.cinza500,
          ),
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
        ),
        child: Text(
          valor,
          style: DsTipografia.bodyLarge.copyWith(color: DsCores.cinza900),
        ),
      ),
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
