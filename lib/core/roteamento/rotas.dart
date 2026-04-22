import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/paginas/login_pagina.dart';
import '../../features/auth/presentation/stores/auth_store.dart';
import '../../features/hospedagens/presentation/paginas/hospedagens_pagina.dart';
import '../../features/splash/presentation/paginas/splash_pagina.dart';
import '../di/injecao.dart';

/// Configuração das rotas da aplicação com go_router.
///
/// Rotas:
/// - `/splash` → [SplashPagina] (tela inicial)
/// - `/login` → [LoginPagina]
/// - `/` → [HospedagensPagina] (requer autenticação)
final roteador = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final authStore = sl<AuthStore>();
    final path = state.matchedLocation;
    final rotasPublicas = {'/splash', '/login'};
    if (!authStore.estaLogado && !rotasPublicas.contains(path)) {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashPagina()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPagina()),
    GoRoute(path: '/', builder: (context, state) => const HospedagensPagina()),
  ],
);
