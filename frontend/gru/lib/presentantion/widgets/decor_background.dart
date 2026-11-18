import 'package:flutter/material.dart';

/// Fundo de pontinhos discretos (textura sutil).
class DotGridBackground extends StatelessWidget {
  const DotGridBackground({
    super.key,
    this.color = const Color(0x142C3E50),
    this.spacing = 26,
  });

  final Color color;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _DotPainter(color, spacing)),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  _DotPainter(this.color, this.spacing);
  final Color color;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter old) =>
      old.color != color || old.spacing != spacing;
}

enum ArcCorner { topLeft, topRight, bottomLeft, bottomRight }

/// Círculo colorido centrado num canto da tela (aparece só o "quarto" visível).
class CornerArc extends StatelessWidget {
  const CornerArc({
    super.key,
    required this.color,
    required this.radius,
    required this.corner,
  });

  final Color color;
  final double radius;
  final ArcCorner corner;

  @override
  Widget build(BuildContext context) {
    final top = corner == ArcCorner.topLeft || corner == ArcCorner.topRight;
    final left = corner == ArcCorner.topLeft || corner == ArcCorner.bottomLeft;
    return Positioned(
      top: top ? -radius : null,
      bottom: top ? null : -radius,
      left: left ? -radius : null,
      right: left ? null : -radius,
      child: IgnorePointer(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
