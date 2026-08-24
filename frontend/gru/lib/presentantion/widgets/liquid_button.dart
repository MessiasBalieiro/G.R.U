import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Botão com efeito de preenchimento líquido no hover.
///
/// Ao passar o mouse, um líquido da cor [color] sobe de baixo para cima
/// com uma ondinha no topo, dando a sensação de líquido enchendo o botão.
/// O ícone e o texto mudam gradualmente de [color] para branco conforme
/// o nível sobe.

class LiquidButton extends StatefulWidget {
  const LiquidButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.height = 180.0,
    this.alignStart = false,
    this.maxFillLevel = 0.95, // Limite do preenchimento (ex: 0.75 = 75% da altura)
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double height;

  /// Se [true], ícone e texto ficam lado a lado (para o card Dashboard).
  final bool alignStart;

  /// Porcentagem máxima que o líquido pode subir (de 0.0 a 1.0).
  final double maxFillLevel;

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
    with TickerProviderStateMixin {
  late final AnimationController _fillCtrl;
  late final AnimationController _waveCtrl;
  late final Animation<double> _fillAnim;

  @override
  void initState() {
    super.initState();

    // Controla o nível do líquido
    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    // Mapeia a animação de 0.0 até o widget.maxFillLevel desejado
    _fillAnim = Tween<double>(
      begin: 0.0,
      end: widget.maxFillLevel.clamp(0.0, 1.0),
    ).animate(
      CurvedAnimation(parent: _fillCtrl, curve: Curves.easeInOut),
    );

    // Loop contínuo que anima a onda no topo do líquido
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _fillCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _fillCtrl.forward(),
      onExit: (_) => _fillCtrl.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              // ── 1. Contorno (sempre visível) ──────────────────────────
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: widget.color, width: 1.6),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              // ── 2. Líquido subindo ────────────────────────────────────
              AnimatedBuilder(
                animation: Listenable.merge([_fillAnim, _waveCtrl]),
                builder: (_, __) {
                  if (_fillAnim.value <= 0) return const SizedBox.shrink();
                  return ClipPath(
                    clipper: _LiquidClipper(
                      fillLevel: _fillAnim.value,
                      wavePhase: _waveCtrl.value * 2 * pi,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
              ),

              // ── 3. Conteúdo (ícone + texto, cor animada) ─────────────
              AnimatedBuilder(
                animation: _fillAnim,
                builder: (_, __) {
                  // Ajusta o progresso de transição da cor de acordo com o limite definido
                  final colorProgress = widget.maxFillLevel > 0
                      ? (_fillAnim.value / widget.maxFillLevel).clamp(0.0, 1.0)
                      : 0.0;

                  final contentColor = Color.lerp(
                    widget.color,
                    Colors.white,
                    colorProgress,
                  )!;

                  final icon = Icon(
                    widget.icon,
                    color: contentColor,
                    size: 30,
                  );
                  final label = Text(
                    widget.label,
                    style: TextStyle(
                      color: contentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  );

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: widget.alignStart
                        ? Row(
                            children: [
                              icon,
                              const SizedBox(width: 14),
                              Flexible(child: label),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [icon, label],
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clipa o líquido: retângulo preenchido de baixo para cima com uma
/// ondinha senoidal no topo, animada pelo [wavePhase].
class _LiquidClipper extends CustomClipper<Path> {
  const _LiquidClipper({required this.fillLevel, required this.wavePhase});

  final double fillLevel;
  final double wavePhase;

  @override
  Path getClip(Size size) {
    final fillY = size.height * (1 - fillLevel);
    const waveH = 7.0;
    const waveFreq = 2.5;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, fillY);

    // Senoide suave no topo do líquido
    for (double x = 0; x <= size.width; x += 2) {
      final y = fillY +
          sin((x / size.width * 2 * pi * waveFreq) + wavePhase) *
              waveH *
              fillLevel;
      path.lineTo(x, y);
    }

    path
      ..lineTo(size.width, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(_LiquidClipper old) =>
      old.fillLevel != fillLevel || old.wavePhase != wavePhase;
}