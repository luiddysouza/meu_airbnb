import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injecao.dart';
import '../stores/auth_store.dart';

/// Tela de login com autenticação mock.
///
/// Valida e-mail e senha localmente, sem chamadas de rede reais.
/// Em caso de sucesso, redireciona para `/`.
class LoginPagina extends StatefulWidget {
  const LoginPagina({super.key});

  @override
  State<LoginPagina> createState() => _LoginPaginaState();
}

class _LoginPaginaState extends State<LoginPagina> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _authStore = sl<AuthStore>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    await _authStore.entrar(_emailCtrl.text.trim(), _senhaCtrl.text);
    if (!mounted) return;
    if (_authStore.estaLogado) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsCores.branco,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DsEspacamentos.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Meu Airbnb',
                    style: DsTipografia.titleLarge.copyWith(
                      color: DsCores.primaria,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DsEspacamentos.xs),
                  Text(
                    'Faça login para continuar',
                    style: DsTipografia.bodyMedium.copyWith(
                      color: DsCores.cinza500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DsEspacamentos.xl),
                  DsTextField(
                    rotulo: 'E-mail',
                    controlador: _emailCtrl,
                    tipoTeclado: TextInputType.emailAddress,
                    prefixIcone: Icons.email_outlined,
                    validador: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe o e-mail'
                        : null,
                  ),
                  const SizedBox(height: DsEspacamentos.md),
                  DsTextField(
                    rotulo: 'Senha',
                    controlador: _senhaCtrl,
                    obscureText: true,
                    prefixIcone: Icons.lock_outline,
                    validador: (v) => (v == null || v.length < 6)
                        ? 'A senha deve ter pelo menos 6 caracteres'
                        : null,
                  ),
                  const SizedBox(height: DsEspacamentos.md),
                  Observer(
                    builder: (_) {
                      if (_authStore.erro != null) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: DsEspacamentos.md,
                          ),
                          child: Text(
                            _authStore.erro!,
                            style: DsTipografia.bodySmall.copyWith(
                              color: DsCores.erro,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Observer(
                    builder: (_) => DsBotaoPrimario(
                      rotulo: 'Entrar',
                      carregando: _authStore.carregando,
                      aoTocar: _authStore.carregando ? null : _entrar,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
