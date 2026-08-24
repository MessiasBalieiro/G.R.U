import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Constantes de path para as ondas SVG do design.
class AppWaves {
  AppWaves._();

  static const dividerGreen      = 'assets/waves/wave_divider_green.svg';
  static const dividerDark       = 'assets/waves/wave_divider_dark.svg';
  static const cornerGreenTop    = 'assets/waves/wave_corner_green_top.svg';
  static const cornerGreenBottom = 'assets/waves/wave_corner_green_bottom.svg';
  static const cornerDark        = 'assets/waves/wave_corner_dark.svg';
  static const cornerOrange      = 'assets/waves/wave_corner_orange.svg';
  static const topGreen          = 'assets/waves/wave_top_green.svg';
  static const bottomDark        = 'assets/waves/wave_bottom_dark.svg';
  static const bottomOrange      = 'assets/waves/wave_bottom_orange.svg';
}

/// Renderiza uma onda SVG do design com animação suave de vai-e-vem.
class AnimatedSvgWave extends StatefulWidget {
  const AnimatedSvgWave({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.amplitude = 10.0,
    this.period = const Duration(seconds: 5),
    this.horizontal = false,
    this.allowDrawingOutsideViewBox = true,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double amplitude;
  final Duration period;
  final bool horizontal;
  final bool allowDrawingOutsideViewBox;

  @override
  State<AnimatedSvgWave> createState() => _AnimatedSvgWaveState();
}

class _AnimatedSvgWaveState extends State<AnimatedSvgWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.period)
      ..repeat(reverse: true);
    _anim = Tween<double>(
      begin: -widget.amplitude,
      end: widget.amplitude,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      child: SvgPicture.asset(
        widget.assetPath,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        allowDrawingOutsideViewBox: widget.allowDrawingOutsideViewBox,
      ),
      builder: (_, child) => Transform.translate(
        offset: widget.horizontal
            ? Offset(_anim.value, 0)
            : Offset(0, _anim.value),
        child: child,
      ),
    );
  }
}
