import 'package:flutter/material.dart';

/// Dá "vida" a qualquer botão: ao passar o mouse ele sobe e ganha brilho,
/// ao clicar ele afunda um pouquinho. Não intercepta o clique do filho.
class HoverLift extends StatefulWidget {
  const HoverLift({
    super.key,
    required this.child,
    this.radius = 24,
    this.glowColor = Colors.black,
    this.lift = 3,
    this.scale = 1.04,
    this.enabled = true,
  });

  final Widget child;
  final double radius;
  final Color glowColor;
  final double lift;
  final double scale;
  final bool enabled;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hover = false;
  bool _press = false;

  @override
  Widget build(BuildContext context) {
    final ativo = widget.enabled && _hover;
    final s = _press ? 0.96 : (ativo ? widget.scale : 1.0);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _press = false;
      }),
      child: Listener(
        onPointerDown: (_) => setState(() => _press = true),
        onPointerUp: (_) => setState(() => _press = false),
        onPointerCancel: (_) => setState(() => _press = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transformAlignment: Alignment.center,
          transform: Matrix4.translationValues(
              0, ativo && !_press ? -widget.lift : 0, 0)
            ..scale(s, s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: ativo
                ? [
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
