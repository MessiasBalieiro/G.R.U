import 'package:flutter/material.dart';

/// Formas de onda decorativas: onda "cheia" (para faixas que atravessam
/// a largura toda, como no App/Cadastro de Lixeira/Gerar Relatório) e
/// "blob" de canto (para decorações pequenas presas só no cantinho da
/// tela, como no Dashboard).
class CornerWave extends StatelessWidget {
  const CornerWave({
    super.key,
    required this.color,
    this.height = 90,
    this.corner = WaveCorner.bottomRight,
  });

  final Color color;
  final double height;
  final WaveCorner corner;

  @override
  Widget build(BuildContext context) {
    final painter = _CornerWavePainter(color: color, corner: corner);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: painter, size: Size.infinite),
    );
  }
}

enum WaveCorner { bottomRight, bottomLeft, topRight, topLeft }

class _CornerWavePainter extends CustomPainter {
  _CornerWavePainter({required this.color, required this.corner});

  final Color color;
  final WaveCorner corner;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final w = size.width;
    final h = size.height;

    switch (corner) {
      case WaveCorner.bottomRight:
      case WaveCorner.bottomLeft:
        path.moveTo(0, h * 0.55);
        path.quadraticBezierTo(w * 0.25, h * 0.05, w * 0.5, h * 0.5);
        path.quadraticBezierTo(w * 0.75, h * 0.95, w, h * 0.45);
        path.lineTo(w, h);
        path.lineTo(0, h);
        path.close();
        break;
      case WaveCorner.topRight:
      case WaveCorner.topLeft:
        path.moveTo(0, h * 0.45);
        path.quadraticBezierTo(w * 0.25, h * 0.95, w * 0.5, h * 0.5);
        path.quadraticBezierTo(w * 0.75, h * 0.05, w, h * 0.55);
        path.lineTo(w, 0);
        path.lineTo(0, 0);
        path.close();
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerWavePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.corner != corner;
}

/// Fundo dividido em duas cores por uma linha ondulada vertical com dois
/// "bicos" (S-curve) - usado nas telas de Login (verde à esquerda / escuro
/// à direita) e Cadastro (escuro à esquerda / verde à direita), reproduzindo
/// a curva do design em vez de uma onda genérica.
class SplitWaveBackground extends StatelessWidget {
  const SplitWaveBackground({
    super.key,
    required this.leftColor,
    required this.rightColor,
    this.splitFraction = 0.52,
  });

  final Color leftColor;
  final Color rightColor;

  /// Fração da largura ocupada pelo painel da esquerda (0 a 1), medida
  /// no ponto central (neutro) da onda.
  final double splitFraction;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _SplitWavePainter(
          leftColor: leftColor,
          rightColor: rightColor,
          splitFraction: splitFraction,
        ),
      ),
    );
  }
}

class _SplitWavePainter extends CustomPainter {
  _SplitWavePainter({
    required this.leftColor,
    required this.rightColor,
    required this.splitFraction,
  });

  final Color leftColor;
  final Color rightColor;
  final double splitFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w * splitFraction;
    final amp = w * 0.10;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = rightColor);

    // Pontos-guia da curva (de cima pra baixo), formando um "S" duplo
    // como no design: bico pra fora perto do topo, reentrância no meio,
    // bico pra fora de novo perto da base.
    final points = <Offset>[
      Offset(centerX, 0),
      Offset(centerX + amp, h * 0.22),
      Offset(centerX - amp * 0.55, h * 0.5),
      Offset(centerX + amp * 0.95, h * 0.78),
      Offset(centerX, h),
    ];

    final path = Path()..moveTo(0, 0)..lineTo(points.first.dx, points.first.dy);
    _addCatmullRomSpline(path, points);
    path.lineTo(0, h);
    path.close();

    canvas.drawPath(path, Paint()..color = leftColor);
  }

  /// Adiciona uma spline suave (Catmull-Rom convertida em curvas cúbicas)
  /// passando exatamente pelos pontos informados, evitando "quinas" entre
  /// os segmentos.
  void _addCatmullRomSpline(Path path, List<Offset> pts) {
    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i == 0 ? pts[i] : pts[i - 1];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = (i + 2 < pts.length) ? pts[i + 2] : p2;

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
  }

  @override
  bool shouldRepaint(covariant _SplitWavePainter oldDelegate) => true;
}

/// Blob decorativo de canto, para telas onde a onda fica só "espremida"
/// num cantinho pequeno (como no Dashboard). Diferente do [CornerWave]
/// (feito para faixas largas), essa forma é uma cunha simples ancorada no
/// canto - fica limpa em qualquer proporção largura x altura, sem os
/// "solavancos" que uma onda de duas curvas faz quando comprimida numa
/// caixa pequena.
class CornerBlob extends StatelessWidget {
  const CornerBlob({
    super.key,
    required this.color,
    required this.size,
    this.corner = WaveCorner.bottomRight,
  });

  final Color color;
  final Size size;
  final WaveCorner corner;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: CustomPaint(
        painter: _CornerBlobPainter(color: color, corner: corner),
        size: size,
      ),
    );
  }
}

class _CornerBlobPainter extends CustomPainter {
  _CornerBlobPainter({required this.color, required this.corner});

  final Color color;
  final WaveCorner corner;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    switch (corner) {
      case WaveCorner.topRight:
        path.moveTo(w * 0.25, 0);
        path.quadraticBezierTo(w * 0.95, h * 0.05, w, h * 0.85);
        path.lineTo(w, 0);
        path.close();
        break;
      case WaveCorner.topLeft:
        path.moveTo(w * 0.75, 0);
        path.quadraticBezierTo(w * 0.05, h * 0.05, 0, h * 0.85);
        path.lineTo(0, 0);
        path.close();
        break;
      case WaveCorner.bottomRight:
        path.moveTo(w * 0.25, h);
        path.quadraticBezierTo(w * 0.95, h * 0.95, w, h * 0.15);
        path.lineTo(w, h);
        path.close();
        break;
      case WaveCorner.bottomLeft:
        path.moveTo(w * 0.75, h);
        path.quadraticBezierTo(w * 0.05, h * 0.95, 0, h * 0.15);
        path.lineTo(0, h);
        path.close();
        break;
    }

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CornerBlobPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.corner != corner;
}
