// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hospedagem_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HospedagemStore on _HospedagemStore, Store {
  late final _$hospedagensAtom = Atom(
    name: '_HospedagemStore.hospedagens',
    context: context,
  );

  @override
  ObservableList<HospedagemEntity> get hospedagens {
    _$hospedagensAtom.reportRead();
    return super.hospedagens;
  }

  @override
  set hospedagens(ObservableList<HospedagemEntity> value) {
    _$hospedagensAtom.reportWrite(value, super.hospedagens, () {
      super.hospedagens = value;
    });
  }

  late final _$carregandoAtom = Atom(
    name: '_HospedagemStore.carregando',
    context: context,
  );

  @override
  bool get carregando {
    _$carregandoAtom.reportRead();
    return super.carregando;
  }

  @override
  set carregando(bool value) {
    _$carregandoAtom.reportWrite(value, super.carregando, () {
      super.carregando = value;
    });
  }

  late final _$erroAtom = Atom(name: '_HospedagemStore.erro', context: context);

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

  late final _$carregarHospedagensAsyncAction = AsyncAction(
    '_HospedagemStore.carregarHospedagens',
    context: context,
  );

  @override
  Future<void> carregarHospedagens() {
    return _$carregarHospedagensAsyncAction.run(
      () => super.carregarHospedagens(),
    );
  }

  late final _$adicionarHospedagemAsyncAction = AsyncAction(
    '_HospedagemStore.adicionarHospedagem',
    context: context,
  );

  @override
  Future<void> adicionarHospedagem(HospedagemEntity hospedagem) {
    return _$adicionarHospedagemAsyncAction.run(
      () => super.adicionarHospedagem(hospedagem),
    );
  }

  late final _$atualizarHospedagemAsyncAction = AsyncAction(
    '_HospedagemStore.atualizarHospedagem',
    context: context,
  );

  @override
  Future<void> atualizarHospedagem(HospedagemEntity hospedagem) {
    return _$atualizarHospedagemAsyncAction.run(
      () => super.atualizarHospedagem(hospedagem),
    );
  }

  late final _$deletarHospedagemAsyncAction = AsyncAction(
    '_HospedagemStore.deletarHospedagem',
    context: context,
  );

  @override
  Future<void> deletarHospedagem(String id) {
    return _$deletarHospedagemAsyncAction.run(
      () => super.deletarHospedagem(id),
    );
  }

  late final _$_HospedagemStoreActionController = ActionController(
    name: '_HospedagemStore',
    context: context,
  );

  @override
  void limparErro() {
    final _$actionInfo = _$_HospedagemStoreActionController.startAction(
      name: '_HospedagemStore.limparErro',
    );
    try {
      return super.limparErro();
    } finally {
      _$_HospedagemStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
hospedagens: ${hospedagens},
carregando: ${carregando},
erro: ${erro}
    ''';
  }
}
