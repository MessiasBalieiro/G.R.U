import 'package:flutter/material.dart';

/// Transição padrão de telas do G.R.U.
///
/// Ao avançar: a nova tela desliza da direita, surge (fade) e "assenta"
/// (escala de 96% a 100%), enquanto a tela anterior recua para a esquerda.
/// Ao voltar, o efeito acontece ao contrário.
class GruPageRoute<T> extends PageRouteBuilder<T> {
  GruPageRoute({required WidgetBuilder builder, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 520),
          reverseTransitionDuration: const Duration(milliseconds: 420),
          transitionsBuilder: _transicao,
        );

  static Widget _transicao(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Esta tela entrando / saindo (push e pop).
    final entradaSlide = animation.drive(
      Tween<Offset>(begin: const Offset(0.16, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
    );
    final entradaFade = animation.drive(
      Tween<double>(begin: 0, end: 1)
          .chain(CurveTween(curve: const Interval(0, 0.75, curve: Curves.easeOut))),
    );
    final entradaEscala = animation.drive(
      Tween<double>(begin: 0.96, end: 1)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
    );

    // Esta tela recuando quando OUTRA é aberta por cima.
    final recuoSlide = secondaryAnimation.drive(
      Tween<Offset>(begin: Offset.zero, end: const Offset(-0.07, 0))
          .chain(CurveTween(curve: Curves.easeInOutCubic)),
    );
    final recuoEscala = secondaryAnimation.drive(
      Tween<double>(begin: 1, end: 0.96)
          .chain(CurveTween(curve: Curves.easeInOutCubic)),
    );

    return SlideTransition(
      position: recuoSlide,
      child: ScaleTransition(
        scale: recuoEscala,
        child: SlideTransition(
          position: entradaSlide,
          child: FadeTransition(
            opacity: entradaFade,
            child: ScaleTransition(scale: entradaEscala, child: child),
          ),
        ),
      ),
    );
  }
}
