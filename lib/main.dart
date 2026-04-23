import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injecao.dart';
import 'core/roteamento/rotas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inicializarDependencias();
  runApp(const MeuAirbnbApp());
}

class MeuAirbnbApp extends StatelessWidget {
  const MeuAirbnbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'meu_airbnb',
      theme: DsTemaApp.tema,
      routerConfig: roteador,
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('pt', 'BR')],
    );
  }
}
