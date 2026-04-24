import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../tokens/cores.dart';
import '../../tokens/sombras.dart';

/// Widget que renderiza uma imagem a partir de uma string base64.
///
/// Fornece estados de carregamento (skeleton), sucesso e erro.
/// A decodificação é feita via Image.memory() do Flutter.
///
/// Exemplo:
/// ```dart
/// DsImagemBase64(
///   base64: '${base64EncodedImageString}',
///   altura: 200,
///   largura: 200,
///   borderRadius: 8,
/// )
/// ```
class DsImagemBase64 extends StatefulWidget {
  const DsImagemBase64({
    super.key,
    this.base64,
    this.altura = 150,
    this.largura = double.infinity,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
    this.exibirSkeleton = true,
  });

  /// String base64 da imagem. Se null, exibe ícone de placeholder.
  final String? base64;

  /// Altura da imagem em pixels.
  final double altura;

  /// Largura da imagem em pixels.
  final double largura;

  /// Raio de borda em pixels.
  final double borderRadius;

  /// Como ajustar a imagem no container (BoxFit).
  final BoxFit fit;

  /// Se true, exibe skeleton loading durante decodificação.
  final bool exibirSkeleton;

  @override
  State<DsImagemBase64> createState() => _DsImagemBase64State();
}

class _DsImagemBase64State extends State<DsImagemBase64> {
  late Future<Uint8List?> _decodeFuture;

  @override
  void initState() {
    super.initState();
    _decodeFuture = _decodificarBase64();
  }

  @override
  void didUpdateWidget(DsImagemBase64 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.base64 != widget.base64) {
      _decodeFuture = _decodificarBase64();
    }
  }

  Future<Uint8List?> _decodificarBase64() async {
    try {
      if (widget.base64 == null || widget.base64!.isEmpty) {
        return null;
      }

      final bytes = base64Decode(widget.base64!);
      return bytes;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _decodeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (widget.exibirSkeleton) {
            return _buildSkeleton();
          }
          return _buildPlaceholder();
        }

        if (snapshot.hasError || snapshot.data == null) {
          return _buildPlaceholder();
        }

        return Container(
          height: widget.altura,
          width: widget.largura,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: DsSombras.nivel2,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Image.memory(
              snapshot.data!,
              fit: widget.fit,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: widget.altura,
      width: widget.largura,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: DsCores.cinza100,
        boxShadow: DsSombras.nivel1,
      ),
      child: Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(DsCores.primaria),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: widget.altura,
      width: widget.largura,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: DsCores.cinza100,
        boxShadow: DsSombras.nivel2,
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: DsCores.cinza500,
        ),
      ),
    );
  }
}
