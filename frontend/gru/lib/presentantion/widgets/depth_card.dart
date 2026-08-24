import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Envolve qualquer widget com um efeito de profundidade 3-D:
/// uma "sombra" colorida sólida e deslocada fica atrás do conteúdo,
/// como na foto do design (card G.R.U com brilho verde atrás).
///
/// Em hover, a profundidade aumenta e o card sobe levemente (scale).
/// Funciona em Flutter Web/Desktop via [MouseRegion].
class DepthCard extends StatefulWidget {
  const DepthCard({
    super.key,
    required this.child,
    this.depthColor = AppColors.green,
    this.depthSize = 10.0,
    this.borderRadius = 18.0,
    this.onTap,
  });

  final Widget child;
  final Color depthColor;

  /// Distância entre o card e a camada de profundidade (em pixels).
  final double depthSize;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  State<DepthCard> createState() => _DepthCardState();
}

class _DepthCardState extends State<DepthCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _depthAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _depthAnim = Tween<double>(begin: widget.depthSize, end: widget.depthSize * 1.6)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.035)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) {
            final d = _depthAnim.value;
            return Transform.scale(
              scale: _scaleAnim.value,
              alignment: Alignment.center,
              // Padding extra para dar espaço à camada de profundidade
              // sem cortar o conteúdo
              child: Container(
                margin: EdgeInsets.only(left: d, bottom: d),
                decoration: BoxDecoration(
                  // A "sombra" sólida colorida atrás do card
                  boxShadow: [
                    BoxShadow(
                      color: widget.depthColor,
                      offset: Offset(-d, d),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: child,
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
