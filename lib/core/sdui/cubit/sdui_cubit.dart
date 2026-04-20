import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../modelos/no_sdui.dart';
import '../parser/sdui_parser.dart';
import 'sdui_estado.dart';

class SduiCubit extends Cubit<SduiEstado> {
  SduiCubit() : super(const SduiInicial());

  /// Caminho padrão do JSON SDUI dentro dos assets.
  static const String _caminhoAsset = 'assets/mock/tela_hospedagens.json';

  /// Carrega o JSON SDUI do asset e parseia em [List<NoSdui>].
  ///
  /// Emite: [SduiCarregando] → [SduiSucesso] ou [SduiErro].
  Future<void> carregarTela({String caminhoAsset = _caminhoAsset}) async {
    emit(const SduiCarregando());
    try {
      final jsonString = await rootBundle.loadString(caminhoAsset);
      final arvore = SduiParser.parsear(jsonString);
      emit(SduiSucesso(arvore));
    } on FormatException catch (e) {
      emit(SduiErro('JSON inválido: ${e.message}'));
    } catch (e) {
      emit(SduiErro('Erro ao carregar tela: $e'));
    }
  }

  /// Expõe a árvore atual quando o estado é [SduiSucesso], ou null.
  List<NoSdui>? get arvoreAtual =>
      state is SduiSucesso ? (state as SduiSucesso).arvore : null;
}
