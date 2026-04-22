import 'package:go_router/go_router.dart';

import '../../features/hospedagens/presentation/paginas/hospedagens_pagina.dart';
import '../../features/splash/presentation/paginas/splash_pagina.dart';

/// Configuração das rotas da aplicação com go_router.
///
/// Rotas:
/// - `/splash` → [SplashPagina] (tela inicial)
/// - `/` → [HospedagensPagina]
final roteador = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashPagina()),
    GoRoute(path: '/', builder: (context, state) => const HospedagensPagina()),
  ],
);
