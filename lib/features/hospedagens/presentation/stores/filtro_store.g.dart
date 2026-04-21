// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filtro_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FiltroStore on _FiltroStore, Store {
  Computed<List<HospedagemEntity>>? _$hospedagensFiltradasComputed;

  @override
  List<HospedagemEntity> get hospedagensFiltradas =>
      (_$hospedagensFiltradasComputed ??= Computed<List<HospedagemEntity>>(
        () => super.hospedagensFiltradas,
        name: '_FiltroStore.hospedagensFiltradas',
      )).value;

  late final _$todasHospedagensAtom = Atom(
    name: '_FiltroStore.todasHospedagens',
    context: context,
  );

  @override
  ObservableList<HospedagemEntity> get todasHospedagens {
    _$todasHospedagensAtom.reportRead();
    return super.todasHospedagens;
  }

  @override
  set todasHospedagens(ObservableList<HospedagemEntity> value) {
    _$todasHospedagensAtom.reportWrite(value, super.todasHospedagens, () {
      super.todasHospedagens = value;
    });
  }

  late final _$periodoSelecionadoAtom = Atom(
    name: '_FiltroStore.periodoSelecionado',
    context: context,
  );

  @override
  DateTimeRange<DateTime>? get periodoSelecionado {
    _$periodoSelecionadoAtom.reportRead();
    return super.periodoSelecionado;
  }

  @override
  set periodoSelecionado(DateTimeRange<DateTime>? value) {
    _$periodoSelecionadoAtom.reportWrite(value, super.periodoSelecionado, () {
      super.periodoSelecionado = value;
    });
  }

  late final _$imovelSelecionadoIdAtom = Atom(
    name: '_FiltroStore.imovelSelecionadoId',
    context: context,
  );

  @override
  String? get imovelSelecionadoId {
    _$imovelSelecionadoIdAtom.reportRead();
    return super.imovelSelecionadoId;
  }

  @override
  set imovelSelecionadoId(String? value) {
    _$imovelSelecionadoIdAtom.reportWrite(value, super.imovelSelecionadoId, () {
      super.imovelSelecionadoId = value;
    });
  }

  late final _$imoveisAtom = Atom(
    name: '_FiltroStore.imoveis',
    context: context,
  );

  @override
  List<ImovelEntity> get imoveis {
    _$imoveisAtom.reportRead();
    return super.imoveis;
  }

  @override
  set imoveis(List<ImovelEntity> value) {
    _$imoveisAtom.reportWrite(value, super.imoveis, () {
      super.imoveis = value;
    });
  }

  late final _$erroAtom = Atom(name: '_FiltroStore.erro', context: context);

  @override
  String? get erro {
    _$erroAtom.reportRead();
    return super.erro;
  }

  @override
  set erro(String? value) {
    _$erroAtom.reportWrite(value, super.erro, () {
      super.erro = value;
    });
  }

  late final _$carregarImoveisAsyncAction = AsyncAction(
    '_FiltroStore.carregarImoveis',
    context: context,
  );

  @override
  Future<void> carregarImoveis() {
    return _$carregarImoveisAsyncAction.run(() => super.carregarImoveis());
  }

  late final _$_FiltroStoreActionController = ActionController(
    name: '_FiltroStore',
    context: context,
  );

  @override
  void selecionarPeriodo(DateTimeRange<DateTime>? periodo) {
    final _$actionInfo = _$_FiltroStoreActionController.startAction(
      name: '_FiltroStore.selecionarPeriodo',
    );
    try {
      return super.selecionarPeriodo(periodo);
    } finally {
      _$_FiltroStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selecionarImovel(String? id) {
    final _$actionInfo = _$_FiltroStoreActionController.startAction(
      name: '_FiltroStore.selecionarImovel',
    );
    try {
      return super.selecionarImovel(id);
    } finally {
      _$_FiltroStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void limparFiltros() {
    final _$actionInfo = _$_FiltroStoreActionController.startAction(
      name: '_FiltroStore.limparFiltros',
    );
    try {
      return super.limparFiltros();
    } finally {
      _$_FiltroStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
todasHospedagens: ${todasHospedagens},
periodoSelecionado: ${periodoSelecionado},
imovelSelecionadoId: ${imovelSelecionadoId},
imoveis: ${imoveis},
erro: ${erro},
hospedagensFiltradas: ${hospedagensFiltradas}
    ''';
  }
}
