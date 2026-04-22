// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on _AuthStore, Store {
  late final _$estaLogadoAtom = Atom(
    name: '_AuthStore.estaLogado',
    context: context,
  );

  @override
  bool get estaLogado {
    _$estaLogadoAtom.reportRead();
    return super.estaLogado;
  }

  @override
  set estaLogado(bool value) {
    _$estaLogadoAtom.reportWrite(value, super.estaLogado, () {
      super.estaLogado = value;
    });
  }

  late final _$carregandoAtom = Atom(
    name: '_AuthStore.carregando',
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

  late final _$erroAtom = Atom(name: '_AuthStore.erro', context: context);

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

  late final _$entrarAsyncAction = AsyncAction(
    '_AuthStore.entrar',
    context: context,
  );

  @override
  Future<void> entrar(String email, String senha) {
    return _$entrarAsyncAction.run(() => super.entrar(email, senha));
  }

  late final _$_AuthStoreActionController = ActionController(
    name: '_AuthStore',
    context: context,
  );

  @override
  void sair() {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
      name: '_AuthStore.sair',
    );
    try {
      return super.sair();
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
estaLogado: ${estaLogado},
carregando: ${carregando},
erro: ${erro}
    ''';
  }
}
