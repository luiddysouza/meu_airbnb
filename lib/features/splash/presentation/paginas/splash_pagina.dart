import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tela inicial exibida por 2 segundos enquanto os recursos da aplicação
/// são inicializados. Redireciona automaticamente para `/login`.
class SplashPagina extends StatefulWidget {
  const SplashPagina({super.key});

  @override
  State<SplashPagina> createState() => _SplashPaginaState();
}

class _SplashPaginaState extends State<SplashPagina> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsCores.branco,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Meu Airbnb',
              style: DsTipografia.titleLarge.copyWith(
                color: DsCores.primaria,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DsEspacamentos.lg),
            const DsCarregando(),
          ],
        ),
      ),
    );
  }
}
