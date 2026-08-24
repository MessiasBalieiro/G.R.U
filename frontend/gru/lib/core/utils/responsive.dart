import 'package:flutter/material.dart';

/// Pequeno helper de responsividade.
///
/// O design original foi pensado em layout mobile (~390px), mas o projeto
/// também compila para Web/Desktop. Este helper deixa as telas usarem um
/// container central com largura máxima, e decide quando empilhar colunas
/// (mobile) versus colocá-las lado a lado (telas largas).
class Responsive {
  Responsive._();

  static const double mobileBreakpoint = 700;
  static const double maxContentWidth = 1100;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;
}

/// Envolve o conteúdo de uma página em um container centralizado,
/// limitando a largura em telas grandes (comportamento típico de site).
class PageContainer extends StatelessWidget {
  const PageContainer({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
