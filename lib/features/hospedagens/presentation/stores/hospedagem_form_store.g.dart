// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hospedagem_form_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HospedagemFormStore on _HospedagemFormStore, Store {
  Computed<bool>? _$formularioValidoComputed;

  @override
  bool get formularioValido => (_$formularioValidoComputed ??= Computed<bool>(
    () => super.formularioValido,
    name: '_HospedagemFormStore.formularioValido',
  )).value;
  Computed<bool>? _$formularioSalvandoComputed;

  @override
  bool get formularioSalvando =>
      (_$formularioSalvandoComputed ??= Computed<bool>(
        () => super.formularioSalvando,
        name: '_HospedagemFormStore.formularioSalvando',
      )).value;
  Computed<String?>? _$erroSubmitComputed;

  @override
  String? get erroSubmit => (_$erroSubmitComputed ??= Computed<String?>(
    () => super.erroSubmit,
    name: '_HospedagemFormStore.erroSubmit',
  )).value;

  late final _$formStateAtom = Atom(
    name: '_HospedagemFormStore.formState',
    context: context,
  );

  @override
  HospedagemFormState get formState {
    _$formStateAtom.reportRead();
    return super.formState;
  }

  @override
  set formState(HospedagemFormState value) {
    _$formStateAtom.reportWrite(value, super.formState, () {
      super.formState = value;
    });
  }

  late final _$salvarAsyncAction = AsyncAction(
    '_HospedagemFormStore.salvar',
    context: context,
  );

  @override
  Future<void> salvar({String? idExistente}) {
    return _$salvarAsyncAction.run(
      () => super.salvar(idExistente: idExistente),
    );
  }

  late final _$_HospedagemFormStoreActionController = ActionController(
    name: '_HospedagemFormStore',
    context: context,
  );

  @override
  void iniciarNovoFormulario() {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.iniciarNovoFormulario',
    );
    try {
      return super.iniciarNovoFormulario();
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void carregarParaEdicao(HospedagemEntity hospedagem) {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.carregarParaEdicao',
    );
    try {
      return super.carregarParaEdicao(hospedagem);
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void atualizarNomeHospede(String valor) {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.atualizarNomeHospede',
    );
    try {
      return super.atualizarNomeHospede(valor);
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void atualizarNumHospedes(String valor) {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.atualizarNumHospedes',
    );
    try {
      return super.atualizarNumHospedes(valor);
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void atualizarValorTotal(String valor) {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.atualizarValorTotal',
    );
    try {
      return super.atualizarValorTotal(valor);
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void atualizarNotas(String? valor) {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.atualizarNotas',
    );
    try {
      return super.atualizarNotas(valor);
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void atualizarCheckIn(DateTime? valor) {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.atualizarCheckIn',
    );
    try {
      return super.atualizarCheckIn(valor);
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void atualizarCheckOut(DateTime? valor) {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.atualizarCheckOut',
    );
    try {
      return super.atualizarCheckOut(valor);
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void atualizarStatus(String? valor) {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.atualizarStatus',
    );
    try {
      return super.atualizarStatus(valor);
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void atualizarPlataforma(String? valor) {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.atualizarPlataforma',
    );
    try {
      return super.atualizarPlataforma(valor);
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void atualizarImovel(String? valor) {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.atualizarImovel',
    );
    try {
      return super.atualizarImovel(valor);
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void atualizarFotoBase64(String? valor) {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.atualizarFotoBase64',
    );
    try {
      return super.atualizarFotoBase64(valor);
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removerFoto() {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.removerFoto',
    );
    try {
      return super.removerFoto();
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void limpar() {
    final _$actionInfo = _$_HospedagemFormStoreActionController.startAction(
      name: '_HospedagemFormStore.limpar',
    );
    try {
      return super.limpar();
    } finally {
      _$_HospedagemFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
formState: ${formState},
formularioValido: ${formularioValido},
formularioSalvando: ${formularioSalvando},
erroSubmit: ${erroSubmit}
    ''';
  }
}
