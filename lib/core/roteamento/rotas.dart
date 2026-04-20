import 'package:go_router/go_router.dart';

import '../../features/hospedagens/presentation/paginas/hospedagens_pagina.dart';

/// Configuração das rotas da aplicação com go_router.
///
/// Rotas:
/// - `/` → [HospedagensPagina]
final roteador = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HospedagensPagina()),
  ],
);
