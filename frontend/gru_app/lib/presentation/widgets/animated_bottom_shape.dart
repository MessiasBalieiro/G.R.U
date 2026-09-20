import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Forma SVG (onda / blob) sempre colada no rodapé da tela, com movimento
/// contínuo e suave (desliza de lado e balança para cima e para baixo).
///
/// Deve ser filho direto de um `Stack` que ocupa a tela inteira
/// (`StackFit.expand`).
///
/// Como garante que nunca apareça vão no rodapé:
///  * o SVG é desenhado mais largo que a tela (sobra dos dois lados), então o
///    deslize lateral nunca mostra a borda do desenho;
///  * ele é posicionado abaixo da borda inferior e uma faixa sólida de
///    [fillColor] cobre o rodapé, inclusive atrás da barra de navegação.
class AnimatedBottomShape extends StatefulWidget {
  const AnimatedBottomShape({
    super.key,
    required this.asset,
    required this.fillColor,
    this.aspectRatio,
    this.height,
    this.drift = 0.05,
    this.bob = 9,
    this.duration = const Duration(seconds: 11),
    this.phase = 0,
  }) : assert(aspectRatio != null || height != null,
            'Informe aspectRatio (largura/altura do SVG) ou height.');

  final String asset;

  /// Cor do preenchimento na borda inferior do SVG (cobre qualquer vão).
  final Color fillColor;

  /// largura / altura do SVG; a altura acompanha a largura da tela.
  final double? aspectRatio;

  /// Altura fixa (alternativa ao [aspectRatio]).
  final double? height;

  /// Deslize lateral máximo, como fração da largura da tela.
  final double drift;

  /// Balanço vertical máximo, em pixels lógicos.
  final double bob;

  final Duration duration;
  final double phase;

  @override
  State<AnimatedBottomShape> createState() => _AnimatedBottomShapeState();
}

class _AnimatedBottomShapeState extends State<AnimatedBottomShape>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            final h = widget.height ?? (w / widget.aspectRatio!);
            final drift = w * widget.drift;
            final sobra = drift + w * 0.02; // sobra em cada lado
            final bob = widget.bob;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Faixa sólida no rodapé (garante zero vão, mesmo com o balanço).
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: bob * 2 + 4,
                  child: ColoredBox(color: widget.fillColor),
                ),
                Positioned(
                  left: -sobra,
                  width: w + sobra * 2,
                  bottom: -bob,
                  height: h + bob,
                  child: AnimatedBuilder(
                    animation: _c,
                    child: SvgPicture.asset(widget.asset, fit: BoxFit.fill),
                    builder: (_, child) {
                      final t = _c.value * 2 * pi + widget.phase;
                      return Transform.translate(
                        offset: Offset(sin(t) * drift, cos(t * 2) * bob),
                        child: child,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
