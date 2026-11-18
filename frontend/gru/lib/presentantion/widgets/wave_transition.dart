import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Transição de tela em forma de onda: uma faixa colorida de onda varre a
/// tela e, logo atrás dela, a nova tela vai sendo revelada.
///
/// Uso: `WaveTransition.replace(context, const CadastroScreen(), ...)`.
class WaveTransition {
  WaveTransition._();

  static Future<void> replace(
    BuildContext context,
    Widget destino, {
    required bool vindoDaDireita,
    required Color corDaOnda,
    String? nomeDaRota,
  }) {
    return Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        settings: RouteSettings(name: nomeDaRota),
        transitionDuration: const Duration(milliseconds: 1100),
        reverseTransitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => destino,
        transitionsBuilder: (_, animation, __, child) {
          return AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (_, filho) {
              final t = animation.value;
              // Faixa colorida (lidera) e página (vem logo atrás).
              final faixa = Curves.easeInOutCubic.transform((t / 0.8).clamp(0.0, 1.0));
              final pagina = Curves.easeInOutCubic
                  .transform(((t - 0.2) / 0.8).clamp(0.0, 1.0));
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipPath(
                    clipper: _OndaClipper(faixa, vindoDaDireita, 0),
                    child: ColoredBox(color: corDaOnda),
                  ),
                  ClipPath(
                    clipper: _OndaClipper(pagina, vindoDaDireita, math.pi),
                    child: filho,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _OndaClipper extends CustomClipper<Path> {
  _OndaClipper(this.progresso, this.vindoDaDireita, this.fase);

  final double progresso;
  final bool vindoDaDireita;
  final double fase;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final amp = math.min(110.0, w * 0.12);
    final base = vindoDaDireita
        ? w + amp - progresso * (w + 2 * amp)
        : -amp + progresso * (w + 2 * amp);
    final deslocamento = progresso * math.pi * 4 + fase;

    double x(double y) =>
        base + amp * math.sin((y / h) * math.pi * 3 + deslocamento);

    final path = Path();
    if (vindoDaDireita) {
      path.moveTo(w, 0);
      path.lineTo(x(0), 0);
      for (double y = 0; y <= h; y += 6) {
        path.lineTo(x(y), y);
      }
      path.lineTo(x(h), h);
      path.lineTo(w, h);
    } else {
      path.moveTo(0, 0);
      path.lineTo(x(0), 0);
      for (double y = 0; y <= h; y += 6) {
        path.lineTo(x(y), y);
      }
      path.lineTo(x(h), h);
      path.lineTo(0, h);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _OndaClipper old) =>
      old.progresso != progresso ||
      old.vindoDaDireita != vindoDaDireita ||
      old.fase != fase;
}
