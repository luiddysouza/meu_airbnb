package br.com.meuairbnb.meu_airbnb

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// MainActivity com suporte a MethodChannel para compartilhamento nativo (Intent.ACTION_SEND)
class MainActivity : FlutterActivity() {
  private val CHANNEL = "br.com.meuairbnb.meu_airbnb/share"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "compartilharHospedagem" -> {
          val titulo = call.argument<String>("titulo") ?: "Hospedagem"
          val descricao = call.argument<String>("descricao") ?: ""
          val url = call.argument<String>("url")

          val textoCompartilhamento = construirTextoCompartilhamento(titulo, descricao, url)
          val sucesso = compartilharPorIntent(textoCompartilhamento)

          result.success(sucesso)
        }
        "compartilharLista" -> {
          val titulo = call.argument<String>("titulo") ?: "Hospedagens"
          @Suppress("UNCHECKED_CAST")
          val hospedagens = call.argument<List<Map<String, String>>>("hospedagens") ?: emptyList()

          val textoCompartilhamento = construirTextoLista(titulo, hospedagens)
          val sucesso = compartilharPorIntent(textoCompartilhamento)

          result.success(sucesso)
        }
        else -> result.notImplemented()
      }
    }
  }

  /// Constrói texto formatado para compartilhamento de uma hospedagem.
  /// 
  /// Formato:
  /// ```
  /// 🏠 [TITULO]
  /// 
  /// [DESCRICAO]
  /// 
  /// Compartilhado via meu_airbnb
  /// [URL opcional]
  /// ```
  private fun construirTextoCompartilhamento(titulo: String, descricao: String, url: String?): String {
    val linhas = mutableListOf<String>()
    linhas.add("🏠 $titulo")
    linhas.add("")
    linhas.add(descricao)
    linhas.add("")
    linhas.add("Compartilhado via meu_airbnb")

    if (!url.isNullOrBlank()) {
      linhas.add(url)
    }

    return linhas.joinToString("\n")
  }

  /// Constrói texto formatado para compartilhamento de múltiplas hospedagens.
  /// 
  /// Formato:
  /// ```
  /// 🏠 [TITULO]
  /// 
  /// 1. [Nome] - [Info adicional]
  /// 2. [Nome] - [Info adicional]
  /// ...
  /// 
  /// Compartilhado via meu_airbnb
  /// ```
  private fun construirTextoLista(titulo: String, hospedagens: List<Map<String, String>>): String {
    val linhas = mutableListOf<String>()
    linhas.add("🏠 $titulo")
    linhas.add("")

    hospedagens.forEachIndexed { index, hospedagem ->
      val nome = hospedagem["nome"] ?: "Hospedagem ${index + 1}"
      val info = hospedagem.entries
        .filter { (k, _) -> k != "nome" }
        .joinToString(", ") { (_, v) -> v }

      linhas.add("${index + 1}. $nome")
      if (info.isNotEmpty()) {
        linhas.add("   $info")
      }
    }

    linhas.add("")
    linhas.add("Compartilhado via meu_airbnb")

    return linhas.joinToString("\n")
  }

  /// Dispara Intent.ACTION_SEND com o texto preparado.
  /// 
  /// Retorna true se o Intent foi despachado com sucesso, false em caso contrário.
  /// O sistema operacional exibe um chooser para o usuário selecionar qual app usar.
  private fun compartilharPorIntent(texto: String): Boolean {
    return try {
      val intent = Intent().apply {
        action = Intent.ACTION_SEND
        putExtra(Intent.EXTRA_TEXT, texto)
        type = "text/plain"
      }

      // ACTION_CHOOSER permite visualizar mais opções e garante que o usuário veja todas
      val chooserIntent = Intent.createChooser(intent, "Compartilhar hospedagem via")

      startActivity(chooserIntent)
      true // Sucesso ao disparar intent
    } catch (e: Exception) {
      // Falha (ex: nenhum app de compartilhamento disponível)
      android.util.Log.e("ShareIntent", "Erro ao compartilhar: ${e.message}")
      false
    }
  }
}

