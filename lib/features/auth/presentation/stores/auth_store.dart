import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

// ignore: library_private_types_in_public_api
class AuthStore = _AuthStore with _$AuthStore;

/// Store MobX responsável pela autenticação mock do usuário.
///
/// Simula login verificando se o e-mail não está vazio e a senha tem
/// pelo menos 6 caracteres. Nenhuma chamada de rede real é feita.
abstract class _AuthStore with Store {
  @observable
  bool estaLogado = false;

  @observable
  bool carregando = false;

  @observable
  String? erro;

  @action
  Future<void> entrar(String email, String senha) async {
    carregando = true;
    erro = null;

    // Simula latência de rede.
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (email.trim().isNotEmpty && senha.length >= 6) {
      estaLogado = true;
    } else {
      erro = email.trim().isEmpty
          ? 'Informe o e-mail'
          : 'A senha deve ter pelo menos 6 caracteres';
    }

    carregando = false;
  }

  @action
  void sair() {
    estaLogado = false;
    erro = null;
  }
}
