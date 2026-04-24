package br.com.meuairbnb.meu_airbnb

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/// MainActivity com suporte a MethodChannel para compartilhamento nativo (Intent.ACTION_SEND)
/// e EventChannel para monitoramento de conectividade
class MainActivity : FlutterActivity() {
  private val CHANNEL = "br.com.meuairbnb.meu_airbnb/share"
  private val CONECTIVIDADE_EVENT_CHANNEL = "br.com.meuairbnb.meu_airbnb/conectividade"
  private val CONECTIVIDADE_METHOD_CHANNEL = "br.com.meuairbnb.meu_airbnb/conectividade/status"
  
  private var eventSink: EventChannel.EventSink? = null
  private var connectivityManager: ConnectivityManager? = null
  private var networkCallback: ConnectivityManager.NetworkCallback? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    // MethodChannel para compartilhamento
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

    // EventChannel para conectividade
    EventChannel(flutterEngine.dartExecutor.binaryMessenger, CONECTIVIDADE_EVENT_CHANNEL).setStreamHandler(
      object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
          eventSink = events
          connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
          iniciarMonitorConectividade()
          // Enviar status atual imediatamente
          enviarStatusConectividade()
        }

        override fun onCancel(arguments: Any?) {
          pararMonitorConectividade()
          eventSink = null
        }
      }
    )

    // MethodChannel para obter status atual de conectividade
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONECTIVIDADE_METHOD_CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "obterStatusAtual" -> {
          result.success(obterStatusConectividadeAtual())
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

  /// Inicia monitoramento de mudanças de conectividade.
  /// Registra NetworkCallback para ouvir eventos de rede.
  private fun iniciarMonitorConectividade() {
    if (connectivityManager == null) {
      connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      // API 24+: Usar NetworkCallback
      networkCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
          super.onAvailable(network)
          enviarStatusConectividade()
        }

        override fun onLost(network: Network) {
          super.onLost(network)
          enviarStatusConectividade()
        }

        override fun onCapabilitiesChanged(
          network: Network,
          networkCapabilities: NetworkCapabilities
        ) {
          super.onCapabilitiesChanged(network, networkCapabilities)
          enviarStatusConectividade()
        }
      }

      val request = NetworkRequest.Builder()
        .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        .build()

      connectivityManager?.registerNetworkCallback(request, networkCallback!!)
    }
  }

  /// Para de monitorar mudanças de conectividade.
  /// Desregistra o NetworkCallback.
  private fun pararMonitorConectividade() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && networkCallback != null) {
      try {
        connectivityManager?.unregisterNetworkCallback(networkCallback!!)
      } catch (e: Exception) {
        android.util.Log.e("Conectividade", "Erro ao desregistrar callback: ${e.message}")
      }
    }
    networkCallback = null
  }

  /// Obtém o status de conectividade atual.
  /// Retorna "online" se há conexão com internet, "offline" caso contrário.
  private fun obterStatusConectividadeAtual(): String {
    val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      val network = connectivityManager.activeNetwork
      val capabilities = connectivityManager.getNetworkCapabilities(network)

      if (capabilities != null && capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)) {
        "online"
      } else {
        "offline"
      }
    } else {
      @Suppress("DEPRECATION")
      val activeNetwork = connectivityManager.activeNetworkInfo
      if (activeNetwork?.isConnectedOrConnecting == true) {
        "online"
      } else {
        "offline"
      }
    }
  }

  /// Envia o status atual de conectividade via EventChannel.
  private fun enviarStatusConectividade() {
    val status = obterStatusConectividadeAtual()
    eventSink?.success(status)
  }
}

