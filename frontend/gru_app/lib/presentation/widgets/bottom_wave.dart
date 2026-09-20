import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_images.dart';

/// Onda laranja do rodapé (Frame_1.svg do Figma), com leve balanço vertical.
/// Deve ser filho direto de um `Stack`.
class BottomWave extends StatefulWidget {
  const BottomWave({super.key, this.height = 120});

  final double height;

  @override
  State<BottomWave> createState() => _BottomWaveState();
}

class _BottomWaveState extends State<BottomWave>
    with SingleTickerProviderStateMixin {
  static const double _amp = 7;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat(reverse: true);
  late final Animation<double> _anim = Tween<double>(begin: -_amp, end: _amp)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: -(_amp + 1),
      height: widget.height + _amp + 1,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _anim,
          child: SvgPicture.asset(AppWaves.orangeBottom, fit: BoxFit.fill),
          builder: (_, child) => Transform.translate(
            offset: Offset(0, _anim.value),
            child: child,
          ),
        ),
      ),
    );
  }
}
