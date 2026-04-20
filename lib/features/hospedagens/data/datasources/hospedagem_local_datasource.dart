import 'dart:convert';

import 'package:flutter/services.dart';

import '../../dominio/entidades/hospedagem_entidade.dart';
import '../../dominio/entidades/imovel_entidade.dart';
import '../modelos/hospedagem_modelo.dart';
import '../modelos/imovel_modelo.dart';

/// Datasource local que carrega os dados mock de assets e os mantém em memória.
///
/// Os assets em `assets/mock/` são **read-only**. Todas as mutações (criar,
/// atualizar, deletar) ocorrem apenas na cópia em memória.
///
/// Cada operação simula latência de rede com [Future.delayed] para reproduzir
/// o comportamento de um datasource remoto real.
class HospedagemLocalDataSource {
  static const String _caminhoHospedagens = 'assets/mock/hospedagens.json';
  static const String _caminhoImoveis = 'assets/mock/imoveis.json';

  List<HospedagemEntidade> _hospedagens = [];
  List<ImovelEntidade> _imoveis = [];
  bool _inicializado = false;

  /// Carrega os dados dos arquivos de asset para memória.
  ///
  /// Deve ser chamado uma única vez na inicialização da aplicação (via [get_it]).
  Future<void> inicializar() async {
    if (_inicializado) return;

    final jsonHospedagens = await rootBundle.loadString(_caminhoHospedagens);
    final jsonImoveis = await rootBundle.loadString(_caminhoImoveis);

    final listaHospedagens = jsonDecode(jsonHospedagens) as List<dynamic>;
    final listaImoveis = jsonDecode(jsonImoveis) as List<dynamic>;

    _hospedagens = listaHospedagens
        .map(
          (e) =>
              HospedagemModelo.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList();

    _imoveis = listaImoveis
        .map((e) => ImovelModelo.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();

    _inicializado = true;
  }

  Future<List<HospedagemEntidade>> obterTodas() async {
    await _simularLatencia();
    return List.unmodifiable(_hospedagens);
  }

  Future<HospedagemEntidade> adicionar(HospedagemEntidade hospedagem) async {
    await _simularLatencia();
    _hospedagens.add(hospedagem);
    return hospedagem;
  }

  Future<HospedagemEntidade> atualizar(HospedagemEntidade hospedagem) async {
    await _simularLatencia();
    final indice = _hospedagens.indexWhere((h) => h.id == hospedagem.id);
    if (indice == -1) {
      throw Exception('Hospedagem com id "${hospedagem.id}" não encontrada.');
    }
    _hospedagens[indice] = hospedagem;
    return hospedagem;
  }

  Future<void> deletar(String id) async {
    await _simularLatencia();
    final removidos = _hospedagens.length;
    _hospedagens.removeWhere((h) => h.id == id);
    if (_hospedagens.length == removidos) {
      throw Exception('Hospedagem com id "$id" não encontrada.');
    }
  }

  Future<List<ImovelEntidade>> obterImoveis() async {
    await _simularLatencia();
    return List.unmodifiable(_imoveis);
  }

  // Simula latência entre 300 ms e 600 ms.
  Future<void> _simularLatencia() =>
      Future.delayed(const Duration(milliseconds: 300));
}
