import 'package:flutter/material.dart';

/// Faz o filho "flutuar" suavemente para cima e para baixo.
class Floating extends StatefulWidget {
  const Floating({
    super.key,
    required this.child,
    this.distance = 8,
    this.duration = const Duration(seconds: 3),
  });

  final Widget child;
  final double distance;
  final Duration duration;

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration)
        ..repeat(reverse: true);
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: Curves.easeInOut);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      child: widget.child,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -widget.distance * _a.value),
        child: child,
      ),
    );
  }
}
