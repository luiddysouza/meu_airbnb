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
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/// MainActivity com suporte a MethodChannel para compartilhamento nativo (Intent.ACTION_SEND),
/// EventChannel para monitoramento de conectividade e MethodChannel para autenticação biométrica
class MainActivity : FlutterActivity() {
  private val CHANNEL = "br.com.meuairbnb.meu_airbnb/share"
  private val CONECTIVIDADE_EVENT_CHANNEL = "br.com.meuairbnb.meu_airbnb/conectividade"
  private val CONECTIVIDADE_METHOD_CHANNEL = "br.com.meuairbnb.meu_airbnb/conectividade/status"
  private val BIOMETRIC_CHANNEL = "br.com.meuairbnb.meu_airbnb/biometric"

  private var eventSink: EventChannel.EventSink? = null
  private var connectivityManager: ConnectivityManager? = null
  private var networkCallback: ConnectivityManager.NetworkCallback? = null
  private var biometricResult: MethodChannel.Result? = null

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

    // MethodChannel para autenticação biométrica
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BIOMETRIC_CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "autenticar" -> {
          val titulo = call.argument<String>("titulo") ?: "Autenticar"
          val subtitulo = call.argument<String>("subtitulo") ?: ""
          val descricao = call.argument<String>("descricao")

          biometricResult = result
          mostrarPromptBiometrico(titulo, subtitulo, descricao)
        }

        "isBiometricoDisponivel" -> {
          val disponivel = verificarDisponibilidadeBiometria()
          result.success(disponivel)
        }

        "getTipoBiometrico" -> {
          val tipo = obterTipoBiometrico()
          result.success(tipo)
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

  /// Verifica se dispositivo possui sensores biométricos disponíveis.
  /// Retorna true se há fingerprint OU face, false caso contrário.
  private fun verificarDisponibilidadeBiometria(): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      // BiometricManager está disponível a partir de API 29
      return false
    }

    val biometricManager = BiometricManager.from(this)

    return biometricManager.canAuthenticate(
      BiometricManager.Authenticators.BIOMETRIC_STRONG
    ) == BiometricManager.BIOMETRIC_SUCCESS
  }

  /// Obtém tipo de sensor biométrico disponível.
  /// Retorna: "fingerprint", "face", "ambos" ou "nenhum"
  private fun obterTipoBiometrico(): String {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      return "nenhum"
    }

    val biometricManager = BiometricManager.from(this)

    val podeFingerprint = biometricManager.canAuthenticate(
      BiometricManager.Authenticators.BIOMETRIC_WEAK
    ) == BiometricManager.BIOMETRIC_SUCCESS

    // Não há forma nativa de distinguir face de fingerprint no BiometricManager
    // Vamos retornar o que está disponível
    return if (podeFingerprint) {
      "fingerprint" // Simplificado: retorna fingerprint como padrão
    } else {
      "nenhum"
    }
  }

  /// Exibe BiometricPrompt nativo para autenticação.
  /// Chama biometricResult.success(true) em sucesso ou success(false) em cancelamento.
  private fun mostrarPromptBiometrico(
    titulo: String,
    subtitulo: String,
    descricao: String?
  ) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
      // BiometricPrompt requer API 28+
      biometricResult?.success(false)
      return
    }

    val biometricPrompt = BiometricPrompt(this, {
      // Executor para rodar callbacks na main thread
    }, object : BiometricPrompt.AuthenticationCallback() {
      override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
        super.onAuthenticationSucceeded(result)
        biometricResult?.success(true)
      }

      override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
        super.onAuthenticationError(errorCode, errString)
        // Inclui cancelamento do usuário
        biometricResult?.success(false)
      }

      override fun onAuthenticationFailed() {
        super.onAuthenticationFailed()
        biometricResult?.success(false)
      }
    })

    val promptInfo = BiometricPrompt.PromptInfo.Builder()
      .setTitle(titulo)
      .setSubtitle(subtitulo)
      .setDescription(descricao)
      .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
      .setNegativeButtonText("Cancelar")
      .build()

    biometricPrompt.authenticate(promptInfo)
  }
}

