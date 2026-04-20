import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/sdui_node.dart';
import '../parser/sdui_parser.dart';
import 'sdui_state.dart';

class SduiCubit extends Cubit<SduiState> {
  SduiCubit() : super(const SduiInitial());

  /// Caminho padrão do JSON SDUI dentro dos assets.
  static const String _caminhoAsset = 'assets/mock/tela_hospedagens.json';

  /// Carrega o JSON SDUI do asset e parseia em [List<SduiNode>].
  ///
  /// Emite: [SduiLoading] → [SduiSuccess] ou [SduiError].
  Future<void> carregarTela({String caminhoAsset = _caminhoAsset}) async {
    emit(const SduiLoading());
    try {
      final jsonString = await rootBundle.loadString(caminhoAsset);
      final arvore = SduiParser.parsear(jsonString);
      emit(SduiSuccess(arvore));
    } on FormatException catch (e) {
      emit(SduiError('JSON inválido: ${e.message}'));
    } catch (e) {
      emit(SduiError('Erro ao carregar tela: $e'));
    }
  }

  /// Expõe a árvore atual quando o estado é [SduiSuccess], ou null.
  List<SduiNode>? get arvoreAtual =>
      state is SduiSuccess ? (state as SduiSuccess).arvore : null;
}
