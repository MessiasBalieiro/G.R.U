import 'dart:math';

import 'package:flutter/material.dart';

/// Cartão de menu com contorno colorido e efeito de preenchimento líquido
/// (versão touch do `LiquidButton` da web): o líquido sobe ao pressionar e
/// a navegação acontece quando ele termina de encher.
class LiquidCard extends StatefulWidget {
  const LiquidCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.restFill,
    this.height = 104,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// Cor do contorno, do ícone e do líquido.
  final Color color;
  final VoidCallback onTap;

  /// Cor de fundo do cartão em repouso (opcional, para dar contraste).
  final Color? restFill;
  final double height;

  @override
  State<LiquidCard> createState() => _LiquidCardState();
}

class _LiquidCardState extends State<LiquidCard> with TickerProviderStateMixin {
  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();
  late final Animation<double> _level =
      CurvedAnimation(parent: _fill, curve: Curves.easeInOut);

  @override
  void dispose() {
    _fill.dispose();
    _wave.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    await _fill.forward();
    if (!mounted) return;
    widget.onTap();
    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted) _fill.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _fill.forward(),
      onTapCancel: () => _fill.reverse(),
      onTap: _tap,
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.restFill,
                  border: Border.all(color: widget.color, width: 1.8),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_level, _wave]),
                builder: (_, __) {
                  if (_level.value <= 0) return const SizedBox.shrink();
                  return ClipPath(
                    clipper: _LiquidClipper(
                      level: _level.value,
                      phase: _wave.value * 2 * pi,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _level,
                    builder: (_, __) {
                      final c =
                          Color.lerp(widget.color, Colors.white, _level.value)!;
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(widget.icon, color: c, size: 26),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.white70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Retângulo preenchido de baixo para cima com uma ondinha senoidal no topo.
class _LiquidClipper extends CustomClipper<Path> {
  const _LiquidClipper({required this.level, required this.phase});

  final double level;
  final double phase;

  @override
  Path getClip(Size size) {
    final fillY = size.height * (1 - level);
    const waveH = 6.0;
    const freq = 2.5;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, fillY);
    for (double x = 0; x <= size.width; x += 2) {
      final y = fillY + sin((x / size.width * 2 * pi * freq) + phase) * waveH * level;
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_LiquidClipper old) =>
      old.level != level || old.phase != phase;
}
