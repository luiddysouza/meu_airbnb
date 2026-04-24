import 'package:equatable/equatable.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/hospedagem_entity.dart';

/// Estado imutável do formulário de hospedagem — o "blueprint" do ser humano em construção.
///
/// Representa um estado transitório durante o preenchimento do formulário.
/// Pode estar incompleto, inválido ou em processo de montagem. Apenas quando
/// todos os campos estão completos e validados, o blueprint pode ser convertido
/// para uma entidade de domínio (ser humano real).
///
/// O padrão Blueprint/Ser Humano garante:
/// - **Imutabilidade:** `copyWith()` cria novas instâncias, nunca modifica o estado existente
/// - **Validação explícita:** `validate()` retorna um novo estado com erros preenchidos
/// - **Contrato claro:** `toEntity()` falha explicitamente se o estado não for válido
/// - **Reatividade limpa:** Um único `@observable` no MobX store gerencia todas as transições
///
/// ## Uso Típico
/// ```dart
/// // Modo criação
/// var state = HospedagemFormState();
/// state = state.copyWith(nomeHospede: 'João').validate();
/// if (state.valido) {
///   final entity = state.toEntity(id: gerarId());
///   // persistir...
/// }
///
/// // Modo edição (copiar hospedagem existente para blueprint)
/// var state = HospedagemFormState.fromEntity(hospedagemExistente);
/// state = state.copyWith(nomeHospede: 'Maria').validate();
/// ```
class HospedagemFormState extends Equatable {
  // ═══════════════════════════════════════════════════════════════════════════
  // CAMPOS DE FORMULÁRIO — mutable em sentido lógico mas imutáveis em design
  // ═══════════════════════════════════════════════════════════════════════════

  /// Nome do hóspede (vazio = incompleto)
  final String nomeHospede;

  /// Número de hóspedes como String (converte em int no validate ou toEntity)
  final String numHospedes;

  /// Valor total em reais como String (converte em double no validate ou toEntity)
  final String valorTotal;

  /// Notas adicionais (opcional, pode ser vazio)
  final String? notas;

  /// Data de check-in (null = não selecionada)
  final DateTime? checkIn;

  /// Data de check-out (null = não selecionada)
  final DateTime? checkOut;

  /// Status como String do enum.name (null = não selecionado)
  final String? status;

  /// Plataforma como String do enum.name (null = não selecionada)
  final String? plataforma;

  /// ID do imóvel selecionado (vazio = não selecionado)
  final String? imovelId;

  /// Foto do imóvel como base64 (null = não selecionada, vazio = removida)
  final String? fotoBase64;

  // ═══════════════════════════════════════════════════════════════════════════
  // ESTADO DA UI — não são partes do "corpo humano" final
  // ═══════════════════════════════════════════════════════════════════════════

  /// Indica se o formulário está sendo enviado (durante o salvar)
  final bool salvando;

  /// Mapa de erros por campo (chave = nome do campo, valor = mensagem)
  /// Campos possíveis: nomeHospede, numHospedes, valorTotal, checkIn, checkOut,
  /// status, plataforma, imovel, fotoBase64, submit
  final Map<String, String> erros;

  /// Indica se o estado é válido e pode ser convertido para entidade
  final bool valido;

  /// Indica se algum campo foi modificado (dirty state)
  final bool sujo;

  const HospedagemFormState({
    this.nomeHospede = '',
    this.numHospedes = '',
    this.valorTotal = '',
    this.notas,
    this.checkIn,
    this.checkOut,
    this.status,
    this.plataforma,
    this.imovelId,
    this.fotoBase64,
    this.salvando = false,
    this.erros = const {},
    this.valido = false,
    this.sujo = false,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS PÚBLICOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Cria uma cópia do state com alterações seletivas.
  ///
  /// Permite modificar apenas alguns campos mantendo os outros intactos,
  /// preservando a imutabilidade.
  HospedagemFormState copyWith({
    String? nomeHospede,
    String? numHospedes,
    String? valorTotal,
    String? notas,
    DateTime? checkIn,
    DateTime? checkOut,
    String? status,
    String? plataforma,
    String? imovelId,
    String? fotoBase64,
    bool? salvando,
    Map<String, String>? erros,
    bool? valido,
    bool? sujo,
  }) {
    return HospedagemFormState(
      nomeHospede: nomeHospede ?? this.nomeHospede,
      numHospedes: numHospedes ?? this.numHospedes,
      valorTotal: valorTotal ?? this.valorTotal,
      notas: notas ?? this.notas,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      plataforma: plataforma ?? this.plataforma,
      imovelId: imovelId ?? this.imovelId,
      fotoBase64: fotoBase64 ?? this.fotoBase64,
      salvando: salvando ?? this.salvando,
      erros: erros ?? this.erros,
      valido: valido ?? this.valido,
      sujo: sujo ?? this.sujo,
    );
  }

  /// Valida o estado atual e retorna um novo state com erros preenchidos.
  ///
  /// Percorre todos os campos obrigatórios, verifica regras de negócio
  /// e retorna um novo state com:
  /// - `erros` preenchido (mapa vazio se válido)
  /// - `valido` true/false
  ///
  /// Regras de validação:
  /// - **nomeHospede**: não pode ser vazio
  /// - **checkIn**: obrigatório
  /// - **checkOut**: obrigatório e deve ser >= checkIn
  /// - **numHospedes**: >= 1
  /// - **valorTotal**: >= 0
  /// - **status**: obrigatório
  /// - **plataforma**: obrigatório
  HospedagemFormState validate() {
    final novoErros = <String, String>{};

    // Validar nome do hóspede
    if (nomeHospede.trim().isEmpty) {
      novoErros['nomeHospede'] = 'Informe o nome do hóspede';
    }

    // Validar check-in
    if (checkIn == null) {
      novoErros['checkIn'] = 'Selecione o check-in';
    }

    // Validar check-out
    if (checkOut == null) {
      novoErros['checkOut'] = 'Selecione o check-out';
    } else if (checkIn != null && checkOut!.isBefore(checkIn!)) {
      novoErros['checkOut'] = 'Check-out deve ser após check-in';
    }

    // Validar número de hóspedes
    final numHospedesInt = int.tryParse(numHospedes);
    if (numHospedesInt == null || numHospedesInt < 1) {
      novoErros['numHospedes'] = 'Mínimo 1 hóspede';
    }

    // Validar valor total
    final valorTotalDouble = double.tryParse(valorTotal.replaceAll(',', '.'));
    if (valorTotalDouble == null || valorTotalDouble < 0) {
      novoErros['valorTotal'] = 'Valor deve ser >= 0';
    }

    // Validar status
    if (status == null || status!.isEmpty) {
      novoErros['status'] = 'Selecione o status';
    }

    // Validar plataforma
    if (plataforma == null || plataforma!.isEmpty) {
      novoErros['plataforma'] = 'Selecione a plataforma';
    }

    return copyWith(erros: novoErros, valido: novoErros.isEmpty);
  }

  /// Converte o blueprint para uma entidade de domínio (ser humano).
  ///
  /// **Pré-condição:** O estado deve ser válido (`valido == true`).
  /// Se chamado em estado inválido, lança `StateError`.
  ///
  /// Argumentos:
  /// - **id**: ID único da hospedagem (gerado externamente)
  ///
  /// Retorna: `HospedagemEntity` imutável e pronta para persistência.
  HospedagemEntity toEntity({required String id}) {
    if (!valido) {
      throw StateError(
        'Não é possível converter blueprint para entidade se não estiver válido. '
        'Erros: $erros',
      );
    }

    return HospedagemEntity(
      id: id,
      nomeHospede: nomeHospede.trim(),
      checkIn: checkIn!,
      checkOut: checkOut!,
      numHospedes: int.tryParse(numHospedes) ?? 1,
      valorTotal: double.tryParse(valorTotal.replaceAll(',', '.')) ?? 0.0,
      status: StatusHospedagem.values.byName(status!),
      plataforma: Plataforma.values.byName(plataforma!),
      imovelId: imovelId ?? '',
      notas: notas?.trim().isEmpty ?? true ? null : notas!.trim(),
      criadoEm: DateTime.now(),
    );
  }

  /// Cria um blueprint a partir de uma hospedagem existente (modo edição).
  ///
  /// Copia todos os campos da entidade para o state do formulário,
  /// depois aplica validação para garantir que o estado começa como válido.
  ///
  /// Uso típico: quando o usuário clica em "Editar hospedagem".
  static HospedagemFormState fromEntity(HospedagemEntity hospedagem) {
    return HospedagemFormState(
      nomeHospede: hospedagem.nomeHospede,
      numHospedes: hospedagem.numHospedes.toString(),
      valorTotal: hospedagem.valorTotal.toStringAsFixed(2),
      notas: hospedagem.notas,
      checkIn: hospedagem.checkIn,
      checkOut: hospedagem.checkOut,
      status: hospedagem.status.name,
      plataforma: hospedagem.plataforma.name,
      imovelId: hospedagem.imovelId.isEmpty ? null : hospedagem.imovelId,
      fotoBase64: null, // Foto é carregada em runtime, não persistida por ora
      sujo: false,
    ).validate();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EQUATABLE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  List<Object?> get props => [
    nomeHospede,
    numHospedes,
    valorTotal,
    notas,
    checkIn,
    checkOut,
    status,
    plataforma,
    imovelId,
    fotoBase64,
    salvando,
    erros,
    valido,
    sujo,
  ];
}
