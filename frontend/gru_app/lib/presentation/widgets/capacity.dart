import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/domain_styles.dart';
import '../../data/models/lixeira_model.dart';
import '../../data/models/residuo_model.dart';

/// Barra horizontal de capacidade (animada, cor pela severidade).
class CapacityBar extends StatelessWidget {
  const CapacityBar({super.key, required this.ocupacao, this.height = 8});

  final int ocupacao;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cor = corDoStatus(StatusLixeira.fromOcupacao(ocupacao));
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: (ocupacao / 100).clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.dark.withValues(alpha: 0.08),
                  ),
                ),
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: v,
                    child: ColoredBox(color: cor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Anel de capacidade com a porcentagem no centro.
class CapacityRing extends StatelessWidget {
  const CapacityRing({super.key, required this.ocupacao, this.size = 124});

  final int ocupacao;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cor = corDoStatus(StatusLixeira.fromOcupacao(ocupacao));
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: (ocupacao / 100).clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(progress: v, color: cor),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$ocupacao%',
                    style: TextStyle(
                      fontSize: size * 0.26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ocupada',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - stroke / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.dark.withValues(alpha: 0.08),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

/// Chip de status ("Cheia", "Ocupação média"…).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final StatusLixeira status;

  @override
  Widget build(BuildContext context) {
    final cor = corDoStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: status == StatusLixeira.media
                  ? const Color(0xFF9A6A0E)
                  : cor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip do tipo de resíduo (opcionalmente com a porcentagem).
class MaterialChip extends StatelessWidget {
  const MaterialChip({super.key, required this.tipo, this.percentual});

  final TipoResiduo tipo;
  final int? percentual;

  @override
  Widget build(BuildContext context) {
    final cor = tipo.cor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tipo.icone, size: 13, color: cor),
          const SizedBox(width: 5),
          Text(
            percentual == null ? tipo.label : '${tipo.label} $percentual%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
