import 'package:get_it/get_it.dart';

import '../../features/hospedagens/data/datasources/hospedagem_local_datasource.dart';
import '../../features/hospedagens/data/repositories/hospedagem_repository_impl.dart';
import '../../features/hospedagens/domain/repositories/hospedagem_repository.dart';
import '../../features/hospedagens/domain/usecases/adicionar_hospedagem.dart';
import '../../features/hospedagens/domain/usecases/atualizar_hospedagem.dart';
import '../../features/hospedagens/domain/usecases/deletar_hospedagem.dart';
import '../../features/hospedagens/domain/usecases/obter_hospedagens.dart';
import '../../features/hospedagens/domain/usecases/obter_imoveis.dart';
import '../sdui/cubit/sdui_cubit.dart';

/// Instância global do service locator.
final sl = GetIt.instance;

/// Inicializa e registra todas as dependências da aplicação.
///
/// Ordem de registro:
/// 1. DataSource (singleton)
/// 2. Repository (singleton)
/// 3. Use cases (factory — nova instância por chamada)
/// 4. SduiCubit (factory)
///
/// Os MobX stores serão registrados no Commit 11.
Future<void> inicializarDependencias() async {
  // ── 1. DataSource ──────────────────────────────────────────────────────────
  sl.registerSingleton<HospedagemLocalDataSource>(HospedagemLocalDataSource());

  // Carrega os assets JSON para memória uma única vez na inicialização.
  await sl<HospedagemLocalDataSource>().inicializar();

  // ── 2. Repository ──────────────────────────────────────────────────────────
  sl.registerSingleton<HospedagemRepository>(
    HospedagemRepositoryImpl(sl<HospedagemLocalDataSource>()),
  );

  // ── 3. Use cases ───────────────────────────────────────────────────────────
  sl.registerFactory(() => ObterHospedagens(sl<HospedagemRepository>()));
  sl.registerFactory(() => AdicionarHospedagem(sl<HospedagemRepository>()));
  sl.registerFactory(() => AtualizarHospedagem(sl<HospedagemRepository>()));
  sl.registerFactory(() => DeletarHospedagem(sl<HospedagemRepository>()));
  sl.registerFactory(() => ObterImoveis(sl<HospedagemRepository>()));

  // ── 4. SduiCubit ───────────────────────────────────────────────────────────
  sl.registerFactory<SduiCubit>(() => SduiCubit());
}
